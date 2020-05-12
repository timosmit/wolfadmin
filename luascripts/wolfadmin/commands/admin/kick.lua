
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
local admin = wolfa_requireModule("admin.admin")
local history = wolfa_requireModule("admin.history")
local commands = wolfa_requireModule("commands.commands")
local config = wolfa_requireModule("config.config")
local output = wolfa_requireModule("game.output")

function commandKick(clientId, command, victim, ...)
    local cmdClient

    if victim == nil then
        output.clientConsole("^dkick usage: "..commands.getadmin("kick")["syntax"], clientId)

        return true
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        output.clientConsole("^dkick: ^9no or multiple matches for '^7"..victim.."^9'.", clientId)

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        output.clientConsole("^dkick: ^9no connected player by that name or slot #", clientId)

        return true
    end

    if auth.isPlayerAllowed(cmdClient, auth.PERM_IMMUNE) then
        output.clientConsole("^dkick: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is immune to this command.", clientId)

        return true
    elseif auth.getPlayerLevel(cmdClient) > auth.getPlayerLevel(clientId) then
        output.clientConsole("^dkick: ^9sorry, but your intended victim has a higher admin level than you do.", clientId)

        return true
    end

    local args = {...}
    local reason

    if args[1] then
        reason = table.concat(args, " ")
    elseif auth.isPlayerAllowed(clientId, auth.PERM_NOREASON) then
        reason = "kicked by admin"
    else
        output.clientConsole("^dkick usage: "..commands.getadmin("kick")["syntax"].."", clientId)

        return true
    end

    if config.get("g_playerHistory") ~= 0 then
        history.add(cmdClient, clientId, "kick", reason)
    end

    output.clientChat("^dkick: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9has been kicked", clientId)

    admin.kickPlayer(cmdClient, clientId, reason)

    return true
end
commands.addadmin("kick", commandKick, auth.PERM_KICK, "kick a player with an optional reason", "^9[^3name|slot#^9] ^9(^3reason^9)", nil, (config.get("g_standalone") == 0))
