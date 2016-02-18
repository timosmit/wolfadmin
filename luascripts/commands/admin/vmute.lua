
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

local util = require "luascripts.wolfadmin.util.util"
local commands = require "luascripts.wolfadmin.commands.commands"
local admin = require "luascripts.wolfadmin.admin.admin"

function commandVoiceMute(clientId, cmdArguments)
    if cmdArguments[1] == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dvmute usage: "..commands.getadmin("vmute")["syntax"].."\";")
        
        return true
    elseif tonumber(cmdArguments[1]) == nil then
        cmdClient = et.ClientNumberFromString(cmdArguments[1])
    else
        cmdClient = tonumber(cmdArguments[1])
    end
    
    if cmdClient == -1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dvmute: ^9no or multiple matches for '^7"..cmdArguments[1].."^9'.\";")
        
        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dvmute: ^9no connected player by that name or slot #\";")
        
        return true
    end
    
    local vmuteTime, vmuteReason = 600, "muted by admin"
    
    if cmdArguments[2] and util.getTimeFromString(cmdArguments[2]) and cmdArguments[3] then
        vmuteTime = util.getTimeFromString(cmdArguments[2])
        vmuteReason = table.concat(cmdArguments, " ", 3)
    elseif cmdArguments[2] and util.getTimeFromString(cmdArguments[2]) then
        vmuteTime = util.getTimeFromString(cmdArguments[2])
    elseif cmdArguments[2] then
        vmuteReason = table.concat(cmdArguments, " ", 2)
    elseif et.G_shrubbot_permission(clientId, "8") ~= 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dvmute usage: "..commands.getadmin("vmute")["syntax"].."\";")
        
        return true
    end
    
    if admin.isVoiceMuted(cmdClient) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dvmute: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is already muted.\";")
        
        return true
    elseif et.G_shrubbot_permission(cmdClient, "!") == 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dvmute: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is immune to this command.\";")
        
        return true
    elseif et.G_shrubbot_level(cmdClient) > et.G_shrubbot_level(clientId) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dvmute: ^9sorry, but your intended victim has a higher admin level than you do.\";")
        
        return true
    end
        
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dvmute: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9has been voicemuted for "..vmuteTime.." seconds\";")
    
    admin.muteVoice(cmdClient, os.time() + vmuteTime)
    
    return true
end
commands.addadmin("vmute", commandVoiceMute, "m", "voicemutes a player", "^9[^3name|slot#^9]")