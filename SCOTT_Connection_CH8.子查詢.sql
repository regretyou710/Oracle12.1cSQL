--============================================================================--
--                                                                            --
/* ※子查詢                                                                    */
--                                                                            --
--============================================================================--
-- 說明:一個完整的查詢之中定義了若干個小的查詢形成的複雜查詢。所有的子查詢在編寫時一定要使
-- 用括號標記。
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
/* ※子查詢-在WHERE之中使用子查詢                                                */
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
AND ename!='ALLEN'
;


-- ➤子查詢返回單行多列數據
-- ex:查詢與SCOTT從事同一工作且工資相同的員工訊息
-- 步驟一
SELECT job, sal FROM emp WHERE ename='SCOTT';
-- 步驟二
SELECT * FROM emp 
WHERE (job,sal)=(SELECT job, sal FROM emp WHERE ename='SCOTT')
AND ename!='SCOTT'
;


-- ex:查詢與員工7566從事同一工作且主管相同的全部員工訊息
-- 步驟一
SELECT job, mgr FROM emp WHERE empno=7566;
-- 步驟二
SELECT * FROM emp 
WHERE (job, mgr)=(SELECT job, mgr FROM emp WHERE empno=7566)
AND empno!=7566
;


-- ex:查詢與ALLEN從事同一工作且在同一年雇用的全部員工訊息(包括ALLEN)
-- 步驟一
SELECT job, TO_CHAR(hiredate,'YYYY') FROM emp WHERE ename='ALLEN';
-- 步驟二
SELECT * 
FROM emp 
WHERE (job, TO_CHAR(hiredate,'YYYY'))
=(SELECT job, TO_CHAR(hiredate,'YYYY') FROM emp WHERE ename='ALLEN')
;


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
-- 此時返回結果與使用IN相同，但如果上述語句使用!=ANY，則是返回一張表的所有資料，不等同NOT IN。


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
/* ※子查詢-在HAVING之中使用子查詢                                               */
--                                                                            --
--============================================================================--
-- 說明:主要目的是對分組過後的數據再次過濾，且與WHERE不同的是，HAVING是在分組後，可以使用
-- 統計函數。一般而言在HAVING子句之中出現子查詢，子查詢返回的數據往往是單行單列，他是按照
-- 一個數值的方式返回，再通過統計函數進行過濾。

-- ex:查詢部門編號、員工人數、平均工資，並要求這些部門的平均工資高於公司平均工資
-- 步驟一:查詢公司平均工資
SELECT ROUND(AVG(sal),2) FROM emp;  
-- 步驟二:按照deptno進行分組，並統計部門的訊息
SELECT 
deptno, 
COUNT(empno), 
ROUND(AVG(sal),2) 
FROM emp 
GROUP BY deptno
;
-- 步驟三:執行分組後數據的過濾，需要在HAVING子句中使用子查詢
SELECT 
deptno, 
COUNT(empno), 
ROUND(AVG(sal),2) 
FROM emp 
GROUP BY deptno
HAVING ROUND(AVG(sal),2)>(SELECT ROUND(AVG(sal),2) FROM emp)
;


