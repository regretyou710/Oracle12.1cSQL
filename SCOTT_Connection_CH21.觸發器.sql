--============================================================================--
--                                                                            --
/* ※觸發器-觸發器簡介                                                        */ 
--                                                                            --
--============================================================================--
-- 說明:觸發器類似於過程和函數，都具有程序主體部份(聲明段、可執行段、異常處理段
-- )，但是與手動調用過程或函數不同的是，所有觸發器都是依靠事件執行的，例如:當某
-- 一張表執行更新操作(INSERT、UPDATE、DELETE)時，都可能引發觸發器的執行。同時過
-- 程或函數都是顯式調用的，所以其是可以接收參數的，但是觸發器由於採用的是隱式調
-- 用(一觸發某類操作時調用)，所以是不能夠接收參數的。
-- 在Oracle中觸發器主要分為:DML觸發器、INSTEAD-OF(替代)觸發器、DDL觸發器、系統
-- 或數據庫事件觸發器。所有的觸發器都可以使用如下的基本語法進行創建。

-- 觸發器創建語法
/*
CREATE [OR REPLACE] TRIGGER 觸發器名稱
[BEFORE|AFTER] -- 觸發時間
[INSTEAD OF]
[INSERT|UPDATE|UPDATE OF 欄位名稱[,欄位名稱,...]|DELETE] -- 觸發事件
ON[表名稱|視圖|DATABASE|SCHEMA] -- 觸發對象
[REFERENCING [OLD AS 標記][new AS 標記][parent AS 標記]]
[FOR EACH ROW] -- 觸發頻率
[FOLLOWS 觸發器名稱]
[DISABLE]
[WHEN 觸發條件] -- 觸發條件
[DECLARE] -- 觸發操作(程序主體)
 [程序聲明部份;]
 [PRAGMAAUTONOMOUS_TRANSATION;]
BEGIN
 程序代碼部份;
END[觸發器名稱];
/
*/

-- 在編寫觸發器過程中應該注意以下幾點:
-- ①觸發器不接收任何參數，並且只能是在產生某一觸發事件後才會自動調用。
-- ②針對一張數據表的觸發器，最多只能有12個(
-- BEFORE INSERT、BEFORE INSERT FOR EACH ROW、
-- AFTER INSERT、AFTER INSERT FOR EACH ROW、
-- BEFORE UPDATE、BEFORE UPDATE FOR EACH ROW、
-- AFTER UPDATE、AFTER UPDATE FOR EACH ROW、
-- BEFORE DELETE、BEFORE DELETE FOR EACH ROW、
-- AFTER DELETE、AFTER DELETE FOR EACH ROW
-- )
-- ③一個觸發器最大為32K，所以如果需要編寫的代碼較多，可以透過過程函數調用完成。
-- ④默認情況下，觸發器中是不能使用事務處理操作，或採用自治事務進行處理。
-- ⑤在一張數據表中，如果定義過多的觸發器，則會造成DML性能下降。

-- ▲數據庫的設計原則:數據庫中不要使用觸發器。因為性能太慢，尤其是針對大型項目中
-- ，這種項目數據的交換是非常頻繁的。
--============================================================================--
--                                                                            --
/* ※觸發器-DML觸發器                                                         */ 
--                                                                            --
--============================================================================--
-- ➤DML觸發器
-- 說明:DML觸發器主要是由DML語句進行出發，當用戶執行了增加(INSERT)、修改(UPDATE)
-- 、刪除(DELETE)操作時，就會觸發操作。
-- DML觸發器分為兩類:表級觸發器、行級觸發器。

-- 操作順序
/*
當用戶執行更新操作值，觸發器的執行順序如下:
BEFORE表級觸發器執行。
BEFORE行級觸發器執行。
執行更新操作。
AFTER行級觸發器執行。
AFTER表級觸發器執行。

如果現在的觸發器建立的是一個行級觸發器，並且一個觸發器會影響到多行數據，則也會在
每一橫列上執行一次觸發器操作(按照BEFORE行級觸發器執行、執行更新操作、
AFTER行級觸發器執行流程重複執行)。
*/
--============================================================================--
--                                                                            --
/* ※觸發器-表級觸發器                                                        */ 
--                                                                            --
--============================================================================--
-- 說明:表級觸發器指的是真對於全表數據的檢查，每次更新數據表時，只會在更新之前或
-- 之後觸發一次，表級觸發器不需要配置"FOR EACH ROW"選項。

-- ex:只有在每個月的10日才允許辦理新員工入職與離職，其他時間不允許增加員工數據
-- 分析:表示針對於emp表整體的操作
CREATE OR REPLACE TRIGGER forbid_emp_trigger 
BEFORE INSERT OR DELETE -- 在增加或刪除前觸發
ON emp -- 觸發對象
DECLARE 
 v_currentdate VARCHAR2(20); -- 取得當前的天
BEGIN 
 SELECT TO_CHAR(SYSDATE,'DD') INTO v_currentdate FROM dual;
 IF TRIM(v_currentdate)!='10' THEN
  -- 如果不在10日就拋異常，不進行執行動作
  RAISE_APPLICATION_ERROR(-20008,'每月10日才允許辦理與入職或離職手續');
 END IF;
END;
/


-- ex:向表中增加數據
INSERT INTO emp(empno,ename,job,hiredate,sal,comm,mgr,deptno) 
VALUES (8998,'EASON','MANAGER',SYSDATE,2000,500,7369,40);
-- 錯誤報告:SQL 錯誤: ORA-20008: 每月10日才允許辦理與入職或離職手續


-- ex:在星期一、週末以及每天下班時間(每天9:00以前、18:00以後)後不允許更新emp數據
-- 表
CREATE OR REPLACE TRIGGER forbid_emp_trigger 
BEFORE INSERT OR DELETE OR UPDATE 
ON emp -- 觸發對象
DECLARE 
 v_currentweek VARCHAR2(20); -- 取得當前一週時間數
 v_currenthour VARCHAR2(20); -- 取得小時
BEGIN 
 SELECT TO_CHAR(SYSDATE,'DAY'), TO_CHAR(SYSDATE,'HH24')
 INTO v_currentweek, v_currenthour FROM dual;
 IF 
  TRIM(v_currentweek)='星期一' 
  OR TRIM(v_currentweek)='星期六' 
  OR TRIM(v_currentweek)='星期日'
 THEN  
  RAISE_APPLICATION_ERROR(-20008,'在星期一及週末不允許更新emp表');
 ELSIF 
  TRIM(v_currenthour)<'9' 
  OR TRIM(v_currenthour)>'18' 
 THEN 
  RAISE_APPLICATION_ERROR(-20009,'在下班時間不允許更新emp表');
 END IF;
END;
/


-- ex:向表中更新數據
INSERT INTO emp(empno,ename,job,hiredate,sal,comm,mgr,deptno) 
VALUES (8998,'EASON','MANAGER',SYSDATE,2000,500,7369,40);
-- 錯誤報告:SQL 錯誤: ORA-20008: 在星期一及週末不允許更新emp表


-- ex:在每天12點以後，不允許修改員工工資和佣金
CREATE OR REPLACE TRIGGER forbid_emp_trigger 
BEFORE UPDATE OF sal,comm -- 針對特定欄位觸發
ON emp -- 觸發對象
DECLARE  
 v_currenthour VARCHAR2(20); -- 取得小時
BEGIN 
 SELECT TO_CHAR(SYSDATE,'HH24') INTO v_currenthour FROM dual;
 IF TRIM(v_currenthour)>'12' THEN 
  RAISE_APPLICATION_ERROR(-20009,'在每天12點以後不允許修改員工工資和佣金');
 END IF;
END;
/
 

-- ex:不更新sal和comm
UPDATE emp SET ename='史密斯' WHERE empno='7369';


-- ex:更新sal和comm
UPDATE emp SET sal=5000, comm=2000 WHERE empno='7369';
-- 錯誤報告:SQL 錯誤: ORA-20009: 在每天12點以後不允許修改員工工資和佣金


-- ex:每一位員工都要根其收入上繳所得稅，假設所得稅的上繳原則為:2000以下上繳
-- 3%、2000~5000上繳8%、5000以上上繳10%，現在要求建立一張新的數據表，可以紀錄
-- 出員工的編號、姓名、工資、傭金、上繳所得稅數據，並且在每次修改員工表中sal和
-- comm欄位後可以自動更新紀錄。
-- 分析:現在沒有區分某一橫列數據的更新能力，所以這個時候最簡單的做法是每次更新
-- 一位員工訊息的時候，就需要修改相應的稅收紀錄表訊息，先全部刪除，然後增加新的
-- 數據。
-- 步驟一:建立一張保存稅收的紀錄表
DROP TABLE emp_tax PURGE;
CREATE TABLE emp_tax(
 empno NUMBER(4),
 ename VARCHAR2(10),
 sal NUMBER(7,2),
 comm NUMBER(7,2),
 tax NUMBER(7,2),
CONSTRAINT pk_empno PRIMARY KEY(empno),
CONSTRAINT fk_empno FOREIGN KEY(empno) 
REFERENCES emp(empno) ON DELETE CASCADE
);
-- 這張表要與emp表一起關聯，之所以設置外鍵是要保證員工刪除的時候對應的訊息也消失
-- 。


