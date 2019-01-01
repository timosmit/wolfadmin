
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2018 Timo 'Timothy' Smit

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

local luasql = require "luasql.sqlite3"

local sqlite3 = {}

local env = assert(luasql.sqlite3())
local con
local cur

-- config
function sqlite3.isSchemaExistent()
    cur = assert(con:execute("SELECT `name` FROM `sqlite_master` WHERE type='table' AND name='config'"))

    local tbl = cur:fetch({}, "a")
    cur:close()

    return tbl and true or false
end

-- players
function sqlite3.addPlayer(guid, ip, lastSeen, seen)
    cur = assert(con:execute("INSERT INTO `player` (`guid`, `ip`, `level_id`, `lastseen`, `seen`) VALUES ('"..util.escape(guid).."', '"..util.escape(ip).."', 0, "..tonumber(lastSeen)..", "..tonumber(seen)..")"))
end

function sqlite3.updatePlayer(guid, ip, lastSeen)
    cur = assert(con:execute("UPDATE `player` SET `ip`='"..util.escape(ip).."', `lastseen`="..lastSeen..", `seen`=`seen`+1 WHERE `guid`='"..util.escape(guid).."'"))
end

function sqlite3.updatePlayerLevel(id, level)
    cur = assert(con:execute("UPDATE `player` SET `level_id`='"..tonumber(level).."' WHERE `id`='"..tonumber(id).."'"))
end

function sqlite3.getPlayerId(clientId)
    return sqlite3.getPlayer(players.getGUID(clientId))["id"]
end

function sqlite3.getPlayersCount()
    cur = assert(con:execute("SELECT COUNT(`id`) AS `count` FROM `player`"))

    local count = tonumber(cur:fetch({}, "a")["count"])
    cur:close()

    return count
end

function sqlite3.getPlayers(limit, offset)
    limit = limit or 30
    offset = offset or 0

    cur = assert(con:execute("SELECT * FROM `player` LIMIT "..tonumber(limit).." OFFSET "..tonumber(offset)))

    local players = {}
    local row = cur:fetch({}, "a")

    while row do
        table.insert(players, tables.copy(row))
        row = cur:fetch(row, "a")
    end

    cur:close()

    return players
end

function sqlite3.getPlayer(guid)
    cur = assert(con:execute("SELECT * FROM `player` WHERE `guid`='"..util.escape(guid).."'"))
    
    local player = cur:fetch({}, "a")
    cur:close()
    
    return player
end

-- levels
function sqlite3.addLevel(id, name)
    cur = assert(con:execute("INSERT INTO `level` (`id`, `name`) VALUES ('"..tonumber(id).."', '"..util.escape(name).."')"))
end

function sqlite3.updateLevel(id, name)
    cur = assert(con:execute("UPDATE `level` SET `name`='"..util.escape(name).."' WHERE `id`='"..tonumber(id).."'"))
end

function sqlite3.removeLevel(id)
    cur = assert(con:execute("DELETE FROM `level` WHERE `id`="..tonumber(id)..""))
end

function sqlite3.reLevel(id, newId)
    cur = assert(con:execute("UPDATE `player` SET `level_id`="..tonumber(newId).." WHERE `level_id`="..tonumber(id)..""))
end

function sqlite3.getLevelsWithIds()
    cur = assert(con:execute("SELECT * FROM `level`"))

    local levels = {}
    local row = cur:fetch({}, "a")

    while row do
        table.insert(levels, tables.copy(row))
        row = cur:fetch(row, "a")
    end

    cur:close()

    return levels
end

function sqlite3.getLevels()
    cur = assert(con:execute("SELECT `l`.*, COUNT(`p`.`id`) AS `players` FROM `level` AS `l` LEFT JOIN `player` AS `p` ON `l`.`id`=`p`.`level_id` GROUP BY `l`.`id`"))

    local levels = {}
    local row = cur:fetch({}, "a")

    while row do
        table.insert(levels, tables.copy(row))
        row = cur:fetch(row, "a")
    end

    cur:close()

    return levels
end

function sqlite3.getLevel(id)
    cur = assert(con:execute("SELECT * FROM `level` WHERE `id`='"..tonumber(id).."'"))
    
    local level = cur:fetch({}, "a")
    cur:close()
    
    return level
end

-- acl
function sqlite3.getLevelPermissions()
    cur = assert(con:execute("SELECT * FROM `level_permission`"))

    local permissions = {}
    local row = cur:fetch({}, "a")

    while row do
        table.insert(permissions, tables.copy(row))
        row = cur:fetch(row, "a")
    end

    cur:close()

    return permissions
