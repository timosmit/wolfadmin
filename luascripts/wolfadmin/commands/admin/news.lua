
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2017 Timo 'Timothy' Smit

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

function commandNews(clientId, command, map)
    map = map and map or game.getMap()

    local fileDescriptor, fileLength = et.trap_FS_FOpenFile("sound/vo/"..map.."/news_"..map..".wav", et.FS_READ)

    if fileLength == -1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dnews: ^9file news_"..map.." does not exist.\";")

        return 0
    end

    et.trap_FS_FCloseFile(fileDescriptor)

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound \"sound/vo/"..map.."/news_"..map..".wav\";")

    return true
end
commands.addadmin("news", commandNews, auth.PERM_NEWS, "play the map's news reel or another map's news reel if specified", "^9(^hmapname^9)")
