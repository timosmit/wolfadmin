
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
local util = wolfa_requireModule("util.util")
local pagination = wolfa_requireModule("util.pagination")

function commandListHistory(clientId, command, victim, offset)
    local cmdClient

    if not db.isConnected() or config.get("g_playerHistory") == 0 then
        output.clientConsole("^dshowhistory: ^9player history is disabled.", clientId)

        return true
    elseif victim == nil then
        output.clientConsole("^dshowhistory usage: "..commands.getadmin("showhistory")["syntax"].."", clientId)

        return true
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        output.clientConsole("^dshowhistory: ^9no or multiple matches for '^7"..victim.."^9'.", clientId)

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        output.clientConsole("^dshowhistory: ^9no connected player by that name or slot #", clientId)

        return true
    end

    local count = history.getCount(cmdClient)
    local limit, offset = pagination.calculate(count, 30, tonumber(offset))
    local playerHistory = history.getList(cmdClient, limit, offset)

    if not (playerHistory and #playerHistory > 0) then
        output.clientConsole("^dshowhistory: ^9there is no history for player ^7"..et.gentity_get(cmdClient, "pers.netname").."^9.", clientId)
    else
        output.clientConsole("^dHistory for ^7"..et.gentity_get(cmdClient, "pers.netname").."^d:", clientId)
        for _, history in pairs(playerHistory) do
            output.clientConsole("^f"..string.format("%4s", history["id"]).." ^7"..string.format("%-20s", util.removeColors(db.getLastAlias(history["invoker_id"])["alias"])).." ^f"..os.date("%d/%m/%Y", history["datetime"]).." ^7"..string.format("%-8s", history["type"]..":").." "..history["reason"].."", clientId)
        end

        output.clientConsole("^9Showing results ^7"..(offset + 1).." ^9- ^7"..(offset + limit).." ^9of ^7"..count.."^9.", clientId)
        output.clientChat("^dshowhistory: ^9history for ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9was printed to the console.", clientId)
    end

    return true
end
commands.addadmin("showhistory", commandListHistory, auth.PERM_LISTHISTORY, "display history for a specific player", "^9[^3name|slot#^9] ^9(^hoffset^9)", (config.get("g_playerHistory") == 0))
