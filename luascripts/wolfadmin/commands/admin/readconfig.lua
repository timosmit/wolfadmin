
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

local banners = wolfa_requireModule("admin.banners")
local censor = wolfa_requireModule("admin.censor")
local rules = wolfa_requireModule("admin.rules")
local auth = wolfa_requireModule("auth.auth")
local commands = wolfa_requireModule("commands.commands")
local config = wolfa_requireModule("config.config")
local output = wolfa_requireModule("game.output")
local sprees = wolfa_requireModule("game.sprees")
local greetings = wolfa_requireModule("players.greetings")

function commandReadconfig(clientId, command)
    config.load()
    local bannersCount = banners.load()
    local rulesCount = rules.load()
    local greetingsCount = greetings.load()
    local spreesCount = sprees.load()

    output.clientConsole("readconfig: loaded "..bannersCount.." banners, "..rulesCount.." rules, "..greetingsCount.." greetings, "..spreesCount.." sprees", clientId)

    return false
end
commands.addadmin("readconfig", commandReadconfig, auth.PERM_READCONFIG, "reloads the shrubbot config file and refreshes user flags", nil, true, (config.get("g_standalone") ~= 0))

function commandReadconfig(clientId, command)
    config.load()
    local bannersCount = banners.load()
    local censorCount = censor.load()
    local rulesCount = rules.load()
    local greetingsCount = greetings.load()
    local spreesCount = sprees.load()

    output.clientConsole("readconfig: loaded "..bannersCount.." banners, "..rulesCount.." rules, "..greetingsCount.." greetings, "..censorCount.." censor patterns, "..spreesCount.." sprees", clientId)

    return false
end
commands.addadmin("readconfig", commandReadconfig, auth.PERM_READCONFIG, "reloads the config file", nil, nil, (config.get("g_standalone") == 0))
