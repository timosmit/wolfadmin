
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

local events = require (wolfa_getLuaPath()..".util.events")
local files = require (wolfa_getLuaPath()..".util.files")

local auth = require (wolfa_getLuaPath()..".auth.auth")

local shrubbot = {}

-- available shrubflags: lqyFHY
local flags = {
    [auth.PERM_ADMINTEST] = "a",
    [auth.PERM_HELP] = "h",
    [auth.PERM_TIME] = "C",
    [auth.PERM_GREETING] = "Q",

    [auth.PERM_LISTPLAYERS] = "i",
    [auth.PERM_LISTTEAMS] = "l",
    [auth.PERM_LISTMAPS] = "C",
    [auth.PERM_LISTSPREES] = "I",
    [auth.PERM_LISTRULES] = "C",
    [auth.PERM_LISTHISTORY] = "f",
    [auth.PERM_LISTBANS] = "B",
    [auth.PERM_LISTALIASES] = "f",
    [auth.PERM_LISTLEVELS] = "s",
    [auth.PERM_LISTSTATS] = "I",
    [auth.PERM_FINGER] = "f",

    [auth.PERM_RESETXP] = "X",
    [auth.PERM_RESETXP_SELF] = "M",

    [auth.PERM_ADMINCHAT] = "~",

    [auth.PERM_PUT] = "p",
    [auth.PERM_DROPWEAPONS] = "D",
    [auth.PERM_RENAME] = "N",
    [auth.PERM_FREEZE] = "E",
    [auth.PERM_DISORIENT] = "d",
    [auth.PERM_BURN] = "U",
    [auth.PERM_SLAP] = "A",
    [auth.PERM_GIB] = "g",
    [auth.PERM_THROW] = "L",
    [auth.PERM_GLOW] = "o",
    [auth.PERM_PANTS] = "t",
    [auth.PERM_POP] = "z",

    [auth.PERM_WARN] = "R",
    [auth.PERM_MUTE] = "m",
    [auth.PERM_VOICEMUTE] = "m",
    [auth.PERM_KICK] = "k",
    [auth.PERM_BAN] = "b",

    [auth.PERM_SPEC999] = "P",
    [auth.PERM_BALANCE] = "p",
    [auth.PERM_LOCKPLAYER] = "L",
    [auth.PERM_LOCKTEAM] = "L",
    [auth.PERM_SHUFFLE] = "S",
    [auth.PERM_SWAP] = "w",

    [auth.PERM_PAUSE] = "Z",
    [auth.PERM_NEXTMAP] = "n",
    [auth.PERM_RESTART] = "r",

    [auth.PERM_BOTADMIN] = "O",

    [auth.PERM_ENABLEVOTE] = "c",
    [auth.PERM_CANCELVOTE] = "c",
    [auth.PERM_PASSVOTE] = "V",

    [auth.PERM_NEWS] = "W",

    [auth.PERM_UPTIME] = "u",
    [auth.PERM_SETLEVEL] = "s",
    [auth.PERM_READCONFIG] = "G",

    [auth.PERM_CHEATS] = "e",
    [auth.PERM_DISGUISE] = "T",
    [auth.PERM_AMMOPACK] = "J",
    [auth.PERM_MEDPACK] = "J",
    [auth.PERM_REVIVE] = "v",

    [auth.PERM_NOINACTIVITY] = "0",
    [auth.PERM_NOVOTE] = "1",
    [auth.PERM_NOCENSOR] = "2",
    [auth.PERM_NOBALANCE] = "5",
    [auth.PERM_NOVOTELIMIT] = "7",
    [auth.PERM_NOREASON] = "6",
    [auth.PERM_PERMA] = "8",

    [auth.PERM_TEAMCMDS] = "9",
    [auth.PERM_SILENTCMDS] = "3",

    [auth.PERM_SPY] = "4",
    [auth.PERM_INCOGNITO] = "@",
    [auth.PERM_IMMUNE] = "!",
}

function shrubbot.isPlayerAllowed(clientId, permission)
    return et.G_shrubbot_permission(clientId, flags[permission]) == 1
end

function shrubbot.getPlayerLevel(clientId)
    return et.G_shrubbot_level(clientId)
end

return shrubbot
