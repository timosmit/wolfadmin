
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

local auth = wolfa_requireModule("auth.auth")
local commands = wolfa_requireModule("commands.commands")
local settings = wolfa_requireModule("util.settings")

function commandShuffle(clientId, command, type)
    if type == "xp" then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dshuffle: ^9teams were shuffled by XP.\";")

        et.trap_SendConsoleCommand(et.EXEC_APPEND, "shuffle_teams")
    elseif type == "sr" then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dshuffle: ^9teams were shuffled by SR.\";")

        et.trap_SendConsoleCommand(et.EXEC_APPEND, "shuffle_teams_sr")
    elseif type == nil then
        if settings.get("fs_game") == "legacy" then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dshuffle: ^9teams were shuffled by SR.\";")

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "shuffle_teams_sr")
        else
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dshuffle: ^9teams were shuffled by XP.\";")

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "shuffle_teams")
        end
    else
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dshuffle usage: "..commands.getadmin("shuffle")["syntax"].."\";")
    end

    return true
end
commands.addadmin("shuffle", commandShuffle, auth.PERM_SHUFFLE, "shuffle the teams to try and even them", "^2!shuffle ^9(^hxp|sr^9)", nil, (settings.get("g_standalone") == 0))
