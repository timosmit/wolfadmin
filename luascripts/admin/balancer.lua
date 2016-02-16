
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2016 Timo 'Timothy' Smit

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

local constants = require "luascripts.wolfadmin.util.constants"
local util = require "luascripts.wolfadmin.util.util"
local events = require "luascripts.wolfadmin.util.events"
local timers = require "luascripts.wolfadmin.util.timers"
local settings = require "luascripts.wolfadmin.util.settings"

local balancer = {}

local evenerCount = 0

function balancer.balance(byAdmin, forceBalance)
    local teams = {
        [1] = {}, 
        [2] = {}, 
        [3] = {}
    }
    
    for playerId = 0, et.trap_Cvar_Get("sv_maxclients") - 1 do
        if wolfa_isPlayer(playerId) then
            local team = tonumber(et.gentity_get(playerId, "sess.sessionTeam"))
            
            table.insert(teams[team], playerId)
        end
    end
    
    local teamGreater = constants.TEAM_SPECTATORS
    local teamSmaller = constants.TEAM_SPECTATORS
    
    local teamsDifference = math.abs(#teams[constants.TEAM_AXIS] - #teams[constants.TEAM_ALLIES])
    
    if #teams[constants.TEAM_AXIS] > #teams[constants.TEAM_ALLIES] then
        teamGreater = constants.TEAM_AXIS
        teamSmaller = constants.TEAM_ALLIES
    elseif #teams[constants.TEAM_ALLIES] > #teams[constants.TEAM_AXIS] then
        teamGreater = constants.TEAM_ALLIES
        teamSmaller = constants.TEAM_AXIS
    end
    
    local teamGreaterName = util.getTeamName(teamGreater)
    local teamSmallerName = util.getTeamName(teamSmaller)
    
    local teamGreaterColor = util.getTeamColor(teamGreater)
    local teamSmallerColor = util.getTeamColor(teamSmaller)
    
    if settings.get("g_evenerMaxDifference") > 0 and teamsDifference >= settings.get("g_evenerMaxDifference") then
        evenerCount = evenerCount + 1
        
        if forceBalance or evenerCount >= 2 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "!shuffle;")
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cpm \"^devener: ^7THE TEAMS HAVE BEEN ^qSHUFFLED^7!\";")
            
            evenerCount = 0
        else
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cpm \"^devener: ^1EVEN THE TEAMS ^7OR ^1SHUFFLE\";")
        end
    elseif teamsDifference >= settings.get("g_evenerMinDifference") then
        evenerCount = evenerCount + 1
        
        if forceBalance or evenerCount >= 3 then
            for i = 1, (teamsDifference / 2) do
                local rand = math.random(#teams[teamGreater])
                
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "!put "..teams[teamGreater][rand].." "..(teamGreater == constants.TEAM_AXIS and constants.TEAM_ALLIES_SC or constants.TEAM_AXIS_SC)..";")
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^devener: ^9thank you, ^7"..et.gentity_get(teams[teamGreater][rand], "pers.netname")..", ^9for helping to even the teams.\";")
                
                teams[teamSmaller][rand] = teams[teamGreater][rand]
                teams[teamGreater][rand] = nil
            end
            
            evenerCount = 0
        else
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^devener: ^9teams seem unfair, would someone from "..teamGreaterColor..teamGreaterName.." ^9please switch to "..teamSmallerColor..teamSmallerName.."^9?\";")
        end
    else
        evenerCount = 0
        
        if byAdmin then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^devener: ^9teams are even.\";")
        end
    end
end

function balancer.oninit()
    if settings.get("g_evenerInterval") > 0 then
        timers.add(balancer.balance, settings.get("g_evenerInterval") * 1000, 0, false, false)
    end
end
events.handle("onGameInit", balancer.oninit)

return balancer
