--============================================================================--
--                                                                            --
/* ※替代變量-替代變量	                                                      */
--                                                                            --
--============================================================================--
-- 說明:替代變量的操作類似於鍵盤輸入數據的操作。
-- ex:使用sqlplus操作
SELECT ename, job , sal, hiredate FROM emp WHERE sal>&inputsal; 


-- ex:查詢一個員工編號、姓名、職位、僱用日期、基本工資，查詢的員工姓名由用戶輸入
-- 分析:因為姓名在表中為字串類型並以大寫儲存所以在輸入關鍵字前後加上單引號並使用
-- 轉換大寫函式。
SELECT empno, ename, job , hiredate, sal 
FROM emp WHERE ename=UPPER('&inputename');


-- ex:根據員工姓名的關鍵字(由用戶輸入)查詢員工編號、姓名、職位、僱用日期、
-- 基本工資
SELECT empno, ename, job , hiredate, sal 
FROM emp WHERE ename LIKE '%&inputkeyword%';


-- ex:由用戶輸入僱用日期，要求查詢出所有早於此僱用日期的員工編號、姓名、職位、
-- 僱用日期、基本工資
SELECT empno, ename, job , hiredate, sal 
FROM emp WHERE hiredate<TO_DATE('&inputhiredate','YYYY,MM,DD');


-- ex:操作兩個輸入欄位;輸入查詢員工的職位及工資(高於輸入工資)訊息，而後顯示
-- 員工編號、姓名、職位、僱用日期、基本工資
SELECT empno, ename, job , hiredate, sal 
FROM emp WHERE job=UPPER('&inputjob') AND sal>&inputsal;


-- ➤在SELECT子句之中使用替代變量
-- ex:由用戶決定最終所查詢出來的直行，以及設置的限定條件的內容
SELECT &inputColumnName FROM emp WHERE deptno=&inputDeptno;

-- ➤在FROM子句之中使用替代變量
SELECT * FROM &inputTalbeName;


-- ➤在ORDER BY子句之中使用替代變量
SELECT empno, ename, job, hiredate, sal FROM emp 
WHERE deptno=20
ORDER BY &inputOrderByColume DESC;


-- ➤在GROUP BY子句之中使用替代變量
SELECT &inpuGroupByColume, SUM(sal), AVG(sal) FROM emp 
GROUP BY &inpuGroupByColume ;
-- 因為分組查詢之中，SELECT子句裡面可以出現的欄位一定是GROUP BY子句之中規定的欄位。
-- 為了避免用戶輸入不同欄位而產生錯誤，可使用&&。
SELECT &&inputGroupByColume, SUM(sal), AVG(sal) FROM emp  
GROUP BY &inputGroupByColume ;

-- 但如此操作也再出現一個問題，如果這個時候執行語句會無法輸入欄位，變成第一次執行
-- 的欄位固定住。所以有兩種方式來解決此問題: 1.關閉窗口重啟 2.執行UNDEFINE命令。
UNDEFINE inputGroupByColume;

-- 如果不需要任何替代變量的定義，可以輸入SET DEFINE OFF指定
SET DEFINE OFF;


-- ➤定義替代變量
-- ex:定義一個替代變量
DEFINE inputdname='ACCOUNTING';
-- ex:查詢此替代變量
DEFINE inputdname;
-- ex:使用此替代變量
SELECT * FROM dept WHERE dname='&inputdname';
-- ex:取消定義替代變量
UNDEFINE inputdname;


-- ➤ACCEPT
-- 說明:可以制定替代變量的提示訊息。如果想使用ACCEPT指令，必須結合腳本文件完成。
/*
ACCEPT命令格式:
ACCEPT替代變量名稱[數據類型][FORMAT 格式][PROMPT '提示訊息']
[HIDE]

ACCEPT語法中各個參數的作用如下所示:
替代變量名稱:存儲值的變量名稱，如果該變量不存在，則由SQL*Plus創建該變量，但是在
             定義此替代變量名稱前不能加上"&"。
數據類型:可以是NUMBER、VARCHAR或DATE型數據。
FORMAT 格式:指定格式化模型，例如A10或9.99。
PROMPT 提示訊息:用戶輸入替代變量時的提示訊息。
HIDE:隱藏輸入內容，例如在輸入密碼時沒有顯示。
*/
-- ex:ACCEPT操作形式;操作腳本文件
@C:\Users\user\Desktop\Oracle12.1cSQL\替代變量ACCEPT1.sql;


-- ex:使用ACCEPT定義替代變量
@C:\Users\user\Desktop\Oracle12.1cSQL\替代變量ACCEPT2.sql;


-- ex:隱藏輸入字串
@C:\Users\user\Desktop\Oracle12.1cSQL\替代變量ACCEPT3.sql;


-- ex:FORMAT操作;T限定輸入的數據長度
@C:\Users\user\Desktop\Oracle12.1cSQL\替代變量ACCEPT4.sql;


-- ex:FORMAT操作;控制日期格式的輸入
-- note:PROMRT後不要換行不然提示訊息部會顯示
@C:\Users\user\Desktop\Oracle12.1cSQL\替代變量ACCEPT5.sql;