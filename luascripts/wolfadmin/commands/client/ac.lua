
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
local output = wolfa_requireModule("game.output")
local server = wolfa_requireModule("game.server")
local players = wolfa_requireModule("players.players")

function commandAdminChat(clientId, command, ...)
    if not ... then
        output.clientConsole("^9usage: "..commands.getclient("adminchat")["syntax"], clientId)
    else
        local recipients = {}
        
        for playerId = 0, et.trap_Cvar_Get("sv_maxclients") - 1 do
            if players.isConnected(playerId) and auth.isPlayerAllowed(playerId, auth.PERM_ADMINCHAT) then
                table.insert(recipients, playerId) 
            end
        end

        local message = table.concat({...}, " ")

        for _, recipient in ipairs(recipients) do
            output.clientChat("^7"..et.gentity_get(clientId, "pers.netname").."^7 -> adminchat ("..#recipients.." recipients): ^a"..message, recipient)
            output.clientCenter("^jadminchat message from ^7"..et.gentity_get(clientId, "pers.netname"), recipient)
            server.exec(string.format("playsound %d \"sound/misc/pm.wav\";", recipient))
        end

        et.G_LogPrint("adminchat: "..et.gentity_get(clientId, "pers.netname")..": "..message.."\n")
    end
    
    return true
end
commands.addclient("adminchat", commandAdminChat, auth.PERM_ADMINCHAT, "[^2message^7]", true)
commands.addclient("ac", commandAdminChat, auth.PERM_ADMINCHAT, "[^2message^7]", true)
