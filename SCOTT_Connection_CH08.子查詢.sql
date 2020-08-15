--============================================================================--
--                                                                            --
/* ※子查詢                                                                   */
--                                                                            --
--============================================================================--
-- 說明:一個完整的查詢之中定義了若干個小的查詢形成的複雜查詢。所有的子查詢在編寫
-- 時一定要使用括號標記。
-- 一個概念:複雜查詢 = 限定查詢 + 多表查詢 + 統計查詢 + 子查詢
-- ▲子查詢的返回結果(數據類型)可分為四種:
--    ①單行單列:返回的是一個具體列的內容，可以理解為一個單值數據。
--    ②單行多列:返回一行數據中多的列的內容。
--    ③多行單列:返回多行紀錄之中同一列的內容，相當於給出了一個操作範圍。
--    ④多行多列:查詢返回的結果是一張臨時表。
-- ▲子查詢的常見操作:
-- WHERE:此時子查詢返回的結果一般都是單行單列、單行多列、多行單列。
-- HAVING:此時子查詢返回的都是單行單列數據，同時為了使用統計函數操作。
-- FROM:此時子查詢返回的結果一般都是多行多列，可以按照一張數據表(臨時表)的形式操作。

-- ex:查詢公司之中工資最低的員工完整訊息
-- 步驟一:透過MIN()函數求得最低工資
SELECT MIN(sal) FROM emp;
-- 步驟二:使用條件查詢出當薪資為MIN()的值
SELECT * FROM emp WHERE sal=800;
SELECT * FROM emp WHERE sal=(SELECT MIN(sal) FROM emp);
--============================================================================--
--                                                                            --
/* ※子查詢-在WHERE之中使用子查詢                                             */
--                                                                            --
--============================================================================--
-- ➤子查詢返回單行單列數據
-- ex:查詢出基本工資比ALLEN低的全部員工訊息
-- 步驟一:
SELECT sal FROM emp WHERE ename='ALLEN';
-- 步驟二:
SELECT * FROM emp WHERE sal<(SELECT sal FROM emp WHERE ename='ALLEN');


-- ex:查詢基本工資高於公司平均薪資的全部員工訊息
-- 步驟一:
SELECT AVG(sal)FROM emp;
-- 步驟二:
SELECT * FROM emp WHERE sal>(SELECT AVG(sal)FROM emp);


-- ex:查找出與ALLEN從事同一工作，並且基本工資高於員工編號為7521的全部員工訊息
-- 步驟一:
SELECT job FROM emp WHERE ename='ALLEN';
SELECT sal FROM emp WHERE empno=7521;
-- 步驟二:
SELECT * FROM emp 
WHERE job=(SELECT job FROM emp WHERE ename='ALLEN')
AND sal>(SELECT sal FROM emp WHERE empno=7521)
AND ename!='ALLEN';


-- ➤子查詢返回單行多列數據
-- ex:查詢與SCOTT從事同一工作且工資相同的員工訊息
-- 步驟一
SELECT job, sal FROM emp WHERE ename='SCOTT';
-- 步驟二
SELECT * FROM emp 
WHERE (job,sal)=(SELECT job, sal FROM emp WHERE ename='SCOTT')
AND ename!='SCOTT';


-- ex:查詢與員工7566從事同一工作且主管相同的全部員工訊息
-- 步驟一
SELECT job, mgr FROM emp WHERE empno=7566;
-- 步驟二
SELECT * FROM emp 
WHERE (job, mgr)=(SELECT job, mgr FROM emp WHERE empno=7566)
AND empno!=7566;


-- ex:查詢與ALLEN從事同一工作且在同一年雇用的全部員工訊息(包括ALLEN)
-- 步驟一
SELECT job, TO_CHAR(hiredate,'YYYY') FROM emp WHERE ename='ALLEN';
-- 步驟二
SELECT * 
FROM emp 
WHERE (job, TO_CHAR(hiredate,'YYYY'))
=(SELECT job, TO_CHAR(hiredate,'YYYY') FROM emp WHERE ename='ALLEN');


-- ➤子查詢返回多行單列數據

-- ➤IN操作符:在一個數據範圍上使用
-- 須注意:
-- 在IN範圍中指定含有null時，不影響返回結果
-- ex:SELECT * FROM emp WHERE mgr IN(7369,7788,null);
-- 在NOT IN範圍中指定含有null時，返回無資料的結果
-- ex:SELECT * FROM emp WHERE mgr NOT IN(7369,7788,null);

-- ex:查詢出與每個部門最低工資相同的全部雇員訊息
-- 步驟一
SELECT MIN(sal) FROM emp GROUP BY deptno;
-- 步驟二
SELECT * FROM emp WHERE sal IN (SELECT MIN(sal) FROM emp GROUP BY deptno);


-- ex:查詢出不與每個部門中最低工資相同的全部員工訊息
-- 步驟一
SELECT MIN(sal) FROM emp GROUP BY deptno;
-- 步驟二
SELECT * FROM emp WHERE sal NOT IN (SELECT MIN(sal) FROM emp GROUP BY deptno);


-- 當多行單列中含有null時
SELECT mgr FROM emp;
-- IN不影響返回結果
SELECT * FROM emp WHERE empno IN (SELECT mgr FROM emp);
-- NOT IN返回無資料結果
SELECT * FROM emp WHERE empno NOT IN (SELECT mgr FROM emp);


-- ➤ANY操作符
-- ANY在使用中有三種型式:
-- ①=ANY:表示與子查詢中的每個元素進行比較，功能與IN類似(然而<>ANY不等價於NOT IN)。
-- ②>ANY:比子查詢中返回結果的最小的要大(包含>=ANY)。
-- ③<ANY:比子查詢中返回結果的最大的要小(包含>=ANY)。
-- 補充:SOME操作符，其功能與ANY相同，Oracle中後來添加的。

-- ex:查找出每個部門經理的最低工資(假設情境:一個部門有多個經理)
SELECT MIN(sal) FROM emp WHERE job='MANAGER' GROUP BY deptno;
-- 對各部門經理的最低工資比較後的員工訊息
-- =ANY
SELECT * FROM emp 
WHERE sal=ANY (SELECT MIN(sal) FROM emp WHERE job='MANAGER' GROUP BY deptno);
-- 此時返回結果與使用IN相同，但如果上述語句使用!=ANY，則是返回一張表的所有資料，
-- 不等同NOT IN。


-- >ANY:返回結果沒有比2450還小的值，都比2450還大
SELECT * FROM emp 
WHERE sal>ANY (SELECT MIN(sal) FROM emp WHERE job='MANAGER' GROUP BY deptno);


-- <ANY:返回結果沒有比2975還大的值，都比2975還小
SELECT * FROM emp 
WHERE sal<ANY (SELECT MIN(sal) FROM emp WHERE job='MANAGER' GROUP BY deptno);


-- ➤ALL操作符
-- ALL在使用中有三種型式:
-- ①<>All:等價於NOT IN(但是=ALL並不等價於IN)。
-- ②>ANY:比子查詢中最大值還要大(包含>=ALL)。
-- ③<ANY:比子查詢中最小值還要小(包含<=ALL)。

-- ex:查找出每個部門經理的最低工資(假設情境:一個部門有多個經理)
SELECT MIN(sal) FROM emp WHERE job='MANAGER' GROUP BY deptno;
-- 對各部門經理的最低工資比較後的員工訊息
-- <>All:工資不等於各部門經理的最低工資的員工訊息
SELECT * FROM emp 
WHERE sal!=ALL (SELECT MIN(sal) FROM emp WHERE job='MANAGER' GROUP BY deptno);
-- 此時返回結果與使用NOT IN相同，但如果上述語句使用=ALL，則是返回無資料結果，不等同IN。


