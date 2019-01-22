
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

local vectors = {}

function vectors.add(vector1, vector2)
    return { vector1[1] + vector2[1], vector1[2] + vector2[2], vector1[3] + vector2[3] }
end

function vectors.scale(vector, factor)
    return { vector[1] * factor, vector[2] * factor, vector[3] * factor }
end

function vectors.angle(angles)
    local angle;
    local sr, sp, sy, cr, cp, cy;
    local forward, right, up = {}, {}, {}

    angle = angles[2] * ((math.pi*2) / 360);
    sy    = math.sin(angle);
    cy    = math.cos(angle);

    angle = angles[1] * ((math.pi*2) / 360);
    sp    = math.sin(angle);
    cp    = math.cos(angle);

    angle = angles[3] * ((math.pi*2) / 360);
    sr    = math.sin(angle);
    cr    = math.cos(angle);

    forward[1] = cp * cy;
    forward[2] = cp * sy;
    forward[3] = -sp;

    right[1] = (-1 * sr * sp * cy + -1 * cr * -sy);
    right[2] = (-1 * sr * sp * sy + -1 * cr * cy);
    right[3] = -1 * sr * cp;

    up[1] = (cr * sp * cy + -sr * -sy);
    up[2] = (cr * sp * sy + -sr * cy);
    up[3] = cr * cp;

    return forward, right, up
end

return vectors
