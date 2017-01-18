
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

local commands = require (wolfa_getLuaPath()..".commands.commands")

local db = require (wolfa_getLuaPath()..".db.db")

local settings = require (wolfa_getLuaPath()..".util.settings")

function commandRemoveBan(clientId, cmdArguments)
    if settings.get("g_standalone") == 0 or not db.isconnected() then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dunban: ^9bans are disabled.\";")

        return true
    elseif #cmdArguments < 1 or tonumber(cmdArguments[1]) == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dunban usage: "..commands.getadmin("unban")["syntax"].."\";")

        return true
    end

    local ban = bans.get(tonumber(cmdArguments[1]))

    if not ban then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dunban: ^9ban #"..cmdArguments[1].." does not exist.\";")
    else
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dunban: ^9ban #"..cmdArguments[1].." removed.\";")

        bans.remove(tonumber(cmdArguments[1]))
    end

    return true
end
commands.addadmin("unban", commandRemoveBan, auth.PERM_BAN, "unbans a player specified ban number as seen in ^2!showbans^9", "^9[^3ban#^9]", function() return (settings.get("g_standalone") == 0 or not db.isconnected()) end)