-- >All
SELECT * FROM emp 
WHERE sal>ALL (SELECT MIN(sal) FROM emp WHERE job='MANAGER' GROUP BY deptno);


-- <All
SELECT * FROM emp 
WHERE sal<ALL (SELECT MIN(sal) FROM emp WHERE job='MANAGER' GROUP BY deptno);


-- EXISTS:空數據判斷，判斷子查詢是否有數據返回。如果有數據返回TRUE，反之則返回FALSE。
SELECT * FROM emp WHERE empno=9999;

-- 此時由於不存在員工編號9999，所以EXISTS判斷FALSE返回無資料結果。
SELECT * FROM emp WHERE EXISTS(SELECT * FROM emp WHERE empno=9999);

-- 此時EXISTS判斷TRUE返回所有員工資料結果。
SELECT * FROM emp WHERE EXISTS(SELECT * FROM emp);

-- ➤EXISTS求反，此時EXISTS判斷TRUE返回所有員工資料結果。
SELECT * FROM emp WHERE NOT EXISTS(SELECT * FROM emp WHERE empno=9999);
--============================================================================--
--                                                                            --
/* ※子查詢-在HAVING之中使用子查詢                                            */
--                                                                            --
--============================================================================--
-- 說明:主要目的是對分組過後的數據再次過濾，且與WHERE不同的是，HAVING是在分組後，
-- 可以使用統計函數。一般而言在HAVING子句之中出現子查詢，子查詢返回的數據往往是單
-- 行單列，他是按照一個數值的方式返回，再通過統計函數進行過濾。

-- ex:查詢部門編號、員工人數、平均工資，並要求這些部門的平均工資高於公司平均工資
-- 步驟一:查詢公司平均工資
SELECT ROUND(AVG(sal),2) FROM emp;  
-- 步驟二:按照deptno進行分組，並統計部門的訊息
SELECT 
deptno, 
COUNT(empno), 
ROUND(AVG(sal),2) 
FROM emp 
GROUP BY deptno;
-- 步驟三:執行分組後數據的過濾，需要在HAVING子句中使用子查詢
SELECT 
deptno, 
COUNT(empno), 
ROUND(AVG(sal),2) 
FROM emp 
GROUP BY deptno
HAVING ROUND(AVG(sal),2)>(SELECT ROUND(AVG(sal),2) FROM emp);


-- ex:查詢出每個部門平均工資最高的部門名稱及平均工資
-- 步驟一:求出每個部門最高平均工資
-- note:所有統計函數允許嵌套使用。但是一旦使用了嵌套的統計函數之後，SELECT子句之中
-- 不允許再出現任何的欄位，包括分組欄位。
SELECT MAX(AVG(sal)) FROM emp e GROUP BY e.deptno;
-- 步驟二:引入部門表求得部門名稱
SELECT d.dname, AVG(e.sal) 
FROM emp e ,dept d 
WHERE e.deptno(+)=d.deptno
GROUP BY d.dname;
-- 步驟三:執行分組後數據的過濾
SELECT d.dname, AVG(e.sal) 
FROM emp e ,dept d 
WHERE e.deptno(+)=d.deptno
GROUP BY d.dname
HAVING AVG(sal)=(SELECT MAX(AVG(sal)) FROM emp e GROUP BY e.deptno);
--============================================================================--
--                                                                            --
/* ※子查詢-在FROM之中使用子查詢                                              */
--                                                                            --
--============================================================================--
-- 說明:FROM子句主要功能是確定數據來源，那麼來源都屬於數據表，表的特徵為行+列的
-- 集合。只要是在FROM子句之中出現的內容一般都是多行多列的子查詢返回。

-- ex:查詢出每個部門的編號、名稱、位置、部門人數、平均工資
-- 方式一:複習多欄位分組統計
-- 步驟一:
SELECT d.deptno, d.dname, d.loc FROM dept d GROUP BY d.deptno, d.dname, d.loc;
-- 步驟二:
SELECT 
d.deptno, d.dname, d.loc, 
COUNT(e.empno) ,
AVG(sal) 
FROM emp e,dept d
WHERE e.deptno(+)=d.deptno
GROUP BY d.deptno, d.dname, d.loc;
-- 方式二:使用子查詢
-- 步驟一:查詢出每個部門的基本訊息
SELECT * FROM dept d;
-- 步驟二:統計訊息，按照部門編號分組統計
SELECT 
e.deptno, 
COUNT(e.empno), 
AVG(e.sal) 
FROM emp e
GROUP BY e.deptno;
-- 步驟三:將步驟一的實體表與步驟二統計出來的臨時表結合
SELECT d.deptno, d.dname, d.loc, temp.COUNT(e.empno), temp.AVG(e.sal) 
FROM dept d, 
(SELECT 
e.deptno, 
COUNT(e.empno), 
AVG(e.sal) 
FROM emp e
GROUP BY e.deptno
) temp 
WHERE d.deptno=temp.deptno(+);
-- 需注意:在步驟二進行分組統計建立臨時表時，須將欄位設置別名，否則在步驟三時兩張
-- 表進行合併後要顯示需求欄位會出異常。
SELECT d.deptno, d.dname, d.loc, temp.count, temp.avg 
FROM dept d, 
(SELECT 
e.deptno, 
COUNT(e.empno) count , 
AVG(e.sal) avg 
FROM emp e
GROUP BY e.deptno
) temp 
WHERE d.deptno=temp.deptno(+);
-- 由以上兩種操作方式都可以實現同樣的結果，那麼該使用哪種?為了解決此問題，可以將
-- 數據擴大100倍，即:emp表中的數據為1400條紀錄，而dept表中的數據為400條紀錄。
-- 方法一:多欄位分組實現
-- 當dept和emp表關聯的時候一定會存在笛卡爾積，數據量 = emp表的1400條 * dpet表的
-- 400條 = 560000條紀錄。
-- 方法二:子查詢
-- 統計:emp表的1400條紀錄，而且最終的統計結果的行數不可能超過400行(在步驟二透過
-- 部門編號分類統計，而分類只有4種*100倍)。
-- 多表關聯:dpet表的400條紀錄(步驟一的100倍) * 子查詢的最多400條紀錄(步驟二的100倍) 
-- = 160000條紀錄。
-- 最終結果:160000 + 1400 = 161400條紀錄。
-- 所以使用子查詢可以解決多表查詢所帶來的效能問題。


