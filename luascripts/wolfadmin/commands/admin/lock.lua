
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

local auth = wolfa_requireModule("auth.auth")
local commands = wolfa_requireModule("commands.commands")
local config = wolfa_requireModule("config.config")
local teams = wolfa_requireModule("game.teams")
local output = wolfa_requireModule("game.output")
local util = wolfa_requireModule("util.util")
local constants = wolfa_requireModule("util.constants")

function commandLock(clientId, command, team)
    if team == nil or (team ~= constants.TEAM_AXIS_SC and team ~= constants.TEAM_ALLIES_SC and team ~= constants.TEAM_SPECTATORS_SC and team ~= "all") then
        return false
    end

    if team == "all" then
        teams.lock(constants.TEAM_AXIS)
        teams.lock(constants.TEAM_ALLIES)
        teams.lock(constants.TEAM_SPECTATORS)

        return false
    end

    teams.lock(util.getTeamFromCode(team))

    return false
end
commands.addadmin("lock", commandLock, auth.PERM_LOCKTEAM, "lock one or all of the teams from players joining", "^9[^3r|b|s|all#^9]", true, (config.get("g_standalone") ~= 0))

function commandLock(clientId, command, team)
    if team == nil or (team ~= constants.TEAM_AXIS_SC and team ~= constants.TEAM_ALLIES_SC and team ~= constants.TEAM_SPECTATORS_SC and team ~= "all") then
        output.clientConsole("^dlock usage: "..commands.getadmin("lock")["syntax"], clientId)

        return true
    end

    if team == "all" then
        teams.lock(constants.TEAM_AXIS)
        teams.lock(constants.TEAM_ALLIES)
        teams.lock(constants.TEAM_SPECTATORS)

        output.clientChat("^dlock: ^9all teams have been locked.")

        return false
    end

    local team = util.getTeamFromCode(team)
    teams.lock(team)

    output.clientChat("^dlock: "..util.getTeamColor(team)..util.getTeamName(team).." ^9team has been locked.")

    return false
end
commands.addadmin("lock", commandLock, auth.PERM_LOCKTEAM, "lock one or all of the teams from players joining", "^9[^3r|b|s|all#^9]", nil, (config.get("g_standalone") == 0))
