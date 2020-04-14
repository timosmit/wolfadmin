
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2020 Timo 'Timothy' Smit

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

local db = wolfa_requireModule("db.db")

local game = wolfa_requireModule("game.game")

local players = wolfa_requireModule("players.players")

local bits = wolfa_requireModule("util.bits")
local constants = wolfa_requireModule("util.constants")
local events = wolfa_requireModule("util.events")
local files = wolfa_requireModule("util.files")
local settings = wolfa_requireModule("util.settings")

local toml = wolfa_requireLib("toml")

local sprees = {}

sprees.RECORD_BOTS_PLAYING = 1
sprees.RECORD_BOTS = 2

sprees.SOUND_PLAY_SELF = 0
sprees.SOUND_PLAY_PUBLIC = 1

sprees.TYPE_KILL = 0
sprees.TYPE_DEATH = 1
sprees.TYPE_REVIVE = 2
sprees.TYPE_NUM = 3

sprees.TYPE_KILL_NAME = "kill"
sprees.TYPE_DEATH_NAME = "death"
sprees.TYPE_REVIVE_NAME = "revive"

local spreeNames = {
    [sprees.TYPE_KILL] = sprees.TYPE_KILL_NAME,
    [sprees.TYPE_DEATH] = sprees.TYPE_DEATH_NAME,
    [sprees.TYPE_REVIVE] = sprees.TYPE_REVIVE_NAME
}

local spreeTypes = {
    [sprees.TYPE_KILL_NAME] = sprees.TYPE_KILL,
    [sprees.TYPE_DEATH_NAME] = sprees.TYPE_DEATH,
    [sprees.TYPE_REVIVE_NAME] = sprees.TYPE_REVIVE
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
        db.removeAllRecords()
    else
        db.removeRecords(currentMapId)
    end

    currentRecords = {}
end

function sprees.load()
    if db.isConnected() and settings.get("g_spreeRecords") ~= 0 then
        local map = db.getMap(game.getMap())

        if map then
            currentMapId = map["id"]
            db.updateMap(currentMapId, os.time())
        else
            db.addMap(game.getMap(), os.time())
            currentMapId = db.getMap(game.getMap())["id"]
        end

        local records = db.getRecords(currentMapId)

        for _, record in ipairs(records) do
            currentRecords[record["type"]] = {
                ["player"] = tonumber(record["player_id"]),
                ["record"] = tonumber(record["record"])
            }
        end
    end

    for i = 0, sprees.TYPE_NUM - 1 do
        spreeMessages[i] = {}
        spreeMessagesByType[i] = {}
    end

    local fileName = settings.get("g_fileSprees")

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
            for _, spree in ipairs(block) do
                if spree["msg"] then
                    table.insert(spreeMessagesByType[sprees.getRecordTypeByName(name)], spree)

                    spreeMessages[sprees.getRecordTypeByName(name)][spree["amount"]] = spree

                    amount = amount + 1
                end
            end
        end

        return amount
    else
        -- compatibility for 1.1.* and lower
        outputDebug("Using .cfg files is deprecated as of 1.2.0. Please consider updating to .toml files.", 3)

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

    return 0
end

function sprees.save()
    if db.isConnected() and settings.get("g_spreeRecords") ~= 0 then
        for i = 0, sprees.TYPE_NUM - 1 do
            if currentRecords[i] and currentRecords[i]["record"] > 0 then
                if db.getRecord(currentMapId, i) then
                    db.updateRecord(currentMapId, os.time(), i, currentRecords[i]["record"], currentRecords[i]["player"])
                else
                    db.addRecord(currentMapId, os.time(), i, currentRecords[i]["record"], currentRecords[i]["player"])
                end
            end
        end
    end
end

function sprees.printRecords()
    if db.isConnected() and settings.get("g_spreeRecords") ~= 0 then
        for i = 0, sprees.TYPE_NUM - 1 do
            if currentRecords[i] and currentRecords[i]["record"] > 0 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dsprees: ^9longest "..sprees.getRecordNameByType(i).." spree (^7"..currentRecords[i]["record"].."^9) by ^7"..db.getLastAlias(currentRecords[i]["player"])["alias"].."^9.\";")
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

    for i = 0, sprees.TYPE_NUM - 1 do
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

