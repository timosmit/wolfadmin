
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2019 Timo 'Timothy' Smit

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

local toml = wolfa_requireLib("toml")
local events = wolfa_requireModule("util.events")

local settings = {}

local data = {
    ["g_logChat"] = "chat.log",
    ["g_logAdmin"] = "admin.log",
    ["g_fileGreetings"] = "greetings.toml",
    ["g_fileRules"] = "rules.toml",
    ["g_fileSprees"] = "sprees.toml",
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
    ["g_debugWolfAdmin"] = 0,
    ["omnibot_maxbots"] = 10,
    ["db_type"] = "sqlite3",
    ["db_file"] = "wolfadmin.db",
    ["db_hostname"] = "localhost",
    ["db_port"] = 3306,
    ["db_database"] = "wolfadmin",
    ["db_username"] = "",
    ["db_password"] = ""
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
    -- compatibility for 1.1.* and lower
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

        local files = wolfa_requireModule("util.files")
        local _, array = files.loadFromCFG("wolfadmin.cfg", "[a-z]+")

        for blocksname, settings in pairs(array) do
            for k, v in pairs(settings[1]) do
                data[cfgStructure[blocksname][k]] = v
            end
        end
    end

    settings.determineOS()
    settings.determineMode()

    outputDebug("WolfAdmin running in "..(settings.get("g_standalone") ~= 0 and "standalone" or "add-on").." mode on "..settings.get("sv_os")..".")
end

function settings.determineOS()
    -- OS has been manually specified
    local os = settings.get("sv_os") and string.lower(settings.get("sv_os")) or nil

    if os == "unix" or os == "windows" then
        return
    end

    -- unknown os specified
    if os then
        outputDebug("Invalid operating system specified, determining automatically.", 3)
    end

    -- 'uname' is available on Unix systems
    local uname = io.popen("uname -s 2>nul"):read("*l")
    if uname then
        settings.set("sv_os", "unix")

        return
    end

    -- 'ver' is available on Windows systems
    local ver = io.popen("ver 2>nul"):read("*l")
    if ver then
        settings.set("sv_os", "windows")

        return
    end

    outputDebug("Operating system could not be determined, falling back to 'unix'.", 3)

    settings.set("sv_os", "unix")
end

function settings.determineMode()
    -- mode has been manually specified
    if settings.get("g_standalone") then
        return
    end

    local mod = et.trap_Cvar_Get("fs_game")
    local shrubbot = et.trap_Cvar_Get("g_shrubbot") -- etpub, nq
    local dbDir = et.trap_Cvar_Get("g_dbDirectory") -- silent
    if mod == "legacy" or mod == "etpro" then
        settings.set("g_standalone", 1)
    elseif (not shrubbot or shrubbot == "") and (not dbDir or dbDir == "") then
        settings.set("g_standalone", 1)
    else
        settings.set("g_standalone", 0)
    end
end

function settings.oninit(levelTime, randomSeed, restartMap)
    settings.load()
end
events.handle("onGameInit", settings.oninit)

return settings
