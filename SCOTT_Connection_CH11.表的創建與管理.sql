--============================================================================--
--                                                                            --
/* ※表的創建與管理-表的基本操作  		                                      */
--                                                                            --
--============================================================================--
-- ➤Oracle常用數據類型
-- CHAR(n):n = 1 to 2000(字元)。保存固定長度的字串。
-- VARCHAR2(n):長度，n = 1 to 4000(字元)。可以放數字、字母以及ASCII碼字符集，
-- 			   Oracle 12C開始，最大支持32767字元長度。
-- NUMBER(m,n):長度，m = 1 to 38、n = -84 to 127。表示數字，其中小數部份長度為m，
-- 			   整數部份為m-n位。
-- DATE:用於存放日期時間型數據(不包含毫秒)。
-- TIMESTAMP:用於存放日期時間型數據(包含毫秒)。
-- CLOB:長度，4G。用於存放海量文字。
-- BLOB:長度，4G。用於保存二進制文件。

-- ex:建立member表
CREATE TABLE member(
mid NUMBER(5), 
name VARCHAR(50) DEFAULT '無名氏', 
age NUMBER(3), 
birthday DATE DEFAULT SYSDATE, 
note CLOB
);
SELECT * FROM tab;
-- 查看表結構
DESC member;


-- ex:向表中增加紀錄
INSERT INTO member (mid,name,age,birthday,note) 
VALUES (1,'張無忌',30,TO_DATE('1990-02-12','YYYY-MM-DD'),'武當派');
INSERT INTO member (mid,name,age,birthday,note) 
VALUES (2,'周芷若',36,TO_DATE('1984-05-14','YYYY-MM-DD'),'峨嵋派');
SELECT * FROM member;


-- ➤表的複製
-- 語法:CREATE TABLE 表名稱 AS 子查詢;
-- note:表的複製操作只要是行與列的查詢結果，就可以將其定義為數據表。
-- ex:複製一張完整的表
CREATE TABLE myemp1 AS SELECT * FROM emp;
SELECT * FROM tab;
SELECT * FROM myemp1;


-- ex:複製的表的部分訊息;將10部門的員工訊息複製到myemp10表
CREATE TABLE myemp10 AS SELECT * FROM emp WHERE deptno=10;
SELECT * FROM tab;
SELECT * FROM myemp10;


-- ex:複製表的結構;執行一個永不滿足的條件
CREATE TABLE employee AS SELECT * FROM emp WHERE 1=2;
SELECT * FROM tab;
DESC employee;
SELECT * FROM employee;

-- ➤表的複製-針對查詢結果進行創建表
-- ex:
CREATE TABLE department 
AS 
SELECT d.deptno, d.dname, d.loc, 
SUM(e.sal+NVL(e.comm,0)) sum, 
ROUND(AVG(e.sal+NVL(e.comm,0)),2) avg, 
MAX(e.sal) max, 
MIN(e.sal) min
FROM emp e, dept d 
WHERE e.deptno(+)=d.deptno 
GROUP BY d.deptno, d.dname, d.loc 
ORDER BY d.deptno;

SELECT * FROM department;


-- ➤數據字典
-- 說明:在Oracle中專門提供了一組數據專門用於紀錄數據庫對象訊息、對象結構、
-- 管理訊息、存儲訊息的數據表，那麼這種類型的表就稱為數據字典，在Oracle中一共
-- 定義了兩類數據字典:
-- ①靜態數據字典:這類數據字典由表及視圖所組成，這些視圖分三類:
-- 	user_*:存儲了所有當前用戶的對象訊息。
-- 	all_*:存儲所有當前用戶可以訪問的對象訊息(某些對象可能不屬於此用戶)。
-- 	dba_*:存儲數據庫之中所有對象的訊息(數據庫管理員操作)。
-- ②動態數據字典:隨著數據庫運行而不斷更新的數據表，一般用來保存內存和硬碟狀態
-- 				  ，而這類數據字典都以"v$"開頭。

