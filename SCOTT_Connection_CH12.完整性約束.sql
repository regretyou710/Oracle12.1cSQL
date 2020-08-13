--============================================================================--
--                                                                            --
/* ※完整性約束-數據庫完整性約束簡介                                          */
--                                                                            --
--============================================================================--
-- ➤完整性約束
-- 說明:完整性約束是保證用戶對數據庫所作的修改不會破壞數據的一致性，是保護數據正
-- 確性和相容性的一種手段。例如:
-- 如果用戶輸入年齡，則年齡肯定不能事999
-- 如果用戶輸入性別，則性別的設置只能是"男"或"女"，而不能設置成"未知"

-- ➤主要約束分類
-- 在開發之中可以使用以下的五種約束進行定義:
-- ①非空約束:如果使用了非空約束，則以後此欄位的內容不允設置成null。
-- ②唯一約束:此直行的內容不允許出現重複。
-- ③主鍵約束:表示一個唯一的標示，如:人員ID不能重複，且不能為空。
-- ④檢查約束:用戶自行編寫設置內容的檢查條件。
-- ⑤主-外鍵約束(參照完整性約束):是在兩張表上進行的關聯約束，加入關聯約束後就產生
--                               父子的關係。
--============================================================================--
--                                                                            --
/* ※完整性約束-非空約束:NK                                                   */
--                                                                            --
--============================================================================--
-- ▲非空約束不允許欄位為null。
-- ▲非空約束出現錯誤時會提示完整的錯誤位置。

-- ex:定義memeber表，其中姓名不允許為空
DROP TABLE member PURGE;
CREATE TABLE member(
mid NUMBER,
name VARCHAR2(200) NOT NULL
);
DESC member;


-- ex:向memeber表增加一筆正確資料
INSERT INTO member (mid, name) VALUES (1,'張三豐');
SELECT * FROM member;
-- ex:向memeber表增加一筆錯誤資料
-- SQL 錯誤: ORA-01400: 無法將 NULL 插入 ("C##SCOTT"."MEMBER"."NAME")
INSERT INTO member (mid, name) VALUES (2,null);
INSERT INTO member (mid) VALUES (3);
--============================================================================--
--                                                                            --
/* ※完整性約束-唯一約束:UK                                                   */
--                                                                            --
--============================================================================--
-- ▲唯一約束可以設置null。
-- ▲唯一約束的直行不允許重複。

-- ex:定義memeber表，其中email為唯一約束
DROP TABLE member PURGE;
CREATE TABLE member(
mid NUMBER,
name VARCHAR2(20) NOT NULL, 
email VARCHAR2(50) UNIQUE
);
DESC member;