-- 步驟二:建立觸發器
CREATE OR REPLACE TRIGGER forbid_emp_trigger 
AFTER UPDATE OR INSERT OF ename,sal,comm -- 針對特定欄位觸發
ON emp -- 觸發對象
DECLARE 
 -- 2.定義游標，找到每一橫列紀錄
 CURSOR cur_emp IS SELECT * FROM emp;
 
 -- 3.保存一橫列紀錄
 v_empRow emp%ROWTYPE;
 
 -- 4.計算總收入
 v_salary emp.sal%TYPE;
 
 -- 保存稅收金額
 v_empTax emp_tax.tax%TYPE;
BEGIN 
 -- 1.清空emp_tax表的紀錄
 DELETE FROM emp_tax;
 
 -- 5.將游標的紀錄指定給v_empRow變數保存
 FOR v_empRow IN cur_emp LOOP 
  -- 計算總工資
  v_salary := v_empRow.sal+NVL(v_empRow.comm,0);
  IF v_salary<2000 THEN 
   v_empTax := v_salary*0.03;
  ELSIF v_salary BETWEEN 2000 AND 5000 THEN 
   v_empTax := v_salary*0.08;
  ELSIF v_salary >5000 THEN 
   v_empTax := v_salary*0.1;
  END IF;
  
  INSERT INTO emp_tax(empno, ename, sal, comm, tax) 
  VALUES (v_empRow.empno, v_empRow.ename, v_empRow.sal, v_empRow.comm, v_empTax);
 END LOOP;
 --COMMIT; -- 錯誤: ORA-04092
END;
/


-- 步驟三:向表中增加一條新的紀錄
INSERT INTO emp(empno,ename,job,hiredate,sal,comm,mgr,deptno) 
VALUES (9898,'EASON','MANAGER',SYSDATE,2000,500,7369,40);
SELECT * FROM emp;
SELECT * FROM emp_tax;
-- 這個時候的觸發器是在更新之後觸發的，所以執行後對於emp_tax表中就有數據了。
-- 但是此時觸發器中所增加的數據並未提交事務。如果此時在觸發器中編寫COMMIT，
-- 那麼執行時就會出現異常。
-- 錯誤報告:SQL 錯誤: ORA-04092: 無法在一個觸發程式中 COMMIT


-- 主事務要執行的事情較多，觸發器只是主事務的旁支事務，所以不應該跟主事務混在
-- 一起。那麼就必須啟動一個新的子事務。
-- ex:完善觸發器
CREATE OR REPLACE TRIGGER forbid_emp_trigger 
AFTER UPDATE OR INSERT OF ename,sal,comm -- 針對特定欄位觸發
ON emp -- 觸發對象
DECLARE 
 -- 2.定義游標，找到每一橫列紀錄
 CURSOR cur_emp IS SELECT * FROM emp;
 
 -- 3.保存一橫列紀錄
 v_empRow emp%ROWTYPE;
 
 -- 4.計算總收入
 v_salary emp.sal%TYPE;
 
 -- 保存稅收金額
 v_empTax emp_tax.tax%TYPE;
 
 -- 加入自治事務聲明 
 PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN 
 -- 1.清空emp_tax表的紀錄
 DELETE FROM emp_tax;
 
 -- 5.將游標的紀錄指定給v_empRow變數保存
 FOR v_empRow IN cur_emp LOOP 
  -- 計算總工資
  v_salary := v_empRow.sal+NVL(v_empRow.comm,0);
  IF v_salary<2000 THEN 
   v_empTax := v_salary*0.03;
  ELSIF v_salary BETWEEN 2000 AND 5000 THEN 
   v_empTax := v_salary*0.08;
  ELSIF v_salary >5000 THEN 
   v_empTax := v_salary*0.1;
  END IF;
  
  INSERT INTO emp_tax(empno, ename, sal, comm, tax) 
  VALUES (v_empRow.empno, v_empRow.ename, v_empRow.sal, v_empRow.comm, v_empTax);
 END LOOP;
 COMMIT;
END;
/
--============================================================================--
--                                                                            --
/* ※觸發器-行級DML觸發器                                                     */ 
--                                                                            --
--============================================================================--
-- 說明:在之前所講解的觸發器操作是在對整張表進行DML操作之前或之後才進行的觸發操
-- 作，並且只在更新前或更新後觸發一次，而行級觸發器指的是表中每一橫列紀錄出現更
-- 新操作時進行的觸發操作，即:如果某些更新操作影響了多橫列數據，則每橫列數據更新
-- 時都會引起觸發器操作，而如果要使用行級觸發器，在定義觸發器時必須定義
-- "FOR EACH ROW"。

-- ➤":old.欄位"和":new.欄位"標識符
-- 說明:在使用行級觸發器操作的過程中，可以在觸發器內部訪問正在處理中的橫列數據，
-- 此時可以透過兩個相關的標識符":old.欄位"和":new.欄位"實現，而這兩個標識符僅僅
-- 是在DML觸發表中欄位時才有效。
------------------------------------------------------------------------
|No.|觸發語句|:old.欄位               |:new.欄位                       |
------------------------------------------------------------------------
|1  |INSERT  |未定義，欄位內容均為NULL|INSERT操作結束後，為增加數據值  |
------------------------------------------------------------------------
|2  |UPDATE  |更新數據前的原始值      |UPDATE操作之後，更新數據後的新值|
------------------------------------------------------------------------
|3  |DELETE  |刪除前的原始值          |未定義，欄位內容均為NULL        |
------------------------------------------------------------------------

-- ex:增加員工訊息時，其職位必須在已有職位內選擇，並且工資不能超過5000
-- 分析:此時一定要找到已有的職位訊息(job欄位內容)，工資肯定是判斷的新工資。
CREATE OR REPLACE TRIGGER forbid_emp_trigger 
BEFORE INSERT  
ON emp -- 觸發對象
FOR EACH ROW -- 行級觸發
DECLARE 
 v_jobCount NUMBER; -- 查詢職位的數量 
BEGIN 
 SELECT COUNT(empno) INTO v_jobCount FROM emp 
 WHERE :new.job IN(SELECT DISTINCT job FROM emp);
 
 -- 增加員工前判斷有無其職位存在
 IF v_jobCount=0 THEN  
  RAISE_APPLICATION_ERROR(-20008,'增加員工的職位訊息名稱錯誤');
 ELSE 
  -- 在職位存在的情況下，判斷工資是否大於5000
  IF :new.sal>5000 THEN  
   RAISE_APPLICATION_ERROR(-20009,'增加員工的工資不得超過5000');
  END IF;
 END IF;
END;
/


-- ex:向emp表輸入錯誤數據
INSERT INTO emp(empno, ename, job, hiredate, sal, comm, mgr, deptno) 
VALUES (8998, 'EASON', '經理', SYSDATE, 9000, 500, 7369, 40);
-- 錯誤報告:SQL 錯誤: ORA-20008: 增加員工的職位訊息名稱錯誤 

-- ex:向emp表輸入錯誤數據
INSERT INTO emp(empno, ename, job, hiredate, sal, comm, mgr, deptno) 
VALUES (8998, 'EASON', 'MANAGER', SYSDATE, 9000, 500, 7369, 40);
-- 錯誤報告:SQL 錯誤: ORA-20009: 增加員工的工資不得超過5000

-- ex:向emp表輸入正確數據
INSERT INTO emp(empno, ename, job, hiredate, sal, comm, mgr, deptno) 
VALUES (8998, 'EASON', 'MANAGER', SYSDATE, 3000, 500, 7369, 40);
SELECT * FROM emp;
ROLLBACK;


-- ex:修改emp表的基本工資漲幅不能超過10%
-- 分析:需要知道原始的工資才有辦法進行漲幅
CREATE OR REPLACE TRIGGER emp_update_trigger 
BEFORE UPDATE OF sal -- 在修改工資之前觸發
ON emp -- 觸發對象
FOR EACH ROW -- 行級觸發
--DECLARE 
BEGIN 
 -- 觸發時產生兩個欄位
 -- 1.old.sal、2.new.sal
 
 -- 新工資減舊工資取絕對值
 IF ABS((:new.sal-:old.sal)/:old.sal)>0.1 THEN 
  -- 如果在修改後新工資調整幅度太大則拋出異常，UPDATE也就不會執行
  RAISE_APPLICATION_ERROR(-20008,'員工工資修改幅度太大'); 
 END IF;
END;
/


-- ex:將7369的工資修改為5000
UPDATE emp SET sal=5000 WHERE empno=7369;
-- 錯誤報告:SQL 錯誤: ORA-20008: 員工工資修改幅度太大


-- ex:不能刪除所有10部門的員工
CREATE OR REPLACE TRIGGER emp_delete_trigger 
BEFORE DELETE  
ON emp -- 觸發對象
FOR EACH ROW -- 行級觸發
--DECLARE 
BEGIN 
 IF :old.deptno=10 THEN  
  RAISE_APPLICATION_ERROR(-20008,:old.empno || 
  '為10部門員工，無法刪除此部門員工'); 
 END IF;
