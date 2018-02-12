
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2018 Timo 'Timothy' Smit

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

local commands = require "luascripts.wolfadmin.commands.commands"
local balancer = require "luascripts.wolfadmin.admin.balancer"

function commandBalance(clientId, cmdArguments)
    if cmdArguments[1] == "enable" then
        if not balancer.isRunning() then
            balancer.enable()

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dbalancer: ^9balancer enabled.\";")
        else
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dbalancer: ^9balancer is already running.\";")
        end
    elseif cmdArguments[1] == "disable" then
        if balancer.isRunning() then
            balancer.disable()

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dbalancer: ^9balancer disabled.\";")
        else
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dbalancer: ^9balancer was not running.\";")
        end
    elseif cmdArguments[1] == "force" then
        balancer.balance(true, true)
    else
        balancer.balance(true, false)
    end

    return true
end
commands.addadmin("balance", commandBalance, "p", "either asks the players to even up or evens them by moving or shuffling players", "^2!balance ^9(^hforce^9)")