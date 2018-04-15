
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

local admin = require (wolfa_getLuaPath()..".admin.admin")
local history = require (wolfa_getLuaPath()..".admin.history")

local auth = require (wolfa_getLuaPath()..".auth.auth")

local db = require (wolfa_getLuaPath()..".db.db")

local commands = require (wolfa_getLuaPath()..".commands.commands")

local settings = require (wolfa_getLuaPath()..".util.settings")

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
commands.addadmin("setlevel", commandSetLevel, auth.PERM_SETLEVEL, "sets the admin level of a player", "^9[^3name|slot#^9] ^9[^3level^9]", true, (settings.get("g_standalone") == 1))

function commandSetLevel(clientId, command, victim, level)
    local cmdClient

    if victim == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dsetlevel usage: "..commands.getadmin("setlevel")["syntax"].."\";")

        return true
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dsetlevel: ^9no or multiple matches for '^7"..victim.."^9'.\";")

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dsetlevel: ^9no connected player by that name or slot #\";")

        return true
    end

    level = tonumber(level) or 0
    
    if auth.getPlayerLevel(cmdClient) > auth.getPlayerLevel(clientId) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dsetlevel: ^9sorry, but your intended victim has a higher admin level than you do.\";")

        return true
    elseif not db.getLevel(level) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dsetlevel: ^9this admin level does not exist.\";")

        return true
    elseif level > auth.getPlayerLevel(clientId) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dsetlevel: ^9you may not setlevel higher than your current level.\";")

        return true
    end

    admin.setPlayerLevel(cmdClient, level, clientId)
    history.add(cmdClient, clientId, "level", tostring(level))

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dsetlevel: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is now a level ^7"..level.." ^9player.\";")

    return true
end
commands.addadmin("setlevel", commandSetLevel, auth.PERM_SETLEVEL, "sets the admin level of a player", "^9[^3name|slot#^9] ^9[^3level^9]", nil, (settings.get("g_standalone") == 0))
