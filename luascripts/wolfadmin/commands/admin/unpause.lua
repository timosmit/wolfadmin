
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

local settings = wolfa_requireModule("util.settings")

function commandUnpause(clientId, command)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dpause: ^9map unpaused.\";")

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref unpause")

    return true
end
commands.addadmin("unpause", commandUnpause, auth.PERM_PAUSE, "pauses the game for all players", nil, nil, (settings.get("g_standalone") == 0))
