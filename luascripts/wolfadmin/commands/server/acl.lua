
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
local commands = wolfa_requireModule("commands.commands")
local db = wolfa_requireModule("db.db")
local output = wolfa_requireModule("game.output")

function commandAclListLevels()
    for _, level in ipairs(acl.getLevels()) do
        output.serverConsole(string.format("%5d %30s %6d players", level["id"], level["name"], level["players"]))
    end
end

function commandAclAddLevel(levelId, name)
    levelId = tonumber(levelId)

    if not levelId then
        output.serverConsole("usage: acl addlevel [id] [name]")

        return true
    elseif acl.isLevel(levelId) then
        output.serverConsole("error: level "..levelId.." already exists")

        return true
    end

    acl.addLevel(levelId, name)

    output.serverConsole("added level "..levelId.." ("..name..")")
end

function commandAclRemoveLevel(levelId)
    levelId = tonumber(levelId)

    if not levelId or not acl.isLevel(levelId) then
        output.serverConsole("usage: acl removelevel [id]")

        return true
    end

    acl.removeLevelPermissions(levelId)
    acl.removeLevel(levelId)

    output.serverConsole("removed level "..levelId)
end

function commandAclReLevel(levelId, newLevelId)
    levelId = tonumber(levelId)
    newLevelId = tonumber(newLevelId)

    if not levelId or not acl.isLevel(levelId) or not newLevelId or not acl.isLevel(newLevelId) then
        output.serverConsole("usage: acl relevel [id] [newid]")

        return true
    end

    acl.reLevel(levelId, newLevelId)

    output.serverConsole("releveled all players with "..levelId.." to "..newLevelId)
end

function commandAclListLevelPermissions(levelId)
    levelId = tonumber(levelId)

    if not levelId or not acl.isLevel(levelId) then
        output.serverConsole("usage: acl listpermissions [id]")

        return true
    end

    output.serverConsole("permissions for level "..levelId..":")

    for _, permission in ipairs(acl.getLevelPermissions(levelId)) do
        output.serverConsole(permission)
    end
end

function commandAclIsAllowed(levelId, permission)
    levelId = tonumber(levelId)

    if not levelId or not acl.isLevel(levelId) or not permission then
        output.serverConsole("usage: acl isallowed [id] [permission]")

        return true
    end

    local isAllowed = acl.isLevelAllowed(levelId, permission)

    output.serverConsole("level "..levelId.." "..(isAllowed and "HAS" or "HAS NOT").." "..permission)
end

function commandAclAddLevelPermission(levelId, permission)
    levelId = tonumber(levelId)

    if not levelId or not acl.isLevel(levelId) or not permission then
        output.serverConsole("usage: acl addpermission [id] [permission]")

        return true
    end

    local isAllowed = acl.isLevelAllowed(levelId, permission)

    if isAllowed then
        output.serverConsole("error: level "..levelId.." already has '"..permission.."'")

        return true
    end

    acl.addLevelPermission(levelId, permission)

    output.serverConsole("added permission "..permission.." to level "..levelId)
end

function commandAclRemoveLevelPermission(levelId, permission)
    levelId = tonumber(levelId)

    if not levelId or not acl.isLevel(levelId) or not permission then
        output.serverConsole("usage: acl removepermission [id] [permission]")

        return true
    end

    local isAllowed = acl.isLevelAllowed(levelId, permission)

    if not isAllowed then
        output.serverConsole("error: level "..levelId.." does not have '"..permission.."'")

        return true
    end

    acl.removeLevelPermission(levelId, permission)

    output.serverConsole("removed permission "..permission.." from level "..levelId)
end

function commandAclCopyLevelPermissions(levelId, newLevelId)
    levelId = tonumber(levelId)
    newLevelId = tonumber(newLevelId)

    if not levelId or not acl.isLevel(levelId) or not newLevelId or not acl.isLevel(newLevelId) then
        output.serverConsole("usage: acl copypermissions [id] [newid]")

        return true
    end

    acl.copyLevelPermissions(levelId, newLevelId)

    output.serverConsole("copied permissions from "..levelId.." to "..newLevelId)
end

function commandAclRemoveLevelPermissions(levelId)
    levelId = tonumber(levelId)

    if not levelId or not acl.isLevel(levelId) then
        output.serverConsole("usage: acl removepermissions [id]")

        return true
    end

    acl.removeLevelPermissions(levelId)

    output.serverConsole("removed permissions from "..levelId)
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
        output.serverConsole("usage: acl [listlevels|addlevel|removelevel|relevel|listpermissions|isallowed|addpermission|removepermission|copypermissions|removepermission]")
    end
    
    return true
end
commands.addserver("acl", commandAcl, (config.get("g_standalone") == 0 or not db.isConnected()))
