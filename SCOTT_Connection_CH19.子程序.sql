--============================================================================--
--                                                                            --
/* ※子程序                                                                   */
--                                                                            --
--============================================================================--
-- ➤子程序定義
-- 在開發之中經常會出現一些重複的代碼塊，Oracle為了方便管理這些代碼塊，會將其封裝
-- 到一個特定的結構體中，這樣的結構體在Oracle中就被稱為子程序，定義子程序的代碼塊
-- 也將成為Oracle數據庫對象，會將其對象訊息保存在相應的數據字典中。
-- 在Oracle中子程序分為兩種:過程、函數。


-- ➤定義過程
-- 過程指的是在大型數據庫系統中，專門定義的一組SQL語句集，它可以定義用戶操作參數
-- ，並且存在於數據庫之中，當使用時直接調用即可，在Oracle中，可以使用以下的語法來
-- 定義存儲過程。
/*
過程 = 過程的聲明 + PL/SQL塊。

CREATE [OR REPLACE] PROCEDURE 過程名稱([參數名稱 [參數模式] NOCOPY 數據類型
[參數名稱 [參數模式] NOCOPY 數據類型, ...]])
 [AUTHID [DEFINER|CURRENT_USER]]
 AS|IS
  [PRAGMA AUTONOMOUS_TRANSACTION;]
  聲明部份;
BEGIN  
  程序部份;
EXCEPTION  
  異常處理;
END;
/  
*/


-- ex:定義一個過程
CREATE OR REPLACE PROCEDURE orcl_proc 
AS
BEGIN 
 DBMS_OUTPUT.put_line('www.oracle.com');
END;
/


-- 過程定義完之後如果想執行過程，則使用"EXEC 過程名稱"的形式運行。
EXEC orcl_proc;


-- 在PL/SQL中使用過程
DECLARE
BEGIN 
 orcl_proc;
END;
/


-- ex:定義過程，根據員工編號找到員工姓名即工資
CREATE OR REPLACE PROCEDURE get_emp_info_proc(p_eno emp.empno%TYPE)
AS 
 v_ename emp.ename%TYPE;
 v_sal emp.sal%TYPE;
 v_count NUMBER; -- 保存個數
BEGIN 
 -- 根據輸入的員工編號判斷此員工是否存在
 SELECT COUNT(empno) INTO v_count FROM emp WHERE empno=p_eno;
 
 IF v_count=0 THEN -- 沒有員工
  RETURN; -- 結束過程調用
 END IF;
 SELECT ename,sal INTO v_ename,v_sal FROM emp WHERE empno=p_eno;
 DBMS_OUTPUT.put_line('員工編號 : ' || v_empno 
 || ', 員工姓名 : ' || v_ename 
 || ', 薪資 : ' || v_sal );
END;
/
EXEC get_emp_info_proc(7369);


-- ex:利用過程新增部門
CREATE OR REPLACE PROCEDURE dept_insert_proc(
 p_dno dept.deptno%TYPE, 
 p_dna dept.dname%TYPE, 
 p_loc dept.loc%TYPE)
AS
 v_deptCount NUMBER; -- 保存COUNT()函數結果
BEGIN 
 SELECT COUNT(deptno) INTO v_deptCount FROM dept WHERE deptno=p_dno;
 
 IF v_deptCount>0 THEN
  RAISE_APPLICATION_ERROR(-20789,'增加失敗: 該部門已存在。'); 
 ELSE 
  INSERT INTO dept (deptno,dname,loc) VALUES (p_dno,p_dna,p_loc);
  DBMS_OUTPUT.put_line('新部門增加成功。');
 COMMIT;
 END IF;
EXCEPTION 
 WHEN OTHERS THEN 
  DBMS_OUTPUT.put_line('SQLCODE = ' || SQLCODE || ', SQLERRM = ' || SQLERRM);
  ROLLBACK;
END;
/
EXEC dept_insert_proc(80,'ORACEL','加州');
-- 如果創建的過程出現錯誤，使用"SHOW ERRORS"查看錯誤。


-- ➤函數
-- 說明:函數又稱存儲函數，也是一種較為方便的存儲結構，用戶定義的函數可以被SQL語句
-- 或是PL/SQL程序直接進行調用，實際上函數與過程最大的區別在於，函數是可以有返回值
-- 的，而過程只能依靠OUT或IN OUT來返回數據，在Oracle中函數的定義格式如下:
/*
CREATE [OR REPLACE] FUNCTION 函數名([參數,[參數,...]])
RETURN 返回值類型
[AUTHID{DEFINER|CURRENT_USER}]
AS|IS
 [PRAGMA AUTONOMOUS_TRANSACTION;]
  聲明部份;
BEGIN  
  程序部份;
  [RETURN 返回值類型;]
[EXCEPTION  
  異常處理;]
END [函數名];
/ 
*/


