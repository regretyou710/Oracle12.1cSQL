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
CREATE USER 用戶名 IDENTIFIED BY 密碼:創建用戶同時設置密碼，但是用戶名和密碼不能
                                      是Oracle保留字也不能以數字開頭(如果要設置
									  為數字，需要將數字使用雙引號聲明)。
DEFAULT TABLESPACE 表空間名稱:用戶存儲默認使用的表空間，當用戶創建對象沒有設置表
                              空間時，就將保存在此處指定的表空間下，這樣就可以和
							  系統表空間進行區分。
TEMPORARY TABLESPACE 表空間名稱:用戶所使用的臨時表空間。
QUOTA 數字[K|M]|UNLIMITED ON 表空間名稱:用戶在表空間上的使用限額，可以指定多個表
                                        空間的限額，如果設置為"UNLIMITED"表示不
										設置限額。
PROFILE 概要文件名稱|DEFAULT:用戶操作的資源文件，如果不指定則使用默認配置資源文
                             件。
PASSWORD EXPIRE:用戶密碼失效，則在第一次使用時必須修改密碼。
ACCOUNT LOCK|UNLOCK:用戶是否為鎖定狀態，默認為"UNLOCK"。
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
-- 訪問或用戶管理等操作。
-- 語法:CREATE PROFILE 概要文件名稱 LIMIT 命令(s);
/*
第一組:資源限制命令
SESSION_PER_USER 數字 |UNLIMITED|DEFAULT:允許一個用戶同時創建SESSION的最大數量。
CPU_PER_SESSION 數字 |UNLIMITED|DEFAULT:每一個SESSION允許使用CPU的時間數，單位為
                                        毫秒。
CPU_PER_CALL 數字 |UNLIMITED|DEFAULT:限制每次調用SQL語句期間，CPU的時間總量。
CONNECT_TIME 數字 |UNLIMITED|DEFAULT:每個SESSION的連接時間數，單位為分。
IDLE_TIME 數字 |UNLIMITED|DEFAULT:每個SESSION的超時時間，單位為分。
LOGICAL_READS_PER_SESSION 數字 |UNLIMITED|DEFAULT:為了防止笛卡爾積的產生，可以限
                                                  定每一個用戶最多允許讀取的數據
												  塊數。
LOGICAL_READS_PER_CALL 數字 |UNLIMITED|DEFAULT:每次調用SQL語句期間，最多允許用戶
                                               讀取的數據塊數。

第二組:口令限制命令
FAILED_LOGIN_ATTEMPTS 數字 |UNLIMITED|DEFAULT:當連續登入失敗次數達到該參數指定值
                                              時，用戶被加鎖。
PASSWORD_LIFE_TIME 數字 |UNLIMITED|DEFAULT:口令的有效(天)，默認為UNLIMITED。
PASSWORD_REUSE_TIME 數字 |UNLIMITED|DEFAULT:口令被修改後原有口令隔多少天後可以被
                                            重新使用，默認為UNLIMITED。
PASSWORD_REUSE_MAX 數字 |UNLIMITED|DEFAULT:口令被修改後原有口令被修改多少次才允
                                           許被重新使用。
PASSWORD_VERIFY_FUNCTION 數字 |UNLIMITED|DEFAULT:口令校驗函數。
PASSWORD_LOCK_TIME 數字 |UNLIMITED|DEFAULT:帳戶因FAILED_LOGIN_ATTEMPTS鎖定時，加
                                           鎖天數。
PASSWORD_GRACE_TIME 數字 |UNLIMITED|DEFAULT:口令過期後，繼續使用員口令官限期(天)
                                            。
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
-- 對於DCL標準組成實際上只有兩個語句:GRANT、REVOKE。
-- ➤
















