
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

function commandLock(clientId, cmdArguments)
    if cmdArguments[1] == nil or (cmdArguments[1] ~= constants.TEAM_AXIS_SC and cmdArguments[1] ~= constants.TEAM_ALLIES_SC and cmdArguments[1] ~= constants.TEAM_SPECTATORS_SC and cmdArguments[1] ~= "all") then
        return false
    end

    if cmdArguments[1] == "all" then
        teams.lock(constants.TEAM_AXIS)
        teams.lock(constants.TEAM_ALLIES)
        teams.lock(constants.TEAM_SPECTATORS)

        return false
    end

    teams.lock(util.getTeamFromCode(cmdArguments[1]))

    return false
end
commands.addadmin("lock", commandLock, auth.PERM_LOCKTEAM, "lock one or all of the teams from players joining", "^9[^3r|b|s|all#^9]", true)

function commandLock(clientId, cmdArguments)
    if cmdArguments[1] == nil or (cmdArguments[1] ~= constants.TEAM_AXIS_SC and cmdArguments[1] ~= constants.TEAM_ALLIES_SC and cmdArguments[1] ~= constants.TEAM_SPECTATORS_SC and cmdArguments[1] ~= "all") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlock usage: "..commands.getadmin("lock")["syntax"].."\";")

        return true
    end

    if cmdArguments[1] == "all" then
        teams.lock(constants.TEAM_AXIS)
        teams.lock(constants.TEAM_ALLIES)
        teams.lock(constants.TEAM_SPECTATORS)

        et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dlock: ^9all teams have been locked.\";")

        return false
    end

    local team = util.getTeamFromCode(cmdArguments[1])
    teams.lock(team)

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dlock: "..util.getTeamColor(team).util.getTeamName(team).." ^9team has been locked.\";")

    return false
end
commands.addadmin("lock", commandLock, auth.PERM_LOCKTEAM, "lock one or all of the teams from players joining", "^9[^3r|b|s|all#^9]", (settings.get("g_standalone") == 0))
