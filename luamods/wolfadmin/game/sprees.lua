
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

local db = require "luamods.wolfadmin.db.db"

local game = require "luamods.wolfadmin.game.game"

local players = require "luamods.wolfadmin.players.players"
-- local stats = require "luamods.wolfadmin.players.stats"

local constants = require "luamods.wolfadmin.util.constants"
local events = require "luamods.wolfadmin.util.events"
local files = require "luamods.wolfadmin.util.files"
local settings = require "luamods.wolfadmin.util.settings"

local sprees = {}

local revivespreeMessages = {
    [3] = {
        ["msg"] = "^dis on a ^2revive spree^d!",
        ["sound"] = "",
    },
    [5] = {
        ["msg"] = "^dis a ^2revive magnet^d!",
        ["sound"] = "",
    },
    [10] = {
        ["msg"] = "^dis a ^2syringe maniac^d!",
        ["sound"] = "",
    },
    [15] = {
        ["msg"] = "^dis the new ^2Dr. Frankenstein^d!",
        ["sound"] = "",
    },
}

local playerSprees = {}
local currentRecords -- cached version
local currentMapId

function sprees.get()
    local records = currentRecords
    
    if records["ksrecord"] and records["ksrecord"] > 0 then
        records["ksname"] = db.getlastalias(records["ksplayer"])["alias"]
    end
    if records["dsrecord"] and records["dsrecord"] > 0 then
        records["dsname"] = db.getlastalias(records["dsplayer"])["alias"]
    end
    if records["rsrecord"] and records["rsrecord"] > 0 then
        records["rsname"] = db.getlastalias(records["rsplayer"])["alias"]
    end
    
    return records
end

function sprees.reset(truncate)
    if truncate then
        db.removeallrecords()
    else
        db.removerecords(currentMapId)
    end
    
    currentRecords = db.getrecords(currentMapId)
end

function sprees.load()
    local map = db.getmap(game.getMap())
    
    if map then
        currentMapId = map["id"]
        db.updatemap(currentMapId, os.time())
    else
        db.addmap(game.getMap(), os.time())
        currentMapId = db.getmap(game.getMap())["id"]
    end
    
    currentRecords = db.getrecords(currentMapId)
    
    return db.getrecordscount(currentMapId)
end

function sprees.oninit(levelTime, randomSeed, restartMap)
    if
        (db.isconnected() and settings.get("g_spreeRecords") ~= 0)
    then
        sprees.load()
        
        events.handle("onGameStateChange", sprees.ongamestatechange)
    end
end
events.handle("onGameInit", sprees.oninit)

function sprees.onconnect(clientId, firstTime, isBot)
    playerSprees[clientId] = {["kill"] = 0, ["death"] = 0, ["revive"] = 0}
end
events.handle("onClientConnect", sprees.onconnect)

function sprees.ondisconnect(clientId)
    playerSprees[clientId] = nil
end
events.handle("onClientDisconnect", sprees.ondisconnect)

function sprees.onteamchange(clientId, old, new)
    playerSprees[clientId] = {["kill"] = 0, ["death"] = 0, ["revive"] = 0}
end

function sprees.ongamestatechange(gameState)
    if gameState == constants.GAME_STATE_RUNNING then
        events.handle("onClientTeamChange", sprees.onteamchange)
        events.handle("onPlayerDeath", sprees.ondeath)
        events.handle("onPlayerRevive", sprees.onrevive)
    elseif gameState == constants.GAME_STATE_INTERMISSION then
        if currentRecords["ksrecord"] and currentRecords["ksrecord"] > 0 then
            if db.getrecord(currentMapId, constants.RECORD_KILL) then
                db.updaterecord(currentMapId, os.time(), constants.RECORD_KILL, currentRecords["ksrecord"], currentRecords["ksplayer"])
            else
                db.addrecord(currentMapId, os.time(), constants.RECORD_KILL, currentRecords["ksrecord"], currentRecords["ksplayer"])
            end
            
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dsprees: ^9longest kill spree (^7"..currentRecords["ksrecord"].."^9) by ^7"..db.getlastalias(currentRecords["ksplayer"])["alias"].."^9.\";")
        end
        if currentRecords["dsrecord"] and currentRecords["dsrecord"] > 0 then
            if db.getrecord(currentMapId, constants.RECORD_DEATH) then
                db.updaterecord(currentMapId, os.time(), constants.RECORD_DEATH, currentRecords["dsrecord"], currentRecords["dsplayer"])
            else
                db.addrecord(currentMapId, os.time(), constants.RECORD_DEATH, currentRecords["dsrecord"], currentRecords["dsplayer"])
            end
            
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dsprees: ^9longest death spree (^7"..currentRecords["dsrecord"].."^9) by ^7"..db.getlastalias(currentRecords["dsplayer"])["alias"].."^9.\";")
        end
        if currentRecords["rsrecord"] and currentRecords["rsrecord"] > 0 then
            if db.getrecord(currentMapId, constants.RECORD_REVIVE) then
                db.updaterecord(currentMapId, os.time(), constants.RECORD_REVIVE, currentRecords["rsrecord"], currentRecords["rsplayer"])
            else
                db.addrecord(currentMapId, os.time(), constants.RECORD_REVIVE, currentRecords["rsrecord"], currentRecords["rsplayer"])
            end
            
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dsprees: ^9longest revive spree (^7"..currentRecords["rsrecord"].."^9) by ^7"..db.getlastalias(currentRecords["rsplayer"])["alias"].."^9.\";")
        end
    end