-- ex:定義函數
CREATE OR REPLACE FUNCTION get_salary_fun(p_eno emp.empno%TYPE) RETURN NUMBER 
AS 
 v_salary emp.sal%TYPE;
BEGIN 
 SELECT sal+NVL(comm,0) INTO v_salary FROM emp WHERE empno=p_eno;
 RETURN v_salary; -- 返回的數據
END;
/


-- 函數創建成功後，可以在兩個地方上使用，一個是PL/SQL塊，一個是SQL語句。
-- ex:透過PL/SQL塊來進行函數調用
DECLARE 
 v_salary NUMBER; -- 接收函數返回值
BEGIN 
 v_salary := get_salary_fun(7369); -- 調用函數
 DBMS_OUTPUT.put_line('員工7369的工資為: ' || v_salary);
END;
/


-- 或者將以上的PL/SQL塊變為一個過程，利用過程調用。
CREATE OR REPLACE PROCEDURE invoke_proc 
AS
 v_salary NUMBER; -- 接收函數返回值
BEGIN 
 v_salary := get_salary_fun(7369); -- 調用函數
 DBMS_OUTPUT.put_line('員工7369的工資為: ' || v_salary);
END;
/
EXEC invoke_proc;


-- 最方便的驗證方式還是透過SQL查詢。在之前使用過dual虛擬表可以實現函數驗證。
-- ex:利用dual查詢
SELECT get_salary_fun(7369) FROM dual;


-- 以上兩種操作方式是相對而言比較容易的，但是除了此種方式之外還有一種CALL操作。
-- 表示將一個函數的返回值綁定在一個變量上。
-- ex:在sqlplus上，觀察CALL操作
VAR v_salary NUMBER;
CALL get_salary_fun(7369) INTO :v_salary;
PRINT v_salary;


-- ▲在Oracle 12c中，提供了直接定義在SQL中使用的函數。
-- ex:在sqlplus上進行操作
COL isfive FOR A30;
WITH FUNCTION length_five_fun(p_str VARCHAR2) RETURN VARCHAR2 
AS 
BEGIN 
 IF LENGTH(p_str)=5 THEN 
  RETURN p_str || ', 長度是5';
 ELSE
  RETURN p_str || ', 長度不是5';
 END IF;
END;
SELECT ROWNUM, empno, ename, length_five_fun(ename) isfive, sal, comm
FROM emp;
/


-- ➤查詢子程序
-- 當用戶創建過程或函數後，對於數據庫而言就相當於創建一個新的數據庫對象。那麼用戶
-- 可以利用以下的數據字典查看子程序的相關訊息。
-- ①user_procedures:查詢出所有的子程序訊息。
-- ②user_objects:查詢出所有用戶的對象(包括表、索引、序列、子程序等)。
-- ③user_source:查看用戶所有對象的源代碼。
-- ④user_errors:查看所有的子程序錯誤訊息。

-- ex:查詢user_procedure數據字典
SELECT * FROM user_procedures;
SELECT object_name, authid, object_type FROM user_procedures;

-- ex:查詢user_objects數據字典
SELECT * FROM user_objects;
SELECT object_name, object_type, created, timestamp, status 
FROM user_objects
WHERE object_type IN('PROCEDURE','FUNCTION');


-- 在user_objects數據字典中提供一個status欄位，此欄位表示子程序是否可用，VALID
-- (有效)、INVALID(無效)。
-- 一般而言，過程都會與一些數據對象存在某些依賴關係。如果想要知道依賴關係，那麼
-- 可以使用"user_dependencies"數據字典查看。
SELECT * FROM user_dependencies
WHERE referenced_name IN('EMP','DEPT');


-- 因為存在依賴關係，當被依賴對象發生改變時，所附加在子程序的狀態也就變為無效狀
-- 態。
-- ex:將dept表進行修改
ALTER TABLE dept ADD (photo VARCHAR2(50) DEFAULT 'nophoto.jpg');
SELECT object_name, object_type, created, timestamp, status 
FROM user_objects
WHERE object_type IN('PROCEDURE','FUNCTION');
-- 可以發現 DEPT_INSERT_PROC的狀態變為INVALID


-- 若dept表恢復到了原始狀態，子程序依然無法使用，所以只有再重新編譯子程序之後才
-- 可以讓其恢復使用。
-- ex:刪除新增的欄位(photo)
ALTER TABLE dept DROP COLUMN photo;
SELECT object_name, object_type, created, timestamp, status 
FROM user_objects
WHERE object_type IN('PROCEDURE','FUNCTION');
-- 可以發現 DEPT_INSERT_PROC的狀態仍為INVALID