-- ex:向memeber表增加一筆正確資料
INSERT INTO member (mid, name, email) VALUES (1,'張三豐','a001@qq.com');
SELECT * FROM member;
-- ex:向memeber表增加一筆錯誤資料;email資料重複
-- SQL 錯誤: ORA-00001: 違反必須為唯一的限制條件 (C##SCOTT.SYS_C0010053)
INSERT INTO member (mid, name, email) VALUES (2,'張無忌','a001@qq.com');


-- 此時可以發現錯誤訊息與之前的非空約束的錯誤訊息相比，完全看不懂。因為約束在數
-- 據庫之中也是一個對象，所以為了方便維護，每一個約束都有自己的名字，如果用戶沒
-- 有指定名字，那麼就將由系統動態分配一個。所以這時就可以使用CONSTRAINT關鍵字來
-- 位約束定義名字。而約束的名字，建議寫法:"約束簡寫_欄位"(約束簡寫_表_欄位)，那
-- 麼現在唯一的簡寫應該為UK，而且在email欄位上使用的唯一約束，約束名稱最好為:
-- uk_email。
-- ex:定義memeber表，其中email為唯一約束同時定義UK名字
DROP TABLE member PURGE;
CREATE TABLE member(
mid NUMBER,
name VARCHAR2(20) NOT NULL, 
email VARCHAR2(50),
CONSTRAINT uk_email UNIQUE(email)
);
DESC member;
INSERT INTO member (mid, name, email) VALUES (1,'張三豐','a001@qq.com');
INSERT INTO member (mid, name, email) VALUES (2,'張無忌','a001@qq.com');
-- SQL 錯誤: ORA-00001: 違反必須為唯一的限制條件 (C##SCOTT.UK_EMAIL)


-- note:空值不受唯一約束影響
DROP TABLE member PURGE;
CREATE TABLE member(
mid NUMBER,
name VARCHAR2(20) NOT NULL, 
email VARCHAR2(50),
CONSTRAINT uk_email UNIQUE(email)
);
DESC member;
INSERT INTO member (mid, name, email) VALUES (1,'張三豐','a001@qq.com');
INSERT INTO member (mid, name, email) VALUES (2,'張無忌',null);
INSERT INTO member (mid, name, email) VALUES (3,'張翠珊',null);
SELECT * FROM member;
--============================================================================--
--                                                                            --
/* ※完整性約束-主鍵約束:PK                                                   */
--                                                                            --
--============================================================================--
-- ➤主鍵約束:PK
-- 說明:如果一個欄位既要求唯一，又不能設置為空null，則可以使用主鍵約束(主鍵約束
-- = 非空約束 + 唯一約束)，主鍵約束使用PRIMARY KEY(簡稱PK)進行指定。
-- ▲在開發過程中，只要是實體表數據，都要有一個主鍵，而一些關係表有可能是不需要
-- 主鍵的。
-- ▲複合主鍵約束一般不建議使用。

-- ex:定義memeber表，其中mid設置為PK
DROP TABLE member PURGE;
CREATE TABLE member(
mid NUMBER PRIMARY KEY,
name VARCHAR2(20) NOT NULL, 
email VARCHAR2(50),
CONSTRAINT uk_email UNIQUE(email)
);
DESC member;


-- ex:向memeber表增加一筆正確資料;mid設置為null
INSERT INTO member (mid, name, email) VALUES (null,'張三豐','a001@qq.com');
-- SQL 錯誤: ORA-01400: 無法將 NULL 插入 ("C##SCOTT"."MEMBER"."MID")


-- ex:向memeber表增加一筆正確資料;mid設置重複
INSERT INTO member (mid, name, email) VALUES (1,'張三豐','a001@qq.com');
INSERT INTO member (mid, name, email) VALUES (1,'張無忌','a001@gmail.com');
-- SQL 錯誤: ORA-00001: 違反必須為唯一的限制條件 (C##SCOTT.SYS_C0010059)


-- ex:定義memeber表，並為主鍵約束定義名字
DROP TABLE member PURGE;
CREATE TABLE member(
mid NUMBER,
name VARCHAR2(20) NOT NULL, 
email VARCHAR2(50),
CONSTRAINT pk_mid PRIMARY KEY(mid), 
CONSTRAINT uk_email UNIQUE(email)
);
DESC member;
INSERT INTO member (mid, name, email) VALUES (1,'張三豐','a001@qq.com');
INSERT INTO member (mid, name, email) VALUES (1,'張無忌','a001@gmail.com');
-- SQL 錯誤: ORA-00001: 違反必須為唯一的限制條件 (C##SCOTT.PK_MID)


-- ➤複合主鍵
-- 說明:把多個欄位都設置為主鍵
-- ex:定義memeber表，其中mid及name設置為PK
-- 當設置複合主鍵後就意味著只有在兩個欄位內容都相同的時候才表示重複，違反約束。
DROP TABLE member PURGE;
CREATE TABLE member(
mid NUMBER,
name VARCHAR2(20) NOT NULL, 
email VARCHAR2(50),
CONSTRAINT pk_mid_name PRIMARY KEY(mid,name), 
CONSTRAINT uk_email UNIQUE(email)
);
DESC member;


-- ex:向memeber表增加正確資料
INSERT INTO member (mid, name, email) VALUES (1,'張三豐','a001@qq.com');
INSERT INTO member (mid, name, email) VALUES (1,'張無忌','a001@gmail.com');
INSERT INTO member (mid, name, email) VALUES (2,'張無忌','a002@gmail.com');
SELECT * FROM member;


-- ex:向memeber表增加一筆錯誤資料;mid,name資料重複
INSERT INTO member (mid, name, email) VALUES (2,'張無忌','a0011@gmail.com');
-- SQL 錯誤: ORA-00001: 違反必須為唯一的限制條件 (C##SCOTT.PK_MID_NAME)
--============================================================================--
--                                                                            --
/* ※完整性約束-檢查約束:CK                                                   */
--                                                                            --
--============================================================================--
-- ➤檢查約束:CK
-- 說明:對數據增加的條件過濾，表中的每行數據都必須滿足指定的過濾條件。在進行數據
-- 更新操作時，如果滿足檢查約束所設置的條件，數據可以成功更新，如果不滿足，則不
-- 能更新，在SQL語句中使用CHECK(簡稱CK)設置約束的條件。
-- ▲對於任何一種操作，如果增加的檢查約束越多，那麼實際上一定會影響更新的效能，所
-- 以一張數據表如果被頻繁修改的話，那麼不建議使用檢查約束。所以這樣的驗證操作一般
-- 都會由程序完成，如:Struts中的各種驗證。

-- ex:在member表中增加age欄位(年齡範圍是0~200歲)和sex欄位(只能是男或女)
DROP TABLE member PURGE;
CREATE TABLE member(
mid NUMBER,
name VARCHAR2(20) NOT NULL, 
email VARCHAR2(50),
age NUMBER CHECK(age BETWEEN 0 AND 200),
sex VARCHAR2(10), 
CONSTRAINT pk_mid_name PRIMARY KEY(mid,name), 
CONSTRAINT uk_email UNIQUE(email), 
CONSTRAINT ck_sex CHECK(sex IN('男','女'))
);
DESC member;


-- ex:向memeber表增加正確資料
INSERT INTO member (mid, name, email, age, sex) 
VALUES (1,'張三豐','a001@qq.com',44,'男');
SELECT * FROM member;


-- ex:向memeber表增加錯誤資料;年齡錯誤
INSERT INTO member (mid, name, email, age, sex) 
VALUES (2,'張無忌','a001@qq.com',999,'男');
-- SQL 錯誤: ORA-02290: 違反檢查條件 (C##SCOTT.SYS_C0010068)
-- 在age上並未設置約束名字，所以依然由系統自動分配約束名稱。


-- ex:向memeber表增加錯誤資料;性別錯誤
INSERT INTO member (mid, name, email, age, sex) 
VALUES (2,'張無忌','a001@qq.com',18,'無');
-- SQL 錯誤: ORA-02290: 違反檢查條件 (C##SCOTT.CK_SEX)
--============================================================================--
--                                                                            --
/* ※完整性約束-主-外鍵約束:FK                                                */
--                                                                            --
--============================================================================--
-- ➤約束:FK

-- ex:創建member與advice表
DROP TABLE member PURGE;
DROP TABLE advice PURGE;
CREATE TABLE member(
mid NUMBER,
name VARCHAR2(20) NOT NULL, 
CONSTRAINT pk_mid PRIMARY KEY(mid) 
);
CREATE TABLE advice(
adid NUMBER,
content CLOB NOT NULL, 
mid NUMBER, 
CONSTRAINT pk_adid PRIMARY KEY(adid)
);
DESC member;
DESC advice;


-- 增加正確數據
INSERT INTO member (mid, name) VALUES (1,'張三豐');
INSERT INTO member (mid, name) VALUES (2,'張無忌');
INSERT INTO advice (adid, content, mid) 
VALUES (1,'應該提倡內部溝通機制，設置經理辦公室',1);
INSERT INTO advice (adid, content, mid) 
VALUES (2,'應該為更多數不會程式學生提供更多的免費課程',1);
INSERT INTO advice (adid, content, mid) 
VALUES (3,'應該加強員工的身體鍛鍊',2);
INSERT INTO advice (adid, content, mid) VALUES
(4,'提供更多元化服務',2);
INSERT INTO advice (adid, content, mid) VALUES
(5,'建立本公司ERP系統，適應電子化訊息發展要求',2);
COMMIT;
SELECT * FROM member;
SELECT * FROM advice;
-- 以上的語句執行，mid=1的成員提出了兩個意見，mid=2的成員提出了三個意見，這些
-- 數據都是有效數據。


-- ex:查詢出每位成員的完整訊息以及所提出的意見數量
-- 分析:
-- 確定所需要的數據表:
-- member表:成員編號、姓名
-- advice表:成員提出的建議數量，統計訊息
-- 已確定關聯欄位:member.mid=advice.mid
-- 方式一:SELECT子查詢
SELECT m.mid, m.name, 
(SELECT COUNT(adid) 
FROM advice a
WHERE m.mid=a.mid 
GROUP BY mid) count
FROM member m;
-- 方式二:FROM子查詢
SELECT m.mid, m.name, t.count 
FROM member m, 
(SELECT mid mid, COUNT(adid) count FROM advice GROUP BY mid) t
WHERE m.mid=t.mid;
-- 方式三:多欄位分組統計
SELECT m.mid, m.name, COUNT(a.mid)
FROM member m, advice a 
WHERE m.mid=a.mid
GROUP BY m.mid,m.name;



-- ex:增加一個建議
INSERT INTO advice (adid, content, mid) VALUES
(6,'應該實現崗位收入透明化',99);
SELECT * FROM advice;
-- 如果增加的一種錯誤訊息;發現在member表中並不存在mid=99的員工訊息，如果按照之
-- 前所學習的技術，這種錯誤數據無法迴避。
-- 現在對於表可以分為父表(member)和子表(advice)，因為子表之中的數據必須參考
-- member表中的數據。建議提出者的成員編號應該是在member表中的mid欄位上所存在的
-- 數據。所以在這樣的情況下，為了保證表中的數據有效性，就只能夠利用外鍵約束來完
-- 成。外鍵使用FOREIGN KEY來進行設置。


-- 對子表(advice)進行外鍵約束設置
DROP TABLE member PURGE;
DROP TABLE advice PURGE;
CREATE TABLE member(
mid NUMBER,
name VARCHAR2(20) NOT NULL, 
CONSTRAINT pk_mid PRIMARY KEY(mid) 
);
CREATE TABLE advice(
adid NUMBER,
content CLOB NOT NULL, 
mid NUMBER, 
CONSTRAINT pk_adid PRIMARY KEY(adid), 
CONSTRAINT fk_mid FOREIGN KEY(mid) REFERENCES member(mid)
);
DESC member;
DESC advice;
-- 增加正確數據
INSERT INTO member (mid, name) VALUES (1,'張三豐');
INSERT INTO member (mid, name) VALUES (2,'張無忌');
INSERT INTO advice (adid, content, mid) 
VALUES (1,'應該提倡內部溝通機制，設置經理辦公室',1);
INSERT INTO advice (adid, content, mid) 
VALUES (2,'應該為更多數不會程式學生提供更多的免費課程',1);
INSERT INTO advice (adid, content, mid) 
VALUES (3,'應該加強員工的身體鍛鍊',2);
INSERT INTO advice (adid, content, mid) VALUES
(4,'提供更多元化服務',2);
INSERT INTO advice (adid, content, mid) VALUES
(5,'建立本公司ERP系統，適應電子化訊息發展要求',2);
COMMIT;
SELECT * FROM member;
SELECT * FROM advice;
-- 再次增加錯誤數據，那麼就會出現錯誤提示
INSERT INTO advice (adid, content, mid) VALUES
(6,'應該實現崗位收入透明化',99);
-- SQL 錯誤: ORA-02291: 違反完整性限制條件 
-- (C##SCOTT.FK_MID) - 找不到父項索引鍵


-- ▲一旦為表中增加外鍵約束，就有新的問題產生:
-- 問題一:如果想要刪除父表數據，那麼首先必須先刪除掉對應的所有子表數據。
-- ex:刪除主表中的紀錄
DELETE FROM member WHERE mid=1;
-- SQL 錯誤: ORA-02292: 違反完整性限制條件 (C##SCOTT.FK_MID) - 發現子項記錄

-- 如果非要刪除紀錄，那麼需先刪除子表紀錄，再刪除父表紀錄
DELETE FROM advice WHERE mid=1;
DELETE FROM member WHERE mid=1;

-- 但這樣的做法也不合適(如果子表外鍵約束數據量大)。為了解決外鍵中的數據操作問題
-- ，提出了數據的級聯操作。
-- ➤級聯操作一:級聯刪除，ON DELETE CASCADE，當主表數據被刪除之後，對應的子表數據
--             也應該同時被清理。

-- note:配置級聯刪除之前應該先刪子表再刪主表
DROP TABLE advice PURGE;
DROP TABLE member PURGE;
CREATE TABLE member(
mid NUMBER,
name VARCHAR2(20) NOT NULL, 
CONSTRAINT pk_mid PRIMARY KEY(mid) 
);
CREATE TABLE advice(
adid NUMBER,
content CLOB NOT NULL, 
mid NUMBER, 
CONSTRAINT pk_adid PRIMARY KEY(adid), 
CONSTRAINT fk_mid FOREIGN KEY(mid) REFERENCES member(mid) 
ON DELETE CASCADE
);
DESC member;
DESC advice;
-- 增加正確數據
INSERT INTO member (mid, name) VALUES (1,'張三豐');
INSERT INTO member (mid, name) VALUES (2,'張無忌');
INSERT INTO advice (adid, content, mid) 
VALUES (1,'應該提倡內部溝通機制，設置經理辦公室',1);
INSERT INTO advice (adid, content, mid) 
VALUES (2,'應該為更多數不會程式學生提供更多的免費課程',1);
INSERT INTO advice (adid, content, mid) 
VALUES (3,'應該加強員工的身體鍛鍊',2);
INSERT INTO advice (adid, content, mid) VALUES
(4,'提供更多元化服務',2);
INSERT INTO advice (adid, content, mid) VALUES
(5,'建立本公司ERP系統，適應電子化訊息發展要求',2);
COMMIT;
SELECT * FROM member;
SELECT * FROM advice;


-- ex:刪除父表(member)中的紀錄，而對應的子表紀錄也同時被刪除
DELETE FROM member WHERE mid=1;
SELECT * FROM member;
SELECT * FROM advice;


-- ➤級聯操作二:級聯更新，ON DELETE SET NULL。當主表數據被刪除之後，對應的子表數
--             據的相應的欄位內容會設置為null。

DROP TABLE advice PURGE;
DROP TABLE member PURGE;
CREATE TABLE member(
mid NUMBER,
name VARCHAR2(20) NOT NULL, 
CONSTRAINT pk_mid PRIMARY KEY(mid) 
);
CREATE TABLE advice(
adid NUMBER,
content CLOB NOT NULL, 
mid NUMBER, 
CONSTRAINT pk_adid PRIMARY KEY(adid), 
CONSTRAINT fk_mid FOREIGN KEY(mid) REFERENCES member(mid) 
ON DELETE SET NULL
);
DESC member;
DESC advice;
-- 增加正確數據
INSERT INTO member (mid, name) VALUES (1,'張三豐');
INSERT INTO member (mid, name) VALUES (2,'張無忌');
INSERT INTO advice (adid, content, mid) 
VALUES (1,'應該提倡內部溝通機制，設置經理辦公室',1);
INSERT INTO advice (adid, content, mid) 
VALUES (2,'應該為更多數不會程式學生提供更多的免費課程',1);
INSERT INTO advice (adid, content, mid) 
VALUES (3,'應該加強員工的身體鍛鍊',2);
INSERT INTO advice (adid, content, mid) VALUES
(4,'提供更多元化服務',2);
INSERT INTO advice (adid, content, mid) VALUES
(5,'建立本公司ERP系統，適應電子化訊息發展要求',2);
COMMIT;
SELECT * FROM member;
SELECT * FROM advice;


-- ex:刪除父表(member)中的紀錄，而對應的子表紀錄也同時被設置為null
DELETE FROM member WHERE mid=1;
SELECT * FROM member;
SELECT * FROM advice;


-- 問題二:刪除父表時須先刪除子表
-- ex:直接刪除member表
DROP TABLE member PURGE;
-- SQL 錯誤: ORA-02449: 外來索引鍵參照表格中的唯一索引鍵/主索引鍵
-- 解決方式:
DROP TABLE advice PURGE;
DROP TABLE member PURGE;


-- note:在進行外鍵設置的時候，對應的欄位在父表中必須是主鍵或是唯一約束。如果將
-- A表作為B表的父表，將B表作為A表的父表，等於這兩張表互為外鍵。這種混亂的情況可
-- 以選擇強制性刪除。
-- ex:強制刪除父表
DROP TABLE member CASCADE CONSTRAINT;
SELECT * FROM advice;
SELECT * FROM tab;
-- 這種強制刪除並不建議使用，主要的原因在編寫數據庫創建腳本的時候一定要考慮好這
-- 先後的關係。
--============================================================================--
--                                                                            --
/* ※完整性約束-查看約束                                                      */
--                                                                            --
--============================================================================--
-- 說明:約束是由數據庫自己創建的對象，所有對象都會在數據字典之中進行保存。可以利
-- 用"user_constraints"數據字典或是"user_cons_columns"數據字典查看。
-- 一般而言，如果按照標準的開發模式，按照"約束簡寫_欄位"實際上就夠解決這些約束名
-- 稱的問題。從開發角度，約束名稱一定要有。

-- 創建member並且主鍵約束未設定名字
DROP TABLE member PURGE;
CREATE TABLE member(
mid NUMBER PRIMARY KEY,
name VARCHAR2(20) NOT NULL
);
DESC member;
-- 新增兩筆相同主鍵約束的資料
INSERT INTO member (mid, name) VALUES (1,'張三豐');
INSERT INTO member (mid, name) VALUES (1,'張無忌');
SELECT * FROM member;
-- 此時錯誤訊息:
-- SQL 錯誤: ORA-00001: 違反必須為唯一的限制條件 (C##SCOTT.SYS_C0010102)
-- 此名稱是數據庫對象(約束)的名稱。

-- 使用user_constraints數據字典查看約束名字的相關訊息
SELECT * FROM user_constraints;
-- 使用user_cons_columns數據字典查看約束名字對應的欄位名稱
SELECT * FROM user_cons_columns;
--============================================================================--
--                                                                            --
/* ※完整性約束-修改約束                                                      */
--                                                                            --
--============================================================================--
-- 如果一張表創建的時候沒有設置任何約束，那麼就可以透過指定的語法實現約束的增加。
-- note:表跟約束一起建立，那麼建立之後就不要修改了。

-- ex:建立一張沒有約束的表
DROP TABLE member PURGE;
CREATE TABLE member(
mid NUMBER,
name VARCHAR2(20) ,
age NUMBER
);
-- 查看表有無約束
SELECT * FROM user_constraints WHERE table_name = 'MEMBER';


-- ➤增加約束
-- 語法:ALTER TABLE 表名稱 ADD CONSTRAINT 約束名稱 約束類型(約束欄位);
-- ex:為member表的mid欄位增加主鍵約束
ALTER TABLE member ADD CONSTRAINT pk_mid PRIMARY KEY(mid);
SELECT * FROM user_constraints WHERE table_name='MEMBER';


-- ex:為member表的age欄位增加檢查約束
ALTER TABLE member ADD CONSTRAINT ck_age CHECK(age BETWEEN 0 AND 200);
SELECT * FROM user_constraints WHERE table_name='MEMBER';


-- note:在進行約束後期添加的時候，非空約束不能夠使用此類語法。
ALTER TABLE member ADD CONSTRAINT nk_name NOT NULL;
-- 應改為:
ALTER TABLE member MODIFY(name VARCHAR2(20) NOT NULL);
INSERT INTO member (mid,name,age) VALUES (1,null,22);
SELECT * FROM user_constraints WHERE table_name='MEMBER';


-- note:後期的約束添加，必須有一個條件，表中存放的數據本身是不存在違反約束
-- 的數據。對於非空的約束，在設計的時候就要增加上。

-- 情況一:
-- ex:建立一張沒有約束的表
DROP TABLE member PURGE;
CREATE TABLE member(
mid NUMBER,
name VARCHAR2(20) ,
age NUMBER
);
-- ex:為member表的mid欄位增加主鍵約束
ALTER TABLE member ADD CONSTRAINT pk_mid PRIMARY KEY(mid);
-- ex:增加一筆設置檢查約束之前的數據
INSERT INTO member (mid,name,age) VALUES (1,null,999);
SELECT * FROM member;
-- ex:為member表的age欄位增加檢查約束
-- 出現:SQL 錯誤: ORA-02293: 無法驗證 (C##SCOTT.CK_AGE) - 違反檢查條件
ALTER TABLE member ADD CONSTRAINT ck_age CHECK(age BETWEEN 0 AND 200);
SELECT * FROM user_constraints WHERE table_name='MEMBER';


-- 情況二:
-- ex:建立一張沒有約束的表
DROP TABLE member PURGE;
CREATE TABLE member(
mid NUMBER,
name VARCHAR2(20) ,
age NUMBER
);
-- ex:為member表的mid欄位增加主鍵約束
ALTER TABLE member ADD CONSTRAINT pk_mid PRIMARY KEY(mid);
-- ex:為member表的age欄位增加檢查約束
ALTER TABLE member ADD CONSTRAINT ck_age CHECK(age BETWEEN 0 AND 200);
SELECT * FROM user_constraints WHERE table_name='MEMBER';
-- ex:增加一筆設置非空約束之前的數據
INSERT INTO member (mid,name,age) VALUES (1,null,22);
SELECT * FROM member;
-- ex:非空約束後期添加
-- 出現:SQL 錯誤: ORA-02296: 無法啟用 (C##SCOTT.) － 發現空值
ALTER TABLE member MODIFY(name VARCHAR2(20) NOT NULL);


-- ➤啟用/禁用約束
/*
禁用約束語法:
ALTER TABLE 表名稱 DISABLE CONSTRAINT 約束名稱 [CASCADE];
啟用約束語法:
ALTER TABLE 表名稱 ENABLE CONSTRAINT 約束名稱;
*/

-- 建立數據表
DROP TABLE advice PURGE;
DROP TABLE member PURGE;
CREATE TABLE member(
mid NUMBER,
name VARCHAR2(20) NOT NULL, 
CONSTRAINT pk_mid PRIMARY KEY(mid) 
);
CREATE TABLE advice(
adid NUMBER,
content CLOB NOT NULL, 
mid NUMBER, 
CONSTRAINT pk_adid PRIMARY KEY(adid), 
CONSTRAINT fk_mid FOREIGN KEY(mid) REFERENCES member(mid) 
ON DELETE SET NULL
);
DESC member;
DESC advice;
-- 增加正確數據
INSERT INTO member (mid, name) VALUES (1,'張三豐');
INSERT INTO member (mid, name) VALUES (2,'張無忌');
INSERT INTO advice (adid, content, mid) 
VALUES (1,'應該提倡內部溝通機制，設置經理辦公室',1);
INSERT INTO advice (adid, content, mid) 
VALUES (2,'應該為更多數不會程式學生提供更多的免費課程',1);
INSERT INTO advice (adid, content, mid) 
VALUES (3,'應該加強員工的身體鍛鍊',2);
INSERT INTO advice (adid, content, mid) VALUES
(4,'提供更多元化服務',2);
INSERT INTO advice (adid, content, mid) VALUES
(5,'建立本公司ERP系統，適應電子化訊息發展要求',2);
COMMIT;
SELECT * FROM member;
SELECT * FROM advice;


-- ex:禁用advice表(子表)中的主鍵
ALTER TABLE advice DISABLE CONSTRAINT pk_adid;


-- ex:advice表中增加主鍵重複紀錄
INSERT INTO advice (adid, content, mid) VALUES
(1,'主鍵重複紀錄',1);
INSERT INTO advice (adid, content, mid) VALUES
(1,'主鍵重複紀錄',1);
SELECT * FROM advice;


-- ex:禁用member表(父表)中的主鍵
ALTER TABLE member DISABLE CONSTRAINT pk_mid;
-- 執行語句後出現錯誤，因為父表主鍵存在子表的外鍵約束，無法直接禁用
-- SQL 錯誤: ORA-02297: 無法停用限制條件 (C##SCOTT.PK_MID) － 含有從屬項目
-- 應改將語句改為:
ALTER TABLE member DISABLE CONSTRAINT pk_mid CASCADE;


-- ex:測試禁用member表(父表)的主鍵是否成功，增加主鍵重複紀錄
INSERT INTO member (mid,name) VALUES (1,'倚天劍');
INSERT INTO member (mid,name) VALUES (1,'屠龍刀');
SELECT * FROM member;


-- ex:重新啟用兩張表的主鍵
ALTER TABLE advice ENABLE CONSTRAINT pk_adid;
ALTER TABLE member ENABLE CONSTRAINT pk_mid;
-- 如果想保證約束可以正常的啟用，那麼須先解決掉重複數據的問題
DELETE FROM member WHERE mid=1;
DELETE FROM advice WHERE adid=1;
ALTER TABLE member ENABLE CONSTRAINT pk_mid;
ALTER TABLE advice ENABLE CONSTRAINT pk_adid;


-- ➤刪除約束
-- 語法:ALTER TABLE 表名稱 DROP CONSTRAINT 約束名稱 [CASCADE];

-- ex:刪除約束
ALTER TABLE member DROP CONSTRAINT pk_mid CASCADE;
ALTER TABLE advice DROP CONSTRAINT pk_adid ;
SELECT * FROM user_constraints WHERE table_name IN('MEMBER','ADVICE');
--============================================================================--
--                                                                            --
/* ※完整性約束-數據庫綜合實戰                                                */
--                                                                            --
--============================================================================--
-- 到了秋天，為了讓同學們增加體育鍛鍊，所以學校開始籌備學生運動會的活動，為了方
-- 便保存比賽成績訊息，所以定義了如下的幾張表數據
/*
運動員sporter(運動員編號sporterid、運動員姓名name、運動員性別sex、
所屬系號department)

項目item(項目編號itemid、項目名稱itemname、項目比賽地點location)

成績grade(運動員編號sporterid、項目編號itemid、積分mark)
*/

-- ▲使用用戶c##scott進行操作
-- 建立數據表;使用sqlplus執行
@C:\Users\user\Desktop\Oracle12.1cSQL\CH12.完整性約束-數據庫綜合實戰.sql
SELECT * FROM tab;
SELECT * FROM sporter;
SELECT * FROM item;
SELECT * FROM grade; 
SELECT * FROM user_constraints 
WHERE table_name IN('SPORTER','ITEM','GRADE')
ORDER BY table_name;


-- ex1:求出目前總積分最高的系名及其積分
-- 確定所需數據表
-- sporter表:系名
-- grade表:總積分最高
-- 確定已知關聯欄位
-- sporter.sporterid=grade.sproterid
-- 步驟一:求出所有系的分數
SELECT s.department, g.mark 
FROM sporter s, grade g
WHERE s.sporterid=g.sporterid;
-- 步驟二:發現系名稱上存在重複，那麼只要是有重複就可以使用GROUP BY進行分組
-- note:在實現分組統計時，統計函數允許嵌套，但嵌套之後的統計查詢SELECT之中
-- 不允許再出現任何的欄位，包括分組欄位。
SELECT s.department, SUM(g.mark) 
FROM sporter s, grade g
WHERE s.sporterid=g.sporterid
GROUP BY s.department;
-- 步驟三:求出最高的積分
SELECT MAX(SUM(g.mark)) 
FROM sporter s, grade g
WHERE s.sporterid=g.sporterid
GROUP BY s.department;
-- 步驟四:以上返回的是單行單列數據，此查詢可以出現在WHERE子句或HAVING子句之中
SELECT s.department, SUM(g.mark) 
FROM sporter s, grade g 
WHERE s.sporterid=g.sporterid 
GROUP BY s.department 
HAVING SUM(g.mark)=
(SELECT MAX(SUM(g.mark)) 
FROM sporter s, grade g 
WHERE s.sporterid=g.sporterid
GROUP BY s.department);


-- ex2:找出在一操場進行比賽的各項目名稱及其冠軍的姓名
-- 確定所需數據表
-- sporter表:姓名
-- item表:項目名稱
-- grade表:積分最高(冠軍)
-- 確定已知關聯欄位
-- 運動員和成績:sporter.sporterid=grade.sproterid
-- 項目和成績:item.itemid=grade.sproterid
-- 步驟一:在一操場進行比賽的各項目的編號和成績
SELECT i.itemid, g.mark  
FROM item i, grade g
WHERE i.itemid=g.itemid 
AND i.location='一操場';
-- 步驟二:所需要的是最高值，發現在項目編號存在重複，那麼直接使用分組完成
SELECT i.itemid, MAX(g.mark) 
FROM item i, grade g
WHERE i.itemid=g.itemid 
AND i.location='一操場'
GROUP BY i.itemid;
-- 步驟三:要找到參加一操場比賽項目的運動員姓名，和他的成績
SELECT s.name, i.itemname, g.mark 
FROM sporter s, item i, grade g 
WHERE s.sporterid=g.sporterid 
AND i.itemid=g.itemid 
AND i.location='一操場';
-- 步驟四:與第二步的查詢結合在一起，確定每一位冠軍的訊息
SELECT s.name, i.itemname, g.mark 
  FROM sporter s, item i, grade g , 
  (SELECT i.itemid iid, MAX(g.mark) max 
  FROM item i, grade g
  WHERE i.itemid=g.itemid 
  AND i.location='一操場'
  GROUP BY i.itemid) t 
WHERE s.sporterid=g.sporterid 
AND i.itemid=g.itemid 
AND i.location='一操場'
AND i.itemid=t.iid
AND g.mark=t.max;
 

-- ex3:找出參加了張三所參加過的項目的其他同學的姓名
-- 確定所需數據表
-- sporter表:找到張三運動員編號
-- grade表:透過張三參加的項目編號找到符合此項目編號的運動員編號
-- 確定已知關聯欄位
-- 運動員和成績:sporter.sporterid=grade.sproterid
-- 項目和成績:item.itemid=grade.sproterid
-- 步驟一:找到張三運動員編號
SELECT s.sporterid 
FROM sporter s
WHERE s.name='張三';
-- 步驟二:根據張三編號找到參加過的項目編號
SELECT g.itemid
FROM grade g
WHERE g.sporterid=
(SELECT s.sporterid 
FROM sporter s
WHERE s.name='張三');
-- 步驟三:重複使用grade表，找到參加過此項目的運動員編號
SELECT g.sporterid 
FROM grade g 
WHERE g.itemid IN
(SELECT g.itemid
FROM grade g
WHERE g.sporterid=
(SELECT s.sporterid 
FROM sporter s
WHERE s.name='張三'));
-- 步驟四:運動員編號知道了，那麼就可以找到運動員的姓名。
SELECT DISTINCT s.name 
FROM sporter s 
WHERE s.sporterid IN
(
  SELECT g.sporterid 
  FROM grade g 
  WHERE g.itemid IN
  (
    SELECT g.itemid
    FROM grade g
    WHERE g.sporterid=
    (
      SELECT s.sporterid 
      FROM sporter s
      WHERE s.name='張三'
    )
  )
)
AND s.name!='張三';
/*
SELECT s.name 
FROM grade g, sporter s, 
  (SELECT g.itemid iid, s.sporterid sid
  FROM sporter s, grade g
  WHERE s.name='張三'
  AND s.sporterid=g.sporterid) t 
WHERE g.itemid=t.iid 
AND s.sporterid!=t.sid
GROUP BY s.name;
*/


-- ex4:經查張三因為使用了違禁品，其成績都記0分，請在數據庫中做出相應的修改
UPDATE grade SET mark=0 
WHERE sporterid=(SELECT sporterid FROM sporter WHERE name='張三');
/*
SELECT * FROM grade 
WHERE sporterid=(SELECT sporterid FROM sporter WHERE name='張三');
*/


-- ex5:經組委會協商，需要刪除女子跳高比賽項目
-- 刪除項目的同時，成績也一定作廢。由於已經設置外鍵，所以只需刪除item表中項目即可
DELETE FROM item WHERE itemname='女子跳高';
/*
SELECT * FROM item;
SELECT * FROM grade;
*/