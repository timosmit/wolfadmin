
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

local constants = require (wolfa_getLuaPath()..".util.constants")
local util = require (wolfa_getLuaPath()..".util.util")

local events = {}

local data = {}

function events.get(name)
    return data[name]
end

function events.add(name)
    if events.get(name) then
        error("event is already added: "..name)
    end
    
    data[name] = {}
end

function events.ishandled(name, func)
    if not events.get(name) then
        error("event not added: "..name)
    end
    
    local handlers = events.get(name)
    
    for i = 0, #handlers do
        if handlers[i] == func then
            return true
        end
    end
    
    return false
end

function events.handle(name, func)
    if not events.get(name) then
        error("event not added: "..name)
    end
    
    if events.ishandled(name, func) then
        error("event "..name.." is already handled by this function")
    end
    
    table.insert(data[name], func)
end

function events.unhandle(name, func)
    if not events.get(name) then
        error("event not added: "..name)
    end
    
    if not events.ishandled(name, func) then
        error("event "..name.." is not handled by this function")
    end
    
    local handlers = events.get(name)
    
    for i = 0, #handlers do
        if handlers[i] == func then
            table.remove(handlers, i)
        end
    end
end

function events.trigger(name, ...)
    local handlers = events.get(name)
    
    if not handlers then
        error("event not added: "..name)
    end
    
    local returnValue = nil
    
    for _, handler in pairs(handlers) do
        local handlerReturn = handler(...)
        
        if not returnValue and returnValue ~= 0 and handlerReturn ~= nil then
            returnValue = handlerReturn
        end
    end
    
    return returnValue
end

events.add("onCallvote")
events.add("onPollStart")
events.add("onPollFinish")

events.add("onClientConnectAttempt")
events.add("onClientConnect")
events.add("onClientDisconnect")
events.add("onClientBegin")
events.add("onClientCommand")
events.add("onClientInfoChange")
events.add("onClientNameChange")
events.add("onClientTeamChange")

events.add("onGameInit")
events.add("onGameStateChange")
events.add("onGameFrame")
events.add("onGameShutdown")

events.add("onPlayerReady")
events.add("onPlayerSpawn")
events.add("onPlayerDeath")
events.add("onPlayerRevive")

events.add("onPlayerSkillUpdate")

events.add("onServerCommand")

return events
