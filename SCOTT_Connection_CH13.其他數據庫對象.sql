--============================================================================--
--                                                                            --
/* ※其他數據庫對象-視圖                                                      */
--                                                                            --
--============================================================================--
-- 說明:視圖是從一個或幾個實體表(或視圖)導出的表。它與實體表不同，視圖本身是一個
-- 不包含任何真實數據的虛擬表。數據庫中只存放視圖的定義，而不存放視圖對應的數據
-- ，這些數據仍存放在原來的實體表中。所以實體表中的數據發生變化，從視圖中查詢出
-- 的數據也就隨之改變了。從這個意義上講，視圖就像一個窗口，透過它可以看到數據庫
-- 中自己敢興趣的數據及其變化。

-- 視圖的優點:
-- 視圖能夠簡化用戶的操作。
-- 視圖使用戶能以多種角度看待同一數據。
-- 視圖對重構處據庫提供了一定程度的邏輯獨立性。
-- 視圖能夠對機密數據提供安全保護。
-- 適當的利用視圖可以更清晰的表達查詢。
-- 視圖是一定會在標準開發之中出現，這樣就可以實現系統的分工。
-- 視圖本身也屬於Oracle中的對象，所以視圖可以被查詢、更新等操作。
-- ▲視圖 = 複雜查詢語句。

-- 創建視圖語法
-- CREATE[FORCE|NOFORCE][OR REPLACE]VIEW 視圖名稱[(別名1,別名2,...)] AS 子查詢;
-- 語法參數:在創建視圖中的主要參數解釋如下:
-- FORCE:表示要創建視圖的表不存在也可以創建視圖。
-- NOFORCE:(默認)表示要創建視圖的表必須存在，否則無法創建。
-- OR REPLACE:表示視圖的替換，如果創建的視圖不存在則建新的，如果視圖已經存在，
--            則將其進行替換。

-- ex:創建一張基本工資大於2000的員工訊息的視圖
CREATE VIEW v_myview AS SELECT * FROM emp WHERE sal>2000;
-- 此時是希望把這條語句的操作直接封裝在視圖之中，即:日後利用視圖來解決查詢問題。
-- 在Oracle 10gR2這個版本之後，默認情況架scott用戶沒有創建視圖權限。
-- 執行CMD:sqlplus /nolog
CONN sys/change_on_install AS SYSDBA;
GRANT CREATE VIEW TO c##scott;


-- 視圖創建完成之後下面按照簡單查詢的方式查詢視圖
SELECT * FROM v_myview;
-- 現在只要查詢視圖就可以實現與被封裝SQL語句同樣的功能。
-- 在Oracle中，針對於視圖也提供了一個數據字典:user_views。
SELECT * FROM user_views;


-- ex:創建一張只包含20部門員工訊息的視圖
CREATE VIEW v_emp20 AS SELECT * FROM emp WHERE deptno=20;
SELECT * FROM v_emp20;


-- ex:替換v_myview視圖，可以顯示每個部門的詳細訊息
CREATE OR REPLACE VIEW v_myview AS 
  SELECT d.deptno, d.dname, d.loc, 
    COUNT(e.empno) count,  
    NVL(ROUND(AVG(e.sal),2),0) avg, 
    NVL(SUM(e.sal),0) sum, 
    NVL(MAX(e.sal),0) max, 
    NVL(MIN(e.sal),0) min 
  FROM emp e, dept d 
  WHERE e.deptno(+)=d.deptno
  GROUP BY d.deptno,d.dname,d.loc;
SELECT * FROM v_myview;


-- ex:在創建視圖時也可以定義別名
CREATE OR REPLACE VIEW 
v_myview (部門編號,部門名稱,位置,人數,平均工資,總工資,最高工資,最低工資)
AS 
  SELECT d.deptno, d.dname, d.loc, 
    COUNT(e.empno) count,  
    NVL(ROUND(AVG(e.sal),2),0) avg, 
    NVL(SUM(e.sal),0) sum, 
    NVL(MAX(e.sal),0) max, 
    NVL(MIN(e.sal),0) min 
  FROM emp e, dept d 
  WHERE e.deptno(+)=d.deptno
  GROUP BY d.deptno,d.dname,d.loc;
SELECT * FROM v_myview;


-- ➤在視圖上執行DML操作
-- 對於DML查詢視圖是一定可以完成的。

-- ①更新簡單視圖(單表映射數據):簡單試圖更新(增刪修)的時候會直接影響到實體表數據
-- ex:創建一張只包含20部門員工訊息的視圖，只有部分欄位
CREATE OR REPLACE VIEW v_emp20 
AS
SELECT empno, ename, job, sal, deptno
FROM emp 
WHERE deptno=20;


-- ex:向視圖新增一筆數據
INSERT INTO v_emp20 (empno,ename,job,sal,deptno) 
VALUES (6688,'張三豐','CLERK',1900,20);
SELECT * FROM v_emp20;
-- note:在進行視圖增加數據的時候，如果視圖只包含表中的部分數據，那麼增加時也只會增加
-- 部分數據，沒有映射到試圖之中的直行內容，都會使用null填充。
SELECT * FROM emp WHERE deptno=20;


-- ex:對視圖執行修改操作
UPDATE v_emp20 SET ename='張無忌', job='MANAGER', sal=2300 
WHERE empno=6688;
SELECT * FROM v_emp20;
SELECT * FROM emp WHERE deptno=20;


