
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015 Timo 'Timothy' Smit

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

require "luascripts.wolfadmin.util.debug"

local util = require "luascripts.wolfadmin.util.util"
local events = require "luascripts.wolfadmin.util.events"
local files = require "luascripts.wolfadmin.util.files"
local admin = require "luascripts.wolfadmin.admin.admin"
local stats = require "luascripts.wolfadmin.players.stats"

local commands = {}

-- available shrubflags: lqyFHY
local data = {}

function commands.get(command)
    if command then
        return data[command]
    end
    
    return data
end

function commands.register(command, func, flag, help, syntax, hidden)
    data[command] = {
        ["function"] = func, 
        ["flag"] = flag,
        ["help"] = help or "N/A",
        ["syntax"] = "^2!"..command..(syntax and " "..syntax or ""),
        ["hidden"] = hidden
    }
end

function commands.load()
    local functionStart = et.trap_Milliseconds()
    local files = files.ls("commands/")
    local amount = 0
    
    for _, file in pairs(files) do
        if string.match(string.lower(file), "^[a-z]+%.lua$") then
            require("luascripts/wolfadmin/commands/"..string.sub(file, 1, string.len(file) - 4))
            
            amount = amount + 1
        end
    end
    
    outputDebug("commands.load(): "..amount.." entries loaded in "..et.trap_Milliseconds() - functionStart.." ms")
    
    return amount
end

function commands.log(clientId, command, cmdArguments)
    local functionStart = et.trap_Milliseconds()
    local fileDescriptor = files.open(et.trap_Cvar_Get("g_logAdmin"), et.FS_APPEND)
    
    local logLine
    local levelTime = wolfa_getLevelTime() / 1000
    
    local clientGUID = clientId and stats.get(clientId, "playerGUID") or "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    local clientName = clientId and stats.get(clientId, "playerName") or "console"
    local clientFlags = ""
    
    local victimId
    
    -- funny, NoQuarter actually checks EACH command for a victim (so even 
    -- !help [playername] will log a victimname). so why not do the same :D
    -- todo: do this more nicely, maybe change .register() function
    if cmdArguments[1] then
        local cmdClient
        
        if tonumber(cmdArguments[1]) == nil then
            cmdClient = et.ClientNumberFromString(cmdArguments[1])
        else
            cmdClient = tonumber(cmdArguments[1])
        end
        
        if cmdClient ~= -1 and et.gentity_get(cmdClient, "pers.netname") then
            victimId = cmdClient
        end
    end
    
    if victimId then
        local victimName = stats.get(victimId, "playerName")
        logLine = string.format("%3i:%02i: %i: %s: %s: %s: %s: %s: %s: \"%s\"\n", math.floor(levelTime / 60), (levelTime % 60), clientId, clientGUID, clientName, clientFlags, command, victimId, victimName, table.concat(cmdArguments, " ", 2))
    else
        logLine = string.format("%3i:%02i: %i: %s: %s: %s: %s: \"%s\"\n", math.floor(levelTime / 60), (levelTime % 60), clientId, clientGUID, clientName, clientFlags, command, table.concat(cmdArguments, " "))
    end
    
    et.trap_FS_Write(logLine, string.len(logLine), fileDescriptor)
    
    et.trap_FS_FCloseFile(fileDescriptor)
end

function commands.oninit()
    commands.load()
end
events.handle("onGameInit", commands.oninit)

