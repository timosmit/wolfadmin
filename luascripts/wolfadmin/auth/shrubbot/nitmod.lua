
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2020 Timo 'Timothy' Smit

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

local auth = wolfa_requireModule("auth.auth")

local flags = {
    [auth.PERM_ADMINTEST] = "admintest",
    [auth.PERM_HELP] = "help",
    [auth.PERM_TIME] = "time",
    [auth.PERM_GREETING] = "", -- TODO

    [auth.PERM_LISTPLAYERS] = "listplayers",
    [auth.PERM_LISTTEAMS] = "", -- TODO
    [auth.PERM_LISTMAPS] = "", -- TODO
    [auth.PERM_LISTSPREES] = "", -- TODO
    [auth.PERM_LISTRULES] = "",
    [auth.PERM_LISTHISTORY] = "",
    [auth.PERM_LISTBANS] = "showbans", -- TODO
    [auth.PERM_LISTALIASES] = "", -- TODO
    [auth.PERM_LISTSTATS] = "", -- TODO
    [auth.PERM_FINGER] = "finger", -- TODO

    [auth.PERM_RESETXP] = "resetxp",
    [auth.PERM_RESETXP_SELF] = "resetmyxp",

    [auth.PERM_ADMINCHAT] = "adminchat",

    [auth.PERM_PUT] = "put",
    [auth.PERM_RENAME] = "rename",
    [auth.PERM_FREEZE] = "freeze",
    [auth.PERM_DISORIENT] = "disorient",
    [auth.PERM_BURN] = "burn",
    [auth.PERM_SLAP] = "slap",
    [auth.PERM_GIB] = "splata", -- g: individual, Q: all players
    [auth.PERM_THROW] = "throw", -- l: individual, L: all players
    [auth.PERM_POP] = "pop",
    [auth.PERM_NADE] = "nade",

    [auth.PERM_WARN] = "warn",
    [auth.PERM_MUTE] = "mute",
    [auth.PERM_VOICEMUTE] = "mute",
    [auth.PERM_KICK] = "kick",
    [auth.PERM_BAN] = "ban",

    [auth.PERM_SPEC999] = "spec999",
    [auth.PERM_BALANCE] = "", -- TODO
    [auth.PERM_LOCKPLAYER] = "lock",
    [auth.PERM_LOCKTEAM] = "lock",
    [auth.PERM_SHUFFLE] = "shuffle",
    [auth.PERM_SWAP] = "swap",

    [auth.PERM_COINTOSS] = "", -- TODO
    [auth.PERM_PAUSE] = "pause",
    [auth.PERM_NEXTMAP] = "nextmap",
    [auth.PERM_RESTART] = "restart",

    [auth.PERM_BOTADMIN] = "maxbots",

    [auth.PERM_ENABLEVOTE] = "cancelvote",
    [auth.PERM_CANCELVOTE] = "cancelvote",
    [auth.PERM_PASSVOTE] = "passvote",

    [auth.PERM_NEWS] = "news",

    [auth.PERM_UPTIME] = "uptime",
    [auth.PERM_SETLEVEL] = "setlevel",
    [auth.PERM_INCOGNITO] = "setlevel",
    [auth.PERM_READCONFIG] = "readconfig",

    [auth.PERM_WARSETTINGS] = "panzerwar",

    [auth.PERM_NOINACTIVITY] = "inactivity",
    [auth.PERM_NOVOTE] = "novote",
    [auth.PERM_NOCENSOR] = "nocensorflood",
    [auth.PERM_NOBALANCE] = "balanceimmunity",
    [auth.PERM_NOVOTELIMIT] = "novotelimit",
    [auth.PERM_NOREASON] = "noreason",
    [auth.PERM_NOAKA] = "incognito",
    [auth.PERM_PERMA] = "permban",

    [auth.PERM_TEAMCMDS] = "teamcmds",
    [auth.PERM_SILENTCMDS] = "silentcmds",

    [auth.PERM_SPY] = "specchat",
    [auth.PERM_IMMUNE] = "immunity",
}

return flags
