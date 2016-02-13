
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015 Timo 'Timothy' Smit

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

local events = require "luascripts.wolfadmin.util.events"
local settings = require "luascripts.wolfadmin.util.settings"
local files = require "luascripts.wolfadmin.util.files"
local db = require "luascripts.wolfadmin.db.db"
local stats = require "luascripts.wolfadmin.players.stats"

local admin = {}

function admin.isVoiceMuted(clientId)
    if stats.get(clientId, "voiceMute") then
        if stats.get(clientId, "voiceMute") - os.time() > 0 then
            return true
        else
            admin.unmuteVoice(clientId)
        end
    end
    
    return false
end

function admin.isPlayerLocked(clientId)
    if stats.get(clientId, "playerLock") then
        return true
    end
    
    return false
end

function admin.muteVoice(clientId, length)
    stats.set(clientId, "voiceMute", length)
end

function admin.unmuteVoice(clientId)
    stats.set(clientId, "voiceMute", false)
end

function admin.lockTeam(clientId, team)
    stats.set(clientId, "voiceMute", length)
end

function admin.unlockTeam(clientId)
    stats.set(clientId, "voiceMute", length)
end

function admin.updatePlayer(clientId)
    local player = db.getplayer(stats.get(clientId, "playerGUID"))
    
    if player then
        local guid = stats.get(clientId, "playerGUID")
        local ip = stats.get(clientId, "playerIP")
        
        db.updateplayer(guid, ip)
    else
        local guid = stats.get(clientId, "playerGUID")
        local ip = stats.get(clientId, "playerIP")
        
        db.addplayer(guid, ip)
        admin.setPlayerLevel(clientId, et.G_shrubbot_level(clientId), 1)
    end
end

function admin.updateAlias(clientId)
    local playerid = db.getplayer(stats.get(clientId, "playerGUID"))["id"]
    local name = stats.get(clientId, "playerName")
    local alias = db.getaliasbyname(playerid, name)
    
    if alias then
        db.updatealias(alias["id"], os.time())
        if alias["cleanalias"] == "" then
            db.updatecleanalias(alias["id"], name)
        end
    else
        db.addalias(playerid, name, os.time())
    end
end

function admin.setPlayerLevel(clientId, level, adminId)
    local playerid = db.getplayer(stats.get(clientId, "playerGUID"))["id"]
    local adminid = db.getplayer(stats.get(adminId, "playerGUID"))["id"]
    
    db.addsetlevel(playerid, level, adminid, os.time())
end

function admin.onconnect(clientId, firstTime, isBot)
    -- only increase the counter on first connection (fixes counter increase on 
    -- clientbegin which is also triggered on warmup/maprestart/etc)
    stats.set(clientId, "namechangeStart", os.time())
    stats.set(clientId, "namechangePts", 0)
    
    if firstTime then
        if stats.get(clientId, "playerGUID") == "NO_GUID" or stats.get(clientId, "playerGUID") == "unknown" then
            return "\n\nIt appears you do not have a ^7GUID^9/^7etkey^9. In order to play on this server, enable ^7PunkBuster ^9(use ^7\pb_cl_enable^9) ^9and/or create an ^7etkey^9.\n\nMore info: ^7www.etkey.org"
        end
        
        if settings.get("db_type") ~= "cfg" then
            admin.updatePlayer(clientId)
            admin.updateAlias(clientId)
        end
    end
end
events.handle("onClientConnect", admin.onconnect)

function stats.oninfochange(clientId)
    local clientInfo = et.trap_GetUserinfo(clientId)
    local old = stats.get(clientId, "playerName")
    local new = et.Info_ValueForKey(clientInfo, "name")
    
    if new ~= old then
        if (os.time() - stats.get(clientId, "namechangeStart")) < settings.get("g_renameInterval") and stats.get(clientId, "namechangePts") >= settings.get("g_renameLimit") and not stats.get(clientId, "namechangeForce") then
            stats.set(clientId, "namechangeForce", true)
            
            clientInfo = et.Info_SetValueForKey(clientInfo, "name", old)
            et.trap_SetUserinfo(clientId, clientInfo)
            et.ClientUserinfoChanged(clientId)
            
            stats.set(clientId, "namechangeForce", false)
            
            et.trap_SendServerCommand(clientId, "cp \"Too many name changes in 1 minute.\";")
        else
            stats.set(clientId, "playerName", new)
            
            if (os.time() - stats.get(clientId, "namechangeStart")) > settings.get("g_renameInterval") then
                stats.set(clientId, "namechangeStart", os.time())
                stats.get(clientId, "namechangePts", 0)
            end
            
            stats.add(clientId, "namechangePts", 1)
            
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay -1 \""..old.." ^7is now known as "..new.."\";")
            
            if settings.get("db_type") ~= "cfg" then
                admin.updateAlias(clientId)
            end
            
            events.trigger("onClientNameChange", clientId, old, new)
        end
    end
end
events.handle("onClientInfoChange", stats.oninfochange)

return admin