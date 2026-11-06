CREATE OR REPLACE FUNCTION fn_transactions RETURN varchar2
AS
BEGIN
	INSERT INTO tbl_log (dt, msg, comments) VALUES (systimestamp, '01_transactions_01_first_insert', 'Начали транзакцию');

	-- Вызвали exception
	dbms_output.put_line(1/0);
	COMMIT;
	RETURN 'P';
EXCEPTION
	WHEN OTHERS THEN
		INSERT INTO tbl_log (dt, msg, comments) VALUES (systimestamp, '01_transactions_01_insert_after_exception', 'Транзакция не прервалась из-за Exception, с ней можно дальше работать. Можно обработать exception в функции или работать с транзакцией уже за пределами функции.');
		COMMIT; -- В данном случае мы завершем транзакцию при обработке Exception внутри функции
		RETURN 'E';	
END;
/


BEGIN
	dbms_output.put_line(fn_transactions);
END;
/

SELECT * FROM tbl_log ORDER BY DT DESC; 