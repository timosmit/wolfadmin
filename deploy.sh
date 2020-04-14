#!/usr/bin/env bash

# WolfAdmin module for Wolfenstein: Enemy Territory servers.
# Copyright (C) 2015-2020 Timo 'Timothy' Smit

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

curr_version="1.3.0-dev"

read_config() {
    db_type=$(grep -oP '(?<=type = ")(sqlite3|mysql)(?=")' $fs_homepath/$fs_homedir/$fs_game/wolfadmin.toml)

    if [ $db_type == 'sqlite3' ]; then
        db_file=$(grep -oP '(?<=file = ")([a-zA-Z0-9_]+\.db)(?=")' $fs_homepath/$fs_homedir/$fs_game/wolfadmin.toml)
    elif [ $db_type == 'mysql' ]; then
        db_hostname=$(grep -oP '(?<=hostname = ")([a-zA-Z0-9]+)(?=")' $fs_homepath/$fs_homedir/$fs_game/wolfadmin.toml)
        db_port=$(grep -oP '(?<=port = ")([0-9]{0,5})(?=")' $fs_homepath/$fs_homedir/$fs_game/wolfadmin.toml)
        db_database=$(grep -oP '(?<=database = ")([a-zA-Z0-9_]+)(?=")' $fs_homepath/$fs_homedir/$fs_game/wolfadmin.toml)
        db_username=$(grep -oP '(?<=username = ")([a-zA-Z0-9_]+)(?=")' $fs_homepath/$fs_homedir/$fs_game/wolfadmin.toml)
        db_password=$(grep -oP '(?<=password = ")(.+)(?=")' $fs_homepath/$fs_homedir/$fs_game/wolfadmin.toml)
    fi

    echo
}

install_lualibs() {
    echo -n 'copying lualibs...'
    cp -r -u lualibs/ $fs_basepath/$fs_game/
    echo 'done.'
}

install_luascripts() {
    echo -n 'copying luascripts...'
    cp -r -u luascripts/ $fs_basepath/$fs_game/
    echo 'done.'
}