-- ex:刪除視圖中的數據
DELETE FROM v_emp20 WHERE empno=6688;
SELECT * FROM v_emp20;
SELECT * FROM emp WHERE deptno=20;


-- ②更新複雜視圖(多表映射)
-- ex:創建一張複雜視圖
CREATE OR REPLACE VIEW v_myview 
AS
SELECT e.empno, e.ename, e.job, e.sal, d.deptno, d.dname, d.loc 
FROM emp e, dept d
WHERE e.deptno=d.deptno
AND d.deptno=20;
SELECT * FROM v_myview;


-- ex:向v_myview視圖之中新增數據
-- 這個時候的數據如果能實現增加肯定要同時向emp和dept兩張表之中保存數據，而且現在
-- 沒有50部門。
INSERT INTO v_myview (empno,ename,job,sal,deptno,dname,loc) 
VALUES (6688,'張三豐','CLERK',2000,50,'教學','武當');
-- SQL 錯誤: ORA-01776: 無法透過結合視觀表來修改一個以上的基本表格
-- 無法進行更新操作，不是一張表。


-- ex:修改v_myview視圖中的數據
UPDATE v_myview SET ename='史密斯', sal=5000, dname='教學' 
WHERE empno=7369;
-- 同樣無法進行修改
-- SQL 錯誤: ORA-01776: 無法透過結合視觀表來修改一個以上的基本表格


-- ex:向v_myview視圖執行刪除操作
DELETE FROM v_myview WHERE empno=7369;
SELECT * FROM emp;
SELECT * FROM dept;
-- 發現此時刪除了emp表的一條訊息，但是dept表中的部門訊息仍被保留著


-- ex:刪除v_myview視圖中所有20部門的員工
DELETE FROM v_myview WHERE deptno=20;
SELECT * FROM emp;
SELECT * FROM dept;
-- 此時emp表中即使沒有了20部門的員工，dept表中的相應數據依然會被保留


-- ➤WITH CHECK OPTION子句
-- 說明:在創建視圖時有時候需要使用一些WHERE子句作一些條件的限制，但是默認情況下
-- 的視圖創建完成後，是可以透過視圖去修改在WHERE子句之中所使用的欄位內容的，而
-- 在此時就需要透過WITH CHECK OPTION子句來保證視圖的創建條件不被更新。
-- 語法
-- CREATE [FPRCE|NOFORCE][OR REPLACE]VIEW 視圖名稱[(別名1,別名2...)]
-- AS 子查詢[WITH CHECK OPTION[CONSTRANIT 約束名稱]];

-- ex:創建一張只包含20部門員工的視圖
CREATE OR REPLACE VIEW v_emp20 
AS 
SELECT *
FROM emp 
WHERE deptno=20;
select * from v_emp20;
-- 在這個視圖之中，"deptno=20"是一個最關鍵的選項，視圖存在條件就是它。


-- ex:修改v_emp20視圖之中的部門編號
UPDATE v_emp20 SET deptno=40 WHERE empno=7369;
select * from v_emp20;
select * from emp;
-- 發現修改視圖之後，原始數據被改變了，但現在的問題又回來了，對於此時的操作，deptno
-- 欄位是視圖存在的核心條件，把核心條件修改了，合適嗎?


-- ex:重新創建v_emp20視圖
ROLLBACK;
CREATE OR REPLACE VIEW v_emp20 
AS 
SELECT *
FROM emp 
WHERE deptno=20
WITH CHECK OPTION CONSTRAINT v_emp20_CK;
select * from v_emp20;


-- ex:修改v_emp20視圖之中的部門編號
UPDATE v_emp20 SET deptno=40 WHERE empno=7369;
-- 重新創建完視圖後，發現無法再更新新試圖的創建條件。
-- SQL 錯誤: ORA-01402: 檢視 WITH CHECK OPTION where- 子句違反


-- ➤WITH CHECK OPTION子句
-- 說明:讓視圖中所有的欄位不可更新，則可以透過WITH READ ONLY子句控制
-- 語法
-- CREATE [FPRCE|NOFORCE][OR REPLACE]VIEW 視圖名稱[(別名1,別名2...)]
-- AS 子查詢[WITH CHECK OPTION[CONSTRANIT 約束名稱]]
-- [WITH READ ONLY];

-- 現在使用WITH CHECK OPTION子句可以保證創建欄位不被修改，但如果現在要修改的是
-- 其他欄位又會如何?
-- ex:修改v_emp20視圖中員工編號7369的訊息
UPDATE v_emp20 SET ename='史密斯',comm=300 WHERE empno=7369;
select * from v_emp20;
ROLLBACK;
-- 發現除了deptno欄位之外，其他的欄位依然可以更新。但是視圖本身不是真實數據，它屬
-- 於映射數據，應該在基表之中更新才合適。


-- ex:將v_emp20視圖變為只讀視圖
CREATE OR REPLACE VIEW v_emp20 
AS 
SELECT *
FROM emp 
WHERE deptno=20 
WITH READ ONLY;


-- ex:修改v_emp20視圖中員工編號7369的訊息
UPDATE v_emp20 SET ename='史密斯',comm=300 WHERE empno=7369;
-- SQL 錯誤: ORA-42399: 無法在唯讀視觀表執行 DML 作業


-- ➤刪除視圖
-- 如果是刪除視圖直接使用DROP語句就可以完成。
-- 語法:DROP VIEW 視圖名稱;


-- ex:刪除v_myview視圖
SELECT * FROM user_views;
DROP VIEW v_myview;
DROP VIEW v_emp20;




