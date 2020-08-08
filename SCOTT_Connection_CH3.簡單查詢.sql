﻿-- ※簡單查詢

-- 透過數據庫查詢出所有員工的編號、姓名和年基本工資、日基本工資，以作為年終獎金的發放標準。
SELECT EMPNO, ENAME, SAL*12 AS 年基本工資, SAL/30 AS 日基本工資 FROM EMP;

-- 現在公司每個雇員在年底的時候可以領取5000元的年終獎金，要求查詢員工編號、姓名、和增長後的年基本工資(不包括佣金)。
SELECT EMPNO, ENAME, SAL*12+5000 AS 年基本工資 FROM EMP;

-- 公司每個月為員工增加200元的補助金，此時，要求可以查詢出每個員工的編號、姓名、基本年工資。
SELECT EMPNO, ENAME, (SAL+200)*12+5000 AS 年基本工資, '$' AS 貨幣 FROM EMP;

-- ※使用 || 進行連接顯示
SELECT '編號是:' || EMPNO || '的員工, 姓名是:' || ENAME || ', 基本工資是:' || SAL AS 員工訊息 FROM EMP;