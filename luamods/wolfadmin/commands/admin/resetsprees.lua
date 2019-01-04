
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

local db = require (wolfa_getLuaPath()..".db.db")

local commands = require (wolfa_getLuaPath()..".commands.commands")

local game = require (wolfa_getLuaPath()..".game.game")
local sprees = require (wolfa_getLuaPath()..".game.sprees")

local settings = require (wolfa_getLuaPath()..".util.settings")

function commandResetSprees(clientId, command, map)
    if not db.isConnected() then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dsprees: ^9spree records are disabled.\";")
        
        return true
    end

    if map and map == "all" then
        sprees.reset(true)

        et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dresetsprees: ^9all spree records have been reset.\";")
    else
        sprees.reset()

        et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dresetsprees: ^9spree records have been reset for map '^7"..game.getMap().."^9'.\";")
    end
    
    return true
end
commands.addadmin("resetsprees", commandResetSprees, auth.PERM_READCONFIG, "resets the spree records", nil, (settings.get("g_spreeRecords") == 0))
