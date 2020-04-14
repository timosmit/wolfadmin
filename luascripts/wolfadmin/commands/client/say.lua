
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

local censor = wolfa_requireModule("admin.censor")

local auth = wolfa_requireModule("auth.auth")

local commands = wolfa_requireModule("commands.commands")

local players = wolfa_requireModule("players.players")

local logs = wolfa_requireModule("util.logs")
local settings = wolfa_requireModule("util.settings")
local util = wolfa_requireModule("util.util")

local types = {
    ["say"] = "chat",
    ["say_team"] = "team",
    ["say_teamnl"] = "spec",
    ["say_buddy"] = "fire",
    ["vsay"] = "chat",
    ["vsay_team"] = "team",
    ["vsay_buddy"] = "fire"
}

function commandSay(clientId, command, ...)
    if players.isMuted(clientId, players.MUTE_CHAT) then
        et.trap_SendServerCommand(clientId, "cp \"^1You are muted\"")

        return true
    end

    if settings.get("g_censor") ~= 0 and not auth.isPlayerAllowed(clientId, auth.PERM_NOCENSOR) then
        local censored, message = censor.filterMessage(...)

        if censored then
            censor.punishClient(clientId)

            et.G_Say(clientId, util.getChatFromCommand(command), message)

            return true
        end
    end

    if settings.get("fs_game") == "legacy" then
        logs.writeChat(clientId, types[command], ...)
    end
end
commands.addclient("say", commandSay, "", "", false, (settings.get("g_standalone") == 0))
commands.addclient("say_team", commandSay, "", "", false, (settings.get("g_standalone") == 0))
commands.addclient("say_teamnl", commandSay, "", "", false, (settings.get("g_standalone") == 0))
commands.addclient("say_buddy", commandSay, "", "", false, (settings.get("g_standalone") == 0))

function commandVoiceSay(clientId, command, ...)
    if players.isMuted(clientId, players.MUTE_VOICE) then
        et.trap_SendServerCommand(clientId, "cp \"^1You are voicemuted\"")

        return true
    end

    if settings.get("fs_game") == "legacy" then
        logs.writeChat(clientId, types[command], ...)
    end
end
commands.addclient("vsay", commandVoiceSay, "", "", false)
commands.addclient("vsay_team", commandVoiceSay, "", "", false)
commands.addclient("vsay_buddy", commandVoiceSay, "", "", false)