-- ex:查詢出每個部門平均工資最高的部門名稱及平均工資
-- 步驟一:求出每個部門最高平均工資
-- note:所有統計函數允許嵌套使用。但是一旦使用了嵌套的統計函數之後，SELECT子句之中
-- 不允許再出現任何的欄位，包括分組欄位。
SELECT MAX(AVG(sal)) FROM emp e GROUP BY e.deptno;
-- 步驟二:引入部門表求得部門名稱
SELECT d.dname, AVG(e.sal) 
FROM emp e ,dept d 
WHERE e.deptno(+)=d.deptno
GROUP BY d.dname
;
-- 步驟三:執行分組後數據的過濾
SELECT d.dname, AVG(e.sal) 
FROM emp e ,dept d 
WHERE e.deptno(+)=d.deptno
GROUP BY d.dname
HAVING AVG(sal)=(SELECT MAX(AVG(sal)) FROM emp e GROUP BY e.deptno)
;
--============================================================================--
--                                                                            --
/* ※子查詢-在FROM之中使用子查詢                                                 */
--                                                                            --
--============================================================================--
-- 說明:FROM子句主要功能是確定數據來源，那麼來源都屬於數據表，表的特徵為行+列的集合。只要
-- 是在FROM子句之中出現的內容一般都是多行多列的子查詢返回。

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
GROUP BY d.deptno, d.dname, d.loc
;
-- 方式二:使用子查詢
-- 步驟一:查詢出每個部門的基本訊息
SELECT * FROM dept d;
-- 步驟二:統計訊息，按照部門編號分組統計
SELECT 
e.deptno, 
COUNT(e.empno), 
AVG(e.sal) 
FROM emp e
GROUP BY e.deptno
;
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
WHERE d.deptno=temp.deptno(+)
;
-- 需注意:在步驟二進行分組統計建立臨時表時，須將欄位設置別名，否則在步驟三時兩張表進行合併
-- 後要顯示需求欄位會出異常。
SELECT d.deptno, d.dname, d.loc, temp.count, temp.avg 
FROM dept d, 
(SELECT 
e.deptno, 
COUNT(e.empno) count , 
AVG(e.sal) avg 
FROM emp e
GROUP BY e.deptno
) temp 
WHERE d.deptno=temp.deptno(+)
;
-- 由以上兩種操作方式都可以實現同樣的結果，那麼該使用哪種?為了解決此問題，可以將數據擴大
-- 100倍，即:emp表中的數據為1400條紀錄，而dept表中的數據為400條紀錄。
-- 方法一:多欄位分組實現
-- 	當dept和emp表關聯的時候一定會存在笛卡爾積，數據量 = emp表的1400條 * dpet表的400條
-- 	= 560000條紀錄。
-- 方法二:子查詢
-- 	統計:emp表的1400條紀錄，而且最終的統計結果的行數不可能超過400行(在步驟二透過部門編號
-- 	分類統計，而分類只有4種*100倍)
-- 	多表關聯:dpet表的400條紀錄(步驟一的100倍) * 子查詢的最多400條紀錄(步驟二的100倍) 
-- 	= 160000條紀錄
-- 	最終結果:160000 + 1400 = 161400條紀錄 
-- 所以使用子查詢可以解決多表查詢所帶來的效能問題。


-- ex:查詢出所有在"SALES"(銷售部)工作的員工的編號、姓名、基本工資、獎金、職位、雇用日期、部門
-- 的最高和最低工資
-- 步驟一:找出銷售部的編號
SELECT deptno FROM dept WHERE dname='SALES';
-- 步驟二:透過步驟一查出該部門的員工訊息
SELECT 
empno, ename, sal, comm, job, hiredate
FROM emp 
WHERE deptno=(SELECT deptno FROM dept WHERE dname='SALES')
;
-- 步驟三:統計最高和最低工資
SELECT deptno don, MAX(sal) maxsal , MIN(sal) minsal FROM emp GROUP BY deptno;
-- 步驟四:步驟三結合到步驟二
-- 說明:在步驟二使用統計函數時的限制;
-- (A)統計函數1.單獨使用 2.結合GROUP BY使用，單獨使用的時後SELECT子句之中無法出現任何欄
--    位，結合GROUP BY使用時，SELECT子句之中只允許出現分組欄位。
-- (B)統計函數嵌套時不允許出現任何欄位包括分組欄位。
-- 由上述兩者限制下，直接進行步驟四會發現，整個SELECT查詢裡面需要統計查詢，但是卻無法直接
-- 使用統計查詢，那麼就可以在子查詢中直接完成，而且子查詢一定返回多行多列的數據，在FROM子
-- 句中出現。
SELECT 
e.empno, e.ename, e.sal, e.comm, e.job, e.hiredate, 
t.maxsal, t.minsal
FROM emp e, 
(SELECT deptno dno, MAX(sal) maxsal , MIN(sal) minsal 
FROM emp GROUP BY deptno) t
WHERE deptno=(SELECT deptno FROM dept WHERE dname='SALES') 
AND e.deptno=t.dno
;


