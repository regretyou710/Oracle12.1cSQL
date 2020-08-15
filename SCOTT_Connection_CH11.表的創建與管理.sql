--============================================================================--
--                                                                            --
/* ※表的創建與管理-表的基本操作                                              */
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
/* ※表的創建與管理-閃回技術(Flashback)                                       */
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
-- ➤徹底刪除回收站之中指定的表
PURGE TABLE employee;
-- ➤清空回收站之中所有的表
PURGE RECYCLEBIN;
--============================================================================--
--                                                                            --
/* ※表的創建與管理-修改表結構                                                */
--                                                                            --
--============================================================================--
-- 數據表屬於Oracle數據庫對象，那麼只要針於數據庫對象，其操作的語法就只有三中:
-- ①創建:CREATE 對象類型 名稱。
-- ②刪除:DROP  對象類型 名稱。
-- ③修改:ALTER 對象類型 名稱。
-- 須強調的是:如果可能盡量不要去使用數據表的改操作，ALTER指令盡量可以忽略，如果
-- 在開發之中修改表結構，把表刪了重新建立。

-- ➤操作準備
@C:\Users\user\Desktop\Oracle12.1cSQL\CH11.表的創建與管理member.sql
SELECT * FROM member;


-- ➤為表中增加數據欄位
-- 語法:ALTER TABLE 表名稱 ADD(欄位名稱 欄位類型 DEFAULT 默認值,
-- 		欄位名稱 欄位類型 DEFAULT 默認值..); 
-- ex:向member增加欄位
-- 1.如果增加的時候沒有設置默認值，那麼所有的資料內容都是null。
ALTER TABLE member ADD(age NUMBER(3));
SELECT * FROM member;
-- 2.增加時設置默認值，那麼所有的資料內容都會變為默認值的內容。
ALTER TABLE member ADD(sex VARCHAR2(10) DEFAULT '男');
ALTER TABLE member ADD(photo VARCHAR2(100) DEFAULT 'nophoto.jpg');
SELECT * FROM member;


-- ➤修改表中的欄位
-- 語法:ALTER TABLE 表名稱 MODIFY(欄位名稱 欄位類型 DEFAULT 默認值); 
-- ex:向member修改欄位
ALTER TABLE member MODIFY(name VARCHAR2(30));
ALTER TABLE member MODIFY(sex VARCHAR2(10) DEFAULT '女');
DESC member;
INSERT INTO member (mid,name) VALUES (4,'小昭');
SELECT * FROM member;


-- ➤刪除表中的欄位
-- note:在進行直行刪除時，至少保留一個直行。如果某個數據表數據量很大，執行這種
-- 刪除操作，這種性能損耗是非常龐大的，所以很多時候為了保證表在大數據量的情況下
-- 刪除操作可以使用，又不影響表的正常使用，所以可以將表中設置為無用的直行。
-- 語法:ALTER TABLE 表名稱 DROP COLUMN 欄位名稱; 
-- ex:向member刪除欄位
ALTER TABLE member DROP COLUMN photo;
ALTER TABLE member DROP COLUMN age;
DESC member;
SELECT * FROM member;


-- ➤無用欄位設置
-- 語法:ALTER TABLE 表名稱 SET UNUSED(欄位名稱);
-- 		ALTER TABLE 表名稱 SET UNUSED COLUMN 欄位名稱;
-- ex:向member設置無用欄位
ALTER TABLE member SET UNUSED(sex);
ALTER TABLE member SET UNUSED COLUMN name;
DESC member;
SELECT * FROM member;
-- 標記為無用欄位後，就可以執行刪除無用欄位
-- ex:向member刪除無用欄位
ALTER TABLE member DROP UNUSED COLUMNS;
DESC member;
SELECT * FROM member;


-- ➤添加註釋
-- 語法:COMMENT ON TABLE 表名稱|COLUMN 表名稱.欄位名稱 IS '註釋內容';
-- ex:建立一張基本的表結構
-- 刪除數據表
DROP TABLE member PURGE;
-- 創建數據表
CREATE TABLE member(
mid NUMBER, 
name VARCHAR(50) DEFAULT '無名氏', 
age NUMBER(3), 
hirthday DATE
);
-- ex:查看表的註釋訊息;在Oracle中提供了一個"user_tab_comments"數據字典
SELECT * FROM user_tab_comments;
-- ex:向member表添加註釋
COMMENT ON TABLE member IS '用於紀錄參加活動的成員訊息';
SELECT * FROM user_tab_comments WHERE table_name='MEMBER';

