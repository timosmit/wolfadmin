-- new naming convention
ALTER TABLE `aliases`
    RENAME TO `alias`;

ALTER TABLE `levels`
    RENAME TO `level`;

ALTER TABLE `maps`
    RENAME TO `map`;

ALTER TABLE `players`
    RENAME TO `player`;

ALTER TABLE `records`
    RENAME TO `record`;

ALTER TABLE `warns`
    RENAME TO `warn`;

ALTER TABLE `alias`
    DROP FOREIGN KEY `aliasplayer`,
    DROP INDEX `playerid_idx`;
ALTER TABLE `alias`
    CHANGE COLUMN `player` `player_id` INT(10) UNSIGNED NOT NULL;
ALTER TABLE `alias`
    ADD CONSTRAINT `alias_player`
        FOREIGN KEY (`player_id`)
        REFERENCES `player` (`id`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    ADD INDEX `player_idx` (`player_id` ASC);

ALTER TABLE `level`
    DROP FOREIGN KEY `levelplayer`,
    DROP INDEX `leveladmin_idx`,
    DROP FOREIGN KEY `leveladmin`,
    DROP INDEX `levelplayer`;
ALTER TABLE `level`
    CHANGE COLUMN `player` `player_id` INT(10) UNSIGNED NOT NULL,
    CHANGE COLUMN `admin` `admin_id` INT(10) UNSIGNED NOT NULL;
ALTER TABLE `level`
    ADD CONSTRAINT `level_player`
        FOREIGN KEY (`player_id`)
        REFERENCES `player` (`id`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    ADD INDEX `player_idx` (`player_id` ASC),
    ADD CONSTRAINT `level_admin`
        FOREIGN KEY (`admin_id`)
        REFERENCES `player` (`id`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    ADD INDEX `admin_idx` (`admin_id` ASC);

ALTER TABLE `record`
    DROP FOREIGN KEY `spreemap`,
    DROP FOREIGN KEY `kspreeplayer`,
    DROP INDEX `ksplayer_idx`;
ALTER TABLE `record`
    CHANGE COLUMN `mapid` `map_id` INT(10) UNSIGNED NOT NULL,
    CHANGE COLUMN `player` `player_id` INT(10) UNSIGNED NOT NULL;
ALTER TABLE `record`
    ADD CONSTRAINT `record_map`
        FOREIGN KEY (`map_id`)
        REFERENCES `map` (`id`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    ADD CONSTRAINT `record_player`
        FOREIGN KEY (`player_id`)
        REFERENCES `player` (`id`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    ADD INDEX `player_idx` (`player_id` ASC);

ALTER TABLE `warn`
    DROP FOREIGN KEY `warnadmin`,
    DROP INDEX `invoker_idx`,
    DROP FOREIGN KEY `warnplayer`,
    DROP INDEX `playerid_idx`;
ALTER TABLE `warn`
    CHANGE COLUMN `player` `player_id` INT(10) UNSIGNED NOT NULL,
    CHANGE COLUMN `admin` `admin_id` INT(10) UNSIGNED NOT NULL;
ALTER TABLE `warn`
    ADD CONSTRAINT `warn_player`
        FOREIGN KEY (`player_id`)
        REFERENCES `player` (`id`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    ADD INDEX `player_idx` (`player_id` ASC),
    ADD CONSTRAINT `warn_admin`
        FOREIGN KEY (`admin_id`)
        REFERENCES `player` (`id`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    ADD INDEX `admin_idx` (`admin_id` ASC);
