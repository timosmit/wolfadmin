
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

require (wolfa_getLuaPath()..".util.debug")

local auth = require (wolfa_getLuaPath()..".auth.auth")

local players = require (wolfa_getLuaPath()..".players.players")

local util = require (wolfa_getLuaPath()..".util.util")
local events = require (wolfa_getLuaPath()..".util.events")
local files = require (wolfa_getLuaPath()..".util.files")
local settings = require (wolfa_getLuaPath()..".util.settings")

local commands = {}

local clientcmds = {}
local servercmds = {}
local admincmds = {}

function commands.getclient(command)
    if command then
        return clientcmds[command]
    end
    
    return clientcmds
end

function commands.getserver(command)
    if command then
        return servercmds[command]
    end
    
    return servercmds
end

function commands.getadmin(command)
    if command then
        return admincmds[command]
    end
    
    return admincmds
end

function commands.addclient(command, func, flag, syntax, chat, disabled)
    if disabled then
        return
    end

    clientcmds[command] = {
        ["function"] = func,
        ["flag"] = flag,
        ["syntax"] = "^7"..command..(syntax and " "..syntax or ""),
        ["chat"] = chat,
    }
end

function commands.addserver(command, func, disabled)
    if disabled then
        return
    end

    servercmds[command] = {
        ["function"] = func,
    }
end

function commands.addadmin(command, func, flag, help, syntax, hidden, disabled)
    if disabled then
        return
    end

    admincmds[command] = {
        ["function"] = func,
        ["flag"] = flag,
        ["help"] = help or "N/A",
        ["syntax"] = "^2!"..command..(syntax and " "..syntax or ""),
        ["hidden"] = hidden
    }
end

function commands.loadFiles(dir)
    local amount = 0
    local files = files.ls("commands/"..dir.."/")
    
    for _, file in pairs(files) do
        if string.match(string.lower(file), "^[a-z]+%.lua$") then
            require (wolfa_getLuaPath()..".commands."..dir.."."..string.sub(file, 1, string.len(file) - 4))
            
            amount = amount + 1
        end
    end
    
    return amount
end

function commands.load()
    local functionStart = et.trap_Milliseconds()
    
    local clientAmount = commands.loadFiles("client")
    local serverAmount = commands.loadFiles("server")
    local adminAmount = commands.loadFiles("admin")
    
    local totalAmount = clientAmount + serverAmount + adminAmount
    
    outputDebug("commands.load(): "..totalAmount.." entries loaded in "..et.trap_Milliseconds() - functionStart.." ms")
    
    return totalAmount
end

function commands.log(clientId, command, cmdArguments)
    local victimId
    
    -- funny, NoQuarter actually checks EACH command for a victim (so even 
    -- !help [playername] will log a victimname). so why not do the same :D
    -- todo: do this more nicely, maybe change .register() function
    if cmdArguments[1] then
        local cmdClient
        
        if tonumber(cmdArguments[1]) == nil or tonumber(cmdArguments[1]) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
            cmdClient = et.ClientNumberFromString(cmdArguments[1])
        else
            cmdClient = tonumber(cmdArguments[1])
        end
        
        if cmdClient ~= -1 and et.gentity_get(cmdClient, "pers.netname") then
            victimId = cmdClient
        end
    end

    local fileDescriptor = files.open(settings.get("g_logAdmin"), et.FS_APPEND)

    local logLine

    local clientGUID = clientId and players.getGUID(clientId) or "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    local clientName = clientId and players.getName(clientId) or "console"
    local clientFlags = ""

    if settings.get("g_standalone") == 1 then
        if victimId then
            local victimName = players.getName(victimId)
            logLine = string.format("[%s] %s: %s: %s: %s: \"%s\"\n", os.date("%Y-%m-%d %H:%M:%S"), clientGUID, clientName, command, victimName, table.concat(cmdArguments, " ", 2))
        else
            logLine = string.format("[%s] %s: %s: %s: \"%s\"\n", os.date("%Y-%m-%d %H:%M:%S"), clientGUID, clientName, command, table.concat(cmdArguments, " "))
        end
    else
        local levelTime = et.trap_Milliseconds() / 1000

        if victimId then
            local victimName = players.getName(victimId)
            logLine = string.format("%3i:%02f: %i: %s: %s: %s: %s: %s: %s: \"%s\"\n", math.floor(levelTime / 60), (levelTime % 60), clientId, clientGUID, clientName, clientFlags, command, victimId, victimName, table.concat(cmdArguments, " ", 2))
        else
            logLine = string.format("%3i:%02f: %i: %s: %s: %s: %s: \"%s\"\n", math.floor(levelTime / 60), (levelTime % 60), clientId, clientGUID, clientName, clientFlags, command, table.concat(cmdArguments, " "))
        end
    end

    et.trap_FS_Write(logLine, string.len(logLine), fileDescriptor)

    et.trap_FS_FCloseFile(fileDescriptor)
end

function commands.onGameInit()
    commands.load()
end
events.handle("onGameInit", commands.onGameInit)

