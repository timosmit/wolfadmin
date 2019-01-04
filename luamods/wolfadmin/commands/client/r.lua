
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

local commands = require (wolfa_getLuaPath()..".commands.commands")

local logs = require (wolfa_getLuaPath()..".util.logs")
local players = require (wolfa_getLuaPath()..".players.players")

function commandR(clientId, command, ...)
    if not ... then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9usage: "..commands.getclient("r")["syntax"].."\";")

        return true
    end

    local recipient = players.getLastPMSender(clientId)

    if not (recipient and et.gentity_get(recipient, "pers.netname")) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"player not found\";")

        return true
    end

    local message = table.concat({...}, " ")

    players.setLastPMSender(recipient, clientId)

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^7"..et.gentity_get(clientId, "pers.netname").."^7 -> "..recipient..": (1 recipients): ^3"..message.."\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound "..clientId.." \"sound/misc/pm.wav\";")

    if clientId ~= recipient then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..recipient.." \"^7"..et.gentity_get(clientId, "pers.netname").."^7 -> "..recipient..": (1 recipients): ^3"..message.."\";")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound "..recipient.." \"sound/misc/pm.wav\";")
    end

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "ccp "..recipient.." \"^3private message from "..et.gentity_get(clientId, "pers.netname").."\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..recipient.." \"^9reply: ^7r [^2message^7]\";")

    logs.writeChat(clientId, "priv", recipient, ...)

    return true
end
commands.addclient("r", commandR, "", "[^2message^7]", true)
