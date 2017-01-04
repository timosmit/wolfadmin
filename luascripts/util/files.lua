
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

local util = require "luascripts.wolfadmin.util.util"
local settings = require "luascripts.wolfadmin.util.settings"

local files = {}

function files.ls(directory)
    local platform, command = settings.get("sv_os"), ""
    local entries = {}
    
    if platform == "unix" then
        command = 'ls -1 "'..wolfa_getBasePath()..directory..'"'
    elseif platform == "windows" then
        command = 'dir "'..wolfa_getBasePath()..directory..'" /b'
    end
    
    for filename in io.popen(command):lines() do
        table.insert(entries, filename)
    end
    
    return entries
end

function files.create(fileName)
    local fileDescriptor, fileLength = et.trap_FS_FOpenFile(fileName, et.FS_WRITE)
    
    return fileDescriptor, fileLength
end

function files.open(fileName, fileMode, fileCreate)
    local fileDescriptor, fileLength = et.trap_FS_FOpenFile(fileName, fileMode)
    
    if fileLength == -1 then
        if not fileCreate then
            error("failed to open "..fileName.."\n")
        end
        
        fileDescriptor, fileLength = files.create(fileName)
    end
    
    outputDebug("util.files.open(): file "..fileName.." opened")
    
    if fileMode == et.FS_READ then
        local fileString = et.trap_FS_Read(fileDescriptor, fileLength)
        
        et.trap_FS_FCloseFile(fileDescriptor)
        
        return fileString
    else
        return fileDescriptor
    end
    
    return false
end

function files.loadCFG(fileName, idExpr, fileCreate)
    local functionStart = et.trap_Milliseconds()
    local fileString = files.open(fileName, et.FS_READ, fileCreate)
    local arrayCount = 0
    local array = {}
    
    if not fileString then return 0, {} end
    
    local blockExpr = "%[("..idExpr..")%][\r\n]+(.-[\r\n]+)[\r\n]+"
    local attrExpr = "([a-z0-9_]+) += +(.-)[\r\n]+"

    for id, values in string.gmatch(fileString, blockExpr) do
        if not array[id] then array[id] = {} end
        
        local data = {}
        
        for k, v in string.gmatch(values, attrExpr) do
            data[k] = v
        end
        
        arrayCount = arrayCount + 1
        
        table.insert(array[id], data)
    end
    
    outputDebug("util.files.loadCFG(): "..arrayCount.." entries loaded in "..et.trap_Milliseconds() - functionStart.." ms")
    
    return arrayCount, array
end

function files.save(fileName, array)
    local functionStart = et.trap_Milliseconds()
    local fileDescriptor = files.open(fileName, et.FS_WRITE)
    local arrayCount = 0
    
    for id, subdata in pairs(array) do
        for _, data in pairs(subdata) do
            local blockId = "["..id.."]\n"
            et.trap_FS_Write(blockId, string.len(blockId), fileDescriptor)
            
            local maxKeyLength = 0
            
            for k, v in pairs(data) do
                maxKeyLength = math.max(maxKeyLength, string.len(k))
            end
            
            for k, v in pairs(data) do
                dataLine = string.format("%-"..maxKeyLength.."s = %s\n", k, v)
                et.trap_FS_Write(dataLine, string.len(dataLine), fileDescriptor)
            end
            
            et.trap_FS_Write("\n", string.len("\n"), fileDescriptor)
            
            arrayCount = arrayCount + 1
        end
    end
    
    et.trap_FS_FCloseFile(fileDescriptor)
    
    outputDebug("util.files.save(): "..arrayCount.." entries saved in "..et.trap_Milliseconds() - functionStart.." ms")
    
    return true
end

return files