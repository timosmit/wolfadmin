
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

local this = {}

function this.exec(command, when)
    when = when and when or et.EXEC_APPEND

    et.trap_SendConsoleCommand(when, command)
end

function this.outputServerConsole(text)
    et.G_Print(text.."\n")
end

function this.outputClientConsole(text, clientId)
    clientId = clientId and clientId or -1

    this.exec(string.format("%s %d \"%s\";", "csay", clientId, text))
end

function this.outputClientBanner(text, clientId)
    clientId = clientId and clientId or -1

    this.exec(string.format("%s %d \"%s\";", "cbp", clientId, text))
end

function this.outputClientAnnounce(text, clientId)
    clientId = clientId and clientId or -1

    this.exec(string.format("%s %d \"%s\";", "cannounce", clientId, text))
end

function this.outputClientCenter(text, clientId)
    clientId = clientId and clientId or -1

    this.exec(string.format("%s %d \"%s\";", "ccp", clientId, text))
end

function this.outputClientPopup(text, clientId, type)
    clientId = clientId and clientId or -1
    type = tonumber(type) and tonumber(type) or 4

    this.exec(string.format("%s %d \"%s\" %d;", "ccpm", clientId, text, type))
end

function this.outputClientChat(text, clientId)
    clientId = clientId and clientId or -1

    this.exec(string.format("%s %d \"%s\";", "cchat", clientId, text))
end

function this.outputClientTeamChat(text, clientId, victimId, x, y, z)
    clientId = clientId and clientId or -1

    if not (x and y and z) then
        this.exec(string.format("%s %d \"%s\" %d;", "ctchat", clientId, text, victimId))

        return
    end

    this.exec(string.format("%s %d \"%s\" %d %d %d %d;", "ctchat", clientId, text, victimId, x, y, z))
end

function this.playClientMusic(file, clientId)
    clientId = clientId and clientId or -1

    this.exec(string.format("%s %d \"%s\";", "cmusic", file))
end

return this
