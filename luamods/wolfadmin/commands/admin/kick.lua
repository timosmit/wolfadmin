
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

local auth = require (wolfa_getLuaPath()..".auth.auth")

local admin = require (wolfa_getLuaPath()..".admin.admin")
local history = require (wolfa_getLuaPath()..".admin.history")

local commands = require (wolfa_getLuaPath()..".commands.commands")

local settings = require (wolfa_getLuaPath()..".util.settings")

function commandKick(clientId, command, victim, ...)
    local cmdClient

    if victim == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dkick usage: "..commands.getadmin("kick")["syntax"].."\";")

        return true
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dkick: ^9no or multiple matches for '^7"..victim.."^9'.\";")

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dkick: ^9no connected player by that name or slot #\";")

        return true
    end

    if auth.isPlayerAllowed(cmdClient, "!") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dkick: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is immune to this command.\";")

        return true
    elseif auth.getPlayerLevel(cmdClient) > auth.getPlayerLevel(clientId) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dkick: ^9sorry, but your intended victim has a higher admin level than you do.\";")

        return true
    end

    local reason = table.concat({...}, " ")

    admin.kickPlayer(cmdClient, clientId, reason)

    if settings.get("g_playerHistory") ~= 0 then
        history.add(cmdClient, clientId, "kick", reason)
    end

    return true
end
commands.addadmin("kick", commandKick, auth.PERM_KICK, "kick a player with an optional reason", "^9[^3name|slot#^9] ^9(^3reason^9)", nil, (settings.get("g_standalone") == 0))
