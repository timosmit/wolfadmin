
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2018 Timo 'Timothy' Smit

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

local constants = require (wolfa_getLuaPath()..".util.constants")
local events = require (wolfa_getLuaPath()..".util.events")
local settings = require (wolfa_getLuaPath()..".util.settings")
local timers = require (wolfa_getLuaPath()..".util.timers")
local util = require (wolfa_getLuaPath()..".util.util")

local voting = {}

local allowed = {}
local forced = {}
local restricted = {}

function voting.allow(type, value)
    allowed[type] = value
    et.trap_Cvar_Set("vote_allow_"..type, value)
end

function voting.isAllowed(type)
    return (allowed[type] == 1)
end

function voting.force(type)
    forced[type] = 1
    voting.allow(type, 1)
end

function voting.isForced(type)
    return (forced[type] == 1)
end

function voting.isRestricted(type)
    return (restricted[type] == 1)
end

function voting.disableNextMap()
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dvote: ^9next map voting has automatically been disabled.\";")

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

function voting.onGameInit(levelTime, randomSeed, restartMap)
    voting.load()

    if settings.get("g_voteNextMapTimeout") > 0 then
        voting.allow("nextmap", 1)
    end
end
events.handle("onGameInit", voting.onGameInit)

function voting.onGameStateChange(gameState)
    if gameState == 0 and settings.get("g_voteNextMapTimeout") > 0 then
        timers.add(voting.disableNextMap, settings.get("g_voteNextMapTimeout") * 1000, 1)
    end
end
events.handle("onGameStateChange", voting.onGameStateChange)

function voting.onCallvote(clientId, type, args)
    if et.gentity_get(clientId, "sess.sessionTeam") == constants.TEAM_SPECTATORS or args[1] == "?" then
        return 0
    elseif voting.isRestricted(type) and not auth.isPlayerAllowed(clientId, auth.PERM_NOVOTELIMIT) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"callvote: you are not allowed to call this type of vote.\";")
        et.trap_SendServerCommand(clientId, "cp \"You are not allowed to call this type of vote.")

        return 1
    end
end
events.handle("onCallvote", voting.onCallvote)

function voting.onPollFinish(passed, poll)
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

            if tonumber(difficulty) then
                difficulty = tonumber(difficulty)
            elseif difficulty == "uber" then
                difficulty = 6
            elseif difficulty == "professional" then
                difficulty = 5
            elseif difficulty == "standard" then
                difficulty = 4
            elseif difficulty == "easy frag" then
                difficulty = 3
            elseif difficulty == "poor" then
                difficulty = 2
            elseif difficulty == "very poor" then
                difficulty = 1
            elseif difficulty == "poorest" then
                difficulty = 0
            else
                return
            end

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "bot difficulty "..difficulty)
        elseif string.find(poll, "set bot max") == 1 then
            local amount = string.sub(poll, 13)

            if tonumber(amount) then
                amount = tonumber(amount)
            else
                return
            end

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "bot maxbots "..amount)
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dmaxbots: ^9maximum set to ^7"..amount.." ^9bots.\";")
        end
    end
end
events.handle("onPollFinish", voting.onPollFinish)

return voting
