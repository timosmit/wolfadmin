
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

local auth = require "luascripts.wolfadmin.auth.auth"

local commands = require "luascripts.wolfadmin.commands.commands"

local teams = require "luascripts.wolfadmin.game.teams"

local util = require "luascripts.wolfadmin.util.util"
local constants = require "luascripts.wolfadmin.util.constants"
local settings = require "luascripts.wolfadmin.util.settings"

function commandUnlock(clientId, cmdArguments)
    if cmdArguments[1] == nil or (cmdArguments[1] ~= constants.TEAM_AXIS_SC and cmdArguments[1] ~= constants.TEAM_ALLIES_SC and cmdArguments[1] ~= constants.TEAM_SPECTATORS_SC and cmdArguments[1] ~= "all") then
        return false
    end
    
    if cmdArguments[1] == "all" then
        teams.unlock(constants.TEAM_AXIS)
        teams.unlock(constants.TEAM_ALLIES)
        teams.unlock(constants.TEAM_SPECTATORS)
        
        return false
    end
    
    teams.unlock(util.getTeamFromCode(cmdArguments[1]))
    
    return false
end
commands.addadmin("unlock", commandUnlock, auth.PERM_LOCKTEAM, "unlock one or all locked teams", "^9[^3r|b|s|all#^9]", true)

function commandUnlock(clientId, cmdArguments)
    if cmdArguments[1] == nil or (cmdArguments[1] ~= constants.TEAM_AXIS_SC and cmdArguments[1] ~= constants.TEAM_ALLIES_SC and cmdArguments[1] ~= constants.TEAM_SPECTATORS_SC and cmdArguments[1] ~= "all") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dunlock usage: "..commands.getadmin("unlock")["syntax"].."\";")

        return true
    end

    if cmdArguments[1] == "all" then
        teams.unlock(constants.TEAM_AXIS)
        teams.unlock(constants.TEAM_ALLIES)
        teams.unlock(constants.TEAM_SPECTATORS)

        et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dlock: ^9all teams have been unlocked.\";")

        return false
    end

    local team = util.getTeamFromCode(cmdArguments[1])
    teams.unlock(team)

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dlock: "..util.getTeamColor(team)..util.getTeamName(team).." ^9team has been unlocked.\";")

    return false
end
commands.addadmin("unlock", commandUnlock, auth.PERM_LOCKTEAM, "unlock one or all locked teams", "^9[^3r|b|s|all#^9]", (settings.get("g_standalone") == 0))
