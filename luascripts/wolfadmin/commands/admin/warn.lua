
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
local history = wolfa_requireModule("admin.history")
local commands = wolfa_requireModule("commands.commands")
local config = wolfa_requireModule("config.config")
local db = wolfa_requireModule("db.db")
local output = wolfa_requireModule("game.output")
local server = wolfa_requireModule("game.server")
local players = wolfa_requireModule("players.players")

function commandWarn(clientId, command, victim, ...)
    local cmdClient

    if not db.isConnected() or config.get("g_playerHistory") == 0 then
        return false
    elseif not victim or not ... then
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

    history.add(cmdClient, clientId, os.time(), "warn", table.concat({...}, " "))

    return false
end
commands.addadmin("warn", commandWarn, auth.PERM_WARN, "warns a player by displaying the reason", "^9[^3name|slot#^9] ^9[^3reason^9]", true, (config.get("g_standalone") ~= 0 or config.get("g_playerHistory") == 0))

function commandWarn(clientId, command, victim, ...)
    local cmdClient

    if not victim or not ... then
        output.clientConsole("^dwarn usage: "..commands.getadmin("warn")["syntax"], clientId)

        return true
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        output.clientConsole("^dwarn: ^9no or multiple matches for '^7"..victim.."^9'.", clientId)

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        output.clientConsole("^dwarn: ^9no connected player by that name or slot #", clientId)

        return true
    end

    if auth.getPlayerLevel(cmdClient) > auth.getPlayerLevel(clientId) then
        output.clientConsole("^dwarn: ^9sorry, but your intended victim has a higher admin level than you do.", clientId)

        return true
    end

    local reason = table.concat({...}, " ")

    if config.get("g_playerHistory") ~= 0 then
        history.add(cmdClient, clientId, "warn", reason)
    end

    output.clientCenter("^7You have been warned by "..players.getName(clientId)..": ^7"..reason..".", cmdClient)
    output.clientChat("^dwarn: ^7"..players.getName(cmdClient).." ^9has been warned.")

    server.exec("playsound \"sound/misc/referee.wav\";")

    return true
end
commands.addadmin("warn", commandWarn, auth.PERM_WARN, "warns a player by displaying the reason", "^9[^3name|slot#^9] ^9[^3reason^9]", nil, (config.get("g_standalone") == 0))
