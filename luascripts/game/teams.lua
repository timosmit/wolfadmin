
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

local constants = require "luascripts.wolfadmin.util.constants"
local tables = require "luascripts.wolfadmin.util.tables"
local events = require "luascripts.wolfadmin.util.events"

local teams = {}

local data = {
    [constants.TEAM_AXIS] = {},
    [constants.TEAM_ALLIES] = {},
    [constants.TEAM_SPECTATORS] = {}
}

function teams.get()
    return data
end

function teams.count(team)
    return #data[team]
end

function teams.difference()
    return math.abs(teams.count(constants.TEAM_AXIS) - teams.count(constants.TEAM_ALLIES))
end

function teams.onconnect(clientId, firstTime, isBot)
    local team = tonumber(et.gentity_get(clientId, "sess.sessionTeam"))

    if not tables.contains(data[team], clientId) then
        table.insert(data[team], clientId)
    end
end
events.handle("onClientConnect", teams.onconnect)

function teams.ondisconnect(clientId)
    local team = tonumber(et.gentity_get(clientId, "sess.sessionTeam"))
    local idx = tables.find(data[team], clientId)

    if idx then
        table.remove(data[team], idx)
    end
end
events.handle("onClientDisconnect", teams.ondisconnect)

function teams.onclientteamchange(clientId, old, new)
    local idx = tables.find(data[old], clientId)

    if idx then
        table.remove(data[old], idx)
    end

    table.insert(data[new], clientId)
end
events.handle("onClientTeamChange", teams.onclientteamchange)

return teams