
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

local auth = require (wolfa_getLuaPath()..".auth.auth")

local commands = require (wolfa_getLuaPath()..".commands.commands")

local players = require (wolfa_getLuaPath()..".players.players")

function commandAdminChat(clientId, command, ...)
    if not ... then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9usage: "..commands.getclient("adminchat")["syntax"].."\";")
    else
        local recipients = {}
        
        for playerId = 0, et.trap_Cvar_Get("sv_maxclients") - 1 do
            if players.isConnected(playerId) and auth.isPlayerAllowed(playerId, auth.PERM_ADMINCHAT) then
                table.insert(recipients, playerId) 
            end
        end
        
        for _, recipient in ipairs(recipients) do
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..recipient.." \"^7"..et.gentity_get(clientId, "pers.netname").."^7 -> adminchat ("..#recipients.." recipients): ^a"..table.concat({...}, " ").."\";")
            et.trap_SendServerCommand(recipient, "cp \"^jadminchat message from ^7"..et.gentity_get(clientId, "pers.netname"))
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound "..recipient.." \"sound/misc/pm.wav\";")
        end
        
        et.G_LogPrint("adminchat: "..et.gentity_get(clientId, "pers.netname")..": "..table.concat({...}, " ").."\n")
    end
    
    return true
end
commands.addclient("adminchat", commandAdminChat, auth.PERM_ADMINCHAT, "[^2message^7]", true)
commands.addclient("ac", commandAdminChat, auth.PERM_ADMINCHAT, "[^2message^7]", true)
