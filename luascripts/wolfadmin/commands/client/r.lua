
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

local commands = wolfa_requireModule("commands.commands")
local output = wolfa_requireModule("game.output")
local server = wolfa_requireModule("game.server")
local players = wolfa_requireModule("players.players")
local logs = wolfa_requireModule("util.logs")

function commandR(clientId, command, ...)
    if not ... then
        output.clientConsole("^9usage: "..commands.getclient("r")["syntax"], clientId)

        return true
    end

    local recipient = players.getLastPMSender(clientId)

    if not (recipient and et.gentity_get(recipient, "pers.netname")) then
        output.clientConsole("player not found", clientId)

        return true
    end

    local message = table.concat({...}, " ")

    players.setLastPMSender(recipient, clientId)

    output.clientChat("^7"..et.gentity_get(clientId, "pers.netname").."^7 -> "..recipient..": (1 recipients): ^3"..message, clientId)
    server.exec(string.format("playsound %d \"sound/misc/pm.wav\";", clientId))

    if clientId ~= recipient then
        output.clientChat("^7"..et.gentity_get(clientId, "pers.netname").."^7 -> "..recipient..": (1 recipients): ^3"..message, recipient)
        server.exec(string.format("playsound %d \"sound/misc/pm.wav\";", recipient))
    end

    output.clientCenter("^3private message from "..et.gentity_get(clientId, "pers.netname"), recipient)
    output.clientConsole("^9reply: ^7r [^2message^7]", recipient)

    logs.writeChat(clientId, "priv", recipient, ...)

    return true
end
commands.addclient("r", commandR, "", "[^2message^7]", true)
