
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

local constants = require "luascripts.wolfadmin.util.constants"
local util = require "luascripts.wolfadmin.util.util"
local settings = require "luascripts.wolfadmin.util.settings"
local tables = require "luascripts.wolfadmin.util.tables"

local stats = require "luascripts.wolfadmin.players.stats"

local luasql = require "luasql.sqlite3"

local sqlite3 = {}

local env = assert(luasql.sqlite3())
local con = nil
local cur = nil

-- players
function sqlite3.addplayer(guid, ip)
    cur = assert(con:execute("INSERT INTO `player` (`guid`, `ip`) VALUES ('"..util.escape(guid).."', '"..util.escape(ip).."')"))
end

function sqlite3.updateplayer(guid, ip)
    cur = assert(con:execute("UPDATE `player` SET `ip`='"..util.escape(ip).."' WHERE `guid`='"..util.escape(guid).."'"))
end

function sqlite3.getplayerid(clientid)
    return sqlite3.getplayer(stats.get(clientid, "playerGUID"))["id"]
end

function sqlite3.getplayer(guid)
    cur = assert(con:execute("SELECT * FROM `player` WHERE `guid`='"..util.escape(guid).."'"))
    
    local player = cur:fetch({}, "a")
    cur:close()
    
    return player
end

-- aliases
function sqlite3.addalias(playerid, alias, lastused)
    cur = assert(con:execute("INSERT INTO `alias` (`player_id`, `alias`, `cleanalias`, `lastused`, `used`) VALUES ("..tonumber(playerid)..", '"..util.escape(alias).."', '"..util.escape(util.removeColors(alias)).."', "..tonumber(lastused)..", 1)"))
end

function sqlite3.updatecleanalias(aliasid, alias)
    cur = assert(con:execute("UPDATE `alias` SET `cleanalias`='"..util.escape(util.removeColors(alias)).."' WHERE `id`='"..util.escape(aliasid).."'"))
end

function sqlite3.updatealias(aliasid, lastused)
    cur = assert(con:execute("UPDATE `alias` SET `lastused`="..tonumber(lastused)..", `used`=`used`+1 WHERE `id`='"..util.escape(aliasid).."'"))
end

function sqlite3.getaliasescount(playerid)
    cur = assert(con:execute("SELECT COUNT(`id`) AS `count` FROM `alias` WHERE `player_id`="..tonumber(playerid)..""))

    local count = tonumber(cur:fetch({}, "a")["count"])
    cur:close()

    return count
end

function sqlite3.getaliases(playerid, limit, offset)
    limit = limit or 30
    offset = offset or 0

    cur = assert(con:execute("SELECT * FROM `alias` WHERE `player_id`="..tonumber(playerid).." ORDER BY `used` DESC LIMIT "..tonumber(limit).." OFFSET "..tonumber(offset)))

    local aliases = {}
    local row = cur:fetch({}, "a")

    while row do
        table.insert(aliases, tables.copy(row))
        row = cur:fetch(row, "a")
    end

    cur:close()
    
    return aliases
end

function sqlite3.getaliasbyid(aliasid)
    cur = assert(con:execute("SELECT * FROM `alias` WHERE `id`="..tonumber(aliasid)..""))
    
    local alias = cur:fetch({}, "a")
    cur:close()
    
    return alias
end

function sqlite3.getaliasbyname(playerid, aliasname)
    cur = assert(con:execute("SELECT * FROM `alias` WHERE `player_id`="..tonumber(playerid).." AND `alias`='"..util.escape(aliasname).."'"))
    
    local alias = cur:fetch({}, "a")
    cur:close()
    
    return alias
end

function sqlite3.getlastalias(playerid)
    cur = assert(con:execute("SELECT * FROM `alias` WHERE `player_id`="..tonumber(playerid).." ORDER BY `lastused` DESC LIMIT 1"))
    
    local alias = cur:fetch({}, "a")
    cur:close()
    
    return alias
end

-- setlevels
function sqlite3.addsetlevel(playerid, level, adminid, datetime)
    cur = assert(con:execute("INSERT INTO `level` (`player_id`, `level`, `admin_id`, `datetime`) VALUES ("..tonumber(playerid)..", "..tonumber(level)..", "..tonumber(adminid)..", "..tonumber(datetime)..")"))
end

function sqlite3.getlevelscount(playerid)
    cur = assert(con:execute("SELECT COUNT(`id`) AS `count` FROM `level` WHERE `player_id`="..tonumber(playerid)..""))

    local count = tonumber(cur:fetch({}, "a")["count"])
    cur:close()

    return count
end

function sqlite3.getlevels(playerid, limit, offset)
    limit = limit or 30
    offset = offset or 0

    cur = assert(con:execute("SELECT * FROM `level` WHERE `player_id`="..tonumber(playerid).." LIMIT "..tonumber(limit).." OFFSET "..tonumber(offset)))

    local levels = {}
    local row = cur:fetch({}, "a")
    
    while row do
        table.insert(levels, tables.copy(row))
        row = cur:fetch(row, "a")
    end
    
    cur:close()
    
    return levels