function sprees.onPlayerSpree(clientId, causeId, type)
    playerSprees[clientId][type] = playerSprees[clientId][type] + 1

    local currentSpree = playerSprees[clientId][type]

    if db.isConnected() and settings.get("g_spreeRecords") ~= 0 and
            (bits.hasbit(settings.get("g_botRecords"), sprees.RECORD_BOTS_PLAYING) or tonumber(et.trap_Cvar_Get("omnibot_playing")) == 0) and
            (bits.hasbit(settings.get("g_botRecords"), sprees.RECORD_BOTS) or not players.isBot(clientId)) and
            (bits.hasbit(settings.get("g_botRecords"), sprees.RECORD_BOTS) or not players.isBot(causeId)) and
            (not currentRecords[type] or currentSpree > currentRecords[type]["record"])
    then
        currentRecords[type] = {
            ["player"] = db.getPlayerId(clientId),
            ["record"] = currentSpree
        }
    end

    if sprees.isSpreeEnabled(type) and #spreeMessagesByType[type] > 0 then
        local spreeMessage = spreeMessages[type][currentSpree]
        local maxSpreeMessage = spreeMessagesByType[type][#spreeMessagesByType[type]]

        if spreeMessage then
            local msg = string.format("^1%s SPREE! ^*%s ^*%s ^d(^3%d ^d%ss in a row!)",
                string.upper(spreeNames[type]),
                players.getName(clientId),
                spreeMessage["msg"],
                currentSpree,
                spreeNames[type])

            if settings.get("g_spreeSounds") > 0 and spreeMessage["sound"] and spreeMessage["sound"] ~= "" and files.exists("sound/spree/"..spreeMessage["sound"]) then
                if bits.hasbit(settings.get("g_spreeSounds"), sprees.SOUND_PLAY_PUBLIC) then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound \"sound/spree/"..spreeMessage["sound"].."\";")
                else
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound "..clientId.." \"sound/spree/"..spreeMessage["sound"].."\";")
                end
            end

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \""..msg.."\";")
        elseif currentSpree % 5 == 0 and currentSpree > maxSpreeMessage["amount"] then
            local msg = string.format("^1%s SPREE! ^*%s ^*%s ^d(^3%d ^d%ss in a row!)",
                string.upper(spreeNames[type]),
                players.getName(clientId),
                maxSpreeMessage["msg"],
                currentSpree,
                spreeNames[type])

            if settings.get("g_spreeSounds") > 0 and maxSpreeMessage["sound"] and maxSpreeMessage["sound"] ~= "" and files.exists("sound/spree/"..maxSpreeMessage["sound"]) then
                if bits.hasbit(settings.get("g_spreeSounds"), sprees.SOUND_PLAY_PUBLIC) then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound \"sound/spree/"..maxSpreeMessage["sound"].."\";")
                else
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound "..clientId.." \"sound/spree/"..maxSpreeMessage["sound"].."\";")
                end
            end

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \""..msg.."\";")
        end
    end
end

function sprees.onPlayerSpreeEnd(clientId, causeId, type)
    if type == sprees.TYPE_DEATH then
        if sprees.isSpreeEnabled(type) and sprees.isPlayerOnSpree(clientId, sprees.TYPE_DEATH) then
            local msg = string.format("^7%s^d was the first victim of ^7%s ^dafter ^3%d ^d%ss!",
                players.getName(causeId),
                players.getName(clientId),
                playerSprees[clientId][sprees.TYPE_DEATH],
                spreeNames[sprees.TYPE_DEATH])

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \""..msg.."\";")
        end

        playerSprees[clientId][sprees.TYPE_DEATH] = 0
    elseif type == nil then
        for i = 0, sprees.TYPE_NUM - 1 do
            if i ~= sprees.TYPE_DEATH then
                if sprees.isSpreeEnabled(i) and sprees.isPlayerOnSpree(clientId, i) then
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

function sprees.onPlayerDeath(victimId, attackerId, meansOfDeath)
    if attackerId == 1022 then -- killed by map
        events.trigger("onPlayerSpreeEnd", victimId)
        events.trigger("onPlayerSpree", victimId, nil, sprees.TYPE_DEATH)
    elseif victimId == attackerId then -- suicides
        -- happens when a bot disconnects, it selfkills before leaving, thus emptying the
        -- player data table, resulting in errors. I'm sorry for your spree records, bots.
        if not players.isConnected(victimId) then return end

        events.trigger("onPlayerSpreeEnd", victimId, attackerId)
        events.trigger("onPlayerSpree", victimId, attackerId, sprees.TYPE_DEATH)
    else -- regular kills
        if et.gentity_get(victimId, "sess.sessionTeam") == et.gentity_get(attackerId, "sess.sessionTeam") then
            -- teamkill handling
            events.trigger("onPlayerSpreeEnd", victimId, attackerId)
            events.trigger("onPlayerSpree", victimId, attackerId, sprees.TYPE_DEATH)
        else
            events.trigger("onPlayerSpreeEnd", attackerId, victimId, sprees.TYPE_DEATH)
            events.trigger("onPlayerSpree", attackerId, victimId, sprees.TYPE_KILL)

            -- happens when a bot disconnects, it selfkills before leaving, thus emptying the
            -- player data table, resulting in errors. I'm sorry for your spree records, bots.
            if not players.isConnected(victimId) then return end

            events.trigger("onPlayerSpreeEnd", victimId, attackerId)
            events.trigger("onPlayerSpree", victimId, attackerId, sprees.TYPE_DEATH)
        end
    end
end

function sprees.onPlayerRevive(clientMedic, clientVictim)
    events.trigger("onPlayerSpree", clientMedic, clientVictim, sprees.TYPE_REVIVE)
end

function sprees.isSpreeEnabled(type)
    return bits.hasbit(settings.get("g_spreeMessages"), 2^type)
end

function sprees.isPlayerOnSpree(clientId, type)
    return spreeMessagesByType[type][1] and playerSprees[clientId][type] >= spreeMessagesByType[type][1]["amount"]
end

return sprees
