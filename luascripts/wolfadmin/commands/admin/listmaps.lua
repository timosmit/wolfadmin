
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
local game = wolfa_requireModule("game.game")
local output = wolfa_requireModule("game.output")

function commandListMaps(clientId, command)
    local maps = game.getMaps()

    if #maps == 0 then
        output.clientConsole("^dlistmaps: ^9no map information available.", clientId)

        return true
    end

    local message = ""
    for _, map in ipairs(maps) do
        local prefix = map == game.getMap() and "^7" or "^9"

        message = (message ~= "") and message.." "..prefix..map or prefix..map
    end

    output.clientChat("^dlistmaps: ^9"..message)

    return true
end
commands.addadmin("listmaps", commandListMaps, auth.PERM_LISTMAPS, "display the maps in the rotation")
