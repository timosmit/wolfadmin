
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

local util = require (wolfa_getLuaPath()..".util.util")

local pagination = {}

function pagination.calculate(count, limit, offset)
    util.typecheck("pagination.calculate", {count, limit, offset}, {"number", "number", "number"})

    limit = limit or 30
    offset = offset or 0

    if offset < 0 then
        if count < math.abs(offset) then
            limit = count
            offset = 0
        else
            limit = math.min(math.abs(offset), 30)
            offset = count + offset
        end
    elseif limit + offset > count then
        limit = count % limit
    end

    return limit, offset
end

return pagination
