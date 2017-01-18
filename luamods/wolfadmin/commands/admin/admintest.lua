
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

local auth = require (wolfa_getLuaPath()..".auth.auth")

local commands = require (wolfa_getLuaPath()..".commands.commands")

local players = require (wolfa_getLuaPath()..".players.players")

local settings = require (wolfa_getLuaPath()..".util.settings")

function commandAdminTest(clientId, cmdArguments)
    local level = auth.getlevel(clientId)
    local levelName = auth.getlevelname(level)

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dadmintest: ^7"..players.getName(clientId).." ^9is a level "..level.." user (^7"..levelName.."^9).\";")

    return true
end
commands.addadmin("admintest", commandAdminTest, auth.PERM_ADMINTEST, "display your current admin level", nil, (settings.get("g_standalone") == 0))
