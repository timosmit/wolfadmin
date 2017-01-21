
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

local auth = require (wolfa_getLuaPath()..".auth.auth")

local bans = require (wolfa_getLuaPath()..".admin.bans")
local history = require (wolfa_getLuaPath()..".admin.history")

local commands = require (wolfa_getLuaPath()..".commands.commands")

local util = require (wolfa_getLuaPath()..".util.util")
local settings = require (wolfa_getLuaPath()..".util.settings")

function commandBan(clientId, cmdArguments)
    if cmdArguments[1] == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dban usage: "..commands.getadmin("ban")["syntax"].."\";")

        return true
    elseif tonumber(cmdArguments[1]) == nil or tonumber(cmdArguments[1]) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(cmdArguments[1])
    else
        cmdClient = tonumber(cmdArguments[1])
    end

    if cmdClient == -1 or cmdClient == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dban: ^9no or multiple matches for '^7"..cmdArguments[1].."^9'.\";")
        
        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dban: ^9no connected player by that name or slot #\";")

        return true
    end

    local duration, reason = 600, "banned by admin"

    if cmdArguments[2] and util.getTimeFromString(cmdArguments[2]) and cmdArguments[3] then
        duration = util.getTimeFromString(cmdArguments[2])
        reason = table.concat(cmdArguments, " ", 3)
    elseif cmdArguments[2] and util.getTimeFromString(cmdArguments[2]) then
        duration = util.getTimeFromString(cmdArguments[2])
    elseif cmdArguments[2] then
        reason = table.concat(cmdArguments, " ", 2)
    elseif not auth.isPlayerAllowed(clientId, "8") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dban usage: "..commands.getadmin("ban")["syntax"].."\";")
        
        return true
    end

    if auth.isPlayerAllowed(cmdClient, "!") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dban: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is immune to this command.\";")

        return true
    elseif auth.getPlayerLevel(cmdClient) > auth.getPlayerLevel(clientId) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dban: ^9sorry, but your intended victim has a higher admin level than you do.\";")

        return true
    end

    bans.add(cmdClient, clientId, duration, reason)
    history.add(cmdClient, clientId, "ban", reason)

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dban: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9has been banned for "..duration.." seconds\";")

    return true
end
commands.addadmin("ban", commandBan, auth.PERM_BAN, "ban a player with an optional duration and reason", "^9[^3name|slot#^9] ^9(^3duration^9) ^9(^3reason^9)", (settings.get("g_standalone") == 0))
