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
-- 此時對dpet表的所有修改都會進行紀錄。


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
/* ※觸發器-複合觸發器                                                            */ 
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








