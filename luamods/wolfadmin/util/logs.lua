
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

local players = require (wolfa_getLuaPath()..".players.players")

local files = require (wolfa_getLuaPath()..".util.files")
local settings = require (wolfa_getLuaPath()..".util.settings")

local logs = {}

function logs.writeChat(clientId, type, ...)
    local fileDescriptor = files.open(settings.get("g_logChat"), et.FS_APPEND)

    local logLine

    local clientGUID = clientId and players.getGUID(clientId) or "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    local clientName = clientId and players.getName(clientId) or "console"

    if type == "priv" then
        local args = {...}
        local recipientName = players.getName(args[1])

        logLine = string.format("[%s] %s: %s: %s: %s: \"%s\"\n", os.date("%Y-%m-%d %H:%M:%S"), clientGUID, string.upper(type), clientName, recipientName, table.concat({...}, " ", 2))
    else
        logLine = string.format("[%s] %s: %s: %s: \"%s\"\n", os.date("%Y-%m-%d %H:%M:%S"), clientGUID, string.upper(type), clientName, table.concat({...}, " "))
    end

    et.trap_FS_Write(logLine, string.len(logLine), fileDescriptor)

    et.trap_FS_FCloseFile(fileDescriptor)
end

function logs.writeAdmin(clientId, command, victimId, ...)
    local fileDescriptor = files.open(settings.get("g_logAdmin"), et.FS_APPEND)

    local logLine

    local clientGUID = clientId and players.getGUID(clientId) or "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    local clientName = clientId and players.getName(clientId) or "console"
    local clientFlags = ""
    local args = table.concat({...}, " ")

    if settings.get("g_standalone") == 1 then
        if victimId then
            local victimName = players.getName(victimId)
            logLine = string.format("[%s] %s: %s: %s: %s: \"%s\"\n", os.date("%Y-%m-%d %H:%M:%S"), clientGUID, clientName, command, victimName, args)
        else
            logLine = string.format("[%s] %s: %s: %s: \"%s\"\n", os.date("%Y-%m-%d %H:%M:%S"), clientGUID, clientName, command, args)
        end
    else
        local levelTime = et.trap_Milliseconds() / 1000

        if victimId then
            local victimName = players.getName(victimId)
            logLine = string.format("%3i:%02f: %i: %s: %s: %s: %s: %s: %s: \"%s\"\n", math.floor(levelTime / 60), (levelTime % 60), clientId, clientGUID, clientName, clientFlags, command, victimId, victimName, args)
        else
            logLine = string.format("%3i:%02f: %i: %s: %s: %s: %s: \"%s\"\n", math.floor(levelTime / 60), (levelTime % 60), clientId, clientGUID, clientName, clientFlags, command, args)
        end
    end

    et.trap_FS_Write(logLine, string.len(logLine), fileDescriptor)

    et.trap_FS_FCloseFile(fileDescriptor)
end

return logs
