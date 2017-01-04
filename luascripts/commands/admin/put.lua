
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

local admin = require "luascripts.wolfadmin.admin.admin"
local auth = require "luascripts.wolfadmin.auth.auth"
local commands = require "luascripts.wolfadmin.commands.commands"
local constants = require "luascripts.wolfadmin.util.constants"
local util = require "luascripts.wolfadmin.util.util"

function commandPlayerLock(clientId, cmdArguments)
    if cmdArguments[2] == nil or (cmdArguments[2] ~= constants.TEAM_AXIS_SC and cmdArguments[2] ~= constants.TEAM_ALLIES_SC and cmdArguments[2] ~= constants.TEAM_SPECTATORS_SC) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dput usage: "..commands.getadmin("put")["syntax"].."\";")
        
        return true
    elseif tonumber(cmdArguments[1]) == nil then
        cmdClient = et.ClientNumberFromString(cmdArguments[1])
    else
        cmdClient = tonumber(cmdArguments[1])
    end

    if cmdClient == -1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dput: ^9no or multiple matches for '^7"..cmdArguments[1].."^9'.\";")
        
        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dput: ^9no connected player by that name or slot #\";")
        
        return true
    end

    if auth.isallowed(cmdClient, "!") == 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dput: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is immune to this command.\";")
        
        return true
    elseif auth.getlevel(cmdClient) > auth.getlevel(cmdClient) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dput: ^9sorry, but your intended victim has a higher admin level than you do.\";")
        
        return true
    end
    
    local team
    if cmdArguments[2] == constants.TEAM_AXIS_SC then
        team = constants.TEAM_AXIS
    elseif cmdArguments[2] == constants.TEAM_ALLIES_SC then
        team = constants.TEAM_ALLIES
    elseif cmdArguments[2] == constants.TEAM_SPECTATORS_SC then
        team = constants.TEAM_SPECTATORS
    end
    
    local teamname = util.getTeamColor(team)..util.getTeamName(team)

    -- TODO fix behaviour, cannot unbalance teams (see g_svcmds.c:SetTeam)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dput: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9has been put to "..teamname.."\";")

    admin.putPlayer(cmdClient, team)

    return true
end
commands.addadmin("put", commandPlayerLock, auth.PERM_LOCKPLAYER, "locks a player to a specific team", "^9[^3name|slot#^9]")
