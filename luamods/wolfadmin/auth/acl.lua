
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

local db = require (wolfa_getLuaPath()..".db.db")

local players = require (wolfa_getLuaPath()..".players.players")

local events = require (wolfa_getLuaPath()..".util.events")
local tables = require (wolfa_getLuaPath()..".util.tables")

local acl = {}

local data = {}

function acl.readPermissions()
    -- read level permissions into a cache file (can be loaded at mod start)
    -- should probably cache current players' permissions as well, then
    -- read in new players' permissions as they join the server

    local levels = db.getLevelsWithIds()
    for _, level in ipairs(levels) do
        data[level["id"]] = {}
    end

    local roles = db.getLevelRoles()

    for _, role in ipairs(roles) do
        table.insert(data[role["level_id"]], role["role"])
    end
end
events.handle("onGameInit", acl.readPermissions)

function acl.clearCache()
    data = {}
end

function acl.isPlayerAllowed(clientId, permission)
    local level = acl.getPlayerLevel(clientId)

    return data[level] ~= nil and tables.contains(data[level], permission)
end

function acl.getLevels()
    return db.getLevels()
end

function acl.isLevel(levelId)
    return (db.getLevel(levelId) ~= nil)
end

function acl.addLevel(levelId, name)
    db.addLevel(levelId, name)

    data[levelId] = {}
end

function acl.removeLevel(levelId)
    db.removeLevel(levelId)

    data[levelId] = nil
end

function acl.reLevel(levelId, newLevelId)
    db.reLevel(levelId, newLevelId)
end

function acl.getLevelRoles(levelId)
    return data[levelId]
end

function acl.isLevelAllowed(levelId, role)
    return tables.contains(data[levelId], role)
end

function acl.addLevelRole(levelId, role)
    db.addLevelRole(levelId, role)

    table.insert(data[levelId], role)
end

function acl.removeLevelRole(levelId, role)
    db.removeLevelRole(levelId, role)

    for i, levelRole in ipairs(data[levelId]) do
        if levelRole == role then
            table.remove(data[levelId], i)
        end
    end
end

function acl.copyLevelRoles(levelId, newLevelId)
    db.copyLevelRoles(levelId, newLevelId)

    data[newLevelId] = tables.copy(data[levelId])
end

function acl.removeLevelRoles(levelId)
    db.removeLevelRoles(levelId)

    data[levelId] = {}
end

function acl.getPlayerLevel(clientId)
    local player = db.getPlayer(players.getGUID(clientId))

    return player["level_id"]
end

function acl.getLevelName(levelId)
    local level = db.getLevel(levelId)

    return level["name"]
end

return acl
