
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

local players = wolfa_requireModule("players.players")

local events = wolfa_requireModule("util.events")
local settings = wolfa_requireModule("util.settings")

local toml = wolfa_requireLib("toml")

local censor = {}

local words = {}
local names = {}

function censor.filterMessage(...)
    local censored = false

    local message = table.concat({...}, " ")

    for _, word in ipairs(words) do
        local occurrences

        message, occurrences = string.gsub(message, word["pattern"], "*censor*")

        censored = (censored or occurrences > 0) and true or false
    end

    return censored, message
end

function censor.punishClient(clientId)
    if settings.get("g_censorMute") > 0 then
        mutes.add(clientId, -1337, players.MUTE_CHAT + players.MUTE_VOICE, settings.get("g_censorMute"), "censor")

        if settings.get("g_playerHistory") ~= 0 then
            history.add(clientId, -1337, "mute", "censor")
        end

        et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dmute: ^7"..players.getName(clientId).." ^9has been muted for "..settings.get("g_censorMute").." seconds\";")
    end
end

function censor.load()
    local fileName = settings.get("g_fileCensor")

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
    if settings.get("g_standalone") ~= 0 then
        local clientInfo = et.trap_GetUserinfo(clientId)

        for _, name in ipairs(names) do
            if string.find(et.Info_ValueForKey(clientInfo, "name"), name["pattern"]) then
                return "\n\nYou have been kicked, Reason: Name not allowed."
            end
        end
    end
end

function censor.onClientNameChange(clientId, oldName, newName)
    for _, name in ipairs(names) do
        if string.find(newName, name["pattern"]) then
            admin.kickPlayer(clientId, -1337, "Name not allowed.")
        end
    end
end

function censor.oninit(levelTime, randomSeed, restartMap)
    if settings.get("g_standalone") ~= 0 then
        censor.load()

        events.handle("onClientConnectAttempt", censor.onClientConnectAttempt)
        events.handle("onClientNameChange", censor.onClientNameChange)
    end
end
events.handle("onGameInit", censor.oninit)

return censor
