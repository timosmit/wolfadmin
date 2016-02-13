
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

local constants = require "luascripts.wolfadmin.util.constants"
local util = require "luascripts.wolfadmin.util.util"
local events = require "luascripts.wolfadmin.util.events"
local files = require "luascripts.wolfadmin.util.files"
local settings = require "luascripts.wolfadmin.util.settings"

local stats = require "luascripts.wolfadmin.players.stats"

local cfg = {}

local maps = {}
local records = {}

function cfg.addmap(mapname, lastplayed)
    table.insert(records, {
        ["map"] = mapname,
    })
end

function cfg.updatemap(mapid, lastplayed)
end

function cfg.getmap(mapname)
    for id, record in ipairs(records) do
        if record["map"] == mapname then
            return {["id"] = id}
        end
    end
end

function cfg.addrecord(mapid, recorddate, recordtype, record, playerid)
    cfg.updaterecord(mapid, recorddate, recordtype, record, playerid)
end

function cfg.updaterecord(mapid, recorddate, recordtype, record, playerid)
    local typestr = ""
    if recordtype == constants.RECORD_KILL then
        typestr = "ks"
    elseif recordtype == constants.RECORD_DEATH then
        typestr = "ds"
    elseif recordtype == constants.RECORD_REVIVE then
        typestr = "rs"
    end
    
    records[mapid][typestr.."record"] = record
    records[mapid][typestr.."name"] = playerid
end

function cfg.removeallrecords()
    records = {}
end

function cfg.removerecords(mapid)
    records[mapid] = {
        ["map"] = records[mapid]["map"],
    }
end

function cfg.getrecords(mapid)
    return records[mapid]
end

function cfg.getrecordscount(mapid)
    return #records
end

function cfg.getrecord(mapid, recordtype)
    local row = records[mapid]
    
    if row then
        local record, typestr = {}, ""
        
        if recordtype == constants.RECORD_KILL then
            typestr = "ks"
        elseif recordtype == constants.RECORD_DEATH then
            typestr = "ds"
        elseif recordtype == constants.RECORD_REVIVE then
            typestr = "rs"
        end
        
        if not record[typestr.."player"] then return end
        
        record[typestr.."player"] = tonumber(row["player"])
        record[typestr.."record"] = tonumber(row["record"])
        
        return record
    end
end

function cfg.addplayer(guid, ip)
end

function cfg.updateplayer(guid, ip)
end

function cfg.getplayerid(clientid)
    if type(clientid) == "number" then
        return stats.get(clientid, "playerName")
    end
    
    return clientid
end

function cfg.isplayerbot(clientid)
    return string.match(stats.get(clientid, "playerGUID"), 'OMNIBOT%d%d%d+')
end

function cfg.getplayer(guid)
end

function cfg.addalias(playerid, alias, lastused)
end

function cfg.updatealias(aliasid, lastused)
end

function cfg.getaliases(playerid)
end

function cfg.getaliasbyid(aliasid)
end

function cfg.getaliasbyname(playerid, aliasname)
end

function cfg.getlastalias(playerid)
    return {["alias"] = playerid}
end

function cfg.addsetlevel(playerid, level, adminid, datetime)
end

function cfg.getlevels(playerid)
end

function cfg.addwarn(playerid, reason, adminid, datetime)
end

function cfg.removewarn(warnid)
end

function cfg.getwarns(playerid)
end

function cfg.getwarn(warnid)
end

function cfg.isconnected()
end

function cfg.start()
    local fileName = settings.get("g_fileSprees")
    
    if fileName == "" then
        return
    end
    
    local amount, array = files.loadCFG(fileName, "record", true)
    records = array["record"] or {}
    
    for id, record in ipairs(records) do
        record["ksrecord"] = tonumber(record["ksrecord"])
        record["dsrecord"] = tonumber(record["dsrecord"])
        record["rsrecord"] = tonumber(record["rsrecord"])
    end
end

function cfg.close(doSave)
    -- in case of a map restart for example
    if not doSave then return end
    
    local fileName = settings.get("g_fileSprees")
    
    if fileName == "" then
        return true
    end
    
    local array = {["record"] = {}}
    
    -- add back the indices we removed
    for _, record in ipairs(records) do
        table.insert(array["record"], record)
    end
    
    files.save(fileName, array)
end

return cfg