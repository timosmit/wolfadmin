CREATE TABLE IF NOT EXISTS `player` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `guid` TEXT NOT NULL UNIQUE,
  `ip` TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS `alias` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `player_id` INTEGER NOT NULL,
  `alias` TEXT NOT NULL,
  `cleanalias` TEXT NOT NULL,
  `lastused` INTEGER NOT NULL,
  `used` INTEGER NOT NULL,
  CONSTRAINT `alias_player` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX IF NOT EXISTS `alias_player_idx` ON `alias` (`player_id`);

CREATE TABLE IF NOT EXISTS `level` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `player_id` INTEGER NOT NULL,
  `level` INTEGER NOT NULL,
  `admin_id` INTEGER NOT NULL,
  `datetime` INTEGER NOT NULL,
  CONSTRAINT `level_player` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `level_admin` FOREIGN KEY (`admin_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX IF NOT EXISTS `level_player_idx` ON `level` (`player_id`);
CREATE INDEX IF NOT EXISTS `level_admin_idx` ON `level` (`player_id`);

CREATE TABLE IF NOT EXISTS `warn` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `player_id` INTEGER NOT NULL,
  `reason` TEXT NOT NULL,
  `admin_id` INTEGER NOT NULL,
  `datetime` INTEGER NOT NULL,
  CONSTRAINT `warn_player` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `warn_admin` FOREIGN KEY (`admin_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX IF NOT EXISTS `warn_player_idx` ON `warn` (`player_id`);
CREATE INDEX IF NOT EXISTS `warn_admin_idx` ON `warn` (`player_id`);

CREATE TABLE IF NOT EXISTS `map` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `name` TEXT NOT NULL,
  `lastplayed` INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS `record` (
  `map_id` INTEGER NOT NULL,
  `type` INTEGER NOT NULL,
  `date` INTEGER NOT NULL,
  `record` INTEGER NOT NULL,
  `player_id` INTEGER NOT NULL,
  PRIMARY KEY (`map_id`, `type`),
  CONSTRAINT `record_map` FOREIGN KEY (`map_id`) REFERENCES `map` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `record_player` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX IF NOT EXISTS `record_player_idx` ON `record` (`player_id`);

INSERT INTO `player` (`id`, `guid`, `ip`) VALUES (1, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', '127.0.0.1');
INSERT INTO `alias` (`id`, `player_id`, `alias`, `cleanalias`, `lastused`, `used`) VALUES (1, 1, 'console', 'console', 0, 0);