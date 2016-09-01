
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2016 Timo 'Timothy' Smit

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

local auth = require "luascripts.wolfadmin.auth.auth"
local commands = require "luascripts.wolfadmin.commands.commands"
local stats = require "luascripts.wolfadmin.players.stats"
local settings = require "luascripts.wolfadmin.util.settings"

function commandAdminTest(clientId, cmdArguments)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dadmintest: "..stats.get(clientId, "playerName").." ^9is a level "..auth.getlevel(clientId).." user (".."^7Guest".."^9).\";")

    return true
end
commands.addadmin("admintest", commandAdminTest, auth.PERM_ADMINTEST, "display your current admin level", nil, (settings.get("g_standalone") == 0))
