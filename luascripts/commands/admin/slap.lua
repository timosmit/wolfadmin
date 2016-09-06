
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2016 Timo 'Timothy' Smit

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

local players = require "luascripts.wolfadmin.players.players"

local settings = require "luascripts.wolfadmin.util.settings"

function commandSlap(clientId, cmdArguments)
    if cmdArguments[1] == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dslap usage: "..commands.getadmin("slap")["syntax"].."\";")

        return true
    elseif tonumber(cmdArguments[1]) == nil then
        cmdClient = et.ClientNumberFromString(cmdArguments[1])
    else
        cmdClient = tonumber(cmdArguments[1])
    end

    if cmdClient == -1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dslap: ^9no or multiple matches for '^7"..cmdArguments[1].."^9'.\";")

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dslap: ^9no connected player by that name or slot #\";")

        return true
    end

    if auth.isallowed(cmdClient, "!") == 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dslap: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is immune to this command.\";")

        return true
    elseif auth.getlevel(cmdClient) > auth.getlevel(clientId) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dslap: ^9sorry, but your intended victim has a higher admin level than you do.\";")

        return true
    end

    local newHealth = et.gentity_get(cmdClient, "health") - 20

    if newHealth < 1 then
        newHealth = 1
    end

    et.gentity_set(cmdClient, "health", newHealth)

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dslap: ^7"..players.getName(cmdClient).." ^9was slapped.\";")

    return true
end
commands.addadmin("slap", commandSlap, auth.PERM_SLAP, "give a player a specified amount of damage for a specified reason", "^9[^3name|slot#^9] (^hdamage^9) (^hreason^9)", (settings.get("g_standalone") == 0))
