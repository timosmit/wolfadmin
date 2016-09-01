
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
local settings = require "luascripts.wolfadmin.util.settings"

function commandReset(clientId, cmdArguments)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dreset: ^9match reset.\";")

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "reset_match")

    return true
end
commands.addadmin("reset", commandReset, auth.PERM_RESTART, "resets the current match", nil, (settings.get("g_standalone") == 0))
