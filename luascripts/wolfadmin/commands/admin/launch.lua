
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

local auth = wolfa_requireModule("auth.auth")
local commands = wolfa_requireModule("commands.commands")
local config = wolfa_requireModule("config.config")
local output = wolfa_requireModule("game.output")
local players = wolfa_requireModule("players.players")
local constants = wolfa_requireModule("util.constants")
local vectors = wolfa_requireModule("util.vectors")

function commandLaunch(clientId, command, victim)
    local cmdClient

    if victim == nil then
        output.clientConsole("^dlaunch usage: "..commands.getadmin("launch")["syntax"], clientId)

        return true
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        output.clientConsole("^dlaunch: ^9no or multiple matches for '^7"..victim.."^9'.", clientId)

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        output.clientConsole("^dlaunch: ^9no connected player by that name or slot #", clientId)

        return true
    end

    if auth.isPlayerAllowed(cmdClient, "!") then
        output.clientConsole("^dlaunch: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is immune to this command.", clientId)

        return true
    elseif auth.getPlayerLevel(cmdClient) > auth.getPlayerLevel(clientId) then
        output.clientConsole("^dlaunch: ^9sorry, but your intended victim has a higher admin level than you do.", clientId)

        return true
    elseif et.gentity_get(cmdClient, "sess.sessionTeam") ~= constants.TEAM_AXIS and et.gentity_get(cmdClient, "sess.sessionTeam") ~= constants.TEAM_ALLIES then
        output.clientConsole("^dlaunch: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is not playing.", clientId)

        return true
    elseif et.gentity_get(cmdClient, "health") <= 0 then
        output.clientConsole("^dlaunch: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is not alive.", clientId)

        return true
    end

    local velocity = et.gentity_get(cmdClient, "ps.velocity")
	local modifier = vectors.scale({0, 0, 10}, 1500)
	et.gentity_set(cmdClient, "ps.velocity", vectors.add(velocity, modifier))

    output.clientChat("^dlaunch: ^7"..players.getName(cmdClient).." ^9was launched.", clientId)

    return true
end
commands.addadmin("launch", commandLaunch, auth.PERM_THROW, "launch a player vertically", "^9[^3name|slot#^9]", nil, (config.get("g_standalone") == 0))
