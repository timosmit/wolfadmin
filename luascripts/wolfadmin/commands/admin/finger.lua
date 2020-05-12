
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
local commands = wolfa_requireModule("commands.commands")
local config = wolfa_requireModule("config.config")
local output = wolfa_requireModule("game.output")
local players = wolfa_requireModule("players.players")
local util = wolfa_requireModule("util.util")

function commandFinger(clientId, command, victim)
    local cmdClient

    if victim == nil then
        output.clientConsole("^dfinger usage: "..commands.getadmin("finger")["syntax"], clientId)

        return true
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        output.clientConsole("^dfinger: ^9no or multiple matches for '^7"..victim.."^9'", clientId)

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        output.clientConsole("^dfinger: ^9no connected player by that name or slot #", clientId)

        return true
    end

    local name = players.getName(cmdClient)
    local cleanname = util.removeColors(players.getName(cmdClient))
    local codedname = players.getName(cmdClient):gsub("%^([^^])", "^^2%1")
    local slot = cmdClient
    local level = auth.getPlayerLevel(cmdClient)
    local levelName = util.removeColors(auth.getLevelName(level))
    local guid = players.getGUID(cmdClient)
    local ip = players.getIP(cmdClient)

    output.clientConsole("^dInformation about ^7"..name.."^d:", clientId)
    output.clientConsole("^dName:    ^2"..cleanname.." ("..codedname..")", clientId)
    output.clientConsole("^dSlot:    ^2"..slot..(slot < tonumber(et.trap_Cvar_Get("sv_privateClients")) and " ^9(private)" or ""), clientId)
    output.clientConsole("^dLevel:   ^2"..level.." ("..levelName..")", clientId)
    output.clientConsole("^dGUID:    ^2"..guid.."", clientId)
    output.clientConsole("^dIP:      ^2"..ip.."", clientId)

    return true
end
commands.addadmin("finger", commandFinger, auth.PERM_FINGER, "gives specific information about a player", "^9[^3name|slot#^9]", nil, (config.get("g_standalone") == 0))
