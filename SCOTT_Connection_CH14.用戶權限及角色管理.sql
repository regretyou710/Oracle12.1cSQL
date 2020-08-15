--============================================================================--
--                                                                            --
/* ※用戶權限及角色管理--用戶管理                                             */
--                                                                            --
--============================================================================--
-- 簡述:用戶在Oracle數據庫之中它是以對象的形式存在的，即:用戶的操作依然需要使用
-- 到數據字典。
-- 雖然在Oracle數據庫之中已經提供了大量的用戶，但是從安全以及維護的角度來講，往
-- 往需要創建屬於自己的用戶，如果要創建用戶可以利用CREATE USER語法來完成
-- ▲用戶是屬於Oracle對象，在Oracle 12c中創建用戶要以C##開頭。
/*
創建用戶語法:
CREATE USER 用戶名 IDENTIFIED BY 密碼 [DEFAULT TABLESPACE 表空間名稱]
[TEMPORARY TABLESPACE 表空間名稱]
[QUOTA 數字[K|M]|UNLIMITED ON 表空間名稱
 QUOTA 數字[K|M]|UNLIMITED ON 表空間名稱...]
[PROFILE 概要文件名稱|DEFAULT][PASSWORD EXPIRE][ACCOUNT LOCK|UNLOCK]

語法組成如下:
①CREATE USER 用戶名 IDENTIFIED BY 密碼:創建用戶同時設置密碼，但是用戶名和密碼不
能是Oracle保留字也不能以數字開頭(如果要設置為數字，需要將數字使用雙引號聲明)。
②DEFAULT TABLESPACE 表空間名稱:用戶存儲默認使用的表空間，當用戶創建對象沒有設置
表空間時，就將保存在此處指定的表空間下，這樣就可以和系統表空間進行區分。
③TEMPORARY TABLESPACE 表空間名稱:用戶所使用的臨時表空間。
④QUOTA 數字[K|M]|UNLIMITED ON 表空間名稱:用戶在表空間上的使用限額，可以指定多個
表空間的限額，如果設置為"UNLIMITED"表示不設置限額。
⑤PROFILE 概要文件名稱|DEFAULT:用戶操作的資源文件，如果不指定則使用默認配置資源
文件。
⑥PASSWORD EXPIRE:用戶密碼失效，則在第一次使用時必須修改密碼。
⑦ACCOUNT LOCK|UNLOCK:用戶是否為鎖定狀態，默認為"UNLOCK"。
*/
-- ▲如果要進行用戶的操作，須具備系統管理員權限。

-- ➤創建用戶
-- ex:創建一個新的用戶，c##testuser，密碼為:java_andorid
CREATE USER c##testuser 
IDENTIFIED BY java_android 
DEFAULT TABLESPACE ORCL12C_DATA 
TEMPORARY TABLESPACE ORCL12C_TEMP 
QUOTA 30M ON ORCL12C_DATA 
QUOTA 20M ON users 
ACCOUNT UNLOCK 
PASSWORD EXPIRE;
-- note:此時用戶無法使用，因為沒有權限。
-- 當用戶創建完之後可以使用"dba_users"數據字典查看對象訊息。
SELECT * FROM dba_users;
-- 每一個用戶都有自己的空間使用配額，所以還可以使用"dba_ts_quotas"數據字典查看。
SELECT * FROM dba_ts_quotas;


