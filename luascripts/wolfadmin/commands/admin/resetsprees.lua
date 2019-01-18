
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

local db = wolfa_requireModule("db.db")

local commands = wolfa_requireModule("commands.commands")

local game = wolfa_requireModule("game.game")
local sprees = wolfa_requireModule("game.sprees")

local settings = wolfa_requireModule("util.settings")

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
