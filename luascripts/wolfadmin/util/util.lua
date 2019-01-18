
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

local constants = require (wolfa_getLuaPath()..".util.constants")

local util = {}

function util.typecheck(func, args, types)
    for idx, arg in ipairs(args) do
        if type(arg) ~= types[idx] then
            error("bad argument #"..idx.." to '"..func.."' ("..types[idx].." expected, got "..type(arg)..")", 3)
        end
    end
end

function util.split(str, pat)
    local t = {}    -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t,cap)
        end
        last_end = e+1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    
    return t
end

function util.escape(str)
    util.typecheck("util.escape", {str}, {"string"})

    return string.gsub(str, "([\"'])", "\\%1")
end

function util.removeColors(str)
    util.typecheck("util.removeColors", {str}, {"string"})

    return string.gsub(str, "(^[%a%d%p])", "")
end

function util.getTeamName(teamId)
    if teamId == constants.TEAM_AXIS then
        return "Axis"
    elseif teamId == constants.TEAM_ALLIES then
        return "Allies"
    elseif teamId == constants.TEAM_SPECTATORS then
        return "Spectators"
    else
        return "unknown"
    end
end

function util.getTeamFromCode(teamCode)
    if teamCode == constants.TEAM_AXIS_SC or teamCode == constants.TEAM_AXIS_NAME or teamCode == constants.TEAM_AXIS_COLOR_NAME then
        return constants.TEAM_AXIS
    elseif teamCode == constants.TEAM_ALLIES_SC or teamCode == constants.TEAM_ALLIES_NAME or teamCode == constants.TEAM_ALLIES_COLOR_NAME then
        return constants.TEAM_ALLIES
    elseif teamCode == constants.TEAM_SPECTATORS_SC or teamCode == constants.TEAM_SPECTATORS_NAME then
        return constants.TEAM_SPECTATORS
    else
        return 0
    end
end

function util.getChatFromCommand(chatCommand)
    if chatCommand == constants.SAY_ALL_CMD then
        return et.SAY_ALL
    elseif chatCommand == constants.SAY_TEAM_CMD then
        return et.SAY_TEAM
    elseif chatCommand == constants.SAY_BUDDY_CMD then
        return et.SAY_BUDDY
    elseif chatCommand == constants.SAY_TEAMNL_CMD then
        return et.SAY_TEAMNL
    else
        return et.SAY_ALL
    end
end

function util.getTeamColor(teamId)
    if teamId == constants.TEAM_AXIS then
        return constants.TEAM_AXIS_COLOR
    elseif teamId == constants.TEAM_ALLIES then
        return constants.TEAM_ALLIES_COLOR
    elseif teamId == constants.TEAM_SPECTATORS then
        return constants.TEAM_SPECTATORS_COLOR
    else
        return constants.COLOR_MAIN
    end
end

function util.getTeamCode(teamId)
    if teamId == constants.TEAM_AXIS then
        return constants.TEAM_AXIS_SC
    elseif teamId == constants.TEAM_ALLIES then
        return constants.TEAM_ALLIES_SC
    elseif teamId == constants.TEAM_SPECTATORS then
        return constants.TEAM_SPECTATORS_SC
    else
        return "unknown"
    end
end

function util.getClassName(classId)
    if classId == constants.CLASS_SOLDIER then
        return "Soldier"
    elseif classId == constants.CLASS_MEDIC then
        return "Medic"
    elseif classId == constants.CLASS_ENGINEER then
        return "Engineer"
    elseif classId == constants.CLASS_FIELDOPS then
        return "Field Ops"
    elseif classId == constants.CLASS_COVERTOPS then
        return "Covert Ops"
    else
        return "unknown"
    end
end

function util.getAreaName(areaId)
    if areaId == constants.AREA_CONSOLE then
        return "csay -1"
    elseif areaId == constants.AREA_POPUPS then
        return "cpm"
    elseif areaId == constants.AREA_CHAT then
        return "cchat -1"
    elseif areaId == constants.AREA_CP then
        return "cp"
    else
        return "cp"
    end
end

function util.getTimeFromString(str)
    local amount, unit = string.match(str, "^([0-9]+)([smhdwy])$")
    
    if not (amount and unit) then return nil end

    amount = math.floor(amount)
    
    local multiplier = {
        ["s"] = function(a) return a end,
        ["m"] = function(a) return a * 60 end,
        ["h"] = function(a) return a * 60 * 60 end,
        ["d"] = function(a) return a * 60 * 60 * 24 end,
        ["w"] = function(a) return a * 60 * 60 * 24 * 7 end,
        ["y"] = function(a) return a * 60 * 60 * 24 * 365 end
    }
    
    return multiplier[unit](amount)
end

return util