function commands.onservercommand(cmdText)
    -- this if statement definitely sucks.
    if string.lower(et.trap_Argv(0)) == "csay" and et.trap_Argc() >= 3 then
        local clientId = tonumber(et.trap_Argv(1))
        
        if clientId and clientId ~= -1337 then -- -1337 because -1 is a magic number/broadcasted to all clients
            et.trap_SendServerCommand(clientId, "print \""..et.trap_Argv(2).."\n\";")
        elseif clientId then
            et.G_Print(util.removeColors(et.trap_Argv(2)).."\n")
        end
    elseif string.lower(et.trap_Argv(0)) == "ccpm" and et.trap_Argc() >= 3 then
        local clientId = tonumber(et.trap_Argv(1))
        
        if clientId and clientId ~= -1337 then -- -1337 because -1 is a magic number/broadcasted to all clients
            et.trap_SendServerCommand(clientId, "cpm \""..et.trap_Argv(2).."\";")
        elseif clientId then
            et.G_Print(util.removeColors(et.trap_Argv(2)).."\n")
        end
    elseif string.lower(et.trap_Argv(0)) == "cchat" and et.trap_Argc() >= 3 then
        local clientId = tonumber(et.trap_Argv(1))
        
        if clientId and clientId ~= -1337 then -- -1337 because -1 is a magic number/broadcasted to all clients
            et.trap_SendServerCommand(clientId, "chat \""..et.trap_Argv(2).."\";")
        elseif clientId then
            et.G_Print(util.removeColors(et.trap_Argv(2)).."\n")
        end
    elseif string.lower(et.trap_Argv(0)) == "cannounce" and et.trap_Argc() >= 3 then
        local clientId = tonumber(et.trap_Argv(1))
        
        if clientId and clientId ~= -1337 then -- -1337 because -1 is a magic number/broadcasted to all clients
            et.trap_SendServerCommand(clientId, "announce \""..et.trap_Argv(2).."\";")
        elseif clientId then
            et.G_Print(util.removeColors(et.trap_Argv(2)).."\n")
        end
    elseif string.lower(et.trap_Argv(0)) == "cmusic" and et.trap_Argc() >= 3 then
        local clientId = tonumber(et.trap_Argv(1))
        
        if clientId and clientId ~= -1337 then -- -1337 because -1 is a magic number/broadcasted to all clients
            et.trap_SendServerCommand(clientId, "mu_play \""..et.trap_Argv(2).."\";")
        elseif clientId then
            et.G_Print(util.removeColors(et.trap_Argv(2)).."\n")
        end
    elseif et.trap_Argv(0) == "cmdclient" then
        local cmd = et.trap_Argv(1)
        local clientId = tonumber(et.trap_Argv(2))
        
        et.trap_SendServerCommand(clientId, cmd.." \""..et.trap_Argv(3).."\n\";")
    else
        -- TODO: merge with commands.onclientcommand
        local shrubCmd = cmdText
        local shrubArgumentsOffset = 1
        local shrubArguments = {}
        
        if string.find(cmdText, "!") == 1 then
            shrubCmd = string.lower(string.sub(cmdText, 2, string.len(cmdText)))
        end
        
        if data[shrubCmd] and data[shrubCmd]["function"] and data[shrubCmd]["flag"] then
            for i = 1, et.trap_Argc() - shrubArgumentsOffset do
                shrubArguments[i] = et.trap_Argv(i + shrubArgumentsOffset - 1)
            end
            
            data[shrubCmd]["function"](-1337, shrubArguments)
            
            if not data[shrubCmd]["hidden"] then
                commands.log(-1, shrubCmd, shrubArguments)
            end
        end
    end
end
events.handle("onServerCommand", commands.onservercommand)

