WITH persons AS (SELECT 'Fedor' name, 'Ivanovich' second_name, 'Krasnov' surname
                 UNION
                 SELECT 'Ivan', NULL, 'Skvorcov'
                 UNION
                 SELECT 'Olga', '', 'Frolova')
SELECT name || ' ' ||second_name || ' ' ||surname AS full_name
     , name || ' ' ||coalesce(second_name, '') || ' ' ||surname fixed_full_name -- Способ избежать ошибки 1
     , CONCAT(name, ' ', second_name, ' ', surname) fixed_full_name2 -- Способ избежать ошибки 2
     , CONCAT_WS(' ', name, second_name, surname) fixed_full_name3 -- Способ избежать ошибки 3
  FROM persons;

--NULL	Ivan  Skvorcov	Ivan  Skvorcov	Ivan Skvorcov
--Olga  Frolova	Olga  Frolova	Olga  Frolova	Olga  Frolova
--Fedor Ivanovich Krasnov	Fedor Ivanovich Krasnov	Fedor Ivanovich Krasnov	Fedor Ivanovich Krasnov


select 'aaa' || null concat_with_null
     , 'aaa' || '' concat_with_empty
     , CASE WHEN '' = '' THEN 'true' ELSE 'false' END
     , CASE WHEN '' = null THEN 'true' ELSE 'false' END
     , CASE WHEN '' is null THEN 'true' ELSE 'false' END
     ;

--NULL	aaa	true	false	false