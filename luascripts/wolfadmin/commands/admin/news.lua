
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
local server = wolfa_requireModule("game.server")

function commandNews(clientId, command, map)
    map = map and map or game.getMap()

    local fileName = string.format("sound/vo/%s/news_%s.wav", map, map)
    local fileDescriptor, fileLength = et.trap_FS_FOpenFile(fileName, et.FS_READ)

    if fileLength == -1 then
        output.clientConsole(string.format("^dnews: ^9file news_%s.wav does not exist", map), clientId)

        return 0
    end

    et.trap_FS_FCloseFile(fileDescriptor)

    server.exec(string.format("playsound \"%s\"", fileName))

    return true
end
commands.addadmin("news", commandNews, auth.PERM_NEWS, "play the map's news reel or another map's news reel if specified", "^9(^hmapname^9)")
