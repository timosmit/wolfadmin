
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

local shrubbot = {}

local players = require (wolfa_getLuaPath()..".players.players")

local flags

function shrubbot.loadFlags(mod)
    flags = require (wolfa_getLuaPath()..".auth.shrubbot."..mod)
end

function shrubbot.isPlayerAllowed(clientId, permission)
    if not flags[permission] then
        outputDebug("shrubbot.isPlayerAllowed requested for unknown permission ("..tostring(permission)..")", 3)

        return false
    end

    return et.G_shrubbot_permission(clientId, flags[permission]) == 1
end

function shrubbot.getPlayerLevel(clientId)
    return et.G_shrubbot_level(clientId)
end

function shrubbot.addPlayerPermission(clientId, permission)
    local fileName = et.trap_Cvar_Get("g_shrubbot")
    local fileDescriptor, fileLength = et.trap_FS_FOpenFile(fileName, et.FS_READ)

    if fileLength == -1 then
        error("failed to open "..fileName.."\n")
    end

    local fileString = et.trap_FS_Read(fileDescriptor, fileLength)

    et.trap_FS_FCloseFile(fileDescriptor)

    for _, adminName, adminGUID, adminLevel, adminFlags in string.gmatch(fileString, "(%[admin%]\nname%s+=%s+([%a%d%p]+)\nguid%s+=%s+([%u%d]+)\nlevel%s+=%s+([%d]+)\nflags%s+=%s+([%a%d%p]*)\n\n)") do
        -- et.G_Print(string.format("%s %s %d %s\n", adminName, adminGUID, adminLevel, adminFlags))

        if players.getGUID(clientId) == adminGUID then
            if not auth.isPlayerAllowed(clientId, flags[permission]) then
                adminFlags = adminFlags.."+"..flags[permission]
            end

            local adminNameEscaped = string.gsub(adminName, "([%*%+%-%?%^%$%%%[%]%(%)%.])", "%%%1") -- fix for special captures
            fileString = string.gsub(fileString, "%[admin%]\nname%s+=%s+"..adminNameEscaped.."\nguid%s+=%s+"..adminGUID.."\nlevel%s+=%s+"..adminLevel.."\nflags%s+=%s+([%a%d%p]*)\n\n", "[admin]\nname    = "..adminName.."\nguid    = "..adminGUID.."\nlevel   = "..adminLevel.."\nflags   = "..adminFlags.."\n\n")

            break
        end
    end

    local fileDescriptor, _ = et.trap_FS_FOpenFile(fileName, et.FS_WRITE)

    local writeCount = et.trap_FS_Write(fileString, string.len(fileString), fileDescriptor)

    if not writeCount or writeCount < 1 then
        error("failed to write "..fileName.."\n")
    end

    et.trap_FS_FCloseFile(fileDescriptor)

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "readconfig;")
end

function shrubbot.removePlayerPermission(clientId, permission)
    local fileName = et.trap_Cvar_Get("g_shrubbot")
    local fileDescriptor, fileLength = et.trap_FS_FOpenFile(fileName, et.FS_READ)

    if fileLength == -1 then
        error("failed to open "..fileName.."\n")
    end

    local fileString = et.trap_FS_Read(fileDescriptor, fileLength)

    et.trap_FS_FCloseFile(fileDescriptor)

    for _, adminName, adminGUID, adminLevel, adminFlags in string.gmatch(fileString, "(%[admin%]\nname%s+=%s+([%a%d%p]+)\nguid%s+=%s+([%u%d]+)\nlevel%s+=%s+([%d]+)\nflags%s+=%s+([%a%d%p]*)\n\n)") do
        -- et.G_Print(string.format("%s %s %d %s\n", adminName, adminGUID, adminLevel, adminFlags))

        if players.getGUID(clientId) == adminGUID then
            if string.find(adminFlags, "+"..flags[permission]) then
                adminFlags = string.gsub(adminFlags, "+"..flags[permission], "")
            elseif string.find(adminFlags, flags[permission]) then
                adminFlags = string.gsub(adminFlags, flags[permission], "")
            else
                adminFlags = adminFlags.."-"..flags[permission]
            end

            local adminNameEscaped = string.gsub(adminName, "([%*%+%-%?%^%$%%%[%]%(%)%.])", "%%%1") -- fix for special captures
            fileString = string.gsub(fileString, "%[admin%]\nname%s+=%s+"..adminNameEscaped.."\nguid%s+=%s+"..adminGUID.."\nlevel%s+=%s+"..adminLevel.."\nflags%s+=%s+([%a%d%p]*)\n\n", "[admin]\nname    = "..adminName.."\nguid    = "..adminGUID.."\nlevel   = "..adminLevel.."\nflags   = "..adminFlags.."\n\n")

            break
        end
    end

    local fileDescriptor, _ = et.trap_FS_FOpenFile(fileName, et.FS_WRITE)

    local writeCount = et.trap_FS_Write(fileString, string.len(fileString), fileDescriptor)

    if not writeCount or writeCount < 1 then
        error("failed to write "..fileName.."\n")
    end

    et.trap_FS_FCloseFile(fileDescriptor)

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "readconfig;")
end

return shrubbot