-- ex:查詢出所有在"SALES"(銷售部)工作的員工的編號、姓名、基本工資、獎金、職位、
-- 雇用日期、部門的最高和最低工資
-- 步驟一:找出銷售部的編號
SELECT deptno FROM dept WHERE dname='SALES';
-- 步驟二:透過步驟一查出該部門的員工訊息
SELECT 
empno, ename, sal, comm, job, hiredate
FROM emp 
WHERE deptno=(SELECT deptno FROM dept WHERE dname='SALES');
-- 步驟三:統計最高和最低工資
SELECT deptno don, MAX(sal) maxsal , MIN(sal) minsal FROM emp GROUP BY deptno;
-- 步驟四:步驟三結合到步驟二
-- 說明:在步驟二使用統計函數時的限制;
-- (A)統計函數1.單獨使用 2.結合GROUP BY使用，單獨使用的時後SELECT子句之中無法
--    出現任何欄位，結合GROUP BY使用時，SELECT子句之中只允許出現分組欄位。
-- (B)統計函數嵌套時不允許出現任何欄位包括分組欄位。
-- 由上述兩者限制下，直接進行步驟四會發現，整個SELECT查詢裡面需要統計查詢，但
-- 是卻無法直接使用統計查詢，那麼就可以在子查詢中直接完成，而且子查詢一定返回
-- 多行多列的數據，在FROM子句中出現。
SELECT 
e.empno, e.ename, e.sal, e.comm, e.job, e.hiredate, 
t.maxsal, t.minsal
FROM emp e, 
(SELECT deptno dno, MAX(sal) maxsal , MIN(sal) minsal 
FROM emp GROUP BY deptno) t
WHERE deptno=(SELECT deptno FROM dept WHERE dname='SALES') 
AND e.deptno=t.dno;


-- ex:查詢出所有工資高於公司平均工資的員工編號、姓名、基本工資、職位、雇用日期
-- 、所在部門名稱、位置、主管姓名、公司的工資等級、部門人數、平均工資、平均服務
-- 年限。
-- 確定所需要的表:
-- emp表:員工編號、姓名、基本工資、職位、雇用日期
-- dept表:部門名稱、位置
-- emp表:主管姓名
-- salgrade表:工資等級
-- emp表:統計部門人數、平均工資、平均服務年限
-- 確定已知關聯欄位:
-- 員工和部門:emp.dpetno=dept.deptno
-- 員工和主管編號:emp.mgr=memp.empno
-- 員工和工資等級:sal BETWEEN salgrade.losal AND salgrade.hisal
-- 步驟一:使用AVG()函數統計公司的平均工資，結果返回單行單列，一定是在WHERE或是
-- HAVING中
SELECT AVG(sal) FROM emp;
-- 步驟二:查出高於步驟一的員工編號、姓名、基本工資、職位、雇用日期
SELECT empno, ename, sal, job, hiredate
FROM emp
WHERE sal>(SELECT AVG(sal) FROM emp);
-- 步驟三:加入dept表關聯查出部門名稱、位置
SELECT empno, ename, sal, job, hiredate, 
dname, loc 
FROM emp, dept 
WHERE sal>(SELECT AVG(sal) FROM emp)
AND emp.deptno=dept.deptno;
-- 步驟四:加入emp表自身關聯查出主管姓名
SELECT e.empno, e.ename, e.sal, e.job, e.hiredate, 
dname, loc, memp.ename mgrname
FROM emp e, dept, emp memp 
WHERE e.sal>(SELECT AVG(sal) FROM emp) 
AND e.deptno=dept.deptno
AND e.mgr=memp.empno(+);
-- 步驟五:加入salgrade表關聯查出工資等級
SELECT e.empno, e.ename, e.sal, e.job, e.hiredate, 
dname, loc, memp.ename mgrname, s.grade 
FROM emp e, dept, emp memp, salgrade s 
WHERE e.sal>(SELECT AVG(sal) FROM emp) 
AND e.deptno=dept.deptno
AND e.mgr=memp.empno(+)
AND e.sal BETWEEN s.losal AND s.hisal;
-- 步驟六:透過統計分組查出部門人數、平均工資、平均服務年限
SELECT 
deptno, 
COUNT(deptno) count , 
ROUND(AVG(sal),2) avgsal , 
TRUNC(AVG(MONTHS_BETWEEN(SYSDATE,hiredate)/12),2) avghiredate 
FROM emp GROUP BY deptno;
-- 步驟七:加入統計結果
SELECT e.empno, e.ename, e.sal, e.job, e.hiredate, 
dname, loc, memp.ename mgrname, s.grade, t.count, t.avgsal, t.avghiredate  
FROM emp e, dept, emp memp, salgrade s , 
(SELECT 
deptno dno, 
COUNT(deptno) count , 
ROUND(AVG(sal),2) avgsal , 
TRUNC(AVG(MONTHS_BETWEEN(SYSDATE,hiredate)/12),2) avghiredate 
FROM emp GROUP BY deptno) t 
WHERE e.sal>(SELECT AVG(sal) FROM emp) 
AND e.deptno=dept.deptno
AND e.mgr=memp.empno(+)
AND e.sal BETWEEN s.losal AND s.hisal
AND e.deptno=t.dno;


-- ex:列出工資比"ALLEN"或"CLARK"多的所有員工的編號、姓名、基本工資、部門名稱
-- 、其主管姓名、部門人數。
/*
-- 步驟一:
SELECT sal FROM emp WHERE ename='ALLEN'
UNION 
SELECT sal FROM emp WHERE ename='CLARK';
-- 步驟二:
SELECT empno, ename, sal 
FROM emp WHERE sal>(SELECT sal FROM emp WHERE ename='ALLEN')
UNION
SELECT empno, ename, sal 
FROM emp WHERE sal>(SELECT sal FROM emp WHERE ename='CLARK');
-- 步驟三:
SELECT e.empno, e.ename, e.sal, d.dname
FROM emp e, dept d
WHERE e.sal>(SELECT sal FROM emp WHERE ename='ALLEN') 
AND e.deptno=d.deptno 
UNION
SELECT e.empno, e.ename, e.sal, d.dname
FROM emp e, dept d 
WHERE e.sal>(SELECT sal FROM emp WHERE ename='CLARK') 
AND e.deptno=d.deptno;
-- 步驟四:
SELECT e.empno, e.ename, e.sal, d.dname, memp.ename mgrname 
FROM emp e, dept d, emp memp 
WHERE e.sal>(SELECT sal FROM emp WHERE ename='ALLEN') 
AND e.deptno=d.deptno 
AND e.mgr=memp.empno(+) 
UNION
SELECT e.empno, e.ename, e.sal, d.dname, memp.ename mgrname
FROM emp e, dept d, emp memp 
WHERE e.sal>(SELECT sal FROM emp WHERE ename='CLARK') 
AND e.deptno=d.deptno 
AND e.mgr=memp.empno(+);
-- 步驟五:
SELECT COUNT(deptno) deptcount FROM emp GROUP BY deptno;
-- 步驟六:
SELECT e.empno, e.ename, e.sal, d.dname, memp.ename mgrname , t.deptcount 
FROM emp e, dept d, emp memp, 
(SELECT deptno, COUNT(deptno) deptcount FROM emp GROUP BY deptno) t 
WHERE e.sal>(SELECT sal FROM emp WHERE ename='ALLEN') 
AND e.deptno=d.deptno 
AND e.mgr=memp.empno(+) 
AND e.deptno=t.deptno 
AND e.ename NOT IN('ALLEN','CLARK') 
UNION
SELECT e.empno, e.ename, e.sal, d.dname, memp.ename mgrname , t.deptcount 
FROM emp e, dept d, emp memp, 
(SELECT deptno, COUNT(deptno) deptcount FROM emp GROUP BY deptno) t 
WHERE e.sal>(SELECT sal FROM emp WHERE ename='CLARK') 
AND e.deptno=d.deptno 
AND e.mgr=memp.empno(+) 
AND e.deptno=t.deptno 
AND e.ename NOT IN('ALLEN','CLARK');
*/
-- 確定所需要的表:
-- emp表:員工編號、姓名、基本工資
-- dept表:部門名稱
-- emp表:主管姓名
-- emp表:統計部門人數
-- 確定已知關聯欄位:
-- 員工和部門:emp.dpetno=dept.deptno
-- 員工和主管編號:emp.mgr=memp.empno
-- 步驟一:因為結果返回多行單列，多行單列的判斷只能夠使用IN、ANY、ALL
SELECT sal FROM emp WHERE ename IN('ALLEN','CLARK');
-- 步驟二:查詢員工訊息
SELECT e.empno, e.ename, e.sal 
FROM emp e 
WHERE e.sal>ANY(SELECT sal FROM emp WHERE ename IN('ALLEN','CLARK')) 
AND e.ename NOT IN('ALLEN','CLARK');
-- 步驟三:加入部門表，列出部門名稱
SELECT e.empno, e.ename, e.sal ,d.dname 
FROM emp e ,dept d 
WHERE e.sal>ANY(SELECT sal FROM emp WHERE ename IN('ALLEN','CLARK')) 
AND e.ename NOT IN('ALLEN','CLARK') 
AND e.deptno=d.deptno;
-- 步驟四:使用emp表自身關聯主管編號
SELECT e.empno, e.ename, e.sal ,d.dname , memp.ename mgrname 
FROM emp e ,dept d , emp memp 
WHERE e.sal>ANY(SELECT sal FROM emp WHERE ename IN('ALLEN','CLARK')) 
AND e.ename NOT IN('ALLEN','CLARK') 
AND e.deptno=d.deptno 
AND e.mgr=memp.empno(+);
-- 步驟五:統計分組部門人數
SELECT deptno don, COUNT(empno) count FROM emp GROUP BY deptno;
-- 步驟六:步驟四結合步驟五
SELECT e.empno, e.ename, e.sal ,d.dname , memp.ename mgrname , 
t.count deptcount 
FROM emp e ,dept d , emp memp , 
(SELECT deptno don, COUNT(empno) count FROM emp GROUP BY deptno) t 
WHERE e.sal>ANY(SELECT sal FROM emp WHERE ename IN('ALLEN','CLARK')) 
AND e.ename NOT IN('ALLEN','CLARK') 
AND e.deptno=d.deptno 
AND e.mgr=memp.empno(+) 
AND e.deptno=t.don;


