
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
local db = wolfa_requireModule("db.db")
local commands = wolfa_requireModule("commands.commands")
local output = wolfa_requireModule("game.output")
local players = wolfa_requireModule("players.players")
local pagination = wolfa_requireModule("util.pagination")
local util = wolfa_requireModule("util.util")

function commandListAliases(clientId, command, victim, offset)
    local cmdClient

    if not db.isConnected() then
        output.clientConsole("^dlistaliases: ^9alias history is disabled.", clientId)
        
        return true
    elseif victim == nil then
        output.clientConsole("^dlistaliases usage: "..commands.getadmin("listaliases")["syntax"], clientId)
        
        return true
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end
    
    if cmdClient == -1 or cmdClient == nil then
        output.clientConsole("^dlistaliases: ^9no or multiple matches for '^7"..victim.."^9'.", clientId)
        
        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        output.clientConsole("^dlistaliases: ^9no connected player by that name or slot #", clientId)
        
        return true
    end
    
    if auth.isPlayerAllowed(cmdClient, "!") then
        output.clientConsole("^dlistaliases: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is immune to this command.", clientId)
        
        return true
    elseif auth.getPlayerLevel(cmdClient) > auth.getPlayerLevel(clientId) then
        output.clientConsole("^dlistaliases: ^9sorry, but your intended victim has a higher admin level than you do.", clientId)
        
        return true
    end
    
    local player = db.getPlayer(players.getGUID(cmdClient))["id"]
    
    local count = db.getAliasesCount(player)
    local limit, offset = pagination.calculate(count, 30, tonumber(offset))
    local aliases = db.getAliases(player, limit, offset)
    
    output.clientConsole("^dAliases for ^7"..et.gentity_get(cmdClient, "pers.netname").."^d:", clientId)
    for _, alias in pairs(aliases) do
        local numberOfSpaces = 24 - string.len(util.removeColors(alias["alias"]))
        local spaces = string.rep(" ", numberOfSpaces)
        
        output.clientConsole("^7"..spaces..alias["alias"].." ^7"..string.format("%8s", alias["used"]).." times", clientId)
    end
    
    output.clientConsole("^9Showing results ^7"..(offset + 1).." ^9- ^7"..(offset + limit).." ^9of ^7"..count.."^9.", clientId)
    output.clientChat("^dlistaliases: ^9aliases for ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9were printed to the console.", clientId)
    
    return true
end
commands.addadmin("listaliases", commandListAliases, auth.PERM_LISTALIASES, "display all known aliases for a player", "^9[^3name|slot#^9] ^9(^hoffset^9)")
