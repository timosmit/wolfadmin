CREATE TABLE IF NOT EXISTS `players` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `guid` char(32) NOT NULL,
  `ip` varchar(40) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `guid` (`guid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `aliases` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `player` int(10) unsigned NOT NULL,
  `alias` varchar(128) NOT NULL,
  `cleanalias` varchar(128) NOT NULL,
  `lastused` int(10) unsigned NOT NULL,
  `used` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `playerid_idx` (`player`),
  CONSTRAINT `aliasplayer` FOREIGN KEY (`player`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `levels` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `player` int(10) unsigned NOT NULL,
  `level` int(11) NOT NULL,
  `admin` int(10) unsigned NOT NULL,
  `datetime` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `leveladmin_idx` (`admin`),
  KEY `levelplayer` (`player`),
  CONSTRAINT `leveladmin` FOREIGN KEY (`admin`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `levelplayer` FOREIGN KEY (`player`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `warns` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `player` int(10) unsigned NOT NULL,
  `reason` varchar(128) NOT NULL,
  `admin` int(10) unsigned NOT NULL,
  `datetime` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `playerid_idx` (`player`),
  KEY `invoker_idx` (`admin`),
  CONSTRAINT `warnadmin` FOREIGN KEY (`admin`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `warnplayer` FOREIGN KEY (`player`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `maps` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `lastplayed` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `records` (
  `mapid` int(10) unsigned NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `date` int(10) unsigned NOT NULL,
  `record` smallint(5) unsigned NOT NULL,
  `player` int(10) unsigned NOT NULL,
  PRIMARY KEY (`mapid`,`type`),
  KEY `ksplayer_idx` (`player`),
  CONSTRAINT `kspreeplayer` FOREIGN KEY (`player`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `spreemap` FOREIGN KEY (`mapid`) REFERENCES `maps` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `players` (`id`, `guid`, `ip`) VALUES (1, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', '127.0.0.1');
INSERT INTO `aliases` (`id`, `player`, `alias`, `lastused`, `used`) VALUES (1, 1, 'console', 0, 0);