-- ➤創建概要文件
-- 說明:概要文件是一組命名了口令資源限制文件，管理員利用它可以直接限制用戶的資源
-- 訪問量或用戶管理等操作。
-- 語法:CREATE PROFILE 概要文件名稱 LIMIT 命令(s);
/*
第一組:資源限制命令
①SESSION_PER_USER 數字 |UNLIMITED|DEFAULT:允許一個用戶同時創建SESSION的最大數量
。
②CPU_PER_SESSION 數字 |UNLIMITED|DEFAULT:每一個SESSION允許使用CPU的時間數，單位
為毫秒。
③CPU_PER_CALL 數字 |UNLIMITED|DEFAULT:限制每次調用SQL語句期間，CPU的時間總量。
④CONNECT_TIME 數字 |UNLIMITED|DEFAULT:每個SESSION的連接時間數，單位為分。
⑤IDLE_TIME 數字 |UNLIMITED|DEFAULT:每個SESSION的超時時間，單位為分。
⑥LOGICAL_READS_PER_SESSION 數字 |UNLIMITED|DEFAULT:為了防止笛卡爾積的產生，可以
限定每一個用戶最多允許讀取的數據塊數。
⑦LOGICAL_READS_PER_CALL 數字 |UNLIMITED|DEFAULT:每次調用SQL語句期間，最多允許用
戶讀取的數據塊數。

第二組:口令限制命令
①FAILED_LOGIN_ATTEMPTS 數字 |UNLIMITED|DEFAULT:當連續登入失敗次數達到該參數指定
值時，用戶被加鎖。
②PASSWORD_LIFE_TIME 數字 |UNLIMITED|DEFAULT:口令的有效(天)，默認為UNLIMITED。
③PASSWORD_REUSE_TIME 數字 |UNLIMITED|DEFAULT:口令被修改後原有口令隔多少天後可以
被重新使用，默認為UNLIMITED。
④PASSWORD_REUSE_MAX 數字 |UNLIMITED|DEFAULT:口令被修改後原有口令被修改多少次才
允許被重新使用。
⑤PASSWORD_VERIFY_FUNCTION 數字 |UNLIMITED|DEFAULT:口令校驗函數。
⑥PASSWORD_LOCK_TIME 數字 |UNLIMITED|DEFAULT:帳戶因FAILED_LOGIN_ATTEMPTS鎖定時，
加鎖天數。
⑦PASSWORD_GRACE_TIME 數字 |UNLIMITED|DEFAULT:口令過期後，繼續使用員口令官限期
(天)。
*/

-- ➤創建PROFILE文件
-- ex:使用系統管理員，創建PROFILE文件
CREATE PROFILE c##testuser_profile LIMIT 
CPU_PER_SESSION 100000 
LOGICAL_READS_PER_SESSION 2000 
CONNECT_TIME 60 
IDLE_TIME 30 
SESSIONS_PER_USER 10 
FAILED_LOGIN_ATTEMPTS 3 
PASSWORD_LOCK_TIME UNLIMITED 
PASSWORD_LIFE_TIME 60
PASSWORD_REUSE_TIME 30
PASSWORD_GRACE_TIME 6;
-- 使用"dba_profiles"數據字典進行查看
SELECT * FROM dba_profiles WHERE profile='C##TESTUSER_PROFILE';


-- ex:使用系統管理員，創建用戶同時使用profile文件
CREATE USER c##testuser02 
IDENTIFIED BY java 
PROFILE c##testuser_profile;


-- ex:使用系統管理員，針對已存在用戶修改其使用的profile文件
ALTER USER c##testuser PROFILE c##testuser_profile;


-- 此時c##testuser_profile文件已經在兩個用戶對象上被使用。
-- ex:使用系統管理員，查看dba_users數據字典，觀察兩個用戶的定義
SELECT * FROM dba_users 
WHERE username IN ('C##TESTUSER','C##TESTUSER02');


-- ➤修改PROFILE文件
-- ex:使用系統管理員，修改PROFILE文件
ALTER PROFILE c##testuser_profile LIMIT 
CPU_PER_SESSION 1000 
PASSWORD_LIFE_TIME 10;



-- ➤刪除PROFILE文件
-- 刪除概要文件時，已經在一個PROFILE文件中定義了用戶，那麼就必須使用CASCADE刪除。
-- ex:使用系統管理員，刪除PROFILE文件
DROP PROFILE c##testuser_profile;
-- SQL 錯誤: ORA-02382: 設定檔 C##TESTUSER_PROFILE 有指派的使用者, 
-- 必須使用 CASCADE 才能將其刪除
DROP PROFILE c##testuser_profile CASCADE;


