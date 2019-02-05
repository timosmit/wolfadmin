
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

local auth = wolfa_requireModule("auth.auth")

local commands = wolfa_requireModule("commands.commands")

local players = wolfa_requireModule("players.players")

local settings = wolfa_requireModule("util.settings")

function commandRename(clientId, command, victim, newName)
    local cmdClient

    if victim == nil or newName == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^drename usage: "..commands.getadmin("rename")["syntax"].."\";")

        return true
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^drename: ^9no or multiple matches for '^7"..victim.."^9'.\";")

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^drename: ^9no connected player by that name or slot #\";")

        return true
    end

    local oldName = players.getName(cmdClient)

    local clientInfo = et.trap_GetUserinfo(cmdClient)
    clientInfo = et.Info_SetValueForKey(clientInfo, "name", newName)
    et.trap_SetUserinfo(cmdClient, clientInfo)
    et.ClientUserinfoChanged(cmdClient)

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^drename: ^7"..oldName.." ^9has been renamed to ^7"..newName.."^9.\";")

    return true
end
commands.addadmin("rename", commandRename, auth.PERM_RENAME, "renames a player", "^9[^3name|slot#^9] [^3new name^9]", nil, (settings.get("g_standalone") == 0))