-- ex:重新編譯子程序
ALTER PROCEDURE dept_insert_proc COMPILE;
SELECT object_name, object_type, created, timestamp, status 
FROM user_objects
WHERE object_type IN('PROCEDURE','FUNCTION');
-- 可以發現 DEPT_INSERT_PROC的狀態變為VALID


-- ex:利用user_source查看子程序代碼
SELECT * FROM user_source
WHERE name='ORCL_PROC';
-- 此時會把子程序的相關源代碼進行展示。


-- ➤刪除子程序
-- 刪除過程語法:
-- DROP PROCEDURE 過程名稱;
-- 刪除函數語法:
-- DROP FUNCTION 函數名稱;
-- ex:刪除子程序
DROP PROCEDURE orcl_proc;
DROP FUNCTION get_salary_fun;
SELECT * FROM user_procedures;


-- ➤參數模式
-- 說明:在定義子程序時往往需要接收傳遞的參數，這樣對於形式參數的定義就分為了三類
-- :IN、OUT和IN OUT模式，此三類形式定義如下:
-- ①IN(默認，數值傳遞):在子程序中所作的修改不會影響原始參數內容。
-- ②OUT(空進帶值出):不帶任何參數到子程序中，子程序可以透過此變量將數值返回給調用
-- 處。
-- ③IN OUT(地址傳遞):可以將值傳到子程序中，同時也會將子程序中對變量的修改返回到調
-- 用處。
-- ▲IN就屬於基本數據類型傳遞，IN OUT屬於引用數據類型傳遞。

-- ➤IN模式
-- ex:觀察IN參數模式
CREATE OR REPLACE PROCEDURE in_proc(
 p_paramA IN VARCHAR2,
 p_paramB VARCHAR2 -- 默認為IN模式
) 
AS
BEGIN 
 DBMS_OUTPUT.put_line('執行 in_proc過程: p_paramA = ' || p_paramA);
 DBMS_OUTPUT.put_line('執行 in_proc過程: p_paramB = ' || p_paramB);
END;
/


-- ex:在PL/SQL塊調用IN過程
DECLARE
 v_titleA VARCHAR2(50) := 'JAVA開發實戰經典';
 v_titleB VARCHAR2(50) := 'Android開發實戰經典';
BEGIN 
 in_proc(v_titleA,v_titleB);
END;
/
-- 使用IN模式接收的參數是無法回傳的。在使用IN模式的時候還有一個DEFAULT定義，它
-- 可以用來定義參數的默認值。


-- ex:定義參數默認值
CREATE OR REPLACE PROCEDURE in_proc(
 p_paramA IN VARCHAR2,
 p_paramB VARCHAR2 DEFAULT 'Oracle開發實戰經典' -- 默認為IN模式
) 
AS
BEGIN 
 DBMS_OUTPUT.put_line('執行 in_proc過程: p_paramA = ' || p_paramA);
 DBMS_OUTPUT.put_line('執行 in_proc過程: p_paramB = ' || p_paramB);
END;
/


-- 由於過程的第2個參數存在默認值，所以調用的時候可以少傳一個參數。
-- ex:在PL/SQL塊調用過程
DECLARE
 v_titleA VARCHAR2(50) := 'JAVA開發實戰經典'; 
BEGIN 
 in_proc(v_titleA);
END;
/


-- 除了在過程中使用IN模式之外，函數也是可以使用IN模式。
-- ex:在函數中使用IN模式
CREATE OR REPLACE FUNCTION in_fun(
 p_paramA IN VARCHAR2,
 p_paramB VARCHAR2 DEFAULT 'Oracle開發實戰經典' -- 默認為IN模式
) RETURN VARCHAR2
AS
BEGIN 
 RETURN 'Android開發實戰經典';
END;
/
-- 函數是可以有返回值的，所以這時參數也只是為了驗證IN模式。


-- ex:在PL/SQL塊調用IN函數
DECLARE
 v_titleA VARCHAR2(50) := 'JAVA開發實戰經典';
 v_return VARCHAR2(50);
BEGIN 
 v_return := in_fun(v_titleA); -- 有默認值
 DBMS_OUTPUT.put_line('in_fun()函數返回值: ' || v_return);
END;
/


-- ➤OUT模式
-- ex:觀察OUT參數模式
CREATE OR REPLACE PROCEDURE out_proc(
 p_paramA OUT VARCHAR2,
 p_paramB OUT VARCHAR2
) 
AS
BEGIN 
 DBMS_OUTPUT.put_line('執行 out_proc過程: p_paramA = ' || p_paramA);
 DBMS_OUTPUT.put_line('執行 out_proc過程: p_paramB = ' || p_paramB);
 p_paramA := 'Android開發實戰經典';
 p_paramB := 'JAVA開發實戰經典';