-- ex:列出公司各部門的經理(假設每個部門只有一個經理，job為"MANAGER")的姓名、
-- 工資、部門名稱、部門人數、部門平均工資
-- 確定所需要的表:
-- emp表:姓名、工資
-- dept表:部門名稱
-- emp表:部門人數、部門平均工資
-- 確定已知關聯欄位:
-- 員工(經理)和部門:emp.deptno=dept.deptno
-- 步驟一:
SELECT ename, sal FROM emp WHERE job IN ('MANAGER');
-- 步驟二:
SELECT e.ename, e.sal , d.dname 
FROM emp e ,dept d
WHERE job IN ('MANAGER')
AND e.deptno=d.deptno;
-- 步驟三:
SELECT COUNT(empno) count , ROUND(AVG(sal),2) avgsal FROM emp GROUP BY deptno;
-- 步驟四:
SELECT e.ename, e.sal , d.dname , t.count, t.avgsal 
FROM emp e ,dept d, 
(SELECT 
deptno dno, 
COUNT(empno) count , 
ROUND(AVG(sal),2) avgsal 
FROM emp 
GROUP BY deptno) t 
WHERE job IN ('MANAGER')
AND e.deptno=d.deptno 
AND e.deptno=t.dno;
--============================================================================--
--                                                                            --
/* ※子查詢-在SELECT之中使用子查詢                                            */
--                                                                            --
--============================================================================--
-- 簡述:子查詢可以出現任意位置上，不過從實際的項目來講，在WHERE、FROM、HAVING
-- 子句之中使用子查詢的情況還是比較多的，而對於SELECT子句，只能是以一種介紹的
-- 形式進行說明。
-- ex:查詢出公司每個部門的編號、名稱、位置、部門人數、平均工資
-- 方式一:SELECT子查詢分組
SELECT 
d.deptno, d.dname, d.loc, 
(
SELECT COUNT(empno)
FROM emp e 
WHERE e.deptno=d.deptno
GROUP BY e.deptno
) count , 
(
SELECT AVG(sal)
FROM emp e 
WHERE e.deptno=d.deptno
GROUP BY e.deptno
) avgsal
FROM dept d;
-- 方式二:SELECT子查詢不分組
SELECT 
d.deptno, d.dname, d.loc, 
(
SELECT COUNT(empno)
FROM emp e 
WHERE e.deptno=d.deptno
) count , 
(
SELECT AVG(sal)
FROM emp e 
WHERE e.deptno=d.deptno
) avgsal
FROM dept d;
-- 由上兩者執行後顯示，分組與不分組返回結果相同，原因是執行SELECT子句時已經
-- 先取得當前部門的訊息。
--============================================================================--
--                                                                            --
/* ※子查詢-WITH子句                                                          */
--                                                                            --
--============================================================================--
-- 簡述:可以使用WITH子句創建臨時查詢表。臨時表實際上就是一個查詢結果，如果
-- 一個查詢結果返回是多行多列，那麼就可以將其定義在FROM子句之中，表示其為一張
-- 臨時表。除了在FROM子句之中出現臨時表之外，也可以利用WITH子句直接定義臨時表
-- ，就可以繞開FROM子句。

-- ex:查詢每個部門的編號、名稱、位置、部門平均工資、人數
WITH e AS(
SELECT deptno, ROUND(AVG(sal),2) avgsal, COUNT(empno) count 
FROM emp GROUP BY deptno 
)
SELECT d.deptno, d.dname, d.loc ,e.avgsal, e.count 
FROM dept d, e 
WHERE d.deptno=e.deptno(+);


-- ex:查詢每個部門工資最高的員工編號、姓名、職位、雇用日期、工資、部門編號、
-- 部門名稱，顯示的結果按照部門編號進行排序。
WITH e AS(
SELECT 
deptno dno, MAX(sal) maxsal 
FROM emp 
GROUP BY deptno
)
SELECT emp.empno, emp.ename, emp.job, emp.hiredate, emp.sal, d.deptno, d.dname 
FROM dept d, e, emp emp
WHERE d.deptno=e.dno
AND e.maxsal=emp.sal
AND e.dno=emp.deptno 
ORDER BY emp.deptno;
--============================================================================--
--                                                                            --
/* ※子查詢-分析函數(Oracle 8)                                                */
--                                                                            --
--============================================================================--
-- 簡述:傳統SQL就是SQL標準規定的語法，SELECT、FROM、WHERE、GROUP BY、HAVING、
-- ORDER BY，但是傳統SQL所能完成的功能實際上不多。
-- 在分析函數之中也可以使用若干統計函數，COUNT()等進行操作。

-- 基本語法:
/*
函數名稱([參數]) VOER (
PARTITION BY 子句 欄位,....
[ORDER BY 子句 欄位,..[ASC][DESC][NULLS FIRST][NULLS LAST]]
[WINDOWING 子句]);
*/
-- 語法組成如下:
-- 函數名稱:類似於統計函數(COUNT()、SUM()等)，但是在此時有了更多的函數支持。
-- OVER子句:為分析函數指名一個查詢結果集，此語句在SELECT子句之中使用。
-- PARTITION BY子句:將一個簡單的結果集分為N組(或稱為分區)，而後按照不同的組
-- 對數據進行統計。
-- NULLS FIRST|NULLS LAST:表示返回數據行中包含NULL值是出現在排序序列前還是尾。
-- WINDOWING子句(代名詞):給定在定義變化的固定的數據窗口方法，分析函數將對此
--                       數據進行操作。
-- ORDER BY子句:主要就是進行排序，但是現在實現的是分區內數據的排序，而這個排序
--              會直接影響到最終的查詢結果。
-- ORDER BY子句選項:
--    NULLS FIRST:表示在進行排序前，出現null值的數據行排列在最前面。
--    NULLS LAST:表示出現的null值數據行排列在最後面。

