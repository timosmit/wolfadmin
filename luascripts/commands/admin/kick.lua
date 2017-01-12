
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

local admin = require "luascripts.wolfadmin.admin.admin"
local history = require "luascripts.wolfadmin.admin.history"

local commands = require "luascripts.wolfadmin.commands.commands"

local settings = require "luascripts.wolfadmin.util.settings"

function commandKick(clientId, cmdArguments)
    if cmdArguments[1] == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dkick usage: "..commands.getadmin("kick")["syntax"].."\";")

        return true
    elseif tonumber(cmdArguments[1]) == nil then
        cmdClient = et.ClientNumberFromString(cmdArguments[1])
    else
        cmdClient = tonumber(cmdArguments[1])
    end

    if cmdClient == -1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dkick: ^9no or multiple matches for '^7"..cmdArguments[1].."^9'.\";")

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dkick: ^9no connected player by that name or slot #\";")

        return true
    end

    if auth.isallowed(cmdClient, "!") == 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dkick: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is immune to this command.\";")

        return true
    elseif auth.getlevel(cmdClient) > auth.getlevel(clientId) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dkick: ^9sorry, but your intended victim has a higher admin level than you do.\";")

        return true
    end

    local reason = table.concat(cmdArguments, " ", 2)

    admin.kickPlayer(cmdClient, clientId, reason)
    history.add(cmdClient, clientId, "kick", reason)

    return true
end
commands.addadmin("kick", commandKick, auth.PERM_KICK, "kick a player with an optional reason", "^9[^3name|slot#^9] ^9(^3reason^9)", (settings.get("g_standalone") == 0))
