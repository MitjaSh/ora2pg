-- Под пользователем ora2pg

CREATE GLOBAL TEMPORARY TABLE my_temp_table (
    c1 VARCHAR2(100)
) ON COMMIT PRESERVE ROWS; -- ON COMMIT DELETE ROWS


INSERT INTO my_temp_table (c1) VALUES ('Значение первой сессии');
COMMIT;

SELECT * FROM my_temp_table;


-- Во второй сессии выполним
INSERT INTO my_temp_table (c1) VALUES ('Значение второй сессии');

-- И не увидим значение первой сессии
SELECT * FROM my_temp_table;

-- Каждая сессия работает только со своими данными

-- Операции вставки и обновления во временных таблицах генерируют минимум redo-логов (но генерируют undo), что снижает нагрузку на дисковую подсистему по сравнению с обычными таблицами.