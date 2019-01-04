
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

local db = require (wolfa_getLuaPath()..".db.db")

local players = require (wolfa_getLuaPath()..".players.players")

local events = require (wolfa_getLuaPath()..".util.events")
local settings = require (wolfa_getLuaPath()..".util.settings")
local tables = require (wolfa_getLuaPath()..".util.tables")

local acl = {}

local cachedLevels = {}
local cachedClients = {}

function acl.onClientConnect(clientId, firstTime, isBot)
    if settings.get("g_standalone") ~= 0 and db.isConnected() then
        local guid = et.Info_ValueForKey(et.trap_GetUserinfo(clientId), "cl_guid")
        local player = db.getPlayer(guid)

        if player then
            cachedClients[clientId] = {}

            local permissions = db.getPlayerPermissions(player["id"])

            for _, permission in ipairs(permissions) do
                table.insert(cachedClients[clientId], permission["permission"])
            end
        end
    end
end
events.handle("onClientConnect", acl.onClientConnect)

function acl.readPermissions()
    -- read level permissions into a cache file (can be loaded at mod start)
    -- should probably cache current players' permissions as well, then
    -- read in new players' permissions as they join the server

    local levels = db.getLevelsWithIds()
    for _, level in ipairs(levels) do
        cachedLevels[level["id"]] = {}
    end

    local permissions = db.getLevelPermissions()

    for _, permission in ipairs(permissions) do
        table.insert(cachedLevels[permission["level_id"]], permission["permission"])
    end
end

function acl.clearCache()
    cachedLevels = {}
end

function acl.isPlayerAllowed(clientId, permission, playerOnly)
    local level = acl.getPlayerLevel(clientId)

    return (not playerOnly and acl.isLevelAllowed(level, permission)) or (cachedClients[clientId] ~= nil and tables.contains(cachedClients[clientId], permission))
end

function acl.getLevels()
    return db.getLevels()
end

function acl.isLevel(levelId)
    return (db.getLevel(levelId) ~= nil)
end

function acl.addLevel(levelId, name)
    db.addLevel(levelId, name)

    cachedLevels[levelId] = {}
end

function acl.removeLevel(levelId)
    db.removeLevel(levelId)

    cachedLevels[levelId] = nil
end

function acl.reLevel(levelId, newLevelId)
    db.reLevel(levelId, newLevelId)
end

function acl.getLevelName(levelId)
    local level = db.getLevel(levelId)

    return level["name"]
end

function acl.getLevelPermissions(levelId)
    return cachedLevels[levelId]
end

function acl.addLevelPermission(levelId, permission)
    db.addLevelPermission(levelId, permission)

    table.insert(cachedLevels[levelId], permission)
end

function acl.removeLevelPermission(levelId, permission)
    db.removeLevelPermission(levelId, permission)

    for i, levelPermission in ipairs(cachedLevels[levelId]) do
        if levelPermission == permission then
            table.remove(cachedLevels[levelId], i)
        end
    end
end

function acl.copyLevelPermissions(levelId, newLevelId)
    db.copyLevelPermissions(levelId, newLevelId)

    cachedLevels[newLevelId] = tables.copy(cachedLevels[levelId])
end

function acl.removeLevelPermissions(levelId)
    db.removeLevelPermissions(levelId)

    cachedLevels[levelId] = {}
end

function acl.isLevelAllowed(levelId, permission)
    return cachedLevels[levelId] ~= nil and tables.contains(cachedLevels[levelId], permission)
end

function acl.getPlayerPermissions(clientId)
    return cachedClients[clientId]
end

function acl.addPlayerPermission(clientId, permission)
    db.addPlayerPermission(db.getPlayerId(clientId), permission)

    table.insert(cachedClients[clientId], permission)
end

function acl.removePlayerPermission(clientId, permission)
    db.removePlayerPermission(db.getPlayerId(clientId), permission)

    for i, levelPermission in ipairs(cachedClients[clientId]) do
        if levelPermission == permission then
            table.remove(cachedClients[clientId], i)
        end
    end
end

function acl.copyPlayerPermissions(clientId, newClientId)
    db.copyPlayerPermissions(db.getPlayerId(clientId), db.getPlayerId(newClientId))

    cachedClients[newClientId] = tables.copy(cachedClients[clientId])
end

function acl.removePlayerPermissions(clientId)
    db.removePlayerPermissions(db.getPlayerId(clientId))

    cachedClients[clientId] = {}
end

function acl.getPlayerLevel(clientId)
    local player = db.getPlayer(players.getGUID(clientId))

    return player["level_id"]
end

return acl
