
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

local admin = require (wolfa_getLuaPath()..".admin.admin")
local history = require (wolfa_getLuaPath()..".admin.history")

local db = require (wolfa_getLuaPath()..".db.db")

local commands = require (wolfa_getLuaPath()..".commands.commands")

local players = require (wolfa_getLuaPath()..".players.players")

local settings = require (wolfa_getLuaPath()..".util.settings")

function commandWarn(clientId, cmdArguments)
    if settings.get("g_warnHistory") == 0 or not db.isconnected() then
        return false
    elseif #cmdArguments < 2 then
        return false
    elseif tonumber(cmdArguments[1]) == nil or tonumber(cmdArguments[1]) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(cmdArguments[1])
    else
        cmdClient = tonumber(cmdArguments[1])
    end

    if cmdClient == -1 then
        return false
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        return false
    end

    history.add(cmdClient, clientId, os.time(), "warn", table.concat(cmdArguments, " ", 2))

    return false
end
commands.addadmin("warn", commandWarn, auth.PERM_WARN, "warns a player by displaying the reason", "^9[^3name|slot#^9] ^9[^3reason^9]", true)

function commandWarn(clientId, cmdArguments)
    if #cmdArguments < 2 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dwarn usage: "..commands.getadmin("warn")["syntax"].."\";")

        return true
    elseif tonumber(cmdArguments[1]) == nil or tonumber(cmdArguments[1]) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(cmdArguments[1])
    else
        cmdClient = tonumber(cmdArguments[1])
    end

    if cmdClient == -1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dwarn: ^9no or multiple matches for '^7"..cmdArguments[1].."^9'.\";")

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dwarn: ^9no connected player by that name or slot #\";")

        return true
    end

    if auth.getPlayerLevel(cmdClient) > auth.getPlayerLevel(clientId) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dwarn: ^9sorry, but your intended victim has a higher admin level than you do.\";")

        return true
    end

    local reason = table.concat(cmdArguments, " ", 2)

    history.add(cmdClient, clientId, "warn", reason)

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "ccp "..cmdClient.." \"^7You have been warned by "..players.getName(clientId)..": ^7"..reason..".\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay -1 \"^dwarn: ^7"..players.getName(cmdClient).." ^9has been warned.\";")

    return true
end
commands.addadmin("warn", commandWarn, auth.PERM_WARN, "warns a player by displaying the reason", "^9[^3name|slot#^9] ^9[^3reason^9]", (settings.get("g_standalone") == 0 and db.isconnected()))
