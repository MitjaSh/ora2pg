-- Под суперпользователем (root)

-- Ограничение 1: Управление транзакциями внутри функций запрещено

CREATE OR REPLACE FUNCTION ora2pg.fn_transactions1() RETURNS varchar
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO  ora2pg.tbl_log (dt, msg, comments) VALUES (current_timestamp, '01_fn_transactions1', 'Insert из функции');
	COMMIT;
	RETURN 'P';
END;
$$;

DO $$
begin
	raise notice 'Result: %', ora2pg.fn_transactions1();
end;
$$;

-- SQL Error [2D000]: ERROR: invalid transaction termination
-- Чтобы работало, надо либо убирать COMMIT, либо переделывать функцию в процедуру

CREATE OR REPLACE FUNCTION ora2pg.fn_transactions2() RETURNS varchar
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO ora2pg.tbl_log (dt, msg, comments) VALUES (current_timestamp, '01_fn_transactions2', 'Insert из функции без COMMIT');
	RETURN 'P';
END;
$$;

DO $$
begin
	raise notice 'Result: %', ora2pg.fn_transactions2();
end;
$$;

SELECT * FROM ora2pg.tbl_log ORDER BY DT DESC;

CREATE OR REPLACE procedure ora2pg.pr_transactions1()
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO ora2pg.tbl_log (dt, msg, comments) VALUES (current_timestamp, '01_pr_transactions1', 'Insert из процедуры с COMMIT');
	COMMIT;
END;
$$;

DO $$
begin
	call ora2pg.pr_transactions1();
end;
$$;

SELECT * FROM ora2pg.tbl_log ORDER BY DT DESC;

-- Ограничение 2: Управление транзакциями запрещено в процедуре с блоком обработки исключений 

CREATE OR REPLACE procedure ora2pg.pr_transactions2()
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlstate varchar;
    v_message varchar;
BEGIN
	INSERT INTO ora2pg.tbl_log (dt, msg, comments) VALUES (current_timestamp, '01_pr_transactions2', 'Insert из процедуры с COMMIT и обработкой Exception');
	COMMIT;
exception
	when others then
        GET STACKED DIAGNOSTICS v_sqlstate = RETURNED_SQLSTATE,
                                v_message = MESSAGE_TEXT;
		raise exception 'Re-rised exception: % %', v_sqlstate, v_message;
END;
$$;

DO $$
begin
	call ora2pg.pr_transactions2();
end;
$$;

-- SQL Error [P0001]: ERROR: Rerised exception: 2D000 cannot commit while a subtransaction is active
-- 2D000 cannot commit while a subtransaction is active

-- Обработка Exception реализована через субтранзакции. В начале блока ставится неявный savepoint, к которому откатывается транзакция в случае exception.
-- Внутри субтранзакции нельзя делать COMMIT/ROLLBACK. Отсюда такая ошибка и ограничение.

-- Если требуется делать Commit и обрабатывать Exception, можно разнести их по разным блокам. Делать Commit вне блока с Exception.

CREATE OR REPLACE procedure ora2pg.pr_transactions3()
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlstate varchar;
    v_message varchar;
BEGIN
	begin
		INSERT INTO ora2pg.tbl_log (dt, msg, comments) VALUES (current_timestamp, '01_pr_transactions3', 'Insert из процедуры с COMMIT. Обработка Exception во вложенном блоке.');
	exception
		when others then
	        GET STACKED DIAGNOSTICS v_sqlstate = RETURNED_SQLSTATE,
	                                v_message = MESSAGE_TEXT;
			raise exception 'Re-rised exception: % %', v_sqlstate, v_message;
	end;
	COMMIT;
END;
$$;

DO $$
begin
	call ora2pg.pr_transactions3();
end;
$$;

SELECT * FROM ora2pg.tbl_log ORDER BY DT DESC;

-- Ограничение 3: Если возник Exception, PostgreSQL автоматом откатывает все изменения в транзакции, сделанные в этом блоке (субтранзакцию).
-- Oracle ведет себя по-другому: там исключения PL/SQL никак не влияют на транзакцию.

CREATE OR REPLACE procedure ora2pg.pr_transactions4()
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlstate varchar;
    v_message varchar;
BEGIN
	INSERT INTO ora2pg.tbl_log (dt, msg, comments) VALUES (current_timestamp, '01_pr_transactions3_before_exception', 'Изменения до Exception');
	-- Raise exception
	perform 1/0;
exception
	when others then
	    INSERT INTO ora2pg.tbl_log (dt, msg, comments) VALUES (current_timestamp, '01_pr_transactions3_after_exception', 'Изменения после Exception');
END;
$$;

DO $$
begin
	call ora2pg.pr_transactions4();
end;
$$;

SELECT * FROM ora2pg.tbl_log ORDER BY DT DESC;

-- Видим в таблице только измненеия После Exception. Изменения До Exception были автоматом откатаны в момент возникновения exception.
-- Надо отслеживать, что логика, реализованная в Oracle, не основана на его способности сохранять изменения в транзакции в момент Exception.
-- И если это не так, то придумывать другую логику для PostgreSQL.

