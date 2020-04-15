
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

local players = wolfa_requireModule("players.players")
local config = wolfa_requireModule("config.config")
local files = wolfa_requireModule("util.files")

local logs = {}

function logs.writeChat(clientId, type, ...)
    if config.get("g_logChat") == "" then
        return
    end

    if not files.exists(config.get("g_logChat")) then
        local fileDescriptor, _ = et.trap_FS_FOpenFile(config.get("g_logChat"), et.FS_WRITE)

        et.trap_FS_FCloseFile(fileDescriptor)
    end

    local fileDescriptor, _ = et.trap_FS_FOpenFile(config.get("g_logChat"), et.FS_APPEND)

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
    if config.get("g_logAdmin") == "" then
        return
    end

    if not files.exists(config.get("g_logAdmin")) then
        local fileDescriptor, _ = et.trap_FS_FOpenFile(config.get("g_logAdmin"), et.FS_WRITE)

        et.trap_FS_FCloseFile(fileDescriptor)
    end

    local fileDescriptor, _ = et.trap_FS_FOpenFile(config.get("g_logAdmin"), et.FS_APPEND)

    local logLine

    local clientGUID = clientId and players.getGUID(clientId) or "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    local clientName = clientId and players.getName(clientId) or "console"
    local clientFlags = ""
    local args = table.concat({...}, " ")

    if config.get("g_standalone") ~= 0 then
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