-- 在分析函數之中存在有三種子句:PARTITION BY、ORDER BY、WINDOWING，而這三種子句
-- 的組合順序有如下幾種
-- 第一種組合:函數名稱([參數, ...])OVER(PARTITION BY子句,ORDER BY子句,WINDOWING
--            子句);
-- 第二種組合:函數名稱([參數, ...])OVER(PARTITION BY子句,ORDER BY子句);
-- 第三種組合:函數名稱([參數, ...])OVER(PARTITION BY子句);
-- 第四種組合:函數名稱([參數, ...])OVER(ORDER BY子句,WINDOWING子句);
-- 第五種組合:函數名稱([參數, ...])OVER(ORDER BY子句);
-- 第六種組合:函數名稱([參數, ...])OVER();


-- ➤PARTITION子句
-- ex:使用PARTITION子句
SELECT deptno, ename, sal FROM emp;
-- 這個時候只是一個簡單查詢，但是在這個SELECT子句裡面是不可能出現統計函數，如:
-- COUNT()、SUM()，因為統計函數1.單獨使用 2.與GROUP BY一起使用。但有了分析函數的
-- 支持後:
SELECT deptno, ename, 
SUM(sal) OVER(PARTITION BY deptno) sum
FROM emp;
-- 現在的數據是按照部門的範疇進行統計，而後每行數據之後都會有這個統計結果存在。


-- ex:不使用PARTITION進行分區，直接使用OVER子句操作
SELECT deptno, ename, 
SUM(sal) OVER() sum
FROM emp;

SELECT SUM(sal) FROM emp;
-- 如果沒有分區，那麼會把所有的數據當成一個區，一起進行統計。


-- ex:透過PARTITION設置多個分區欄位
SELECT deptno, ename, job, 
SUM(sal) OVER(PARTITION BY deptno, job) sum
FROM emp;


-- ➤ORDER BY子句
-- ex:ORDER BY子句操作;按照部門編號分區，而後按照裡面的工資進行降序排列
SELECT deptno, ename, sal, 
RANK() OVER(PARTITION BY deptno ORDER BY sal DESC) rk
FROM emp;
-- RANK():排名，兩個工資相同併列第一


-- ex:設置多個排序欄位
SELECT deptno, ename, sal, hiredate, 
RANK() OVER(PARTITION BY deptno ORDER BY sal, hiredate DESC) rk
FROM emp;


-- ex:直接使用ORDER BY排序所有數據;現在不寫分區操作，那麼就表示所有數據進行排序。
SELECT deptno, ename, sal, hiredate, 
SUM(sal) OVER(ORDER BY ename DESC) sum
FROM emp;
-- 第二筆sum = 第一筆sum + 第二筆sal，第三筆sum = 第二筆sum + 第三筆sal


-- ➤NULLS FIRST|NULLS LAST
-- ex: NULLS FIRST|NULLS LAST操作
SELECT deptno, ename, sal, comm, 
RANK() OVER(ORDER BY comm DESC) rk,
SUM(sal) OVER(ORDER BY comm DESC) sum
FROM emp;
-- 將comm中的null排在最後
SELECT deptno, ename, sal, comm, 
RANK() OVER(ORDER BY comm DESC NULLS LAST) rk,
SUM(sal) OVER(ORDER BY comm DESC NULLS LAST) sum
FROM emp;


-- ➤WINDOWING子句
-- 分窗子句主要是用於定義一個變化或固定的數據窗口方法，主要用於定義分析函數在
-- 操作行的集合，分窗子具有兩種實現方式:
-- 實現一:值域窗(RANGE WINDOW)，邏輯偏移。當前分區之中當前行的前N行到當前行的
--        紀錄集。
-- 實現二:行窗(ROWS WINDOW)，物理偏移。以排序的結果順序計算偏移當前行的起始行
--        紀錄集。
-- 而如果想要指定RANGE或ROWS的偏移量，則可以採用如下的幾種排序列:
-- 	RANGE|ROWS 數字 PRECEDING;
-- 	RANGE|ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW;
-- 	RANGE|ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING;
-- 以上的幾種排列之中包含的概念如下:
-- 	PRECEDING:主要是設置一個偏移量，這個偏移量可以是用戶設置的數字，或是其他
--                標記。
-- 	BETWEEN...AND:設置一個偏移量的操作範圍。
-- 	UNBOUNDED PRECEDING:不限制偏移量大小。
-- 	FOLLOWING:如果不寫此語句表示使用上N行與當前行指定數據比較，如果編寫此語句
--               ，表示當前行與下N行數據比較。

-- ex:在sal上設置偏移量;RANGE子句操作
-- 未進行RANG子句操作前:向上n行偏移
SELECT deptno, ename, sal,  
SUM(sal) OVER(PARTITION BY deptno ORDER BY sal) sum 
FROM emp;
-- 進行RANGE子句操作後:
-- 說明:對deptno分區後，每列的sal進行邏輯偏移
/*
<note:超出範圍不累加>
第二列sal:2450超出第一列sal:1300+偏移量300範圍內所以第二列sum=2450。
1300<= 第二列sal <=1600

第五列sal:1100在第四列sal:800+偏移量300範圍內所以第五列sum=1100+800。800
<= 第五列sal <=1100

第七列sal:3000在第六列sal:2975+偏移量300範圍內所以第七列sum=2975+3000。
2975<= 第七列sal <=3275
第八列sal:3000在第七列sal:2975+偏移量300範圍內所以第八列sum=2975+3000。
2975<= 第八列sal <=3275
因為第七、八列sal值相同所以兩者視為一區，兩者sum都為2975+3000+3000
*/
SELECT deptno, ename, sal,  
SUM(sal) OVER(PARTITION BY deptno ORDER BY sal RANGE 300 PRECEDING) sum 
FROM emp;


-- ex:設置偏移量為300，採用向下匹配方式處理(向下偏移)
SELECT deptno, ename, sal,  
SUM(sal) OVER(PARTITION BY deptno ORDER BY sal 
RANGE BETWEEN 0 PRECEDING AND 300 FOLLOWING) sum 
FROM emp;


-- ex:匹配當前行數據
SELECT deptno, ename, sal,  
SUM(sal) OVER(PARTITION BY deptno ORDER BY sal 
RANGE BETWEEN 0 PRECEDING AND CURRENT ROW) sum 
FROM emp;
-- 在sal中有相同數據時，偏移量為0，因為分區兩筆sal值相加後視為同一筆


-- ex:使用UNBOUNDED不設置邊界;在一個區域內，進行逐行的操作
SELECT deptno, ename, sal,  
SUM(sal) OVER(PARTITION BY deptno ORDER BY sal 
RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) sum 
FROM emp;


-- ex:設置兩行物理偏移
SELECT deptno, ename, sal,  
SUM(sal) OVER(PARTITION BY deptno ORDER BY sal 
ROWS 1 PRECEDING) sum 
FROM emp;
/*
<note:設置多少物理偏移就向上偏移多少列>
題意為設置2行物理偏移，所以在進行部門區分後的sum要從分區後的第三列開始比較，
前兩列的sum都是累加而來。

部門10的分區:
第二列的sum:3750<第三列的sal:5000，所以第三列的sum=3750+5000

部門20的分區:
第五列的sum:1900<第六列的sal:2975，所以第六列的sum=1900+2975
第六列的sum:4875>第七列的sal:3000，所以第七列的sum要往上偏移2列
=第五列的sal:1100+第六列的sal:2975
*/


