
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2019 Timo 'Timothy' Smit

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

local constants = wolfa_requireModule("util.constants")
local tables = wolfa_requireModule("util.tables")
local events = wolfa_requireModule("util.events")

local teams = {}

local players = {
    [constants.TEAM_AXIS] = {},
    [constants.TEAM_ALLIES] = {},
    [constants.TEAM_SPECTATORS] = {}
}

local locks = {
    [constants.TEAM_AXIS] = false,
    [constants.TEAM_ALLIES] = false,
    [constants.TEAM_SPECTATORS] = false
}

function teams.get()
    return players
end

function teams.count(team)
    return #players[team]
end

function teams.difference()
    return math.abs(teams.count(constants.TEAM_AXIS) - teams.count(constants.TEAM_ALLIES))
end

function teams.lock(teamId)
    locks[teamId] = true
end

function teams.unlock(teamId)
    locks[teamId] = false
end

function teams.isLocked(teamId)
    return locks[teamId]
end

function teams.onconnect(clientId, firstTime, isBot)
    local team = tonumber(et.gentity_get(clientId, "sess.sessionTeam"))

    if not tables.contains(players[team], clientId) then
        table.insert(players[team], clientId)
    end
end
events.handle("onClientConnect", teams.onconnect)

function teams.ondisconnect(clientId)
    local team = tonumber(et.gentity_get(clientId, "sess.sessionTeam"))
    local idx = tables.find(players[team], clientId)

    if idx then
        table.remove(players[team], idx)
    end
end
events.handle("onClientDisconnect", teams.ondisconnect)

function teams.onclientteamchange(clientId, old, new)
    local idx = tables.find(players[old], clientId)

    if idx then
        table.remove(players[old], idx)
    end

    table.insert(players[new], clientId)
end
events.handle("onClientTeamChange", teams.onclientteamchange)

return teams
