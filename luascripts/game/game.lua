
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015 Timo 'Timothy' Smit

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

local util = require "luascripts.wolfadmin.util.util"
local events = require "luascripts.wolfadmin.util.events"
local settings = require "luascripts.wolfadmin.util.settings"
local stats = require "luascripts.wolfadmin.players.stats"

local game = {}

local killCount = 0
local lastKillerId = nil

local currentState = nil
local currentMaps, currentMap, nextMap = {}, nil, nil

function game.getState()
    return currentState
end

function game.getMode()
    return tonumber(et.trap_Cvar_Get("g_gametype"))
end

function game.getMaps()
    return currentMaps
end

function game.getMap()
    return currentMap
end

function game.getNextMap()
    return nextMap
end

function game.oninit()
    local gameType = game.getMode() -- 2: objective, 3: stopwatch, 4: campaign, 5: LMS
    local campaignMaps = tostring(et.trap_Cvar_Get("campaign_maps"))
    local objectiveMaps = tostring(et.trap_Cvar_Get("objective_maps"))
    
    if gameType == 4 then
        currentMaps = util.split(campaignMaps, ",")
    else
        currentMaps = util.split(objectiveMaps, ",")
    end
    
    currentMap = et.trap_Cvar_Get("mapname")
    
    for i, map in ipairs(currentMaps) do
        if map == game.getMap() then nextMap = currentMaps[i + 1] break end
    end
    
    nextMap = nextMap and nextMap or "unknown"
end
events.handle("onGameInit", game.oninit)

function game.onstatechange(gameState)
    currentState = gameState
    
    if gameState == 3 then
        -- do not display when there haven't been any kills
        if lastKillerId ~= nil then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dAnd the last kill of the round goes to.. ^7"..et.gentity_get(lastKillerId, "pers.netname").."^d!\";")
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dA total of ^7"..killCount.." ^dsoldiers died during this battle.\";")
        end
        
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dNext map: ^7"..game.getNextMap().."^d.\";")
    end
end
events.handle("onGameStateChange", game.onstatechange)

function game.ondeath(victimId, killerId, mod)
    if killerId ~= 1022 and victimId ~= killerId then -- regular kills
        lastKillerId = killerId
    end
    
    killCount = killCount + 1
end
events.handle("onPlayerDeath", game.ondeath)

function game.onrevive(clientMedic, clientVictim)
    if settings.get("g_announceRevives") ~= 0 then
        for playerId = 0, et.trap_Cvar_Get("sv_maxclients") - 1 do
            if wolfa_isPlayer(playerId) and tonumber(et.gentity_get(playerId, "sess.sessionTeam")) == tonumber(et.gentity_get(clientMedic, "sess.sessionTeam")) then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..playerId.." \"^drevive: ^7"..et.gentity_get(clientMedic, "pers.netname").." ^9revived ^7"..et.gentity_get(clientVictim, "pers.netname").."^9.\";")
            end
        end
    end
end
events.handle("onPlayerRevive", game.onrevive)

function game.onbegin(clientId, firstTime)
    if firstTime and settings.get("g_welcomeMessage") ~= "" then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \""..settings.get("g_welcomeMessage").."\";")
    end
end
events.handle("onClientBegin", game.onbegin)

return game