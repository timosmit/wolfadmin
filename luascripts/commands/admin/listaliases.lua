
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
local settings = require "luascripts.wolfadmin.util.settings"
local pagination = require "luascripts.wolfadmin.util.pagination"
local auth = require "luascripts.wolfadmin.auth.auth"
local db = require "luascripts.wolfadmin.db.db"
local commands = require "luascripts.wolfadmin.commands.commands"
local stats = require "luascripts.wolfadmin.players.stats"

function commandListAliases(clientId, cmdArguments)
    if not db.isconnected() then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistaliases: ^9alias history is disabled.\";")
        
        return true
    elseif cmdArguments[1] == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistaliases usage: "..commands.getadmin("listaliases")["syntax"].."\";")
        
        return true
    elseif tonumber(cmdArguments[1]) == nil then
        cmdClient = et.ClientNumberFromString(cmdArguments[1])
    else
        cmdClient = tonumber(cmdArguments[1])
    end
    
    if cmdClient == -1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistaliases: ^9no or multiple matches for '^7"..cmdArguments[1].."^9'.\";")
        
        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistaliases: ^9no connected player by that name or slot #\";")
        
        return true
    end
    
    if auth.isallowed(cmdClient, "!") == 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistaliases: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is immune to this command.\";")
        
        return true
    elseif auth.getlevel(cmdClient) > auth.getlevel(clientId) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistaliases: ^9sorry, but your intended victim has a higher admin level than you do.\";")
        
        return true
    end
    
    local player = db.getplayer(stats.get(cmdClient, "playerGUID"))["id"]
    
    local count = db.getaliasescount(player)
    local limit, offset = pagination.calculate(count, 30, tonumber(cmdArguments[2]))
    local aliases = db.getaliases(player, limit, offset)
    
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dAliases for ^7"..et.gentity_get(cmdClient, "pers.netname").."^d:\";")
    for _, alias in pairs(aliases) do
        local numberOfSpaces = 24 - string.len(util.removeColors(alias["alias"]))
        local spaces = string.rep(" ", numberOfSpaces)
        
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^7"..spaces..alias["alias"].." ^7"..string.format("%8s", alias["used"]).." times\";")
    end
    
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9Showing results ^7"..(offset + 1).." ^9- ^7"..limit.." ^9of ^7"..count.."^9.\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^dlistaliases: ^9aliases for ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9were printed to the console.\";")
    
    return true
end
commands.addadmin("listaliases", commandListAliases, auth.PERM_FINGER, "display all known aliases for a player", "^9[^3name|slot#^9] ^9(^hoffset^9)", function() return (not db.isconnected()) end)
