
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

this.CLIENT_CONSOLE = -1337;

function this.exec(command, clientId)
    clientId = tonumber(clientId) and tonumber(clientId) or -1

    et.trap_SendServerCommand(clientId, command)
end

function this.outputConsole(text, clientId)
    this.exec(string.format("%s \"%s\n\";", "print", text), clientId)
end

function this.outputBanner(text, clientId)
    this.exec(string.format("%s \"%s\";", "bp", text), clientId)
end

function this.outputAnnounce(text, clientId)
    this.exec(string.format("%s \"%s\";", "announce", text), clientId)
end

function this.outputCenter(text, clientId)
    this.exec(string.format("%s \"%s\";", "cp", text), clientId)
end

function this.outputPopup(text, clientId, type)
    type = tonumber(type) and tonumber(type) or 4

    this.exec(string.format("%s \"%s\" %d;", "cpm", text, type), clientId)
end

function this.outputChat(text, clientId)
    this.exec(string.format("%s \"%s\";", "chat", text), clientId)
end

function this.outputTeamChat(text, clientId, victimId, x, y, z)
    if not (x and y and z) then
        this.exec(string.format("%s \"%s\" %d;", "tchat", text, victimId), clientId)

        return
    end

    this.exec(string.format("%s \"%s\" %d %d %d %d;", "tchat", text, victimId, x, y, z), clientId)
end

function this.playMusic(file, clientId)
    this.exec(string.format("%s \"%s\";", "mu_play", file), clientId)
end

return this