end

function sqlite3.addLevelPermission(levelId, permission)
    cur = assert(con:execute("INSERT INTO `level_permission` (`level_id`, `permission`) VALUES ("..tonumber(levelId)..", '"..util.escape(permission).."')"))
end

function sqlite3.removeLevelPermission(levelId, permission)
    cur = assert(con:execute("DELETE FROM `level_permission` WHERE `level_id`="..tonumber(levelId).." AND permission='"..util.escape(permission).."'"))
end

function sqlite3.copyLevelPermissions(levelId, newLevelId)
    cur = assert(con:execute("INSERT INTO `level_permission` (`level_id`, `permission`) SELECT '"..tonumber(newLevelId).."' AS `level_id`, `permission` FROM `level_permission` WHERE `level_id`="..tonumber(levelId)))
end

function sqlite3.removeLevelPermissions(levelId)
    cur = assert(con:execute("DELETE FROM `level_permission` WHERE `level_id`="..tonumber(levelId)..""))
end

function sqlite3.getPlayerPermissions(playerId)
    cur = assert(con:execute("SELECT * FROM `player_permission` WHERE `player_id`="..tonumber(playerId)..""))

    local permissions = {}
    local row = cur:fetch({}, "a")

    while row do
        table.insert(permissions, tables.copy(row))
        row = cur:fetch(row, "a")
    end

    cur:close()

    return permissions
end

function sqlite3.addPlayerPermission(playerId, permission)
    cur = assert(con:execute("INSERT INTO `player_permission` (`player_id`, `permission`) VALUES ("..tonumber(playerId)..", '"..util.escape(permission).."')"))
end

function sqlite3.removePlayerPermission(playerId, permission)
    cur = assert(con:execute("DELETE FROM `player_permission` WHERE `player_id`="..tonumber(playerId).." AND permission='"..util.escape(permission).."'"))
end

function sqlite3.copyPlayerPermissions(playerId, newPlayerId)
    cur = assert(con:execute("INSERT INTO `player_permission` (`player_id`, `permission`) SELECT '"..tonumber(newPlayerId).."' AS `player_id`, `permission` FROM `player_permission` WHERE `player_id`="..tonumber(playerId)))
end

function sqlite3.removePlayerPermissions(playerId)
    cur = assert(con:execute("DELETE FROM `player_permission` WHERE `player_id`="..tonumber(playerId)..""))
end

-- aliases
function sqlite3.addAlias(playerid, alias, lastused)
    cur = assert(con:execute("INSERT INTO `alias` (`player_id`, `alias`, `cleanalias`, `lastused`, `used`) VALUES ("..tonumber(playerid)..", '"..util.escape(alias).."', '"..util.escape(util.removeColors(alias)).."', "..tonumber(lastused)..", 1)"))
end

function sqlite3.updateAlias(aliasid, lastused)
    cur = assert(con:execute("UPDATE `alias` SET `lastused`="..tonumber(lastused)..", `used`=`used`+1 WHERE `id`='"..util.escape(aliasid).."'"))
end

function sqlite3.getAliasesCount(playerid)
    cur = assert(con:execute("SELECT COUNT(`id`) AS `count` FROM `alias` WHERE `player_id`="..tonumber(playerid)..""))

    local count = tonumber(cur:fetch({}, "a")["count"])
    cur:close()

    return count
end

function sqlite3.getAliases(playerid, limit, offset)
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

function sqlite3.getAliasById(aliasid)
    cur = assert(con:execute("SELECT * FROM `alias` WHERE `id`="..tonumber(aliasid)..""))
    
    local alias = cur:fetch({}, "a")
    cur:close()
    
    return alias
end

function sqlite3.getAliasByName(playerid, aliasname)
    cur = assert(con:execute("SELECT * FROM `alias` WHERE `player_id`="..tonumber(playerid).." AND `alias`='"..util.escape(aliasname).."'"))
    
    local alias = cur:fetch({}, "a")
    cur:close()
    
    return alias
end

function sqlite3.getLastAlias(playerid)
    cur = assert(con:execute("SELECT * FROM `alias` WHERE `player_id`="..tonumber(playerid).." ORDER BY `lastused` DESC LIMIT 1"))
    
    local alias = cur:fetch({}, "a")
    cur:close()
    
    return alias
