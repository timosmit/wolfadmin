
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

local bits = require (wolfa_getLuaPath()..".util.bits")

local fireteams = {}

fireteams.FT_ALPHA = 0
fireteams.FT_BRAVO = 1
fireteams.FT_CHARLIE = 2
fireteams.FT_DELTA = 3
fireteams.FT_ECHO = 4
fireteams.FT_FOXTROT = 5

fireteams.NUM_FIRETEAMS = 6

function fireteams.getId(fireteam)
    return 893 + fireteam
end

function fireteams.isUsed(fireteamId)
    if not fireteamId then
        return nil
    end

    local data = et.trap_GetConfigstring(fireteamId)
    local id = tonumber(et.Info_ValueForKey(data, "id"))

    return (id ~= -1)
end

function fireteams.isPrivate(fireteamId)
    if not fireteamId or not fireteams.isUsed(fireteamId) then
        return nil
    end

    local data = et.trap_GetConfigstring(fireteamId)
    local p = tonumber(et.Info_ValueForKey(data, "p"))

    return (p == 1)
end

function fireteams.getName(fireteamId)
    if not fireteamId or not fireteams.isUsed(fireteamId) then
        return nil
    end

    local data = et.trap_GetConfigstring(fireteamId)
    local id = tonumber(et.Info_ValueForKey(data, "id"))

    local name

    if id == fireteams.FT_ALPHA then
        name = "Alpha"
    elseif id == fireteams.FT_BRAVO then
        name = "Bravo"
    elseif id == fireteams.FT_CHARLIE then
        name = "Charlie"
    elseif id == fireteams.FT_DELTA then
        name = "Delta"
    elseif id == fireteams.FT_ECHO then
        name = "Echo"
    elseif id == fireteams.FT_FOXTROT then
        name = "Foxtrot"
    end

    return name
end

function fireteams.getLeader(fireteamId)
    if not fireteamId or not fireteams.isUsed(fireteamId) then
        return nil
    end

    local data = et.trap_GetConfigstring(fireteamId)
    local l = tonumber(et.Info_ValueForKey(data, "l"))

    return l
end

function fireteams.getTeam(fireteamId)
    if not fireteamId or not fireteams.isUsed(fireteamId) then
        return nil
    end

    local data = et.trap_GetConfigstring(fireteamId)
    local l = tonumber(et.Info_ValueForKey(data, "l"))
    local team = et.gentity_get(l, "sess.sessionTeam")

    return team
end

function fireteams.getMembers(fireteamId)
    if not fireteamId or not fireteams.isUsed(fireteamId) then
        return nil
    end

    local data = et.trap_GetConfigstring(fireteamId)

    local members = {}

    for i = 0, 15 do
        local c = tonumber("0x0"..et.Info_ValueForKey(data, "c"):sub(16 - i, 16 - i))

        for j = 0, 3 do
            if bits.hasbit(c, 2^j) then
                table.insert(members, (i * 4 + j))
            end
        end
    end

    return members
end

function fireteams.getPlayerFireteamId(clientId)
    local hex = math.floor(clientId / 4)
    local bit = clientId % 4

    for i = 0, 11 do
        local fireteamId = fireteams.getId(i)

        if fireteams.isUsed(fireteamId) then -- please add a continue statement one day
            local data = et.trap_GetConfigstring(fireteamId)
            local c = tonumber("0x0"..et.Info_ValueForKey(data, "c"):sub(16 - hex, 16 - hex))

            if bits.hasbit(c, 2^bit) then
                return fireteamId
            end
        end
    end

    return nil
end

return fireteams
