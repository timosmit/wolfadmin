
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

local history = require (wolfa_getLuaPath()..".admin.history")

local db = require (wolfa_getLuaPath()..".db.db")

local commands = require (wolfa_getLuaPath()..".commands.commands")

local util = require (wolfa_getLuaPath()..".util.util")
local pagination = require (wolfa_getLuaPath()..".util.pagination")
local settings = require (wolfa_getLuaPath()..".util.settings")

function commandListHistory(clientId, cmdArguments)
    if settings.get("g_standalone") == 0 or not db.isconnected() then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dshowhistory: ^9warn history is disabled.\";")

        return true
    elseif cmdArguments[1] == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dshowhistory usage: "..commands.getadmin("showwarns")["syntax"].."\";")

        return true
    elseif tonumber(cmdArguments[1]) == nil or tonumber(cmdArguments[1]) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(cmdArguments[1])
    else
        cmdClient = tonumber(cmdArguments[1])
    end

    if cmdClient == -1 or cmdClient == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dshowhistory: ^9no or multiple matches for '^7"..cmdArguments[1].."^9'.\";")

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dshowhistory: ^9no connected player by that name or slot #\";")

        return true
    end

    local count = history.getCount(cmdClient)
    local limit, offset = pagination.calculate(count, 30, tonumber(cmdArguments[2]))
    local playerHistory = history.getList(cmdClient, limit, offset)

    if not (playerHistory and #playerHistory > 0) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dshowhistory: ^9there is no history for player ^7"..et.gentity_get(cmdClient, "pers.netname").."^9.\";")
    else
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dHistory for ^7"..et.gentity_get(cmdClient, "pers.netname").."^d:\";")
        for _, history in pairs(playerHistory) do
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^f"..string.format("%4s", history["id"]).." ^7"..string.format("%-20s", util.removeColors(db.getlastalias(history["invoker_id"])["alias"])).." ^f"..os.date("%d/%m/%Y", history["datetime"]).." ^7"..string.format("%-8s", history["type"]..":").." "..history["reason"].."\";")
        end

        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9Showing results ^7"..(offset + 1).." ^9- ^7"..limit.." ^9of ^7"..count.."^9.\";")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^dshowhistory: ^9history for ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9was printed to the console.\";")
    end

    return true
end
commands.addadmin("showhistory", commandListHistory, auth.PERM_LISTHISTORY, "display history for a specific player", "^9[^3name|slot#^9] ^9(^hoffset^9)", nil, (settings.get("g_standalone") == 0))
