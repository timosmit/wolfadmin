
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

local util = require (wolfa_getLuaPath()..".util.util")
local events = require (wolfa_getLuaPath()..".util.events")
local files = require (wolfa_getLuaPath()..".util.files")
local logs = require (wolfa_getLuaPath()..".util.logs")
local tables = require (wolfa_getLuaPath()..".util.tables")

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

function commands.log(clientId, command, victim, ...)
    local victimId
    
    -- funny, NoQuarter actually checks EACH command for a victim (so even 
    -- !help [playername] will log a victimname). so why not do the same :D
    -- todo: do this more nicely, maybe change .register() function
    if victim then
        local cmdClient

        if tonumber(victim) == nil or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
            cmdClient = et.ClientNumberFromString(victim)
        else
            cmdClient = tonumber(victim)
        end
        
        if cmdClient ~= -1 and cmdClient ~= nil and et.gentity_get(cmdClient, "pers.netname") then
            victimId = cmdClient
        end
    end

    logs.writeAdmin(clientId, command, victimId, ...)
end

function commands.onGameInit()
    commands.load()
end
events.handle("onGameInit", commands.onGameInit)

function commands.onServerCommand(command)
    local wolfCmd = string.lower(command)
    local args = {}

    if servercmds[wolfCmd] and servercmds[wolfCmd]["function"] then
        for i = 1, et.trap_Argc() - 1 do
            table.insert(args, et.trap_Argv(i))
        end

        return servercmds[wolfCmd]["function"](wolfCmd, tables.unpack(args)) and 1 or 0
    end

    local shrubCmd = command

    if string.find(command, "!") == 1 then
        shrubCmd = string.lower(string.sub(command, 2, string.len(command)))
    end
    
    if admincmds[shrubCmd] and admincmds[shrubCmd]["function"] and admincmds[shrubCmd]["flag"] then
        for i = 1, et.trap_Argc() - 1 do
            table.insert(args, et.trap_Argv(i))
        end

        if not admincmds[shrubCmd]["hidden"] then
            commands.log(-1337, shrubCmd, tables.unpack(args))
        end

        return admincmds[shrubCmd]["function"](-1337, shrubCmd, tables.unpack(args)) and 1 or 0
    end
end
events.handle("onServerCommand", commands.onServerCommand)

function commands.onClientCommand(clientId, command)
    local wolfCmd = string.lower(command)
    local args = {}

    -- mod-specific or custom commands loading
    -- syntax: command arg1 arg2 ... argN
    if clientcmds[wolfCmd] and clientcmds[wolfCmd]["function"] and clientcmds[wolfCmd]["flag"] then
        if clientcmds[wolfCmd]["flag"] == "" or auth.isPlayerAllowed(clientId, clientcmds[wolfCmd]["flag"]) then
            for i = 1, et.trap_Argc() - 1 do
                table.insert(args, et.trap_Argv(i))
            end

            local isFinished = clientcmds[wolfCmd]["function"](clientId, wolfCmd, tables.unpack(args))

            if isFinished ~= nil then
                return isFinished and 1 or 0
            end
        end
    end

    -- client cmds
    -- syntax: say or say_*
    local clientCmd = nil

    if (wolfCmd == "say" or wolfCmd == "say_team" or wolfCmd == "say_buddy") and string.find(et.trap_Argv(1), "/") == 1 then
        args = util.split(et.trap_Argv(1), " ")

        -- say "/command arg1 arg2 argN"
        if #args > 1 then
            clientCmd = string.sub(args[1], 2, string.len(args[1]))
            table.remove(args, 1)
        -- say /command arg1 arg2 argN
        else
            clientCmd = string.sub(et.trap_Argv(1), 2, string.len(et.trap_Argv(1)))

            for i = 2, et.trap_Argc() - 1 do
                table.insert(args, et.trap_Argv(i))
            end
            if args[1] == et.trap_Argv(1) then table.remove(args, 1) end
        end
    end

    -- handle client cmds
    if clientCmd then
        clientCmd = string.lower(clientCmd)
        
        if clientcmds[clientCmd] and clientcmds[clientCmd]["function"] and clientcmds[clientCmd]["chat"] then
            if clientcmds[clientCmd]["flag"] == "" or auth.isPlayerAllowed(clientId, clientcmds[clientCmd]["flag"]) then
                return clientcmds[clientCmd]["function"](clientId, clientCmd, tables.unpack(args)) and 1 or 0
            end
        end
    end
    
    -- shrub cmds
    local shrubCmd = nil
    
    -- syntax: say or say_*
    if (wolfCmd == "say" or wolfCmd == "say_team" or wolfCmd == "say_buddy") and string.find(et.trap_Argv(1), "!") == 1 then
        args = util.split(et.trap_Argv(1), " ")

        -- syntax: say "!command arg1 arg2 ... argN"
        if #args > 1 then
            shrubCmd = string.sub(args[1], 2, string.len(args[1]))

            table.remove(args, 1)
        -- syntax: say !command arg1 arg2 ... argN
        else
            shrubCmd = string.sub(et.trap_Argv(1), 2, string.len(et.trap_Argv(1)))
            
            for i = 2, et.trap_Argc() - 1 do
                table.insert(args, et.trap_Argv(i))
            end
            if args[1] == et.trap_Argv(1) then table.remove(args, 1) end
        end
    -- syntax: !command arg1 arg2 ... argN
    elseif string.find(wolfCmd, "!") == 1 then
        shrubCmd = string.sub(wolfCmd, 2, string.len(wolfCmd))
        
        for i = 1, et.trap_Argc() - 1 do
            table.insert(args, et.trap_Argv(i))
        end
    end

    -- handle shrub commands
    if shrubCmd then
        shrubCmd = string.lower(shrubCmd)
        
        if admincmds[shrubCmd] and admincmds[shrubCmd]["function"] and admincmds[shrubCmd]["flag"] then
            if wolfCmd == "say" or (((wolfCmd == "say_team" and et.gentity_get(cmdClient, "sess.sessionTeam") ~= et.TEAM_SPECTATORS) or wolfCmd == "say_buddy") and auth.isPlayerAllowed(clientId, auth.PERM_TEAMCMDS)) or (wolfCmd == "!"..shrubCmd and auth.isPlayerAllowed(clientId, auth.PERM_SILENTCMDS)) then
                if admincmds[shrubCmd]["flag"] ~= "" and auth.isPlayerAllowed(clientId, admincmds[shrubCmd]["flag"]) then
                    local isFinished = admincmds[shrubCmd]["function"](clientId, shrubCmd, tables.unpack(args))
                    
                    if not admincmds[shrubCmd]["hidden"] then
                        commands.log(clientId, shrubCmd, tables.unpack(args))
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
