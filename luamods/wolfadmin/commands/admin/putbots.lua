
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

local auth = require (wolfa_getLuaPath()..".auth.auth")
local constants = require (wolfa_getLuaPath()..".util.constants")
local util = require (wolfa_getLuaPath()..".util.util")
local balancer = require (wolfa_getLuaPath()..".admin.balancer")
local commands = require (wolfa_getLuaPath()..".commands.commands")
local bots = require (wolfa_getLuaPath()..".game.bots")

function commandPutBots(clientId, command, team)
    if team == nil and team ~= constants.TEAM_AXIS_SC and team ~= constants.TEAM_ALLIES_SC and team ~= constants.TEAM_SPECTATORS_SC then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dputbots usage: "..commands.getadmin("vmute")["syntax"].."\";")
        
        return true
    end

    team = util.getTeamFromCode(team)
    
    bots.put(team)

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dputbots: ^9all bots were set to ^7"..util.getTeamColor(team)..util.getTeamName(team).." ^9team.\";")

    if (team == constants.TEAM_AXIS or team == constants.TEAM_ALLIES) and balancer.isRunning() then
        balancer.disable()

        et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dbalancer: ^9balancer disabled.\";")
    end
    
    return true
end
commands.addadmin("putbots", commandPutBots, auth.PERM_PUT, "puts all bots into a specific team", "^9[r|b|s]")
