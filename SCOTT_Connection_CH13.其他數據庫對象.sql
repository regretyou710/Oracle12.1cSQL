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
--============================================================================--
--                                                                            --
/* ※其他數據庫對象-序列                                                      */
--                                                                            --
--============================================================================--
-- 說明:序列(Sequence)可以自動的按照既定的規則實現數據的編號操作。
-- 序列的完整創建語法
/*
CREATE SEQUENCE 序列名稱
[INCREMENT BY 步長]
[START WITH 開始值]
[MAXVALUE 最大值|NOMAXVALUE]
[MINVALUE 最小值|NOMINVALUE]
[CYCLE|NOCYCLE]
[CACHE 緩存大小|NOCACHE]

各主要屬性內容如下:
SEQUENCE_NAME:表示序列的名稱。
MIN_VALUE:此序列開始的默認最小值，(默認是0)。
MAX_VALUE:此序列增長的最大值(默認是9999999999999999999999999999)。
INCREMENT_BY:序列每次增長的步長(默認是1)。
CYCLE_FLAG:循環標記，如果是循環序列則顯示"Y"，非循環序列則顯示為"N"(默認是"N")。
CACHE_SIZE:序列操作的緩存量(默認是20)。
LAST_NUMBER:最後一次操作的值。
*/
-- ▲Oracle 12c提供自動序列。
-- ▲序列是屬於Oracle的對象，所以對象的創建依然以CREATE為主。
-- ▲序列的兩個偽列:currval、nextval。

-- ➤創建序列
-- ex:創建默認序列
CREATE SEQUENCE myseq;
-- 序列創建完成後，可以直接利用數據字典查詢，序列的數據字典:user_sequences。
SELECT * FROM user_sequences;


-- ➤使用序列
-- 要使用一個已經創建完成的序列，則可以使用序列中提供的兩個偽列進行操作
-- ①序列名稱.currval:表示取得當前序列已經增長的結果，重複調用多次後序列內容不會
--                    有任何變化，同時當前序列的大小(LAST_NUMBER)不會改變。
-- ②序列名稱.nextval:表示取得一個序列的下一次增長值，每次調用一次，序列都會自動
--                    增長。

-- ex:偽列的調用 
SELECT myseq.currval FROM dual;
-- ORA-08002: 尚未在此階段作業中定義順序 MYSEQ.CURRVAL
-- 對於給出偽列而言，一定是先使用nextval，而後才可以使用currval，也就是說此時表
-- 是的概念是只有在執行了nextval之後序列才真正進入到了可用的狀態。
SELECT myseq.nextval FROM dual;
SELECT myseq.currval FROM dual;

-- 每一次執行nextval發現序列的內容都會增加，而調用currval的時候序列不會有任何變
-- 化。
-- 對於序列之中緩存是一個非常重要的概念，在序列使用之前，已經在內存裡面偽用戶提供
-- 好了一系列的生成序列號。用的時候不是隨用隨取，而是已經準備好了。
-- 如果設置了緩存，如果數據庫出現了問題，那麼可能這些緩存的數據就會消失，就會出現
-- 跳號的問題。


-- ex:創建memeber數據表
DROP TABLE member PURGE;
CREATE TABLE member(
mid NUMBER,
name VARCHAR2(50) NOT NULL,
CONSTRAINT pk_mid PRIMARY KEY(mid)
);
-- 向member表中使用序列增加紀錄
INSERT INTO member (mid,name) VALUES (myseq.nextval,'張三豐');
SELECT * FROM member;


-- ➤刪除序列
DROP SEQUENCE myseq;
SELECT * FROM user_sequences;


-- ➤創建特殊功能序列
-- 默認情況下序列的步長是1
-- ex:設置新的步長為3
DROP SEQUENCE myseq;
CREATE SEQUENCE myseq INCREMENT BY 3;
SELECT * FROM user_sequences;
SELECT myseq.nextval FROM dual;


-- ex:設置初始值為30
DROP SEQUENCE myseq;
CREATE SEQUENCE myseq 
INCREMENT BY 3
START WITH 30;
SELECT * FROM user_sequences;
SELECT myseq.nextval FROM dual;


-- CACHE保存的是緩存的個數，而不是數值
-- ex:設置緩存
DROP SEQUENCE myseq;
CREATE SEQUENCE myseq 
CACHE 100;
SELECT * FROM user_sequences;
SELECT myseq.nextval FROM dual;


