-- Под пользователем my_user

select * from ora2pg.tbl_log;

CREATE TABLE ora2pg.tbl_created_by_my_user (
comments varchar(2000)
);

select * from ora2pg.tbl_created_by_my_user;

insert into ora2pg.tbl_created_by_my_user(comments) values ('Insert прошел');

-- У объектов кроме схемы есть еще владелец - это пользователь или роль, обладающий абсолютными правами на объект
SELECT schemaname, tablename, tableowner FROM pg_tables WHERE schemaname = 'ora2pg';
-- Обычно это пользователь, создавший объект. Но владельца можно и переназначать.

-- Под суперпользователем (root)
ALTER TABLE ora2pg.tbl_created_by_my_user OWNER TO root;
ALTER TABLE ora2pg.tbl_created_by_my_user OWNER TO my_user;

-- Есть необязательная возможность создавать одноименные схему и пользователя
-- Если такой пользователь обратится к объекту без указания схемы, то такой объект будет сначала искаться в одноименной схеме, а потом в схеме public. 