-- ex:查看橫列的註釋訊息;在Oracle中提供了一個"user_col_comments"數據字典
SELECT * FROM user_col_comments;
-- ex:向member表中的mid欄位添加註釋
COMMENT ON COLUMN member.mid IS '參加活動的成員編號';
SELECT * FROM user_col_comments WHERE table_name='MEMBER';


-- ➤設置可見/不可見欄位
-- 說明:如果某些數據直行的內容不需要使用，那麼直接為其設置null值數據即可，但是這
-- 樣一來有可能會出現一個小問題，例如:在一張數據表設計的時候，考慮到日後需要增加
-- 若干個直行，那麼這些直行如果提前增加的話，那麼就有可能造成開發人員的困擾(不知
-- 到這些直行要作什麼)，為此就希望將這些暫時不使用的直行定義為不可見的狀態，這樣
-- 開發人員在瀏覽數據時只需要瀏覽有用的部份即可。當需要這些直行時，再恢復其可見
-- 狀態。在Oracle 12C之前，這些特性是不被支持的，而從Oracle 12C開始為了方便用戶
-- 進行表管理，提供了不可見直行的使用，同時用戶也可以將一個可見直行修改為不可見
-- 的狀態。
-- 語法:ALTER TABLE 表名稱 MODIFY(欄位名稱 INVISIBLE);

-- ex:定義數據表
DROP TABLE mytab PURGE;
CREATE TABLE mytab(
mid NUMBER, 
name VARCHAR2(30)
);
-- 如果現在name是一個之後才會使用的欄位，那麼這種情況下直接執行INSERT INTO操作，
-- 必須設置mid和name。
INSERT INTO mytab VALUES(1);
-- 執行上面語句後發生，SQL 錯誤: ORA-00947: 值不夠


-- ex:將name欄位修改為不可見狀態
ALTER TABLE mytab MODIFY(name INVISIBLE);
DESC mytab;
-- 此時name欄位就不會在表結構上進行顯示，但是在數據字典上"user_tab_columns"可以查到
SELECT * FROM user_tab_columns WHERE table_name='MYTAB';
-- 再次進行添加數據
INSERT INTO mytab VALUES(1);
SELECT * FROM mytab;


-- ex:將name欄位修改為可見狀態
ALTER TABLE mytab MODIFY(name VISIBLE);
DESC mytab;
SELECT * FROM mytab;


-- 除了在表創建之後修改可見與不可見狀態之外，表在創建的時候也可以直接設置。
DROP TABLE mytab PURGE;
CREATE TABLE mytab(
mid NUMBER, 
name VARCHAR2(30) INVISIBLE
);
DESC mytab;
SELECT * FROM user_tab_columns WHERE table_name='MYTAB';
--============================================================================--
--                                                                            --
/* ※表的創建與管理-表空間                                                    */
--                                                                            --
--============================================================================--
-- ➤表空間
-- 說明:所有的商業應用所有的操作都是以操作系統為前提的，所以數據庫一定是安裝在操
-- 作系統上。對於數據庫中的數據，那麼也一定是保存在硬碟上。在Oracle之中，數據庫
-- 也被稱為實例(Instance 圖書館)，而數據庫中維護的是表空間(每一組書架)，那麼每張
-- 表都要保存在表空間之中(圖書)。

-- 在數據庫數據和硬碟數據之間存在了兩種結構:
-- ①邏輯結構:Oracle中所引入的結構，開發人員所操作的都只針對於Oracle的邏輯結構。
-- ②物理結構:操作系統擁有的存儲結構，而邏輯結構到物理結構的轉換由Oracle數據庫管
-- 			  理系統來完成。

-- 說明二:表空間是Oracle數據庫之中最大的一個邏輯結構，每一個Oracle數據庫都會由若干
-- 個表空間所組成，而每一個表空間將由多個數據文件組成，用戶所創建的數據表也統一被
-- 表空間所管理。表空間與硬碟上的數據文件對應，所以直接與物理存儲結構關聯。而用戶
-- 在數據庫之中所創建的數據表、索引、視圖、子程序等都被表空間保存到了不同的區域內。
-- 在Oracle數據庫之中一般有兩類表空間:
-- ①系統表空間:是在數據庫創建時與數據庫一起建立起來的，例如:用戶用於撤銷的事務
--              處理，或者使用的數據字典就保存在系統表空間之中，例如:System或
--              Sysaux表空間。
-- ②非系統表空間:由具備指定管理員權限的數據庫用戶創建，主要用於保存用戶數據、索
--                引等數據庫對象，例如:USERS、TEMP、UNDOTBS1等表空間。
-- ▲數據表受到表空間的管理。
-- ▲表空間分為兩類:數據表空間、臨時表空間。

