-- Под суперпользователем (root)

-- Модуль входит в стандартный дистрибутив, но его надо активировать
CREATE EXTENSION dblink;

CREATE OR REPLACE procedure  ora2pg.pr_log_autonomous(IN p_msg varchar)
LANGUAGE plpgsql
as $$
DECLARE
	v_SQL text := 'INSERT INTO ora2pg.tbl_log (dt, msg, comments) VALUES (clock_timestamp(), ''05_autonomous'', '''||p_msg||''')';
BEGIN
	-- через dblink обращаемся к свой же базе, при этом изменения будут происходить в отдельной транзакции
	PERFORM dblink_exec('dbname=' || current_database() || ' user=root password=123456', v_SQL);
END;
$$


DO $$
begin
	call ora2pg.pr_log_autonomous('Из отдельной транзакции');
    INSERT INTO ora2pg.tbl_log (dt, msg, comments) VALUES (clock_timestamp(), '05_autonomous', 'Из основной транзакции 1');
	ROLLBACK;
    
    INSERT INTO ora2pg.tbl_log (dt, msg, comments) VALUES (clock_timestamp(), '05_autonomous', 'Из основной транзакции 2');
	commit;
end $$;

SELECT * FROM tbl_log ORDER BY DT DESC;

-- Минусы такого решения: расходы на установку нового соединения (времени и количества доступных соединений).