
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

local commands = wolfa_requireModule("commands.commands")

local players = wolfa_requireModule("players.players")

local logs = wolfa_requireModule("util.logs")
local settings = wolfa_requireModule("util.settings")
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

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..cmdClient.." \"^9reply: ^7r [^2message^7]\";")
        end
    end
end
commands.addclient("pm", commandPersonalMessage, "", "", true, (settings.get("fs_game") == "legacy"))
commands.addclient("m", commandPersonalMessage, "", "", true, (settings.get("fs_game") == "legacy"))

function commandPersonalMessageLegacy(clientId, command, target, ...)
    if not target or not ... then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9usage: "..commands.getclient("pm")["syntax"].."\";")

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
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9pm: ^7no or multiple matches for '^7"..target.."^9'.\";")

        return true
    end

    local message = table.concat({...}, " ")

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^7"..et.gentity_get(clientId, "pers.netname").."^7 -> "..target.."^7: ("..#recipients.." recipients): ^3"..message.."\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound "..clientId.." \"sound/misc/pm.wav\";")

    for _, recipient in ipairs(recipients) do
        players.setLastPMSender(recipient, clientId)

        if clientId ~= recipient then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..recipient.." \"^7"..et.gentity_get(clientId, "pers.netname").."^7 -> "..recipient.."^7: ("..#recipients.." recipients): ^3"..message.."\";")
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound "..recipient.." \"sound/misc/pm.wav\";")
        end

        et.trap_SendConsoleCommand(et.EXEC_APPEND, "ccp "..recipient.." \"^3private message from "..et.gentity_get(clientId, "pers.netname").."\";")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..recipient.." \"^9reply: ^7r [^2message^7]\";")

        logs.writeChat(clientId, "priv", recipient, ...)
    end

    return true
end
commands.addclient("pm", commandPersonalMessageLegacy, "", "[^2name^7|^2slot#^7] [^2message^7]", true, (settings.get("fs_game") ~= "legacy"))
commands.addclient("m", commandPersonalMessageLegacy, "", "[^2name^7|^2slot#^7] [^2message^7]", true, (settings.get("fs_game") ~= "legacy"))