END;
/


-- ex:在PL/SQL塊調用OUT過程
DECLARE
 v_titleA VARCHAR2(100) := '隨便寫，只為接收參數';
 v_titleB VARCHAR2(100) := '內容不會傳遞';
BEGIN 
 out_proc(v_titleA,v_titleB);
 DBMS_OUTPUT.put_line('調用out_proc()過程後變量內容: v_titleA = ' || v_titleA);
 DBMS_OUTPUT.put_line('調用out_proc()過程後變量內容: v_titleB = ' || v_titleB);
END;
/
-- 在調用out_proc()過程的時的確世傳遞了參數內容，但由於OUT本身的特性，所以數據根
-- 本就不會被接收到。


-- 除了在過程中使用OUT模式之外，函數也是可以使用OUT模式。
-- ex:在函數中使用OUT模式
CREATE OR REPLACE FUNCTION out_fun(
 p_paramA OUT VARCHAR2,
 p_paramB OUT VARCHAR2
) RETURN VARCHAR2
AS
BEGIN 
 p_paramA := 'Android開發實戰經典';
 p_paramB := 'JAVA開發實戰經典';
 RETURN 'Oracle開發實戰經典';
END;
/


-- ex:在PL/SQL塊調用OUT函數
DECLARE
 v_titleA VARCHAR2(100) := '隨便寫，只為接收參數';
 v_titleB VARCHAR2(100) := '內容不會傳遞';
 v_return VARCHAR2(100); -- 接收返回數據
BEGIN 
 v_return := out_fun(v_titleA,v_titleB);
 DBMS_OUTPUT.put_line('調用out_fun()函數後變量內容: v_titleA = ' || v_titleA);
 DBMS_OUTPUT.put_line('調用out_fun()函數後變量內容: v_titleB = ' || v_titleB);
 DBMS_OUTPUT.put_line('調用out_fun()函數返回值: v_return = ' || v_return);
END;
/


-- ➤IN OUT模式
-- 簡述:相當於IN與OUT兩種模式結合，利用IN可以接收的特性以及OUT只能返回不能接收的
-- 特性。
-- ex:觀察IN OUT參數模式
CREATE OR REPLACE PROCEDURE inout_proc(
 p_paramA IN OUT VARCHAR2,
 p_paramB IN OUT VARCHAR2 -- IN OUT模式
) 
AS
BEGIN 
 DBMS_OUTPUT.put_line('執行 inout_proc過程: p_paramA = ' || p_paramA);
 DBMS_OUTPUT.put_line('執行 inout_proc過程: p_paramB = ' || p_paramB);
 p_paramA := 'Android開發實戰經典';
 p_paramB := 'JAVA開發實戰經典';
END;
/


-- ex:在PL/SQL塊調用IN OUT過程
DECLARE
 v_titleA VARCHAR2(100) := 'JAVASE基礎入門';
 v_titleB VARCHAR2(100) := 'JAVAEE基礎入門';
BEGIN 
 inout_proc(v_titleA,v_titleB);
 DBMS_OUTPUT.put_line('調用inout_proc()過程後變量內容: v_titleA = ' || v_titleA);
 DBMS_OUTPUT.put_line('調用inout_proc()過程後變量內容: v_titleB = ' || v_titleB);
END;
/


-- ➤參數模式應用
-- ex:編寫一個過程，實現部門數據增加。需要告訴用戶增加成功與否，所以可以使用一個
-- IN OUT作為判斷標記，如果是0表示增加成功，如果是-1表示增加失敗。
CREATE OR REPLACE PROCEDURE dept_insert_proc(
 p_dno dept.deptno%TYPE,
 p_dna dept.dname%TYPE,
 p_dloc dept.loc%TYPE,
 p_result OUT NUMBER -- 此為操作標記
) 
AS
 v_deptCount NUMBER; -- 保存COUNT()函數結果
BEGIN 
 SELECT COUNT(deptno) INTO v_deptCount FROM dept WHERE deptno=p_dno;
 IF v_deptCount>0 THEN
   p_result := -1; -- 修改返回標記
 ELSE 
  INSERT INTO dept (deptno,dname,loc) VALUES (p_dno,p_dna,p_dloc);
  p_result := 0;
  COMMIT;
 END IF;
END;
/


-- ex:方式一，在PL/SQL塊調用過程
DECLARE
 v_result NUMBER; -- 接收結果 
BEGIN 
 dept_insert_proc(82,'GOOGLE','東岸',v_result); -- 調用過程
 IF v_result = 0 THEN 
  DBMS_OUTPUT.put_line('部門新增成功。');
 ELSE
  DBMS_OUTPUT.put_line('部門新增失敗。');
 END IF;
