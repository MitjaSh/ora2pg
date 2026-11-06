CREATE schema ora2pg;

CREATE TABLE ora2pg.tbl_log (
dt timestamp,
msg varchar(255),
comments varchar(2000)
);
