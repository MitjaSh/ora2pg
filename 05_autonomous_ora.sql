CREATE OR REPLACE procedure pr_log_autonomous(p_msg VARCHAR2) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO tbl_log (dt, msg, comments) VALUES (systimestamp, '05_autonomous', p_msg);
	COMMIT;
END;

begin
	pr_log_autonomous('Из автономной транзакции');

    INSERT INTO tbl_log (dt, msg, comments) VALUES (systimestamp, '05_autonomous', 'Из основной транзакции 1');
	ROLLBACK;
    
    INSERT INTO tbl_log (dt, msg, comments) VALUES (systimestamp, '05_autonomous', 'Из основной транзакции 2');
	commit;
END;
/

SELECT * FROM tbl_log ORDER BY DT DESC;