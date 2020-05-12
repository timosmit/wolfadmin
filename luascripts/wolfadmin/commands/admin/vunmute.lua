
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
local mutes = wolfa_requireModule("admin.mutes")
local commands = wolfa_requireModule("commands.commands")
local output = wolfa_requireModule("game.output")
local players = wolfa_requireModule("players.players")

function commandVoiceUnmute(clientId, command, victim)
    local cmdClient

    if victim == nil then
        output.clientConsole("^dvunmute usage: "..commands.getadmin("vunmute")["syntax"], clientId)
        
        return true
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end
    
    if cmdClient == -1 or cmdClient == nil then
        output.clientConsole("^dvunmute: ^9no or multiple matches for '^7"..victim.."^9'.", clientId)
        
        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        output.clientConsole("^dvunmute: ^9no connected player by that name or slot #", clientId)
        
        return true
    end
    
    if not players.isMuted(cmdClient) then
        output.clientConsole("^dvunmute: ^9no player by that name or slot # is voicemuted", clientId)
        
        return true
    end

    output.clientChat("^dvunmute: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9has been unvoicemuted.")

    mutes.removeByClient(cmdClient)
    
    return true
end
commands.addadmin("vunmute", commandVoiceUnmute, auth.PERM_VOICEMUTE, "unmutes a player (voice chat only)", "^9[^3name|slot#^9]")
