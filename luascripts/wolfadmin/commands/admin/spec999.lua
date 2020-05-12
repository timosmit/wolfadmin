
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

local admin = wolfa_requireModule("admin.admin")
local auth = wolfa_requireModule("auth.auth")
local commands = wolfa_requireModule("commands.commands")
local config = wolfa_requireModule("config.config")
local output = wolfa_requireModule("game.output")
local players = wolfa_requireModule("players.players")
local constants = wolfa_requireModule("util.constants")

function commandSpec999(clientId, command)
    local count = 0

    for playerId = 0, et.trap_Cvar_Get("sv_maxclients") - 1 do
        if players.isConnected(playerId) then
            if et.gentity_get(playerId, "ps.ping") > 500 and et.gentity_get(playerId, "ps.ping") <= 999 then
                admin.putPlayer(playerId, constants.TEAM_SPECTATORS)

                count = count + 1
            end
        end
    end

    output.clientConsole("^dspec999: ^9"..count.." players were put to spectators.", clientId)

    return true
end
commands.addadmin("spec999", commandSpec999, auth.PERM_SPEC999, "moves 999 pingers to the spectator team", nil, nil, (config.get("g_standalone") == 0))
