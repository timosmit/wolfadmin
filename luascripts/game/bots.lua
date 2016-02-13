
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

local bots = {}

function bots.is(clientId)
    return stats.get(clientId, "isBot")
end

function bots.put(team)
    local team = util.getTeamCode(team)
    
    for playerId = 0, et.trap_Cvar_Get("sv_maxclients") - 1 do
        if wolfa_isPlayer(playerId) and bots.is(playerId) then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "!put "..playerId.." "..team..";")
        end
    end
end

function bots.enable(enable)
    if enable then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "bot minbots -1;")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "bot maxbots "..settings.get("omnibot_maxbots")..";")
    else
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "bot minbots -1;")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "bot maxbots -1;")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "bot kickall;")
    end
end

function bots.oninit(levelTime, randomSeed, restartMap)
end
events.handle("onGameInit", bots.oninit)

return bots