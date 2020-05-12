
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

local config = wolfa_requireModule("config.config")
local output = wolfa_requireModule("game.output")

local COLOURS_CHAT = {
    [1] = "^_", -- termination
    [2] = "^1", -- error
    [3] = "^8", -- warning
    [4] = "^2", -- success
    [5] = "^7", -- information
}

local COLOURS_CONSOLE = {
    [1] = "^_", -- termination
    [2] = "^1", -- error
    [3] = "^3", -- warning
    [4] = "^2", -- success
    [5] = "", -- information
}

local neededSeverity = 5

function outputDebug(msg, severity)
    local severity = severity or 5

    if severity <= neededSeverity then
        -- FIXME check whether non-legacymod servers handle colouring correctly
        et.G_Print("[WolfAdmin] "..COLOURS_CONSOLE[severity]..msg.."\n")

        for playerId = 0, et.trap_Cvar_Get("sv_maxclients") - 1 do
            if config.get("g_debugWolfAdmin") ~= 0 then
                output.clientConsole("^:[WolfAdmin DEBUG] "..COLOURS_CHAT[severity]..msg, playerId)
            end
        end
    end
end
