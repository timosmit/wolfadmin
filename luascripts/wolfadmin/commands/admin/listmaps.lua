
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

local game = wolfa_requireModule("game.game")

function commandListMaps(clientId, command)
    local maps = game.getMaps()

    if #maps == 0 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistmaps: ^9no map information available.\";")

        return true
    end

    local output = ""

    for _, map in ipairs(maps) do
        local prefix = "^9"
        if map == game.getMap() then prefix = "^7" end

        output = (output ~= "") and output.." "..prefix..map or prefix..map
    end

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dlistmaps: ^9"..output.. "\";")

    return true
end
commands.addadmin("listmaps", commandListMaps, auth.PERM_LISTMAPS, "display the maps in the rotation")
