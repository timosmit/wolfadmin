
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
local output = wolfa_requireModule("game.output")
local util = wolfa_requireModule("util.util")

function commandShowStats(clientId, command, victim)
    local cmdClient

    if victim == nil then
        output.clientConsole("^dstats usage: "..commands.getadmin("stats")["syntax"], clientId)

        return true
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        output.clientConsole("^dstats: ^9no or multiple matches for '^7"..victim.."^9'.", clientId)

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        output.clientConsole("^dstats: ^9no connected player by that name or slot #", clientId)

        return true
    end

    local stats = {
        ["name"] = et.gentity_get(cmdClient, "pers.netname"),
        ["cleanname"] = et.gentity_get(cmdClient, "pers.netname"):gsub("%^[^^]", ""),
        ["codedsname"] = et.gentity_get(cmdClient, "pers.netname"):gsub("%^([^^])", "^^2%1"),
        ["slot"] = cmdClient,
        ["team"] = et.gentity_get(cmdClient, "sess.sessionTeam"),
        ["class"] = et.gentity_get(cmdClient, "sess.playerType"),
        ["health"] = et.gentity_get(cmdClient, "health"),
        ["kills"] = et.gentity_get(cmdClient, "sess.kills"),
        ["teamkills"] = et.gentity_get(cmdClient, "sess.team_kills"),
        ["totalkills"] = et.gentity_get(cmdClient, "sess.kills") + et.gentity_get(cmdClient, "sess.team_kills"),
        ["damage"] = et.gentity_get(cmdClient, "sess.damage_given"),
        ["damagereceived"] = et.gentity_get(cmdClient, "sess.damage_received"),
        ["deaths"] = et.gentity_get(cmdClient, "sess.deaths")
    }

    if et.trap_Cvar_Get("fs_game") == "legacy" then
        stats["teamdamage"] = et.gentity_get(cmdClient, "sess.team_damage_given")
        stats["teamdamagereceived"] = et.gentity_get(cmdClient, "sess.team_damage_received")
        stats["totaldamage"] = et.gentity_get(cmdClient, "sess.damage_given") + et.gentity_get(cmdClient, "sess.team_damage_given")
        stats["totaldamagereceived"] = et.gentity_get(cmdClient, "sess.damage_received") + et.gentity_get(cmdClient, "sess.team_damage_received")
        stats["selfkills"] = et.gentity_get(cmdClient, "sess.self_kills")
        stats["gibs"] = et.gentity_get(cmdClient, "sess.gibs")
        stats["teamgibs"] = et.gentity_get(cmdClient, "sess.team_gibs")
        stats["totaldeaths"] = et.gentity_get(cmdClient, "sess.deaths") + et.gentity_get(cmdClient, "sess.self_kills")
        stats["totalgibs"] = et.gentity_get(cmdClient, "sess.gibs") + et.gentity_get(cmdClient, "sess.team_gibs")
    elseif settings.get("fs_game") == "etpro" then
        stats["teamdamagereceived"] = et.gentity_get(cmdClient, "sess.team_received") -- ETPro only
    else
        stats["teamdamage"] = et.gentity_get(cmdClient, "sess.team_damage")
        stats["totaldamage"] = et.gentity_get(cmdClient, "sess.damage_given") + et.gentity_get(cmdClient, "sess.team_damage")
        stats["suicides"] = et.gentity_get(cmdClient, "sess.suicides")
    end

    if stats["totalkills"] == 0 then stats["totalkills"] = 1 end
    if stats["totaldamage"] == 0 then stats["totaldamage"] = 1 end
    if et.trap_Cvar_Get("fs_game") == "legacy" then
        if stats["totaldeaths"] == 0 then stats["totaldeaths"] = 1 end
        if stats["totalgibs"] == 0 then stats["totalgibs"] = 1 end
        if stats["totaldamagereceived"] == 0 then stats["totaldamagereceived"] = 1 end
    end

    --[[ for key, value in pairs(stats) do
        output.clientConsole("^dstats: ^9"..string.format("%-15s", key..":").." ^7"..value, clientId)
    end ]]

    output.clientConsole("^dStatistics for ^7"..stats["name"].."^d:", clientId)
    output.clientConsole("^dName:     ^2"..stats["cleanname"].." ("..stats["codedsname"]..")", clientId)
    output.clientConsole("^dSlot:     ^2"..stats["slot"]..(stats["slot"] < tonumber(et.trap_Cvar_Get("sv_privateClients")) and " ^9(private)" or ""), clientId)
    output.clientConsole("^dTeam:     ^2"..util.getTeamName(stats["team"]), clientId)

    if stats["team"] ~= et.TEAM_SPECTATORS then
        output.clientConsole("^dClass:    ^2"..util.getClassName(stats["class"]), clientId)
        output.clientConsole("^dHealth:   ^2"..(stats["health"] < 0 and "dead" or stats["health"]), clientId)
    end
    if et.trap_Cvar_Get("fs_game") == "legacy" then
        output.clientConsole("^dDmg gvn:  ^2"..string.format("%-8s", stats["damage"]).." ^dTeam dmg gvn:   ^2"..string.format("%-4s", stats["teamdamage"]).." ^9("..string.format("%0.2f", (stats["teamdamage"] / (stats["totaldamage"] or 1) * 100)).." percent)", clientId)
        output.clientConsole("^dDmg rcvd: ^2"..string.format("%-8s", stats["damagereceived"]).." ^dTeam dmg rcvd:  ^2"..string.format("%-4s", stats["teamdamagereceived"]).." ^9("..string.format("%0.2f", (stats["teamdamagereceived"] / (stats["totaldamagereceived"] or 1) * 100)).." percent)", clientId)
    else
        output.clientConsole("^dDamage:   ^2"..string.format("%-8s", stats["damage"]).." ^dTeam damage:    ^2"..string.format("%-4s", stats["teamdamage"]).." ^9("..string.format("%0.2f", (stats["teamdamage"] / (stats["totaldamage"] or 1) * 100)).." percent)", clientId)
    end
    output.clientConsole("^dKills:    ^2"..string.format("%-8s", stats["kills"]).." ^dTeam kills:     ^2"..string.format("%-4s", stats["teamkills"]).." ^9("..string.format("%0.2f", (stats["teamkills"] / (stats["totalkills"] or 1) * 100)).." percent)", clientId)
    if et.trap_Cvar_Get("fs_game") == "legacy" then
        output.clientConsole("^dDeaths:   ^2"..string.format("%-8s", stats["deaths"]).." ^dSelf kills:     ^2"..string.format("%-4s", stats["selfkills"]).." ^9("..string.format("%0.2f", (stats["selfkills"] / (stats["totaldeaths"] or 1) * 100)).." percent)", clientId)
        output.clientConsole("^dGibs:     ^2"..string.format("%-8s", stats["gibs"]).." ^dTeam gibs:      ^2"..string.format("%-4s", stats["teamgibs"]).." ^9("..string.format("%0.2f", (stats["teamgibs"] / (stats["totalgibs"] or 1) * 100)).." percent)", clientId)
    else
        output.clientConsole("^dDeaths:   ^2"..string.format("%-8s", stats["deaths"]).." ^dSuicides:       ^2"..string.format("%-8s", stats["suicides"]), clientId)
        output.clientConsole("^dK/D:      ^2"..string.format("%0.2f", (stats["kills"] / ((stats["deaths"] > 0) and stats["deaths"] or 1))), clientId)
    end

    -- NQ 1.3.0 and higher
    --[[ for key, value in ipairs(stats["weapstats"]) do
        output.clientConsole("^dstats: ^9"..stats["weapstats"], clientId)
    end ]]

    -- NQ 1.3.0 and higher
    --[[ local weapstats = et.gentity_get(cmdClient, "sess.aWeaponStats", WP_THOMPSON)
        output.clientConsole("^dstats: ^9"..weapstats, clientId)
    ]]

    output.clientChat("^dstats: ^9stats for ^7"..stats["name"].." ^9were printed to the console.", clientId)

    return true
end
commands.addadmin("stats", commandShowStats, auth.PERM_LISTSTATS, "display the statistics for a specific player", "^9[^3name|slot#^9]")
