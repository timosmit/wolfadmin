
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2018 Timo 'Timothy' Smit

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
local balancer = require "luascripts.wolfadmin.admin.balancer"
local commands = require "luascripts.wolfadmin.commands.commands"
local bots = require "luascripts.wolfadmin.game.bots"

function commandPutBots(clientId, cmdArguments)
    if cmdArguments[1] == nil and cmdArguments[1] ~= constants.TEAM_AXIS_SC and cmdArguments[1] ~= constants.TEAM_ALLIES_SC and cmdArguments[1] ~= constants.TEAM_SPECTATORS_SC then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dputbots usage: "..commands.getadmin("vmute")["syntax"].."\";")
        
        return true
    end
    
    local team
    if cmdArguments[1] == constants.TEAM_AXIS_SC then
        team = constants.TEAM_AXIS
    elseif cmdArguments[1] == constants.TEAM_ALLIES_SC then
        team = constants.TEAM_ALLIES
    elseif cmdArguments[1] == constants.TEAM_SPECTATORS_SC then
        team = constants.TEAM_SPECTATORS
    end
    
    local teamname = util.getTeamColor(team)..util.getTeamName(team)
    
    bots.put(team)
    
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dputbots: ^9all bots were set to ^7"..teamname.." ^9team.\";")

    if (team == constants.TEAM_AXIS or team == constants.TEAM_ALLIES) and balancer.isRunning() then
        balancer.disable()

        et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dbalancer: ^9balancer disabled.\";")
    end
    
    return true
end
commands.addadmin("putbots", commandPutBots, "p", "puts all bots into a specific team", "^9[r|b|s]")