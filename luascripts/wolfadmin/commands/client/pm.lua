
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
local config = wolfa_requireModule("config.config")
local output = wolfa_requireModule("game.output")
local server = wolfa_requireModule("game.server")
local players = wolfa_requireModule("players.players")
local logs = wolfa_requireModule("util.logs")
local util = wolfa_requireModule("util.util")

function commandPersonalMessage(clientId, command, recipient, ...)
    if recipient and ... then
        local cmdClient

        if tonumber(recipient) == nil or tonumber(recipient) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
            cmdClient = et.ClientNumberFromString(recipient)
        else
            cmdClient = tonumber(recipient)
        end

        if cmdClient ~= -1 and et.gentity_get(cmdClient, "pers.netname") then
            players.setLastPMSender(cmdClient, clientId)

            output.clientConsole("^9reply: ^7r [^2message^7]", clientId)
        end
    end
end
commands.addclient("pm", commandPersonalMessage, "", "", true, (config.get("fs_game") == "legacy"))
commands.addclient("m", commandPersonalMessage, "", "", true, (config.get("fs_game") == "legacy"))

function commandPersonalMessageLegacy(clientId, command, target, ...)
    if not target or not ... then
        output.clientConsole("^9usage: "..commands.getclient("pm")["syntax"], clientId)

        return true
    end

    local recipients = {}

    local targetSanitized = string.lower(util.removeColors(target))

    for playerId = 0, et.trap_Cvar_Get("sv_maxclients") - 1 do
        if players.isConnected(playerId) then
            local playerNameSanitized = string.lower(util.removeColors(players.getName(playerId)))

            if string.find(playerNameSanitized, targetSanitized, 1, true) then
                table.insert(recipients, playerId)
            end
        end
    end

    if #recipients == 0 then
        output.clientConsole("^9pm: ^7no or multiple matches for '^7"..target.."^9'.", clientId)

        return true
    end

    local message = table.concat({...}, " ")

    output.clientChat("^7"..et.gentity_get(clientId, "pers.netname").."^7 -> "..target.."^7: ("..#recipients.." recipients): ^3"..message, clientId)
    server.exec(string.format("playsound %d \"sound/misc/pm.wav\";", clientId))

    for _, recipient in ipairs(recipients) do
        players.setLastPMSender(recipient, clientId)

        if clientId ~= recipient then
            output.clientChat("^7"..et.gentity_get(clientId, "pers.netname").."^7 -> "..recipient.."^7: ("..#recipients.." recipients): ^3"..message, recipient)
            server.exec(string.format("playsound %d \"sound/misc/pm.wav\";", recipient))
        end

        output.clientCenter("^3private message from "..et.gentity_get(clientId, "pers.netname").."\";", recipient)
        output.clientConsole("^9reply: ^7r [^2message^7]", recipient)

        logs.writeChat(clientId, "priv", recipient, ...)
    end

    return true
end
commands.addclient("pm", commandPersonalMessageLegacy, "", "[^2name^7|^2slot#^7] [^2message^7]", true, (config.get("fs_game") ~= "legacy"))
commands.addclient("m", commandPersonalMessageLegacy, "", "[^2name^7|^2slot#^7] [^2message^7]", true, (config.get("fs_game") ~= "legacy"))
