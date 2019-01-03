
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

local events = require (wolfa_getLuaPath()..".util.events")
local settings = require (wolfa_getLuaPath()..".util.settings")

local db = {}

local con

function db.isConnected()
    return (con ~= nil and con.isConnected())
end

-- as this module serves as a wrapper/super class, we load the selected database
-- system in this function. might have to think of a better way to implement
-- this, but it will suffice.
function db.oninit()
    if settings.get("db_type") ~= "none" then
        if settings.get("db_type") == "sqlite3" then
            con = require (wolfa_getLuaPath()..".db.sqlite3")
        elseif settings.get("db_type") == "mysql" then
            con = require (wolfa_getLuaPath()..".db.mysql")
        else
            outputDebug("Invalid database system (none|sqlite3|mysql), defaulting to 'none'.")

            return
        end

        setmetatable(db, {__index = con})

        if not db.start() then
            outputDebug("Database could not be loaded, only limited functionality is available.", 3)
        end
    end
end
events.handle("onGameInit", db.oninit)

function db.onshutdown(restartMap)
    if db.isConnected() then
        db.close(not restartMap)
    end
end
events.handle("onGameShutdown", db.onshutdown)

return db
