
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015 Timo 'Timothy' Smit

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

local constants = {}

constants.GAME_STATE_RUNNING = 0
constants.GAME_STATE_WARMUP = 1
constants.GAME_STATE_INTERMISSION = 3

constants.COLOR_MAIN = "^7"

constants.MAX_LENGTH_CP = 56
constants.MAX_LENGTH_CVAR = 254
constants.MAX_LENGTH_CONSOLE = 255

constants.TEAM_AXIS = 1
constants.TEAM_ALLIES = 2
constants.TEAM_SPECTATORS = 3

constants.TEAM_AXIS_SC = "r"
constants.TEAM_ALLIES_SC = "b"
constants.TEAM_SPECTATORS_SC = "s"

constants.TEAM_AXIS_COLOR = "^1"
constants.TEAM_ALLIES_COLOR = "^4"
constants.TEAM_SPECTATORS_COLOR = "^2"

constants.CLASS_SOLDIER = 0
constants.CLASS_MEDIC = 1
constants.CLASS_ENGINEER = 2
constants.CLASS_FIELDOPS = 3
constants.CLASS_COVERTOPS = 4

constants.SKILL_BATTLESENSE = 0
constants.SKILL_ENGINEER = 1
constants.SKILL_MEDIC = 2
constants.SKILL_FIELDOPS = 3
constants.SKILL_LIGHTWEAPONS = 4
constants.SKILL_SOLDIER = 5
constants.SKILL_COVERTOPS = 6

constants.AREA_CONSOLE = 0
constants.AREA_POPUPS = 1
constants.AREA_CHAT = 2
constants.AREA_CP = 3

constants.VOTE_TYPES = { "antilag", "balancedteams", "comp", "friendlyfire", "gamconstantsype", "kick", 
    "map", "maprestart", "matchresconstants", "mutespecs", "muting", "nextcampaign", "nextmap", 
    "poll", "pub", "referee", "restartcampaign", "shufflconstantseamsxp", "shufflconstantseamsxp_norestart",
    "surrender", "swapteams", "timelimit", "warmupdamage"
}

constants.RECORD_KILL = 0
constants.RECORD_DEATH = 1
constants.RECORD_REVIVE = 2

return constants