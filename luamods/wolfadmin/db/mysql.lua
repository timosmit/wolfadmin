
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

local players = require (wolfa_getLuaPath()..".players.players")

local constants = require (wolfa_getLuaPath()..".util.constants")
local util = require (wolfa_getLuaPath()..".util.util")
local settings = require (wolfa_getLuaPath()..".util.settings")
local tables = require (wolfa_getLuaPath()..".util.tables")

local luasql = require "luasql.mysql"

local mysql = {}

local env = assert(luasql.mysql())
local con = nil
local cur = nil

-- players
function mysql.addplayer(guid, ip)
    cur = assert(con:execute("INSERT INTO `player` (`guid`, `ip`) VALUES ('"..util.escape(guid).."', '"..util.escape(ip).."')"))
end

function mysql.updateplayerip(guid, ip)
    cur = assert(con:execute("UPDATE `player` SET `ip`='"..util.escape(ip).."' WHERE `guid`='"..util.escape(guid).."'"))
end

function mysql.updateplayerlevel(id, level)
    cur = assert(con:execute("UPDATE `player` SET `level_id`='"..tonumber(level).."' WHERE `id`='"..tonumber(id).."'"))
end

function mysql.getplayerid(clientId)
    return mysql.getplayer(players.getGUID(clientId))["id"]
end

function mysql.getplayer(guid)
    cur = assert(con:execute("SELECT * FROM `player` WHERE `guid`='"..util.escape(guid).."'"))
    
    local player = cur:fetch({}, "a")
    cur:close()
    
    return player
end

-- levels
function mysql.addlevel(id, name)
    cur = assert(con:execute("INSERT INTO `level` (`id`, `name`) VALUES ('"..tonumber(id).."', '"..util.escape(name).."')"))
end

function mysql.updatelevel(id, name)
    cur = assert(con:execute("UPDATE `level` SET `name`='"..util.escape(name).."' WHERE `id`='"..tonumber(id).."'"))
end

function mysql.getlevel(id)
    cur = assert(con:execute("SELECT * FROM `level` WHERE `id`='"..tonumber(id).."'"))
    
    local level = cur:fetch({}, "a")
    cur:close()
    
    return level
end

-- aliases
function mysql.addalias(playerid, alias, lastused)
    cur = assert(con:execute("INSERT INTO `alias` (`player_id`, `alias`, `cleanalias`, `lastused`, `used`) VALUES ("..tonumber(playerid)..", '"..util.escape(alias).."', '"..util.escape(util.removeColors(alias)).."', "..tonumber(lastused)..", 1)"))
end

function mysql.updatealias(aliasid, lastused)
    cur = assert(con:execute("UPDATE `alias` SET `lastused`="..tonumber(lastused)..", `used`=`used`+1 WHERE `id`='"..util.escape(aliasid).."'"))
end

function mysql.getaliasescount(playerid)
    cur = assert(con:execute("SELECT COUNT(`id`) AS `count` FROM `alias` WHERE `player_id`="..tonumber(playerid)..""))

    local count = tonumber(cur:fetch({}, "a")["count"])
    cur:close()

    return count
end

function mysql.getaliases(playerid, limit, offset)
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

function mysql.getaliasbyid(aliasid)
    cur = assert(con:execute("SELECT * FROM `alias` WHERE `id`="..tonumber(aliasid)..""))
    
    local alias = cur:fetch({}, "a")
    cur:close()
    
    return alias
end

function mysql.getaliasbyname(playerid, aliasname)
    cur = assert(con:execute("SELECT * FROM `alias` WHERE `player_id`="..tonumber(playerid).." AND `alias`='"..util.escape(aliasname).."'"))
    
    local alias = cur:fetch({}, "a")
    cur:close()
    
    return alias
end

function mysql.getlastalias(playerid)
    cur = assert(con:execute("SELECT * FROM `alias` WHERE `player_id`="..tonumber(playerid).." ORDER BY `lastused` DESC LIMIT 1"))
    
    local alias = cur:fetch({}, "a")
    cur:close()
    
    return alias
end

-- level history
function mysql.addsetlevel(playerid, level, adminid, datetime)
    cur = assert(con:execute("INSERT INTO `player_level` (`player_id`, `level`, `admin_id`, `datetime`) VALUES ("..tonumber(playerid)..", "..tonumber(level)..", "..tonumber(adminid)..", "..tonumber(datetime)..")"))
