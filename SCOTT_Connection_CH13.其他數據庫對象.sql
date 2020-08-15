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
--============================================================================--
--                                                                            --
/* ※其他數據庫對象-Oracle偽列                                                */
--                                                                            --
--============================================================================--
-- ➤ROWID偽列
-- 在數據表中每一行所保存的紀錄，實際上Oracle都會默認位每條紀錄分配一個唯一的
-- 地址編號，而這個地址編號就是透過ROWID進行表示的，ROWID本身是一個數據的偽列
-- ，所有的數據都利用ROWID進行數據定位。
-- ▲ROWID可以作為唯一的橫列標記。
-- ▲利用ROWNUM可以取得第一橫列和前N橫列紀錄。

-- ex:查看ROWID
SELECT ROWID, deptno, dname, loc FROM dept;
-- ROWID不在dept表中，但卻可以使用。
-- ROWID組成:
-- 數據對象號(date object number):為AAAWok。
-- 相對文件號(relative file number):為AAG。
-- 數據塊號(block number):為AAAAC1。
-- 數據行號(row number):為AAD。


-- 如果需要還原ROWID的內容，那麼可以利用以下的函數完成。
-- DBMS_ROWID.rowid_object(ROWID):從一個ROWID之中，取得數據對象號。
-- DBMS_ROWID.rowid_relative_fno(ROWID):從一個ROWID之中，取得相對文件號。
-- DBMS_ROWID.rowid_block_number(ROWID):從一個ROWID之中，取得數據塊號。
-- DBMS_ROWID.rowid_row_number(ROWID):從一個ROWID之中，取得數據行號。
SELECT ROWID, 
DBMS_ROWID.rowid_object(ROWID) 數據對象號, 
DBMS_ROWID.rowid_relative_fno(ROWID) 相對文件號, 
DBMS_ROWID.rowid_block_number(ROWID) 數據塊號, 
DBMS_ROWID.rowid_row_number(ROWID) 數據行號,
deptno, dname, loc  
FROM dept;


-- ex:將表中重複的數據刪除掉，只保留不重複的數據。
-- 刪除重複數據後最終的效果如下
SELECT ROWID, deptno, dname, loc FROM dept;
-- 操作前準備:
-- 將dept表複製mydept
CREATE TABLE mydept AS SELECT * FROM dept; 
-- 在mydept表中增加若干行數據
INSERT INTO mydept (deptno,dname,loc) 
  VALUES (10,'ACCOUNTING','NEW YORK');
INSERT INTO mydept (deptno,dname,loc) 
  VALUES (10,'ACCOUNTING','NEW YORK');
INSERT INTO mydept (deptno,dname,loc) 
  VALUES (10,'ACCOUNTING','NEW YORK');
INSERT INTO mydept (deptno,dname,loc) 
  VALUES (20,'RESEARCH','DALLAS');
INSERT INTO mydept (deptno,dname,loc) 
  VALUES (20,'RESEARCH','DALLAS');
-- 在mydept表中存在大量的重複數據
SELECT ROWID, deptno, dname, loc FROM mydept;

-- 程序分析:對於刪除數據，現在只要求保留一條，其他的重複都被刪除掉。既然要保留
-- 最早的，那麼ROWID一定是最小的。
-- 對mydept分組，統計出最早的ROWID數據
SELECT MIN(ROWID), deptno, dname, loc 
FROM mydept
GROUP BY deptno, dname, loc;
-- 此時已經知道了要保留的ROWID數據了，那麼就可以排除以上的幾個ROWID。
DELETE FROM mydept 
WHERE ROWID NOT IN(
  SELECT MIN(ROWID)  
  FROM mydept
  GROUP BY deptno
); 
SELECT ROWID, deptno, dname, loc FROM mydept;


-- ➤ROWNUM偽列
-- 說明:主要是生成行號。
-- 在所有給出的偽列之中，ROWNUM是一個非常重要的核心重點。

-- ex:
SELECT ROWNUM, empno, ename, job, sal, hiredate FROM emp;
-- 在emp表中不存在ROWNUM這個列，可是這個列可以直接使用。可是必須提醒的是，
-- ROWNUM絕對不是固定與某條數據綁在一起的。


