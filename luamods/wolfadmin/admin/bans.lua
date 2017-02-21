
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

local bans = {}

function bans.get(banId)
    return db.getBan(banId)
end

function bans.getCount()
    return db.getBansCount()
end

function bans.getList(start, limit)
    return db.getBans(start, limit)
end

function bans.add(victimId, invokerId, duration, reason)
    local victimPlayerId = db.getplayer(players.getGUID(victimId))["id"]
    local invokerPlayerId = db.getplayer(players.getGUID(invokerId))["id"]

    local reason = reason and reason or "banned by admin"

    db.addBan(victimPlayerId, invokerPlayerId, os.time(), duration, reason)

    et.trap_DropClient(victimId, "You have been banned for "..duration.." seconds, Reason: "..reason, 0)
end

function bans.remove(banId)
    db.removeBan(banId)
end

return bans
