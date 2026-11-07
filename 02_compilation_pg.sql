-- В PostgreSQL нет понятия инвалидной процедуры/функции.
-- Сервер при создании процедуры проверит только базовый синтаксис, 
-- он успешно сохранит процедуру с другими ошибками разных типов

CREATE OR REPLACE FUNCTION ora2pg.fn_compilation() RETURNS varchar
LANGUAGE plpgsql
AS $$
DECLARE
	v_num numeric;
BEGIN
	-- error:22P02:5:assignment:invalid input syntax for type numeric: "строка"
	v_num := 'строка';

	-- error:42P01:8:SQL statement:relation "ora2pg.unknown_table" does not exist
	select count(*) into v_num from ora2pg.unknown_table;

	--error:22012:11:assignment:division by zero
	v_num := 1/0;

	--error:42P01:15:SQL statement:relation "ora2pg.unknown_table" does not exist
	select count(*) into v_num from ora2pg.unknown_table;
	-- и т.д.

	RETURN 'P';
END;
$$;

-- Обнаружатся эти ошибки только при первом вызове процедуры/функции
select ora2pg.fn_compilation();

-- Но если установить и использовать расширение plpgsql_check, то можно вручную проверять свои объекты
-- Статический анализатор кода сообщает об ошибках процедуры без ее выполнения
-- Проверки, которые в Oracle происходят автоматом в момент создания и компиляции процедуры, в PostgreSQL надо сделать вручную при помощи plpgsql_check.
SELECT * FROM plpgsql_check_function('ora2pg.fn_compilation');