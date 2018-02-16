
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2018 Timo 'Timothy' Smit

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

local shrubbot = {}

local flags

function shrubbot.loadFlags(mod)
    flags = require (wolfa_getLuaPath()..".auth.shrubbot."..mod)
end

function shrubbot.isPlayerAllowed(clientId, permission)
    if not flags[permission] then
        outputDebug("shrubbot.isPlayerAllowed requested for unknown permission ("..tostring(permission)..")", 3)

        return false
    end

    return et.G_shrubbot_permission(clientId, flags[permission]) == 1
end

function shrubbot.getPlayerLevel(clientId)
    return et.G_shrubbot_level(clientId)
end

return shrubbot
