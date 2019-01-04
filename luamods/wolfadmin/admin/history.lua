
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

local history = {}

function history.get(clientId, historyId)
    return db.getHistoryItem(historyId)
end

function history.getCount(clientId)
    local playerId = db.getPlayer(players.getGUID(clientId))["id"]

    return db.getHistoryCount(playerId)
end

function history.getList(clientId, start, limit)
    local playerId = db.getPlayer(players.getGUID(clientId))["id"]

    return db.getHistory(playerId, start, limit)
end

function history.add(victimId, invokerId, type, reason)
    local victimPlayerId = db.getPlayer(players.getGUID(victimId))["id"]
    local invokerPlayerId = db.getPlayer(players.getGUID(invokerId))["id"]

    db.addHistory(victimPlayerId, invokerPlayerId, type, os.time(), reason)
end

function history.remove(clientId, historyId)
    db.removeHistory(historyId)
end

return history
