
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2016 Timo 'Timothy' Smit

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

local auth = require "luascripts.wolfadmin.auth.auth"
local settings = require "luascripts.wolfadmin.util.settings"
local db = require "luascripts.wolfadmin.db.db"
local commands = require "luascripts.wolfadmin.commands.commands"
local admin = require "luascripts.wolfadmin.admin.admin"

function commandSetLevel(clientId, cmdArguments)
    if #cmdArguments < 2 then
        return false
    elseif tonumber(cmdArguments[1]) == nil then
        cmdClient = et.ClientNumberFromString(cmdArguments[1])
    else
        cmdClient = tonumber(cmdArguments[1])
    end
    
    if cmdClient == -1 then
        return false
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        return false
    end
    
    -- plays a promotion sound
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound \"/sound/vo/general/axis/hq_promogen.wav\";")
    
    if db.isconnected() then
        cmdArguments[2] = tonumber(cmdArguments[2]) or 0 
        
        admin.setPlayerLevel(cmdClient, tonumber(cmdArguments[2]), clientId)
    end
    
    return false
end
commands.addadmin("setlevel", commandSetLevel, auth.PERM_SETLEVEL, "sets the admin level of a player", "^9[^3name|slot#^9] ^9[^3level^9]", true)
