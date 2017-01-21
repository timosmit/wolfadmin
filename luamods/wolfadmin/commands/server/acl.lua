
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

local acl = require (wolfa_getLuaPath()..".auth.acl")

local commands = require (wolfa_getLuaPath()..".commands.commands")

function commandAclListLevels(cmdArguments)
    for _, level in ipairs(acl.getLevels()) do
        et.G_Print(string.format("%5d %30s %6d players", level["id"], level["name"], level["players"]).."\n")
    end
end

function commandAclAddLevel(cmdArguments)
    local levelId = tonumber(cmdArguments[2])
    local name = cmdArguments[3]

    if not levelId then
        et.G_Print("usage: acl addlevel [id] [name]\n")

        return true
    elseif acl.isLevel(levelId) then
        et.G_Print("error: level "..levelId.." already exists\n")

        return true
    end

    acl.addLevel(levelId, name)

    et.G_Print("added level "..levelId.." ("..name..")\n")
end

function commandAclRemoveLevel(cmdArguments)
    local levelId = tonumber(cmdArguments[2])

    if not levelId or not acl.isLevel(levelId) then
        et.G_Print("usage: acl removelevel [id]\n")

        return true
    end

    acl.removeLevelRoles(levelId)
    acl.removeLevel(levelId)

    et.G_Print("removed level "..levelId.."\n")
end

function commandAclReLevel(cmdArguments)
    local levelId = tonumber(cmdArguments[2])
    local newLevelId = tonumber(cmdArguments[3])

    if not levelId or not acl.isLevel(levelId) or not newLevelId or not acl.isLevel(newLevelId) then
        et.G_Print("usage: acl relevel [id] [newid]\n")

        return true
    end

    acl.reLevel(levelId, newLevelId)

    et.G_Print("releveled all players with "..levelId.." to "..newLevelId.."\n")
end

function commandAclListLevelRoles(cmdArguments)
    local levelId = tonumber(cmdArguments[2])

    if not levelId or not acl.isLevel(levelId) then
        et.G_Print("usage: acl listroles [id]\n")

        return true
    end

    et.G_Print("roles for level "..levelId..":\n")

    for _, role in ipairs(acl.getLevelRoles(levelId)) do
        et.G_Print(role.."\n")
    end
end

function commandAclIsAllowed(cmdArguments)
    local levelId = tonumber(cmdArguments[2])
    local role = cmdArguments[3]

    if not levelId or not acl.isLevel(levelId) or not role then
        et.G_Print("usage: acl isallowed [id] [role]\n")

        return true
    end

    local isAllowed = acl.isLevelAllowed(levelId, role)

    et.G_Print("level "..levelId.." "..(isAllowed and "HAS" or "HAS NOT").." "..role.."\n")
end

function commandAclAddLevelRole(cmdArguments)
    local levelId = tonumber(cmdArguments[2])
    local role = cmdArguments[3]

    if not levelId or not acl.isLevel(levelId) or not role then
        et.G_Print("usage: acl addrole [id] [role]\n")

        return true
    end

    local isAllowed = acl.isLevelAllowed(levelId, role)

    if isAllowed then
        et.G_Print("error: level "..levelId.." already has '"..role.."'\n")

        return true
    end

    acl.addLevelRole(levelId, role)

    et.G_Print("added role "..role.." to level "..levelId.."\n")
end

function commandAclRemoveLevelRole(cmdArguments)
    local levelId = tonumber(cmdArguments[2])
    local role = cmdArguments[3]

    if not levelId or not acl.isLevel(levelId) or not role then
        et.G_Print("usage: acl removerole [id] [role]\n")

        return true
    end

    local isAllowed = acl.isLevelAllowed(levelId, role)

    if not isAllowed then
        et.G_Print("error: level "..levelId.." does not have '"..role.."'\n")

        return true
    end

    acl.removeLevelRole(levelId, role)

    et.G_Print("removed role "..role.." from level "..levelId.."\n")
end

function commandAclCopyLevelRoles(cmdArguments)
    local levelId = tonumber(cmdArguments[2])
    local newLevelId = tonumber(cmdArguments[3])

    if not levelId or not acl.isLevel(levelId) or not newLevelId or not acl.isLevel(newLevelId) then
        et.G_Print("usage: acl copyroles [id] [newid]\n")

        return true
    end

    if #acl.getLevelRoles(newLevelId) ~= 0 then
        et.G_Print("error: level "..newLevelId.." already has roles\n")

        return true
    end

    acl.copyLevelRoles(levelId, newLevelId)

    et.G_Print("copied roles from "..levelId.." to "..newLevelId.."\n")
end

function commandAcl(cmdArguments)
    local cmd = cmdArguments[1]

    if cmd == "listlevels" then
        return commandAclListLevels(cmdArguments)
    elseif cmd == "addlevel" then
        return commandAclAddLevel(cmdArguments)
    elseif cmd == "removelevel" then
        return commandAclRemoveLevel(cmdArguments)
    elseif cmd == "relevel" then
        return commandAclReLevel(cmdArguments)
    elseif cmd == "listroles" then
        return commandAclListLevelRoles(cmdArguments)
    elseif cmd == "isallowed" then
        return commandAclIsAllowed(cmdArguments)
    elseif cmd == "addrole" then
        return commandAclAddLevelRole(cmdArguments)
    elseif cmd == "removerole" then
        return commandAclRemoveLevelRole(cmdArguments)
    elseif cmd == "copyroles" then
        return commandAclCopyLevelRoles(cmdArguments)
    else
        et.G_Print("usage: acl [listlevels|addlevel|removelevel|relevel|listroles|isallowed|addrole|removerole|copyroles]")
    end
    
    return true
end
commands.addserver("acl", commandAcl)
