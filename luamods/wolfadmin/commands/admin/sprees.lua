
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2018 Timo 'Timothy' Smit

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

local commands = require (wolfa_getLuaPath()..".commands.commands")

local db = require (wolfa_getLuaPath()..".db.db")

local sprees = require (wolfa_getLuaPath()..".game.sprees")

function commandShowSprees(clientId, command)
    if not db.isConnected() then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dsprees: ^9spree records are disabled.\";")
        
        return true
    end

    local records = sprees.get()

    if #records == 0 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dsprees: ^9there are no records for this map yet.\"")
    else
        for i = 0, sprees.RECORD_NUM - 1 do
            if records[i] and records[i]["record"] > 0 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dsprees: ^9longest "..sprees.getRecordNameByType(i).." spree (^7"..records[i]["record"].."^9) by ^7"..db.getLastAlias(records[i]["player"])["alias"].."^9.\";")
            end
        end
    end
    
    return true
end
commands.addadmin("sprees", commandShowSprees, auth.PERM_LISTSPREES, "display the current spree records")
