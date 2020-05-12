
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
local config = wolfa_requireModule("config.config")
local output = wolfa_requireModule("game.output")

function commandHelp(clientId, command, cmd)
    local cmds = commands.getadmin()
    
    if not cmd then
        local availableCommands = {}
        
        for command, data in pairs(cmds) do
            if data["function"] and data["flag"] and auth.isPlayerAllowed(clientId, data["flag"]) and not data["hidden"] then
                table.insert(availableCommands, command)
            end
        end
        
        output.clientChat("^dhelp: ^9"..#availableCommands.." "..((config.get("g_standalone") ~= 0) and "available" or "additional").." commands (open console for the full list)", clientId)
        
        local cmdsOnLine, cmdsBuffer = 0, ""
        
        for _, command in pairs(availableCommands) do
            cmdsBuffer = cmdsBuffer ~= "" and cmdsBuffer..string.format("%-12s", command) or string.format("%-12s", command)
            cmdsOnLine = cmdsOnLine + 1
                
            if cmdsOnLine == 6 then
                output.clientConsole("^f"..cmdsBuffer, clientId)
                cmdsBuffer = ""
                cmdsOnLine = 0
            end
        end
        
        if cmdsBuffer ~= "" then
            output.clientConsole("^f"..cmdsBuffer, clientId)
        end
        
        output.clientConsole("^9Type ^2!help ^d[command] ^9for help with a specific command.", clientId)
        
        return false
    else
        cmd = string.lower(cmd)
        
        if cmds[cmd] ~= nil and (not cmds[cmd]["hidden"] or (type(cmds[cmd]["hidden"]) == "function" and not cmds[cmd]["hidden"]())) then
            output.clientConsole("^dhelp: ^9help for '^2".. cmd .."^9':", clientId)
            output.clientConsole("^dfunction: ^9"..cmds[cmd]["help"], clientId)
            output.clientConsole("^dsyntax: ^9"..cmds[cmd]["syntax"], clientId)
            output.clientConsole("^dflag: ^9'^2"..cmds[cmd]["flag"].."^9'", clientId)
            
            return true
        end
    end
    
    return false
end
commands.addadmin("help", commandHelp, auth.PERM_HELP, "display commands available to you or help on a specific command", "^9(^hcommand^9)", (config.get("g_standalone") == 0))
