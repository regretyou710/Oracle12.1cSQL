--============================================================================--
--                                                                            --
/* ※分組統計查詢-統計函數                                                    */
--                                                                            --
--============================================================================--
-- ex:查找出公司每個月支出的月工資的總和
SELECT SUM(sal)FROM emp;

-- ex:查詢出公司的最高工資、最低工資、平均工資
SELECT MAX(sal), MIN(sal), ROUND(AVG(sal),2) FROM emp;


-- ex:統計出公司最早雇用和最晚雇用的雇用日期
SELECT MIN(hiredate) 最早雇用, MAX(hiredate) 最晚雇用 FROM emp;


-- ex:統計公司工資之中中間的工資值
SELECT MEDIAN(sal) FROM emp;


-- ex:統計工資的標準差與變異數(方差)
SELECT STDDEV(sal), VARIANCE(sal) FROM emp;


-- ex:統計出公司的雇用人數
SELECT COUNT(empno), COUNT(*) FROM emp;


-- ➤COUNT():對於COUNT()函數而言，可以傳遞三類內容 1.* 2.欄位 3.DISTINCT 欄位 
--   ①如果使用COUNT(欄位)的時候，資料內容為null，那麼null不會進行統計。
--   ②如果使用COUNT(DISTINCT 欄位)，如果列上有重複，重複的紀錄也不統計。
--   ③使用COUNT(*)最為方便，但建議使用COUNT(欄位)，使一個不可能為null的列進行
--     統計。例如:主鍵。
-- 所有的統計函數中，只有COUNT()函數可以在表中沒有任何數據時依然返回內容。
SELECT COUNT(*), COUNT(empno), COUNT(ename), COUNT(comm)
, COUNT(DISTINCT job) FROM emp;
--============================================================================--
--                                                                            --
/* ※分組統計查詢-單欄位分組統計                                              */ 
--                                                                            --
--============================================================================--
-- ➤GROUP BY
-- 執行子句順序:FROM、WHERE、GROUP BY、SELECT、ORDER BY
-- ▲注意事項一:
-- 如果在一個查詢之中不存在GROUP BY子句，那麼在SELECT子句之中只允許出現統計函數，
-- 其他任何的欄位都不允許出現。
-- 錯誤程序:
SELECT deptno, COUNT(empno) FROM emp;
-- 正確程序:
SELECT deptno, COUNT(empno) FROM emp GROUP BY deptno;
-- ▲注意事項二:
-- 在統計查詢之中(存在了GROUP BY子句)，SELECT子句之中只允許出現分組欄位(GROUP BY之後定義
-- 的欄位)和統計函數，其他的任何欄位都不允許出現。故，在進行分組操作的時候，遵守一個原則:
-- GROUP BY子句之中允許出現的欄位才是在SELECT子句之中允許出現的欄位。
-- 錯誤程序:
SELECT deptno, ename, COUNT(empno) FROM emp GROUP BY deptno;
-- 正確程序:
SELECT deptno, COUNT(empno) FROM emp GROUP BY deptno;
-- ▲注意事項三:所有統計函數允許嵌套使用。但是一旦使用了嵌套的統計函數之後，SELECT子句之中
-- 不允許再出現任何的欄位，包括分組欄位。
-- ex:求出每個部門平均工資最高的工資
-- 此時因為SELECT子句之中存在了deptno的欄位，所以出現錯誤(ORA-00937: 不是單一群組的群組函數)。
SELECT deptno, MAX(AVG(sal)) FROM emp GROUP BY deptno;
-- 正確程序:
SELECT MAX(AVG(sal)) FROM emp GROUP BY deptno;


-- ex:統計出每個部門的人數
SELECT deptno, COUNT(empno) FROM emp GROUP BY deptno;


-- ex:統計出每種職位的最低最高工資
SELECT job, MIN(sal), MAX(sal) FROM emp GROUP BY job;


-- ex:查詢每個部門的名稱、部門人數、部門平均工資、平均服務年限
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


-- ex:查詢公司各個工資等級員工數量、平均工資
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


