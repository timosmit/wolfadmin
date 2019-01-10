
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2019 Timo 'Timothy' Smit

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

local events = wolfa_requireModule("util.events")
local tables = wolfa_requireModule("util.tables")

local timers = {}

local data = {}
local nextId = 0

function timers.add(func, interval, rep, ...)
    local args = {...}
    
    table.insert(data, {
        ["id"] = nextId,
        ["function"] = func,
        ["start"] = et.trap_Milliseconds(),
        ["interval"] = interval,
        ["iteration"] = 0,
        ["repeat"] = rep,
        ["args"] = args
    })
    
    nextId = nextId + 1
    
    return nextId - 1
end

function timers.remove(id)
    for i = 1, #data do
        if data[i]["id"] == id then
            table.remove(data, i)
            
            return
        end
    end
end

function timers.ongameframe(levelTime)
    for id, timer in pairs(data) do
        if (et.trap_Milliseconds() - timer["start"]) > timer["interval"] then
            timer["function"](tables.unpack(timer["args"]))
            timer["iteration"] = timer["iteration"] + 1
            
            if timer["repeat"] == 0 or timer["iteration"] < timer["repeat"] then
                timer["start"] = et.trap_Milliseconds()
            else
                timers.remove(timer["id"])
            end
        end
    end
end
events.handle("onGameFrame", timers.ongameframe)

return timers
