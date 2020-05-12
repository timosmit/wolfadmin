
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

local admin = wolfa_requireModule("admin.admin")
local history = wolfa_requireModule("admin.history")
local auth = wolfa_requireModule("auth.auth")
local commands = wolfa_requireModule("commands.commands")
local config = wolfa_requireModule("config.config")
local db = wolfa_requireModule("db.db")
local output = wolfa_requireModule("game.output")

function commandSetLevel(clientId, command, victim, level)
    local cmdClient

    if not victim or not level then
        return false
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        return false
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        return false
    end

    level = tonumber(level) or 0

    if auth.getPlayerLevel(cmdClient) > auth.getPlayerLevel(clientId) then
        return false
    elseif level > auth.getPlayerLevel(clientId) then
        return false
    end

    history.add(cmdClient, clientId, "level", tostring(level))

    return false
end
commands.addadmin("setlevel", commandSetLevel, auth.PERM_SETLEVEL, "sets the admin level of a player", "^9[^3name|slot#^9] ^9[^3level^9]", true, (config.get("g_standalone") ~= 0))

function commandSetLevel(clientId, command, victim, level)
    local cmdClient

    if victim == nil then
        output.clientConsole("^dsetlevel usage: "..commands.getadmin("setlevel")["syntax"], clientId)

        return true
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        output.clientConsole("^dsetlevel: ^9no or multiple matches for '^7"..victim.."^9'.", clientId)

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        output.clientConsole("^dsetlevel: ^9no connected player by that name or slot #", clientId)

        return true
    end

    level = tonumber(level) or 0
    
    if auth.getPlayerLevel(cmdClient) > auth.getPlayerLevel(clientId) then
        output.clientConsole("^dsetlevel: ^9sorry, but your intended victim has a higher admin level than you do.", clientId)

        return true
    elseif not db.getLevel(level) then
        output.clientConsole("^dsetlevel: ^9this admin level does not exist.", clientId)

        return true
    elseif level > auth.getPlayerLevel(clientId) then
        output.clientConsole("^dsetlevel: ^9you may not setlevel higher than your current level.", clientId)

        return true
    end

    admin.setPlayerLevel(cmdClient, level, clientId)
    history.add(cmdClient, clientId, "level", tostring(level))

    output.clientChat("^dsetlevel: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is now a level ^7"..level.." ^9player.")

    return true
end
commands.addadmin("setlevel", commandSetLevel, auth.PERM_SETLEVEL, "sets the admin level of a player", "^9[^3name|slot#^9] ^9[^3level^9]", nil, (config.get("g_standalone") == 0))