-- ➤創建表空間
/*
如果要進行非系統表空間的創建，可以使用下面語法完成。
CREATE [TEMPORARY] TABLESPACE 表空間名稱
[DATAFILE|TEMPFILE 表空間文件保存路徑...][SIZE 數字[K|M]]
[AUTOEXTEND ON|OFF][NEXT 數字[K|M]]
[LOGGING|NOLOGGING];

本程序各個創建子句的相關說明如下:
DATAFILE:保存表空間的硬碟路徑，可以設置多個保存路徑。
TEMPFILE:保存臨時表空間的硬碟路徑。
SIZE:開闢的空間大小，其單位有K(字元)和M(兆)。
AUTOEXTEND:是否為自動擴展表空間，如果為ON表示可以自動擴展表空間大小，反之為OFF。
NEXT:可以定義表空間的增長量。
LOGGING|NOLOGGING:是否需要對DML進行日誌紀錄，紀錄下的日誌可以用於數據恢復。
*/

-- ex:創建一個orcl12c_data的數據表空間
-- note:使用管理員權限登入並要先存在存放的資料夾
CREATE TABLESPACE orcl12c_data 
DATAFILE 'C:\orcls\orcl12c_data01.dbf' SIZE 50M, 
'C:\orcls\orcl12c_data02.dbf' SIZE 50M 
AUTOEXTEND on NEXT 2M 
LOGGING;


-- ex:創建一個orcl12c_temp的臨時表空間
CREATE TEMPORARY TABLESPACE orcl12c_temp 
TEMPFILE 'C:\orcls\orcl12c_temp01.dbf' SIZE 50M, 
'C:\orcls\orcl12c_temp02.dbf' SIZE 50M 
AUTOEXTEND on NEXT 2M;


-- 此時一共建立了orcl12c_data與orcl12c_temp兩個表空間，在創建完之後的
-- 表空間一定都會在數據字典之中進行相關內容的紀錄。如果想查看表空間(管理
-- 員負責)可以使用dba_tablespaces數據字典查看。


-- ➤使用系統管理員查看表空間
-- SELECT * FROM dba_tablespaces;
SELECT 
tablespace_name, block_size, extent_management, status, contents 
FROM dba_tablespaces;


-- ➤Oracle中的默認表空間
/*
在Oracle數據庫中默認提供了以下幾個表空間，各個表空間的作用如下:
SYSTEM表空間:在一個數據庫中至少有一個表空間，既System表空間。創建數據庫時必須指
             明表空間的數據文件的特徵，如數據文件名稱、大小。System主要是存儲數
			 據庫的數據字典，在Oracle系統表空間中存儲全部的PL/SQL程序的源代碼和
			 編譯後的代碼，例如存儲程序、函數、包、數據庫觸發器。如果要大量使用
			 PL/SQL，就應該設置足夠大的System表空間。
SYSAUX表空間:是System表空間的輔助表空間，許多數據庫的工具和可選組件將其對象存儲
             在SYSAUX表空間內，他是許多數據庫工具和可選組件的默認表空間。
Users表空間:用於存儲用戶的數據。
Undo表空間(UNDOTBS1)表空間:用於事務的回滾、撤銷。
Temp臨時表空間:用於存放Oracle運行中需要臨時存放的數據，如排序的中間結果等。
*/


-- 使用dba_tablespaces數據字典只能知道數據表空間的訊息，想知道每個表空間花費的
-- 存儲，可使用dba_data_files與dba_temp_files查看。
-- note:使用系統管理員查看
-- ex:查看"數據表空間"數據字典
SELECT * FROM dba_data_files;

-- ex:查看"臨時表空間"數據字典
SELECT * FROM dba_temp_files;


-- ➤使用表空間
-- ex:使用c##scott創建數據表並使用特定表空間
DROP TABLE mytab PURGE;
CREATE TABLE mytab(
id NUMBER, 
name VARCHAR2(20)
) TABLESPACE orcl12c_data;