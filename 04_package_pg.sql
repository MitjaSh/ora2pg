-- Этот пример не будет работать в ванильном PostgreSQL, только в Postgres Pro
CREATE OR REPLACE PACKAGE my_package
	-- Вместо CREATE PACKAGE можно руками создать схему my_package
	-- И процедуры/функции в ней с необходимыми директивами (#package #private #export #export on #export off)
	CREATE FUNCTION __init__() RETURNS void AS $$ -- Инициализация пакета. В схеме-пакете такая функция должна быть обязательно.
	#export off
	DECLARE
		g_var varchar; -- private variable
	BEGIN
		call my_package.pr_log('srart working');
	END;
	$$

	CREATE PROCEDURE pr_log(IN v_msg varchar) AS $$ -- внутренняя пакетная процедура
	#private
	BEGIN
		insert into ora2pg.tbl_log (dt, msg, comments) values (clock_timestamp(), '04_package', v_msg);
	END;
	$$

	CREATE PROCEDURE pr_set_var(IN p_val varchar) AS $$
	BEGIN
		call my_package.pr_log('Set new variable value = ||p_val');
		g_var := p_val;
	END;
	$$
	
	CREATE FUNCTION fn_get_var() returns varchar AS $$
	BEGIN
		return g_var;
	END;
	$$
;


-- Блок выполнится с ошибкой, т.к. переменная my_package.g_var private
DO $$
BEGIN
	RAISE INFO 'g_var = %', my_package.g_var;
END;
$$;


-- ERROR: private package function or procedure my_package.pr_log(character varying) called out of its package
DO $$
BEGIN
	call my_package.pr_log('Message from outside.');
END;
$$;


-- Успешно присвоили значения глобальной переменной
DO $$
BEGIN
	call my_package.pr_set_var('My value!');
END;
$$;


-- успешно прочитали глобальную переменную
DO $$
BEGIN
	raise notice "%", my_package.fn_get_var();
END;
$$;

-- Или так
select my_package.fn_get_var();

-- Можно посмотреть, что при этом писалось в лог
select * from ora2pg.tbl_log order by dt desc;