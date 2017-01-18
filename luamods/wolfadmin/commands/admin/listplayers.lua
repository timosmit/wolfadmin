
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

local auth = require "luamods.wolfadmin.auth.auth"

local commands = require "luamods.wolfadmin.commands.commands"

local game = require "luamods.wolfadmin.game.game"
local fireteams = require "luamods.wolfadmin.game.fireteams"

local players = require "luamods.wolfadmin.players.players"

local constants = require "luamods.wolfadmin.util.constants"
local settings = require "luamods.wolfadmin.util.settings"
local util = require "luamods.wolfadmin.util.util"

function commandListPlayers(clientId, cmdArguments)
    local playersOnline = {}

    for playerId = 0, et.trap_Cvar_Get("sv_maxclients") - 1 do
        if players.isConnected(playerId) then
            table.insert(playersOnline, playerId)
        end
    end

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dCurrently ^7"..(#playersOnline).." ^dplayers online^d:\";")
    for _, player in pairs(playersOnline) do
        local guidStub

        if players.isBot(player) then
            guidStub = "OMNIBOT-"
        else
            guidStub = players.getGUID(player):sub(-8)
        end

        local level = auth.getlevel(player)
        local levelName = auth.getlevelname(level)

        local teamColor, teamCode

        if et.gentity_get(player, "pers.connected") then
            teamColor = util.getTeamColor(tonumber(et.gentity_get(player, "sess.sessionTeam")))
            teamCode = util.getTeamCode(tonumber(et.gentity_get(player, "sess.sessionTeam"))):upper():sub(1,1)
        else
            teamColor = "^8"
            teamCode = "C"
        end

        local fireteamId, fireteamName = fireteams.getPlayerFireteamId(player), ""

        if fireteamId then
            fireteamName = fireteams.getName(fireteamId):sub(1, 1)
        end

        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^f"..string.format("%2i %s ^7%-2i %20s ^7(*%s) ^1%1s ^3%1s ^7%s ^7%s%s^7%s", 
            player, -- slot
            teamCode, -- team
            level, -- level
            levelName, -- levelname
            guidStub, -- guid stub
            (players.isMuted(player) and "M" or ""), -- muted
            fireteamName, -- fireteam
            players.getName(player), -- name
            "", -- alias open
            "", -- alias
            "" -- alias close
        ).."\";")
    end

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^dlistplayers: ^9current player info was printed to the console.\";")

    return true
end
commands.addadmin("listplayers", commandListPlayers, auth.PERM_LISTPLAYERS, "display a list of connected players, their slot numbers as well as their admin levels", nil, (settings.get("g_standalone") == 0))
