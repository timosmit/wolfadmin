
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

local db = wolfa_requireModule("db.db")
local config = wolfa_requireModule("config.config")
local output = wolfa_requireModule("game.output")
local server = wolfa_requireModule("game.server")
local players = wolfa_requireModule("players.players")
local constants = wolfa_requireModule("util.constants")
local events = wolfa_requireModule("util.events")
local util = wolfa_requireModule("util.util")

local admin = {}

local playerRenames = {}

function admin.checkDamage(clientId)
    local teamDamage = et.gentity_get(clientId, "sess.team_damage_given")
    local totalDamage = teamDamage + et.gentity_get(clientId, "sess.damage_given")
    local teamDamagePercentage = teamDamage / totalDamage

    if teamDamage > 250 and totalDamage > 500 and teamDamagePercentage > config.get("g_maxTeamDamage") then
        admin.kickPlayer(clientId, -1337, "Too much team damage.")
    end
end

function admin.putPlayer(clientId, teamId)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "forceteam "..clientId.." "..util.getTeamCode(teamId)..";")
end

function admin.burnPlayer(clientId)
    if et.gentity_get(clientId, "sess.sessionTeam") == constants.TEAM_SPECTATORS or et.gentity_get(clientId, "health") <= 0 then
        return
    end

    local levelTime = et.trap_Milliseconds()

    et.G_Damage(clientId, clientId, clientId, 5, 0, 17)

    et.gentity_set(clientId, "s.onFireStart", levelTime)
    et.gentity_set(clientId, "s.onFireEnd", levelTime + 323000)
    outputDebug(levelTime)
    outputDebug(et.gentity_get(clientId, "s.onFireEnd"))
end

function admin.slapPlayer(clientId, damage)
    if et.gentity_get(clientId, "sess.sessionTeam") == constants.TEAM_SPECTATORS or et.gentity_get(clientId, "health") <= 0 then
        return
    end

    local newHealth = et.gentity_get(clientId, "health") - damage

    if newHealth < 1 then
        newHealth = 1
    end

    et.gentity_set(clientId, "health", newHealth)

    server.exec(string.format("playsound %d \"sound/player/land_hurt.wav\";", clientId))
end

function admin.killPlayer(clientId)
    if et.gentity_get(clientId, "sess.sessionTeam") == constants.TEAM_SPECTATORS or et.gentity_get(clientId, "health") <= 0 then
        return
    end

    et.gentity_set(clientId, "health", 0)
end

function admin.gibPlayer(clientId)
    if et.gentity_get(clientId, "sess.sessionTeam") == constants.TEAM_SPECTATORS or et.gentity_get(clientId, "health") <= 0 then
        return
    end

    -- GENTITYNUM_BITS    10                      10
    -- MAX_GENTITIES      1 << GENTITYNUM_BITS    1024
    -- ENTITYNUM_WORLD    MAX_GENTITIES - 2       18
    et.G_Damage(clientId, 0, 1024, 500, 0, 0) -- MOD_UNKNOWN = 0
end

function admin.kickPlayer(victimId, invokerId, reason)
    et.trap_DropClient(victimId, "You have been kicked, Reason: "..reason, 0)
end

function admin.setPlayerLevel(clientId, level)
    local playerId = db.getPlayer(players.getGUID(clientId))["id"]

    db.updatePlayerLevel(playerId, level)
end

function admin.onClientConnectAttempt(clientId, firstTime, isBot)
    if firstTime and db.isConnected() then
        local guid = et.Info_ValueForKey(et.trap_GetUserinfo(clientId), "cl_guid")

        if string.len(guid) < 32 then
            return "\n\nIt appears you do not have a ^7GUID^9/^7etkey^9. In order to play on this server, create an ^7etkey^9.\n\nMore info: ^7www.etkey.org"
        end

        if config.get("g_standalone") ~= 0 then
            local player = db.getPlayer(guid)
            if player then
                local playerId = player["id"]
                local ban = db.getBanByPlayer(playerId)
                if ban then
                    return "\n\nYou have been banned for "..ban["duration"].." seconds, Reason: "..ban["reason"]
                end
            end
        end
    end

    events.trigger("onClientConnect", clientId, firstTime, isBot)
