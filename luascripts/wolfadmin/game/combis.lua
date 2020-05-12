
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

local config = wolfa_requireModule("config.config")
local output = wolfa_requireModule("game.output")
local server = wolfa_requireModule("game.server")
local players = wolfa_requireModule("players.players")
local bits = wolfa_requireModule("util.bits")
local constants = wolfa_requireModule("util.constants")
local events = wolfa_requireModule("util.events")
local timers = wolfa_requireModule("util.timers")

local toml = wolfa_requireLib("toml")

local combis = {}

combis.COMBI_KILL = 0
combis.COMBI_REVIVE = 1
combis.COMBI_NUM = 2

combis.SOUND_PLAY_SELF = 0
combis.SOUND_PLAY_PUBLIC = 1

combis.COMBI_KILL_NAME = "kill"
combis.COMBI_REVIVE_NAME = "revive"

local combiNames = {
    [combis.COMBI_KILL] = combis.COMBI_KILL_NAME,
    [combis.COMBI_REVIVE] = combis.COMBI_REVIVE_NAME
}

local combiTypes = {
    [combis.COMBI_KILL_NAME] = combis.COMBI_KILL,
    [combis.COMBI_REVIVE_NAME] = combis.COMBI_REVIVE
}

local combiMessages = {}
local combiMessagesByType = {}

local playerCombis = {}

function combis.getRecordNameByType(type)
    return combiNames[type]
end

function combis.getRecordTypeByName(name)
    return combiTypes[name]
end

function combis.load()
    for i = 0, combis.COMBI_NUM - 1 do
        combiMessages[i] = {}
        combiMessagesByType[i] = {}
    end

    local fileName = config.get("g_fileCombis")

    if fileName == "" then
        return 0
    end

    if string.find(fileName, ".toml") == string.len(fileName) - 4 then
        local fileDescriptor, fileLength = et.trap_FS_FOpenFile(fileName, et.FS_READ)

        if fileLength == -1 then
            return 0
        end

        local fileString = et.trap_FS_Read(fileDescriptor, fileLength)

        et.trap_FS_FCloseFile(fileDescriptor)

        local fileTable = toml.parse(fileString)

        local amount = 0

        for name, block in pairs(fileTable) do
            for _, combi in ipairs(block) do
                if combi["msg"] then
                    table.insert(combiMessagesByType[combis.getRecordTypeByName(name)], combi)

                    combiMessages[combis.getRecordTypeByName(name)][combi["amount"]] = combi

                    amount = amount + 1
                end
            end
        end

        return amount
    end

    return 0
end

function combis.printCombi(clientId, type)
    local currentCombi = playerCombis[clientId][type]["total"]

    if bits.hasbit(config.get("g_combiMessages"), 2^type) and #combiMessagesByType[type] > 0 then
        local combiMessage = combiMessages[type][currentCombi]

        if combiMessage then
            local msg = string.gsub(combiMessage["msg"], "%[N%]", players.getName(clientId))

            if config.get("g_combiSounds") > 0 and combiMessage["sound"] and combiMessage["sound"] ~= "" then
                if bits.hasbit(config.get("g_combiSounds"), combis.SOUND_PLAY_PUBLIC) then
                    server.exec(string.format("playsound \"sound/combi/%s\";", combiMessage["sound"]))
                else
                    server.exec(string.format("playsound %d \"sound/combi/%s\";", clientId, combiMessage["sound"]))
                end
            end

            output.clientChat(msg)
        end
    end
end

function combis.onGameInit(levelTime, randomSeed, restartMap)
    combis.load()

    events.handle("onGameStateChange", combis.onGameStateChange)
end
events.handle("onGameInit", combis.onGameInit)

function combis.onClientConnect(clientId, firstTime, isBot)
    playerCombis[clientId] = {}

    for i = 0, combis.COMBI_NUM - 1 do
        playerCombis[clientId][i] = {["last"] = nil, ["total"] = 0, ["timer"] = nil}
    end
end
events.handle("onClientConnect", combis.onClientConnect)

function combis.onClientDisconnect(clientId)
    playerCombis[clientId] = nil
end
events.handle("onClientDisconnect", combis.onClientDisconnect)

function combis.onGameStateChange(gameState)
    if gameState == constants.GAME_STATE_RUNNING then
        events.handle("onPlayerDeath", combis.onPlayerDeath)
        events.handle("onPlayerRevive", combis.onPlayerRevive)
        events.handle("onPlayerCombi", combis.onPlayerCombi)
    end
end

function combis.onPlayerCombi(clientId, type, sourceId)
    if not playerCombis[clientId][type]["last"] or et.trap_Milliseconds() - playerCombis[clientId][type]["last"] > config.get("g_combiTime") then
        playerCombis[clientId][type]["total"] = 0
    elseif playerCombis[clientId][type]["timer"] then
        timers.remove(playerCombis[clientId][type]["timer"])
    end

    playerCombis[clientId][type]["last"] = et.trap_Milliseconds()
    playerCombis[clientId][type]["total"] = playerCombis[clientId][type]["total"] + 1
    playerCombis[clientId][type]["timer"] = timers.add(combis.printCombi, config.get("g_combiTime"), 1, clientId, type)
end

function combis.onPlayerDeath(victimId, attackerId, meansOfDeath)
    if attackerId ~= 1022 and victimId ~= attackerId then
        if et.gentity_get(victimId, "sess.sessionTeam") ~= et.gentity_get(attackerId, "sess.sessionTeam") then
            events.trigger("onPlayerCombi", attackerId, combis.COMBI_KILL)
        end
    end
end

function combis.onPlayerRevive(clientMedic, clientVictim)
    events.trigger("onPlayerCombi", clientMedic, combis.COMBI_REVIVE)
end

return combis
