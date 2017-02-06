
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

local rules = require (wolfa_getLuaPath()..".admin.rules")

local auth = require (wolfa_getLuaPath()..".auth.auth")

local commands = require (wolfa_getLuaPath()..".commands.commands")

local greetings = require (wolfa_getLuaPath()..".players.greetings")

local settings = require (wolfa_getLuaPath()..".util.settings")

function commandReadconfig(clientId, command)
    settings.load()
    local rulesCount = rules.load()
    local greetingsCount = greetings.load()

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"readconfig: loaded "..greetingsCount.." greetings, "..rulesCount.." rules\";")

    return false
end
commands.addadmin("readconfig", commandReadconfig, auth.PERM_READCONFIG, "reloads the shrubbot config file and refreshes user flags", nil, true, (settings.get("g_standalone") == 1))

function commandReadconfig(clientId, command)
    settings.load()
    local rulesCount = rules.load()
    local greetingsCount = greetings.load()

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"readconfig: loaded "..greetingsCount.." greetings, "..rulesCount.." rules\";")

    return false
end
commands.addadmin("readconfig", commandReadconfig, auth.PERM_READCONFIG, "reloads the config file", nil, nil, (settings.get("g_standalone") == 0))
