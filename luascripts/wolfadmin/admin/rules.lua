
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

local events = wolfa_requireModule("util.events")
local files = wolfa_requireModule("util.files")
local settings = wolfa_requireModule("util.settings")

local toml = wolfa_requireLib("toml")

local rules = {}

local data = {}

function rules.get(shortcut)
    if shortcut then
        return data[shortcut]
    end

    return data
end

function rules.load()
    local fileName = settings.get("g_fileRules")

    if fileName == "" then
        return 0
    end

    if string.find(fileName, ".toml") == string.len(fileName) - 4 then
        local fileDescriptor, fileLength = et.trap_FS_FOpenFile(fileName, et.FS_READ)

        if fileLength == -1 then
            return 0
        end

        local fileString = et.trap_FS_Read(fileDescriptor, fileLength)

        et.trap_FS_FCloseFile(fileDescriptor)

        local fileTable = toml.parse(fileString)

        local amount = 0

        for _, rule in ipairs(fileTable["rule"]) do
            if rule["shortcut"] and rule["rule"] then
                data[rule["shortcut"]] = rule["rule"]

                amount = amount + 1
            end
        end

        return amount
    else
        -- compatibility for 1.1.* and lower
        outputDebug("Using .cfg files is deprecated as of 1.2.0. Please consider updating to .toml files.", 3)

        local amount, array = files.loadFromCFG(fileName, "[a-z]+")

        if amount == 0 then return 0 end

        for _, rule in ipairs(array["rule"]) do
            if rule["shortcut"] and rule["rule"] then
                data[rule["shortcut"]] = rule["rule"]
            end
        end

        return amount
    end

    return 0
end

function rules.oninit(levelTime, randomSeed, restartMap)
    rules.load()
end
events.handle("onGameInit", rules.oninit)

return rules
