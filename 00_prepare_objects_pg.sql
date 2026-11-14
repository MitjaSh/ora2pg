-- Под суперпользователем (root)

CREATE schema ora2pg;

CREATE TABLE ora2pg.tbl_log (
dt timestamp,
msg varchar(255),
comments varchar(2000)
);

-- Создаем пользрователя (аналог CREATE ROLE ... WITH LOGIN)
CREATE USER my_user WITH PASSWORD 'StrongPassword123';

-- Разрешить использование схемы
GRANT USAGE ON SCHEMA ora2pg TO my_user;

-- Выдать ганты на конктретные объекты
GRANT SELECT ON ora2pg.tbl_log TO my_user;

-- Разрешить создавать объекты в хеме
GRANT CREATE ON SCHEMA ora2pg TO my_user;