end

-- history
function sqlite3.addHistory(victimId, invokerId, type, datetime, reason)
    cur = assert(con:execute("INSERT INTO `history` (`victim_id`, `invoker_id`, `type`, `datetime`, `reason`) VALUES ("..tonumber(victimId)..", "..tonumber(invokerId)..", '"..util.escape(type).."', "..tonumber(datetime)..", '"..util.escape(reason).."')"))
end

function sqlite3.removeHistory(historyId)
    cur = assert(con:execute("DELETE FROM `history` WHERE `id`="..tonumber(historyId)..""))
end

function sqlite3.getHistoryCount(playerId)
    cur = assert(con:execute("SELECT COUNT(`id`) AS `count` FROM `history` WHERE `victim_id`="..tonumber(playerId)..""))

    local count = tonumber(cur:fetch({}, "a")["count"])
    cur:close()

    return count
end

function sqlite3.getHistory(playerId, limit, offset)
    limit = limit or 30
    offset = offset or 0

    cur = assert(con:execute("SELECT * FROM `history` WHERE `victim_id`="..tonumber(playerId).." LIMIT "..tonumber(limit).." OFFSET "..tonumber(offset)))

    local warns = {}
    local row = cur:fetch({}, "a")
    
    while row do
        table.insert(warns, tables.copy(row))
        row = cur:fetch(row, "a")
    end

    cur:close()
    
    return warns
end

function sqlite3.getHistoryItem(historyId)
    cur = assert(con:execute("SELECT * FROM `history` WHERE `id`="..tonumber(historyId)..""))
    
    local history = cur:fetch({}, "a")
    cur:close()
    
    return history
end

-- mutes
function sqlite3.addMute(victimId, invokerId, type, issued, duration, reason)
    cur = assert(con:execute("INSERT INTO `mute` (`victim_id`, `invoker_id`, `type`, `issued`, `expires`, `duration`, `reason`) VALUES ("..tonumber(victimId)..", "..tonumber(invokerId)..", "..tonumber(type)..", "..tonumber(issued)..", "..tonumber(issued + duration)..", "..tonumber(duration)..", '"..util.escape(reason).."')"))
end

function sqlite3.removeMute(muteId)
    cur = assert(con:execute("DELETE FROM `mute` WHERE `id`="..tonumber(muteId)..""))
end

function sqlite3.getMutesCount()
    cur = assert(con:execute("SELECT COUNT(`id`) AS `count` FROM `mute`"))

    local count = tonumber(cur:fetch({}, "a")["count"])
    cur:close()

    return count
end

function sqlite3.getMutes(limit, offset)
    limit = limit or 30
    offset = offset or 0

    cur = assert(con:execute("SELECT * FROM `mute` LIMIT "..tonumber(limit).." OFFSET "..tonumber(offset)))

    local mutes = {}
    local row = cur:fetch({}, "a")

    while row do
        table.insert(mutes, tables.copy(row))
        row = cur:fetch(row, "a")
    end

    cur:close()

    return mutes
end

function sqlite3.getMute(muteId)
    cur = assert(con:execute("SELECT * FROM `mute` WHERE `id`="..tonumber(muteId)..""))

    local mute = cur:fetch({}, "a")
    cur:close()

    return mute
end

function sqlite3.getMuteByPlayer(playerId)
    cur = assert(con:execute("SELECT * FROM `mute` WHERE `victim_id`="..tonumber(playerId).." AND `expires`>"..os.time()))

    local mute = cur:fetch({}, "a")
    cur:close()

    return mute
end

-- bans
function sqlite3.addBan(victimId, invokerId, issued, duration, reason)
    cur = assert(con:execute("INSERT INTO `ban` (`victim_id`, `invoker_id`, `issued`, `expires`, `duration`, `reason`) VALUES ("..tonumber(victimId)..", "..tonumber(invokerId)..", "..tonumber(issued)..", "..(tonumber(issued) + tonumber(duration))..", "..tonumber(duration)..", '"..util.escape(reason).."')"))
end

function sqlite3.removeBan(banId)
    cur = assert(con:execute("DELETE FROM `ban` WHERE `id`="..tonumber(banId)..""))
end

function sqlite3.getBansCount()
    cur = assert(con:execute("SELECT COUNT(`id`) AS `count` FROM `ban`"))

    local count = tonumber(cur:fetch({}, "a")["count"])
    cur:close()

    return count
end

