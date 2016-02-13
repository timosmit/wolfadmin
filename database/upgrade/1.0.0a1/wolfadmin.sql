CREATE TABLE `maps` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `lastplayed` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

CREATE TABLE `records` (
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

INSERT INTO `wolfadmin`.`players` (`id`, `guid`, `ip`) VALUES (1, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', '127.0.0.1');
INSERT INTO `wolfadmin`.`aliases` (`id`, `player`, `alias`, `lastused`, `used`) VALUES (1, 1, 'console', 0, 0);