-- ➤維護用戶
-- ex:使用系統管理員，修改c##testuser的密碼為1234
ALTER USER c##testuser IDENTIFIED BY 1234;


-- ex:使用系統管理員，控制用戶鎖定
ALTER USER c##testuser ACCOUNT LOCK;
SELECT * FROM dba_users 
WHERE username='C##TESTUSER';


-- ex:使用系統管理員，為用戶解鎖
ALTER USER c##testuser ACCOUNT UNLOCK;
SELECT * FROM dba_users 
WHERE username='C##TESTUSER';


-- ex:使用系統管理員，讓用戶密碼失效
ALTER USER c##testuser PASSWORD EXPIRE;
-- 下次登入時強制用戶修改密碼。


-- ex:使用系統管理員，修改用戶表空間配額
ALTER USER c##testuser 
QUOTA 20M ON system 
QUOTA 35M ON users;
SELECT * FROM dba_ts_quotas 
WHERE username='C##TESTUSER';


-- ➤刪除用戶
-- 語法:DROP USER 用戶名 [CASCADE];
-- note:如果存在數據表則加上CASCADE強制刪除。
-- ex:使用系統管理員，刪除用戶
DROP USER c##testuser;
SELECT * FROM dba_users 
WHERE username='C##TESTUSER';
--============================================================================--
--                                                                            --
/* ※用戶權限及角色管理--權限管理                                             */
--                                                                            --
--============================================================================--
-- 權限分類:
-- 說明:用戶創建完成之後實際上是沒有任何權限的，即:是無法使用的，如果要讓一個用
-- 戶真正可用，那麼就必須為此用戶授權，在Oracle之中，權限分為兩類:
-- ①系統權限:進行數據庫資源操作的權限，例如:創建數據表、索引等權限。
-- ②對象權限:維護數據庫中對象的能力，即:由一個用戶操作另外一個用戶的對象。
-- 所有的權限應該由DBA進行控制，在SQL語句規範之中針對於權限的控制提供了兩個核心
-- 的操作命令(DCL標準組成):GRANT(授權)、REVOKE(回收授權)。

-- ➤系統權限
-- 系統權限主要指的是資源操作的權限，例如:數據庫管理員(DBA)是數據庫系統中級別最
-- 高的用戶，它擁有一切的系統權限以及各種資源的操作能力。在Oracle中有100多種的系
-- 統權限，並且不同的數據庫版本相應的權限數也會增加。
-- ▲常用的權限:表、用戶、索引、序列、同義詞、視圖、子程序。


-- ➤為用戶授權
/*
語法:
GRANT 權限, ...
TO [用戶名,...|角色名,...|PUBLIC] 
[WITH ADMIN OPTION]

語法解釋:
①權限:主要指的是各個系統權限。
②TO:設置授予權限的用戶、角色或者是使用PUBLIC將此權限設置為公共權限。
③WITH ADMIN OPTION:將用戶授予的權限繼續授予其他用戶。
*/
-- ex:使用系統管理員，為c##testuser用戶授予創建SESSION權限
CREATE USER c##testuser IDENTIFIED BY java_android;
GRANT CREATE SESSION TO c##testuser;
-- 此時只是給予c##testuser登入的權限，還需要給他一些操作的權限。
DROP TABLE mytab;
DROP SEQUENCE myseq;
CREATE SEQUENCE myseq;
CREATE TABLE mytab(
mid NUMBER, 
name VARCHAR2(20));
-- 無法執行以上SQL語句。
-- ORA-01031: 權限不足
-- 如果希望c##testuser用戶可以操作資源，需要繼續為其授權。


