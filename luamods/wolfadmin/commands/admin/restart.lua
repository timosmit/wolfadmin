
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
local commands = require (wolfa_getLuaPath()..".commands.commands")
local game = require (wolfa_getLuaPath()..".game.game")
local settings = require (wolfa_getLuaPath()..".util.settings")

function commandRestart(clientId, command)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^drestart: ^9map restarted.\";")

    local currentState = game.getState()
    local newState = 5 -- GS_RESET

		if currentState == 0 or currentState == 3 then -- GS_PLAYING or GS_INTERMISSION
			  newState = 2 -- GS_WARMUP
		end

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "map_restart 0 "..newState)

    return true
end
commands.addadmin("restart", commandRestart, auth.PERM_RESTART, "restarts the current map", nil, nil, (settings.get("g_standalone") == 0))
