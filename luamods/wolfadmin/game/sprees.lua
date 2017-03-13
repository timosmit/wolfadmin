
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2017 Timo 'Timothy' Smit

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

local db = require (wolfa_getLuaPath()..".db.db")

local game = require (wolfa_getLuaPath()..".game.game")

local players = require (wolfa_getLuaPath()..".players.players")

local bits = require (wolfa_getLuaPath()..".util.bits")
local constants = require (wolfa_getLuaPath()..".util.constants")
local events = require (wolfa_getLuaPath()..".util.events")
local files = require (wolfa_getLuaPath()..".util.files")
local settings = require (wolfa_getLuaPath()..".util.settings")

local sprees = {}

sprees.RECORD_KILL = 0
sprees.RECORD_DEATH = 1
sprees.RECORD_REVIVE = 2
sprees.RECORD_NUM = 3

sprees.RECORD_KILL_NAME = "kill"
sprees.RECORD_DEATH_NAME = "death"
sprees.RECORD_REVIVE_NAME = "revive"

local spreeNames = {
    [sprees.RECORD_KILL] = sprees.RECORD_KILL_NAME,
    [sprees.RECORD_DEATH] = sprees.RECORD_DEATH_NAME,
    [sprees.RECORD_REVIVE] = sprees.RECORD_REVIVE_NAME
}

local spreeTypes = {
    [sprees.RECORD_KILL_NAME] = sprees.RECORD_KILL,
    [sprees.RECORD_DEATH_NAME] = sprees.RECORD_DEATH,
    [sprees.RECORD_REVIVE_NAME] = sprees.RECORD_REVIVE
}

local spreeMessages = {}
local spreeMessagesByType = {}

local playerSprees = {}
local currentRecords = {} -- cached version
local currentMapId

function sprees.getRecordNameByType(type)
    return spreeNames[type]
end

function sprees.getRecordTypeByName(name)
    return spreeTypes[name]
end

function sprees.get()
    return currentRecords
end

function sprees.reset(truncate)
    if truncate then
        db.removeallrecords()
    else
        db.removerecords(currentMapId)
    end

    currentRecords = {}
end

function sprees.load()
    if db.isconnected() and settings.get("g_spreeRecords") ~= 0 then
        local map = db.getmap(game.getMap())

        if map then
            currentMapId = map["id"]
            db.updatemap(currentMapId, os.time())
        else
            db.addmap(game.getMap(), os.time())
            currentMapId = db.getmap(game.getMap())["id"]
        end

        local records = db.getrecords(currentMapId)

        for _, record in ipairs(records) do
            currentRecords[record["type"]] = {
                ["player"] = tonumber(record["player_id"]),
                ["record"] = tonumber(record["record"])
            }
        end
    end

    local fileName = settings.get("g_fileSprees")

    for i = 0, sprees.RECORD_NUM - 1 do
        spreeMessages[i] = {}
        spreeMessagesByType[i] = {}
    end

    if fileName == "" then
        return 0
    end

    local amount, array = files.loadFromCFG(fileName, "[a-z]+")

    for name, block in pairs(array) do
        for _, spree in ipairs(block) do
            if spree["msg"] then
                for k, v in pairs(spree) do
                    if k == "amount" then
                        spree[k] = tonumber(v)
                    end
                end
                table.insert(spreeMessagesByType[sprees.getRecordTypeByName(name)], spree)

                spreeMessages[sprees.getRecordTypeByName(name)][spree["amount"]] = spree
            end
        end
    end

    return amount
end

function sprees.save()
    if db.isconnected() and settings.get("g_spreeRecords") ~= 0 then
        for i = 0, sprees.RECORD_NUM - 1 do
            if currentRecords[i] and currentRecords[i]["record"] > 0 then
                if db.getrecord(currentMapId, i) then
                    db.updaterecord(currentMapId, os.time(), i, currentRecords[i]["record"], currentRecords[i]["player"])
                else
                    db.addrecord(currentMapId, os.time(), i, currentRecords[i]["record"], currentRecords[i]["player"])
                end
            end
        end
    end
