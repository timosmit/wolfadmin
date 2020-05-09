
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

local client = wolfa_requireModule("game.client")
local server = wolfa_requireModule("game.server")

local this = {}

function this.serverConsole(text)
    server.outputServerConsole(text)
end

function this.clientConsole(text, clientId)
    if clientId ~= client.CLIENT_CONSOLE then
        server.outputClientConsole(text, clientId)
    elseif clientId then
        this.serverConsole(text)
    end
end

function this.clientBanner(text, clientId)
    if clientId ~= client.CLIENT_CONSOLE then
        server.outputClientBanner(text, clientId)
    elseif clientId then
        this.serverConsole(text)
    end
end

function this.clientAnnounce(text, clientId)
    if clientId ~= client.CLIENT_CONSOLE then
        server.outputClientAnnounce(text, clientId)
    elseif clientId then
        this.serverConsole(text)
    end
end

function this.clientCenter(text, clientId)
    if clientId ~= client.CLIENT_CONSOLE then
        server.outputClientCenter(text, clientId)
    elseif clientId then
        this.serverConsole(text)
    end
end

function this.clientPopup(text, clientId, type)
    if clientId ~= client.CLIENT_CONSOLE then
        server.outputClientPopup(text, clientId, type)
    elseif clientId then
        this.serverConsole(text)
    end
end

function this.clientChat(text, clientId)
    if clientId ~= client.CLIENT_CONSOLE then
        server.outputClientChat(text, clientId)
    elseif clientId then
        this.serverConsole(text)
    end
end

function this.clientTeamChat(text, clientId, victimId, x, y, z)
    if clientId ~= client.CLIENT_CONSOLE then
        server.outputClientChat(text, clientId, victimId, x, y, z)
    elseif clientId then
        this.serverConsole(text)
    end
end

return this
