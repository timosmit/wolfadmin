#!/usr/bin/env bash

# WolfAdmin module for Wolfenstein: Enemy Territory servers.
# Copyright (C) 2015-2018 Timo 'Timothy' Smit

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# at your option any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

VERSION="1.2.0-dev"

install() {
    echo

    if [[ ! -d $fs_basepath/$fs_game ]]; then
        while true; do
            read -p "$fs_basepath/$fs_game does not exist, continue? (y/n) " yn
            case $yn in
                [Yy]* ) mkdir $fs_basepath/$fs_game; echo "created $fs_basepath/$fs_game"; break;;
                [Nn]* ) echo 'exited without making changes'; exit;;
                * ) echo 'please answer yes or no.';;
            esac
        done
    fi

    if [[ ! -d $fs_homepath/$fs_homedir/$fs_game ]]; then
        while true; do
            read -p "$fs_homepath/$fs_homedir/$fs_game does not exist, continue? (y/n) " yn
            case $yn in
                [Yy]* ) mkdir $fs_homepath/$fs_homedir/$fs_game; echo "created $fs_homepath/$fs_homedir/$fs_game"; break;;
                [Nn]* ) echo 'exited without making changes'; exit;;
                * ) echo 'please answer yes or no.';;
            esac
        done
    fi

    if [[ -d $fs_basepath/$fs_game/luamods/wolfadmin ]]; then
        while true; do
            read -p "$fs_basepath/$fs_game/luamods/wolfadmin already exists, continue? (y/n) " yn
            case $yn in
                [Yy]* ) rm -r $fs_basepath/$fs_game/luamods/wolfadmin; echo 'removed old WolfAdmin luamod'; break;;
                [Nn]* ) echo 'exited without making changes'; exit;;
                * ) echo 'please answer yes or no.';;
            esac
        done
    fi

    echo

    echo -n 'copying lualibs...'
    cp -r lualibs/* $fs_basepath/$fs_game/lualibs
    echo 'done.'

    echo -n 'copying luamods...'
    cp -r luamods/* $fs_basepath/$fs_game/luamods
    echo 'done.'

    echo -n 'copying configs...'
    cp -n config/* $fs_homepath/$fs_homedir/$fs_game
    echo 'done.'

    if [ -e $fs_homepath/$fs_homedir/$fs_game/wolfadmin*.pk3 ]; then
        rm $fs_homepath/$fs_homedir/$fs_game/wolfadmin*.pk3
        echo 'removed old pk3'
        install_pk3
    else
        while true; do
            read -p 'install pk3? (y/n) ' yn
            case $yn in
                [Yy]* ) install_pk3; break;;
                [Nn]* ) echo 'pk3 not installed'; break;;
                * ) echo 'please answer yes or no.';;
            esac
        done
    fi

    if [ ! -x "$(command -v sqlite3)" ]; then
        echo 'sqlite3 executable does not exist, cannot create database'
    elif [[ -e $fs_homepath/$fs_homedir/$fs_game/wolfadmin.db ]]; then
        while true; do
            read -p 'database already exists, overwrite? (y/n) ' yn
            case $yn in
                [Yy]* ) rm $fs_homepath/$fs_homedir/$fs_game/wolfadmin.db; echo 'removed old database'; install_db; break;;
                [Nn]* ) echo 'database not created'; break;;
                * ) echo 'please answer yes or no.';;
            esac
        done
    else
        install_db
    fi

    echo

    echo 'install process finished.'
}

install_pk3() {
    echo -n 'zipping pk3...';
    zip -r -q wolfadmin-$VERSION.pk3 pk3
    echo 'done.'
    echo -n 'copying pk3...';
    cp wolfadmin-$VERSION.pk3 $fs_basepath/$fs_game
    echo 'done.'
}

install_db() {
    echo -n 'initializing database...';
    sqlite3 $fs_homepath/$fs_homedir/$fs_game/wolfadmin.db < database/new/sqlite.sql;
    echo 'done.'
}

update() {
    echo

    if [[ ! -d $fs_basepath/$fs_game ]]; then
        echo "$fs_basepath/$fs_game dir does not exist, cannot update"
        exit
    elif [[ ! -d $fs_homepath/$fs_homedir/$fs_game ]]; then
        echo "$fs_homepath/$fs_game dir does not exist, cannot update"
        exit
    elif [[ -d $fs_basepath/$fs_game/luamods/wolfadmin ]]; then
        echo "$fs_basepath/$fs_game/luamods/wolfadmin does not exist, cannot update"
        exit
    fi

    echo -n 'removing old WolfAdmin luamod...'
    rm -r $fs_basepath/$fs_game/luamods/wolfadmin
    echo 'done.'

    echo -n 'copying lualibs...'
    cp -r lualibs/* $fs_basepath/$fs_game/lualibs
    echo 'done.'

    echo -n 'copying luamods...'
    cp -r luamods/* $fs_basepath/$fs_game/luamods
    echo 'done.'

    echo -n 'copying configs...'
    cp -n config/* $fs_homepath/$fs_homedir/$fs_game
    echo 'done.'

    if [ -e $fs_homepath/$fs_homedir/$fs_game/wolfadmin*.pk3 ]; then
        rm $fs_homepath/$fs_homedir/$fs_game/wolfadmin*.pk3
        echo 'removed old pk3'
        install_pk3
    else
        while true; do
            read -p 'install pk3? (y/n) ' yn
            case $yn in
                [Yy]* ) install_pk3; break;;
                [Nn]* ) echo 'pk3 not installed'; break;;
                * ) echo 'please answer yes or no.';;
            esac
        done
    fi

    if [ ! -x "$(command -v sqlite3)" ]; then
        echo 'sqlite3 executable does not exist, cannot update database'
    elif [[ ! -e $fs_homepath/$fs_homedir/$fs_game/wolfadmin.db ]]; then
        echo 'wolfadmin.db does not exist, cannot update database'
    else
        echo -n 'updating database...'
        sqlite3 $fs_homepath/$fs_homedir/$fs_game/wolfadmin.db < database/update/$prev_version/sqlite.sql
        echo 'done.'
    fi

    echo

    echo 'update process finished.'
}

echo "WolfAdmin $VERSION deployment script"

read -p 'fs_basepath (install directory):  ' fs_basepath

if [[ -z $fs_basepath ]]; then
    echo 'fs_basepath cannot be empty'
    exit
elif [[ ! -d $fs_basepath ]]; then
    echo 'fs_basepath does not exist'
    exit
fi

read -p 'fs_homepath (user directory):     ' fs_homepath

if [[ -z $fs_homepath ]]; then
    echo 'fs_homepath cannot be empty'
    exit
elif [[ ! -d $fs_homepath ]]; then
    echo 'fs_homepath does not exist'
    exit
elif [[ -d $fs_homepath/.etlegacy ]]; then
    fs_homedir=.etlegacy
elif [[ -d $fs_homepath/.wolfet ]]; then
    fs_homedir=.wolfet
else
    echo 'fs_homepath does not contain a .etlegacy or .wolfet directory'
    exit
fi

read -p 'fs_game     (e.g. legacy, nq):    ' fs_game

if [[ -z $fs_game ]]; then
    echo 'fs_game cannot be empty'
    exit
fi

echo

while true; do
    read -p 'install or update? (i/u) ' mode
    case $mode in
        [Ii]* ) install; break;;
        [Uu]* ) update; break;;
    esac
done