end

function sprees.ondeath(victimId, killerId, mod)
    if killerId == 1022 then -- killed by map
        playerSprees[victimId]["kill"] = 0
        playerSprees[victimId]["death"] = playerSprees[victimId]["death"] + 1
        playerSprees[victimId]["revive"] = 0
    
        -- stats.set(victimId, "longestDeathSpree", stats.get(victimId, "currentDeathSpree") > stats.get(victimId, "longestDeathSpree") and stats.get(victimId, "currentDeathSpree") or stats.get(victimId, "longestDeathSpree"))

        if (settings.get("g_botRecords") == 1 or not players.isBot(victimId)) and (not currentRecords["dsrecord"] or playerSprees[victimId]["death"] > currentRecords["dsrecord"]) then
            currentRecords["dsplayer"] = db.getplayerid(victimId)
            currentRecords["dsrecord"] = playerSprees[victimId]["death"]
        end
    elseif victimId == killerId then -- suicides
        -- happens when a bot disconnects, it selfkills before leaving, thus emptying the
        -- player data table, resulting in errors. I'm sorry for your spree records, bots.
        if not players.isConnected(victimId) then return end
        
        playerSprees[victimId]["kill"] = 0
        playerSprees[victimId]["death"] = playerSprees[victimId]["death"] + 1
        playerSprees[victimId]["revive"] = 0
        
        -- stats.set(victimId, "longestDeathSpree", stats.get(victimId, "currentDeathSpree") > stats.get(victimId, "longestDeathSpree") and stats.get(victimId, "currentDeathSpree") or stats.get(victimId, "longestDeathSpree"))
        
        if (settings.get("g_botRecords") == 1 or not players.isBot(victimId)) and (not currentRecords["dsrecord"] or playerSprees[victimId]["death"] > currentRecords["dsrecord"]) then
            currentRecords["dsplayer"] = db.getplayerid(victimId)
            currentRecords["dsrecord"] = playerSprees[victimId]["death"]
        end
    else -- regular kills
        if et.gentity_get(victimId, "sess.sessionTeam") == et.gentity_get(killerId, "sess.sessionTeam") then
            -- teamkill handling
        else
            playerSprees[killerId]["kill"] = playerSprees[killerId]["kill"] + 1
            playerSprees[victimId]["death"] = 0
            
            -- stats.set(killerId, "longestKillSpree", stats.get(killerId, "currentKillSpree") > stats.get(killerId, "longestKillSpree") and stats.get(killerId, "currentKillSpree") or stats.get(killerId, "longestKillSpree"))
            
            if (settings.get("g_botRecords") == 1 or not players.isBot(killerId)) and (not currentRecords["ksrecord"] or playerSprees[killerId]["kill"] > currentRecords["ksrecord"]) then
                currentRecords["ksplayer"] = db.getplayerid(killerId)
                currentRecords["ksrecord"] = playerSprees[killerId]["kill"]
            end
            
            -- happens when a bot disconnects, it selfkills before leaving, thus emptying the
            -- player data table, resulting in errors. I'm sorry for your spree records, bots.
            if not players.isConnected(victimId) then return end
            
            playerSprees[victimId]["kill"] = 0
            playerSprees[victimId]["death"] = playerSprees[victimId]["death"] + 1
            playerSprees[victimId]["revive"] = 0
            
            -- stats.set(victimId, "longestDeathSpree", stats.get(victimId, "currentDeathSpree") > stats.get(victimId, "longestDeathSpree") and stats.get(victimId, "currentDeathSpree") or stats.get(victimId, "longestDeathSpree"))
            
            if (settings.get("g_botRecords") == 1 or not players.isBot(victimId)) and (not currentRecords["dsrecord"] or playerSprees[victimId]["death"] > currentRecords["dsrecord"]) then
                currentRecords["dsplayer"] = db.getplayerid(victimId)
                currentRecords["dsrecord"] = playerSprees[victimId]["death"]
            end
        end
    end
end

function sprees.onrevive(clientMedic, clientVictim)
    playerSprees[clientMedic]["revive"] = playerSprees[clientMedic]["revive"] + 1
    -- stats.set(clientMedic, "longestReviveSpree", stats.get(clientMedic, "currentReviveSpree") > stats.get(clientMedic, "longestReviveSpree") and stats.get(clientMedic, "currentReviveSpree") or stats.get(clientMedic, "longestReviveSpree"))
    
    if revivespreeMessages[playerSprees[clientMedic]["revive"]] then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^1REVIVE SPREE! ^*"..players.getName(clientMedic).." ^*"..revivespreeMessages[playerSprees[clientMedic]["revive"]]["msg"].." ^d(^3"..playerSprees[clientMedic]["revive"].." ^drevives in a row!)\";")
    end
    
    if (settings.get("g_botRecords") == 1 or not players.isBot(clientMedic)) and (not currentRecords["rsrecord"] or playerSprees[clientMedic]["revive"] > currentRecords["rsrecord"]) then
        currentRecords["rsplayer"] = db.getplayerid(clientMedic)
        currentRecords["rsrecord"] = playerSprees[clientMedic]["revive"]
    end
end

return sprees
