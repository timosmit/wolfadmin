
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015 Timo 'Timothy' Smit

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

local events = require "luascripts.wolfadmin.util.events"
local files = require "luascripts.wolfadmin.util.files"
local settings = require "luascripts.wolfadmin.util.settings"

local rules = {}

local data = {}

function rules.get(shortcut)
    if shortcut then
        return data[shortcut]
    end
    
    return data
end

function rules.load()
    local fileName = settings.get("g_fileRules")
    
    if fileName == "" then
        return 0
    end
    
    local amount, array = files.loadCFG(fileName, "[a-z]+", true)
    
    if amount == 0 then return 0 end
    
    for id, rule in ipairs(array["rule"]) do
        data[rule["shortcut"]] = rule["rule"]
    end
    
    return amount
end

function rules.oninit(levelTime, randomSeed, restartMap)
    rules.load()
end
events.handle("onGameInit", rules.oninit)

return rules