END;
/


-- ex:方式二，在sqlplus上進行操作，直接定義變量調用過程
VAR v_result NUMBER; -- 接收結果 
EXEC dept_insert_proc(83,'oracle','加州',:v_result); -- 調用過程
PRINT v_result;


-- 如過不使用過程而使用函數那麼會更加方便，因為函數可以直接將操作的結果返回。
-- ex:改用函數實現同樣功能
CREATE OR REPLACE FUNCTION dept_insert_fun(
 p_dno dept.deptno%TYPE,
 p_dna dept.dname%TYPE,
 p_dloc dept.loc%TYPE
) RETURN NUMBER 
AS
 v_deptCount NUMBER; -- 保存COUNT()函數結果
BEGIN 
 SELECT COUNT(deptno) INTO v_deptCount FROM dept WHERE deptno=p_dno;
 IF v_deptCount>0 THEN
   RETURN -1; -- 修改返回標記
 ELSE 
  INSERT INTO dept (deptno,dname,loc) VALUES (p_dno,p_dna,p_dloc);
  COMMIT;
  RETURN 0;  
 END IF;
END;
/


-- ex:在PL/SQL塊調用函數
DECLARE
 v_result NUMBER; -- 接收結果 
BEGIN 
  v_result := dept_insert_fun(83,'GOOGLE','東岸'); -- 調用函數
 IF v_result = 0 THEN 
  DBMS_OUTPUT.put_line('部門新增成功。');
 ELSE
  DBMS_OUTPUT.put_line('部門新增失敗。');
 END IF;
END;
/


-- ➤子程序嵌套
-- 簡述:在一個子程序中也可以嵌套其他子程序，就好比內部的PL/SQL塊。相當於現在定義
-- 的內部子程序。
-- ex:定義子程序嵌套
CREATE OR REPLACE PROCEDURE dept_insert_proc(
 p_dno dept.deptno%TYPE,
 p_dna dept.dname%TYPE,
 p_dloc dept.loc%TYPE,
 p_result OUT NUMBER
) 
AS
 v_deptCount NUMBER; -- 保存COUNT()函數結果
 
 -- 定義內部子程序
 -- 查詢部門數量過程
 PROCEDURE get_dept_count_proc(
  p_temp dept.deptno%TYPE,
  p_count OUT NUMBER -- 返回統計結果
  )
 AS 
 BEGIN 
  SELECT COUNT(deptno) INTO p_count FROM dept WHERE deptno=p_temp; -- 統計訊息
 END;
 
 -- 新增部門紀錄過程
 PROCEDURE inster_operate_proc(
  p_temp_dno dept.deptno%TYPE,
  p_temp_dna dept.dname%TYPE,
  p_temp_dloc dept.loc%TYPE,
  p_count NUMBER,
  p_flag OUT NUMBER
  )
 AS 
 BEGIN 
  IF p_count>0 THEN 
   p_flag := -1;
  ELSE
   INSERT INTO dept (deptno,dname,loc) 
   VALUES (p_temp_dno,p_temp_dna,p_temp_dloc);
   p_flag := 0;
   COMMIT;
  END IF;
 END;
BEGIN 
 get_dept_count_proc(p_dno,v_deptCount); -- 查詢部門個數
 inster_operate_proc(p_dno,p_dna,p_dloc,v_deptCount,p_result); -- 新增部門
END;
/


-- ex:在PL/SQL塊調用嵌套過程
DECLARE
 v_result NUMBER; -- 接收結果 
BEGIN 
  dept_insert_proc(83,'GOOGLE','東岸',v_result); -- 調用過程
 IF v_result = 0 THEN 
  DBMS_OUTPUT.put_line('部門新增成功。');
 ELSE
  DBMS_OUTPUT.put_line('部門新增失敗。');
 END IF;
END;
/
-- ▲透過內部子程序的劃分，可以讓功能更明確。但是這種內部的結構較混亂。如果可以
-- 不建議使用。


-- ex:(簡化子程序嵌套)內部程序屬性使用外部屬性
CREATE OR REPLACE PROCEDURE dept_insert_proc(
 p_dno dept.deptno%TYPE,
 p_dna dept.dname%TYPE,
 p_dloc dept.loc%TYPE,
 p_result OUT NUMBER
) 
AS
 v_deptCount NUMBER; -- 保存COUNT()函數結果
 
 -- 定義內部子程序
 -- 查詢部門數量過程
 PROCEDURE get_dept_count_proc
 AS 
 BEGIN 
  SELECT COUNT(deptno) INTO v_deptCount FROM dept WHERE deptno=p_dno; -- 統計訊息
 END;
 
 -- 新增部門紀錄過程
 PROCEDURE inster_operate_proc
 AS 
 BEGIN 
  IF v_deptCount>0 THEN 
   p_result := -1;
  ELSE
   INSERT INTO dept (deptno,dname,loc) 
   VALUES (p_dno,p_dna,p_dloc);
   p_result := 0;
   COMMIT;
  END IF;
 END;