-- ex:使用系統管理員，為c##testuser用戶授權操作資源
-- 使用"WITH ADMIN OPTION"之後，表示c##testuser用戶的權限可以繼續向下授予。
GRANT CREATE TABLE, CREATE SEQUENCE, CREATE VIEW 
TO c##testuser WITH ADMIN OPTION;
-- 使用c##testuser用戶執行語句
CREATE SEQUENCE myseq;
CREATE TABLE mytab(
mid NUMBER, 
name VARCHAR2(20));
-- note:現在所使用的版本是Oracle 12c，如果在它之前的版本，那麼用戶授權之後需要
-- 重新登入，只有登入的時候會取權限。


-- ex:使用c##testuser操作，將自身的權限授予c##testuser02用戶
GRANT CREATE TABLE, CREATE SEQUENCE TO c##testuser02;


-- ➤查看用戶權限
-- 權限的分配訊息可以利用"dba_sys_privs"數據字典查看。
-- ex:使用系統管理員，查看權限分配訊息
SELECT * FROM dba_sys_privs 
WHERE grantee IN('C##TESTUSER','C##TESTUSER02');


-- ➤撤銷權限
-- REVOKE 權限 ,... FROM (被撤銷)用戶名;
-- ex:使用系統管理員，撤銷c##testuser的部分權限
REVOKE CREATE TABLE, CREATE VIEW FROM c##testuser;
-- note:雖然撤銷了c##testuser用戶的權限，但是透過c##testuser為
-- c##testuser02用戶授予的權限沒有任何影響。


-- 對於c##testuser02用戶中的CREATE SEQUENCE權限，是透過c##testuser
-- 用戶授予的，所以也可以透過c##testuser用戶來回收此權限。
-- ex:使用c##testuser用戶回收c##testuser02權限
REVOKE CREATE SEQUENCE FROM c##testuser02;


-- ➤對象權限
-- 系統權限針對的是全局用戶，而對象權限指的是一個用戶下的所有相關對象的操作。
-- 在不同用戶之間如果要互相訪問，那麼就必須加上用戶名。雖然c##testuser用戶
-- 具備了CREATE SESSION權限，但在使用c##testuser訪問c##scott用戶的數據時
-- ，會無法成功，是因為缺少權限。

-- 對象權限指的是數據庫之中某一個對象所擁有的權限，即:可以透過某一個用戶的對象
-- 權限，讓其他用戶來操作本用戶中的所有授權對象。
/*
在Oracle之中一共定義了八種對象權限:
----------------------------------------------------------------------------
|No.|對象權限        |表(Table)|序列(Sequence)|視圖(View)|子程序(Procedure)|
----------------------------------------------------------------------------
|1  |查詢(SELECT)    |V        |V             |V         |                 |
----------------------------------------------------------------------------
|2  |增加(INSERT)    |V        |              |V         |                 |
----------------------------------------------------------------------------
|3  |更新(UPDATE)    |V        |              |V         |                 |
----------------------------------------------------------------------------
|4  |刪除(DELETE)    |V        |              |V         |                 |
----------------------------------------------------------------------------
|5  |執行(EXECUTE)   |         |              |          |V                |
----------------------------------------------------------------------------
|6  |修改(ALTER)     |V        |V             |V         |                 |
----------------------------------------------------------------------------
|7  |索引(INDEX)     |V        |              |V         |                 |
----------------------------------------------------------------------------
|8  |關聯(REFERENCES)|V        |              |          |                 |
----------------------------------------------------------------------------
*/


-- ➤授予對象權限
/*
語法:
GRANT 對象權限 |ALL[(列),...]
ON 對象 
TO [用戶名|角色名|PUBLIC] 
[WITH GRANT OPTION];

語法組成:
①對象權限:指的是表所列出的權限標記，如果設置為ALL表示所有對象權限。
②ON:要授予權限的對象名稱。
③TO:將此權限授予的用戶名稱或角色名稱，如果設置為PUBLIC表示為公共權限。
④WITH GRANT OPTION:允許授權用戶繼續授權其他用戶。
*/