function commands.onclientcommand(clientId, cmdText)
    local wolfCmd = string.lower(et.trap_Argv(0))
    local shrubCmd = nil
    local shrubArguments = {}
    local shrubArgumentsOffset = 0
    
    if wolfCmd == "m" or wolfCmd == "pm" then
        if et.trap_Argc() > 2 then
            local cmdClient
            
            if tonumber(et.trap_Argv(1)) == nil then
                cmdClient = et.ClientNumberFromString(et.trap_Argv(1))
            else
                cmdClient = tonumber(et.trap_Argv(1))
            end
            
            if cmdClient ~= -1 and et.gentity_get(cmdClient, "pers.netname") then
                stats.set(cmdClient, "lastMessageFrom", clientId)
                
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..cmdClient.." \"^9reply: ^7r [^2message^7]\";")
            end
        end
    elseif wolfCmd == "r" then
        if et.trap_Argc() == 1 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9usage: ^7"..wolfCmd.." [^2message^7]\";")
        else
            local recipient = stats.get(clientId, "lastMessageFrom")
            
            if et.gentity_get(recipient, "pers.netname") then
                local message = {}
                
                for i = 1, et.trap_Argc() - 1 do
                    message[i] = et.trap_Argv(i)
                end
                
                stats.set(recipient, "lastMessageFrom", clientId)
                
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..recipient.." \"^7"..et.gentity_get(clientId, "pers.netname").."^7 -> "..recipient.." (1 recipients): ^3"..table.concat(message, " ").."\";")
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..recipient.." \"^9reply: ^7r [^2message^7]\";")
            end
        end
        
        return 1
    elseif wolfCmd == "adminchat" or wolfCmd == "ac" then
        if et.G_shrubbot_permission(clientId, "~") == 1 then
            if et.trap_Argc() == 1 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9usage: ^7"..wolfCmd.." [^2message^7]\";")
            else
                local message = {}
                local recipients = {}
                
                for i = 1, et.trap_Argc() - 1 do
                    message[i] = et.trap_Argv(i)
                end
                
                for playerId = 0, et.trap_Cvar_Get("sv_maxclients") - 1 do
                    if wolfa_isPlayer(playerId) and et.G_shrubbot_permission(playerId, "~") == 1 then
                        table.insert(recipients, playerId) 
                    end
                end
                
                for _, recipient in ipairs(recipients) do
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..recipient.." \"^7"..et.gentity_get(clientId, "pers.netname").."^7 -> adminchat ("..#recipients.." recipients): ^a"..table.concat(message, " ").."\";")
                    et.trap_SendServerCommand(recipient, "cp \"^jadminchat message from ^7"..et.gentity_get(clientId, "pers.netname"))
                end
                
                et.G_LogPrint("adminchat: "..et.gentity_get(clientId, "pers.netname")..": "..table.concat(message, " ").."\n")
            end
        end
        
        return 1
    elseif wolfCmd == "wolfadmin" then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^3This server is running ^7Wolf^1Admin ^7"..wolfa_getVersion().." ^3("..wolfa_getRelease().."^3)\";")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"\";")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^3Created by ^7Timo '^aTimo^qthy^7' ^7Smit^3. More info on\";")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"    ^7http://dev.timosmit.com/wolfadmin/\";")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"\";")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^3Thanks for using!\";")
        
        return 1
    elseif wolfCmd == "team" then
        if admin.isPlayerLocked(clientId) then
            local clientTeam = tonumber(et.gentity_get(clientId, "sess.sessionTeam"))
            local teamName = util.getTeamName(clientTeam)
            local teamColor = util.getTeamColor(clientTeam)
            
            et.trap_SendServerCommand(clientId, "cp \"^7You are locked to the "..teamColor..teamName.." ^7team")
            
            return 1
        end
        
        stats.set(clientId, "currentKillSpree", 0)
        stats.set(clientId, "currentDeathSpree", 0)
        stats.set(clientId, "currentReviveSpree", 0)
    elseif wolfCmd == "callvote" then
        local voteArguments = {}
        for i = 2, et.trap_Argc() - 1 do
            voteArguments[(i - 1)] = et.trap_Argv(i)
        end
        
        return events.trigger("onCallvote", clientId, et.trap_Argv(1), voteArguments)
    elseif wolfCmd == "say" or wolfCmd == "say_team" or wolfCmd == "say_teamnl" or wolfCmd == "say_buddy" then
        if et.gentity_get(clientId, "sess.muted") == 1 then
            et.trap_SendServerCommand(clientId, "cp \"^1You are muted\"")
            
            return 1
        end
    elseif wolfCmd == "vsay" or wolfCmd == "vsay_team" then
        if admin.isVoiceMuted(clientId) then
            et.trap_SendServerCommand(clientId, "cp \"^1You are voicemuted\"")
            
            return 1
        end
    end
    
    if (wolfCmd == "say" or wolfCmd == "say_team" or wolfCmd == "say_buddy") and string.find(et.trap_Argv(1), "!") == 1 then
        shrubArguments = util.split(et.trap_Argv(1), " ")
        if #shrubArguments > 1 then
            shrubCmd = string.sub(shrubArguments[1], 2, string.len(shrubArguments[1]))
            table.remove(shrubArguments, 1)
        else
            shrubCmd = string.sub(et.trap_Argv(1), 2, string.len(et.trap_Argv(1)))
            shrubArgumentsOffset = 2
            
            for i = 1, et.trap_Argc() - shrubArgumentsOffset do
                shrubArguments[i] = et.trap_Argv(i + shrubArgumentsOffset - 1)
            end
            if shrubArguments[1] == et.trap_Argv(1) then table.remove(shrubArguments, 1) end
        end
    elseif string.find(wolfCmd, "!") == 1 then
        shrubCmd = string.sub(wolfCmd, 2, string.len(wolfCmd))
        shrubArgumentsOffset = 1
        
        for i = 1, et.trap_Argc() - shrubArgumentsOffset do
            shrubArguments[i] = et.trap_Argv(i + shrubArgumentsOffset - 1)
        end
    end
    
    if shrubCmd then
        shrubCmd = string.lower(shrubCmd)
        
        if data[shrubCmd] and data[shrubCmd]["function"] and data[shrubCmd]["flag"] then
            if wolfCmd == "say" or (((wolfCmd == "say_team" and et.gentity_get(cmdClient, "sess.sessionTeam") ~= et.TEAM_SPECTATORS) or wolfCmd == "say_buddy") and et.G_shrubbot_permission(clientId, "9") == 1) or (wolfCmd == "!"..shrubCmd and et.G_shrubbot_permission(clientId, "3") == 1) then
                if data[shrubCmd]["flag"] ~= "" and et.G_shrubbot_permission(clientId, data[shrubCmd]["flag"]) == 1 then
                    local isFinished = data[shrubCmd]["function"](clientId, shrubArguments)
                    
                    if not data[shrubCmd]["hidden"] then
                        commands.log(clientId, shrubCmd, shrubArguments)
                    end
                    
                    if isFinished and "!"..shrubCmd == wolfCmd then -- silent command via console, removes "unknown command" message
                        return 1
                    end
                else
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \""..shrubCmd..": permission denied\";")
                end
            end
        end
    end
    
    return 0
end
events.handle("onClientCommand", commands.onclientcommand)

return commands