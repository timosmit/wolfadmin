
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

local db = require "luascripts.wolfadmin.db.db"

local players = require "luascripts.wolfadmin.players.players"

local events = require "luascripts.wolfadmin.util.events"
local settings = require "luascripts.wolfadmin.util.settings"

local warns = {}

local data = {}

function warns.get(clientId, warnId)
    if warnId then
        return db.getwarn(warnId)
    else
        local playerid = db.getplayer(players.getGUID(clientId))["id"]
        
        return db.getwarns(playerid)
    end
end

function warns.getcount(clientId)
    local playerid = db.getplayer(players.getGUID(clientId))["id"]

    return db.getwarnscount(playerid)
end

function warns.getlimit(clientId, start, limit)
    local playerid = db.getplayer(players.getGUID(clientId))["id"]

    return db.getwarns(playerid, start, limit)
end

function warns.add(clientId, reason, adminId, datetime)
    local playerid = db.getplayer(players.getGUID(clientId))["id"]
    local adminid = db.getplayer(players.getGUID(clientId))["id"]
    
    db.addwarn(playerid, reason, adminid, datetime)
end

function warns.remove(clientId, warnId)
    if not warns.get(clientId, warnId) then
        return
    end
    
    db.removewarn(warnId)
end

return warns
