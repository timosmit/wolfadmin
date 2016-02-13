
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
local settings = require "luascripts.wolfadmin.util.settings"

local stats = require "luascripts.wolfadmin.players.stats"

require "luasql.mysql"

local mysql = {}

local env = assert(luasql.mysql())
local con = nil
local cur = nil

function mysql.addmap(mapname, lastplayed)
    cur = assert(con:execute("INSERT INTO `maps` (`name`, `lastplayed`) VALUES ('"..util.escape(mapname).."', "..tonumber(lastplayed)..")"))
end

function mysql.updatemap(mapid, lastplayed)
    cur = assert(con:execute("UPDATE `maps` SET `lastplayed`="..tonumber(lastplayed).." WHERE `id`="..tonumber(mapid)..""))
end

function mysql.getmap(mapname)
    cur = assert(con:execute("SELECT * FROM `maps` WHERE `name`='"..util.escape(mapname).."'"))
    
    local map = cur:fetch({}, "a")
    cur:close()
    
    return map
end

function mysql.addrecord(mapid, recorddate, recordtype, record, playerid)
    cur = assert(con:execute("INSERT INTO `records` (`mapid`, `date`, `type`, `record`, `player`) VALUES ("..tonumber(mapid)..", "..tonumber(recorddate)..", "..tonumber(recordtype)..", "..tonumber(record)..", "..tonumber(playerid)..")"))
end

function mysql.updaterecord(mapid, recorddate, recordtype, record, playerid)
    cur = assert(con:execute("UPDATE `records` SET `date`="..tonumber(recorddate)..", `record`="..tonumber(record)..", `player`="..tonumber(playerid).." WHERE `mapid`="..tonumber(mapid).." AND `type`="..tonumber(recordtype)..""))
end

function mysql.removerecords(mapid)
    cur = assert(con:execute("DELETE FROM `records` WHERE `mapid`="..tonumber(mapid)..""))
end

function mysql.getrecords(mapid)
    cur = assert(con:execute("SELECT * FROM `records` WHERE `mapid`="..tonumber(mapid)..""))
    local numrows = cur:numrows()
    local records = {}
    
    for i = 1, numrows do
        local record = cur:fetch({}, "a")
        local typestr = ""
        
        if tonumber(record["type"]) == constants.RECORD_KILL then
            typestr = "ks"
        elseif tonumber(record["type"]) == constants.RECORD_DEATH then
            typestr = "ds"
        elseif tonumber(record["type"]) == constants.RECORD_REVIVE then
            typestr = "rs"
        end
        
        records[typestr.."player"] = tonumber(record["player"])
        records[typestr.."record"] = tonumber(record["record"])
    end
    
    cur:close()
    
    return records
end

function mysql.getrecordscount(mapid)
    cur = assert(con:execute("SELECT COUNT(*) AS `count` FROM `records` WHERE `mapid`="..tonumber(mapid)..""))
    
    local count = cur:fetch({}, "a")
    cur:close()
    
    return count["count"]
end

function mysql.getrecord(mapid, recordtype)
    cur = assert(con:execute("SELECT * FROM `records` WHERE `mapid`="..tonumber(mapid).." AND `type`="..tonumber(recordtype)..""))
    
    local row = cur:fetch({}, "a")
    cur:close()
    
    if row then
        local record, typestr = {}, ""
        
        if tonumber(row["type"]) == constants.RECORD_KILL then
            typestr = "ks"
        elseif tonumber(row["type"]) == constants.RECORD_DEATH then
            typestr = "ds"
        elseif tonumber(row["type"]) == constants.RECORD_REVIVE then
            typestr = "rs"
        end
        
        record[typestr.."player"] = tonumber(row["player"])
        record[typestr.."record"] = tonumber(row["record"])
        
        return record
    end
end

function mysql.addplayer(guid, ip)
    cur = assert(con:execute("INSERT INTO `players` (`guid`, `ip`) VALUES ('"..util.escape(guid).."', '"..util.escape(ip).."')"))
end

function mysql.updateplayer(guid, ip)
    cur = assert(con:execute("UPDATE `players` SET `ip`='"..util.escape(ip).."' WHERE `guid`='"..util.escape(guid).."'"))
end

function mysql.getplayerid(clientid)
    return mysql.getplayer(stats.get(clientid, "playerGUID"))["id"]
end

function mysql.isplayerbot(clientid)
    return mysql.getplayer(stats.get(clientid, "playerGUID"))["bot"] == 1
