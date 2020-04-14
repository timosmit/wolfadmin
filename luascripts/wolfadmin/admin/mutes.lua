
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2020 Timo 'Timothy' Smit

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

local db = wolfa_requireModule("db.db")

local players = wolfa_requireModule("players.players")

local events = wolfa_requireModule("util.events")
local timers = wolfa_requireModule("util.timers")

local mutes = {}

local storedMuteTimer
local liveMuteTimer

function mutes.get(muteId)
    return db.getMute(muteId)
end

function mutes.getCount()
    return db.getMutesCount()
end

function mutes.getList(start, limit)
    return db.getMutes(start, limit)
end

function mutes.add(victimId, invokerId, type, duration, reason)
    local victimPlayerId = db.getPlayer(players.getGUID(victimId))["id"]
    local invokerPlayerId = db.getPlayer(players.getGUID(invokerId))["id"]

    local reason = reason and reason or "muted by admin"

    players.setMuted(victimId, true, type, os.time(), os.time() + duration)
    db.addMute(victimPlayerId, invokerPlayerId, type, os.time(), duration, reason)
end

function mutes.remove(muteId)
    db.removeMute(muteId)
end

function mutes.removeByClient(clientId)
    players.setMuted(clientId, false)

    local guid = et.Info_ValueForKey(et.trap_GetUserinfo(clientId), "cl_guid")
    local playerId = db.getPlayer(guid)["id"]
    local mute = db.getMuteByPlayer(playerId)

    if mute then
        return mutes.remove(mute["id"])
    end
end

function mutes.checkStoredMutes()
    db.removeExpiredMutes()
end

function mutes.checkLiveMutes()
    for clientId = 0, et.trap_Cvar_Get("sv_maxclients") - 1 do
        if players.isMuted(clientId) and players.getMuteExpiresAt(clientId) < os.time() then
            mutes.removeByClient(clientId)

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dunmute: ^7"..et.gentity_get(clientId, "pers.netname").." ^9has been automatically unmuted\";")
        end
    end
end

function mutes.onInit()
    if db.isConnected() then
        storedMuteTimer = timers.add(mutes.checkStoredMutes, 60000, 0, false, false)
        liveMuteTimer = timers.add(mutes.checkLiveMutes, 1000, 0, false, false)
    end
end
events.handle("onGameInit", mutes.onInit)

return mutes
