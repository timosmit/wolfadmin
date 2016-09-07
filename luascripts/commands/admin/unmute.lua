
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

local players = require "luascripts.wolfadmin.players.players"

function commandUnmute(clientId, cmdArguments)
    if cmdArguments[1] == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dunmute usage: "..commands.getadmin("unmute")["syntax"].."\";")
        
        return true
    elseif tonumber(cmdArguments[1]) == nil then
        cmdClient = et.ClientNumberFromString(cmdArguments[1])
    else
        cmdClient = tonumber(cmdArguments[1])
    end
    
    if cmdClient == -1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dunmute: ^9no or multiple matches for '^7"..cmdArguments[1].."^9'.\";")
        
        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dunmute: ^9no connected player by that name or slot #\";")
        
        return true
    end
    
    if not players.isPlayerMuted(cmdClient) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dunmute: ^9no player by that name or slot # is muted\";")
        
        return true
    end
    
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dunmute: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9has been unmuted\";")
    
    players.setPlayerMuted(cmdClient, false)
    
    return true
end
commands.addadmin("unmute", commandUnmute, auth.PERM_MUTE, "unvoicemutes a player", "^9[^3name|slot#^9]")