-- ex:列出工資高於公司平均工資的所有員工編號、姓名、基本工資、職位、僱用日期、
-- 所在部門名稱、位置、公司的工資等級，但是為了訊息瀏覽方便，要求在每一行數據
-- 顯示前都增加一個行號
SELECT ROWNUM, e.empno, e.ename, e.sal, e.job, e.hiredate, 
d.dname, d.loc, s.grade 
FROM emp e, dept d, salgrade s 
WHERE e.sal>(SELECT avg(sal) FROM emp)
AND e.deptno=d.deptno 
AND sal BETWEEN losal AND hisal;
-- note:ROWNUM是根據紀錄橫列的累加而進行的自動編號，絕對不是固定的。


-- ➤ROWNUM作用
-- ROWNUM除了可以自動的進行橫列號的顯示之外，也可以完成以下兩個常用操作:
-- 操作一:取出一個查詢的第一橫列紀錄。
-- 操作二:取出一個查詢的前n橫列紀錄。


-- ex:使用ROWNUM取得首橫列
SELECT * FROM emp WHERE ROWNUM=1;
-- 但是只能是首橫列不能是其他橫列。因為ROWNUM是隨機生成，是在SELECT子句之中
-- 出現，WHERE要優先於SELECT執行。
SELECT * FROM emp WHERE ROWNUM=2;
-- 對於ROWNUM而言，可以取得前n橫列紀錄。
SELECT * FROM emp WHERE ROWNUM<=10;
SELECT * FROM emp WHERE ROWNUM<=5;
-- 但如果設置範圍，那就不能取得了，例如使用BETWEEN...AND...
SELECT * FROM emp WHERE ROWNUM BETWEEN 5 AND 10;


-- ➤數據的分頁顯示
-- 分頁操作組成:
--  數據顯示部份:主要是從數據表之中選出指定的部份數據，需要ROWNUM偽列才可以完成。
--  分頁控制部份:留給用戶的控制端，用戶只需要選擇指定的頁數，那麼應用程序就會根據
--              用戶的選擇，列出指定的部份數據，相當於控制了格式中的currentPage。

/*
--▲子查詢:找出ROWNUM <= 當前頁數 * 每頁顯示筆數 = 總筆數，
          找出大於總筆數中的第n筆 = 
          橫列數值 > 當前頁數-1 * 每頁顯示筆數 = 分頁顯示紀錄
          
分頁操作語法:
SELECT * FROM 
(
	SELECT 列1,[,列2,...],ROWNUM rownum別名
	FROM 表名稱[別名]
	WHERE ROWNUM<=(currentPage(當前所在頁)*lineSize(每頁顯示紀錄行數))
) temp
WHERE temp.rownum別名>(currentPage(當前所在頁)-1)*lineSize(每頁顯示紀錄行數);
*/

-- ex:取出員工之中的前5條紀錄
SELECT empno, ename, sal, job, hiredate, mgr, deptno, ROWNUM rn
FROM emp 
WHERE ROWNUM<=5;


-- ex:假設每頁顯示5條，linesize=5，那麼當前業就是在第一頁，currentPage=1。
SELECT * FROM(
  SELECT empno, ename, sal, job, hiredate, mgr, deptno, ROWNUM rn
  FROM emp 
  WHERE ROWNUM<=5) temp 
WHERE temp.rn>0;


-- ex:顯示6~10條紀錄
-- 當前所在頁為第2頁，那麼currentPage=2，每頁顯示5橫列，linesize=5
SELECT * FROM(
  SELECT empno, ename, sal, job, hiredate, mgr, deptno, ROWNUM rn
  FROM emp 
  WHERE ROWNUM<=10) temp 
WHERE temp.rn>5;


-- ➤FETCH(Oracle 12c新特性)
-- 說明:在Oracle 12c之中為了方便數據的分頁顯示操作，專門提供了FETCH語句，使用此
-- 語句可以方便的取得指定範圍內的操作數據。
/*
FETCH語法:
SELECT [DISTINCT] 分組欄位1[AS][直行別名],[分組欄位2[AS][直行別名],...]
FROM 表名稱1[表別名1],表名稱2[表別名2]...
[WHERE 條件(s)]
[GROUP BY 分組欄位1,分組欄位2,...]
[HAVING 過濾條件(s)]
[ORDER BY 排序欄位 ASC|DESC]
[FETCH FIRST 橫列數][OFFSET 開始位置 ROWS FETCH NEXT 個數]|[FETCH NEXT 百分比
PERCENT] ROW ONLY

此語句有三種使用方式:
①取得前n橫列紀錄:FETCH FIRST 橫列數 ROW ONLY。
②取得指定範圍的紀錄:OFFSET 開始位置 ROWS FETCH NEXT 個數 ROWS ONLY。
③按照百分比取得紀錄:FETCH NEXT 百分比 PERCENT ROWS ONLY。
*/

