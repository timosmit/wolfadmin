
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

local stats = require "luascripts.wolfadmin.players.stats"

local events = require "luascripts.wolfadmin.util.events"

local players = {}

function players.onconnect(clientId, firstTime, isBot)
    local clientInfo = et.trap_GetUserinfo(clientId)

    -- name is NOT yet set in pers.netname, so get all info out of infostring
    stats.set(clientId, "playerName", et.Info_ValueForKey(clientInfo, "name"))
    stats.set(clientId, "playerGUID", et.Info_ValueForKey(clientInfo, "cl_guid"))
    stats.set(clientId, "playerIP", string.gsub(et.Info_ValueForKey(clientInfo, "ip"), ":%d*", ""))
    stats.set(clientId, "playerTeam", tonumber(et.gentity_get(clientId, "sess.sessionTeam")))
    stats.set(clientId, "isBot", isBot)

    if firstTime == 1 then
        stats.set(clientId, "newConnection", true)

        if db.isconnected() then
            local player = db.getplayer(stats.get(clientId, "playerGUID"))

            if player then
                local guid = stats.get(clientId, "playerGUID")
                local ip = stats.get(clientId, "playerIP")

                db.updateplayer(guid, ip)
            else
                local guid = stats.get(clientId, "playerGUID")
                local ip = stats.get(clientId, "playerIP")

                db.addplayer(guid, ip)
            end

            local name = stats.get(clientId, "playerName")
            local alias = db.getaliasbyname(player["id"], name)

            if alias then
                db.updatealias(alias["id"], os.time())
            else
                db.addalias(playerid, name, os.time())
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

    events.trigger("onPlayerReady", clientId, stats.get(clientId, "newConnection"))

    stats.set(clientId, "newConnection", false)
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

    if db.isconnected() then
        local playerid = db.getplayer(stats.get(clientId, "playerGUID"))["id"]
        local name = stats.get(clientId, "playerName")
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
    local old = stats.get(clientId, "playerTeam")
    local new = tonumber(et.gentity_get(clientId, "sess.sessionTeam"))

    if new ~= old then
        stats.set(clientId, "playerTeam", new)

        events.trigger("onClientTeamChange", clientId, old, new)
    end
end
events.handle("onClientInfoChange", players.oninfochange)

return players