END;
/


-- ex:刪除10部門員工
DELETE FROM emp WHERE empno=7839;
-- 錯誤報告:SQL 錯誤: ORA-20008: 7839為10部門員工，無法刪除此部門員工


-- ➤實現自動序列
-- 在Oracle 12c之中已經提供了自動序列的支持，但本次的操作是針對Oracle 12c之前的
-- 版本，考慮到之前版本的問題，所以做一個簡單的範例。
-- 序列只能夠透過nextval手動調用後才可以取得增長值，現在希望透過一個觸發器，幫助
-- 用戶取得增長值，然後向表中保存。
-- 步驟一:創建數據表
DROP TABLE member PURGE;
DROP TABLE membertemp PURGE;
CREATE SEQUENCE member_seq;
CREATE TABLE member(
 mid NUMBER,
 name VARCHAR2(30),
 address VARCHAR2(50),
 CONSTRAINT pk_mid PRIMARY KEY(mid)
);
-- 複製member表結構沒有數據
CREATE TABLE membertemp AS SELECT * FROM member WHERE 1=2;


-- member表為主要使用，但是為了可以正常操作所以又創建了一個membertemp表，此表結構
-- 與member表完全相同。
-- 步驟二:定義觸發器
-- ex:錯誤的觸發器(不考慮membertemp，而在member表上創建觸發器)
CREATE OR REPLACE TRIGGER member_insert_trigger 
BEFORE INSERT 
ON member
FOR EACH ROW -- 為了有:old和:new可以操作
--DECLARE 
BEGIN 
 INSERT INTO member(mid, name, address) 
 VALUES (member_seq.nextval, :new.name, :new.address);
END;
/


-- ex:向member表增加紀錄，此時不須設置mid,因為由序列完成。
INSERT INTO member(name, address) VALUES ('伊森','TW');
/*
錯誤報告:
SQL 錯誤: ORA-00036: 已超過遞迴 SQL 層次 (50) 的數目上限
ORA-06512: 在 "C##SCOTT.MEMBER_INSERT_TRIGGER", line 2
ORA-04088: 執行觸發程式 'C##SCOTT.MEMBER_INSERT_TRIGGER' 時發生錯誤
*/


-- ex:正確的觸發器(在membertemp表操作)
DROP trigger member_insert_trigger;
CREATE OR REPLACE TRIGGER member_insert_trigger 
BEFORE INSERT 
ON membertemp
FOR EACH ROW -- 為了有:old和:new可以操作
--DECLARE 
BEGIN 
 DELETE FROM membertemp; -- 清空membertemp表數據
 INSERT INTO member(mid, name, address) 
 VALUES (member_seq.nextval, :new.name, :new.address);
END;
/


-- ex:向membertemp表增加紀錄，等同向member表增加數據
INSERT INTO membertemp(name, address) VALUES ('伊森','TW');
SELECT * FROM member;
SELECT * FROM membertemp;
-- 所以此時就可以感受到在Oracle 12c中的自動序列支持的優點。


-- ➤REFERENCING子句
-- 說明:如果現在覺得使用":new.欄位"或是":old.欄位"標記不清，那麼也可以透過
-- REFERENCING子句為這兩個標示符設置別名。
-- note:REFERENCING子句要寫在FOR EACH ROW之前，順序不能改變。
-- ex:透過REFERENCING子句設置別名(修改員工工資漲幅觸發器)
CREATE OR REPLACE TRIGGER emp_update_trigger 
BEFORE UPDATE OF sal -- 在修改工資之前觸發
ON emp -- 觸發對象
REFERENCING old AS emp_old new AS emp_new 
FOR EACH ROW -- 行級觸發
--DECLARE 
BEGIN 
 -- 觸發時產生兩個欄位
 -- 1.old.sal、2.new.sal
 /*
 -- 新工資減舊工資取絕對值
 IF ABS((:new.sal-:old.sal)/:old.sal)>0.1 THEN 
  -- 如果在修改後新工資調整幅度太大則拋出異常，UPDATE也就不會執行
  RAISE_APPLICATION_ERROR(-20008,'員工工資修改幅度太大'); 
 END IF;
 */
  -- 新工資減舊工資取絕對值
 IF ABS((:emp_new.sal-:emp_old.sal)/:emp_old.sal)>0.1 THEN 
  -- 如果在修改後新工資調整幅度太大則拋出異常，UPDATE也就不會執行
  RAISE_APPLICATION_ERROR(-20008,'員工工資修改幅度太大'); 
 END IF;
END;
/


-- ex:將7369的工資修改為5000
UPDATE emp SET sal=5000 WHERE empno=7369;
-- 錯誤報告:SQL 錯誤: ORA-20008: 員工工資修改幅度太大


-- ➤WHEN子句
-- 說明:除了REFERENCING子句之外，在觸發器定義語法中也存在WHEN子句，WHEN子句是在
-- 觸發器被觸發之後，用來控制觸發器是否被執行的一個控制條件，在WHEN子句中也可以
-- 利用"new"和"old"訪問修改前後的數據，同時最方便的地方在於，WHEN子句中使用"new"
-- 和"old"時，可以不用加前面的冒號。
-- ex:在增加員工時，判斷員工工資是否存在，如果工資為0則報錯
CREATE OR REPLACE TRIGGER emp_insert_trigger 
BEFORE INSERT 
ON emp -- 觸發對象
FOR EACH ROW -- 行級觸發
WHEN (new.sal=0) -- 替代IF判斷條件
--DECLARE 
BEGIN   
  RAISE_APPLICATION_ERROR(-20008, :new.empno || '的工資為0, 不符合規定'); 
END;
/


-- ex:增加錯誤數據
INSERT INTO emp(empno, ename, job, hiredate, sal, comm, mgr, deptno) 
VALUES (8998, 'EASON', 'MANAGER', SYSDATE, 0, 500, 7369, 40);
-- 錯誤報告:SQL 錯誤: ORA-20008: 8998的工資為0, 不符合規定


-- ex:要求工資只能上漲，不能降低
CREATE OR REPLACE TRIGGER emp_sal_update_trigger 
BEFORE UPDATE -- 在工資修改前觸發 
ON emp -- 觸發對象
FOR EACH ROW -- 行級觸發
WHEN (new.sal<old.sal) -- 替代IF判斷條件
--DECLARE 
BEGIN 
  RAISE_APPLICATION_ERROR(-20008, :new.empno || '的工資少於原本工資, 無法更新'); 
END;
/


-- ex:增加更新數據
UPDATE emp SET sal=700 WHERE empno=7369;
-- 錯誤報告:SQL 錯誤: ORA-20008: 7369的工資少於原本工資, 無法更新


-- ➤觸發器謂詞
-- 說明:除了依靠不同的操作事件來定義觸發器外，也可以在一個觸發器之中針對於一個觸
-- 發器的不同狀態來執行不同的操作，而此時為了區分出不同的DML操作，在觸發器定義中
-- 專門提供三個觸發器謂詞:INSERTING、UPDATING、DELETEING
--------------------------------------------------------------
|No.|觸發器謂詞|描述                                         |
--------------------------------------------------------------
|1  |INSERTING |如果觸發語句為INSERT，返回TRUE，否則返回FALSE|
--------------------------------------------------------------
|2  |UPDATING  |如果觸發語句為UPDATE，返回TRUE，否則返回FALSE|
--------------------------------------------------------------
|3  |DELETEING |如果觸發語句為DELETE，返回TRUE，否則返回FALSE|
--------------------------------------------------------------


-- ex:定義觸發器，針對不同的DML操作進行日誌紀錄
-- 步驟一:建立一張部門日誌表
DROP TABLE dept_log PURGE;
DROP SEQUENCE dept_log_seq;
CREATE SEQUENCE dept_log_seq;
CREATE TABLE dept_log(
 logid NUMBER,
 type VARCHAR2(20) NOT NULL,
 deptno NUMBER(2),
 logdate DATE,
 dname VARCHAR2(14) NOT NULL,
 loc VARCHAR2(13) NOT NULL,
 CONSTRAINT pk_logid PRIMARY KEY(logid)
);


-- 步驟二:定義觸發器，對操作何種DML進行日誌添加
CREATE OR REPLACE TRIGGER dept_update_trigger 
BEFORE INSERT OR UPDATE OR DELETE  
ON dept -- 觸發對象
FOR EACH ROW -- 行級觸發
--DECLARE 
BEGIN 
 IF INSERTING THEN 
  INSERT INTO dept_log(logid, type, logdate, deptno, dname, loc)
  VALUES (dept_log_seq.nextval, 'INSERT', SYSDATE, :new.deptno, 
  :new.dname, :new.loc);  
 ELSIF UPDATING THEN 
  INSERT INTO dept_log(logid, type, logdate, deptno, dname, loc)
  VALUES (dept_log_seq.nextval, 'UPDATE', SYSDATE, :new.deptno, 
  :new.dname, :new.loc);  
 ELSE
  INSERT INTO dept_log(logid, type, logdate, deptno, dname, loc)
  VALUES (dept_log_seq.nextval, 'DELETE', SYSDATE, :old.deptno, 
  :old.dname, :old.loc);  
 END IF;
