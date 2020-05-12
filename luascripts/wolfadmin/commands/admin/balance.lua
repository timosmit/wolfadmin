
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
local balancer = wolfa_requireModule("admin.balancer")
local output = wolfa_requireModule("game.output")
local commands = wolfa_requireModule("commands.commands")
local config = wolfa_requireModule("config.config")

function commandBalance(clientId, command, action)
    if action == "enable" then
        if not balancer.isRunning() then
            balancer.enable()

            output.clientChat("^dbalancer: ^9balancer enabled.")
        else
            output.clientConsole("^dbalancer: ^9balancer is already running.", clientId)
        end
    elseif action == "disable" then
        if balancer.isRunning() then
            balancer.disable()

            output.clientChat("^dbalancer: ^9balancer disabled.")
        else
            output.clientConsole("^dbalancer: ^9balancer was not running.", clientId)
        end
    elseif action == "force" then
        balancer.balance(true, true)
    elseif not action then
        balancer.balance(true, false)
    else
        output.clientConsole("^dbalance usage: "..commands.getadmin("balance")["syntax"], clientId)
    end

    return true
end
commands.addadmin("balance", commandBalance, auth.PERM_BALANCE, "either asks the players to even up or evens them by moving or shuffling players", "^2!balance ^9(^henable|disable|force^9)", nil, (config.get("fs_game") == "etpub"))
