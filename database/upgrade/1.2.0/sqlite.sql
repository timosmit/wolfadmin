-- rename 'incognito' permission to 'noaka'
UPDATE `player_permission` SET `permission`='noaka' WHERE `permission`='incognito';

-- fix mute type column type
ALTER TABLE `mute` RENAME TO `mute_old`;

CREATE TABLE IF NOT EXISTS `mute` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `victim_id` INTEGER NOT NULL,
  `invoker_id` INTEGER NOT NULL,
  `type` INTEGER NOT NULL,
  `issued` INTEGER NOT NULL,
  `expires` INTEGER NOT NULL,
  `duration` INTEGER NOT NULL,
  `reason` TEXT NOT NULL,
  CONSTRAINT `mute_victim` FOREIGN KEY (`victim_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `mute_invoker` FOREIGN KEY (`invoker_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX IF NOT EXISTS `mute_victim_idx` ON `mute` (`victim_id`);
CREATE INDEX IF NOT EXISTS `mute_invoker_idx` ON `mute` (`invoker_id`);

INSERT INTO `mute` (`id`, `victim_id`, `invoker_id`, `type`, `issued`, `expires`, `duration`, `reason`)
    SELECT `id`, `victim_id`, `invoker_id`, `type`, `issued`, `expires`, `duration`, `reason`
    FROM `mute_old`;

DROP TABLE `mute_old`;