END;
/
-- 此時對dept表的所有修改都會進行紀錄。


-- ex:向dept表增加一系列紀錄
INSERT INTO dept(deptno, dname, loc) VALUES (50, 'IT', '台中');
INSERT INTO dept(deptno, dname, loc) VALUES (60, 'TE', '台北');
UPDATE dept SET dname='資訊部' WHERE deptno=50;
UPDATE dept SET dname='技術部' WHERE deptno=60;
DELETE FROM dept WHERE deptno=60;
SELECT * FROM dept_log;


-- ➤FOLLOWS子句
-- 說明:如果為一個表創建了多個觸發器，那麼其在進行觸發時，是不會按照用戶希望的觸
-- 發順序執行觸發器的，假設用戶希望觸發器的執行順序是:emp_insert_one、
-- emp_insert_two、emp_insert_three，但是在默認情況下，各個觸發器執行的順序往往
-- 並不會像預期的那樣。
-- ex:定義三個觸發器
CREATE OR REPLACE TRIGGER emp_insert_one 
BEFORE INSERT 
ON emp -- 觸發對象
FOR EACH ROW -- 行級觸發
--DECLARE 
BEGIN 
 DBMS_OUTPUT.put_line('執行第一個觸發器(emp_insert_one)');
END;
/

CREATE OR REPLACE TRIGGER emp_insert_two 
BEFORE INSERT 
ON emp -- 觸發對象
FOR EACH ROW -- 行級觸發
--DECLARE 
BEGIN 
 DBMS_OUTPUT.put_line('執行第二個觸發器(emp_insert_two)');
END;
/

CREATE OR REPLACE TRIGGER emp_insert_three 
BEFORE INSERT 
ON emp -- 觸發對象
FOR EACH ROW -- 行級觸發
--DECLARE 
BEGIN 
 DBMS_OUTPUT.put_line('執行第三個觸發器(emp_insert_three)');
END;
/
-- 是三個觸發器，但是注意雖然此時有定義順序，但並不是執行順序。


-- ex:增加員工數據
INSERT INTO emp(empno, ename, job, hiredate, sal, comm, mgr, deptno) 
VALUES (8098, 'EASON', 'MANAGER', SYSDATE, 1000, 500, 7369, 40);
/*
執行結果:
執行第三個觸發器(emp_insert_three)
執行第二個觸發器(emp_insert_two)
執行第一個觸發器(emp_insert_one)
*/


-- 如果希望按照順序執行，那麼就必須使用Oracle 11g中提供的新功能，利用FOLLOWSA子句
-- 完成。
-- ex:修改觸發器定義
CREATE OR REPLACE TRIGGER emp_insert_one 
BEFORE INSERT 
ON emp -- 觸發對象
FOR EACH ROW -- 行級觸發
--DECLARE 
BEGIN 
 DBMS_OUTPUT.put_line('執行第一個觸發器(emp_insert_one)');
END;
/

CREATE OR REPLACE TRIGGER emp_insert_two 
BEFORE INSERT 
ON emp -- 觸發對象
FOR EACH ROW -- 行級觸發
FOLLOWS emp_insert_one -- 定義觸發順序
--DECLARE 
BEGIN 
 DBMS_OUTPUT.put_line('執行第二個觸發器(emp_insert_two)');
END;
/

CREATE OR REPLACE TRIGGER emp_insert_three 
BEFORE INSERT 
ON emp -- 觸發對象
FOR EACH ROW -- 行級觸發
FOLLOWS emp_insert_two -- 定義觸發順序
--DECLARE 
BEGIN 
 DBMS_OUTPUT.put_line('執行第三個觸發器(emp_insert_three)');
END;
/
/*
執行結果:
執行第一個觸發器(emp_insert_one)
執行第二個觸發器(emp_insert_two)
執行第三個觸發器(emp_insert_three)
*/
--============================================================================--
--                                                                            --
/* ※觸發器-變異表                                                            */ 
--                                                                            --
--============================================================================--
-- 說明:當一張數據表上執行了更新操作後(INSERT、UPDATE、DELETE)就會成為了一張變異
-- 表，而如果在這張變異表上設置了行級觸發器，那麼就會出現"ORA-04091"的異常。

-- ex:定義一張數據表
DROP TABLE info PURGE;
CREATE TABLE info(
 id NUMBER,
 title VARCHAR2(50),
 CONSTRAINT pk_id PRIMARY KEY(id)
);

INSERT INTO info(id, title) VALUES (1, 'www.oracle.com');


-- ex:為info表增加觸發器
CREATE OR REPLACE TRIGGER info_trigger 
BEFORE INSERT OR UPDATE OR DELETE 
ON info 
FOR EACH ROW 
DECLARE 
 v_infocount NUMBER;
BEGIN 
 SELECT COUNT(id) INTO v_infocount FROM info;
END;
/


-- ex:執行以下更新操作
UPDATE info SET id=2;
-- 錯誤報告:
-- SQL 錯誤: ORA-04091: 表格 C##SCOTT.INFO 正在變更中, 觸發程式/函數無法檢視它
-- 現在進行表修改的時候，一定會引起觸發器的工作，而觸發器的程序中會取得表中的數
-- 據列個數，但由於操作的數據沒有更新結束，所以是無法得到個數的。
--============================================================================--
--                                                                            --
/* ※觸發器-複合觸發器                                                        */ 
--                                                                            --
--============================================================================--
-- 說明:複合觸發器是在Oracle 11g之後引入進來的一種新結構的觸發器，複合觸發器既是
-- 表級觸發器又是行級觸發器。在之前針對不同級別的觸發器，如果要在一張數據表上完
-- 成表級觸發(BEFORE和AFTER)與行級觸發器(BEFORE和AFTER)則需要編寫四個觸發器才可以
-- 完成，而有了複合觸發器後，只需要一個觸發器就可以定義完全部的四個功能，所以使用
-- 複合觸發器可以捕獲四個操作事件:
-- ①觸發執行語句之前(BEFORE STATEMENT)。
-- ②觸發語句中的每一橫列發生變化之前(BEFORE EACH ROW)。
-- ③觸發語句中的每一橫列發生變化之後(AFTER EACH ROW)。
-- ④觸發執行語句之後(AFTER STATEMENT)。

/*
複合觸發器創建語法:
CREATE [OR REPLACE] TRIGGER 觸發器名稱
FOR [INSERT|UPDATE|UPDATE OF 欄位名稱[,欄位名稱,...]|DELETE] ON 表名稱
COMOPOUND TRIGGER 
 [BEFORE STATEMENT IS -- 語句執行前觸發(表級)
  [聲明部份;]
 BEGIN
  程序主體部份;
 END BEFORE STATEMENT;]
 [BEFORE EACH ROW IS -- 語句執行前觸發(行級)
  [聲明部份;]
 BEGIN
  程序主體部份;
 END BEFORE EACH ROW;]
 [AFTER STATEMENT IS -- 語句執行後觸發(表級)
  [聲明部份;]
 BEGIN
  程序主體部份;
 END AFTER STATEMENT;]
 [AFTER EACH ROW IS -- 語句執行後觸發(行級)
  [聲明部份;]
 BEGIN
  程序主體部份;
 END AFTER EACH ROW;]
END;
/
*/

-- ex:驗證複合觸發器
CREATE OR REPLACE TRIGGER compound_trigger
FOR INSERT OR UPDATE OR DELETE ON dept
COMPOUND TRIGGER 
 BEFORE STATEMENT IS   
 BEGIN
  DBMS_OUTPUT.put_line('1. BEFORE STATEMENT');
 END BEFORE STATEMENT;
 
 BEFORE EACH ROW IS   
 BEGIN
  DBMS_OUTPUT.put_line('2. BEFORE EACH ROW');
 END BEFORE EACH ROW;
 
 AFTER STATEMENT IS   
 BEGIN
  DBMS_OUTPUT.put_line('3. AFTER STATEMENT');
 END AFTER STATEMENT;
 
 AFTER EACH ROW IS   
 BEGIN
  DBMS_OUTPUT.put_line('4. AFTER EACH ROW');
 END AFTER EACH ROW;
END;
/


-- ex:向dept表中增加一條紀錄
INSERT INTO dept(deptno, dname, loc) VALUES (70,'google','USA');
/*
1. BEFORE STATEMENT
2. BEFORE EACH ROW
4. AFTER EACH ROW
3. AFTER STATEMENT
*/


-- ex:現在向dept表中增加數據的時候沒有設置部門名稱及位置，希望由觸發器自己將名稱
-- 設置為java，位置設置為'TW'
CREATE OR REPLACE TRIGGER compound_trigger
FOR INSERT OR UPDATE OR DELETE ON dept
COMPOUND TRIGGER  
 BEFORE EACH ROW IS   
 BEGIN
  IF INSERTING THEN
   IF :new.dname IS NULL THEN 
    :new.dname := 'java'; 
   END IF;
  
   IF :new.loc IS NULL THEN 
    :new.loc := 'TW'; 
   END IF;
  END IF;
 END BEFORE EACH ROW; 
