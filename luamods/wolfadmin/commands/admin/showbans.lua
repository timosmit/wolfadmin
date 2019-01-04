
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2019 Timo 'Timothy' Smit

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

local db = require (wolfa_getLuaPath()..".db.db")

local commands = require (wolfa_getLuaPath()..".commands.commands")

local pagination = require (wolfa_getLuaPath()..".util.pagination")
local settings = require (wolfa_getLuaPath()..".util.settings")
local util = require (wolfa_getLuaPath()..".util.util")

function commandShowBans(clientId, offset)
    if not db.isConnected() then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dshowbans: ^9bans are disabled.\";")

        return true
    end

    local count = bans.getCount()
    local limit, offset = pagination.calculate(count, 30, tonumber(offset))
    local bans = bans.getList(limit, offset)

    if not (bans and #bans > 0) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dshowbans: ^9there are no bans.\";")
    else
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^d"..count.." bans:\";")
        for _, ban in pairs(bans) do
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^f"..string.format("%4s", ban["id"]).." ^7"..string.format("%-20s", util.removeColors(db.getLastAlias(ban["victim_id"])["alias"])).." ^f"..os.date("%d/%m/%Y", ban["issued"]).." ^7"..string.format("%-20s", util.removeColors(db.getLastAlias(ban["invoker_id"])["alias"])).." ^f"..os.date("%d/%m/%Y", ban["expires"]).." ^7"..ban["reason"].."\";")
        end

        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9Showing results ^7"..(offset + 1).." ^9- ^7"..(offset + limit).." ^9of ^7"..count.."^9.\";")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^dshowbans: ^9bans were printed to the console.\";")
    end

    return true
end
commands.addadmin("showbans", commandShowBans, auth.PERM_LISTBANS, "display a (partial) list of active bans", "(^hstart at ban#^9) ((^hbanner^9) (^3banner's name^9)) ((^3find^9) (^hbanned player^9)) ((^3reason^9) (^hreason for ban^9))", nil, (settings.get("g_standalone") == 0))