install_configs() {
    echo -n 'copying configs...'
    cp -n config/* $fs_homepath/$fs_homedir/$fs_game/

    if [ $db_type == 'sqlite' ]; then
        sed -i -e "s/type = \"sqlite3\"/type = \"$db_type\"/" $fs_homepath/$fs_homedir/$fs_game/wolfadmin.toml
        sed -i -e "s/file = \"wolfadmin.db\"/file = \"$db_file\"/" $fs_homepath/$fs_homedir/$fs_game/wolfadmin.toml
    elif [ $db_type == 'mysql' ]; then
        sed -i -e "s/type = \"sqlite3\"/type = \"$db_type\"/" $fs_homepath/$fs_homedir/$fs_game/wolfadmin.toml
        sed -i -e "s/file = \"wolfadmin.db\"/# file = \"wolfadmin.db\"/" $fs_homepath/$fs_homedir/$fs_game/wolfadmin.toml
        sed -i -e "s/# hostname = \"localhost\"/hostname = \"$db_hostname\"/" $fs_homepath/$fs_homedir/$fs_game/wolfadmin.toml
        sed -i -e "s/# port = 3306/port = \"$db_port\"/" $fs_homepath/$fs_homedir/$fs_game/wolfadmin.toml
        sed -i -e "s/# database = \"wolfadmin\"/database = \"$db_database\"/" $fs_homepath/$fs_homedir/$fs_game/wolfadmin.toml
        sed -i -e "s/# username = \"wolfadmin\"/username = \"$db_username\"/" $fs_homepath/$fs_homedir/$fs_game/wolfadmin.toml
        sed -i -e "s/# password = \"suchasecret\"/password = \"$db_password\"/" $fs_homepath/$fs_homedir/$fs_game/wolfadmin.toml
    fi

    echo 'done.'
}

install_db_sqlite() {
    echo "$fs_homepath/$fs_homedir/$fs_game/$db_file"

    echo -n 'initializing database...';
    sqlite3 $fs_homepath/$fs_homedir/$fs_game/$db_file < database/new/sqlite.sql
    echo 'done.'
}

install_db_mysql() {
    echo -n 'initializing database...';
    mysql -h $db_hostname -D $db_database -u $db_username -p$db_password < database/new/mysql.sql
    echo 'done.'
}

install_pk3() {
    echo -n 'zipping pk3...';
    pushd pk3
    zip -r -q ../wolfadmin-$curr_version.pk3 .
    popd
    echo 'done.'
    echo -n 'copying pk3...';
    cp wolfadmin-$curr_version.pk3 $fs_basepath/$fs_game
    echo 'done.'
}

install() {
    echo

    if [ -d $fs_basepath/$fs_game/luascripts/wolfadmin ]; then
        echo 'WolfAdmin has already been installed'
        exit
    fi

    install_lualibs
    install_luascripts

    read -p 'db_type     (sqlite3/mysql):      ' db_type

    if [ -z $db_type ]; then
        echo 'db_type cannot be empty'
        exit
    elif [ $db_type != 'sqlite3' ] && [ $db_type != 'mysql' ]; then
        echo 'unknown db_type'
        exit
    fi

    if [ $db_type == 'sqlite3' ]; then
        read -p 'db_file     (wolfadmin.db):       ' db_file

        if [ -z $db_file ]; then
            db_file='wolfadmin.db'
        elif [[ $db_file != *.db ]]; then
            echo 'db_file should end with .db'
            exit
        fi

        if [ -e $fs_homepath/$fs_homedir/$fs_game/$db_file ]; then
            while true; do
                read -p 'database already exists, append? (y/n) ' yn
                case $yn in
                    [Yy]* ) install_db_sqlite; break;;
                    [Nn]* ) echo 'database not created'; break;;
                    * ) echo 'please answer yes or no.';;
                esac
            done
        else
            install_db_sqlite
        fi
    elif [ $db_type == 'mysql' ]; then
        read -p 'db_hostname (localhost):          ' db_hostname

        if [ -z $db_hostname ]; then
            db_hostname='localhost'
        fi

        read -p 'db_port     (3306):               ' db_port

        if [ -z $db_port ]; then
            db_port=3306
        fi

        read -p 'db_database (wolfadmin):          ' db_database

        if [ -z $db_database ]; then
            db_database='wolfadmin'
        fi

        read -p 'db_username (wolfadmin):          ' db_username

        if [ -z $db_username ]; then
            echo 'db_username cannot be empty'
            exit
        fi

        read -s -p 'db_password:                      ' db_password

        if [ -z $db_password ]; then
            echo 'db_password cannot be empty'
            exit
        fi

        echo

        install_db_mysql
    fi

    install_configs

    while true; do
        read -p 'install pk3 (y/n) ' yn
        case $yn in
            [Yy]* ) install_pk3; break;;
            [Nn]* ) echo 'pk3 not installed'; break;;
            * ) echo 'please answer yes or no.';;
        esac
    done

    echo

    echo 'install process finished.'
}

update_lualibs() {
    install_lualibs
}

update_luascripts() {
    echo -n 'removing old luascripts...'
    rm -r $fs_basepath/$fs_game/luascripts/wolfadmin/
    echo 'done.'

    install_luascripts
}

update_configs() {
    install_configs
}

update_db_sqlite() {
    echo -n 'updating database...'
    sqlite3 $fs_homepath/$fs_homedir/$fs_game/$db_file < database/upgrade/$prev_version/sqlite.sql
    echo 'done.'
}

update_db_mysql() {
    echo -n 'updating database...'
    mysql -h $db_hostname -D $db_database -u $db_username -p$db_password < database/upgrade/$prev_version/mysql.sql
    echo 'done.'
}

update_pk3() {
    if [ ! -e $fs_homepath/$fs_homedir/$fs_game/wolfadmin*.pk3 ]; then
        while true; do
            read -p 'install pk3? (y/n) ' yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* ) echo 'pk3 not updated'; return;; # break;;
                * ) echo 'please answer yes or no.';;
            esac
        done
    else
        rm $fs_homepath/$fs_homedir/$fs_game/wolfadmin*.pk3
        echo 'removed old pk3'
    fi

    install_pk3
}

update() {
    echo

    if [ ! -d $fs_basepath/$fs_game/luascripts/wolfadmin ]; then
        echo 'WolfAdmin has not been installed'
        exit
    fi

    read_config

    read -p 'Have you backupped any changes/additions to WolfAdmin sources? (y/n) ' yn

    if [ $yn != 'y' ]; then
        echo 'Please backup any modifications to WolfAdmin.'
        exit
    fi

    if [ $db_type == 'sqlite3' ]; then
        table_check=$(sqlite3 $fs_homepath/$fs_homedir/$fs_game/$db_file "SELECT 1 FROM player" 2>/dev/null)

        if [ $? -eq 1 ]; then
            echo 'Database does not exist'
            exit
        fi

        prev_version=$(sqlite3 $fs_homepath/$fs_homedir/$fs_game/$db_file "SELECT value FROM config WHERE id='schema_version'" 2>/dev/null)

        if [ $? -eq 1 ]; then
            echo 'Database version unknown'
            exit
        fi

        if [ ! -x database/upgrade/$prev_version/sqlite.sql ]; then
            echo "Cannot update from version $prev_version to version $curr_version; no database scripts available."
            exit
        fi
    elif [ $db_type == 'mysql' ]; then
        table_check=$(mysql -h $db_hostname -D $db_database -u $db_username -p$db_password -e "SELECT 1 FROM player" 2>/dev/null)

        if [ $? -eq 1 ]; then
            echo 'Database does not exist'
            exit
        fi

        prev_version=$(mysql -h $db_hostname -D $db_database -u $db_username -p$db_password -e "SELECT value FROM config WHERE id='schema_version'" 2>/dev/null)

        if [ $? -eq 1 ]; then
            echo 'Database version unknown'
        fi

        if [ ! -x database/upgrade/$prev_version/mysql.sql ]; then
            echo "Cannot update from version $prev_version to version $curr_version; no database scripts available."
            exit
        fi
    fi

    update_lualibs
    update_luascripts

    if [ $db_type == 'sqlite3' ]; then
        update_db_sqlite
    elif [ $db_type == 'mysql' ]; then
        update_db_mysql
    fi

    update_pk3
    update_configs

    echo

    echo 'update process finished.'
}

echo "WolfAdmin $curr_version deployment script"

echo

echo "This script is HIGHLY experimental. You cannot use this script for \
WolfAdmin versions pre-1.1.0. Make sure you have backupped your database. I am \
not responsible for any data loss."

echo

echo -n 'Checking package integrity...'
if [ ! -d 'lualibs' ]; then
    echo
    echo 'lualibs dir does not exist'
    exit
elif [ ! -d 'luascripts' ]; then
    echo
    echo 'luascripts dir does not exist'
    exit
elif [ ! -d 'config' ]; then
    echo
    echo 'config dir does not exist'
    exit
elif [ ! -d 'database' ] || [ ! -d 'database/new' ] || \
     [ ! -e 'database/new/sqlite.sql' ] || [ ! -e 'database/new/mysql.sql' ] || \
     [ ! -d 'database/upgrade' ]; then
    echo
    echo 'database dir does not exist or is incomplete'
    exit
elif [ ! -d 'pk3' ]; then
    echo
    echo 'pk3 dir does not exist'
    exit
fi
echo 'OK'

echo -n 'Checking dependencies...'
if [ ! -x "$(command -v sqlite3)" ]; then
    echo
    echo 'sqlite3 executable does not exist'
fi
if [ ! -x "$(command -v mysql)" ]; then
    echo
    echo 'mysql executable does not exist'
fi
echo 'OK'

read -p 'fs_basepath (install directory):  ' fs_basepath
fs_basepath=/home/timo/game/fsb

if [ -z $fs_basepath ]; then
    echo 'fs_basepath cannot be empty'
    exit
elif [ ! -d $fs_basepath ]; then
    echo 'fs_basepath does not exist'
    exit
fi

read -p 'fs_homepath (user directory):     ' fs_homepath
fs_homepath=/home/timo/game/fsh

if [ -z $fs_homepath ]; then
    echo 'fs_homepath cannot be empty'
    exit
elif [ ! -d $fs_homepath ]; then
    echo 'fs_homepath does not exist'
    exit
elif [ -d $fs_homepath/.etlegacy ]; then
    fs_homedir=.etlegacy
elif [ -d $fs_homepath/.wolfet ]; then
    fs_homedir=.wolfet
else
    echo 'fs_homepath does not contain a .etlegacy or .wolfet directory'
    exit
fi

read -p 'fs_game     (e.g. legacy, nq):    ' fs_game
fs_game=mod

if [ -z $fs_game ]; then
    echo 'fs_game cannot be empty'
    exit
elif [ ! -d $fs_basepath/$fs_game ]; then
    echo 'fs_basepath/fs_game does not exist'
    exit
elif [ ! -d $fs_homepath/$fs_homedir/$fs_game ]; then
    echo 'fs_basepath/fs_homedir/fs_game does not exist'
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
