
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

require "luascripts.wolfadmin.util.debug"

local admin = require "luascripts.wolfadmin.admin.admin"

local auth = require "luascripts.wolfadmin.auth.auth"

local teams = require "luascripts.wolfadmin.game.teams"

local players = require "luascripts.wolfadmin.players.players"

local util = require "luascripts.wolfadmin.util.util"
local events = require "luascripts.wolfadmin.util.events"
local files = require "luascripts.wolfadmin.util.files"

local commands = {}

-- available shrubflags: lqyFHY
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

function commands.addclient(command, func, flag, syntax, chat)
    clientcmds[command] = {
        ["function"] = func,
        ["flag"] = flag,
        ["syntax"] = "^7"..command..(syntax and " "..syntax or ""),
        ["chat"] = chat,
    }
end

function commands.addserver(command, func)
    servercmds[command] = {
        ["function"] = func,
    }
end

function commands.addadmin(command, func, flag, help, syntax, hidden)
    admincmds[command] = {
        ["function"] = func,
        ["flag"] = flag,
        ["help"] = help or "N/A",
        ["syntax"] = "^2!"..command..(syntax and " "..syntax or ""),
        ["hidden"] = hidden
    }
end

function commands.loadfiles(dir)
    local amount = 0
    local files = files.ls("commands/"..dir.."/")
    
    for _, file in pairs(files) do
        if string.match(string.lower(file), "^[a-z]+%.lua$") then
            require("luascripts/wolfadmin/commands/"..dir.."/"..string.sub(file, 1, string.len(file) - 4))
            
            amount = amount + 1
        end
    end
    
    return amount
end

function commands.load()
    local functionStart = et.trap_Milliseconds()
    
    local clientAmount = commands.loadfiles("client")
    local serverAmount = commands.loadfiles("server")
    local adminAmount = commands.loadfiles("admin")
    
    local totalAmount = clientAmount + serverAmount + adminAmount
    
    outputDebug("commands.load(): "..totalAmount.." entries loaded in "..et.trap_Milliseconds() - functionStart.." ms")
    
    return totalAmount
end

function commands.log(clientId, command, cmdArguments)
    local functionStart = et.trap_Milliseconds()
    local fileDescriptor = files.open(et.trap_Cvar_Get("g_logAdmin"), et.FS_APPEND)
    
    local logLine
    local levelTime = wolfa_getLevelTime() / 1000
    
    local clientGUID = clientId and players.getGUID(clientId) or "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    local clientName = clientId and players.getName(clientId) or "console"
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
        local victimName = players.getName(victimId)
        logLine = string.format("%3i:%02f: %i: %s: %s: %s: %s: %s: %s: \"%s\"\n", math.floor(levelTime / 60), (levelTime % 60), clientId, clientGUID, clientName, clientFlags, command, victimId, victimName, table.concat(cmdArguments, " ", 2))
    else
        logLine = string.format("%3i:%02f: %i: %s: %s: %s: %s: \"%s\"\n", math.floor(levelTime / 60), (levelTime % 60), clientId, clientGUID, clientName, clientFlags, command, table.concat(cmdArguments, " "))
    end
    
    et.trap_FS_Write(logLine, string.len(logLine), fileDescriptor)
    
    et.trap_FS_FCloseFile(fileDescriptor)
end

function commands.oninit()
    commands.load()
end
events.handle("onGameInit", commands.oninit)

function commands.onservercommand(cmdText)
    local wolfCmd = string.lower(et.trap_Argv(0))
    local cmdArguments = {}
    
    if servercmds[wolfCmd] and servercmds[wolfCmd]["function"] then
        for i = 1, et.trap_Argc() - 1 do
            cmdArguments[i] = et.trap_Argv(i)
        end
        
        return servercmds[wolfCmd]["function"](clientId, cmdArguments) and 1 or 0
    end
    
    -- TODO: merge with commands.onclientcommand
    local shrubCmd = cmdText
    
    if string.find(cmdText, "!") == 1 then
        shrubCmd = string.lower(string.sub(cmdText, 2, string.len(cmdText)))
    end
    
    if admincmds[shrubCmd] and admincmds[shrubCmd]["function"] and admincmds[shrubCmd]["flag"] then
        for i = 1, et.trap_Argc() - 1 do
            cmdArguments[i] = et.trap_Argv(i)
        end
        
        admincmds[shrubCmd]["function"](-1337, cmdArguments)
        
        if not admincmds[shrubCmd]["hidden"] then
            commands.log(-1337, shrubCmd, cmdArguments)
        end
    end
end
events.handle("onServerCommand", commands.onservercommand)