end
events.handle("onClientConnectAttempt", admin.onClientConnectAttempt)

function admin.onClientConnect(clientId, firstTime, isBot)
    if config.get("g_standalone") ~= 0 and db.isConnected() then
        local guid = et.Info_ValueForKey(et.trap_GetUserinfo(clientId), "cl_guid")
        local player = db.getPlayer(guid)

        if player then
            local playerId = player["id"]
            local mute = db.getMuteByPlayer(playerId)

            if mute then
                players.setMuted(clientId, true, mute["type"], mute["issued"], mute["expires"])
            end
        end
    end
end
events.handle("onClientConnect", admin.onClientConnect)

function admin.onClientDisconnect(clientId)
    if playerRenames[clientId] then
        playerRenames[clientId] = nil
    end
end
events.handle("onClientDisconnect", admin.onClientDisconnect)

function admin.onPlayerDamage(victimId, attackerId, damage, damageFlags, meansOfDeath)
    local attackerType = tonumber(et.gentity_get(attackerId, "s.eType"))
    local victimType = tonumber(et.gentity_get(victimId, "s.eType"))

    -- FIXME: use constant ET_PLAYER
    if attackerId and victimId and attackerType == 1 and victimType == 1 and attackerId ~= victimId then
        local victimTeam = tonumber(et.gentity_get(victimId, "sess.sessionTeam"))
        local attackerTeam = tonumber(et.gentity_get(attackerId, "sess.sessionTeam"))

        if attackerTeam == victimTeam then
            admin.checkDamage(attackerId)
        end
    end
end
events.handle("onPlayerDamage", admin.onPlayerDamage)

function admin.onPlayerDeath(victimId, attackerId, meansOfDeath)
    local attackerType = tonumber(et.gentity_get(attackerId, "s.eType"))
    local victimType = tonumber(et.gentity_get(victimId, "s.eType"))

    -- FIXME: use constant ET_PLAYER
    if attackerId and victimId and attackerType == 1 and victimType == 1 and attackerId ~= victimId then
        local victimTeam = tonumber(et.gentity_get(victimId, "sess.sessionTeam"))
        local attackerTeam = tonumber(et.gentity_get(attackerId, "sess.sessionTeam"))

        if attackerTeam == victimTeam then
            admin.checkDamage(attackerId)
        end
    end
end
events.handle("onPlayerDeath", admin.onPlayerDeath)

function admin.onClientNameChange(clientId, oldName, newName)
    -- rename filter
    if not playerRenames[clientId] or playerRenames[clientId]["last"] < os.time() - 60 then
        playerRenames[clientId] = {
            ["first"] = os.time(),
            ["last"] = os.time(),
            ["count"] = 1
        }
    else
        playerRenames[clientId]["count"] = playerRenames[clientId]["count"] + 1
        playerRenames[clientId]["last"] = os.time()

        -- give them some time
        if (playerRenames[clientId]["last"] - playerRenames[clientId]["first"]) > 3 then
            local renamesPerMinute = playerRenames[clientId]["count"] / (playerRenames[clientId]["last"] - playerRenames[clientId]["first"]) * 60

            if renamesPerMinute > config.get("g_renameLimit") then
                admin.kickPlayer(clientId, -1337, "Too many name changes.")
            end
        end
    end

    -- on some mods, this message is already printed
    -- known: old NQ versions, Legacy
    if et.trap_Cvar_Get("fs_game") ~= "legacy" then
        output.clientConsole(oldName.." ^7is now known as "..newName)
    end

    -- update database
    if db.isConnected() then
        local playerId = db.getPlayer(players.getGUID(clientId))["id"]
        local alias = db.getAliasByName(playerId, newName)

        if alias then
            db.updateAlias(alias["id"], os.time())
        else
            db.addAlias(playerId, newName, os.time())
        end
    end
end
events.handle("onClientNameChange", admin.onClientNameChange)

return admin
