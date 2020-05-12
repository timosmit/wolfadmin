
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
local game = wolfa_requireModule("game.game")
local output = wolfa_requireModule("game.output")
local server = wolfa_requireModule("game.server")

function commandRestart(clientId, command)
    output.clientChat("^drestart: ^9map restarted")

    local currentState = game.getState()
    local newState = 5 -- GS_RESET

		if currentState == 0 or currentState == 3 then -- GS_PLAYING or GS_INTERMISSION
			  newState = 2 -- GS_WARMUP
		end

    server.exec(string.format("map_restart 0 %d;", newState))

    return true
end
commands.addadmin("restart", commandRestart, auth.PERM_RESTART, "restarts the current map", nil, nil, (config.get("g_standalone") == 0))
