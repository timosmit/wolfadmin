
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

local db = require "luascripts.wolfadmin.db.db"
local settings = require "luascripts.wolfadmin.util.settings"
local commands = require "luascripts.wolfadmin.commands.commands"
local warns = require "luascripts.wolfadmin.admin.warns"

function commandRemoveWarn(clientId, cmdArguments)
    if settings.get("g_warnHistory") == 0 or not db.isconnected() then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^ddewarn: ^9warn history is disabled.\";")
        
        return true
    elseif #cmdArguments < 2 or tonumber(cmdArguments[2]) == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^ddewarn usage: "..commands.getadmin("dewarn")["syntax"].."\";")
        
        return true
    elseif tonumber(cmdArguments[1]) == nil then
        cmdClient = et.ClientNumberFromString(cmdArguments[1])
    else
        cmdClient = tonumber(cmdArguments[1])
    end
    
    if cmdClient == -1 or cmdClient > et.trap_Cvar_Get("sv_maxclients") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^ddewarn: ^9no or multiple matches for '^7"..cmdArguments[1].."^9'.\";")
        
        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^ddewarn: ^9no connected player by that name or slot #\";")
        
        return true
    end
    
    local playerWarn = warns.get(cmdClient, tonumber(cmdArguments[2]))
    
    if not playerWarn then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^ddewarn: ^9warn #"..cmdArguments[2].." does not exist for ^7"..et.gentity_get(cmdClient, "pers.netname").."^9.\";")
    else
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^ddewarn: ^9warn #"..cmdArguments[2].." removed for ^7"..et.gentity_get(cmdClient, "pers.netname").."^9.\";")
        
        warns.remove(cmdClient, tonumber(cmdArguments[2]))
    end
    
    return true
end
commands.addadmin("dewarn", commandRemoveWarn, "R", "remove a warning for a certain player", "^9[^3name|slot#^9] ^9[^3warn#^9]", function() return (settings.get("g_warnHistory") == 0 or not db.isconnected()) end)
