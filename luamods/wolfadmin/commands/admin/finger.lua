
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

local commands = require (wolfa_getLuaPath()..".commands.commands")

local players = require (wolfa_getLuaPath()..".players.players")

local settings = require (wolfa_getLuaPath()..".util.settings")

function commandFinger(clientId, command, victim)
    local cmdClient

    if victim == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dfinger usage: "..commands.getadmin("finger")["syntax"].."\";")

        return true
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dfinger: ^9no or multiple matches for '^7"..victim.."^9'.\";")

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dfinger: ^9no connected player by that name or slot #\";")

        return true
    end

    local stats = {
        ["name"] = players.getName(cmdClient),
        ["cleanname"] = players.getName(cmdClient):gsub("%^[^^]", ""),
        ["codedsname"] = players.getName(cmdClient):gsub("%^([^^])", "^^2%1"),
        ["slot"] = cmdClient,
        ["guid"] = players.getGUID(cmdClient),
        ["ip"] = players.getIP(cmdClient),
        ["version"] = players.getVersion(cmdClient)
    }

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dInformation about ^7"..stats["name"].."^d:\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dName:    ^2"..stats["cleanname"].." ("..stats["codedsname"]..")\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dSlot:    ^2"..stats["slot"]..(stats["slot"] < tonumber(et.trap_Cvar_Get("sv_privateClients")) and " ^9(private)" or "").."\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dGUID:    ^2"..stats["guid"].."\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dIP:      ^2"..stats["ip"].."\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dVersion: ^2"..stats["version"].."\";")

    return true
end
commands.addadmin("finger", commandFinger, auth.PERM_FINGER, "gives specific information about a player", "^9[^3name|slot#^9]", nil, (settings.get("g_standalone") == 0))