-- ex:取得emp表前5條紀錄
SELECT *
FROM emp 
ORDER BY sal DESC
FETCH FIRST 5 ROW ONLY;


-- ex:取得emp表4~5條紀錄
-- 從第3列開始取2條紀錄
SELECT *
FROM emp 
ORDER BY sal DESC
OFFSET 3 ROWS FETCH NEXT 2 ROWS ONLY;


-- 按照百分比取部分數據
SELECT *
FROM emp 
ORDER BY sal DESC
FETCH NEXT 10 PERCENT ROWS ONLY;
--============================================================================--
--                                                                            --
/* ※其他數據庫對象-索引                                                      */
--                                                                            --
--============================================================================--
-- 說明:主要是進行查詢優化。在數據庫之中，索引是一種專門用於數據庫查詢操作性能的一種手段。
-- 在Oracle中為了維護這種查詢性能，需要對某一類數據進行指定結構的排列。但是在Oracle之中，
-- 針對於不同的情況會有不同的索引使用。
-- ▲索引是一種相對提升數據庫性能的手段，並非絕對。


-- ➤B數索引(B*Tree)
-- 說明:是最為基本的索引結構，在Oracle之中默認建立的索引就是此類型索引。一般B樹
-- 索引在檢索高基數數列(該直行上重複內容較少或沒有)的時候可以提供高性能的檢索操
-- 作。

-- B-Tree索引由分支塊(branch block)和葉塊(leaf block)組成。在樹結構中，位於最底層
-- 底塊被稱為葉塊，包含每個被索引列的值和行所對應的ROWID。在葉節點的上面是分支塊
-- ，用來導航結構，包含了索引列(關鍵字)範圍和另一索引塊的地址。
-- 主要包含的組件如下:
-- 葉子節點(Leaf Node):包含直接指向表中的數據行(即:索引項)。
-- 分支節點(Branch Node):包含指向索引裡其他的分支節點或是葉子節點。
-- 根節點(Root Node):一個B樹索引只有一個根節點，是位於最頂端的分支節點。

-- 每一個索引項都由下面三個部份組成:
-- 索引項頭(Entry Header):存儲了行數和鎖的訊息。
-- 索引列長度和值:兩者需要同時出現，定義了列的長度而長度之後保存的就是列的內容。
-- ROWID:指向表中數據橫列的ROWID，透過此ROWID找到完整紀錄。


-- ex:查詢工資大於1500的全部員工
SELECT * FROM emp WHERE sal>1500;
-- 在默認情況下，如果使用以上的查詢，那麼肯定是採用逐行掃描。如果emp有500萬條紀
-- 錄，那麼就表示這500萬條紀錄都要被掃描。如果現在假設在200萬條之後已經沒有滿足
-- 條件的數據，但是默認還是需要全部檢索，所以就會帶來查詢效能的問題。
-- 所謂的逐行掃描實際上就表示全部掃描，如果想觀察到此類形式，可以打開跟蹤。

-- 使用系統管理員打開跟蹤
CONN sys/change_on_install AS SYSDBA;
SET AUTOTRACE ON;
SELECT * FROM c##scott.emp WHERE sal>1500;
-- 可以發現查詢採用:TABLE ACCESS FULL。


-- 為解決全部檢索帶來的性能問題，採用排序方式查詢
-- ex:現在假設emp表中的工資數據為"1300、2850、1100、1600、2450、2975、5000、3000、
-- 1250、950、800"，則現在可以按照以下的原則進行樹結構的繪製
-- 取第一個數據作為根節點，比根節點小的數據放在左子樹，比根節點大的數據放在右子樹。
-- 如果不想全部查詢，那麼就必須將數據以樹的形式展現出來。而且在整個過程之中也可
-- 以發現，在樹排列的時候有一個ROWID，必須利用此ROWID找到對應數據，而且利用
-- ROWID實現的查詢，也是非常快的。

