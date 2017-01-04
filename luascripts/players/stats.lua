
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

local players = require "luascripts.wolfadmin.players.players"

local stats = {}

local data = {}

function stats.get(clientId, statKey)
    if not players.isConnected(clientId) then
        error("client "..clientId.." is not connected")
    end
    
    if statKey and type(statKey) == "string" and data[clientId] then
        return data[clientId][statKey]
    end
    
    return false
end

function stats.set(clientId, statKey, statValue)
    if not players.isConnected(clientId) then
        error("client "..clientId.." is not connected")
    end
    
    if not data[clientId] then data[clientId] = {} end
    
    if statKey and type(statKey) == "string" then
        data[clientId][statKey] = statValue
        
        return true
    end
    
    return false
end

function stats.add(clientId, statKey, statAdd)
    statAdd = statAdd and statAdd or 1
    
    return stats.set(clientId, statKey, stats.get(clientId, statKey) + statAdd)
end

function stats.take(clientId, statKey, statTake)
    statTake = statTake and statTake or 1
    
    return stats.set(clientId, statKey, stats.get(clientId, statKey) - statTake)
end

function stats.remove(clientId)
    if not players.isConnected(clientId) then
        error("client "..clientId.." is not connected")
    end
    
    data[clientId] = nil
    
    return true
end

return stats
