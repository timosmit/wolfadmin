
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

local config = wolfa_requireModule("config.config")
local teams = wolfa_requireModule("game.teams")
local output = wolfa_requireModule("game.output")
local server = wolfa_requireModule("game.server")
local constants = wolfa_requireModule("util.constants")
local bits = wolfa_requireModule("util.bits")
local events = wolfa_requireModule("util.events")
local tables = wolfa_requireModule("util.tables")
local timers = wolfa_requireModule("util.timers")
local util = wolfa_requireModule("util.util")

local balancer = {}

balancer.BALANCE_RANDOM = 0
balancer.BALANCE_LAST_JOINED = 1
balancer.BALANCE_ONLY_DEAD = 2
balancer.BALANCE_NOT_OBJECTIVE = 4

local balancerTimer

local lastJoined = {[constants.TEAM_AXIS] = {}, [constants.TEAM_ALLIES] = {}, [constants.TEAM_SPECTATORS] = {}}
local evenerCount = 0

function balancer.balance(byAdmin, forceBalance)
    local teamsDifference = teams.difference()

    if teamsDifference <= 1 then
        evenerCount = 0

        if byAdmin then
            output.clientChat("^dbalancer: ^9teams are even.")
        end

        return
    end

    local teamGreater, teamSmaller

    if teams.count(constants.TEAM_AXIS) > teams.count(constants.TEAM_ALLIES) then
        teamGreater = constants.TEAM_AXIS
        teamSmaller = constants.TEAM_ALLIES
    elseif teams.count(constants.TEAM_ALLIES) > teams.count(constants.TEAM_AXIS) then
        teamGreater = constants.TEAM_ALLIES
        teamSmaller = constants.TEAM_AXIS
    end

    if config.get("g_evenerMaxDifference") > 0 and teamsDifference >= config.get("g_evenerMaxDifference") then
        evenerCount = evenerCount + 1

        if forceBalance or evenerCount >= 2 then
            server.exec("!shuffle;")
            output.clientPopup("^dbalancer: ^7THE TEAMS HAVE BEEN ^1SHUFFLED^7!")

            evenerCount = 0
        else
            output.clientPopup("^dbalancer: ^1EVEN THE TEAMS ^7OR ^1SHUFFLE")
        end
    elseif teamsDifference >= config.get("g_evenerMinDifference") then
        evenerCount = evenerCount + 1

        if forceBalance or evenerCount >= 3 then
            local teamsData = teams.get()

            for i = 1, math.floor(teamsDifference / 2) do
                local player = balancer.findPlayer(teamsData[teamGreater], teamGreater, teamSmaller)

                server.exec("!put "..player.." "..(teamGreater == constants.TEAM_AXIS and constants.TEAM_ALLIES_SC or constants.TEAM_AXIS_SC)..";")
                output.clientChat("^dbalancer: ^9thank you, ^7"..et.gentity_get(player, "pers.netname").."^9, for helping to even the teams.")

                teamsData = teams.get()
            end

            evenerCount = 0
        else
            local teamGreaterName, teamSmallerName = util.getTeamName(teamGreater), util.getTeamName(teamSmaller)
            local teamGreaterColor, teamSmallerColor = util.getTeamColor(teamGreater), util.getTeamColor(teamSmaller)

            output.clientChat("^dbalancer: ^9teams seem unfair, would someone from "..teamGreaterColor..teamGreaterName.." ^9please switch to "..teamSmallerColor..teamSmallerName.."^9?")
        end
    end
end

function balancer.findPlayer(team, teamGreater, teamSmaller)
    local playerSelection = config.get("g_evenerPlayerSelection")

    if bits.hasbit(playerSelection, balancer.BALANCE_LAST_JOINED) then
        if #lastJoined[teamGreater] > 0 then
            return lastJoined[teamGreater][#lastJoined[teamGreater]]
        end
    end

    local players = {}

    for _, playerId in ipairs(team) do
        local health = tonumber(et.gentity_get(playerId, "health"))

        local blueflag = et.gentity_get(playerId, "ps.powerups", 5) -- bg_public.h enum powerup_t PW_REDFLAG 6 and PW_BLUEFLAG 7
        local redflag = et.gentity_get(playerId, "ps.powerups", 6)

        if
            (not bits.hasbit(playerSelection, balancer.BALANCE_ONLY_DEAD) or health <= 0)
        and
            (not bits.hasbit(playerSelection, balancer.BALANCE_NOT_OBJECTIVE) or (blueflag ~= 0 and redflag ~= 0))
        then
            table.insert(players, playerId)
        end
    end

    if #players == 0 then
        players = team
    end

    local rand = math.random(#players)

    return players[rand]
end

function balancer.onclientteamchange(clientId, old, new)
    local idx = tables.find(lastJoined[old], clientId)

    if idx then
        table.remove(lastJoined[old], idx)
    end

    if #lastJoined[new] == 10 then
        table.remove(lastJoined[new], 1)
    end

    lastJoined[new][#lastJoined[new] + 1] = clientId
end
events.handle("onClientTeamChange", balancer.onclientteamchange)

function balancer.onclientdisconnect(clientId)
    local team = tonumber(et.gentity_get(clientId, "sess.sessionTeam"))
    local idx = tables.find(lastJoined[team], clientId)

    if idx then
        table.remove(lastJoined[team], idx)
    end
end
events.handle("onClientDisconnect", balancer.onclientdisconnect)

function balancer.enable()
    balancerTimer = timers.add(balancer.balance, config.get("g_evenerInterval") * 1000, 0, false, false)
end

function balancer.disable()
    timers.remove(balancerTimer)

    balancerTimer = nil
end

function balancer.isRunning()
    return (balancerTimer ~= nil)
end

function balancer.oninit()
    if config.get("g_balancedteams") ~= 0 and config.get("g_evenerInterval") > 0 then
        balancer.enable()
    end
end
events.handle("onGameInit", balancer.oninit)

return balancer