-- ex:設置查詢行範圍;與按照部門分區進行求和返回相同結果。
SELECT deptno, ename, sal,  
SUM(sal) OVER(PARTITION BY deptno ORDER BY sal 
ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sum 
FROM emp;


-- ➤分析函數應用-數據統計函數:
-- ex:查詢員工編號是7369的員工姓名、職位、基本工資、部門編號、部門的人數、
-- 部門平均工資、部門最高工資、部門最低工資、部門總工資。
-- 說明:除了使用多表查詢的操作完成，現在有了分析函數，就可以使用分析函數完成。
-- 步驟一:統計出所有數據
SELECT 
empno, ename, job, sal, deptno, 
COUNT(empno) OVER(PARTITION BY deptno) count, 
ROUND(AVG(sal) OVER(PARTITION BY deptno),2) avg, 
MAX(sal) OVER(PARTITION BY deptno) max, 
MIN(sal) OVER(PARTITION BY deptno) min, 
SUM(sal) OVER(PARTITION BY deptno) sum 
FROM emp;
-- 步驟二:以上的結果返回多行多列，所以就是一張數據表的結構。
SELECT * 
FROM 
(SELECT 
empno, ename, job, sal, deptno, 
COUNT(empno) OVER(PARTITION BY deptno) count, 
ROUND(AVG(sal) OVER(PARTITION BY deptno),2) avg, 
MAX(sal) OVER(PARTITION BY deptno) max, 
MIN(sal) OVER(PARTITION BY deptno) min, 
SUM(sal) OVER(PARTITION BY deptno) sum 
FROM emp) t 
WHERE t.empno=7369;
/*
-- 使用FROM子查詢
SELECT 
e.empno, e.ename, e.job, e.sal, e.deptno, 
t.count, t.avg, t.max, t.min, t.sum 
FROM emp e, 
(SELECT 
deptno,
count(empno) count , 
ROUND(AVG(sal),2) avg ,
MAX(sal) max , 
MIN(sal) min , 
SUM(sal) sum  
FROM emp 
GROUP BY deptno) t 
WHERE e.deptno=t.deptno 
AND e.empno=7369;
*/


-- ex:查詢員工的編號、姓名、基本工資、所在部門名稱、部門位置即此部門的平均工資
-- 、最高工資、最低工資。
-- 確定所需資料表:
-- emp表:員工的編號、姓名、基本工資
-- dept表:部門名稱、部門位置
-- emp表:平均工資、最高工資、最低工資
-- 確定已知關聯欄位:emp.deptno=dept.deptno
-- 步驟一:進行多表關聯
SELECT 
e.empno, e.ename, e.sal, d.deptno, d.dname, d.loc
FROM emp e, dept d
WHERE e.deptno=d.deptno;
-- 步驟二:統計訊息
SELECT 
e.empno, e.ename, e.sal, d.deptno, d.dname, d.loc, 
ROUND(AVG(e.sal) OVER(PARTITION BY e.deptno ORDER BY sal 
RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),2) avg , 
MAX(e.sal) OVER(PARTITION BY e.deptno ORDER BY sal 
RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) max , 
MIN(e.sal) OVER(PARTITION BY e.deptno ORDER BY sal 
RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) mim 
FROM emp e, dept d 
WHERE e.deptno=d.deptno;
/*
-- 使用FROM子查詢
SELECT
e.empno, e.ename, e.sal, d.deptno, d.dname, d.loc, 
t.avg, t.max, t.mim 
FROM emp e, dept d, 
(SELECT
deptno, 
ROUND(AVG(sal),2) avg , 
MAX(sal) max , 
MIN(sal) mim 
FROM emp 
GROUP BY deptno) t 
WHERE e.deptno=d.deptno(+) 
AND e.deptno=t.deptno(+);
*/


-- ➤分析函數應用-等級函數:
-- 說明:在使用RANK()的時候如果有相同的，那麼出現跳號;如果是DENSE_RANK()就保持序號。
-- ex:RANK()與DENSE_RANK()操作
SELECT deptno, ename, sal, 
RANK() OVER(PARTITION BY deptno ORDER BY sal) rank_result , 
DENSE_RANK() OVER(PARTITION BY deptno ORDER BY sal) dense_rank_result  
FROM emp;


-- ex:ROW_NUMBER()操作
-- 說明:ROW_NUMBER()函數功能是用於生成一個行的紀錄號。
SELECT deptno, ename, sal, 
ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY sal) row_result_deptno , 
ROW_NUMBER() OVER(ORDER BY sal) row_result_all  
FROM emp;
-- 由以上操作顯示，針對於所有的數據，ROW_NUMBER()自動生成行號，但是在每一個
-- 分區裡面它也存在。


-- ex:KEEP語句操作;查詢每個部門的最高及最低工資
-- 說明:KEEP語句的功能是保留滿足條件的數據，而且在使用DENSE_RANK()函數確定的
-- 集合後才可以使用，透過FIRST或LAST取得集合中的數據。
-- FIRST:取出DENSE_RANK返回集合中第一行數據
-- LAST:取出DENSE_RANK返回集合中最後一行數據
SELECT
deptno, 
MAX(sal) KEEP(DENSE_RANK FIRST ORDER BY sal DESC) max_salary,  
MIN(sal) KEEP(DENSE_RANK LAST ORDER BY sal DESC) min_salary  
FROM emp
GROUP BY deptno;


-- ex:FIRST_VALUE()與LAST_VALUE()函數操作
-- 說明:OVER()是聲明一個數據集合，而利用FIRST_VALUE()或LAST_VALUE()函數取得
-- 集合中首行或尾行。
-- FIRST_VALUE(直行):返回區分(分組)的第一個值。
-- LAST_VALUE(直行):返回區分(分組)的最後一個值。
SELECT deptno, empno, ename, sal FROM emp WHERE deptno=10;

SELECT
deptno, empno, ename, sal, 
FIRST_VALUE(sal) OVER(PARTITION BY deptno ORDER BY sal 
RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) first_result,
LAST_VALUE(sal) OVER(PARTITION BY deptno ORDER BY sal 
RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) last_result
FROM emp
WHERE deptno=10;
/*
-- Q:為什麼last_result行返回結果內容不是應該都是最後一筆5000?
SELECT
deptno, empno, ename, sal, 
FIRST_VALUE(sal) OVER(PARTITION BY deptno ORDER BY sal) first_result,
LAST_VALUE(sal) OVER(PARTITION BY deptno ORDER BY sal) last_result
FROM emp
WHERE deptno=10;
*/


-- ex:LAG()與LEAD()函數操作
-- LAG(欄位[,橫列數][,默認值]):訪問分區(分組)中指定前N行的紀錄(以當前紀錄列前N行)
-- ，如果沒有則返回默認值。
-- LEAD(欄位[,橫列數][,默認值]):訪問分區(分組)中指定後N行的紀錄(以當前紀錄列後N行)
-- ，如果沒有則返回默認值。
SELECT 
deptno, empno, ename, sal, 
LAG(sal,2,0) OVER(PARTITION BY deptno ORDER BY sal) lag_result , 
LEAD(sal,2,0) OVER(PARTITION BY deptno ORDER BY sal) lead_result 
FROM emp 
WHERE deptno=20;


