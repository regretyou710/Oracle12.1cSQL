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

-- IN操作符:在一個數據範圍上使用
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


-- ANY操作符
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


-- ALL操作符
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

-- EXISTS求反，此時EXISTS判斷TRUE返回所有員工資料結果。
SELECT * FROM emp WHERE NOT EXISTS(SELECT * FROM emp WHERE empno=9999);