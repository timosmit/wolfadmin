
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

local commands = require (wolfa_getLuaPath()..".commands.commands")

function commandCallVote(clientId, cmdArguments)
    local voteArguments = {}
    for i = 2, et.trap_Argc() - 1 do
        voteArguments[(i - 1)] = et.trap_Argv(i)
    end

    return events.trigger("onCallvote", clientId, et.trap_Argv(1), voteArguments)
end
commands.addclient("callvote", commandCallVote, "", "", false)
