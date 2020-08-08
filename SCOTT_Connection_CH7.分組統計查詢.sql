-- ※分組統計查詢-統計函數

-- 查找出公司每個月支出的月工資的總和
SELECT SUM(sal)FROM emp;

-- 查詢出公司的最高工資、最低工資、平均工資
SELECT MAX(sal), MIN(sal), ROUND(AVG(sal),2) FROM emp;


-- 統計出公司最早雇用和最晚雇用的雇用日期
SELECT MIN(hiredate) 最早雇用, MAX(hiredate) 最晚雇用 FROM emp;


-- 統計公司工資之中中間的工資值
SELECT MEDIAN(sal) FROM emp;


-- 統計工資的標準差與變異數(方差)
SELECT STDDEV(sal), VARIANCE(sal) FROM emp;



-- 統計出公司的雇用人數
SELECT COUNT(empno), COUNT(*) FROM emp;


-- COUNT():對於COUNT()函數而言，可以傳遞三類內容 1.* 2.欄位 3.DISTINCT 欄位 
-- 如果使用COUNT(欄位)的時候，資料內容為null，那麼null不會進行統計。
-- 如果使用COUNT(DISTINCT 欄位)，如果列上有重複，重複的紀錄也不統計。
-- 使用COUNT(*)最為方便，但建議使用COUNT(欄位)，使一個不可能為null的列進行統計。例如:主鍵。
-- 所有的統計函數中，只有COUNT()函數可以在表中沒有任何數據時依然返回內容。
SELECT COUNT(*), COUNT(empno), COUNT(ename), COUNT(comm)
, COUNT(DISTINCT job) FROM emp;


-- ※分組統計查詢-單欄位分組統計
-- GROUP BY
-- 執行子句順序:FROM、WHERE、GROUP BY、SELECT、ORDER BY
-- ▲注意事項一:
-- 如果在一個查詢之中不存在GROUP BY子句，那麼在SELECT子句之中指允許出現統計函數，其他任何
-- 的欄位都不允許出現。
-- 錯誤程序:
SELECT deptno, COUNT(empno) FROM emp;
-- 正確程序:
SELECT deptno, COUNT(empno) FROM emp GROUP BY deptno;
-- ▲注意事項二:
-- 在統計查詢之中(存在了GROUP BY子句)，SELECT子句之中只允許出現分組欄位(GROUP BY之後定義的
-- 欄位)和統計函數，其他的任何欄位都不允許出現。故，在進行分組操作的時候，遵守一個原則:
-- GROUP BY子句之中允許出現的欄位才是在SELECT子句之中允許出現的欄位。
-- 錯誤程序:
SELECT deptno, ename, COUNT(empno) FROM emp GROUP BY deptno;
-- 正確程序:
SELECT deptno, COUNT(empno) FROM emp GROUP BY deptno;
-- ▲注意事項三:所有統計函數允許嵌套使用。但是一旦使用了嵌套的統計函數之後，SELECT子句之中不
-- 允許再出現任何的欄位，包括分組欄位。
-- ex:求出每個部門平均工資最高的工資
-- 此時因為SELECT子句之中存在了deptno的欄位，所以出現錯誤(ORA-00937: 不是單一群組的群組函數)。
SELECT deptno, MAX(AVG(sal)) FROM emp GROUP BY deptno;
-- 正確程序:
SELECT MAX(AVG(sal)) FROM emp GROUP BY deptno;


-- 統計出每個部門的人數
SELECT deptno, COUNT(empno) FROM emp GROUP BY deptno;


-- 統計出每種職位的最低最高工資
SELECT job, MIN(sal), MAX(sal) FROM emp GROUP BY job;


-- 查詢每個部門的名稱、部門人數、部門平均工資、平均服務年限
-- 分析:
-- 平均服務年限需要計算出年的概念，所以使用MONTHS_BETWEEN()函數
-- 確定所需要的資料表:
-- dept表:部門名稱
-- emp表:部門人數、平均工資、平均服務年限
-- 確定已知的關聯欄位:
-- 員工和部門的關聯 emp.deptno=dept.deptno
-- 步驟一:將dept和emp關聯一起進行查詢，暫時不分組
SELECT 
d.dname, 
e.empno, 
e.sal,
e.hiredate 
FROM dept d,emp e 
WHERE d.deptno=e.deptno;
-- 步驟二:觀察現在的dname欄位(查詢結果，理解為臨時表)，既然重複的列就可以進行分組。
-- 針對臨時表數據進行分組。
SELECT 
d.dname, 
COUNT(e.empno), 
ROUND(AVG(e.sal),2) 部門平均工資 , 
TRUNC(AVG(MONTHS_BETWEEN(SYSDATE,e.hiredate)/12)) 平均服務年限 
FROM dept d,emp e WHERE d.deptno=e.deptno GROUP BY d.dname;
-- 步驟三:針對部門表是包含了四個部門訊息，可是此處只顯示三個部門訊息，需要加入外連接顯示40
-- 部門的統計。
SELECT 
d.dname, 
COUNT(e.empno), 
ROUND(AVG(e.sal),2) 部門平均工資 , 
TRUNC(AVG(MONTHS_BETWEEN(SYSDATE,e.hiredate)/12)) 平均服務年限 
FROM dept d,emp e WHERE d.deptno=e.deptno(+) GROUP BY d.dname;


-- 查詢公司各個工資等級員工數量、平均工資
-- 先使用salgrade和emp進行關聯查詢
SELECT 
s.grade, 
e.empno, 
e.sal  
FROM emp e,salgrade s 
WHERE e.sal BETWEEN s.losal AND s.hisal
;
-- 針對臨時表grade數據進行分組
SELECT 
DECODE(s.grade,'1','E等工資',
      '2','D等工資', 
      '3','C等工資', 
      '4','B等工資', 
      '5','A等工資') 工資等級, 
COUNT(e.empno) 員工數量, 
ROUND(AVG(e.sal),2) 平均工資 
FROM emp e,salgrade s 
WHERE e.sal BETWEEN s.losal AND s.hisal
GROUP BY s.grade
;


-- 統計出領取佣金與不領取佣金的員工平均工資、平均雇用年限、員工人數
SELECT 
e.comm, 
COUNT(e.empno) 員工人數 , 
ROUND(AVG(e.sal),2) 平均工資 , 
TRUNC(AVG(MONTHS_BETWEEN(SYSDATE,e.hiredate)/12)) 平均雇用年限
FROM emp e
GROUP BY e.comm
;
-- 查詢結果會發現，並未顯示出佣金的領與不領的分組，而是變成按照每一種可能出現的佣金數值
-- 來進行分組。因此，需更換查詢過程。首先先查詢出所有領取佣金的員工訊息，再查出不領取佣
-- 金的員工訊息，這兩者查詢結果的返回列形式完全相同則可使用UNION語句。
SELECT 
'領取佣金' 領用類型 , 
COUNT(e.empno) 員工人數 , 
ROUND(AVG(e.sal),2) 平均工資 , 
TRUNC(AVG(MONTHS_BETWEEN(SYSDATE,e.hiredate)/12)) 平均雇用年限
FROM emp e
WHERE comm IS NOT NULL
UNION
SELECT 
'不領取佣金' 領用類型 , 
COUNT(e.empno) 員工人數 , 
ROUND(AVG(e.sal),2) 平均工資 , 
TRUNC(AVG(MONTHS_BETWEEN(SYSDATE,e.hiredate)/12)) 平均雇用年限
FROM emp e
WHERE comm IS NULL
;


-- ※分組統計查詢-多欄位分組統計