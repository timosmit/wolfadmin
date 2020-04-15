
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
local commands = wolfa_requireModule("commands.commands")
local config = wolfa_requireModule("config.config")

function commandTime(clientId, command)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dtime: ^9current time is ^7"..os.date("%H:%M:%S").."^9.\";")

    return true
end
commands.addadmin("time", commandTime, auth.PERM_TIME, "displays the local time", nil, nil, (config.get("g_standalone") == 0))