-- ex:統計出領取佣金與不領取佣金的員工平均工資、平均雇用年限、員工人數
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
--============================================================================--
--                                                                            --
/* ※分組統計查詢-多欄位分組統計                                              */ 
--                                                                            --
--============================================================================--
-- ex:要求查詢出每個部門的詳細訊息
-- 分析:
-- 必須包含的欄位:部門編號、名稱、位置
-- 額外欄位:平均工資、總工資、最高工資、最低工資、部門人數
-- 確定所需的資料表:dept表、emp表
-- 確定已知關聯欄位:dept.deptno=emp.deptno
-- 步驟一:
SELECT 
d.deptno, 
d.dname, 
d.loc,
e.sal, 
e.empno 
FROM dept d, emp e 
WHERE d.deptno=e.deptno
;
-- 由上查詢結果顯示deptno、dname、loc三行都在重複，所有具備分組的條件
-- 步驟二:
SELECT 
d.deptno, 
d.dname, 
d.loc,
AVG(e.sal) 平均工資, 
SUM(e.sal) 總工資 , 
MAX(e.sal) 最高工資 , 
MIN(e.sal) 最低工資 , 
COUNT(e.empno) 部門人數 
FROM dept d, emp e 
WHERE d.deptno=e.deptno
GROUP BY d.deptno, d.dname, d.loc
;
-- 由上查詢結果只顯示出3個部門，所以需使用外連接達到顯示出4個部門
-- 步驟三:
SELECT 
d.deptno, 
d.dname, 
d.loc,
ROUND(AVG(e.sal),2) 平均工資, 
SUM(e.sal) 總工資 , 
MAX(e.sal) 最高工資 , 
MIN(e.sal) 最低工資 , 
COUNT(e.empno) 部門人數 
FROM dept d, emp e 
WHERE d.deptno=e.deptno(+)
GROUP BY d.deptno, d.dname, d.loc
;
-- 步驟四:處理資料為空的欄位
SELECT 
d.deptno, 
d.dname, 
d.loc,
NVL(ROUND(AVG(e.sal),2),0) 平均工資, 
NVL(SUM(e.sal),0) 總工資 , 
NVL(MAX(e.sal),0) 最高工資 , 
NVL(MIN(e.sal),0) 最低工資 , 
COUNT(e.empno) 部門人數 
FROM dept d, emp e 
WHERE d.deptno=e.deptno(+)
GROUP BY d.deptno, d.dname, d.loc
;
--============================================================================--
--                                                                            --
/* ※分組統計查詢-HAVING子句                                                  */ 
--                                                                            --
--============================================================================--
-- ➤HAVING:對分組後的數據進行過濾
-- HAVING子句一定要與GROUP BY子句一起使用
-- 子句執行順序:FROM、WHERE、GROUP BY、HAVING、SELECT、ORDER BY
-- 因為GROUP BY、HAVING都在SELECT之前所以無法使用SELECT中的別名
-- ▲對於HAVING和WHERE的區別:
-- WHERE:是在分組之前使用(可以沒有GROUP BY)，不允許使用統計函數
-- HAVING:是在分組之後使用(必須結合GROUP BY)，允許使用統計函數

-- ex:查詢出所有平均工資大於2000的職位訊息、平均工資、員工人數
SELECT 
e.job, 
e.sal, 
e.empno 員工人數 
FROM emp e 
;
-- 無法使用WHERE進行條件過濾，因為WHERE子句執行優先於GROUP BY子句，而且不允許使用統計函數
SELECT 
e.job, 
ROUND(AVG(e.sal),2) 平均工資, 
COUNT(e.empno) 員工人數 
FROM emp e 
WHERE ROUND(AVG(e.sal),2)>2000 
GROUP BY e.job
;

SELECT 
e.job, 
ROUND(AVG(e.sal),2) 平均工資, 
COUNT(e.empno) 員工人數 
FROM emp e 
GROUP BY e.job 
HAVING ROUND(AVG(e.sal),2)>2000
;


-- ex:列出至少有一個員工的所有部門編號、名稱，並統計出這些部門的平均工資、最低工資、最高工資
SELECT d.deptno, d.dname, e.sal FROM emp e,dept d WHERE e.deptno(+)=d.deptno;

SELECT 
d.deptno, 
d.dname, 
ROUND(AVG(e.sal),2) 平均工資 , 
MIN(e.sal) 最低工資 , 
MAX(e.sal) 最高工資 
FROM emp e,dept d 
WHERE e.deptno(+)=d.deptno 
GROUP BY d.deptno, d.dname
HAVING COUNT(e.empno)>1
;


-- ex:顯示非銷售人員工作名稱以及從事同一工作員工的月工資的總和，並且要滿足從事同一工作的員
-- 工的月工資合計大於5000，輸出結果按月工資的合計升序排列。
-- 步驟一:顯示非銷售人員工作名稱
SELECT e.job FROM emp e WHERE e.job!='SALESMAN';
-- 步驟二:從事同一工作員工的月工資的總和，進行統計分組
SELECT e.job , SUM(e.sal) 工資總和 FROM emp e WHERE e.job!='CLERK' GROUP BY e.job;
-- 步驟三:針對分組後的工資總和進行過濾與排序
SELECT 
e.job, 
SUM(e.sal) 工資總和 
FROM emp e
WHERE e.job!='SALESMAN' 
GROUP BY e.job 
HAVING SUM(e.sal)>5000
ORDER BY 工資總和
;