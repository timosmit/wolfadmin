
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

local auth = wolfa_requireModule("auth.auth")
local commands = wolfa_requireModule("commands.commands")
local db = wolfa_requireModule("db.db")
local sprees = wolfa_requireModule("game.sprees")
local output = wolfa_requireModule("game.output")

function commandShowSprees(clientId, command)
    if not db.isConnected() then
        output.clientConsole("^dsprees: ^9spree records are disabled.", clientId)
        
        return true
    end

    local records = sprees.get()

    if #records == 0 then
        output.clientConsole("^dsprees: ^9there are no records for this map yet.", clientId)
    else
        for i = 0, sprees.TYPE_NUM - 1 do
            if records[i] and records[i]["record"] > 0 then
                output.clientChat("^dsprees: ^9longest "..sprees.getRecordNameByType(i).." spree (^7"..records[i]["record"].."^9) by ^7"..db.getLastAlias(records[i]["player"])["alias"].."^9.")
            end
        end
    end
    
    return true
end
commands.addadmin("sprees", commandShowSprees, auth.PERM_LISTSPREES, "display the current spree records")
