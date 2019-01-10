
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

local commands = wolfa_requireModule("commands.commands")

local teams = wolfa_requireModule("game.teams")

local players = wolfa_requireModule("players.players")

local util = wolfa_requireModule("util.util")
local settings = wolfa_requireModule("util.settings")

function commandTeam(clientId, command)
    if players.isTeamLocked(clientId) then
        local clientTeam = tonumber(et.gentity_get(clientId, "sess.sessionTeam"))
        local teamName = util.getTeamName(clientTeam)
        local teamColor = util.getTeamColor(clientTeam)

        et.trap_SendServerCommand(clientId, "cp \"^7You are locked to the "..teamColor..teamName.." ^7team")

        return true
    end

    local team = util.getTeamFromCode(et.trap_Argv(1))
    if settings.get("g_standalone") ~= 0 and teams.isLocked(team) then
        local teamName = util.getTeamName(team)
        local teamColor = util.getTeamColor(team)

        et.trap_SendServerCommand(clientId, "cp \""..teamColor..teamName.." ^7team is locked")

        return true
    end
end
commands.addclient("team", commandTeam, "", "", false)
