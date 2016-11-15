
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

local bits = require "luascripts.wolfadmin.util.bits"
local events = require "luascripts.wolfadmin.util.events"

local players = {}

players.MUTE_CHAT = 1
players.MUTE_VOICE = 2

local data = {}

function players.isConnected(clientId)
    return (data[clientId] ~= nil)
end

function players.getCachedName(clientId)
    return data[clientId]["name"]
end

function players.getName(clientId)
    return et.gentity_get(clientId, "pers.netname")
end

function players.getGUID(clientId)
    return data[clientId]["guid"]
end

function players.getIP(clientId)
    return data[clientId]["ip"]
end

function players.isBot(clientId)
    return data[clientId]["bot"]
end

function players.setLastPMSender(clientId, senderId)
    data[clientId]["lastpmsender"] = senderId
end

function players.getLastPMSender(clientId)
    return data[clientId]["lastpmsender"]
end

function players.setNameForced(clientId, state)
    data[clientId]["nameforced"] = state
end

function players.isNameForced(clientId)
    return data[clientId]["nameforced"]
end

function players.setMuted(clientId, state, type, issued, expires)
    data[clientId]["mute"] = nil

    if state == true then
        data[clientId]["mute"] = {
            ["type"] = type,
            ["issued"] = issued,
            ["expires"] = expires
        }
    end
end

function players.isMuted(clientId, type)
    if type == nil then
        return data[clientId]["mute"] ~= nil
    elseif type == players.MUTE_CHAT then
        return data[clientId]["mute"] ~= nil and bits.hasbit(data[clientId]["mute"]["type"], players.MUTE_CHAT)
    elseif type == players.MUTE_VOICE then
        return data[clientId]["mute"] ~= nil and bits.hasbit(data[clientId]["mute"]["type"], players.MUTE_VOICE)
    end

    return false
end

function players.getMuteType(clientId)
    return data[clientId]["mute"]["type"]
end

function players.getMuteIssuedAt(clientId)
    return data[clientId]["mute"]["issued"]
end

function players.getMuteExpiresAt(clientId)
    return data[clientId]["mute"]["expires"]
end

function players.setTeamLocked(clientId, state)
    data[clientId]["teamlock"] = state
end

function players.isTeamLocked(clientId)
    return data[clientId]["teamlock"]
end

function players.onconnect(clientId, firstTime, isBot)
    local clientInfo = et.trap_GetUserinfo(clientId)

    -- name is NOT yet set in pers.netname, so get all info out of infostring
    data[clientId] = {}

    -- data[clientId]["name"] is cached version for detecting namechanges, do not
    -- use it to retrieve a player's name
    data[clientId]["name"] = et.Info_ValueForKey(clientInfo, "name")
    data[clientId]["guid"] = et.Info_ValueForKey(clientInfo, "cl_guid")
    data[clientId]["ip"] = string.gsub(et.Info_ValueForKey(clientInfo, "ip"), ":%d*", "")
    data[clientId]["bot"] = isBot
    data[clientId]["team"] = tonumber(et.gentity_get(clientId, "sess.sessionTeam"))

    if firstTime then
        data[clientId]["new"] = true

        if db.isconnected() then
            local player = db.getplayer(data[clientId]["guid"])

            if player then
                db.updateplayerip(data[clientId]["guid"], data[clientId]["ip"])

                local alias = db.getaliasbyname(player["id"], data[clientId]["name"])

                if alias then
                    db.updatealias(alias["id"], os.time())
                else
                    db.addalias(playerid, name, os.time())
                end
            else
                db.addplayer(data[clientId]["guid"], data[clientId]["ip"])

                local player = db.getplayer(data[clientId]["guid"])
                db.addalias(player["id"], name, os.time())
            end
        end
    end
end
events.handle("onClientConnect", players.onconnect)

function players.onbegin(clientId)
    -- TODO:
    -- new approach: load necessary data in onClientConnect event handlers,
    -- load rest in onClientBegin handlers (avoids useless loading of stats, 
    -- less coupling between main.lua and stats.lua)
    -- ensures that all data is loaded from this moment on

    events.trigger("onPlayerReady", clientId, data[clientId]["new"])

    data[clientId]["new"] = false
end
events.handle("onClientBegin", players.onbegin)

function players.ondisconnect(clientId)
    stats.remove(clientId)
end
events.handle("onClientDisconnect", players.ondisconnect)

function players.onnamechange(clientId, old, new)
    -- TODO: on some mods, this message is already printed
    -- known: old NQ versions, Legacy
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay -1 \""..old.." ^7is now known as "..new.."\";")

    data[clientId]["name"] = new

    if db.isconnected() then
        local playerid = db.getplayer(players.getGUID(clientId))["id"]
        local name = players.getName(clientId)
        local alias = db.getaliasbyname(playerid, name)

        if alias then
            db.updatealias(alias["id"], os.time())
        else
            db.addalias(playerid, name, os.time())
        end
    end
end
events.handle("onClientNameChange", players.onnamechange)

function players.oninfochange(clientId)
    local clientInfo = et.trap_GetUserinfo(clientId)
    local old = data[clientId]["team"]
    local new = tonumber(et.gentity_get(clientId, "sess.sessionTeam"))

    if new ~= old then
        data[clientId]["team"] = new

        events.trigger("onClientTeamChange", clientId, old, new)
    end
end
events.handle("onClientInfoChange", players.oninfochange)

return players
