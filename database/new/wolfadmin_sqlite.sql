CREATE TABLE IF NOT EXISTS `level` (
  `id` INTEGER NOT NULL AUTOINCREMENT,
  `name` TEXT NOT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `level_role` (
  `level_id` INTEGER NOT NULL,
  `role` TEXT NOT NULL,
  PRIMARY KEY (`level_id`, `role`),
  CONSTRAINT `role_level` FOREIGN KEY (`level_id`) REFERENCES `level` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `player` (
  `id` INTEGER NOT NULL AUTOINCREMENT,
  `guid` TEXT NOT NULL UNIQUE,
  `ip` TEXT NOT NULL,
  `level` INTEGER NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `player_level` FOREIGN KEY (`level`) REFERENCES `level` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `alias` (
  `id` INTEGER NOT NULL AUTOINCREMENT,
  `player_id` INTEGER NOT NULL,
  `alias` TEXT NOT NULL,
  `cleanalias` TEXT NOT NULL,
  `lastused` INTEGER NOT NULL,
  `used` INTEGER NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `alias_player` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX IF NOT EXISTS `alias_player_idx` ON `alias` (`player_id`);

CREATE TABLE IF NOT EXISTS `player_level` (
  `id` INTEGER NOT NULL AUTOINCREMENT,
  `player_id` INTEGER NOT NULL,
  `invoker_id` INTEGER NOT NULL,
  `level` INTEGER NOT NULL,
  `datetime` INTEGER NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `level_player` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `level_invoker` FOREIGN KEY (`invoker_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX IF NOT EXISTS `level_player_idx` ON `player_level` (`player_id`);
CREATE INDEX IF NOT EXISTS `level_invoker_idx` ON `player_level` (`invoker_id`);

CREATE TABLE IF NOT EXISTS `history` (
  `id` INTEGER NOT NULL AUTOINCREMENT,
  `victim_id` INTEGER NOT NULL,
  `invoker_id` INTEGER NOT NULL,
  `datetime` INTEGER NOT NULL,
  `reason` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `history_victim` FOREIGN KEY (`victim_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `history_invoker` FOREIGN KEY (`invoker_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX IF NOT EXISTS `history_victim_idx` ON `history` (`victim_id`);
CREATE INDEX IF NOT EXISTS `history_invoker_idx` ON `history` (`invoker_id`);

CREATE TABLE IF NOT EXISTS `mute` (
  `id` INTEGER NOT NULL AUTOINCREMENT,
  `victim_id` INTEGER NOT NULL,
  `invoker_id` INTEGER NOT NULL,
  `issued` INTEGER NOT NULL,
  `expires` INTEGER NOT NULL,
  `duration` INTEGER NOT NULL,
  `reason` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `mute_victim` FOREIGN KEY (`victim_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `mute_invoker` FOREIGN KEY (`invoker_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX IF NOT EXISTS `mute_victim_idx` ON `mute` (`victim_id`);
CREATE INDEX IF NOT EXISTS `mute_invoker_idx` ON `mute` (`invoker_id`);

CREATE TABLE IF NOT EXISTS `ban` (
  `id` INTEGER NOT NULL AUTOINCREMENT,
  `victim_id` INTEGER NOT NULL,
  `invoker_id` INTEGER NOT NULL,
  `issued` INTEGER NOT NULL,
  `expires` INTEGER NOT NULL,
  `duration` INTEGER NOT NULL,
  `reason` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `ban_victim` FOREIGN KEY (`victim_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `ban_invoker` FOREIGN KEY (`invoker_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX IF NOT EXISTS `ban_victim_idx` ON `ban` (`victim_id`);
CREATE INDEX IF NOT EXISTS `ban_invoker_idx` ON `ban` (`invoker_id`);

CREATE TABLE IF NOT EXISTS `map` (
  `id` INTEGER NOT NULL AUTOINCREMENT,
  `name` TEXT NOT NULL,
  PRIMARY KEY (`id`),
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

INSERT INTO `level_role`(`level_id`, `role`) VALUES (0, 'admintest');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (0, 'help');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (0, 'time');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (0, 'greeting');

INSERT INTO `level_role`(`level_id`, `role`) VALUES (0, 'listmaps');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (0, 'listsprees');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (0, 'listrules');

INSERT INTO `level_role`(`level_id`, `role`) VALUES (0, 'adminchat');

INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'admintest');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'help');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'time');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'greeting');

INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'listplayers');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'listteams');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'listmaps');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'listsprees');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'listrules');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'listhistory');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'listwarns');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'listbans');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'listaliases');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'listlevels');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'liststats');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'finger');

INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'adminchat');

INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'put');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'dropweapons');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'rename');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'freeze');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'disorient');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'burn');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'slap');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'gib');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'throw');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'glow');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'pants');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'pop');

INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'warn');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'mute');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'voicemute');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'kick');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'ban');

INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'spec999');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'balance');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'lockplayers');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'lockteam');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'shuffle');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'swap');

INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'pause');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'nextmap');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'restart');

INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'botadmin');

INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'enablevote');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'cancelvote');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'passvote');

INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'news');

INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'uptime');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'setlevel');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'readconfig');

INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'noinactivity');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'novote');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'nocensor');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'nobalance');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'novotelimit');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'noreason');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'perma');

INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'teamcmds');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'silentcmds');

INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'spy');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'incognito');
INSERT INTO `level_role`(`level_id`, `role`) VALUES (5, 'immune');

INSERT INTO `player` (`id`, `guid`, `ip`, `level`) VALUES (1, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', '127.0.0.1', 5);
INSERT INTO `alias` (`id`, `player_id`, `alias`, `cleanalias`, `lastused`, `used`) VALUES (1, 1, 'console', 'console', 0, 0);