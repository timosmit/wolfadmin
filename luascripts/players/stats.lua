
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

local events = require "luascripts.wolfadmin.util.events"

local stats = {}

local data = {[-1337] = {["playerGUID"] = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"}}

-- TODO: need to check this in stat functions, apparently goes wrong
function wolfa_isPlayer(clientId)
    if data[clientId] then
        return true
    end
    
    return false
end

function stats.get(clientId, statKey)
    -- if not wolfa_isPlayer(clientId) then return false end
    
    if statKey and type(statKey) == "string" and data[clientId] then
        return data[clientId][statKey]
    end
    
    return false
end

function stats.set(clientId, statKey, statValue)
    -- if not wolfa_isPlayer(clientId) then return false end
    
    if not data[clientId] then data[clientId] = {} end
    
    if statKey and type(statKey) == "string" then
        data[clientId][statKey] = statValue
        
        return true
    end
    
    return false
end

function stats.add(clientId, statKey, statAdd) -- alias
    statAdd = statAdd and statAdd or 1
    
    return stats.set(clientId, statKey, stats.get(clientId, statKey) + statAdd)
end

function stats.take(clientId, statKey, statTake) -- alias
    statTake = statTake and statTake or 1
    
    return stats.set(clientId, statKey, stats.get(clientId, statKey) - statTake)
end

function stats.remove(clientId)
    -- if not wolfa_isPlayer(clientId) then return false end
    
    data[clientId] = nil
    
    return true
end

function stats.onconnect(clientId, firstTime, isBot)
    local clientInfo = et.trap_GetUserinfo(clientId)
    
    -- name is NOT yet set in pers.netname, so get all info out of infostring
    stats.set(clientId, "playerName", et.Info_ValueForKey(clientInfo, "name"))
    stats.set(clientId, "playerGUID", et.Info_ValueForKey(clientInfo, "cl_guid"))
    stats.set(clientId, "playerIP", string.gsub(et.Info_ValueForKey(clientInfo, "ip"), ":%d*", ""))
    stats.set(clientId, "playerTeam", tonumber(et.gentity_get(clientId, "sess.sessionTeam")))
    stats.set(clientId, "isBot", isBot)
    
    if firstTime then
        stats.set(clientId, "voiceMute", false)
    end
end
events.handle("onClientConnect", stats.onconnect)

function stats.ondisconnect(clientId)
    stats.remove(clientId)
end
events.handle("onClientDisconnect", stats.ondisconnect)

function stats.onteamchange(clientId)
    local clientInfo = et.trap_GetUserinfo(clientId)
    local old = stats.get(clientId, "playerTeam")
    local new = tonumber(et.gentity_get(clientId, "sess.sessionTeam"))

    if new ~= old then
        stats.set(clientId, "playerTeam", new)

        events.trigger("onClientTeamChange", clientId, old, new)
    end
end
events.handle("onClientInfoChange", stats.onteamchange)

return stats