BEGIN 
 get_dept_count_proc; -- 查詢部門個數
 inster_operate_proc; -- 新增部門
END;
/


-- ex:在PL/SQL塊調用嵌套過程
DECLARE
 v_result NUMBER; -- 接收結果 
BEGIN 
  dept_insert_proc(83,'GOOGLE','東岸',v_result); -- 調用過程
 IF v_result = 0 THEN 
  DBMS_OUTPUT.put_line('部門新增成功。');
 ELSE
  DBMS_OUTPUT.put_line('部門新增失敗。');
 END IF;
END;
/


-- 如果定義了內部結構那麼一定會存在一些限制，關於執行的先後關係問題。現在定義了兩
-- 個內部子程序，但是這兩個子程序之間存在互相調用的情況。
-- ex:錯誤的程序
DECLARE 
 PROCEDURE a_proc(p_paramA NUMBER)
 AS
 BEGIN 
  DBMS_OUTPUT.put_line('A過程，p_paramA = ' || p_paramA);
  b_proc('www.google.com'); -- 調用B過程
 END;
 
 PROCEDURE b_proc(p_paramB VARCHAR2)
 AS
 BEGIN 
  DBMS_OUTPUT.put_line('B過程，p_paramB = ' || p_paramB);
  a_proc(100); -- 調用A過程
 END;
BEGIN
 NULL; 
END;
/
-- 錯誤報告:ORA-06550: 第 6 行, 第 3 個欄位: PLS-00313: 此範疇沒有宣告 'B_PROC'
-- 此時編譯十一定會出現錯誤，因為有一個順序過程，所以子程序嵌套互相調用時，就必須
-- 採用前導聲明方式來解決問題。


-- ex:使用前導聲明
DECLARE 
 PROCEDURE b_proc(p_paramB VARCHAR2); -- 前導聲明
 PROCEDURE a_proc(p_paramA NUMBER)
 AS
 BEGIN 
  DBMS_OUTPUT.put_line('A過程，p_paramA = ' || p_paramA);
  b_proc('www.google.com'); -- 調用B過程
 END;
 
 PROCEDURE b_proc(p_paramB VARCHAR2)
 AS
 BEGIN 
  DBMS_OUTPUT.put_line('B過程，p_paramB = ' || p_paramB);
  a_proc(100); -- 調用A過程
 END;
BEGIN
 NULL; 
END;
/


-- 而進行子程序嵌套後，也同時存在重載問題。
-- ex:實現過程重載
DECLARE  
 PROCEDURE get_dept_info_proc(p_deptno dept.deptno%TYPE)
 AS
 BEGIN 
  DBMS_OUTPUT.put_line('部門編號: ' || p_deptno);
 END;
 
 PROCEDURE get_dept_info_proc(p_dname dept.dname%TYPE)
 AS
 BEGIN 
  DBMS_OUTPUT.put_line('部門名稱: ' || p_dname);
 END;
BEGIN
 get_dept_info_proc(30);
 get_dept_info_proc('SALES');
END;
/
-- 子程序重載後在調用時會會自動根據參數的類型及個數的不同執行不同的程序體。
-- 以上全都是針對過程的操作，對於函數也可以進行內部函數的定義。


-- 過程的內部子程序都是使用基本類型返回，下面操作函數的內部子程序集合數據類型返回
-- ex:操作函數內部子程序，嵌套表集合數據
DECLARE 
 TYPE emp_nested IS TABLE OF emp%ROWTYPE; -- 定義簡單嵌套表類型
 v_emp_return emp_nested;
 FUNCTION dept_emp_fun(
  p_dno emp.deptno%TYPE  
  ) RETURN emp_nested  
 AS 
  v_emp_temp emp_nested;
 BEGIN 
  -- 所有emp的數據都保存在v_emp_temp集合(嵌套表)裡面
  SELECT * BULK COLLECT INTO v_emp_temp FROM emp WHERE deptno=p_dno;
  RETURN v_emp_temp; -- 返回emp的數據集合
 END; 
BEGIN 
 v_emp_return := dept_emp_fun(10); -- 查詢10部門的集合結果
 FOR i IN v_emp_return.FIRST .. v_emp_return.LAST LOOP   
  DBMS_OUTPUT.put_line('部門編號: ' || v_emp_return(i).empno 
  || ', 姓名: ' || v_emp_return(i).ename 
  || ', 職稱: ' || v_emp_return(i).job 
  || ', 薪資: ' || v_emp_return(i).sal);
 END LOOP;
