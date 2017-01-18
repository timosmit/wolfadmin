
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

local constants
local util
local events
local timers
local settings

local db

local admin
local balancer
local bans
local history
local mutes
local rules

local commands

local game
local bots
local sprees
local teams
local voting

local greetings
local players
local stats

local version = "1.2.0-dev"
local release = "TBD"

local basepath = nil
local homepath = nil
local luapath = nil

-- need to do this somewhere else
function wolfa_getVersion()
    return version
end

function wolfa_getRelease()
    return release
end

function wolfa_getBasePath()
    return basepath
end

function wolfa_getHomePath()
    return homepath
end

function wolfa_getLuaPath()
    return luapath
end

function et_InitGame(levelTime, randomSeed, restartMap)
    -- set up paths
    basepath = string.gsub(et.trap_Cvar_Get("fs_basepath"), "\\", "/").."/"..et.trap_Cvar_Get("fs_game").."/"
    homepath = string.gsub(et.trap_Cvar_Get("fs_homepath"), "\\", "/").."/"..et.trap_Cvar_Get("fs_game").."/"
    luapath = string.gsub(debug.getinfo(1).source, "[\\/]", "."):sub(0, -10)

    -- load modules
    require (wolfa_getLuaPath()..".util.debug")

    constants = require (wolfa_getLuaPath()..".util.constants")
    util = require (wolfa_getLuaPath()..".util.util")
    events = require (wolfa_getLuaPath()..".util.events")
    timers = require (wolfa_getLuaPath()..".util.timers")
    settings = require (wolfa_getLuaPath()..".util.settings")

    db = require (wolfa_getLuaPath()..".db.db")

    admin = require (wolfa_getLuaPath()..".admin.admin")
    balancer = require (wolfa_getLuaPath()..".admin.balancer")
    bans = require (wolfa_getLuaPath()..".admin.bans")
    history = require (wolfa_getLuaPath()..".admin.history")
    mutes = require (wolfa_getLuaPath()..".admin.mutes")
    rules = require (wolfa_getLuaPath()..".admin.rules")

    commands = require (wolfa_getLuaPath()..".commands.commands")

    game = require (wolfa_getLuaPath()..".game.game")
    bots = require (wolfa_getLuaPath()..".game.bots")
    sprees = require (wolfa_getLuaPath()..".game.sprees")
    teams = require (wolfa_getLuaPath()..".game.teams")
    voting = require (wolfa_getLuaPath()..".game.voting")

    greetings = require (wolfa_getLuaPath()..".players.greetings")
    players = require (wolfa_getLuaPath()..".players.players")
    stats = require (wolfa_getLuaPath()..".players.stats")

    -- register the module
    et.RegisterModname("WolfAdmin "..wolfa_getVersion())
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "sets mod_wolfadmin "..wolfa_getVersion()..";")

    outputDebug("Module "..wolfa_getVersion().." ("..wolfa_getRelease()..") loaded successfully. Created by Timo 'Timothy' Smit.")
    
    events.trigger("onGameInit", levelTime, randomSeed, (restartMap == 1))
end

function et_ShutdownGame(restartMap)
    events.trigger("onGameShutdown", (restartMap == 1))
end

function et_ConsoleCommand(cmdText)
    return events.trigger("onServerCommand", cmdText)
end

function et_ClientConnect(clientId, firstTime, isBot)
    return events.trigger("onClientConnectAttempt", clientId, (firstTime == 1), (isBot == 1))
end

function et_ClientBegin(clientId)
    events.trigger("onClientBegin", clientId)
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
