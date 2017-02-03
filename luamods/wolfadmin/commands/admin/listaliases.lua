
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

local db = require (wolfa_getLuaPath()..".db.db")

local commands = require (wolfa_getLuaPath()..".commands.commands")

local players = require (wolfa_getLuaPath()..".players.players")

local pagination = require (wolfa_getLuaPath()..".util.pagination")
local settings = require (wolfa_getLuaPath()..".util.settings")
local util = require (wolfa_getLuaPath()..".util.util")

function commandListAliases(clientId, command, victim, offset)
    if not db.isconnected() then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistaliases: ^9alias history is disabled.\";")
        
        return true
    elseif victim == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistaliases usage: "..commands.getadmin("listaliases")["syntax"].."\";")
        
        return true
    elseif tonumber(victim) == nil or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end
    
    if cmdClient == -1 or cmdClient == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistaliases: ^9no or multiple matches for '^7"..victim.."^9'.\";")
        
        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistaliases: ^9no connected player by that name or slot #\";")
        
        return true
    end
    
    if auth.isPlayerAllowed(cmdClient, "!") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistaliases: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is immune to this command.\";")
        
        return true
    elseif auth.getPlayerLevel(cmdClient) > auth.getPlayerLevel(clientId) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistaliases: ^9sorry, but your intended victim has a higher admin level than you do.\";")
        
        return true
    end
    
    local player = db.getplayer(players.getGUID(cmdClient))["id"]
    
    local count = db.getaliasescount(player)
    local limit, offset = pagination.calculate(count, 30, tonumber(offset))
    local aliases = db.getaliases(player, limit, offset)
    
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dAliases for ^7"..et.gentity_get(cmdClient, "pers.netname").."^d:\";")
    for _, alias in pairs(aliases) do
        local numberOfSpaces = 24 - string.len(util.removeColors(alias["alias"]))
        local spaces = string.rep(" ", numberOfSpaces)
        
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^7"..spaces..alias["alias"].." ^7"..string.format("%8s", alias["used"]).." times\";")
    end
    
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9Showing results ^7"..(offset + 1).." ^9- ^7"..(offset + limit).." ^9of ^7"..count.."^9.\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^dlistaliases: ^9aliases for ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9were printed to the console.\";")
    
    return true
end
commands.addadmin("listaliases", commandListAliases, auth.PERM_LISTALIASES, "display all known aliases for a player", "^9[^3name|slot#^9] ^9(^hoffset^9)")