END;
/


-- ex:向dept表中增加一條紀錄
INSERT INTO dept(deptno) VALUES (70);


-- ex:定義觸發器，此觸發器可以完成如下的功能:
-- ①在週末時間不允許更新emp表數據。
-- ②在更新數據時，要求將所有增加的數據自動變為大寫。
-- ③在更新完成之後，新增員工的工資不得高於公司的平均工資。
DROP TRIGGER compound_trigger;
CREATE OR REPLACE TRIGGER compound_trigger
FOR INSERT OR UPDATE OR DELETE ON emp
COMPOUND TRIGGER 
 BEFORE STATEMENT IS 
  v_currentweek VARCHAR2(20);
 BEGIN 
  -- ①在週末時間不允許更新emp表數據。
  SELECT TO_CHAR(SYSDATE,'DAY') INTO v_currentweek FROM dual;
  IF TRIM(v_currentweek) IN('星期六','星期日') THEN
   RAISE_APPLICATION_ERROR(-20008,'在週末時間不允許更新emp表數據');
  END IF;
 END BEFORE STATEMENT;
  
 BEFORE EACH ROW IS 
  v_avgSal emp.sal%TYPE;
 BEGIN
  -- ②在更新數據時，要求將所有增加的數據自動變為大寫。
  IF INSERTING OR UPDATING THEN 
   :new.ename := UPPER(:new.ename);
   :new.job := UPPER(:new.job);
  END IF;
  
  -- ③在更新完成之後，新增員工的工資不得高於公司的平均工資。
  IF INSERTING THEN 
   SELECT AVG(sal) INTO v_avgSal FROM emp;
    IF :new.sal>v_avgSal THEN 
	 RAISE_APPLICATION_ERROR(-20009,'新增員工的工資不得高於公司的平均工資'); 
	END IF;
  END IF;
 END BEFORE EACH ROW; 
END;
/


-- ex:向emp表中增加正確數據，數據為小寫
INSERT INTO emp(empno, ename, job, hiredate, sal, comm, mgr, deptno) 
VALUES (8105, 'judy', 'salesman', SYSDATE, 1680, null, 7566, 20);


-- ex:向emp表中增加一條紀錄，工資大於5000
INSERT INTO emp(empno, ename, job, hiredate, sal, comm, mgr, deptno) 
VALUES (8104, 'judy', 'salesman', SYSDATE, 5000, null, 7566, 20);
-- 錯誤報告:SQL 錯誤: ORA-20009: 新增員工的工資不得高於公司的平均工資

-- ex:在週末，向emp表中增加正確數據
INSERT INTO emp(empno, ename, job, hiredate, sal, comm, mgr, deptno) 
VALUES (8103, 'judy', 'salesman', SYSDATE, 1680, null, 7566, 20);
-- 錯誤報告:SQL 錯誤: ORA-20008: 在週末時間不允許更新emp表數據
--============================================================================--
--                                                                            --
/* ※觸發器-instead-of觸發器                                                  */ 
--                                                                            --
--============================================================================--
-- 簡述:透過替代觸發器解決更新視圖十多的數據表一起更新的問題。
/*
創建語法:
CREATE [OR REPLACE] TRIGGER 觸發器名稱
INSTEAD OF [INSERT|UPDATE|UPDATE OF 欄位名稱[,欄位名稱,...]|DELETE] ON
視圖名稱
[FOR EACH ROW]
[WHEN 觸發條件]
[DECLARE]
 [程序聲明部份;]
BEGIN 
 程序代碼部份;
END[觸發器名稱];
/ 
*/


-- ➤複雜視圖的更新問題
-- ex:創建包含20部門員工訊息的複雜視圖
CREATE OR REPLACE VIEW v_myview 
AS 
 SELECT e.empno, e.ename, e.job, e.sal, d.deptno, d.dname, d.loc 
 FROM emp e, dept d 
 WHERE e.deptno=d.deptno AND d.deptno=20;
 
 
-- ex:向視圖增加紀錄
INSERT INTO v_myview(empno, ename, job, sal, deptno, dname, loc) 
VALUES (6688, '谷歌', 'CLERK', 2000, 50, '資訊', '加州'); 
-- 錯誤報告:SQL 錯誤: ORA-01776: 無法透過結合視觀表來修改一個以上的基本表格
-- 因為這個視圖屬於複雜視圖，不是簡單視圖。如果現在希望操作可以成功，那麼只能利用
-- 替代觸發器完成。


-- ex:創建一個替代觸發器，實現視圖更新操作
CREATE OR REPLACE TRIGGER view_trigger 
INSTEAD OF INSERT ON v_myview 
FOR EACH ROW 
DECLARE 
 v_empCount NUMBER;
 v_deptCount NUMBER;
BEGIN 
 -- 判斷要增加的員工是否存在
 SELECT COUNT(empno) INTO v_empCount FROM emp WHERE empno=:new.empno;
 IF v_empCount=0 THEN 
  INSERT INTO emp(empno, ename, job, sal) 
  VALUES (:new.empno, :new.ename, :new.job, :new.sal);
 END IF;
 
 -- 判斷要增加的部門是否存在
 SELECT COUNT(deptno) INTO v_deptCount FROM dept WHERE deptno=:new.deptno; 
 IF v_deptCount=0 THEN
  INSERT INTO dept(deptno, dname, loc) 
  VALUES (:new.deptno, :new.dname, :new.loc);
 END IF; 
END;
/


-- ex:向視圖增加紀錄
INSERT INTO v_myview(empno, ename, job, sal, deptno, dname, loc) 
VALUES (6688, '谷歌', 'CLERK', 2000, 50, '資訊', '加州'); 
SELECT * FROM emp;
SELECT * FROM dept;
/*
因為建立視圖時emp表沒有定義e.deptno欄位所以insert時是null，查詢也就沒有資料
SELECT * FROM v_myview;
*/


-- ex:向視圖表執行更新操作
UPDATE v_myview SET ename='史密斯', sal=2000, dname='技術部' WHERE empno=7369;
-- 錯誤報告:SQL 錯誤: ORA-01776: 無法透過結合視觀表來修改一個以上的基本表格
-- 此時視圖也無法進行修改，所以還需透過替代觸發器進行。


-- ex:創建一個替代觸發器，實現視圖更新操作
-- note:更新emp表中有而視圖沒有的數據是沒有作用的
CREATE OR REPLACE TRIGGER view_trigger 
INSTEAD OF UPDATE ON v_myview 
FOR EACH ROW 
DECLARE 
BEGIN
 UPDATE emp SET ename=:new.ename, job=:new.job, sal=:new.sal 
 WHERE empno=:new.empno; 

 UPDATE dept SET dname=:new.dname, loc=:new.loc WHERE deptno=:new.deptno;
END;
/


-- ex:編寫刪除功能
-- 如果刪除的是視圖中的數據，某一個部門沒有員工，那麼就連部門一起刪除。
-- 創建替代觸發器
CREATE OR REPLACE TRIGGER view_trigger 
INSTEAD OF DELETE ON v_myview 
FOR EACH ROW 
DECLARE 
 v_empCount NUMBER;
BEGIN
 DELETE FROM emp WHERE empno=:old.empno;

 -- 判斷要刪除的部門員工數量是否存在 
 SELECT COUNT(empno) INTO v_empCount FROM emp WHERE deptno=:old.deptno;
 -- 此部門沒有人
 IF v_empCount=0 THEN 
  DELETE FROM dept WHERE deptno=:old.deptno;
 END IF;
END;
/


-- ex:刪除視圖中所有20部門員工
DELETE FROM v_myview WHERE deptno=20;


-- 以上三個功能可以合在一起，使用觸發器謂詞創建一個觸發器完成。
-- ex:定義觸發器
CREATE OR REPLACE TRIGGER view_trigger 
INSTEAD OF INSERT OR UPDATE OR DELETE ON v_myview 
FOR EACH ROW 
DECLARE 
 v_empCount NUMBER;
 v_deptCount NUMBER;
BEGIN 
 IF INSERTING THEN 
  -- 判斷要增加的員工是否存在
  SELECT COUNT(empno) INTO v_empCount FROM emp WHERE empno=:new.empno;
  IF v_empCount=0 THEN 
   INSERT INTO emp(empno, ename, job, sal) 
   VALUES (:new.empno, :new.ename, :new.job, :new.sal);
  END IF;
 
  -- 判斷要增加的部門是否存在
  SELECT COUNT(deptno) INTO v_deptCount FROM dept WHERE deptno=:new.deptno; 
  IF v_deptCount=0 THEN
   INSERT INTO dept(deptno, dname, loc) 
   VALUES (:new.deptno, :new.dname, :new.loc);
  END IF;
 ELSIF UPDATING THEN 
  UPDATE emp SET ename=:new.ename, job=:new.job, sal=:new.sal 
  WHERE empno=:new.empno;
  
  UPDATE dept SET dname=:new.dname, loc=:new.loc WHERE deptno=:new.deptno;
 ELSE 
  DELETE FROM emp WHERE empno=:old.empno;

  -- 判斷要刪除的部門員工數量是否存在 
  SELECT COUNT(empno) INTO v_empCount FROM emp WHERE deptno=:old.deptno;
  -- 此部門沒有人
  IF v_empCount=0 THEN 
   DELETE FROM dept WHERE deptno=:old.deptno;
  END IF;
 END IF; 
