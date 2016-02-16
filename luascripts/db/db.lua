
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

local util = require "luascripts.wolfadmin.util.util"
local events = require "luascripts.wolfadmin.util.events"
local settings = require "luascripts.wolfadmin.util.settings"

local db = {}

local con

-- as this module serves as a wrapper/super class, we load the selected database
-- system in this function. might have to think of a better way to implement
-- this, but it will suffice.
function db.oninit()
    if settings.get("db_type") == "mysql" and settings.get("db_username") ~= "" then
        con = require "luascripts.wolfadmin.db.mysql"
    else
        con = require "luascripts.wolfadmin.db.cfg"
    end
    
    setmetatable(db, {__index = con})
    
    db.start()
end
events.handle("onGameInit", db.oninit)

function db.onshutdown(restartMap)
    db.close(not restartMap)
end
events.handle("onGameShutdown", db.onshutdown)

return db