end

function sprees.printRecords()
    if db.isconnected() and settings.get("g_spreeRecords") ~= 0 then
        for i = 0, sprees.RECORD_NUM - 1 do
            if currentRecords[i] and currentRecords[i]["record"] > 0 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dsprees: ^9longest "..sprees.getRecordNameByType(i).." spree (^7"..currentRecords[i]["record"].."^9) by ^7"..db.getlastalias(currentRecords[i]["player"])["alias"].."^9.\";")
            end
        end
    end
end

function sprees.onGameInit(levelTime, randomSeed, restartMap)
    sprees.load()

    events.handle("onGameStateChange", sprees.onGameStateChange)
end
events.handle("onGameInit", sprees.onGameInit)

function sprees.onClientConnect(clientId, firstTime, isBot)
    playerSprees[clientId] = {}

    for i = 0, sprees.RECORD_NUM - 1 do
        playerSprees[clientId][i] = 0
    end
end
events.handle("onClientConnect", sprees.onClientConnect)

function sprees.onClientDisconnect(clientId)
    playerSprees[clientId] = nil
end
events.handle("onClientDisconnect", sprees.onClientDisconnect)

function sprees.onClientTeamChange(clientId, old, new)
    events.trigger("onPlayerSpreeEnd", clientId, clientId)
end

function sprees.onGameStateChange(gameState)
    if gameState == constants.GAME_STATE_RUNNING then
        events.handle("onClientTeamChange", sprees.onClientTeamChange)
        events.handle("onPlayerDeath", sprees.onPlayerDeath)
        events.handle("onPlayerRevive", sprees.onPlayerRevive)
        events.handle("onPlayerSpree", sprees.onPlayerSpree)
        events.handle("onPlayerSpreeEnd", sprees.onPlayerSpreeEnd)
    elseif gameState == constants.GAME_STATE_INTERMISSION then
        sprees.save()
        sprees.printRecords()
    end
end

function sprees.onPlayerSpree(clientId, type, sourceId)
    playerSprees[clientId][type] = playerSprees[clientId][type] + 1

    local currentSpree = playerSprees[clientId][type]

    if db.isconnected() and settings.get("g_spreeRecords") ~= 0 and
            (settings.get("g_botRecords") == 1 or not players.isBot(clientId)) and
            (not currentRecords[type] or currentSpree > currentRecords[type]["record"]) then
        currentRecords[type] = {
            ["player"] = db.getplayerid(clientId),
            ["record"] = currentSpree
        }
    end

    local settingSpreeMessages = settings.get("g_spreeMessages")
    if settingSpreeMessages ~= 0 and bits.hasbit(settingSpreeMessages, 2^type) and #spreeMessagesByType[type] > 0 then
        local spreeMessage = spreeMessages[type][currentSpree]

        if spreeMessage then
            local msg = string.format("^1%s SPREE! ^*%s ^*%s ^d(^3%d ^d%ss in a row!)",
                string.upper(spreeNames[type]),
                players.getName(clientId),
                spreeMessage["msg"],
                currentSpree,
                spreeNames[type])

            if spreeMessage["sound"] and spreeMessage["sound"] ~= "" then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound \"sound/spree/"..spreeMessage["sound"].."\";")
            end

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \""..msg.."\";")
        elseif currentSpree % 5 == 0 then
            local maxSpreeMessage = spreeMessagesByType[type][#spreeMessagesByType[type]]

            local msg = string.format("^1%s SPREE! ^*%s ^*%s ^d(^3%d ^d%ss in a row!)",
                string.upper(spreeNames[type]),
                players.getName(clientId),
                maxSpreeMessage["msg"],
                currentSpree,
                spreeNames[type])

            if maxSpreeMessage["sound"] and maxSpreeMessage["sound"] ~= "" then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound \"sound/spree/"..maxSpreeMessage["sound"].."\";")
            end

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \""..msg.."\";")
        end
    end
end