-- 在系統管理員中操作，根據ROWID查詢
SELECT ROWID, empno FROM c##scott.emp;
SELECT * FROM c##scott.emp WHERE ROWID='AAAWomAAGAAAADFAAA';


-- ex:使用系統管理員操作，在emp.sal欄位上創建索引，但須注意，最好的索引是在高基
-- 數列(沒有重複的值)上使用。
-- 創建B*Tree索引列
-- 語法:
-- CREATE INDEX[用戶名.]索引名稱 ON[用戶名.]表名稱(直行名稱[ASC|DESC],...);
CREATE INDEX emp_sal_ind ON c##scott.emp(sal);
-- 此時是手動創建索引，如果現在表中的列上定義了主鍵或者是唯一約束的時候，會自動
-- 創建索引。


-- 使用系統管理員進行查詢
SELECT * FROM c##scott.emp WHERE sal>1500;
-- 可以發現查詢採用:INDEX RANGE SCAN。
-- 而同時在數據字典之中來觀察所有的索引對象。
-- SELECT * FROM user_indexes;
SELECT * FROM user_ind_columns;


-- 那麼索引一定可以提昇性能嗎?如果在數據量很大而且到處都是多表關聯，那麼想提昇性
-- 能也不好提昇，最好的作法是夠透過冗餘欄位，減少多表查詢。
-- 發現索引如果想正常操作，那麼必須始終維持這一棵樹。可是如果表需要被頻繁修改，
-- 1秒改100次，每次都需要重複修改樹，現在又要求保持高速的查找，同時又要求可以接
-- 收頻繁的更新，只有一個方法:用時間換空間，犧牲實時性。


-- ➤降序索引
-- ex:使用系統管理員定義降序索引
CREATE INDEX emp_hiredate_ind_desc ON c##scott.emp(hiredate);


-- ex:使用系統管理員操作，在hiredate欄位上設置查詢的條件，查詢所有在1981年
-- 雇用的員工
SELECT * 
FROM c##scott.emp 
WHERE hiredate 
BETWEEN TO_DATE('1981-01-01','YYYY-MM-DD') 
AND TO_DATE('1981-12-31','YYYY-MM-DD') 
ORDER BY hiredate DESC;
-- 可以發現查詢採用:INDEX RANGE SCAN DESCENDING


-- ➤函數索引
-- 說明:是一種B樹索引的衍生品。
-- :在ename欄位上定義函數索引
CREATE INDEX emp_ename_ind ON emp(LOWER(ename));
-- ex:使用系統管理員操作，員工姓名查詢
SELECT * FROM c##scott.emp WHERE LOWER(ename)='smith';


-- ➤位圖索引
-- 說明:如果說現在某一直行上的數據都屬於低基數(Low-Cardinality)的時候就可以利用
-- 位圖索引來提昇查詢的性能，例如:表示員工的數據表上會存在部門編號(deptno)的數據
-- 直行，而在部門編號直行上現在只有三種取值:10、20、30，在這種情況下使用位圖索引
-- 是最適合的。

-- 原理:對於表中的每一數據橫列的位圖包含了deptno=10、deptno=20、deptno=30值，現
-- 一共只包含了3個基數，如果說現在表中有30萬條紀錄，那麼最終這些直行也只分為了3
-- 組，這樣在進行位圖查找的時候可以非常的方便和快捷。同時，位圖索引以一種壓縮數
-- 據的格式存放，因此所佔用的硬碟空間要比B*Tree索引小很多。


-- ex:使用系統管理員在deptno欄位上定義位圖索引
CREATE BITMAP INDEX emp_deptno_ind ON c##scott.emp(deptno);


-- ex:使用系統管理員操作，根據部門編號查找
SELECT * FROM c##scott.emp WHERE deptno =10;

SELECT * FROM user_ind_columns;
SELECT * FROM user_indexes;


-- ➤刪除索引
-- 說明:索引本身需要進行自身數據結構的維護，所以一般而言會占用較大的硬碟空間。並且
-- 隨著表的增長，索引所占用的空間也會越來越大。那麼對於數據庫之中那些不經常使用的
-- 索引就應該盡早刪除。索引是以Oracle對樣存在的，所以用戶可以直接利用DROP語句進行
-- 索引的刪除。

-- ex:使用系統管理員操作刪除索引
DROP INDEX c##scott.emp_sal_ind;
-- ex:使用c##scott操作刪除索引
DROP INDEX emp_ename_ind;