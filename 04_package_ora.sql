CREATE OR REPLACE PACKAGE my_package AS

    PROCEDURE pr_set_var(p_val IN VARCHAR2);
    
    FUNCTION fn_get_val RETURN VARCHAR2;
END my_package;
/

CREATE OR REPLACE PACKAGE BODY my_package IS

	-- глобальная переменная видна только внутри пакета
	g_var varchar2(255);
	

    -- Приватная процедура (видна только внутри этого пакета)
    procedure pr_log(p_msg VARCHAR2) IS
    BEGIN
        INSERT INTO tbl_log (dt, msg, comments) VALUES (systimestamp, '04_package', p_msg);
    END;

    -- Публичная процедура для установки значения переменной пакета
    PROCEDURE pr_set_var(p_val IN VARCHAR2) IS
    BEGIN
        pr_log('Set new variable value = '||p_val);
    	g_var := p_val;
    END pr_set_var;

    -- Публичная функция для получения значения переменной пакета
    FUNCTION fn_get_val RETURN VARCHAR2 IS
    BEGIN
        return g_var;
    END fn_get_val;
    
BEGIN -- инициализационный код выполняется единожды за сессию в момент первого обращения к пакету
	pr_log('Start working');
END my_package;
/


begin
	my_package.pr_set_var('Значение');
END;
/

SELECT * FROM tbl_log ORDER BY DT DESC; 

SELECT my_package.fn_get_val FROM dual;