function sprees.onPlayerSpreeEnd(clientId, causeId, type)
    local settingSpreeMessages = settings.get("g_spreeMessages")

    if type == sprees.RECORD_DEATH then
        if settingSpreeMessages ~= 0 and bits.hasbit(settingSpreeMessages, 2^type) and playerSprees[clientId][sprees.RECORD_DEATH] > spreeMessagesByType[sprees.RECORD_DEATH][1]["amount"] then
            local msg = string.format("^7%s^d was the first victim of ^7%s ^dafter ^3%d ^d%ss!",
                players.getName(causeId),
                players.getName(clientId),
                playerSprees[clientId][sprees.RECORD_DEATH],
                spreeNames[sprees.RECORD_DEATH])

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \""..msg.."\";")
        end

        playerSprees[clientId][sprees.RECORD_DEATH] = 0
    elseif type == nil then
        for i = 0, sprees.RECORD_NUM - 1 do
            if i ~= sprees.RECORD_DEATH then
                if settingSpreeMessages ~= 0 and bits.hasbit(settingSpreeMessages, 2^i) and playerSprees[clientId][i] > spreeMessagesByType[i][1]["amount"] then
                    local msg = ""

                    if clientId == causeId then
                        msg = string.format("^7%s^d's spree (^3%d ^d%ss) was brought to an end by ^1himself^d!",
                            players.getName(clientId),
                            playerSprees[clientId][i],
                            spreeNames[i])
                    elseif causeId then
                        local prefix = ""

                        if et.gentity_get(clientId, "sess.sessionTeam") == et.gentity_get(causeId, "sess.sessionTeam") then
                            prefix = "^1TEAMMATE "
                        end

                        msg = string.format("^7%s^d's spree (^3%d ^d%ss) was brought to an end by %s^7%s^d!",
                            players.getName(clientId),
                            playerSprees[clientId][i],
                            spreeNames[i],
                            prefix,
                            players.getName(causeId))
                    else
                        msg = string.format("^7%s^d's spree (^3%d ^d%ss) was brought to an end.",
                            players.getName(clientId),
                            playerSprees[clientId][i],
                            spreeNames[i])
                    end

                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \""..msg.."\";")
                end

                playerSprees[clientId][i] = 0
            end
        end
    end
end

function sprees.onPlayerDeath(victimId, killerId, mod)
    if killerId == 1022 then -- killed by map
        events.trigger("onPlayerSpreeEnd", victimId)
        events.trigger("onPlayerSpree", victimId, sprees.RECORD_DEATH)
    elseif victimId == killerId then -- suicides
        -- happens when a bot disconnects, it selfkills before leaving, thus emptying the
        -- player data table, resulting in errors. I'm sorry for your spree records, bots.
        if not players.isConnected(victimId) then return end

        events.trigger("onPlayerSpreeEnd", victimId, killerId)
        events.trigger("onPlayerSpree", victimId, sprees.RECORD_DEATH)
    else -- regular kills
        if et.gentity_get(victimId, "sess.sessionTeam") == et.gentity_get(killerId, "sess.sessionTeam") then
            -- teamkill handling
            events.trigger("onPlayerSpreeEnd", victimId, killerId)
            events.trigger("onPlayerSpree", victimId, sprees.RECORD_DEATH)
        else
            events.trigger("onPlayerSpreeEnd", killerId, victimId, sprees.RECORD_DEATH)
            events.trigger("onPlayerSpree", killerId, sprees.RECORD_KILL)

            -- happens when a bot disconnects, it selfkills before leaving, thus emptying the
            -- player data table, resulting in errors. I'm sorry for your spree records, bots.
            if not players.isConnected(victimId) then return end

            events.trigger("onPlayerSpreeEnd", victimId, killerId)
            events.trigger("onPlayerSpree", victimId, sprees.RECORD_DEATH)
        end
    end
end

function sprees.onPlayerRevive(clientMedic, clientVictim)
    events.trigger("onPlayerSpree", clientMedic, sprees.RECORD_REVIVE)
end

return sprees
