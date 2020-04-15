
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2020 Timo 'Timothy' Smit

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

local acl = wolfa_requireModule("auth.acl")
local config = wolfa_requireModule("config.config")
local db = wolfa_requireModule("db.db")
local commands = wolfa_requireModule("commands.commands")

function commandAclListLevels()
    for _, level in ipairs(acl.getLevels()) do
        et.G_Print(string.format("%5d %30s %6d players", level["id"], level["name"], level["players"]).."\n")
    end
end

function commandAclAddLevel(levelId, name)
    local levelId = tonumber(levelId)

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

function commandAclRemoveLevel(levelId)
    local levelId = tonumber(levelId)

    if not levelId or not acl.isLevel(levelId) then
        et.G_Print("usage: acl removelevel [id]\n")

        return true
    end

    acl.removeLevelPermissions(levelId)
    acl.removeLevel(levelId)

    et.G_Print("removed level "..levelId.."\n")
end

function commandAclReLevel(levelId, newLevelId)
    local levelId = tonumber(levelId)
    local newLevelId = tonumber(newLevelId)

    if not levelId or not acl.isLevel(levelId) or not newLevelId or not acl.isLevel(newLevelId) then
        et.G_Print("usage: acl relevel [id] [newid]\n")

        return true
    end

    acl.reLevel(levelId, newLevelId)

    et.G_Print("releveled all players with "..levelId.." to "..newLevelId.."\n")
end

function commandAclListLevelPermissions(levelId)
    local levelId = tonumber(levelId)

    if not levelId or not acl.isLevel(levelId) then
        et.G_Print("usage: acl listpermissions [id]\n")

        return true
    end

    et.G_Print("permissions for level "..levelId..":\n")

    for _, permission in ipairs(acl.getLevelPermissions(levelId)) do
        et.G_Print(permission.."\n")
    end
end

function commandAclIsAllowed(levelId, permission)
    local levelId = tonumber(levelId)

    if not levelId or not acl.isLevel(levelId) or not permission then
        et.G_Print("usage: acl isallowed [id] [permission]\n")

        return true
    end

    local isAllowed = acl.isLevelAllowed(levelId, permission)

    et.G_Print("level "..levelId.." "..(isAllowed and "HAS" or "HAS NOT").." "..permission.."\n")
end

function commandAclAddLevelPermission(levelId, permission)
    local levelId = tonumber(levelId)

    if not levelId or not acl.isLevel(levelId) or not permission then
        et.G_Print("usage: acl addpermission [id] [permission]\n")

        return true
    end

    local isAllowed = acl.isLevelAllowed(levelId, permission)

    if isAllowed then
        et.G_Print("error: level "..levelId.." already has '"..permission.."'\n")

        return true
    end

    acl.addLevelPermission(levelId, permission)

    et.G_Print("added permission "..permission.." to level "..levelId.."\n")
end

function commandAclRemoveLevelPermission(levelId, permission)
    local levelId = tonumber(levelId)

    if not levelId or not acl.isLevel(levelId) or not permission then
        et.G_Print("usage: acl removepermission [id] [permission]\n")

        return true
    end

    local isAllowed = acl.isLevelAllowed(levelId, permission)

    if not isAllowed then
        et.G_Print("error: level "..levelId.." does not have '"..permission.."'\n")

        return true
    end

    acl.removeLevelPermission(levelId, permission)

    et.G_Print("removed permission "..permission.." from level "..levelId.."\n")
end

function commandAclCopyLevelPermissions(levelId, newLevelId)
    local levelId = tonumber(levelId)
    local newLevelId = tonumber(newLevelId)

    if not levelId or not acl.isLevel(levelId) or not newLevelId or not acl.isLevel(newLevelId) then
        et.G_Print("usage: acl copypermissions [id] [newid]\n")

        return true
    end

    acl.copyLevelPermissions(levelId, newLevelId)

    et.G_Print("copied permissions from "..levelId.." to "..newLevelId.."\n")
end

function commandAclRemoveLevelPermissions(levelId)
    local levelId = tonumber(levelId)

    if not levelId or not acl.isLevel(levelId) then
        et.G_Print("usage: acl removepermissions [id]\n")

        return true
    end

    acl.removeLevelPermissions(levelId)

    et.G_Print("removed permissions from "..levelId.."\n")
end

function commandAcl(command, action, ...)
    if action == "listlevels" then
        return commandAclListLevels(...)
    elseif action == "addlevel" then
        return commandAclAddLevel(...)
    elseif action == "removelevel" then
        return commandAclRemoveLevel(...)
    elseif action == "relevel" then
        return commandAclReLevel(...)
    elseif action == "listpermissions" then
        return commandAclListLevelPermissions(...)
    elseif action == "isallowed" then
        return commandAclIsAllowed(...)
    elseif action == "addpermission" then
        return commandAclAddLevelPermission(...)
    elseif action == "removepermission" then
        return commandAclRemoveLevelPermission(...)
    elseif action == "copypermissions" then
        return commandAclCopyLevelPermissions(...)
    elseif action == "removepermissions" then
        return commandAclRemoveLevelPermissions(...)
    else
        et.G_Print("usage: acl [listlevels|addlevel|removelevel|relevel|listpermissions|isallowed|addpermission|removepermission|copypermissions|removepermissions]")
    end
    
    return true
end
commands.addserver("acl", commandAcl, (config.get("g_standalone") == 0 or not db.isConnected()))
