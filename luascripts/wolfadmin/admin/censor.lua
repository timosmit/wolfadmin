
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2019 Timo 'Timothy' Smit

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- at your option any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local admin = wolfa_requireModule("admin.admin")
local mutes = wolfa_requireModule("admin.mutes")
local history = wolfa_requireModule("admin.history")
local auth = wolfa_requireModule("auth.auth")
local config = wolfa_requireModule("config.config")
local output = wolfa_requireModule("game.output")
local players = wolfa_requireModule("players.players")
local events = wolfa_requireModule("util.events")
local toml = wolfa_requireLib("toml")

local censor = {}

local words = {}
local names = {}

function censor.filter(dictionary, subject)
    local censored = false

    for _, item in ipairs(dictionary) do
        local pos1, pos2 = string.find(string.lower(subject), item["pattern"])

        while pos1 and pos2 do
            subject = string.sub(subject, 1, pos1 - 1).."*censor*"..string.sub(subject, pos2 + 1)

            pos1, pos2 = string.find(string.lower(subject), item["pattern"])

            censored = true
        end
    end

    return censored, subject
end

function censor.filterName(name)
    return censor.filter(names, name)
end

function censor.filterMessage(...)
    return censor.filter(words, table.concat({...}, " "))
end

function censor.punishClient(clientId)
    if config.get("g_censorBurn") ~= 0 then
        admin.burnPlayer(clientId)

        output.clientChat("^dburn: ^7"..players.getName(clientId).." ^9burnt his tongue.")
    end

    if config.get("g_censorSlap") ~= 0 then
        admin.slapPlayer(clientId, 20)

        output.clientChat("^dslap: ^7"..players.getName(clientId).." ^9was slapped for his foul language.")
    end

    if config.get("g_censorKill") ~= 0 and config.get("g_censorGib") == 0 then
        admin.killPlayer(clientId)

        output.clientChat("^dkill: ^7"..players.getName(clientId).." ^9stumbled over his words.")
    end

    if config.get("g_censorGib") ~= 0 then
        admin.gibPlayer(clientId)

        output.clientChat("^dgib: ^7"..players.getName(clientId).." ^9should not have said that.")
    end

    if config.get("g_censorMute") > 0 then
        mutes.add(clientId, -1337, players.MUTE_CHAT + players.MUTE_VOICE, config.get("g_censorMute"), "censor")

        if config.get("g_playerHistory") ~= 0 then
            history.add(clientId, -1337, "mute", "censor")
        end

        output.clientChat("^dmute: ^7"..players.getName(clientId).." ^9has been muted for "..config.get("g_censorMute").." seconds")
    end
end

function censor.load()
    local fileName = config.get("g_fileCensor")

    if fileName == "" then
        return 0
    end

    local fileDescriptor, fileLength = et.trap_FS_FOpenFile(fileName, et.FS_READ)

    if fileLength == -1 then
        return 0
    end

    -- in case someone issued a !readconfig, make sure the old data is removed
    censor.clear()

    local fileString = et.trap_FS_Read(fileDescriptor, fileLength)

    et.trap_FS_FCloseFile(fileDescriptor)

    local fileTable = toml.parse(fileString)

    if fileTable["word"] then
        for _, word in ipairs(fileTable["word"]) do
            if word["pattern"] then
                table.insert(words, word)
            end
        end
    end

    if fileTable["name"] then
        for _, name in ipairs(fileTable["name"]) do
            if name["pattern"] then
                table.insert(names, name)
            end
        end
    end

    return #words + #names
end

function censor.clear()
    words = {}
    names = {}
end

function censor.onClientConnectAttempt(clientId, firstTime, isBot)
    if config.get("g_censor") == 0 or auth.isPlayerAllowed(clientId, auth.PERM_NOCENSOR) then
        return
    end

    local clientInfo = et.trap_GetUserinfo(clientId)

    local censored, censoredName = censor.filterName(et.Info_ValueForKey(clientInfo, "name"))

    if censored then
        if config.get("g_censorKick") ~= 0 then
            return "\n\nYou have been kicked, Reason: Name not allowed."
        else
            clientInfo = et.Info_SetValueForKey(clientInfo, "name", censoredName)
            et.trap_SetUserinfo(clientId, clientInfo)
            et.ClientUserinfoChanged(clientId)

            return
        end
    end
end

function censor.onClientNameChange(clientId, oldName, newName)
    if config.get("g_censor") == 0 or auth.isPlayerAllowed(clientId, auth.PERM_NOCENSOR) then
        return
    end

    local censored, censoredName = censor.filterName(newName)

    if censored then
        if config.get("g_censorKick") ~= 0 then
            admin.kickPlayer(clientId, -1337, "Name not allowed.")
        else
            local clientInfo = et.trap_GetUserinfo(clientId)
            clientInfo = et.Info_SetValueForKey(clientInfo, "name", censoredName)
            et.trap_SetUserinfo(clientId, clientInfo)
            et.ClientUserinfoChanged(clientId)
        end
    end
end

function censor.oninit(levelTime, randomSeed, restartMap)
    if config.get("g_standalone") ~= 0 then
        censor.load()

        events.handle("onClientConnectAttempt", censor.onClientConnectAttempt)
        events.handle("onClientNameChange", censor.onClientNameChange)
    end
end
events.handle("onGameInit", censor.oninit)

return censor
