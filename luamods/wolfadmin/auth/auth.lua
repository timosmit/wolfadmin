
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

local events = require (wolfa_getLuaPath()..".util.events")
local settings = require (wolfa_getLuaPath()..".util.settings")

local auth = {}

local srv

auth.PERM_ADMINTEST = "admintest"
auth.PERM_HELP = "help"
auth.PERM_TIME = "time"
auth.PERM_GREETING = "greeting"

auth.PERM_LISTPLAYERS = "listplayers"
auth.PERM_LISTTEAMS = "listteams"
auth.PERM_LISTMAPS = "listmaps"
auth.PERM_LISTSPREES = "listsprees"
auth.PERM_LISTRULES = "listrules"
auth.PERM_LISTHISTORY = "listhistory"
auth.PERM_LISTBANS = "listbans"
auth.PERM_LISTALIASES = "listaliases"
auth.PERM_LISTSTATS = "liststats"
auth.PERM_FINGER = "finger"

auth.PERM_RESETXP = "resetxp"
auth.PERM_RESETXP_SELF = "resetxp_self"

auth.PERM_ADMINCHAT = "adminchat"

auth.PERM_PUT = "put"
auth.PERM_DROPWEAPONS = "dropweapons"
auth.PERM_RENAME = "rename"
auth.PERM_FREEZE = "freeze"
auth.PERM_DISORIENT = "disorient"
auth.PERM_BURN = "burn"
auth.PERM_SLAP = "slap"
auth.PERM_GIB = "gib"
auth.PERM_THROW = "throw"
auth.PERM_GLOW = "glow"
auth.PERM_PANTS = "pants"
auth.PERM_POP = "pop"

auth.PERM_WARN = "warn"
auth.PERM_MUTE = "mute"
auth.PERM_VOICEMUTE = "voicemute"
auth.PERM_KICK = "kick"
auth.PERM_BAN = "ban"

auth.PERM_SPEC999 = "spec999"
auth.PERM_BALANCE = "balance"
auth.PERM_LOCKPLAYER = "lockplayer"
auth.PERM_LOCKTEAM = "lockteam"
auth.PERM_SHUFFLE = "shuffle"
auth.PERM_SWAP = "swap"

auth.PERM_PAUSE = "pause"
auth.PERM_NEXTMAP = "nextmap"
auth.PERM_RESTART = "restart"

auth.PERM_BOTADMIN = "botadmin"

auth.PERM_ENABLEVOTE = "enablevote"
auth.PERM_CANCELVOTE = "cancelvote"
auth.PERM_PASSVOTE = "passvote"

auth.PERM_COINTOSS = "cointoss"
auth.PERM_NEWS = "news"

auth.PERM_UPTIME = "uptime"
auth.PERM_SETLEVEL = "setlevel"
auth.PERM_READCONFIG = "readconfig"

auth.PERM_CHEATS = "cheats"
auth.PERM_DISGUISE = "disguise" -- legacy
auth.PERM_AMMOPACK = "ammopack" -- legacy
auth.PERM_MEDPACK = "medpack" -- legacy
auth.PERM_REVIVE = "revive" -- legacy

auth.PERM_NOINACTIVITY = "noinactivity"
auth.PERM_NOVOTE = "novote"
auth.PERM_NOCENSOR = "nocensor"
auth.PERM_NOBALANCE = "nobalance"
auth.PERM_NOVOTELIMIT = "novotelimit"
auth.PERM_NOREASON = "noreason"
auth.PERM_PERMA = "perma"

auth.PERM_TEAMCMDS = "teamcmds"
auth.PERM_SILENTCMDS = "silentcmds"

auth.PERM_SPY = "spy"
auth.PERM_INCOGNITO = "incognito"
auth.PERM_IMMUNE = "immune"

-- as this module serves as a wrapper/super class, we load the selected database
-- system in this function. might have to think of a better way to implement
-- this, but it will suffice.
function auth.onGameInit()
    if settings.get("g_standalone") == 1 then
        srv = require (wolfa_getLuaPath()..".auth.acl")
    else
        srv = require (wolfa_getLuaPath()..".auth.shrubbot")
    end
    
    if settings.get("g_standalone") == 1 and et.trap_Cvar_Get("g_shrubbot") ~= "" then
        outputDebug("Running in standalone mode while g_shrubbot is set", 3)
    end
    
    setmetatable(auth, {__index = srv})
end
events.handle("onGameInit", auth.onGameInit)

return auth
