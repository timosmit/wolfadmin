
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

local auth = require (wolfa_getLuaPath()..".auth.auth")

local commands = require (wolfa_getLuaPath()..".commands.commands")

local players = require (wolfa_getLuaPath()..".players.players")

local settings = require (wolfa_getLuaPath()..".util.settings")

function commandPersonalMessage(clientId, cmdArguments)
    if #cmdArguments > 1 then
        local cmdClient

        if tonumber(cmdArguments[1]) == nil or tonumber(cmdArguments[1]) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
            cmdClient = et.ClientNumberFromString(cmdArguments[1])
        else
            cmdClient = tonumber(cmdArguments[1])
        end

        if cmdClient ~= -1 and et.gentity_get(cmdClient, "pers.netname") then
            players.setLastPMSender(cmdClient, clientId)

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..cmdClient.." \"^9reply: ^7r [^2message^7]\";")
        end
    end
end
commands.addclient("pm", commandPersonalMessage, "", "", true, (settings.get("fs_game") ~= "legacy"))
commands.addclient("m", commandPersonalMessage, "", "", true, (settings.get("fs_game") ~= "legacy"))

function commandPersonalMessage(clientId, cmdArguments)
    if #cmdArguments == 0 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9usage: "..commands.getclient("pm")["syntax"].."\";")

        return true
    end

    local cmdClient

    if tonumber(cmdArguments[1]) == nil or tonumber(cmdArguments[1]) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(cmdArguments[1])
    else
        cmdClient = tonumber(cmdArguments[1])
    end

    if cmdClient == -1 or cmdClient == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9pm: ^7no or multiple matches for '^7"..cmdArguments[1].."^9'.\";")

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dpm: ^7no connected player by that name or slot #\";")

        return true
    end

    local message, messageConcatenated = {}, ""

    for i = 1, #cmdArguments do
        message[i] = cmdArguments[i]
    end

    messageConcatenated = table.concat(message, " ")

    if cmdClient ~= -1 and et.gentity_get(cmdClient, "pers.netname") then
        players.setLastPMSender(cmdClient, clientId)

        et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^7"..et.gentity_get(clientId, "pers.netname").."^7 -> "..cmdArguments[1].."^7: (1 recipients): ^3"..messageConcatenated.."\";")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound "..clientId.." \"sound/misc/pm.wav\";")

        if clientId ~= cmdClient then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..cmdClient.." \"^7"..et.gentity_get(clientId, "pers.netname").."^7 -> "..cmdArguments[1].."^7: (1 recipients): ^3"..messageConcatenated.."\";")
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound "..cmdClient.." \"sound/misc/pm.wav\";")
        end

        et.trap_SendConsoleCommand(et.EXEC_APPEND, "ccp "..cmdClient.." \"^3private message from "..et.gentity_get(clientId, "pers.netname").."\";")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..cmdClient.." \"^9reply: ^7r [^2message^7]\";")
    end
end
commands.addclient("pm", commandPersonalMessage, "", "", true, (settings.get("fs_game") == "legacy"))
commands.addclient("m", commandPersonalMessage, "", "", true, (settings.get("fs_game") == "legacy"))