-- 所有的數據表都屬於數據庫對象，每當創建一張數據表的時候，會自動在制定的數據字
-- 典表執行一個增加語句(這個增加語句你是不知道的)，但是這些數據字典的數據操作只
-- 能透過命令完成。

-- ex:靜態數據字典，如果想要知道全部的數據表對象，使用user_tables，這個數據字典。
SELECT * FROM user_tables;


-- ➤數據表重命名
-- 說明:在Oracle中數據表是可以被重新命名的，主要是由Oracle存處結構決定的。
/*
在Oracle之中，為了方便用戶對數據表進行管理，所以專門提供了修改表名稱的操作
語法:RENAME 舊的表名稱 TO 新的表名稱
*/
-- ex:將member表修改為testuser表
RENAME member TO testuser;
SELECT * FROM tab;
SELECT * FROM testuser;
-- 此時使用回滾表名稱依然是testuser;
ROLLBACK;
-- note:當發生任何的DDL操作的時候對於事務都會自動提交。例如:現在正在執行某些更
-- 新操作，但是在更新操作的中間出現了某些創建表的操作，這個時候對於事務而言，是
-- 會自動提交的。而且所有的DDL操作不受事務的控制。


-- ➤截斷表
-- 如果說現在表中的紀錄都不再需要，最早可以知道的就是DELETE語法，刪除表的全部內
-- 容。但是刪除的同時所佔用的資源(表空間資源、約束、索引等)都不會立刻被釋放掉，
-- 可是如果現在希望能夠立刻被釋放掉資源，只能夠截斷表。
-- ex:截斷testuser表;表一但被截斷之後，所占用的全部資源都將釋放掉。
TRUNCATE TABLE testuser;
SELECT * FROM tab;
SELECT * FROM testuser;

ROLLBACK;
SELECT * FROM testuser;


-- ➤刪除表
DROP TABLE testuser;
DROP TABLE myemp;
DROP TABLE myemp1;
DROP TABLE myemp10;
DROP TABLE employee;
DROP TABLE department;

SELECT * FROM tab;
SELECT * FROM testuser;
--============================================================================--
--                                                                            --
/* ※表的創建與管理-閃回技術(Flashback)  		                              */
--                                                                            --
--============================================================================--
-- 說明:在Oracle 10g之前的版本，如果執行了DROP TABLE語句，那麼就表示表被徹底的
-- 刪除了，只能透過備份文件進行恢復。在Oracle 10g開始為了解決誤刪除表的操作情況
-- ，所以提供了閃回技術的支持，所謂的閃回指的是在刪除表的時候不是立刻刪除，而是將
-- 表暫時保存在回收佔裡。如果發現刪除表有錯誤，那麼可以進行恢復。
-- 在Oracle 10g的時候只需要透過如下的命令就可以查看回收站。
SHOW RECYCLEBIN;
-- 但是從 Oracle 11g開始，這個命令如果在sqlplus中使用，會造成閃退。所以最為保險
-- 的作法還是按照SQL語句的方式進行閃回操作。

-- ➤查看回收站中的數據
-- ex:SELECT * FROM RECYCLEBIN;
SELECT object_name, original_name, operation, type FROM RECYCLEBIN;


-- ➤閃回(恢復)指定表
FLASHBACK TABLE myemp TO BEFORE DROP;
SELECT * FROM tab;
SELECT * FROM myemp;


-- 在windows裡面回收站提供有徹底刪除的功能，不進入到回收站而是直接刪除掉全部內容。
-- 在Oracle中也存在此項支持。
-- ➤徹底刪除表，不經過回收站
DROP TABLE myemp PURGE;
-- ➤徹底刪除回收站之中的表
PURGE TABLE employee;
-- ➤清空回收站之中的表
PURGE RECYCLEBIN;
--============================================================================--
--                                                                            --
/* ※表的創建與管理-修改表結構			  		                              */
--                                                                            --
--============================================================================--





