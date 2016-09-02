
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

local constants = require "luascripts.wolfadmin.util.constants"
local util = require "luascripts.wolfadmin.util.util"
local events = require "luascripts.wolfadmin.util.events"
local settings = require "luascripts.wolfadmin.util.settings"
local files = require "luascripts.wolfadmin.util.files"

local stats = require "luascripts.wolfadmin.players.stats"

local greetings = {}

local userGreetings = {}
local levelGreetings = {}

function greetings.get(clientId)
    local lvl = auth.getlevel(clientId)
    
    if auth.isallowed(clientId, auth.PERM_INCOGNITO) ~= 1 then
        if userGreetings[stats.get(clientId, "playerGUID")] ~= nil then
            return userGreetings[stats.get(clientId, "playerGUID")]
        elseif levelGreetings[lvl] ~= nil then
            return levelGreetings[lvl]
        end
    else
        if levelGreetings[0] then
            return levelGreetings[0]
        end
    end
end

function greetings.show(clientId)
    local greeting = greetings.get(clientId)
    
    if greeting then
        local prefix = (util.getAreaName(settings.get("g_greetingArea")) ~= "cp") and "^dgreeting: ^9" or "^7"
        local text = prefix..greeting["text"]:gsub("%[N%]", et.gentity_get(clientId, "pers.netname"))
        local out = ""
        
        while util.getAreaName(settings.get("g_greetingArea")) == "cp" and string.len(text) > constants.MAX_LENGTH_CP do
            local sub = text:sub(1, constants.MAX_LENGTH_CP)
            local rev = sub:reverse()

            local pos = rev:find(" [^^]") -- some epic smiley exclusion here

            if pos then
                pos = constants.MAX_LENGTH_CP - pos
                out = out..text:sub(1, pos).."\\n"
                text = text:sub(pos + 2)
            else
                pos = sub:len()
                out = out..text:sub(1, pos).."\\n"
                text = text:sub(pos + 1)
            end
        end
        
        if greeting["sound"] then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound \"/sound/"..greeting["sound"].."\";")
        end
        
        et.trap_SendConsoleCommand(et.EXEC_APPEND, util.getAreaName(settings.get("g_greetingArea")).." \""..out..text.."\";")
    end
end

function greetings.load()
    local fileName = settings.get("g_fileGreetings")
    
    local amount, array = files.loadCFG(fileName, "[a-z]+", true)
    
    if amount == 0 then return 0 end
    
    for id, greeting in ipairs(array["level"]) do
        levelGreetings[tonumber(greeting["level"])] = {
            ["text"] = greeting["greeting"],
            ["sound"] = greeting["sound"],
        }
    end
    
    for id, greeting in ipairs(array["user"]) do
        userGreetings[greeting["guid"]] = {
            ["text"] = greeting["greeting"],
            ["sound"] = greeting["sound"],
        }
    end
    
    return amount
end

function greetings.oninit(levelTime, randomSeed, restartMap)
    if settings.get("g_fileGreetings") ~= "" then
        greetings.load()
        
        events.handle("onClientBegin", greetings.onbegin)
    end
end
events.handle("onGameInit", greetings.oninit)

function greetings.onbegin(clientId, firstTime)
    if firstTime and (not stats.get(clientId, "isBot") or settings.get("g_botGreetings") == 1) then
        greetings.show(clientId)
    end
end

return greetings
