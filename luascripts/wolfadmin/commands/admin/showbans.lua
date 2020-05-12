
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
local bans = wolfa_requireModule("admin.bans")
local commands = wolfa_requireModule("commands.commands")
local config = wolfa_requireModule("config.config")
local db = wolfa_requireModule("db.db")
local output = wolfa_requireModule("game.output")
local pagination = wolfa_requireModule("util.pagination")
local util = wolfa_requireModule("util.util")

function commandShowBans(clientId, offset)
    if not db.isConnected() then
        output.clientConsole("^dshowbans: ^9bans are disabled.", clientId)

        return true
    end

    local count = bans.getCount()
    local limit, offset = pagination.calculate(count, 30, tonumber(offset))
    local bans = bans.getList(limit, offset)

    if not (bans and #bans > 0) then
        output.clientConsole("^dshowbans: ^9there are no bans.", clientId)
    else
        output.clientConsole("^d"..count.." bans:", clientId)
        for _, ban in pairs(bans) do
            output.clientConsole("^f"..string.format("%4s", ban["id"]).." ^7"..string.format("%-20s", util.removeColors(db.getLastAlias(ban["victim_id"])["alias"])).." ^f"..os.date("%d/%m/%Y", ban["issued"]).." ^7"..string.format("%-20s", util.removeColors(db.getLastAlias(ban["invoker_id"])["alias"])).." ^f"..os.date("%d/%m/%Y", ban["expires"]).." ^7"..ban["reason"].."", clientId)
        end

        output.clientConsole("^9Showing results ^7"..(offset + 1).." ^9- ^7"..(offset + limit).." ^9of ^7"..count.."^9.", clientId)
        output.clientChat("^dshowbans: ^9bans were printed to the console.", clientId)
    end

    return true
end
commands.addadmin("showbans", commandShowBans, auth.PERM_LISTBANS, "display a (partial) list of active bans", "(^hstart at ban#^9) ((^hbanner^9) (^3banner's name^9)) ((^3find^9) (^hbanned player^9)) ((^3reason^9) (^hreason for ban^9))", nil, (config.get("g_standalone") == 0))
