-- remove old rows (MySQL only)

DELETE FROM
    `aliases`
WHERE
    `cleanalias`='';