function commands.onclientcommand(clientId, cmdText)
    local wolfCmd = string.lower(et.trap_Argv(0))
    local cmdArguments = {}
    
    -- mod-specific or custom commands loading
    if clientcmds[wolfCmd] and clientcmds[wolfCmd]["function"] and clientcmds[wolfCmd]["flag"] then
        if clientcmds[wolfCmd]["flag"] == "" or auth.isallowed(clientId, clientcmds[wolfCmd]["flag"]) == 1 then        
            for i = 1, et.trap_Argc() - 1 do
                cmdArguments[i] = et.trap_Argv(i)
            end
            
            return clientcmds[wolfCmd]["function"](clientId, cmdArguments) and 1 or 0
        end
    end
    
    -- all Wolfenstein-related commands defined separately for now
    if wolfCmd == "team" then
        if players.isTeamLocked(clientId) then
            local clientTeam = tonumber(et.gentity_get(clientId, "sess.sessionTeam"))
            local teamName = util.getTeamName(clientTeam)
            local teamColor = util.getTeamColor(clientTeam)
            
            et.trap_SendServerCommand(clientId, "cp \"^7You are locked to the "..teamColor..teamName.." ^7team")
            
            return 1
        end

        local team = util.getTeamFromCode(et.trap_Argv(1))
        if teams.isLocked(team) then
            local teamName = util.getTeamName(team)
            local teamColor = util.getTeamColor(team)

            et.trap_SendServerCommand(clientId, "cp \""..teamColor..teamName.." ^7team is locked")

            return 1
        end
    elseif wolfCmd == "callvote" then
        local voteArguments = {}
        for i = 2, et.trap_Argc() - 1 do
            voteArguments[(i - 1)] = et.trap_Argv(i)
        end
        
        return events.trigger("onCallvote", clientId, et.trap_Argv(1), voteArguments)
    elseif wolfCmd == "say" or wolfCmd == "say_team" or wolfCmd == "say_teamnl" or wolfCmd == "say_buddy" then
        if players.isMuted(clientId, players.MUTE_CHAT) then
            et.trap_SendServerCommand(clientId, "cp \"^1You are muted\"")
            
            return 1
        end
    elseif wolfCmd == "vsay" or wolfCmd == "vsay_team" then
        if players.isMuted(clientId, players.MUTE_VOICE) then
            et.trap_SendServerCommand(clientId, "cp \"^1You are voicemuted\"")
            
            return 1
        end
    end
    
    -- client cmds
    local clientCmd = nil
    
    -- say and say_*
    if (wolfCmd == "say" or wolfCmd == "say_team" or wolfCmd == "say_buddy") and string.find(et.trap_Argv(1), "/") == 1 then
        cmdArguments = util.split(et.trap_Argv(1), " ")
        
        -- say "/command param1 param2 paramN"
        if #cmdArguments > 1 then
            clientCmd = string.sub(cmdArguments[1], 2, string.len(cmdArguments[1]))
            table.remove(cmdArguments, 1)
        -- say /command param1 param2 paramN
        else
            clientCmd = string.sub(et.trap_Argv(1), 2, string.len(et.trap_Argv(1)))
            
            for i = 2, et.trap_Argc() - 1 do
                cmdArguments[(i - 1)] = et.trap_Argv(i)
            end
            if cmdArguments[1] == et.trap_Argv(1) then table.remove(cmdArguments, 1) end
        end
    -- !command
    elseif string.find(wolfCmd, "!") == 1 then
        clientCmd = string.sub(wolfCmd, 2, string.len(wolfCmd))
        
        for i = 1, et.trap_Argc() - 1 do
            cmdArguments[i] = et.trap_Argv(i)
        end
    end
    
    if clientCmd then
        clientCmd = string.lower(clientCmd)
        
        if clientcmds[clientCmd] and clientcmds[clientCmd]["function"] and clientcmds[clientCmd]["chat"] then
            if clientcmds[clientCmd]["flag"] == "" or auth.isallowed(clientId, clientcmds[clientCmd]["flag"]) == 1 then
                return clientcmds[clientCmd]["function"](clientId, cmdArguments) and 1 or 0
            end
        end
    end
    
    -- shrub cmds
    local shrubCmd = nil
    
    -- say and say_*
    if (wolfCmd == "say" or wolfCmd == "say_team" or wolfCmd == "say_buddy") and string.find(et.trap_Argv(1), "!") == 1 then
        cmdArguments = util.split(et.trap_Argv(1), " ")
        
        -- say "!command param1 param2 paramN"
        if #cmdArguments > 1 then
            shrubCmd = string.sub(cmdArguments[1], 2, string.len(cmdArguments[1]))
            table.remove(cmdArguments, 1)
        -- say !command param1 param2 paramN
        else
            shrubCmd = string.sub(et.trap_Argv(1), 2, string.len(et.trap_Argv(1)))
            
            for i = 2, et.trap_Argc() - 1 do
                cmdArguments[(i - 1)] = et.trap_Argv(i)
            end
            if cmdArguments[1] == et.trap_Argv(1) then table.remove(cmdArguments, 1) end
        end
    -- !command
    elseif string.find(wolfCmd, "!") == 1 then
        shrubCmd = string.sub(wolfCmd, 2, string.len(wolfCmd))
        
        for i = 1, et.trap_Argc() - 1 do
            cmdArguments[i] = et.trap_Argv(i)
        end
    end
    
    if shrubCmd then
        shrubCmd = string.lower(shrubCmd)
        
        if admincmds[shrubCmd] and admincmds[shrubCmd]["function"] and admincmds[shrubCmd]["flag"] then
            if wolfCmd == "say" or (((wolfCmd == "say_team" and et.gentity_get(cmdClient, "sess.sessionTeam") ~= et.TEAM_SPECTATORS) or wolfCmd == "say_buddy") and auth.isallowed(clientId, auth.PERM_TEAMCMDS) == 1) or (wolfCmd == "!"..shrubCmd and auth.isallowed(clientId, auth.PERM_SILENTCMDS) == 1) then
                if admincmds[shrubCmd]["flag"] ~= "" and auth.isallowed(clientId, admincmds[shrubCmd]["flag"]) == 1 then
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
events.handle("onClientCommand", commands.onclientcommand)

return commands