EXCEPTION
 WHEN OTHERS THEN 
  DBMS_OUTPUT.put_line('此部門沒有員工');
END;
/
-- 這種返回集合類型現在只能夠在內部結構上使用。


-- ➤遞歸操作
-- 說明:在Oracle中函數本身依然支持遞歸調用操作，即:一個函數可以繼續調用函數，而想
-- 實現這樣的遞歸操作，須有兩個前提:
-- ①需要增加函數遞歸調用結束的操作，如果沒有此方式會出現內存溢出的問題。
-- ②在每次函數進行遞歸調用時，都需要修改傳遞的參數值。
-- ▲遞歸在開發中盡量不要使用。
-- ex:利用遞歸操作實現數據累加
DECLARE 
 v_sum NUMBER;
 FUNCTION add_fun(
  p_num NUMBER
  ) RETURN NUMBER   
 AS   
 BEGIN 
  IF p_num=1 THEN
   RETURN 1; -- 結束條件
  ELSE 
   RETURN p_num+add_fun(p_num-1); -- ex:p_num = 3, 3 + ( 2 + ( 1 )) 
  END IF;
 END; 
BEGIN 
 v_sum := add_fun(100); -- 累加
 DBMS_OUTPUT.put_line('累加結果: ' || v_sum);
END;
/


-- ➤NOCOPY選項
-- 說明:在默認情況下PL/SQL程序中對於IN模式傳遞的參數採用的都是引用傳遞方式，所以
-- 其性能較高。而對於OUT或IN OUT模式傳遞參數時採用的是數值傳遞，在傳遞時需要將實
-- 參數拷貝一份給型參，這樣做主要是方便型參對數據的操作，而在過程結束之後，被賦
-- 予OUT或IN OUT型參上的值會賦值回對應的實參。
-- 由於OUT和IN OUT會將操作的數據進行複製，所以當傳遞數據較大時(例如:集合、紀錄等
-- )，那麼這一複製的過程就會變得很長，也會消耗大量的內存空間，而為了防止這種情況
-- 的出現，在定義過程參數時，可以使用NOCOPY選項，將OUT或IN OUT的值傳遞變為引用傳
-- 遞。
-- NOCOPY語法:
-- 參數名稱 [參數模式] NOCOPY 數據類型;


-- ex:驗證NOCOPY程序
DECLARE 
 TYPE dept_nested IS TABLE OF dept%ROWTYPE; -- 定義簡單嵌套表類型
 v_dept dept_nested;
 --PROCEDURE useNocopy_proc(p_temp IN OUT dept_nested)
 PROCEDURE useNocopy_proc(p_temp IN OUT NOCOPY dept_nested)
 AS 
 BEGIN 
  NULL;
 END; 
BEGIN 
 SELECT * BULK COLLECT INTO v_dept FROM dept; -- 取得全部數據
 v_dept.EXTEND(2000000,1); -- 擴充集合
 /*
 FOR i IN v_dept.FIRST .. v_dept.LAST LOOP 
  DBMS_OUTPUT.put_line(v_dept(i).dname);
 END LOOP;
 */
 useNocopy_proc(v_dept);
END;
/


-- 使用NOCOPY選樣，即使出現錯誤，NOCOPY也可以自動處理。
-- ex:觀察NOCOPY操作
DECLARE 
 v_varA NUMBER := 10;
 v_varB NUMBER := 20;
 PROCEDURE change_proc(
  p_paramINOUT IN OUT NUMBER,
  p_paramNOCOPY IN OUT NOCOPY NUMBER
 )
 AS   
 BEGIN 
  p_paramINOUT := 100; -- 修改參數內容
  p_paramNOCOPY := 100; -- 修改參數內容
  RAISE_APPLICATION_ERROR(-20001,'測試NOCOPY。');
 END;
BEGIN 
 DBMS_OUTPUT.put_line('<過程調用前> v_varA = ' || v_varA 
 || ', v_varB = ' || v_varB);
 BEGIN 
  change_proc(v_varA,v_varB); -- 傳遞參數
 EXCEPTION
  WHEN OTHERS THEN
   DBMS_OUTPUT.put_line('SQLCODE: ' || SQLCODE || ', SQLERRM: ' || SQLERRM);
 END; 
 DBMS_OUTPUT.put_line('<過程調用後> v_varA = ' || v_varA 
 || ', v_varB = ' || v_varB);
END;
/
/*
匿名區塊已完成
<過程調用前> v_varA = 10, v_varB = 20
SQLCODE: -20001, SQLERRM: ORA-20001: 測試NOCOPY。
<過程調用後> v_varA = 10, v_varB = 100

可以發現使用了NOCOPY參數模式後，即使程序之中出現異常，那麼所修改的內容也可以正
常的返回。
*/


