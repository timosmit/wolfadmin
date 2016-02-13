
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015 Timo 'Timothy' Smit

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

local commands = require "luascripts.wolfadmin.commands"
local sprees = require "luascripts.wolfadmin.game.sprees"

function commandResetSprees(clientId, cmdArguments)
    sprees.reset()
    
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dresetsprees: ^9spree records have been reset.\";")
    
    return true
end
commands.register("resetsprees", commandResetSprees, "G", "resets the spree records")