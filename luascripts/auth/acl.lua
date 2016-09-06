
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

local auth = require "luascripts.wolfadmin.auth.auth"

local db = require "luascripts.wolfadmin.db.db"

local players = require "luascripts.wolfadmin.players.players"

local events = require "luascripts.wolfadmin.util.events"
local files = require "luascripts.wolfadmin.util.files"

local acl = {}

function acl.readpermissions()
    -- read level permissions into a cache file (can be loaded at mod start)
    -- should probably cache current players' permissions as well, then
    -- read in new players' permissions as they join the server
end

function acl.clearcache()
    -- clear cache whenever database is updated, or do this manually
end

function acl.isallowed(clientId, permission)
    -- stub function, reads from cache

    return 1
end

function acl.getlevel(clientId)
    local player = db.getplayer(players.getGUID(clientId))

    return player["level_id"]
end

function acl.getlevelname(levelId)
    local level = db.getlevel(levelId)

    return level["name"]
end

return acl