-- ex:使用系統管理員，為c##testuser用戶授與c##scott用戶dept表的增加及
-- 查詢權限
GRANT SELECT, INSERT ON c##scott.dept TO c##testuser;


-- ex:使用系統管理員，將c##scott用戶數據表更新"部門名稱(dname)"的權限
-- 授予c##testuser用戶
GRANT UPDATE(dname) ON c##scott.dept TO c##testuser;
-- ex:使用c##testuser用戶對c##scott的部門名稱進行更新
UPDATE c##scott.dept SET dname='財務部' WHERE deptno=10;
-- ROLLBACK;


-- ex:使用c##testuser，查看當前用戶的權限("user_tab_privs_recd"數據字典)
COL owner FOR A10;
COL table_name FOR A10;
COL column_name FOR A10;
COL grantor FOR A10;
COL privilege FOR A10;
SELECT * FROM user_tab_privs_recd;
-- ex:使用c##testuser，查看當前用戶直行的權限("user_col_privs_recd"數據字典)
COL owner FOR A10;
COL table_name FOR A10;
COL column_name FOR A10;
COL grantor FOR A10;
COL privilege FOR A10;
SELECT * FROM user_col_privs_recd;


-- ➤回收對象權限
-- ex:使用c##scott用戶對c##testuser回收權限
REVOKE SELECT, INSERT ON c##scott.dept FROM c##testuser;
REVOKE UPDATE ON c##scott.dept FROM c##testuser;
--============================================================================--
--                                                                            --
/* ※用戶權限及角色管理--角色                                                 */
--                                                                            --
--============================================================================--
-- 說明:如果想要讓一個用戶正常進行操作，那麼肯定需要授予很多的操作權限。如果現在
-- 有100個用戶，而且這些用戶都需要具備相同的權限，那麼在進行權限維護的時候肯定不
-- 可能針對於100個用戶分別維護，而是需要將所有用戶的權限一起進行維護，而在這時就
-- 只能夠將多個權限加入到一個角色之中，透過對角色的維護來實現對多個用戶的權限維
-- 護(可以是系統權限，也可以是對象權限)，所以，所謂的角色就是指一組相關權限的集
-- 合。

-- ➤創建角色
-- 如果用戶要創建角色，則可以透過DBA或者是具有相應"CREATE ROLE"權限的用戶來完成
-- 語法:
-- CREATE ROLE 角色名稱 [NOT IDENTIFIED|IDENTIFIED BY 密碼];
-- ex:使用系統管理員，創建一個普通的角色
CREATE ROLE c##test_role_a;


-- ex:使用系統管理員，創建一個帶有密碼的角色
CREATE ROLE c##test_role_b IDENTIFIED BY hellojava;


-- ex:使用系統管理員，查看"dba_roles"數據字典
SELECT * FROM dba_roles
WHERE role IN('C##TEST_ROLE_A','C##TEST_ROLE_B');


-- ➤角色授權
-- ex:使用系統管理員，對c##test_role_a角色授權
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE 
TO c##test_role_a;


-- ex:使用系統管理員，對c##test_role_b角色授權
GRANT CREATE SESSION, CREATE ANY TABLE, INSERT ANY TABLE 
TO c##test_role_b;


-- ex:使用系統管理員，查看角色的權限
SELECT * FROM role_sys_privs 
WHERE role IN('C##TEST_ROLE_A','C##TEST_ROLE_B') ORDER BY role;


-- ➤為用戶授予角色
-- ex:使用系統管理員，將c##test_role_a角色授予c##testuser用戶
GRANT c##test_role_a TO c##testuser;


-- ex:使用系統管理員，將c##test_role_a角色與c##test_role_b角色
-- 授予c##testuser02用戶
GRANT c##test_role_a, c##test_role_b TO c##testuser02;


