
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

local auth = require "luamods.wolfadmin.auth.auth"

local db = require "luamods.wolfadmin.db.db"

local players = require "luamods.wolfadmin.players.players"

local events = require "luamods.wolfadmin.util.events"
local files = require "luamods.wolfadmin.util.files"
local tables = require "luamods.wolfadmin.util.tables"

local acl = {}

local data = {}

function acl.readPermissions()
    -- read level permissions into a cache file (can be loaded at mod start)
    -- should probably cache current players' permissions as well, then
    -- read in new players' permissions as they join the server

    local roles = db.getLevelRoles()

    for _, role in ipairs(roles) do
        if not data[role["level_id"]] then
            data[role["level_id"]] = {}
        end

        table.insert(data[role["level_id"]], role["role"])
    end
end
events.handle("onGameInit", acl.readPermissions)

function acl.clearCache()
    -- clear cache whenever database is updated, or do this manually
end

function acl.isallowed(clientId, permission)
    local level = acl.getlevel(clientId)

    if data[level] ~= nil and tables.contains(data[level], permission) then
        return 1
    end

    return 0
end

function acl.getlevel(clientId)
    local player = db.getplayer(players.getGUID(clientId))

    return player["level_id"]
end

function acl.getlevelname(levelId)
    local level = db.getLevel(levelId)

    return level["name"]
end

return acl