-- ex:查詢出所有工資高於公司平均工資的員工編號、姓名、基本工資、職位、雇用日期、所在部門名稱
-- 、位置、主管姓名、公司的工資等級、部門人數、平均工資、平均服務年限。
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
-- 步驟一:使用AVG()函數統計公司的平均工資，結果返回單行單列，一定是在WHERE或是HAVING中
SELECT AVG(sal) FROM emp;
-- 步驟二:查出高於步驟一的員工編號、姓名、基本工資、職位、雇用日期
SELECT empno, ename, sal, job, hiredate
FROM emp
WHERE sal>(SELECT AVG(sal) FROM emp)
;
-- 步驟三:加入dept表關聯查出部門名稱、位置
SELECT empno, ename, sal, job, hiredate, 
dname, loc 
FROM emp, dept 
WHERE sal>(SELECT AVG(sal) FROM emp)
AND emp.deptno=dept.deptno
;
-- 步驟四:加入emp表自身關聯查出主管姓名
SELECT e.empno, e.ename, e.sal, e.job, e.hiredate, 
dname, loc, memp.ename mgrname
FROM emp e, dept, emp memp 
WHERE e.sal>(SELECT AVG(sal) FROM emp) 
AND e.deptno=dept.deptno
AND e.mgr=memp.empno(+)
;
-- 步驟五:加入salgrade表關聯查出工資等級
SELECT e.empno, e.ename, e.sal, e.job, e.hiredate, 
dname, loc, memp.ename mgrname, s.grade 
FROM emp e, dept, emp memp, salgrade s 
WHERE e.sal>(SELECT AVG(sal) FROM emp) 
AND e.deptno=dept.deptno
AND e.mgr=memp.empno(+)
AND e.sal BETWEEN s.losal AND s.hisal
;
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
AND e.deptno=t.dno
;


-- ex:列出工資比"ALLEN"或"CLARK"多的所有員工的編號、姓名、基本工資、部門名稱、其主管姓名
-- 、部門人數。
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
FROM emp WHERE sal>(SELECT sal FROM emp WHERE ename='CLARK') 
;
-- 步驟三:
SELECT e.empno, e.ename, e.sal, d.dname
FROM emp e, dept d
WHERE e.sal>(SELECT sal FROM emp WHERE ename='ALLEN') 
AND e.deptno=d.deptno 
UNION
SELECT e.empno, e.ename, e.sal, d.dname
FROM emp e, dept d 
WHERE e.sal>(SELECT sal FROM emp WHERE ename='CLARK') 
AND e.deptno=d.deptno 
;
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
AND e.mgr=memp.empno(+) 
;
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
AND e.ename NOT IN('ALLEN','CLARK') 
;
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
AND e.ename NOT IN('ALLEN','CLARK')
;
-- 步驟三:加入部門表，列出部門名稱
SELECT e.empno, e.ename, e.sal ,d.dname 
FROM emp e ,dept d 
WHERE e.sal>ANY(SELECT sal FROM emp WHERE ename IN('ALLEN','CLARK')) 
AND e.ename NOT IN('ALLEN','CLARK') 
AND e.deptno=d.deptno 
;
-- 步驟四:使用emp表自身關聯主管編號
SELECT e.empno, e.ename, e.sal ,d.dname , memp.ename mgrname 
FROM emp e ,dept d , emp memp 
WHERE e.sal>ANY(SELECT sal FROM emp WHERE ename IN('ALLEN','CLARK')) 
AND e.ename NOT IN('ALLEN','CLARK') 
AND e.deptno=d.deptno 
AND e.mgr=memp.empno(+) 
;
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
AND e.deptno=t.don
;


-- ex:列出公司各部門的經理(假設每個部門只有一個經理，job為"MANAGER")的姓名、工資、部門名
-- 稱、部門人數、部門平均工資
-- 確定所需要的表:
-- emp表:姓名、工資
-- dept表:部門名稱
-- emp表:部門人數、部門平均工資
--確定已知關聯欄位:
-- 員工(經理)和部門:emp.deptno=dept.deptno
-- 步驟一:
SELECT ename, sal FROM emp WHERE job IN ('MANAGER');
-- 步驟二:
SELECT e.ename, e.sal , d.dname 
FROM emp e ,dept d
WHERE job IN ('MANAGER')
AND e.deptno=d.deptno 
;
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
AND e.deptno=t.dno 
;
--============================================================================--
--                                                                            --
/* ※子查詢-在SELECT之中使用子查詢                                               */
--                                                                            --
--============================================================================--