end

function mysql.getlevelscount(playerid)
    cur = assert(con:execute("SELECT COUNT(`id`) AS `count` FROM `player_level` WHERE `player_id`="..tonumber(playerid)..""))

    local count = tonumber(cur:fetch({}, "a")["count"])
    cur:close()

    return count
end

function mysql.getlevels(playerid, limit, offset)
    limit = limit or 30
    offset = offset or 0

    cur = assert(con:execute("SELECT * FROM `player_level` WHERE `player_id`="..tonumber(playerid).." LIMIT "..tonumber(limit).." OFFSET "..tonumber(offset)))

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
function mysql.addwarn(playerid, reason, adminid, datetime)
    cur = assert(con:execute("INSERT INTO `warn` (`player_id`, `reason`, `admin_id`, `datetime`) VALUES ("..tonumber(playerid)..", '"..util.escape(reason).."', "..tonumber(adminid)..", "..tonumber(datetime)..")"))
end

function mysql.removewarn(warnid)
    cur = assert(con:execute("DELETE FROM `warn` WHERE `id`="..tonumber(warnid)..""))
end

function mysql.getwarnscount(playerid)
    cur = assert(con:execute("SELECT COUNT(`id`) AS `count` FROM `warn` WHERE `player_id`="..tonumber(playerid)..""))

    local count = tonumber(cur:fetch({}, "a")["count"])
    cur:close()

    return count
end

function mysql.getwarns(playerid, limit, offset)
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

function mysql.getwarn(warnid)
    cur = assert(con:execute("SELECT * FROM `warn` WHERE `id`="..tonumber(warnid)..""))
    
    local warn = cur:fetch({}, "a")
    cur:close()
    
    return warn
end

-- maps
function mysql.addmap(mapname, lastplayed)
    cur = assert(con:execute("INSERT INTO `map` (`name`, `lastplayed`) VALUES ('"..util.escape(mapname).."', "..tonumber(lastplayed)..")"))
end

function mysql.updatemap(mapid, lastplayed)
    cur = assert(con:execute("UPDATE `map` SET `lastplayed`="..tonumber(lastplayed).." WHERE `id`="..tonumber(mapid)..""))
end

function mysql.getmap(mapname)
    cur = assert(con:execute("SELECT * FROM `map` WHERE `name`='"..util.escape(mapname).."'"))
    
    local map = cur:fetch({}, "a")
    cur:close()
    
    return map
end

-- records
function mysql.addrecord(mapid, recorddate, recordtype, record, playerid)
    cur = assert(con:execute("INSERT INTO `record` (`map_id`, `date`, `type`, `record`, `player_id`) VALUES ("..tonumber(mapid)..", "..tonumber(recorddate)..", "..tonumber(recordtype)..", "..tonumber(record)..", "..tonumber(playerid)..")"))
end

function mysql.updaterecord(mapid, recorddate, recordtype, record, playerid)
    cur = assert(con:execute("UPDATE `record` SET `date`="..tonumber(recorddate)..", `record`="..tonumber(record)..", `player_id`="..tonumber(playerid).." WHERE `map_id`="..tonumber(mapid).." AND `type`="..tonumber(recordtype)..""))
end

function mysql.removeallrecords()
    cur = assert(con:execute("TRUNCATE `record`"))
end

function mysql.removerecords(mapid)
    cur = assert(con:execute("DELETE FROM `record` WHERE `map_id`="..tonumber(mapid)..""))
end

function mysql.getrecords(mapid)
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

function mysql.getrecordscount(mapid)
    cur = assert(con:execute("SELECT COUNT(*) AS `count` FROM `record` WHERE `map_id`="..tonumber(mapid)..""))
    
    local count = cur:fetch({}, "a")
    cur:close()
    
    return count["count"]
end

function mysql.getrecord(mapid, recordtype)
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

function mysql.isconnected()
    return (con ~= nil)
end

function mysql.start()
    con = env:connect(settings.get("db_database"), settings.get("db_username"), settings.get("db_password"), settings.get("db_hostname"), settings.get("db_port"))

    if not con then
        return
    end
end

function mysql.close(doSave)
end

return mysql