end

function mysql.getplayer(guid)
    cur = assert(con:execute("SELECT * FROM `players` WHERE `guid`='"..util.escape(guid).."'"))
    
    local player = cur:fetch({}, "a")
    cur:close()
    
    return player
end

function mysql.addalias(playerid, alias, lastused)
    cur = assert(con:execute("INSERT INTO `aliases` (`player`, `alias`, `cleanalias`, `lastused`, `used`) VALUES ("..tonumber(playerid)..", '"..util.escape(alias).."', '"..util.escape(util.removeColors(alias)).."', "..tonumber(lastused)..", 1)"))
end

function mysql.updatecleanalias(aliasid, alias)
    cur = assert(con:execute("UPDATE `aliases` SET `cleanalias`='"..util.escape(util.removeColors(alias)).."' WHERE `id`='"..util.escape(aliasid).."'"))
end

function mysql.updatealias(aliasid, lastused)
    cur = assert(con:execute("UPDATE `aliases` SET `lastused`="..tonumber(lastused)..", `used`=`used`+1 WHERE `id`='"..util.escape(aliasid).."'"))
end

function mysql.getaliases(playerid)
    cur = assert(con:execute("SELECT * FROM `aliases` WHERE `player`="..tonumber(playerid).." ORDER BY `used` DESC"))
    local numrows = cur:numrows()
    local aliases = {}
    
    for i = 1, numrows do
        aliases[i] = cur:fetch({}, "a")
    end
    
    cur:close()
    
    return aliases
end

function mysql.getaliasbyid(aliasid)
    cur = assert(con:execute("SELECT * FROM `aliases` WHERE `id`="..tonumber(aliasid)..""))
    
    local alias = cur:fetch({}, "a")
    cur:close()
    
    return alias
end

function mysql.getaliasbyname(playerid, aliasname)
    cur = assert(con:execute("SELECT * FROM `aliases` WHERE `player`="..tonumber(playerid).." AND `alias`='"..util.escape(aliasname).."'"))
    
    local alias = cur:fetch({}, "a")
    cur:close()
    
    return alias
end

function mysql.getlastalias(playerid)
    cur = assert(con:execute("SELECT * FROM `aliases` WHERE `player`="..tonumber(playerid).." ORDER BY `lastused` DESC LIMIT 1"))
    
    local alias = cur:fetch({}, "a")
    cur:close()
    
    return alias
end

function mysql.addsetlevel(playerid, level, adminid, datetime)
    cur = assert(con:execute("INSERT INTO `levels` (`player`, `level`, `admin`, `datetime`) VALUES ("..tonumber(playerid)..", "..tonumber(level)..", "..tonumber(adminid)..", "..tonumber(datetime)..")"))
end

function mysql.getlevels(playerid)
    cur = assert(con:execute("SELECT * FROM `levels` WHERE `player`="..tonumber(playerid)..""))
    local numrows = cur:numrows()
    local levels = {}
    
    for i = 1, numrows do
        levels[i] = cur:fetch({}, "a")
    end
    
    cur:close()
    
    return levels
end

function mysql.addwarn(playerid, reason, adminid, datetime)
    cur = assert(con:execute("INSERT INTO `warns` (`player`, `reason`, `admin`, `datetime`) VALUES ("..tonumber(playerid)..", '"..util.escape(reason).."', "..tonumber(adminid)..", "..tonumber(datetime)..")"))
end

function mysql.removewarn(warnid)
    cur = assert(con:execute("DELETE FROM `warns` WHERE `id`="..tonumber(warnid)..""))
end

function mysql.getwarns(playerid)
    cur = assert(con:execute("SELECT * FROM `warns` WHERE `player`="..tonumber(playerid)..""))
    local numrows = cur:numrows()
    local warns = {}
    
    for i = 1, numrows do
        warns[i] = cur:fetch({}, "a")
    end
    
    cur:close()
    
    return warns
end

function mysql.getwarn(warnid)
    cur = assert(con:execute("SELECT * FROM `warns` WHERE `id`="..tonumber(warnid)..""))
    
    local warn = cur:fetch({}, "a")
    cur:close()
    
    return warn
end

function mysql.isconnected()
    return (con ~= nil)
end

function mysql.start()
    con = assert(env:connect(settings.get("db_database"), settings.get("db_username"), settings.get("db_password"), settings.get("db_hostname"), settings.get("db_port")))
end

function mysql.close(doSave)
end

return mysql