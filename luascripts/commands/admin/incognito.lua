
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

local commands = require "luascripts.wolfadmin.commands.commands"
local stats = require "luascripts.wolfadmin.players.stats"

function commandIncognito(clientId, cmdArguments)
    local fileName = et.trap_Cvar_Get("g_shrubbot")
    local functionStart = et.trap_Milliseconds()
    local fileDescriptor, fileLength = et.trap_FS_FOpenFile(fileName, et.FS_READ)
    
    if fileLength == -1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dincognito: ^9an error happened (shrubbot file could not be opened)\";")
        
        error("failed to open "..fileName.."\n")
    end
    
    local fileString = et.trap_FS_Read(fileDescriptor, fileLength)
    
    et.trap_FS_FCloseFile(fileDescriptor)
    
    for entry, adminName, adminGUID, adminLevel, adminFlags in string.gmatch(fileString, "(%[admin%]\nname%s+=%s+([%a%d%p]+)\nguid%s+=%s+([%u%d]+)\nlevel%s+=%s+([%d]+)\nflags%s+=%s+([%a%d%p]*)\n\n)") do
        -- et.G_Print(string.format("%s %s %d %s\n", adminName, adminGUID, adminLevel, adminFlags))
        
        if stats.get(clientId, "playerGUID") == adminGUID then
            if et.G_shrubbot_permission(clientId, "@") ~= 1 then
                adminFlags = adminFlags.."+@"
                
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^dincognito: ^9you are now playing incognito.\";")
            else
                if string.find(adminFlags, "+@") then
                    adminFlags = string.gsub(adminFlags, "+@", "")
                elseif string.find(adminFlags, "@") then
                    adminFlags = string.gsub(adminFlags, "@", "")
                else
                    adminFlags = adminFlags.."-@"
                end
                
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^dincognito: ^9you stopped playing incognito.\";")
            end
            
            local adminNameEscaped = string.gsub(adminName, "([%*%+%-%?%^%$%%%[%]%(%)%.])", "%%%1") -- fix for special captures
            fileString = string.gsub(fileString, "%[admin%]\nname%s+=%s+"..adminNameEscaped.."\nguid%s+=%s+"..adminGUID.."\nlevel%s+=%s+"..adminLevel.."\nflags%s+=%s+([%a%d%p]*)\n\n", "[admin]\nname    = "..adminName.."\nguid    = "..adminGUID.."\nlevel   = "..adminLevel.."\nflags   = "..adminFlags.."\n\n")            
            
            break
        end
    end
    
    local fileDescriptor, fileLength = et.trap_FS_FOpenFile(fileName, et.FS_WRITE)
    
    local writeCount = et.trap_FS_Write(fileString, string.len(fileString), fileDescriptor)
    
    if not writeCount or writeCount < 1 then
        error("failed to write "..fileName.."\n")
    end
    
    et.trap_FS_FCloseFile(fileDescriptor)
    
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "readconfig;")
    
    return true
end
commands.addadmin("incognito", commandIncognito, "s", "fakes your level to guest (no aka)")