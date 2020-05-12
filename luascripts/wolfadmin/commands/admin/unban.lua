
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

function commandRemoveBan(clientId, command, banId)
    if config.get("g_standalone") == 0 or not db.isConnected() then
        output.clientConsole("^dunban: ^9bans are disabled.", clientId)

        return true
    elseif not banId or tonumber(banId) == nil then
        output.clientConsole("^dunban usage: "..commands.getadmin("unban")["syntax"], clientId)

        return true
    end

    if not bans.get(tonumber(banId)) then
        output.clientConsole("^dunban: ^9ban #"..banId.." does not exist.", clientId)
    else
        output.clientConsole("^dunban: ^9ban #"..banId.." removed.", clientId)

        bans.remove(tonumber(banId))
    end

    return true
end
commands.addadmin("unban", commandRemoveBan, auth.PERM_BAN, "unbans a player specified ban number as seen in ^2!showbans^9", "^9[^3ban#^9]", nil, (config.get("g_standalone") == 0))
