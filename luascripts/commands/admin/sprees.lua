
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

local auth = require "luascripts.wolfadmin.auth.auth"
local commands = require "luascripts.wolfadmin.commands.commands"
local db = require "luascripts.wolfadmin.db.db"
local sprees = require "luascripts.wolfadmin.game.sprees"

function commandShowSprees(clientId, cmdArguments)
    if not db.isconnected() then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dsprees: ^9spree records are disabled.\";")
        
        return true
    end

    local records = sprees.get()
    
    if not (records["ksrecord"] or records["dsrecord"] or records["rsrecord"]) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dsprees: ^9there are no records for this map yet.\"")
    else
        if records["ksrecord"] and records["ksrecord"] > 0 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dsprees: ^9longest kill spree (^7"..records["ksrecord"].."^9) by ^7"..records["ksname"].."^9.\";")
        end
        if records["dsrecord"] and records["dsrecord"] > 0 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dsprees: ^9longest death spree (^7"..records["dsrecord"].."^9) by ^7"..records["dsname"].."^9.\";")
        end
        if records["rsrecord"] and records["rsrecord"] > 0 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "chat \"^dsprees: ^9longest revive spree (^7"..records["rsrecord"].."^9) by ^7"..records["rsname"].."^9.\";")
        end
    end
    
    return true
end
commands.addadmin("sprees", commandShowSprees, auth.PERM_LISTSPREES, "display the current spree records")