function commands.onServerCommand(cmdText)
    local wolfCmd = string.lower(cmdText)
    local cmdArguments = {}
    
    if servercmds[wolfCmd] and servercmds[wolfCmd]["function"] then
        for i = 1, et.trap_Argc() - 1 do
            cmdArguments[i] = et.trap_Argv(i)
        end

        return servercmds[wolfCmd]["function"](cmdArguments) and 1 or 0
    end

    local shrubCmd = cmdText
    
    if string.find(cmdText, "!") == 1 then
        shrubCmd = string.lower(string.sub(cmdText, 2, string.len(cmdText)))
    end
    
    if admincmds[shrubCmd] and admincmds[shrubCmd]["function"] and admincmds[shrubCmd]["flag"] then
        for i = 1, et.trap_Argc() - 1 do
            cmdArguments[i] = et.trap_Argv(i)
        end

        if not admincmds[shrubCmd]["hidden"] then
            commands.log(-1337, shrubCmd, cmdArguments)
        end

        return admincmds[shrubCmd]["function"](-1337, cmdArguments) and 1 or 0
    end
end
events.handle("onServerCommand", commands.onServerCommand)

function commands.onClientCommand(clientId, cmdText)
    local wolfCmd = string.lower(cmdText)
    local cmdArguments = {}

    -- mod-specific or custom commands loading
    -- syntax: command arg1 arg2 ... argN
    if clientcmds[wolfCmd] and clientcmds[wolfCmd]["function"] and clientcmds[wolfCmd]["flag"] then
        if clientcmds[wolfCmd]["flag"] == "" or auth.isPlayerAllowed(clientId, clientcmds[wolfCmd]["flag"]) then
            for i = 1, et.trap_Argc() - 1 do
                cmdArguments[i] = et.trap_Argv(i)
            end

            local isFinished = clientcmds[wolfCmd]["function"](clientId, cmdArguments)

            if isFinished ~= nil then
                return isFinished and 1 or 0
            end
        end
    end

    -- client cmds
    -- syntax: say or say_*
    local clientCmd = nil

    if (wolfCmd == "say" or wolfCmd == "say_team" or wolfCmd == "say_buddy") and string.find(et.trap_Argv(1), "/") == 1 then
        cmdArguments = util.split(et.trap_Argv(1), " ")
        
        -- say "/command arg1 arg2 argN"
        if #cmdArguments > 1 then
            clientCmd = string.sub(cmdArguments[1], 2, string.len(cmdArguments[1]))
            table.remove(cmdArguments, 1)
        -- say /command arg1 arg2 argN
        else
            clientCmd = string.sub(et.trap_Argv(1), 2, string.len(et.trap_Argv(1)))
            
            for i = 2, et.trap_Argc() - 1 do
                cmdArguments[(i - 1)] = et.trap_Argv(i)
            end
            if cmdArguments[1] == et.trap_Argv(1) then table.remove(cmdArguments, 1) end
        end
    end

    -- handle client cmds
    if clientCmd then
        clientCmd = string.lower(clientCmd)
        
        if clientcmds[clientCmd] and clientcmds[clientCmd]["function"] and clientcmds[clientCmd]["chat"] then
            if clientcmds[clientCmd]["flag"] == "" or auth.isPlayerAllowed(clientId, clientcmds[clientCmd]["flag"]) then
                return clientcmds[clientCmd]["function"](clientId, cmdArguments) and 1 or 0
            end
        end
    end
    
    -- shrub cmds
    local shrubCmd = nil
    
    -- syntax: say or say_*
    if (wolfCmd == "say" or wolfCmd == "say_team" or wolfCmd == "say_buddy") and string.find(et.trap_Argv(1), "!") == 1 then
        cmdArguments = util.split(et.trap_Argv(1), " ")
        
        -- syntax: say "!command arg1 arg2 ... argN"
        if #cmdArguments > 1 then
            shrubCmd = string.sub(cmdArguments[1], 2, string.len(cmdArguments[1]))

            table.remove(cmdArguments, 1)
        -- syntax: say !command arg1 arg2 ... argN
        else
            shrubCmd = string.sub(et.trap_Argv(1), 2, string.len(et.trap_Argv(1)))
            
            for i = 2, et.trap_Argc() - 1 do
                cmdArguments[(i - 1)] = et.trap_Argv(i)
            end
            if cmdArguments[1] == et.trap_Argv(1) then table.remove(cmdArguments, 1) end
        end
    -- syntax: !command arg1 arg2 ... argN
    elseif string.find(wolfCmd, "!") == 1 then
        shrubCmd = string.sub(wolfCmd, 2, string.len(wolfCmd))
        
        for i = 1, et.trap_Argc() - 1 do
            cmdArguments[i] = et.trap_Argv(i)
        end
    end

    -- handle shrub commands
    if shrubCmd then
        shrubCmd = string.lower(shrubCmd)
        
        if admincmds[shrubCmd] and admincmds[shrubCmd]["function"] and admincmds[shrubCmd]["flag"] then
            if wolfCmd == "say" or (((wolfCmd == "say_team" and et.gentity_get(cmdClient, "sess.sessionTeam") ~= et.TEAM_SPECTATORS) or wolfCmd == "say_buddy") and auth.isPlayerAllowed(clientId, auth.PERM_TEAMCMDS)) or (wolfCmd == "!"..shrubCmd and auth.isPlayerAllowed(clientId, auth.PERM_SILENTCMDS)) then
                if admincmds[shrubCmd]["flag"] ~= "" and auth.isPlayerAllowed(clientId, admincmds[shrubCmd]["flag"]) then
                    local isFinished = admincmds[shrubCmd]["function"](clientId, cmdArguments)
                    
                    if not admincmds[shrubCmd]["hidden"] then
                        commands.log(clientId, shrubCmd, cmdArguments)
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
events.handle("onClientCommand", commands.onClientCommand)

return commands
