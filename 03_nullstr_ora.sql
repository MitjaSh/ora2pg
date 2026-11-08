WITH persons AS (SELECT 'Fedor' name, 'Ivanovich' second_name, 'Krasnov' surname FROM dual
                 UNION
                 SELECT 'Ivan', NULL, 'Skvorcov' FROM dual
                 UNION
                 SELECT 'Olga', '', 'Frolova' FROM dual)
SELECT name || ' ' ||second_name || ' ' ||surname AS full_name
  FROM persons;

--Fedor Ivanovich Krasnov
--Ivan  Skvorcov
--Olga  Frolova


select 'aaa' || null concat_with_null
     , 'aaa' || '' concat_with_empty
     , CASE WHEN '' = '' THEN 'true' ELSE 'false' END
     , CASE WHEN '' = null THEN 'true' ELSE 'false' END
     , CASE WHEN '' is null THEN 'true' ELSE 'false' END
  FROM dual;

-- aaa	aaa	false	false	true