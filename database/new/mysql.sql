CREATE TABLE IF NOT EXISTS `level` (
  `id` int(11) NOT NULL,
  `name` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `level_permission` (
  `level_id` int(11) NOT NULL,
  `permission` varchar(32) NOT NULL,
  PRIMARY KEY (`level_id`,`permission`),
  CONSTRAINT `level_permission_level` FOREIGN KEY (`level_id`) REFERENCES `level` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `player` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `guid` char(32) NOT NULL,
  `ip` varchar(40) NOT NULL,
  `level_id` int(11) NOT NULL,
  `lastseen` int(11) NOT NULL,
  `seen` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `guid` (`guid`),
  KEY `player_level_idx` (`level_id`),
  CONSTRAINT `player_level` FOREIGN KEY (`level_id`) REFERENCES `level` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `player_permission` (
  `player_id` int(11) NOT NULL,
  `permission` varchar(32) NOT NULL,
  PRIMARY KEY (`player_id`,`permission`),
  CONSTRAINT `player_permission_level` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `alias` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `player_id` int(10) unsigned NOT NULL,
  `alias` varchar(128) NOT NULL,
  `cleanalias` varchar(128) NOT NULL,
  `lastused` int(10) unsigned NOT NULL,
  `used` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `player_idx` (`player_id`),
  CONSTRAINT `alias_player` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `victim_id` int(10) unsigned NOT NULL,
  `invoker_id` int(10) unsigned NOT NULL,
  `type` varchar(16) NOT NULL,
  `datetime` int(10) unsigned NOT NULL,
  `reason` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `history_victim_idx` (`victim_id`),
  KEY `history_invoker_idx` (`invoker_id`),
  CONSTRAINT `history_invoker` FOREIGN KEY (`invoker_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `history_victim` FOREIGN KEY (`victim_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `mute` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `victim_id` int(10) unsigned NOT NULL,
  `invoker_id` int(10) unsigned NOT NULL,
  `type` smallint(5) unsigned NOT NULL,
  `issued` int(10) unsigned NOT NULL,
  `expires` int(10) unsigned NOT NULL,
  `duration` int(10) unsigned NOT NULL,
  `reason` varchar(128) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`id`),
  KEY `mute_victim_idx` (`victim_id`),
  KEY `mute_invoker_idx` (`invoker_id`),
  CONSTRAINT `mute_invoker` FOREIGN KEY (`invoker_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `mute_victim` FOREIGN KEY (`victim_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `ban` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `victim_id` int(10) unsigned DEFAULT NULL,
  `invoker_id` int(10) unsigned NOT NULL,
  `issued` int(10) unsigned NOT NULL,
  `expires` int(10) unsigned NOT NULL,
  `duration` int(10) unsigned NOT NULL,
  `reason` varchar(128) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ban_victim_idx` (`victim_id`),
  KEY `ban_invoker_idx` (`invoker_id`),
  CONSTRAINT `ban_invoker` FOREIGN KEY (`invoker_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `ban_victim` FOREIGN KEY (`victim_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `map` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `lastplayed` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `record` (
  `map_id` int(10) unsigned NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `date` int(10) unsigned NOT NULL,
  `record` smallint(5) unsigned NOT NULL,
  `player_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`map_id`,`type`),
  KEY `player_idx` (`player_id`),
  CONSTRAINT `record_map` FOREIGN KEY (`map_id`) REFERENCES `map` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `record_player` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- add levels
INSERT INTO `level` (`id`, `name`) VALUES (0, 'Guest');
INSERT INTO `level` (`id`, `name`) VALUES (1, 'Regular');
INSERT INTO `level` (`id`, `name`) VALUES (2, 'VIP');
INSERT INTO `level` (`id`, `name`) VALUES (3, 'Admin');
INSERT INTO `level` (`id`, `name`) VALUES (4, 'Senior Admin');
INSERT INTO `level` (`id`, `name`) VALUES (5, 'Server Owner');

-- add permissions for level 0
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (0, 'admintest');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (0, 'help');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (0, 'time');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (0, 'greeting');

-- add permissions for level 1
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (1, 'admintest');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (1, 'help');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (1, 'time');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (1, 'greeting');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (1, 'listmaps');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (1, 'listsprees');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (1, 'listrules');

-- add permissions for level 2
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'admintest');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'help');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'time');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'greeting');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'listplayers');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'listteams');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'listmaps');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'listsprees');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'listrules');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'spec999');

-- add permissions for level 3
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'admintest');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'help');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'time');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'greeting');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'listplayers');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'listteams');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'listmaps');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'listsprees');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'listrules');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'listhistory');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'listbans');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'liststats');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'adminchat');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'put');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'dropweapons');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'warn');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'mute');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'voicemute');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'spec999');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'balance');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'cointoss');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'pause');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'nextmap');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'restart');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'botadmin');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'enablevote');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'noinactivity');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'novote');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'nocensor');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'novotelimit');

-- add permissions for level 4
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'admintest');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'help');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'time');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'greeting');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'listplayers');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'listteams');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'listmaps');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'listsprees');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'listrules');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'listhistory');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'listwarns');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'listbans');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'listaliases');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'liststats');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'finger');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'adminchat');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'put');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'dropweapons');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'rename');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'freeze');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'disorient');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'burn');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'slap');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'gib');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'throw');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'glow');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'pants');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'pop');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'warn');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'mute');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'voicemute');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'kick');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'ban');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'spec999');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'balance');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'lockplayers');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'lockteam');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'shuffle');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'swap');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'cointoss');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'pause');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'nextmap');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'restart');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'botadmin');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'enablevote');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'cancelvote');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'passvote');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'news');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'noinactivity');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'novote');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'nocensor');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'nobalance');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'novotelimit');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'noreason');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'teamcmds');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'silentcmds');

-- add permissions for level 5
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'admintest');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'help');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'time');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'greeting');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'listplayers');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'listteams');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'listmaps');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'listsprees');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'listrules');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'listhistory');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'listwarns');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'listbans');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'listaliases');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'liststats');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'finger');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'adminchat');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'put');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'dropweapons');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'rename');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'freeze');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'disorient');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'burn');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'slap');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'gib');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'throw');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'glow');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'pants');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'pop');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'warn');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'mute');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'voicemute');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'kick');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'ban');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'spec999');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'balance');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'lockplayers');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'lockteam');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'shuffle');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'swap');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'cointoss');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'pause');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'nextmap');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'restart');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'botadmin');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'enablevote');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'cancelvote');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'passvote');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'news');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'uptime');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'setlevel');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'readconfig');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'noinactivity');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'novote');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'nocensor');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'nobalance');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'novotelimit');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'noreason');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'perma');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'teamcmds');
INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'silentcmds');

INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'spy');

-- add console to players table
INSERT INTO `player` (`id`, `guid`, `ip`) VALUES (1, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', '127.0.0.1');
INSERT INTO `alias` (`id`, `player_id`, `alias`, `cleanalias`, `lastused`, `used`) VALUES (1, 1, 'console', 'console', 0, 0);
