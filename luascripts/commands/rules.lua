
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
local rules = require "luascripts.wolfadmin.admin.rules"

function commandRules(clientId, cmdArguments)
    if #cmdArguments == 0 then
        local amountOfRules = 0
        
        local list = rules.get()
        
        for shortcut, rule in pairs(list) do
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^f"..string.format("%8s", shortcut).." ^9- "..rule.."\";")
            
            amountOfRules = amountOfRules + 1
        end
        
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^drules: ^9"..amountOfRules.." rules (open console for the full list)\";")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9Type ^2!rules ^d[rule] ^9to announce a specific rule.\";")
    elseif #cmdArguments > 0 then
        local rule = rules.get(string.lower(cmdArguments[1]))
        
        if rule then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^drules: "..rules.get(string.lower(cmdArguments[1])).."\";")
        end
    end
    
    return true
end
commands.register("rules", commandRules, "C", "display the rules on the server", "^9(^hrule^9)")