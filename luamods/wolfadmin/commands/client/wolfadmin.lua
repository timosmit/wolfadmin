
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

local commands = require (wolfa_getLuaPath()..".commands.commands")

function commandWolfAdmin(clientId, command)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^3This server is running ^7Wolf^1Admin ^7"..wolfa_getVersion().." ^3("..wolfa_getRelease().."^3)\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^3Created by ^7Timo '^aTimo^qthy^7' ^7Smit^3. More info on\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"    ^7http://dev.timosmit.com/wolfadmin/\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^3Thanks for using!\";")
    
    return true
end
commands.addclient("wolfadmin", commandWolfAdmin, "", "")
