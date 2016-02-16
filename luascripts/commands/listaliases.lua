
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
local db = require "luascripts.wolfadmin.db.db"
local commands = require "luascripts.wolfadmin.commands"
local stats = require "luascripts.wolfadmin.players.stats"

function commandListAliases(clientId, cmdArguments)
    if settings.get("db_type") == "cfg" then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistaliases: ^9alias history is disabled.\";")
        
        return true
    elseif cmdArguments[1] == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistaliases usage: "..commands.get("listaliases")["syntax"].."\";")
        
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
    
    if et.G_shrubbot_permission(cmdClient, "!") == 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistaliases: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is immune to this command.\";")
        
        return true
    elseif et.G_shrubbot_level(cmdClient) > et.G_shrubbot_level(clientId) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistaliases: ^9sorry, but your intended victim has a higher admin level than you do.\";")
        
        return true
    end
    
    local player = db.getplayer(stats.get(cmdClient, "playerGUID"))["id"]
    local aliases = db.getaliases(player)
    
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dAliases for ^7"..et.gentity_get(cmdClient, "pers.netname").."^d:\";")
    for _, alias in pairs(aliases) do
        local numberOfSpaces = 24 - string.len(util.removeColors(alias["alias"]))
        local spaces = string.rep(" ", numberOfSpaces)
        
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^7"..spaces..alias["alias"].." ^7"..string.format("%8s", alias["used"]).." times\";")
    end
    
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^dlistaliases: ^9"..#aliases.." known aliases for ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9 (open console for the full list).\";")
    
    return true
end
commands.register("listaliases", commandListAliases, "f", "display all known aliases for a player", "^9[^3name|slot#^9]", function() return (settings.get("db_type") == "cfg") end)