-- ➤分析函數應用-報表函數:
-- ex:CUME_DIST()函數操作
-- 說明:CUME_DIST()函數他是計算相對位置，例如:假設分區有5條紀錄，那麼這些紀錄會
-- 按照1、0.8、0.6、0.4、0.2的方式進行劃分。
SELECT deptno, ename, sal, 
CUME_DIST() OVER(PARTITION BY deptno ORDER BY sal) cume_result
FROM emp 
WHERE deptno IN(10,20);


-- ex:NTILE(數字)函數操作
-- 說明:針對數據分區中的有序結果集進行分化。
SELECT deptno, sal, 
SUM(sal) OVER(PARTITION BY deptno ORDER BY sal) sum_result , 
NTILE(3) OVER(PARTITION BY deptno ORDER BY sal) ntile_result_3  , 
NTILE(6) OVER(PARTITION BY deptno ORDER BY sal) ntile_result_6  
FROM emp;


-- ex:RATIO_TO_REPORT(表達式)函數操作
-- 說明:該函數計算expression/(sum(expression))的值，它給出相對於總數的百分比。
SELECT deptno,  SUM(sal), 
ROUND(RATIO_TO_REPORT(SUM(sal)) OVER(),5) rate_result , 
ROUND(RATIO_TO_REPORT(SUM(sal)) OVER(),5)*100 || '%' percent_result 
FROM emp 
GROUP BY deptno;
--============================================================================--
--                                                                            --
/* ※子查詢-行列轉換                                                          */
--                                                                            --
--============================================================================--

-- ex:查詢每個部門中各職位的總工資
SELECT deptno, job, 
SUM(sal) sumsal 
FROM emp 
GROUP BY deptno, job;


-- ex:查詢每個部門中各職位的總工資(將多條工資統計訊息放在一列上進行顯示)
SELECT deptno, 
SUM(DECODE(job,'PRESIDENT',sal,0)) president_job , 
SUM(DECODE(job,'MANAGER',sal,0)) manager_job , 
SUM(DECODE(job,'ANALYST',sal,0)) anaylst_job , 
SUM(DECODE(job,'CLERK',sal,0)) clerk_job , 
SUM(DECODE(job,'SALESMAN',sal,0)) salesman_job 
FROM emp 
GROUP BY deptno;
-- 以上方式使用的是DECODE()函數，但是對於這個函數屬於Oracle自己的色，如果沒有
-- 此函數只能夠利用SELECT子句使用子查詢的方式完成。

SELECT 
deptno dno, 
(SELECT SUM(sal) FROM emp 
WHERE job='PRESIDENT' AND e.empno=empno) president_job , 
(SELECT SUM(sal) FROM emp 
WHERE job='MANAGER' AND e.empno=empno) manager_job , 
(SELECT SUM(sal) FROM emp 
WHERE job='ANALYST' AND e.empno=empno) anaylst_job , 
(SELECT SUM(sal) FROM emp 
WHERE job='CLERK' AND e.empno=empno) clerk_job , 
(SELECT SUM(sal) FROM emp 
WHERE job='SALESMAN' AND e.empno=empno) salesman_job 
FROM emp e;
-- 以上列出的是各職位的統計訊息

SELECT t.dno, SUM(t.president_job), SUM(t.manager_job), 
SUM(t.anaylst_job), SUM(t.clerk_job), SUM(t.salesman_job) 
FROM
(SELECT 
deptno dno, 
(SELECT SUM(sal) FROM emp 
WHERE job='PRESIDENT' AND e.empno=empno) president_job , 
(SELECT SUM(sal) FROM emp 
WHERE job='MANAGER' AND e.empno=empno) manager_job , 
(SELECT SUM(sal) FROM emp 
WHERE job='ANALYST' AND e.empno=empno) anaylst_job , 
(SELECT SUM(sal) FROM emp 
WHERE job='CLERK' AND e.empno=empno) clerk_job , 
(SELECT SUM(sal) FROM emp 
WHERE job='SALESMAN' AND e.empno=empno) salesman_job 
FROM emp e) t 
GROUP BY t.dno;

-- ➤使用PIVOT函數操作
SELECT * FROM (SELECT deptno, job, sal FROM emp) 
PIVOT(
SUM(sal) 
  FOR job IN(
    'PRESIDENT' AS president_job ,  
    'MANAGER' AS manager_job , 
    'ANALYST' AS anaylst_job , 
    'CLERK' AS clerk_job , 
    'SALESMAN' salesman_job 
  )
)ORDER BY deptno;
/*
SELECT * FROM (SELECT deptno, job, sal FROM emp) 
PIVOT XML(
SUM(sal) 
  FOR job IN(ANY)
)ORDER BY deptno;
*/


-- ex:加入查詢總工資、最高及最低工資需求(如:使用分析函數)
SELECT * FROM 
(SELECT deptno, job, sal, 
SUM(sal) OVER(PARTITION BY deptno) sumsal , 
MAX(sal) OVER(PARTITION BY deptno) maxsal , 
MIN(sal) OVER(PARTITION BY deptno) minsal
FROM emp) 
PIVOT(
SUM(sal) 
  FOR job IN(
    'PRESIDENT' AS president_job ,  
    'MANAGER' AS manager_job , 
    'ANALYST' AS anaylst_job , 
    'CLERK' AS clerk_job , 
    'SALESMAN' salesman_job 
  )
)ORDER BY deptno;


-- ex:在PIVOT函數使用多個統計函數
-- 結果:數據被拆分
SELECT * FROM (SELECT deptno, job, sal FROM emp) 
PIVOT(
SUM(sal) AS sum_sal , MAX(sal) AS max_sal 
  FOR job IN(
    'PRESIDENT' AS president_job ,  
    'MANAGER' AS manager_job , 
    'ANALYST' AS anaylst_job , 
    'CLERK' AS clerk_job , 
    'SALESMAN' salesman_job 
  )
)ORDER BY deptno;


-- ex:在PIVOT函數使用上有多欄位分組需求，增加一個sex欄位同時更新81年僱用的
-- 雇員的性別為女
ALTER TABLE emp ADD(sex VARCHAR2(10) DEFAULT '男');
UPDATE emp SET sex='女' WHERE TO_CHAR(hiredate,'YYYY')='1981';
COMMIT;


-- ex:PIVOT函數操作多欄位統計
SELECT * FROM (SELECT deptno, job, sal, sex FROM emp) 
PIVOT(
SUM(sal) AS sum_sal , MAX(sal) AS max_sal 
  FOR (job,sex) IN(      
    ('MANAGER','男') AS manager_male_job , 
    ('MANAGER','女') AS manager_female_job , 
    ('CLERK','男') AS clerk_male_job , 
    ('CLERK','女') AS clerk_female_job 
  )
)ORDER BY deptno;


