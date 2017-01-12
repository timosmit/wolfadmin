CREATE TABLE IF NOT EXISTS `level` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `name` TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS `player` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `guid` TEXT NOT NULL UNIQUE,
  `ip` TEXT NOT NULL,
  `level` INTEGER NOT NULL,
  CONSTRAINT `player_level` FOREIGN KEY (`level`) REFERENCES `level` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
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

CREATE TABLE IF NOT EXISTS `player_level` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `player_id` INTEGER NOT NULL,
  `invoker_id` INTEGER NOT NULL,
  `level` INTEGER NOT NULL,
  `datetime` INTEGER NOT NULL,
  CONSTRAINT `level_player` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `level_invoker` FOREIGN KEY (`invoker_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX IF NOT EXISTS `level_player_idx` ON `player_level` (`player_id`);
CREATE INDEX IF NOT EXISTS `level_invoker_idx` ON `player_level` (`invoker_id`);

CREATE TABLE IF NOT EXISTS `history` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `victim_id` INTEGER NOT NULL,
  `invoker_id` INTEGER NOT NULL,
  `datetime` INTEGER NOT NULL,
  `reason` TEXT NOT NULL,
  CONSTRAINT `history_victim` FOREIGN KEY (`victim_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `history_invoker` FOREIGN KEY (`invoker_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX IF NOT EXISTS `history_victim_idx` ON `history` (`victim_id`);
CREATE INDEX IF NOT EXISTS `history_invoker_idx` ON `history` (`invoker_id`);

CREATE TABLE IF NOT EXISTS `mute` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `victim_id` INTEGER NOT NULL,
  `invoker_id` INTEGER NOT NULL,
  `issued` INTEGER NOT NULL,
  `expires` INTEGER NOT NULL,
  `duration` INTEGER NOT NULL,
  `reason` TEXT NOT NULL,
  CONSTRAINT `mute_victim` FOREIGN KEY (`victim_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `mute_invoker` FOREIGN KEY (`invoker_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX IF NOT EXISTS `mute_victim_idx` ON `mute` (`victim_id`);
CREATE INDEX IF NOT EXISTS `mute_invoker_idx` ON `mute` (`invoker_id`);

CREATE TABLE IF NOT EXISTS `ban` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `victim_id` INTEGER NOT NULL,
  `invoker_id` INTEGER NOT NULL,
  `issued` INTEGER NOT NULL,
  `expires` INTEGER NOT NULL,
  `duration` INTEGER NOT NULL,
  `reason` TEXT NOT NULL,
  CONSTRAINT `ban_victim` FOREIGN KEY (`victim_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `ban_invoker` FOREIGN KEY (`invoker_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX IF NOT EXISTS `ban_victim_idx` ON `ban` (`victim_id`);
CREATE INDEX IF NOT EXISTS `ban_invoker_idx` ON `ban` (`invoker_id`);

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

INSERT INTO `level` (`id`, `name`) VALUES (0, 'Guest');
INSERT INTO `level` (`id`, `name`) VALUES (5, 'Admin');
INSERT INTO `player` (`id`, `guid`, `ip`, `level`) VALUES (1, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', '127.0.0.1', 5);
INSERT INTO `alias` (`id`, `player_id`, `alias`, `cleanalias`, `lastused`, `used`) VALUES (1, 1, 'console', 'console', 0, 0);