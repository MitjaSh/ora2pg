-- Это не будет работать в ванильном PostgreSQL, только в Postgres Pro
CREATE or replace PROCEDURE pr_log_autonomous2 (IN v_msg varchar)
LANGUAGE plpgsql AS $$
BEGIN AUTONOMOUS -- автономная транзакция
	insert into ora2pg.tbl_log (dt, msg, comments) values (clock_timestamp(), '05_autonomous2', v_msg);
END;
$$;


DO $$ begin
	call pr log_autonomous2('Из автономной транзакции');
	insert into ora2pg.tbl_log (dt, msg, comments) values (clock_timestamp(), '05_autonomous2', 'Из основной транзакции 1');
	rollback;
	insert into ora2pg.tbl_log (dt, msg, comments) values (clock_timestamp(), '05_autonomous2', 'Из основной транзакции 2');
	commit;
end $$;


select * from ora2pg.tbl_log order by dt desc;
I