
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

require "luascripts.wolfadmin.util.debug"

local constants = require "luascripts.wolfadmin.util.constants"
local util = require "luascripts.wolfadmin.util.util"
local events = require "luascripts.wolfadmin.util.events"
local timers = require "luascripts.wolfadmin.util.timers"
local settings = require "luascripts.wolfadmin.util.settings"

local db = require "luascripts.wolfadmin.db.db"

local admin = require "luascripts.wolfadmin.admin.admin"
local balancer = require "luascripts.wolfadmin.admin.balancer"
local rules = require "luascripts.wolfadmin.admin.rules"
local warns = require "luascripts.wolfadmin.admin.warns"

local commands = require "luascripts.wolfadmin.commands"

local game = require "luascripts.wolfadmin.game.game"
local bots = require "luascripts.wolfadmin.game.bots"
local sprees = require "luascripts.wolfadmin.game.sprees"
local voting = require "luascripts.wolfadmin.game.voting"

local stats = require "luascripts.wolfadmin.players.stats"
local greetings = require "luascripts.wolfadmin.players.greetings"

local version = "1.0.2"
local release = "16 February 2016"

local basepath = nil

-- game related data
local currentLevelTime = nil

-- need to do this somewhere else
function wolfa_getLevelTime()
    return currentLevelTime
end

function wolfa_getVersion()
    return version
end

function wolfa_getRelease()
    return release
end

function wolfa_getBasePath()
    return basepath
end

function et_InitGame(levelTime, randomSeed, restartMap)
    et.RegisterModname("WolfAdmin "..wolfa_getVersion())
    
    outputDebug("Module "..wolfa_getVersion().." ("..wolfa_getRelease()..") loaded successfully. Created by Timo 'Timothy' Smit.")
    
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "sets mod_wolfadmin "..wolfa_getVersion()..";")
    
    basepath = string.gsub(et.trap_Cvar_Get("fs_basepath"), "\\", "/").."/"..et.trap_Cvar_Get("fs_game").."/luascripts/wolfadmin/"
    
    if not (et.trap_Cvar_Get("fs_game") == "noquarter" or et.trap_Cvar_Get("fs_game") == "nq") then
        outputDebug("Warning! Not running NoQuarter, this may cause bugs. Use at your own risk.")
    end
    
    currentLevelTime = levelTime
    
    events.trigger("onGameInit", levelTime, randomSeed, (restartMap == 1))
end

function et_ShutdownGame(restartMap)
    events.trigger("onGameShutdown", (restartMap == 1))
end

function et_ConsoleCommand(cmdText)
    return events.trigger("onServerCommand", cmdText)
end

function et_ClientConnect(clientId, firstTime, isBot)
    if firstTime == 1 then
        stats.set(clientId, "newConnection", true)
    end
    
    return events.trigger("onClientConnect", clientId, (firstTime == 1), (isBot == 1))
end

function et_ClientBegin(clientId)
    events.trigger("onClientBegin", clientId, stats.get(clientId, "newConnection"))
    
    stats.set(clientId, "newConnection", false)
end

function et_ClientDisconnect(clientId)
    events.trigger("onClientDisconnect", clientId)
end

function et_ClientUserinfoChanged(clientId)
    events.trigger("onClientInfoChange", clientId)
end

function et_ClientCommand(clientId, cmdText)
    return events.trigger("onClientCommand", clientId, cmdText)
end

-- gameState
--   0 - game (also when paused)
--   1 - warmup
--   2 - unknown
--   3 - intermission
function et_RunFrame(levelTime)
    local gameState = tonumber(et.trap_Cvar_Get("gamestate"))
    
    if game.getState() ~= gameState then
        events.trigger("onGameStateChange", gameState)
    end
    
    events.trigger("onGameFrame", levelTime)
end

-- no callbacks defined for these things, so had to invent some special regexes
-- note for etlegacy team: please take a look at this, might come in handy :-)
function et_Print(consoleText)
    local result, poll = string.match(consoleText, "^Vote (%w+): %[poll%] ([%w%s]+)\n$")
    if result then
        events.trigger("onPollFinish", (result == "Passed"), poll)
    end
    
    local clientMedic, clientVictim = string.match(consoleText, "^Medic_Revive:%s+(%d+)%s+(%d+)\n$")
    clientMedic = tonumber(clientMedic)
    clientVictim = tonumber(clientVictim)
    if clientMedic and clientVictim then
        events.trigger("onPlayerRevive", clientMedic, clientVictim)
    end
end

function et_Obituary(victimId, killerId, mod)
    events.trigger("onPlayerDeath", victimId, killerId, mod)
end

function et_ClientSpawn(clientId, revived)
    if revived == 0 then
        events.trigger("onPlayerSpawn", clientId)
    end
end
