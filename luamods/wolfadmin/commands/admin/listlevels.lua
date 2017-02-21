
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

local auth = require (wolfa_getLuaPath()..".auth.auth")

local commands = require (wolfa_getLuaPath()..".commands.commands")

local db = require (wolfa_getLuaPath()..".db.db")

local players = require (wolfa_getLuaPath()..".players.players")

local pagination = require (wolfa_getLuaPath()..".util.pagination")
local settings = require (wolfa_getLuaPath()..".util.settings")
local util = require (wolfa_getLuaPath()..".util.util")

function commandListLevels(clientId, command, victim, offset)
    local cmdClient

    if victim == nil then
        if settings.get("g_standalone") ~= 0 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistlevels usage: "..commands.getadmin("listlevels")["syntax"].."\";")

            return true
        else
            local fileName = et.trap_Cvar_Get("g_shrubbot")
            local fileDescriptor, fileLength = et.trap_FS_FOpenFile(fileName, et.FS_READ)
            local levelsCount = 0

            if fileLength == -1 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistlevels: ^9an error happened (shrubbot file could not be opened)\";")

                error("failed to open "..fileName.."\n")
            end

            local fileString = et.trap_FS_Read(fileDescriptor, fileLength)

            et.trap_FS_FCloseFile(fileDescriptor)

            for _, levelNr, levelName, levelFlags in string.gmatch(fileString, "(%[level%]\nlevel%s+=%s+(-?[0-9]+)\nname%s+=%s+([%a%d%p ]+)\nflags%s+=%s+([%a%d%p]*)\n\n)") do
                -- et.G_Print(string.format("%d %s %s\n", levelNr, levelName, levelFlags))

                local numberOfSpaces = 24 - string.len(util.removeColors(levelName))
                local spaces = string.rep(" ", numberOfSpaces)

                et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^7"..string.format("%5s", levelNr).." ^7"..spaces..levelName.." ^7"..levelFlags.."\";")

                levelsCount = levelsCount + 1
            end

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^dlistlevels: ^9"..levelsCount.." available levels (open console for the full list)\";")

            return true
        end
    elseif not db.isconnected() then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistlevels: ^9level history is disabled.\";")
        
        return true
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end
    
    if cmdClient == -1 or cmdClient == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistlevels: ^9no or multiple matches for '^7"..victim.."^9'.\";")
        
        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistlevels: ^9no connected player by that name or slot #\";")
        
        return true
    end
    
    local player = db.getplayer(players.getGUID(cmdClient))["id"]
    
    local count = db.getlevelscount(player)
    local limit, offset = pagination.calculate(count, 30, tonumber(offset))
    local levels = db.getlevels(player, limit, offset)
    
    if not (levels and #levels > 0) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistlevels: ^9there are no recorded levels for player ^7"..et.gentity_get(cmdClient, "pers.netname").."^9.\";")
    else
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dLevels for ^7"..et.gentity_get(cmdClient, "pers.netname").."^d:\";")
        for _, level in pairs(levels) do
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^f"..string.format("%4s", level["id"]).." ^7"..string.format("%-20s", util.removeColors(db.getlastalias(level["invoker_id"])["alias"])).." ^f"..os.date("%d/%m/%Y", level["datetime"]).." ^7"..level["level_id"].."\";")
        end
        
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9Showing results ^7"..(offset + 1).." ^9- ^7"..(offset + limit).." ^9of ^7"..count.."^9.\";")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^dlistlevels: ^9recorded levels for ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9were printed to the console.\";")
    end
    
    return true
end
commands.addadmin("listlevels", commandListLevels, auth.PERM_LISTLEVELS, "display all levels on the server", (not db.isconnected() and nil or "^9(^3name|slot#^9) ^9(^hoffset^9)"))