function sqlite3.getBans(limit, offset)
    limit = limit or 30
    offset = offset or 0

    cur = assert(con:execute("SELECT * FROM `ban` LIMIT "..tonumber(limit).." OFFSET "..tonumber(offset)))

    local bans = {}
    local row = cur:fetch({}, "a")

    while row do
        table.insert(bans, tables.copy(row))
        row = cur:fetch(row, "a")
    end

    cur:close()

    return bans
end

function sqlite3.getBan(banId)
    cur = assert(con:execute("SELECT * FROM `ban` WHERE `id`="..tonumber(banId)..""))

    local ban = cur:fetch({}, "a")
    cur:close()

    return ban
end

function sqlite3.getBanByPlayer(playerId)
    cur = assert(con:execute("SELECT * FROM `ban` WHERE `victim_id`="..tonumber(playerId).." AND `expires`>"..os.time()))

    local ban = cur:fetch({}, "a")
    cur:close()

    return ban
end

-- maps
function sqlite3.addMap(mapname, lastplayed)
    cur = assert(con:execute("INSERT INTO `map` (`name`, `lastplayed`) VALUES ('"..util.escape(mapname).."', "..tonumber(lastplayed)..")"))
end

function sqlite3.updateMap(mapid, lastplayed)
    cur = assert(con:execute("UPDATE `map` SET `lastplayed`="..tonumber(lastplayed).." WHERE `id`="..tonumber(mapid)..""))
end

function sqlite3.getMap(mapname)
    cur = assert(con:execute("SELECT * FROM `map` WHERE `name`='"..util.escape(mapname).."'"))
    
    local map = cur:fetch({}, "a")
    cur:close()
    
    return map
end

-- records
function sqlite3.addRecord(mapid, recorddate, recordtype, record, playerid)
    cur = assert(con:execute("INSERT INTO `record` (`map_id`, `date`, `type`, `record`, `player_id`) VALUES ("..tonumber(mapid)..", "..tonumber(recorddate)..", "..tonumber(recordtype)..", "..tonumber(record)..", "..tonumber(playerid)..")"))
end

function sqlite3.updateRecord(mapid, recorddate, recordtype, record, playerid)
    cur = assert(con:execute("UPDATE `record` SET `date`="..tonumber(recorddate)..", `record`="..tonumber(record)..", `player_id`="..tonumber(playerid).." WHERE `map_id`="..tonumber(mapid).." AND `type`="..tonumber(recordtype)..""))
end

function sqlite3.removeAllRecords()
    cur = assert(con:execute("TRUNCATE `record`"))
end

function sqlite3.removeRecords(mapid)
    cur = assert(con:execute("DELETE FROM `record` WHERE `map_id`="..tonumber(mapid)..""))
end

function sqlite3.getRecords(mapid)
    cur = assert(con:execute("SELECT * FROM `record` WHERE `map_id`="..tonumber(mapid)..""))

    local records = {}
    local row = cur:fetch({}, "a")

    while row do
        table.insert(records, tables.copy(row))
        row = cur:fetch({}, "a")
    end
    
    cur:close()
    
    return records
end

function sqlite3.getRecordsCount(mapid)
    cur = assert(con:execute("SELECT COUNT(*) AS `count` FROM `record` WHERE `map_id`="..tonumber(mapid)..""))
    
    local count = cur:fetch({}, "a")
    cur:close()
    
    return count["count"]
end

function sqlite3.getRecord(mapid, recordtype)
    cur = assert(con:execute("SELECT * FROM `record` WHERE `map_id`="..tonumber(mapid).." AND `type`="..tonumber(recordtype)..""))

    local record = cur:fetch({}, "a")
    cur:close()

    return record
end

function sqlite3.isConnected()
    return (con ~= nil)
end

function sqlite3.start()
    local uri, file = nil, settings.get("db_file")

    if string.find(file, ":memory:%?cache=shared") then
        uri = file
    else
        uri = wolfa_getHomePath()..file
    end

    con = env:connect(uri)

    if not con then
        error("could not connect to database")
    elseif not sqlite3.isSchemaExistent() then
        sqlite3.close()
        error("schema does not exist")
    end

    -- enable foreign key enforcement
    assert(con:execute("PRAGMA foreign_keys=1"))
    assert(con:execute("PRAGMA synchronous=0"))
end

function sqlite3.close(doSave)
    if con:close() then
        con = nil

        if env:close() then
            env = nil

            return true
        end
    end

    return false
end

return sqlite3
