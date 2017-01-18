
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2017 Timo 'Timothy' Smit

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

function commandPersonalMessage(clientId, cmdArguments)
    if #cmdArguments > 1 then
        local cmdClient
        
        if tonumber(cmdArguments[1]) == nil or tonumber(cmdArguments[1]) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
            cmdClient = et.ClientNumberFromString(cmdArguments[1])
        else
            cmdClient = tonumber(cmdArguments[1])
        end
        
        if cmdClient ~= -1 and et.gentity_get(cmdClient, "pers.netname") then
            players.setLastPMSender(cmdClient, clientId)
            
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..cmdClient.." \"^9reply: ^7r [^2message^7]\";")
        end
    end
end
commands.addclient("pm", commandPersonalMessage, "", "", true)
commands.addclient("m", commandPersonalMessage, "", "", true)
