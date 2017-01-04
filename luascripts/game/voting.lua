
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
local constants = require "luascripts.wolfadmin.util.constants"
local util = require "luascripts.wolfadmin.util.util"
local events = require "luascripts.wolfadmin.util.events"
local timers = require "luascripts.wolfadmin.util.timers"
local settings = require "luascripts.wolfadmin.util.settings"
local bots = require "luascripts.wolfadmin.game.bots"

local voting = {}

local allowed = {}
local forced = {}
local restricted = {}

function voting.allow(type, value)
    allowed[type] = value
    et.trap_Cvar_Set("vote_allow_"..type, value)
end

function voting.isallowed(type)
    return (allowed[type] == 1)
end

function voting.force(type)
    forced[type] = 1
    voting.allow(type, 1)
end

function voting.isforced(type)
    return (forced[type] == 1)
end

function voting.isrestricted(type)
    return (restricted[type] == 1)
end

function voting.disablenextmap()
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dvote: ^9next map voting has automatically been disabled.\";")
    
    voting.allow("nextmap", 0)
end

function voting.load()
    for _, type in pairs(constants.VOTE_TYPES) do
        allowed[type] = tonumber(et.trap_Cvar_Get("vote_allow_"..type))
        forced[type] = 0
    end
    
    local restrictedVotes = util.split(settings.get("g_restrictedVotes"), ",")
    
    for _, type in pairs(restrictedVotes) do
        restricted[type] = 1
    end
end

function voting.oninit(levelTime, randomSeed, restartMap)
    voting.load()
    
    if settings.get("g_voteNextMapTimeout") > 0 then
        voting.allow("nextmap", 1)
    end
end
events.handle("onGameInit", voting.oninit)

function voting.ongamestatechange(gameState)
    if gameState == 0 and settings.get("g_voteNextMapTimeout") > 0 then
        timers.add(voting.disablenextmap, settings.get("g_voteNextMapTimeout") * 1000, 1)
    end
end
events.handle("onGameStateChange", voting.ongamestatechange)

function voting.oncallvote(clientId, type, args)
    if et.gentity_get(clientId, "sess.sessionTeam") == constants.TEAM_SPECTATORS or args[1] == "?" then
        return 0
    elseif voting.isrestricted(type) and auth.isallowed(clientId, PERM_NOVOTELIMIT) ~= 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"callvote: you are not allowed to call this type of vote.\";")
        et.trap_SendServerCommand(clientId, "cp \"You are not allowed to call this type of vote.")
        
        return 1
    end
end
events.handle("onCallvote", voting.oncallvote)

function voting.onpollfinish(passed, poll)
    if passed then
        if poll == "enable bots" then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "needbots")
        elseif poll == "disable bots" then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "kickbots")
        elseif string.find(poll, "put bots") == 1 then
            local team = string.sub(poll, 10)
            
            if team == "axis" then
                team = constants.TEAM_AXIS_SC
            elseif team == "allies" then
                team = constants.TEAM_ALLIES_SC
            else
                return
            end
            
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "putbots "..team)
        elseif string.find(poll, "set bot difficulty") == 1 then
            local difficulty = string.sub(poll, 20)
            
            if difficulty == "epic" then
                difficulty = 6
            elseif difficulty == "hard" then
                difficulty = 5
            elseif difficulty == "normal" then
                difficulty = 4
            else
                return
            end
            
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "bot difficulty "..difficulty)
        -- else
            -- et.trap_SendConsoleCommand(et.EXEC_APPEND, command)
        end
    end
end
events.handle("onPollFinish", voting.onpollfinish)

return voting