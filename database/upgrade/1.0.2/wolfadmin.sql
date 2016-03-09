ALTER TABLE `wolfadmin`.`aliases`
    RENAME TO `wolfadmin`.`alias`;

ALTER TABLE `wolfadmin`.`levels`
    RENAME TO `wolfadmin`.`level`;

ALTER TABLE `wolfadmin`.`maps`
    RENAME TO `wolfadmin`.`map`;

ALTER TABLE `wolfadmin`.`players`
    RENAME TO `wolfadmin`.`player`;

ALTER TABLE `wolfadmin`.`records`
    RENAME TO `wolfadmin`.`record`;

ALTER TABLE `wolfadmin`.`warns`
    RENAME TO `wolfadmin`.`warn`;

ALTER TABLE `wolfadmin`.`alias`
    DROP FOREIGN KEY `aliasplayer`,
    DROP INDEX `playerid_idx`;
ALTER TABLE `wolfadmin`.`alias`
    CHANGE COLUMN `player` `player_id` INT(10) UNSIGNED NOT NULL;
ALTER TABLE `wolfadmin`.`alias`
    ADD CONSTRAINT `alias_player`
        FOREIGN KEY (`player_id`)
        REFERENCES `wolfadmin`.`player` (`id`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    ADD INDEX `player_idx` (`player_id` ASC);

ALTER TABLE `wolfadmin`.`level`
    DROP FOREIGN KEY `levelplayer`,
    DROP INDEX `leveladmin_idx`,
    DROP FOREIGN KEY `leveladmin`,
    DROP INDEX `levelplayer`;
ALTER TABLE `wolfadmin`.`level`
    CHANGE COLUMN `player` `player_id` INT(10) UNSIGNED NOT NULL,
    CHANGE COLUMN `admin` `admin_id` INT(10) UNSIGNED NOT NULL;
ALTER TABLE `wolfadmin`.`level`
    ADD CONSTRAINT `level_player`
        FOREIGN KEY (`player_id`)
        REFERENCES `wolfadmin`.`player` (`id`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    ADD INDEX `player_idx` (`player_id` ASC),
    ADD CONSTRAINT `level_admin`
        FOREIGN KEY (`admin_id`)
        REFERENCES `wolfadmin`.`player` (`id`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    ADD INDEX `admin_idx` (`admin_id` ASC);

ALTER TABLE `wolfadmin`.`record`
    DROP FOREIGN KEY `spreemap`,
    DROP FOREIGN KEY `kspreeplayer`,
    DROP INDEX `ksplayer_idx`;
ALTER TABLE `wolfadmin`.`record`
    CHANGE COLUMN `mapid` `map_id` INT(10) UNSIGNED NOT NULL,
    CHANGE COLUMN `player` `player_id` INT(10) UNSIGNED NOT NULL;
ALTER TABLE `wolfadmin`.`record`
    ADD CONSTRAINT `record_map`
        FOREIGN KEY (`map_id`)
        REFERENCES `wolfadmin`.`map` (`id`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    ADD CONSTRAINT `record_player`
        FOREIGN KEY (`player_id`)
        REFERENCES `wolfadmin`.`player` (`id`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    ADD INDEX `player_idx` (`player_id` ASC);

ALTER TABLE `wolfadmin`.`warn`
    DROP FOREIGN KEY `warnadmin`,
    DROP INDEX `invoker_idx`,
    DROP FOREIGN KEY `warnplayer`,
    DROP INDEX `playerid_idx`;
ALTER TABLE `wolfadmin`.`warn`
    CHANGE COLUMN `player` `player_id` INT(10) UNSIGNED NOT NULL,
    CHANGE COLUMN `admin` `admin_id` INT(10) UNSIGNED NOT NULL;
ALTER TABLE `wolfadmin`.`warn`
    ADD CONSTRAINT `warn_player`
        FOREIGN KEY (`player_id`)
        REFERENCES `wolfadmin`.`player` (`id`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    ADD INDEX `player_idx` (`player_id` ASC),
    ADD CONSTRAINT `warn_admin`
        FOREIGN KEY (`admin_id`)
        REFERENCES `wolfadmin`.`player` (`id`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    ADD INDEX `admin_idx` (`admin_id` ASC);
