
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

local commands = require (wolfa_getLuaPath()..".commands.commands")

local players = require (wolfa_getLuaPath()..".players.players")

function commandSay(clientId, cmdArguments)
    if players.isMuted(clientId, players.MUTE_CHAT) then
        et.trap_SendServerCommand(clientId, "cp \"^1You are muted\"")

        return true
    end
end
commands.addclient("say", commandSay, "", "", false, (settings.get("g_standalone") == 0))
commands.addclient("say_team", commandSay, "", "", false, (settings.get("g_standalone") == 0))
commands.addclient("say_teamnl", commandSay, "", "", false, (settings.get("g_standalone") == 0))
commands.addclient("say_buddy", commandSay, "", "", false, (settings.get("g_standalone") == 0))

function commandVoiceSay(clientId, cmdArguments)
    if players.isMuted(clientId, players.MUTE_VOICE) then
        et.trap_SendServerCommand(clientId, "cp \"^1You are voicemuted\"")

        return true
    end
end
commands.addclient("vsay", commandVoiceSay, "", "", false)
commands.addclient("vsay_team", commandVoiceSay, "", "", false)
