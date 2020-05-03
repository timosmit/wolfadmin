
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

function commandUptime(clientId, command)
    local uptime = et.trap_Milliseconds() / 1000
    local days = math.floor(uptime / (60 * 60 * 24))
    uptime = uptime - (days * 60 * 60 * 24)
    local hours = math.floor(uptime / (60 * 60))
    uptime = uptime - (hours * 60 * 60)
    local minutes = math.ceil(uptime / 60)

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^duptime: ^2"..days.." days, "..hours.." hours, "..minutes.." minutes.\";")

    return true
end
commands.addadmin("uptime", commandUptime, auth.PERM_UPTIME, "displays server uptime", nil, nil, (config.get("g_standalone") == 0))
