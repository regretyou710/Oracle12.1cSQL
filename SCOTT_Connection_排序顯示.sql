-- ※數據排序:ORDER BY。須注意:在所有子句中，ORDER BY子句是放在查語句最後一行，最後一個執行。
-- 執行順序:FROM、WHERE、SELECT、ORDER BY。如此表示在ORDER BY中可以使用SELECT的別名。

-- 查詢員工的完整訊息並按照基本工資由高到低排序
SELECT * FROM emp ORDER BY sal DESC;


-- 查詢員工的完整訊息並按照基本工資由低到高排序
SELECT * FROM emp ORDER BY sal;
SELECT * FROM emp ORDER BY sal ASC;


-- 查詢出所有辦事員(CLERK)的詳細資料，並按照基本工資由低到高排序
SELECT * FROM emp WHERE job='CLERK' ORDER BY sal;


-- 查詢出所有員工訊息，要求按照基本工資由高到低排序，如果工資相等則按照雇用日期由早到晚進行排序。
SELECT * FROM emp ORDER BY sal DESC, hiredate ASC;