-- ex:不設置緩存
DROP SEQUENCE myseq;
CREATE SEQUENCE myseq NOCACHE;
SELECT * FROM user_sequences;
SELECT myseq.nextval FROM dual;


-- 序列在一個數值範圍內循環:1、3、5、7、9。
-- ex:創建循環序列
DROP SEQUENCE myseq;
CREATE SEQUENCE myseq 
START WITH 1
INCREMENT BY 2
MAXVALUE 10
MINVALUE 1
CYCLE
CACHE 3;
SELECT * FROM user_sequences;
SELECT myseq.nextval FROM dual;


-- ➤修改序列
/*
語法:
ALTER SEQUENCE 序列名稱
[INCREMENT BY 步長]
[START WITH 開始值]
[MAXVALUE 最大值|NOMAXVALUE]
[MINVALUE 最小值|NOMINVALUE]
[CYCLE|NOCYCLE]
[CACHE 緩存大小|NOCACHE]
*/

-- ex:定義一個基本序列
DROP SEQUENCE myseq;
CREATE SEQUENCE myseq ;
SELECT * FROM user_sequences;


-- ex:按照如下方式修改序列
-- 將每次的步長修改為10
-- 將序列的最大值修改為98765
-- 緩存修改為100
ALTER SEQUENCE myseq
INCREMENT BY 10
MAXVALUE 98765
CACHE 100;
SELECT * FROM user_sequences;


-- ➤自動序列(Oracle 12c新特性)
-- 說明:從Oracle 12c起，為了方便用戶生成數據表的流水編號，所以提供了類似於DB2
-- 或MySQL那樣的自動增長列，而這種自動增長列實際上也是一個序列，只是序列對象的
-- 定義是由Oracle數據庫自己控制的。
/*
語法:
CREATE TABLE 表名稱(
	列名稱 類型 GENERATED BY DEFAULT AS INDENTITY(
		[INCREMENT BY 步長]
		[START WITH 開始值]
		[MAXVALUE 最大值|NOMAXVALUE]
		[MINVALUE 最小值|NOMINVALUE]
		[CYCLE|NOCYCLE]
		[CACHE 緩存大小|NOCACHE]
	),
	列名稱 類型...
);
*/

-- ex:使用自動增長列
-- note:有了自動增長列後，用戶在增加記錄時就不再需要配置mid的內容
DROP TABLE member PURGE;
CREATE TABLE member(
mid NUMBER GENERATED BY DEFAULT AS IDENTITY(START WITH 1 INCREMENT BY 1),
name VARCHAR2(50) NOT NULL,
CONSTRAINT pk_mid PRIMARY KEY(mid)
);

SELECT * FROM user_sequences;
INSERT INTO member (name) VALUES ('張無忌');
INSERT INTO member (name) VALUES ('周芷若');
INSERT INTO member (name) VALUES ('趙敏');
SELECT * FROM member;


-- 自動的序列會在表徹底刪除之後被自動的刪除
-- 情況一:
DROP TABLE member PURGE;
SELECT * FROM user_sequences;
-- 情況二:
DROP TABLE member;
SELECT * FROM user_sequences;
PURGE RECYCLEBIN;
SELECT * FROM user_sequences;

--============================================================================--
--                                                                            --
/* ※其他數據庫對象-同義詞                                                    */
--                                                                            --
--============================================================================--
-- 說明:為解決不同用戶之間，訪問表時一定要加上用戶名。如:dual表示的是sys.dual，
-- 而dual就是同義詞。
-- ▲同義詞須具備管理員權限才能創建。
-- ▲同義詞本身只屬於Oracle數據庫自己的特徵，所以在其他數據庫之中不一定會存在此
-- 概念。

-- ➤創建同義詞
-- 語法:
-- CREATE [PUBLIC] SYNONYM 同義詞名稱 FOR 數據庫對象

-- ex:在sys用戶中，為c##scott創建myemp同義詞
CONN sys/change_on_install AS SYSDBA;
CREATE SYNONYM myemp FOR c##scott.emp;
-- 在sys用戶中，執行查詢
SELECT * FROM myemp;
-- 在sys用戶中，查看user_synonyms數據字典
SELECT * FROM user_synonyms;

-- 此時所創建的同義詞只能被sys使用，如果希望同義詞被所有用戶使用，那麼應該將其
-- 創建為公共同義詞。

-- 創建公共同義詞前將已創建的同義詞刪除
-- ➤刪除同義詞
-- ex:在sys用戶中，刪除同義詞
DROP SYNONYM myemp;
CREATE PUBLIC SYNONYM myemp FOR c##scott.emp;