END;
/


-- ➤在嵌套表上定義替代觸發器
-- 說明:嵌套表是一種Oracle中特殊的結構，如果創建的視圖包含嵌套表的定義，那麼在
-- 進行視圖更新的時候，也必須透過替代觸發器進行操作。
-- ex:定義一個嵌套表
-- 步驟一:定義複合類型
DROP TYPE project_type FORCE;
DROP TYPE project_nested FORCE;
CREATE OR REPLACE TYPE project_type AS OBJECT(
 projectid NUMBER,
 projectname VARCHAR2(50),
 projectfunds NUMBER,
 pubdate DATE
);
/
-- 步驟二:定義嵌套表類型
CREATE OR REPLACE TYPE project_nested 
AS 
TABLE OF project_type NOT NULL;
/
-- 步驟三:創建嵌套表類型的數據表
DROP TABLE department PURGE;
CREATE TABLE department(
 did NUMBER,
 deptname VARCHAR2(50) NOT NULL,
 projects project_nested,
 CONSTRAINT pk_did PRIMARY KEY(did)
) NESTED TABLE projects STORE AS project_nested_table;
-- 步驟四:增加測試數據
INSERT INTO department (did,deptname,projects) 
VALUES (10,'甲骨文',
 project_nested(
  project_type(1,'JAVA實戰開發',550,TO_DATE('2004-09-27','YYYY-MM-DD')),
  project_type(2,'Android實戰開發',450,TO_DATE('2010-07-19','YYYY-MM-DD'))
 ));
INSERT INTO department (did,deptname,projects) 
VALUES (20,'ORACLE出版部',
 project_nested(
  project_type(10,'<JAVA開發實戰經典>',79.8,TO_DATE('2008-08-13','YYYY-MM-DD')),
  project_type(11,'<C#開發實戰經典>',69.8,TO_DATE('2010-08-27','YYYY-MM-DD')),
  project_type(12,'<Android開發實戰經典>',88,TO_DATE('2012-03-19','YYYY-MM-DD'))
 ));
COMMIT;


-- ex:定義與嵌套表有關的視圖
DROP VIEW v_department10;
CREATE OR REPLACE VIEW v_department10
AS
 SELECT did, deptname, projects FROM department
 WHERE did=10;
 

-- ex:查看v_department10表中數據
SELECT * FROM v_department10;


-- ex:查看一個部門的全部項目訊息
SELECT * FROM TABLE(
SELECT projects FROM v_department10 WHERE did=10);


-- ex:對視圖進行數據增加
INSERT INTO TABLE(SELECT projects FROM v_department10) 
VALUES (3,'WEB框架應用',600,TO_DATE('2013-02-19','YYYY-MM-DD'));
-- 錯誤報告:SQL 錯誤: ORA-25015: 無法在此巢狀表格視觀表資料欄上執行 DML


-- ex:對視圖進行數據修改
UPDATE TABLE(SELECT projects FROM v_department10) pro SET
VALUE(pro)=project_type(2,'Android高級應用',555,TO_DATE('2013-04-10','YYYY-MM-DD')) 
WHERE pro.projectid=2;
-- 錯誤報告:SQL 錯誤: ORA-25015: 無法在此巢狀表格視觀表資料欄上執行 DML


-- ex:對視圖進行數據刪除
DELETE FROM TABLE(SELECT projects FROM v_department10) pro 
WHERE pro.projectid=2;
-- 錯誤報告:SQL 錯誤: ORA-25015: 無法在此巢狀表格視觀表資料欄上執行 DML


-- 此時增加、修改、刪除都無法操作，如果希望三者可以進行那麼就必須使用替代觸發器
-- 。在Oracle中為了找到標記的數據橫列，提供了一個":parent.欄位"。
-- ex:定義替代觸發器，實現更新
DROP TRIGGER nested_trigger;
CREATE OR REPLACE TRIGGER nested_trigger 
INSTEAD OF INSERT OR UPDATE OR DELETE 
ON NESTED TABLE projects OF v_department10 -- 在視圖的嵌套欄位上
DECLARE  
BEGIN 
 IF INSERTING THEN 
  INSERT INTO TABLE(SELECT projects FROM department WHERE did=:parent.did) 
  VALUES (:new.projectid, :new.projectname, :new.projectfunds, :new.pubdate);
 ELSIF UPDATING THEN 
  UPDATE TABLE(SELECT projects FROM department WHERE did=:parent.did) pro SET
  VALUE(pro)=project_type(
  :new.projectid, 
  :new.projectname, 
  :new.projectfunds, :new.pubdate) 
  WHERE pro.projectid=:old.projectid;
 ELSIF DELETING THEN 
  DELETE FROM TABLE(SELECT projects FROM department WHERE did=:parent.did) pro 
  WHERE pro.projectid=:old.projectid;
 ELSE 
  NULL;
 END IF; 
END;
/


-- ex:對視圖進行數據增加
INSERT INTO TABLE(SELECT projects FROM v_department10) 
VALUES (3,'WEB框架應用',600,TO_DATE('2013-02-19','YYYY-MM-DD'));


-- ex:對視圖進行數據修改
UPDATE TABLE(SELECT projects FROM v_department10) pro SET
VALUE(pro)=project_type(2,'Android高級應用',555,TO_DATE('2013-04-10','YYYY-MM-DD')) 
WHERE pro.projectid=2;


-- ex:對視圖進行數據刪除
DELETE FROM TABLE(SELECT projects FROM v_department10) pro 
WHERE pro.projectid=2;


-- ▲實際上對於替代觸發器，還是不建議過多使用。
--============================================================================--
--                                                                            --
/* ※觸發器-DDL觸發器                                                         */ 
--                                                                            --
--============================================================================--
-- 說明:當創建、修改或者刪除數據庫對象時，也會引起相應的觸發器操作事件，而此時就
-- 可以利用觸發器來對這些數據庫對象的DDL操作進行監控。
/*
DDL觸發器的創建語法:
CREATE [OR REPLACE] TRIGGER 觸發器名稱
[BEFORE|AFTER|INSTEAD OF][DDL事件] ON [DATABASE|SCHEMA]
[WHEN 觸發條件]
[DECLARE]
 [程序聲明部份;] 
BEGIN
 程序代碼部份;
END[觸發器名稱];
/
*/

