
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

local toml = require "toml"
local events = require (wolfa_getLuaPath()..".util.events")

local settings = {}

local data = {
    ["g_logChat"] = "chat.log",
    ["g_logAdmin"] = "admin.log",
    ["g_fileGreetings"] = "greetings.cfg",
    ["g_fileRules"] = "rules.cfg",
    ["g_fileSprees"] = "sprees.cfg",
    ["g_playerHistory"] = 1,
    ["g_spreeMessages"] = 7,
    ["g_spreeRecords"] = 1,
    ["g_botRecords"] = 1,
    ["g_announceRevives"] = 1,
    ["g_greetingArea"] = 3,
    ["g_botGreetings"] = 1,
    ["g_welcomeMessage"] = "^dwolfadmin: ^9This server is running WolfAdmin, type ^7/wolfadmin ^9for more information.",
    ["g_welcomeArea"] = 3,
    ["g_evenerMinDifference"] = 2,
    ["g_evenerMaxDifference"] = 5,
    ["g_evenerPlayerSelection"] = 0,
    ["g_evenerInterval"] = 30,
    ["g_voteNextMapTimeout"] = 0,
    ["g_restrictedVotes"] = "",
    ["g_renameLimit"] = 80,
    ["g_standalone"] = 1,
    ["g_debugWolfAdmin"] = 0,
    ["omnibot_maxbots"] = 10,
    ["db_type"] = "sqlite3",
    ["db_file"] = "wolfadmin.db",
    ["db_hostname"] = "localhost",
    ["db_port"] = 3306,
    ["db_database"] = "wolfadmin",
    ["db_username"] = "",
    ["db_password"] = "",
    ["sv_os"] = "unix"
}

local cfgStructure = {
    ["main"] = {
        ["os"] = "sv_os",
        ["standalone"] = "g_standalone",
        ["debug"] = "g_debugWolfAdmin",
    },
    ["db"] = {
        ["type"] = "db_type",
        ["file"] = "db_file",
        ["hostname"] = "db_hostname",
        ["port"] = "db_port",
        ["database"] = "db_database",
        ["username"] = "db_username",
        ["password"] = "db_password",
    },
    ["logs"] = {
        ["chat"] = "g_logChat",
        ["admin"] = "g_logAdmin"
    },
    ["omnibot"] = {
        ["minbots"] = "omnibot_minbots",
        ["maxbots"] = "omnibot_maxbots"
    },
    ["admin"] = {
        ["history"] = "g_playerHistory",
        ["maxrenames"] = "g_renameLimit"
    },
    ["balancer"] = {
        ["mindif"] = "g_evenerMinDifference",
        ["maxdif"] = "g_evenerMaxDifference",
        ["selection"] = "g_evenerPlayerSelection",
        ["interval"] = "g_evenerInterval"
    },
    ["game"] = {
        ["announcerevives"] = "g_announceRevives"
    },
    ["voting"] = {
        ["timeout"] = "g_voteNextMapTimeout",
        ["restricted"] = "g_restrictedVotes"
    },
    ["banners"] = {
        ["welcome"] = "g_welcomeMessage",
        ["area"] = "g_welcomeArea"
    },
    ["rules"] = {
        ["file"] = "g_fileRules"
    },
    ["greetings"] = {
        ["file"] = "g_fileGreetings",
        ["area"] = "g_greetingsArea",
        ["bots"] = "g_botGreetings"
    },
    ["records"] = {
        ["bots"] = "g_botRecords"
    },
    ["sprees"] = {
        ["file"] = "g_fileSprees",
        ["messages"] = "g_spreeMessages",
        ["records"] = "g_spreeRecords"
    }
}

function settings.get(name)
    return data[name]
end

function settings.set(name, value)
    data[name] = value
end

function settings.load()
    for setting, default in pairs(data) do
        local cvar = et.trap_Cvar_Get(setting)
        
        if type(default) == "string" then
            data[setting] = (cvar ~= "" and tostring(cvar) or default)
        elseif type(default) == "number" then
            data[setting] = (cvar ~= "" and tonumber(cvar) or default)
        end
    end

    local fileDescriptor, fileLength = et.trap_FS_FOpenFile("wolfadmin.toml", et.FS_READ)

    if fileLength ~= -1 then
        local fileString = et.trap_FS_Read(fileDescriptor, fileLength)

        et.trap_FS_FCloseFile(fileDescriptor)

        local fileTable = toml.parse(fileString)
        for module, settings in pairs(fileTable) do
            for setting, value in pairs(settings) do
                if cfgStructure[module][setting] then
                    data[cfgStructure[module][setting]] = value
                end
            end
        end

        -- compatibility for 1.1.* and lower
        if type(data["g_restrictedVotes"]) == "table" then
            data["g_restrictedVotes"] = table.concat(data["g_restrictedVotes"], " ")
        end
    else
        -- compatibility for 1.1.* and lower
        outputDebug("Using .cfg files is deprecated as of 1.2.0. Please consider updating to .toml files.", 3)

        local files = require (wolfa_getLuaPath()..".util.files")
        local _, array = files.loadFromCFG("wolfadmin.cfg", "[a-z]+")

        for blocksname, settings in pairs(array) do
            for k, v in pairs(settings[1]) do
                data[cfgStructure[blocksname][k]] = v
            end
        end
    end

    local platform = string.lower(data["sv_os"])
    if not (platform == "unix" or platform == "windows") then
        settings.set("sv_os", settings.determineOS())
    end
end

function settings.determineOS()
    local system = io.popen("uname -s"):read("*l")
    local platform

    if system then
        platform = "unix"
    else
        platform = "windows"
    end

    return platform
end

function settings.oninit(levelTime, randomSeed, restartMap)
    settings.load()
end
events.handle("onGameInit", settings.oninit)

return settings
