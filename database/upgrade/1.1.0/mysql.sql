-- remove old rows (MySQL only)

DELETE FROM
    `aliases`
WHERE
    `cleanalias`='';

-- set last seen information
UPDATE `player` SET `lastseen`=(SELECT MAX(`lastused`) AS `lastused` FROM `alias` AS `a` WHERE `a`.`player_id`=`player`.`id`);
UPDATE `player` SET `seen`=(SELECT SUM(`used`) AS `used` FROM `alias` AS `a` WHERE `a`.`player_id`=`player`.`id`);
