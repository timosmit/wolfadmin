
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

local db = require "luascripts.wolfadmin.db.db"

local players = require "luascripts.wolfadmin.players.players"
-- local stats = require "luascripts.wolfadmin.players.stats"

local constants = require "luascripts.wolfadmin.util.constants"
local events = require "luascripts.wolfadmin.util.events"
local files = require "luascripts.wolfadmin.util.files"
local settings = require "luascripts.wolfadmin.util.settings"
local util = require "luascripts.wolfadmin.util.util"

local admin = {}

function admin.putPlayer(clientId, teamId)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "forceteam "..clientId.." "..util.getTeamCode(teamId)..";")
end

function admin.kickPlayer(victimId, invokerId, reason)
    et.trap_DropClient(victimId, "You have been kicked, Reason: "..(reason and reason or "kicked by admin"), 0)
end

function admin.setPlayerLevel(clientId, level, adminId)
    local playerid = db.getplayer(players.getGUID(clientId))["id"]
    local adminid = db.getplayer(players.getGUID(clientId))["id"]

    db.updateplayerlevel(playerid, level)
    db.addsetlevel(playerid, level, adminid, os.time())
end

function admin.onconnectattempt(clientId, firstTime, isBot)
    if firstTime then
        local guid = et.Info_ValueForKey(et.trap_GetUserinfo(clientId), "cl_guid")

        if guid == "NO_GUID" or guid == "unknown" then
            return "\n\nIt appears you do not have a ^7GUID^9/^7etkey^9. In order to play on this server, enable ^7PunkBuster ^9(use ^7\\pb_cl_enable^9) ^9and/or create an ^7etkey^9.\n\nMore info: ^7www.etkey.org"
        end

        local player = db.getplayer(guid)
        if player then
            local playerId = player["id"]
            local ban = db.getBanByPlayer(playerId)
            if ban then
                return "\n\nYou have been banned for "..ban["duration"].." seconds, Reason: "..ban["reason"]
            end
        end
    end

    events.trigger("onClientConnect", clientId, firstTime, isBot)
end
events.handle("onClientConnectAttempt", admin.onconnectattempt)

function admin.onconnect(clientId, firstTime, isBot)
    -- only increase the counter on first connection (fixes counter increase on 
    -- clientbegin which is also triggered on warmup/maprestart/etc)
    --[[ stats.set(clientId, "namechangeStart", os.time())
    stats.set(clientId, "namechangePts", 0) ]]

    local guid = et.Info_ValueForKey(et.trap_GetUserinfo(clientId), "cl_guid")
    local player = db.getplayer(guid)

    if player then
        local playerId = player["id"]
        local mute = db.getMuteByPlayer(playerId)

        if mute then
            players.setMuted(clientId, true, mute["type"], mute["issued"], mute["expires"])
        end
    end
end
events.handle("onClientConnect", admin.onconnect)

function players.oninfochange(clientId)
    local clientInfo = et.trap_GetUserinfo(clientId)

    local old = players.getCachedName(clientId)
    local new = et.Info_ValueForKey(clientInfo, "name")

    -- TODO fix for Legacy
    -- prints messages by itself, also when rename is rejected - not desirable
    --[[ if new ~= old then
        if (os.time() - stats.get(clientId, "namechangeStart")) < settings.get("g_renameInterval") and stats.get(clientId, "namechangePts") >= settings.get("g_renameLimit") and not players.isNameForced(clientId) then
            players.setNameForced(clientId, true)

            clientInfo = et.Info_SetValueForKey(clientInfo, "name", old)
            et.trap_SetUserinfo(clientId, clientInfo)
            et.ClientUserinfoChanged(clientId)

            players.setNameForced(clientId, false)

            et.trap_SendServerCommand(clientId, "cp \"Too many name changes in 1 minute.\";")
        else
            if (os.time() - stats.get(clientId, "namechangeStart")) > settings.get("g_renameInterval") then
                stats.set(clientId, "namechangeStart", os.time())
                stats.get(clientId, "namechangePts", 0)
            end

            stats.add(clientId, "namechangePts", 1)

            events.trigger("onClientNameChange", clientId, old, new)
        end
    end ]]
end
events.handle("onClientInfoChange", players.oninfochange)

return admin
