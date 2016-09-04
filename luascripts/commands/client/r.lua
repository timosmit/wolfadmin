
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2016 Timo 'Timothy' Smit

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

local auth = require "luascripts.wolfadmin.auth.auth"
local commands = require "luascripts.wolfadmin.commands.commands"
local stats = require "luascripts.wolfadmin.players.stats"

function commandR(clientId, cmdArguments)
    if #cmdArguments == 0 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9usage: "..commands.getclient("r")["syntax"].."\";")
    else
        local recipient = stats.get(clientId, "lastMessageFrom")
        
        if not (recipient and et.gentity_get(recipient, "pers.netname")) then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"player not found\";")
        else
            local message, messageConcatenated = {}, ""
            
            for i = 1, #cmdArguments do
                message[i] = cmdArguments[i]
            end
            
            messageConcatenated = table.concat(message, " ")
            
            stats.set(recipient, "lastMessageFrom", clientId)
            
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^7"..et.gentity_get(clientId, "pers.netname").."^7 -> "..recipient..": (1 recipients): ^3"..messageConcatenated.."\";")
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound "..clientId.." \"sound/misc/pm.wav\";")
            
            if clientId ~= recipient then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..recipient.." \"^7"..et.gentity_get(clientId, "pers.netname").."^7 -> "..recipient..": (1 recipients): ^3"..messageConcatenated.."\";")
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound "..clientId.." \"sound/misc/pm.wav\";")
            end
            
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "ccp "..recipient.." \"^3private message from "..et.gentity_get(clientId, "pers.netname").."\";")
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..recipient.." \"^9reply: ^7r [^2message^7]\";")
        end
    end
    
    return true
end
commands.addclient("r", commandR, "", "[^2message^7]", true)
