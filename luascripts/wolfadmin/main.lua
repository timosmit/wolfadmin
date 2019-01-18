
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2019 Timo 'Timothy' Smit

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

local admin
local balancer
local bans
local censor
local history
local mutes
local rules

local auth

local db

local commands

local bots
local fireteams
local game
local sprees
local teams
local voting

local greetings
local players
local stats

local bits
local constants
local events
local files
local logs
local pagination
local settings
local tables
local timers
local util

local version = "1.3.0-dev"
local release = "TBD"

local basepath
local homepath
local lualibspath
local luamodspath

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

function wolfa_getLuaLibsPath()
    return lualibspath
end

function wolfa_getLuaModsPath()
    return luamodspath
end

function wolfa_requireLib(lib)
    return require(wolfa_getLuaLibsPath().."/"..string.gsub(lib, "%.", "/"))
end

function wolfa_requireModule(module)
    return require(wolfa_getLuaModsPath().."/"..string.gsub(module, "%.", "/"))
end

function et_InitGame(levelTime, randomSeed, restartMap)
    -- set up paths
    basepath = string.gsub(et.trap_Cvar_Get("fs_basepath"), "\\", "/").."/"..et.trap_Cvar_Get("fs_game").."/"
    homepath = string.gsub(et.trap_Cvar_Get("fs_homepath"), "\\", "/").."/"..et.trap_Cvar_Get("fs_game").."/"
    lualibspath = "lualibs"
    luamodspath = "luascripts/wolfadmin"

    if debug then
        luamodspath = string.sub(debug.getinfo(1).source, 0, -10)
    end

    -- load modules
    wolfa_requireModule("util.debug")

    admin = wolfa_requireModule("admin.admin")
    balancer = wolfa_requireModule("admin.balancer")
    bans = wolfa_requireModule("admin.bans")
    censor = wolfa_requireModule("admin.censor")
    history = wolfa_requireModule("admin.history")
    mutes = wolfa_requireModule("admin.mutes")
    rules = wolfa_requireModule("admin.rules")

    auth = wolfa_requireModule("auth.auth")

    db = wolfa_requireModule("db.db")

    commands = wolfa_requireModule("commands.commands")

    bots = wolfa_requireModule("game.bots")
    game = wolfa_requireModule("game.game")
    fireteams = wolfa_requireModule("game.fireteams")
    sprees = wolfa_requireModule("game.sprees")
    teams = wolfa_requireModule("game.teams")
    voting = wolfa_requireModule("game.voting")

    greetings = wolfa_requireModule("players.greetings")
    players = wolfa_requireModule("players.players")
    stats = wolfa_requireModule("players.stats")

    bits = wolfa_requireModule("util.bits")
    constants = wolfa_requireModule("util.constants")
    events = wolfa_requireModule("util.events")
    files = wolfa_requireModule("util.files")
    logs = wolfa_requireModule("util.logs")
    pagination = wolfa_requireModule("util.pagination")
    settings = wolfa_requireModule("util.settings")
    tables = wolfa_requireModule("util.tables")
    timers = wolfa_requireModule("util.timers")
    util = wolfa_requireModule("util.util")

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
    local result, poll

    if et.trap_Cvar_Get("fs_game") == "legacy" then
        result, poll = string.match(consoleText, "^Vote (%w+): %(Y:%d+-N:%d+%) %[poll%] ([%w%s]+)\n$")
    else
        result, poll = string.match(consoleText, "^Vote (%w+): %[poll%] ([%w%s]+)\n$")
    end

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