/*
DDL觸發器支持事件
-------------------------------------------------------------------------
|No.|DDL事件                |觸發時機    |描述                          | 
-------------------------------------------------------------------------
|1  |ALTER                  |BEFORE/AFTER|修改對象的結構時觸發          |
|2  |ANALYZE                |BEFORE/AFTER|分析數據庫對象時觸發          |
|3  |ASSOCIATE STATISTICS   |BEFORE/AFTER|啟動統計數據庫對象時觸發      |
|4  |AUDIT                  |BEFORE/AFTER|開起審核數據庫對象時觸發      |
|5  |COMMENT                |BEFORE/AFTER|為數據庫對象設置註解訊息時觸發|
|6  |CREATE                 |BEFORE/AFTER|創建數據庫對象時觸發          |
|7  |DDL                    |BEFORE/AFTER|針對出現的所有DDL事件觸發     |
|8  |DISASSOCIATE STATISTICS|BEFORE/AFTER|關閉統計數據庫對象時觸發      |
|9  |DROP                   |BEFORE/AFTER|刪除數據庫對象時觸發          |
|10 |GRANT                  |BEFORE/AFTER|用戶授權時觸發                |
|11 |NOAUDIT                |BEFORE/AFTER|禁用審核數據庫對象時觸發      |
|12 |RENAME                 |BEFORE/AFTER|為數據庫對象重命名時觸發      |
|13 |REVOKE                 |BEFORE/AFTER|用戶撤銷權限時觸發            |
|14 |TRUNCATE               |BEFORE/AFTER|截斷數據表時觸發              |
-------------------------------------------------------------------------

常用的事件屬性函數
--------------------------------------------------------------------------------
|No.|事件屬性函數                  |描述                                       |
--------------------------------------------------------------------------------
|1  |ORA_CLIENT_IP_ADDRESS         |用於返回客戶端的IP地址                     |
--------------------------------------------------------------------------------
|2  |ORA_DATABASE_NAME             |用於返回當前數據庫名                       |
--------------------------------------------------------------------------------
|3  |ORA_DICT_OBJ_NAME             |用於返回DDL操作所對應的數據庫對象名        |
--------------------------------------------------------------------------------
|4  |ORA_DICT_OBJ_NAME_LIST        |用於返回字事件中被修改的對象名列表         |
|   |(nameList OUT ORA_NAME_LIST_T)|                                           |
--------------------------------------------------------------------------------
|5  |ORA_DICT_OBJ_OWNER            |用於返回DDL操作所對應的對象所有者名        |
--------------------------------------------------------------------------------
|6  |ORA_DICT_OBJ_OWERR_LIST       |                                           |
|   |(objList OUT ORA_NAME_LIST_T) |用於返回在事件中被修改對象的所有者列表     |
--------------------------------------------------------------------------------
|7  |ORA_DICT_OBJ_TYPE	           |用於返回DDL操作所對應的數據庫對象的類型    |
--------------------------------------------------------------------------------
|8  |ORA_GRANTEE                   |用於返回授權時事件授權者                   |
|   |(nameList OUT ORA_NAME_LIST_T)|                                           |
--------------------------------------------------------------------------------
|9  |ORA_INSTANCE_NUM	           |用於返回歷程號                             |
--------------------------------------------------------------------------------
|10 |ORA_IS_ALTER_COLUMN           |                                           |
|   |(columnName IN VARCHAR2)      |用於監測特定列是否被修改                   |
--------------------------------------------------------------------------------
|11 |ORA_IS_DROP_COLUMN            |                                           |
|   |(columnName IN VARCHAR2)	   |用於檢測特定列是否被刪除                   |
--------------------------------------------------------------------------------
|12 |ORA_IS_SERVERERROR            |                                           |
|   |(errorCode NUMBER)            |用於檢測是否返回了特定ORACLE錯誤           |
--------------------------------------------------------------------------------
|13 |ORA_LOGIN_USER	               |用於返回登錄用戶名                         |
--------------------------------------------------------------------------------
|14 |ORA_SYSEVENT                  |用於返回觸發的類型                         |
--------------------------------------------------------------------------------
|15 |ORA_DES_ENCRYPTED_PASSWORD    |取得加密後的密碼內容，返回的數據類型為     |
|   |                              |VARCHAR2                                   |
--------------------------------------------------------------------------------
|16 |ORA_IS_CREATING_NESTED_TABLE  |如果創建一個嵌套表，返回數據類型為BOOLEAN  |
--------------------------------------------------------------------------------
|17 |ORA_REVOKE                    |返回撤銷的權限或角色列表                   |
|   |(nameList OUT ORA_NAME_LIST_T)|                                           |
--------------------------------------------------------------------------------
|18 |ORA_SERVER_ERROR(point NUMBER)|返回錯誤堆棧訊息中的錯誤號，其中1為錯誤堆棧|
|   |                              |頂端，返回的數據類型為NUMBER               |
--------------------------------------------------------------------------------
|19 |ORA_SERVER_ERROR_MSG          |返回錯誤堆棧訊息中的錯誤訊息，其中1為錯誤堆|
|   |                              |棧頂端，返回的數據類型為VARCHAR2           |
--------------------------------------------------------------------------------
*/


-- ex:禁止scott用戶的所有DDL操作
CREATE OR REPLACE TRIGGER scott_forbid_trigger
BEFORE DDL 
ON SCHEMA 
BEGIN 
 RAISE_APPLICATION_ERROR(-20007,'scott用戶禁止使用任何的DDL操作!');
END;
/


-- ex:由於觸發器的存在，用戶創建序列無法成功
CREATE SEQUENCE orcl_seq;
-- 錯誤報告:SQL 錯誤: ORA-00604: 遞迴 SQL 層次 1 發生錯誤
-- ORA-20007: scott用戶禁止使用任何的DDL操作!


-- ex:建立能夠保存操作各個數據庫對象的日誌
-- 步驟一:創建保存訊息的數據表
DROP TRIGGER scott_forbid_trigger;
DROP TABLE object_log PURGE;
DROP SEQUENCE object_log_seq;
CREATE SEQUENCE object_log_seq;
CREATE TABLE object_log(
 oid NUMBER,
 username VARCHAR2(50) NOT NULL,
 operatedate DATE NOT NULL,
 objecttype VARCHAR2(50) NOT NULL,
 objectowner VARCHAR2(50) NOT NULL,
 CONSTRAINT pk_oid PRIMARY KEY(oid)
);


-- 步驟二:使用sys用戶，創建(簡單的系統級)觸發器進行紀錄
CONN sys/change_on_install AS SYSDBA;
CREATE OR REPLACE TRIGGER object_trigger 
AFTER CREATE OR DROP OR ALTER -- 在資料庫進行DDL操作之後
ON DATABASE 
DECLARE  
BEGIN 
 INSERT INTO c##scott.object_log(
  oid,
  username,
  operatedate,
  objecttype,
  objectowner
 ) 
 VALUES (
  c##scott.object_log_seq.nextval,
  ORA_LOGIN_USER,
  SYSDATE,
  ORA_DICT_OBJ_TYPE,
  ORA_DICT_OBJ_OWNER
 );
END;
/


-- 現在可以針對c##scott用戶下的所有對象進行追蹤。
-- ex:刪除無用數據表
SELECT * FROM tab;
DROP TABLE mytab PURGE;
DROP TABLE advice PURGE;
-- use sys drop table
DROP TABLE c##scott.mydept PURGE;


-- ex:查看訊息表
SELECT * FROM object_log;


-- ex:禁止修改emp表的empno主鍵和dpetno外鍵的定義結構
-- 分析:要進行修改一定使用ALTER語句完成，而修改表的欄位也只有empno和deptno。
-- 如果要知道一個表所有的直行訊息，可以使用all_tab_columns數據字典。
SELECT * FROM all_tab_columns WHERE table_name='EMP' AND owner='C##SCOTT';

CREATE OR REPLACE TRIGGER emp_alter_trigger 
BEFORE ALTER  
ON SCHEMA  
DECLARE 
 -- 操作的所有者及操作的表名稱由外部傳遞
 CURSOR emp_column_cur(
  p_tableOwner all_tab_columns.owner%TYPE,
  p_tableName all_tab_columns.table_name%TYPE
 ) 
 IS 
 SELECT column_name FROM all_tab_columns 
 WHERE owner=p_tableOwner AND table_name=p_tableName;
BEGIN 
 -- 如果操作的是數據表
 IF ORA_DICT_OBJ_TYPE='TABLE' THEN
   FOR empColumnRow 
   IN emp_column_cur(ORA_DICT_OBJ_OWNER, ORA_DICT_OBJ_NAME) LOOP 
    IF ORA_IS_ALTER_COLUMN(empColumnRow.column_name) THEN 
	 -- 如果empno欄位要被修改
	 IF empColumnRow.column_name='EMPNO' THEN 
	  RAISE_APPLICATION_ERROR(-20007,'empno欄位不允許修改');
	 END IF;
	 
	 -- 如果deptno欄位要被修改
	 IF empColumnRow.column_name='DEPTNO' THEN 
	  RAISE_APPLICATION_ERROR(-20008,'deptno欄位不允許修改');
	 END IF;
	END IF;
	
	IF ORA_IS_DROP_COLUMN(empColumnRow.column_name) THEN 
	 -- 如果empno欄位要被刪除
	 IF empColumnRow.column_name='EMPNO' THEN 
	  RAISE_APPLICATION_ERROR(-20009,'empno欄位不允許刪除');
	 END IF;
	 
	 -- 如果deptno欄位要被刪除
	 IF empColumnRow.column_name='DEPTNO' THEN 
	  RAISE_APPLICATION_ERROR(-20010,'deptno欄位不允許刪除');
	 END IF;
	END IF;
   END LOOP;
 END IF;
END;
/


-- ex:測試修改empno欄位
ALTER TABLE emp MODIFY(empno NUMBER(6));
-- 錯誤報告:SQL 錯誤: ORA-00604: 遞迴 SQL 層次 1 發生錯誤
-- ORA-20007: empno欄位不允許修改

-- ex:測試刪除deptno欄位
ALTER TABLE emp DROP COLUMN deptno;
-- 錯誤報告:SQL 錯誤: ORA-00604: 遞迴 SQL 層次 1 發生錯誤
-- ORA-20010: deptno欄位不允許刪除
--============================================================================--
--                                                                            --
/* ※觸發器-系統觸發器                                                        */ 
--                                                                            --
--============================================================================--
-- 說明:系統觸發器用於監視數據庫服務的打開、關閉、錯誤等訊息的取得，或者是監控
-- 用戶的行為操作等。
/*
語法:
CREATE [OR REPLACE] TRIGGER 觸發器名稱
[BEFORE|AFTER][數據庫事件] ON [DATABASE|SCHEMA]
[WHEN 觸發條件]
[DECLARE]
 [程序聲明部份;] 
BEGIN
 程序代碼部份;
END[觸發器名稱];
/

系統觸發器事件:
-------------------------------------------------
|No.|事件       |觸發時機|描述                  |
|1  |STARTUP    |AFTER   |數據庫實例啟動之後觸發|
|2  |SHUTDOWN   |BEFORE  |數據庫實例關閉之前觸發|
|3  |SERVERERROR|AFTER   |出現錯誤時觸發        |
|4  |LOGON      |AFTER   |用戶登入後觸發        |
|5  |LOGOFF     |BEFORE  |用戶註銷前觸發        |
-------------------------------------------------
*/ 