end

-- warns
function sqlite3.addwarn(playerid, reason, adminid, datetime)
    cur = assert(con:execute("INSERT INTO `warn` (`player_id`, `reason`, `admin_id`, `datetime`) VALUES ("..tonumber(playerid)..", '"..util.escape(reason).."', "..tonumber(adminid)..", "..tonumber(datetime)..")"))
end

function sqlite3.removewarn(warnid)
    cur = assert(con:execute("DELETE FROM `warn` WHERE `id`="..tonumber(warnid)..""))
end

function sqlite3.getwarnscount(playerid)
    cur = assert(con:execute("SELECT COUNT(`id`) AS `count` FROM `warn` WHERE `player_id`="..tonumber(playerid)..""))

    local count = tonumber(cur:fetch({}, "a")["count"])
    cur:close()

    return count
end

function sqlite3.getwarns(playerid, limit, offset)
    limit = limit or 30
    offset = offset or 0

    cur = assert(con:execute("SELECT * FROM `warn` WHERE `player_id`="..tonumber(playerid).." LIMIT "..tonumber(limit).." OFFSET "..tonumber(offset)))

    local warns = {}
    local row = cur:fetch({}, "a")
    
    while row do
        table.insert(warns, tables.copy(row))
        row = cur:fetch(row, "a")
    end

    cur:close()
    
    return warns
end

function sqlite3.getwarn(warnid)
    cur = assert(con:execute("SELECT * FROM `warn` WHERE `id`="..tonumber(warnid)..""))
    
    local warn = cur:fetch({}, "a")
    cur:close()
    
    return warn
end

-- maps
function sqlite3.addmap(mapname, lastplayed)
    cur = assert(con:execute("INSERT INTO `map` (`name`, `lastplayed`) VALUES ('"..util.escape(mapname).."', "..tonumber(lastplayed)..")"))
end

function sqlite3.updatemap(mapid, lastplayed)
    cur = assert(con:execute("UPDATE `map` SET `lastplayed`="..tonumber(lastplayed).." WHERE `id`="..tonumber(mapid)..""))
end

function sqlite3.getmap(mapname)
    cur = assert(con:execute("SELECT * FROM `map` WHERE `name`='"..util.escape(mapname).."'"))
    
    local map = cur:fetch({}, "a")
    cur:close()
    
    return map
end

-- records
function sqlite3.addrecord(mapid, recorddate, recordtype, record, playerid)
    cur = assert(con:execute("INSERT INTO `record` (`map_id`, `date`, `type`, `record`, `player_id`) VALUES ("..tonumber(mapid)..", "..tonumber(recorddate)..", "..tonumber(recordtype)..", "..tonumber(record)..", "..tonumber(playerid)..")"))
end

function sqlite3.updaterecord(mapid, recorddate, recordtype, record, playerid)
    cur = assert(con:execute("UPDATE `record` SET `date`="..tonumber(recorddate)..", `record`="..tonumber(record)..", `player_id`="..tonumber(playerid).." WHERE `map_id`="..tonumber(mapid).." AND `type`="..tonumber(recordtype)..""))
end

function sqlite3.removeallrecords()
    cur = assert(con:execute("TRUNCATE `record`"))
end

function sqlite3.removerecords(mapid)
    cur = assert(con:execute("DELETE FROM `record` WHERE `map_id`="..tonumber(mapid)..""))
end

function sqlite3.getrecords(mapid)
    cur = assert(con:execute("SELECT * FROM `record` WHERE `map_id`="..tonumber(mapid)..""))

    local records = {}
    local row = cur:fetch({}, "a")

    while row do
        local typestr = ""

        if tonumber(row["type"]) == constants.RECORD_KILL then
            typestr = "ks"
        elseif tonumber(row["type"]) == constants.RECORD_DEATH then
            typestr = "ds"
        elseif tonumber(row["type"]) == constants.RECORD_REVIVE then
            typestr = "rs"
        end

        records[typestr.."player"] = tonumber(row["player_id"])
        records[typestr.."record"] = tonumber(row["record"])

        row = cur:fetch({}, "a")
    end
    
    cur:close()
    
    return records
end

function sqlite3.getrecordscount(mapid)
    cur = assert(con:execute("SELECT COUNT(*) AS `count` FROM `record` WHERE `map_id`="..tonumber(mapid)..""))
    
    local count = cur:fetch({}, "a")
    cur:close()
    
    return count["count"]
end

function sqlite3.getrecord(mapid, recordtype)
    cur = assert(con:execute("SELECT * FROM `record` WHERE `map_id`="..tonumber(mapid).." AND `type`="..tonumber(recordtype)..""))
    
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

function sqlite3.isconnected()
    return (con ~= nil)
end

function sqlite3.start()
    con = env:connect(wolfa_getHomePath()..settings.get("db_file"))

    if not con then
        return
    end

    -- enable foreign key enforcement
    cur = assert(con:execute("PRAGMA foreign_keys=1"))
    cur = assert(con:execute("PRAGMA synchronous=0"))
end

function sqlite3.close(doSave)
end

return sqlite3