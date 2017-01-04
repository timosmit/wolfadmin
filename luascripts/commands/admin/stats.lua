
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

local auth = require "luascripts.wolfadmin.auth.auth"
local util = require "luascripts.wolfadmin.util.util"
local commands = require "luascripts.wolfadmin.commands.commands"

function commandShowStats(clientId, cmdArguments)
    if cmdArguments[1] == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dstats usage: "..commands.getadmin("stats")["syntax"].."\";")
        
        return true
    elseif tonumber(cmdArguments[1]) == nil then
        cmdClient = et.ClientNumberFromString(cmdArguments[1])
    else
        cmdClient = tonumber(cmdArguments[1])
    end
    
    if cmdClient == -1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dstats: ^9no or multiple matches for '^7"..cmdArguments[1].."^9'.\";")
        
        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dstats: ^9no connected player by that name or slot #\";")
        
        return true
    end
    
    local stats = {
        ["name"] = et.gentity_get(cmdClient, "pers.netname"), 
        ["cleanname"] = et.gentity_get(cmdClient, "pers.netname"):gsub("%^[^^]", ""), 
        ["codedsname"] = et.gentity_get(cmdClient, "pers.netname"):gsub("%^([^^])", "^^2%1"), 
        ["slot"] = cmdClient, 
        ["team"] = et.gentity_get(cmdClient, "sess.sessionTeam"),
        ["class"] = et.gentity_get(cmdClient, "sess.playerType"), 
        ["health"] = et.gentity_get(cmdClient, "health"),
        ["kills"] = et.gentity_get(cmdClient, "sess.kills"),
        ["teamkills"] = et.gentity_get(cmdClient, "sess.team_kills"), 
        ["totalkills"] = et.gentity_get(cmdClient, "sess.kills") + et.gentity_get(cmdClient, "sess.team_kills"), 
        ["damage"] = et.gentity_get(cmdClient, "sess.damage_given"), 
        ["damagereceived"] = et.gentity_get(cmdClient, "sess.damage_received"), 
        ["teamdamage"] = et.gentity_get(cmdClient, "sess.team_damage"), 
        -- ["teamdamagereceived"] = et.gentity_get(cmdClient, "sess.team_received"), -- ETPro only
        ["totaldamage"] = et.gentity_get(cmdClient, "sess.damage_given") + et.gentity_get(cmdClient, "sess.team_damage"), 
        ["deaths"] = et.gentity_get(cmdClient, "sess.deaths"), 
        ["suicides"] = et.gentity_get(cmdClient, "sess.suicides")
    }
    
    if stats["totalkills"] == 0 then stats["totalkills"] = 1 end
    if stats["totaldamage"] == 0 then stats["totaldamage"] = 1 end
    
    --[[ for key, value in pairs(stats) do
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dstats: ^9"..string.format("%-15s", key..":").." ^7"..value.."\";")
    end ]]
    
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dStatistics for ^7"..stats["name"].."^d:\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dName:    ^2"..stats["cleanname"].." ("..stats["codedsname"]..")\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dSlot:    ^2"..stats["slot"]..(stats["slot"] < tonumber(et.trap_Cvar_Get("sv_privateClients")) and " ^9(private)" or "").."\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dTeam:    ^2"..util.getTeamName(stats["team"]).."\";")
    
    if stats["team"] ~= et.TEAM_SPECTATORS then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dClass:   ^2"..util.getClassName(stats["class"]).."\";")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dHealth:  ^2"..(stats["health"] < 0 and "dead" or stats["health"]).."\";")
    end
    
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dKills:   ^2"..string.format("%-8s", stats["kills"]).." ^dTeam kills:   ^2"..stats["teamkills"].." ^9("..string.format("%0.2f", (stats["teamkills"] / (stats["totalkills"] or 1) * 100)).." percent)\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dDamage:  ^2"..string.format("%-8s", stats["damage"]).." ^dTeam damage:  ^2"..stats["teamdamage"].." ^9("..string.format("%0.2f", (stats["teamdamage"] / (stats["totaldamage"] or 1) * 100)).." percent)\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dDeaths:  ^2"..string.format("%-8s", stats["deaths"]).." ^dSuicides:     ^2"..stats["suicides"].."\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dK/D:     ^2"..string.format("%0.2f", (stats["kills"] / ((stats["deaths"] > 0) and stats["deaths"] or 1))).."\";")
    
    -- NQ 1.3.0 and higher
    --[[ for key, value in ipairs(stats["weapstats"]) do
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dstats: ^9"..stats["weapstats"].."\";")
    end ]]
    
    -- NQ 1.3.0 and higher
    --[[ local weapstats = et.gentity_get(cmdClient, "sess.aWeaponStats", WP_THOMPSON)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dstats: ^9"..weapstats.."\";") ]]
    
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^dstats: ^9stats for ^7"..stats["name"].." ^9were printed to the console.\";")
    
    return true
end
commands.addadmin("stats", commandShowStats, auth.PERM_LISTSTATS, "display the statistics for a specific player", "^9[^3name|slot#^9]")