-- ex:登入日誌功能
-- 步驟一:使用sys，創建用戶登入日誌數據表
DROP SEQUENCE user_log_seq;
DROP TABLE user_log PURGE;
CREATE SEQUENCE user_log_seq;
CREATE TABLE user_log(
 logid NUMBER,
 username VARCHAR2(50) NOT NULL,
 logondate DATE,
 logoffdate DATE,
 ip VARCHAR2(20),
 logtype VARCHAR2(20),
 CONSTRAINT pk_logid PRIMARY KEY(logid)
);
-- 步驟二:使用sys，創建用戶登入觸發器
CREATE OR REPLACE TRIGGER logon_trigger 
AFTER LOGON -- 用戶登入後觸發
ON DATABASE 
BEGIN 
 INSERT INTO user_log(logid, username, logondate, ip, logtype)
 VALUES (
  user_log_seq.nextval,
  ORA_LOGIN_USER,
  SYSDATE,
  ORA_CLIENT_IP_ADDRESS,
  'LOGON'
 );
END;
/
-- 步驟三:使用sys，創建用戶註銷觸發器
CREATE OR REPLACE TRIGGER logoff_trigger 
BEFORE LOGOFF -- 用戶註銷前觸發
ON DATABASE 
BEGIN 
 INSERT INTO user_log(logid, username, logoffdate, ip, logtype)
 VALUES (
  user_log_seq.nextval,
  ORA_LOGIN_USER,
  SYSDATE,
  ORA_CLIENT_IP_ADDRESS,
  'LOGOFF'
 );
END;
/
-- 步驟四:sqlplus反覆操作CONN
CONN sys/change_on_install AS SYSDBA;
CONN c##scott/tiger;
SELECT * FROM user_log;


-- 如果要進行數據庫維護，有一大部份是需要經常的進行系統的關閉與重新啟動。
-- ex:系統啟動和關閉日誌功能
-- 步驟一:使用sys，創建數據庫事件紀錄表
DROP SEQUENCE db_event_log_seq;
DROP TABLE db_event_log PURGE;
CREATE SEQUENCE db_event_log_seq;
CREATE TABLE db_event_log(
 eventid NUMBER,
 eventType VARCHAR2(50) NOT NULL, 
 eventDate DATE,
 eventUser VARCHAR2(20), 
 CONSTRAINT pk_eventid PRIMARY KEY(eventid)
);
-- 步驟二:使用sys，創建啟動紀錄的觸發器
CREATE OR REPLACE TRIGGER startup_trigger 
AFTER STARTUP 
ON DATABASE 
BEGIN 
 INSERT INTO db_event_log(eventid, eventType, eventDate, eventUser)
 VALUES (
  db_event_log_seq.nextval,
  'STARTUP',
  SYSDATE,
  ORA_LOGIN_USER
 );
END;
/
-- 步驟三:使用sys，創建關閉紀錄的觸發器
CREATE OR REPLACE TRIGGER shutdown_trigger 
BEFORE SHUTDOWN 
ON DATABASE 
BEGIN 
 INSERT INTO db_event_log(eventid, eventType, eventDate, eventUser)
 VALUES (
  db_event_log_seq.nextval,
  'SHUTDOWN',
  SYSDATE,
  ORA_LOGIN_USER
 );
END;
/
-- 步驟四:使用sys，sqlplus操作停止和啟動數據庫實例指令
--SHUTDOWN ABORT;
SHUTDOWN IMMEDIATE;
STARTUP ;
SELECT * FROM db_event_log;


-- 在進行數據庫的SQL編寫時，經常會出現各種錯誤。
-- ex:錯誤訊息日誌
-- 步驟一:使用sys，創建紀錄錯誤訊息數據表
DROP SEQUENCE db_error_seq;
DROP TABLE db_error PURGE;
CREATE SEQUENCE db_error_seq;
CREATE TABLE db_error(
 eid NUMBER,
 usename VARCHAR2(50), 
 errorDate DATE,
 dbname VARCHAR2(50),
 content CLOB,
 CONSTRAINT pk_eid PRIMARY KEY(eid)
);
-- 步驟二:使用sys，創建觸發器
CREATE OR REPLACE TRIGGER error_trigger 
AFTER SERVERERROR  
ON DATABASE 
BEGIN 
 INSERT INTO db_error(eid, usename, errorDate, dbname, content)
 VALUES (
  db_error_seq.nextval,
  ORA_LOGIN_USER,
  SYSDATE,
  ORA_DATABASE_NAME,
  DBMS_UTILITY.format_error_stack
 );
END;
/
-- 步驟三:使用sys或c##scott編寫錯誤語句
SELECT * FROM orcl;


-- 步驟四:使用sys查看錯誤訊息數據表
SELECT * FROM db_error;
--============================================================================--
--                                                                            --
/* ※觸發器-管理觸發器                                                        */ 
--                                                                            --
--============================================================================--
-- ➤查看觸發器
-- 說明:所有的數據庫對象一定會在數據字典中進行查詢，對於觸發器，用戶同樣可以使用
-- 三個數據字典查看訊息:USER_TRIGGERS、ALL_TRIGGERS、DBA_TRIGGERS。
-- ex:使用c##scott用戶登入，查看user_triggers數據字典
SELECT trigger_name, status, trigger_type, table_name, triggering_event, 
trigger_body FROM user_triggers;


-- ➤禁用/啟用觸發器
-- 說明:當觸發器創建完成之後的默認狀態為啟用，如果要修改觸發器的操作狀態，可以
-- 使用下面的語法操作。
/*
ALTER TRIGGER 觸發器名稱 [DISABLE|ENABLE];
在修改觸發器時提供了兩種觸發器的操作狀態:
①ENABLE(有效狀態):當觸發事件發生時，處於有效狀態的數據庫觸發器將被觸發。
②DISABLE(無效狀態):當觸發事件發生時，處於無效狀態的數據庫觸發器TRIGGER將
不會被觸發，相當於觸發器不存在。

禁用/啟用一張表的全部觸發器
ALTER TABLE [schema.]表名稱 [DISABLE|ENABLE] ALL TRIGGERS;
*/
-- ex:將emp_alter_trigger觸發器修改為禁用狀態
ALTER TRIGGER emp_alter_trigger DISABLE;
SELECT trigger_name, status FROM user_triggers;


-- ex:禁用emp表的全部觸發器
ALTER TABLE emp DISABLE ALL TRIGGERS;
SELECT table_name, trigger_name, status FROM user_triggers;

-- ex:啟用emp表的全部觸發器
ALTER TABLE emp ENABLE ALL TRIGGERS;
SELECT table_name, trigger_name, status FROM user_triggers;


-- ➤刪除觸發器
-- ex:刪除觸發器
DROP TRIGGER emp_alter_trigger;
SELECT table_name, trigger_name, status FROM user_triggers;
--============================================================================--
--                                                                            --
/* ※觸發器-觸發器中調用子程序                                                */ 
--                                                                            --
--============================================================================--
-- 說明:一個觸發器只能夠編寫最多32K大小的代碼，如果此時要編寫的代碼較多，則可以
-- 將這些代碼定義在過程或函數中，觸發器只需要完成調用即可。

-- ex:在每月10號允許辦理新進人員入職，同時入職的員工工資不能超過公司的平均工資
-- 編寫一個過程，實現每月10號的限制
CREATE OR REPLACE PROCEDURE emp_update_date_proc 
AS
 v_currentdate VARCHAR2(20);
BEGIN 
 SELECT TO_CHAR(SYSDATE,'DD') INTO v_currentdate FROM dual;
 IF v_currentdate!='10' THEN 
  RAISE_APPLICATION_ERROR(-20006, '在每月10號才允許辦理新進人員入職');
 END IF;
END;
/
-- 編寫一個函數，查出公司平均工資
CREATE OR REPLACE FUNCTION emp_avg_sal_fun 
RETURN NUMBER 
AS
 v_avgSal emp.sal%TYPE;
BEGIN 
 SELECT AVG(sal) INTO v_avgSal FROM emp; 
 RETURN v_avgSal;
END;
/
-- 在觸發器中使用以上兩個子程序
CREATE OR REPLACE TRIGGER forbid_emp_trigger 
BEFORE INSERT 
ON emp
FOR EACH ROW 
BEGIN 
 -- 調用過程
 emp_update_date_proc;
 
 -- 判斷函數回傳值
 IF :new.sal>emp_avg_sal_fun() THEN 
  RAISE_APPLICATION_ERROR(-20007, '新進人員工資不得高於公司平均工資');
 END IF; 
END;
/
-- 執行增加員工
INSERT INTO emp(empno, ename, job, sal, hiredate, mgr, comm, deptno) 
VALUES (3333, 'KEN', 'CLERK', 8888, SYSDATE, 7369, NULL, 20);
-- 錯誤報告:SQL 錯誤: ORA-20006: 在每月10號才允許辦理新進人員入職
-- 錯誤報告:SQL 錯誤: ORA-20007: 新進人員工資不得高於公司平均工資