-- ➤使用UNPIVOT函數操作
-- 說明:直行轉橫列，只換前後的欄位名稱要對應
-- INCLUDE NULLS:轉換後保留所有的null數據。
-- EXCLUDE NULLS(默認):轉換後不保留null數據。
-- ex:
WITH temp AS
(SELECT * FROM (SELECT deptno, job, sal FROM emp) 
PIVOT(
SUM(sal) 
  FOR job IN(
    'PRESIDENT' AS president_job ,  
    'MANAGER' AS manager_job , 
    'ANALYST' AS analyst_job , 
    'CLERK' AS clerk_job , 
    'SALESMAN' salesman_job 
  )
)ORDER BY deptno) 
SELECT * FROM temp 
UNPIVOT INCLUDE NULLS(
 sal_sum FOR job IN(
	president_job AS 'PRESIDENT' , 
	manager_job AS 'MANAGER' , 
	analyst_job AS 'ANALYST' , 
	clerk_job AS 'CLERK' , 
	salesman_job AS 'SALESMAN' 
 )
)ORDER BY deptno;
--============================================================================--
--                                                                            --
/* ※子查詢-設置數據層次                                                      */
--                                                                            --
--============================================================================--
-- ➤層次函數
-- 簡述:層次查詢是一種較為確定數據行之間關係結構的一種操作。如:學校分為
-- "教學管理層"、"教師層"、"學生層"這樣三層次結構。
/*
語法結構:
LEVEL...
CONNECT BY [NOCYCLE] PRIOR 連接條件 
[START WITH 開始條件]
語法組成:
LEVEL:可以根據數據所處的層次結構實現自動的層次編號，如:1、2、3。
CONNECT BY:指的是數據之間的連接，如:員工數據依靠mgr找到其主管，就是一個連接
           條件，其中NOCYCLE需要結合CONNECT_BY_ISCYCLE偽列確定出父子節點循環關係。
START WITH:根節點數據的開始條件。
*/

-- ex:查出員工對應主管的層次結構
-- 字串左邊填充:LPAD(被填充字串,填充後字串長度,填充字元)
SELECT empno,LPAD('|-',LEVEL*2,' ') || ename, mgr, LEVEL 
FROM emp 
CONNECT BY PRIOR empno=mgr 
START WITH mgr IS NULL;


-- ➤CONNECT_BY_ISLEAF偽列
-- 說明:在一棵樹狀結構之中，節點會分為兩種:根節點、葉子節點，用戶可以利用
-- "CONNECT_BY_ISLEAF"偽列判斷某一個節點是根節點還是葉子節點，如果直行返回的是
-- 數字0，則表示根節點，反之返回為1。
-- ex:判斷是否為子節點
SELECT empno,LPAD('|-',LEVEL*2,' ') || ename, mgr, LEVEL, 
DECODE(CONNECT_BY_ISLEAF,0,'根節點',1,'    子節點') ISLEAF 
FROM emp 
CONNECT BY PRIOR empno=mgr 
START WITH mgr IS NULL;


-- ➤CONNECT_BY_ROOT列
-- 說明:CONNECT_BY_ROOT主要作用是取得某一個欄位在本次分層之中的根節點數據名稱
-- ，例如:如果按照主管層次劃分，則所有數據的根節點都應該是KING。
-- ex:
SELECT empno,LPAD('|-',LEVEL*2,' ') || ename, mgr, LEVEL, 
CONNECT_BY_ROOT ename 
FROM emp 
CONNECT BY PRIOR empno=mgr 
START WITH mgr IS NULL;
-- ex:從一個指定的員工開始
SELECT empno,LPAD('|-',LEVEL*2,' ') || ename, mgr, LEVEL, 
CONNECT_BY_ROOT ename 
FROM emp 
CONNECT BY PRIOR empno=mgr 
START WITH empno=7566;


-- ➤SYS_CONNECT_BY_PATH(列,char)函數
-- 說明:利用"SYS_CONNECT_BY_PATH()"函數按照給出的節點關係，自動的將前根節點中的
-- 所有相關路徑進行顯示。
-- ex:使用SYS_CONNECT_BY_PATH()函數取得節點路徑訊息
SELECT empno,LPAD('|-',LEVEL*2,' ') || SYS_CONNECT_BY_PATH(ename,'=>') empname,  
mgr, LEVEL, DECODE(CONNECT_BY_ISLEAF,0,'根節點',1,'    子節點') ISLEAF 
FROM emp 
CONNECT BY PRIOR empno=mgr 
START WITH mgr IS NULL;


-- 去掉某一節點
SELECT empno,LPAD('|-',LEVEL*2,' ') || SYS_CONNECT_BY_PATH(ename,'=>') empname, 
mgr, LEVEL, DECODE(CONNECT_BY_ISLEAF,0,'根節點',1,'    子節點') ISLEAF 
FROM emp 
CONNECT BY PRIOR empno=mgr AND empno!=7698
START WITH mgr IS NULL;


-- ➤ORDER SIBLINGS BY 欄位
-- 說明:在使用層次查詢進行數據顯示時，如果用戶直接使用ORDER BY子句進行指定欄位
-- 的排序，有可能會破壞數據的組成結構。
-- ex:直接使用ORDER BY排序
SELECT empno,LPAD('|-',LEVEL*2,' ') || ename, mgr, LEVEL, 
DECODE(CONNECT_BY_ISLEAF,0,'根節點',1,'    子節點') ISLEAF 
FROM emp 
CONNECT BY PRIOR empno=mgr 
START WITH mgr IS NULL 
ORDER BY ename;
-- ex:保持結構排序
SELECT empno,LPAD('|-',LEVEL*2,' ') || ename, mgr, LEVEL, 
DECODE(CONNECT_BY_ISLEAF,0,'根節點',1,'    子節點') ISLEAF 
FROM emp 
CONNECT BY PRIOR empno=mgr 
START WITH mgr IS NULL 
ORDER SIBLINGS BY ename;


-- ➤CONNECT_BY_ISCYCLE偽列
-- 說明:在進行數據層次設計的過程之中，最為重要根據指定的數據列確定數據間的
-- 層次關係，但是有時候也可能出現死循環，如:KING的主管是BLAKE，而BLAKE的領導
-- 也是KING就表示一個循環關係，為了判斷循環關係的出現，在Oralce中也提供一個
-- CONNECT_BY_ISCYCLE偽列，來判斷是否會出現循環，如果出現循環，則顯示1，沒有
-- 出現循環，則顯示0。同時如果想要判斷是否為循環節點，則還需要"NOCYCLE"的支持。
-- ex:原本KING沒有主管，但是為了發現問題，讓KING有一個主管，將主管設置為7698。
UPDATE emp SET mgr=7698 WHERE empno=7839;
-- ex:執行上面指令後，再執行下面指令會出現死循環
SELECT empno,LPAD('|-',LEVEL*2,' ') || ename, mgr, LEVEL, 
DECODE(CONNECT_BY_ISLEAF,0,'根節點',1,'    子節點') ISLEAF 
FROM emp 
CONNECT BY PRIOR empno=mgr 
START WITH empno=7839 
ORDER SIBLINGS BY ename;
-- 加入NOCYCLE停止循環
SELECT empno,LPAD('|-',LEVEL*2,' ') || ename, mgr, LEVEL, 
DECODE(CONNECT_BY_ISLEAF,0,'根節點',1,'    子節點') ISLEAF 
FROM emp 
CONNECT BY NOCYCLE PRIOR empno=mgr 
START WITH empno=7839 
ORDER SIBLINGS BY ename;
-- 加入偽列判斷有無循環
SELECT empno,LPAD('|-',LEVEL*2,' ') || ename, mgr, LEVEL, 
DECODE(CONNECT_BY_ISLEAF,0,'根節點',1,'    子節點') ISLEAF , 
DECODE(CONNECT_BY_ISCYCLE,0,'(V)沒有循環',1,'(X)存在循環') ISCYCLE 
FROM emp 
CONNECT BY NOCYCLE PRIOR empno=mgr 
START WITH empno=7839 
ORDER SIBLINGS BY ename;