-- ex:使用c##testuser用戶登入，查看當前用戶的權限
CONN c##testuser/java_android;
SELECT * FROM session_privs;


-- ➤修改及回收角色
-- 既然角色本身屬於Oracle對象，所以可以直接實現修改。
-- 設置或取消角色密碼語法:
-- ALTER ROLE 角色名稱[NOT IDENTIFIED|IDENTIFIED BY 密碼];
-- ex:使用系統管理員，將c##test_role_a的角色密碼變為hellojava(原本尚未設置)
SELECT * FROM dba_roles
WHERE role IN('C##TEST_ROLE_A','C##TEST_ROLE_B');
ALTER ROLE c##test_role_a IDENTIFIED BY hellojava;


-- ex:使用系統管理員，將c##test_role_b的角色密碼取消
SELECT * FROM dba_roles
WHERE role IN('C##TEST_ROLE_A','C##TEST_ROLE_B');
ALTER ROLE c##test_role_b NOT IDENTIFIED;


-- ex:使用系統管理員，回收c##test_role_a角色中的權限
SELECT * FROM role_sys_privs 
WHERE role IN('C##TEST_ROLE_A','C##TEST_ROLE_B') ORDER BY role;
REVOKE CREATE SESSION FROM c##test_role_a;


-- ➤刪除角色
--  ex:使用系統管理員，刪除角色
DROP ROLE c##test_role_b;
SELECT * FROM dba_roles
WHERE role IN('C##TEST_ROLE_A','C##TEST_ROLE_B');


-- ➤預定義角色
-- 說明:即使有了角色，那麼如果是一個新的數據庫，而且又著急使用，分別創建角色在
-- 授權實際上是一件非常麻煩的事情，所以為了方便使用，可以用一些預定義的角色。
/*
在Oracle之中為了減輕管理員的負擔，提供了一些預定義角色。
-----------------------------------------------
|No.|預定義角色          |描述                |
-----------------------------------------------
|1  |EXP_FULL_DATABASE   |導出數據庫權限      |
-----------------------------------------------
|2  |IMP_FULL_DATABASE   |導入數據庫權限      |
-----------------------------------------------
|3  |SELECT_CATALOG_ROLE |查詢數據字典權限    |
-----------------------------------------------
|4  |EXECUTE_CATALOG_ROLE|數據字典上的執行權限|
-----------------------------------------------
|5  |DELETE_CATALOG_ROLE |數據字典上的刪除權限|
-----------------------------------------------
|6  |DBA                 |系統管理的相關權限  |
-----------------------------------------------
|7  |CONNECT             |授予用戶最典型的權限|
-----------------------------------------------
|8  |RESOURCE            |授予開發人員的權限  |
-----------------------------------------------
*/

-- ex:使用系統管理員，查看CONNECT、RESOURCE角色所具備的權限
SELECT * FROM role_sys_privs 
WHERE role IN('CONNECT','RESOURCE') ORDER BY role;


-- ex:使用系統管理員，將CONNECT、RESOURCE角色授予c##testuser用戶
SELECT * FROM dba_role_privs
WHERE grantee LIKE 'C##%' ORDER BY grantee;
GRANT CONNECT, RESOURCE TO c##testuser;


/*
-- ex:使用系統管理員，查看角色
SELECT * FROM dba_roles
WHERE role LIKE 'C##%';

-- ex:使用系統管理員，查看角色的權限
SELECT * FROM role_sys_privs 
WHERE role LIKE 'C##%' ORDER BY role;

-- ex:使用系統管理員，查看用戶或是角色的權限
SELECT * FROM dba_sys_privs 
WHERE grantee LIKE 'C##%' ORDER BY grantee;

-- ex:使用系統管理員，查看用戶的套用角色
SELECT * FROM dba_role_privs
WHERE grantee LIKE 'C##%' ORDER BY grantee;
*/