-- ➤自治事務
-- 說明:在Oracle中每一個SESSION都擁有獨立的事務，而在一個事務處理過程之中都會執行
-- 一系列SQL更新操作，這些都受到一個整體的事務控制，其他用戶如果要進行操作則必須
-- 在執行COMMIT或ROLLBACK之後才可以。但是如果現在開發的子程序中需要進行獨立的子事
-- 務處理，並且在此事務處理的過程中執行的COMMIT或ROLLBACK不影響整體主事務，那麼就
-- 需要透過自治事務進行控制。
-- ex:觀察自治事務處理
DECLARE 
 PROCEDURE dept_insert_proc
 AS
  PRAGMA AUTONOMOUS_TRANSACTION; -- 自治事務聲明 
 BEGIN 
  INSERT INTO dept(deptno,dname,loc) VALUES (60,'google','紐約');
  COMMIT; -- 提交自治事務(主事務被掛起)
 END;
BEGIN 
 INSERT INTO dept(deptno,dname,loc) VALUES (50,'googleIT','墨爾本');
 dept_insert_proc; -- 調用過程，裡面會啟動子事務
 ROLLBACK; -- 回滾主事務
END;
/
-- 現在50部門的訊息使用了ROLLBACK進行回滾，所以主事務中數據沒有更新，但是子事務不
-- 受主事務的控制。


-- ➤子程序權限
-- 說明:在Oracle中每一個子程序都是一個Oracle對象，但不同用戶之間的子程序如果要進
-- 行訪問，則必須授權。如:現在在scott用戶下建立一個子程序bonus_proc的子程序，如
-- 果想讓其他用戶使用此子程序，則必須為操作用戶授予EXECUTE的執行權限。
-- ex:採用實際操作進行完整說明
-- 第一步:使用sys登入
CONN sys/change_on_install AS SYSDBA;

-- 第二步:創建一個c##testuser01用戶，密碼設置testuser
CREATE USER c##testuser01 IDENTIFIED BY testuser01;
ALTER USER c##testuser01 QUOTA 20M ON users; -- 設置表空間容量

-- 第三步:使用角色為用戶授權
GRANT CONNECT, RESOURCE TO c##testuser01;

-- 第四步:使用c##scott創建過程
CREATE OR REPLACE PROCEDURE bonus_proc 
AS 
BEGIN 
 INSERT INTO bonus(ename,job,sal,comm) VALUES('user01','程序員',3000,1000);
 COMMIT;
END;
/
-- 在c##scott用戶下存在bouns表，此過程屬於c##scott用戶的。

-- 第五步:由sys用戶將bouns_proc的執行權限授予c##testuser01用戶
GRANT EXECUTE ON c##scott.bonus_proc TO c##testuser01;
/*
現在情況如下:
 1.c##scott用戶下存在一張bonus表和一個過程bonus_proc。
 2.c##testuser01用戶具備了bonus_proc過程的使用權限。
*/

-- 第六步:在c##testuser01用戶下執行c##scott.bonus_proc的過程
EXEC c##scott.bonus_proc;
-- 此時過程執行完畢，但在c##testuser01用戶下並不存在bonus表。發現c##testuser01操
-- 作完的過程數據保存在c##scott.bonus表中。目前的情況是默認的資源還是創建者本人
-- 的。

-- 第七步:創建與c##scott.bonus同樣結構的表
DROP TABLE bonus PURGE;
CREATE TABLE bonus (
    ename VARCHAR2(10),
    job VARCHAR2(9),
    sal NUMBER,
    comm NUMBER
);
-- 即使在c##testuser01用戶下創建了bouns表後執行c##scott.bonus_proc的過程也不會保
-- 存在此表中。因為現在bonus_proc的權限就是DEFINER，表示由創建者定義，所以如果希
-- 望由不同的使用者可以保存到自己的資源表中，那麼就需要將其修改為CURRENT_USER選
-- 項。


-- ex:修改c##scott.bonus_proce過程定義，主要是修改權限
-- 1.在c##scott用戶重新執行(編譯)
CREATE OR REPLACE PROCEDURE bonus_proc 
AUTHID CURRENT_USER 
AS 
BEGIN 
 INSERT INTO bonus(ename,job,sal,comm) VALUES('user01','程序員',3000,1000);
 COMMIT;
END;
/
-- 2.在c##testuser01用戶操作c##scott.bonus_proc
EXEC c##scott.bonus_proc;
-- 這樣一來，雖然在不同的用戶中，但是卻可以在自己的資源表中實現數據的更新操作。




























