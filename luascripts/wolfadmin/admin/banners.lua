
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

local bits = wolfa_requireModule("util.bits")
local events = wolfa_requireModule("util.events")
local settings = wolfa_requireModule("util.settings")
local timers = wolfa_requireModule("util.timers")
local constants = wolfa_requireModule("util.constants")
local util = wolfa_requireModule("util.util")

local toml = wolfa_requireLib("toml")

local banners = {}

banners.RANDOM_START = 1
banners.RANDOM_ALL = 2

local nextBannerId = 0
local bannerTimer

local welcomeBanners = {}
local infoBanners = {}

function banners.print(clientId, banner)
    local prefix = (settings.get("g_bannerArea") ~= constants.AREA_CHAT) and "^7" or "^dbanner: ^9"
    local target = clientId and clientId or -1
    et.trap_SendConsoleCommand(et.EXEC_APPEND, 
        string.format("%s %i \"%s%s\";", util.getCommandForArea(settings.get("g_bannerArea")), target, prefix, banner["text"]))
end

function banners.nextBanner(random)
    if #infoBanners == 0 then
        nextBannerId = 0
    elseif random then
        nextBannerId = math.random(#infoBanners)
    elseif nextBannerId ~= #infoBanners then
        nextBannerId = nextBannerId + 1
    else
        nextBannerId = 1
    end
end

function banners.autoprint()
    if nextBannerId ~= 0 and infoBanners[nextBannerId] then
        banners.print(nil, infoBanners[nextBannerId])
    end

    banners.nextBanner(bits.hasbit(settings.get("g_bannerRandomize"), banners.RANDOM_ALL))
end

function banners.load()
    local fileName = settings.get("g_fileBanners")

    if fileName == "" then
        return 0
    end

    local fileDescriptor, fileLength = et.trap_FS_FOpenFile(fileName, et.FS_READ)

    if fileLength == -1 then
        return 0
    end

    -- in case someone issued a !readconfig, make sure the old data is removed
    banners.clear()

    local fileString = et.trap_FS_Read(fileDescriptor, fileLength)

    et.trap_FS_FCloseFile(fileDescriptor)

    local fileTable = toml.parse(fileString)

    if fileTable["banner"] then
        for _, banner in ipairs(fileTable["banner"]) do
            if banner["welcome"] and banner["welcome"] == true then
                table.insert(welcomeBanners, banner)
            end

            if banner["info"] and banner["info"] == true then
                table.insert(infoBanners, banner)
            end
        end
    end

    return #welcomeBanners + #infoBanners
end

function banners.clear()
    welcomeBanners = {}
    infoBanners = {}
end

function banners.onPlayerReady(clientId, firstTime)
    if firstTime then
        for _, banner in ipairs(welcomeBanners) do
            banners.print(clientId, banner)
        end
    end
end
events.handle("onPlayerReady", banners.onPlayerReady)

function banners.onGameInit(levelTime, randomSeed, restartMap)
    banners.load()

    banners.nextBanner(bits.hasbit(settings.get("g_bannerRandomize"), banners.RANDOM_START))

    bannerTimer = timers.add(banners.autoprint, settings.get("g_bannerInterval") * 1000, 0)
end
events.handle("onGameInit", banners.onGameInit)

return banners
