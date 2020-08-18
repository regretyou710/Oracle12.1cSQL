--============================================================================--
--                                                                            --
/* ※集合-紀錄類型                                                            */
--                                                                            --
--============================================================================--
-- ➤定義紀錄類型
/*
TYPE 類型名稱 IS RECORD(
 成員名稱 數據類型[[NOT NULL][:=默認值]表達式],
 ...
 成員名稱 數據類型[[NOT NULL][:=默認值]表達式]
)
*/
-- ex:操作定義紀錄類型
-- 定義前:
DECLARE
 v_emp_empno emp.empno%TYPE;
 v_emp_ename emp.ename%TYPE;
 v_emp_job emp.job%TYPE;
 v_emp_hiredate emp.hiredate%TYPE;
 v_emp_sal emp.sal%TYPE;
 v_emp_comm emp.comm%TYPE;
BEGIN
 v_emp_empno := &inputEmpno;
 SELECT ename, job, hiredate, sal, comm INTO 
 v_emp_ename, v_emp_job, v_emp_hiredate, v_emp_sal, v_emp_comm
 FROM emp WHERE empno=v_emp_empno;
 DBMS_OUTPUT.put_line('員工編號: ' || v_emp_empno 
 || ', 姓名: ' || v_emp_ename 
 || ', 職位: ' || v_emp_job 
 || ', 僱用日期: ' || TO_CHAR(v_emp_hiredate,'YYYY-MM-DD') 
 || ', 基本工資: ' || v_emp_sal 
 || ', 佣金: ' || v_emp_comm);
EXCEPTION
 WHEN OTHERS THEN
 -- 1.查詢不存在員工編號發生異常被捕獲
 -- 2.捕獲後拋出自定義異常，再次被捕獲並顯示自定義異常內容
  RAISE_APPLICATION_ERROR(-20007,'此雇員訊息不存在');
END;
/
-- 定義後:
DECLARE
 v_emp_empno emp.empno%TYPE;
 TYPE emp_type IS RECORD(
  ename emp.ename%TYPE,
  job emp.job%TYPE,
  hiredate emp.hiredate%TYPE,
  sal emp.sal%TYPE,
  comm emp.comm%TYPE);
  v_emp emp_type; -- 定義一個複合類型
BEGIN
 v_emp_empno := &inputEmpno;
 SELECT ename, job, hiredate, sal, comm INTO v_emp 
 FROM emp WHERE empno=v_emp_empno;
 DBMS_OUTPUT.put_line('員工編號: ' || v_emp_empno
 || ', 姓名: ' || v_emp.ename 
 || ', 職位: ' || v_emp.job 
 || ', 僱用日期: ' || TO_CHAR(v_emp.hiredate,'YYYY-MM-DD') 
 || ', 基本工資: ' || v_emp.sal 
 || ', 佣金: ' || v_emp.comm);
EXCEPTION
 WHEN OTHERS THEN
 -- 1.查詢不存在員工編號發生異常被捕獲
 -- 2.捕獲後拋出自定義異常，再次被捕獲並顯示自定義異常內容
  RAISE_APPLICATION_ERROR(-20007,'此雇員訊息不存在');
END;
/


-- 雖然PL/SQL中提供了ROWTYPE操作，但是ROWTYPE指能夠根據自己有的表來決定複合類型
-- ，而紀錄類型可以由用戶自己定義組成。
-- 除了可以透過查詢設置內容外，也可以直接利用紀錄類型的變量操作裡面的屬性。


-- ex:直接操作紀錄類型數據
DECLARE
 TYPE dept_type IS RECORD(
  deptno dept.deptno%TYPE :=80,
  dname dept.dname%TYPE,
  loc dept.loc%TYPE
 );
 v_dept dept_type;
BEGIN
 v_dept.dname := 'Oracle'; -- 為紀錄類型成員賦值
 v_dept.loc := '美國'; -- 為紀錄類型成員賦值
 DBMS_OUTPUT.put_line('部門編號: ' || v_dept.deptno 
 || ', 名稱: ' || v_dept.dname 
 || ', 位置: ' || v_dept.loc);
END;
/
-- 此時沒有透過查詢，而是直接聲明變量之後位屬性賦值完成的。


-- ➤嵌套紀錄類型
-- ex:操作嵌套紀錄類型
DECLARE
 TYPE dept_type IS RECORD(
  deptno dept.deptno%TYPE :=80,
  dname dept.dname%TYPE,
  loc dept.loc%TYPE
 );
 TYPE emp_type IS RECORD(
  empno emp.empno%TYPE,
  ename emp.ename%TYPE,
  job emp.job%TYPE,
  hiredate emp.hiredate%TYPE,
  sal emp.sal%TYPE,
  comm emp.comm%TYPE,
  dept dept_type);  
  v_emp emp_type;
BEGIN
 SELECT e.empno, e.ename, e.job, e.hiredate, e.sal, e.comm, 
 d.deptno, d.dname, d.loc 
 INTO v_emp.empno, v_emp.ename, v_emp.job, v_emp.hiredate, v_emp.sal, 
 v_emp.comm, v_emp.dept.deptno, v_emp.dept.dname, v_emp.dept.loc 
 FROM emp e, dept d
 WHERE e.deptno=d.deptno(+) AND e.empno=7369;
 DBMS_OUTPUT.put_line('員工編號: ' || v_emp.empno
 || ', 姓名: ' || v_emp.ename 
 || ', 職位: ' || v_emp.job 
 || ', 僱用日期: ' || TO_CHAR(v_emp.hiredate,'YYYY-MM-DD') 
 || ', 基本工資: ' || v_emp.sal 
 || ', 佣金: ' || NVL(v_emp.comm,0)); 
 DBMS_OUTPUT.put_line('部門編號: ' || v_emp.dept.deptno 
 || ', 名稱: ' || v_emp.dept.dname 
 || ', 位置: ' || v_emp.dept.loc);
END;
/
-- 這個是以一種物件導向的方式進行操作的。


-- 對於紀錄類型除了保存數據之外，最大的特徵還在於可以直接利用紀錄類型進行數據操
-- 作。
-- note:增加數據過程中，紀錄類型內容中欄位定義的順序要和表中的欄位順序保持一致
-- ex:利用紀錄賴型保存數據，實現數據的增加
DECLARE
 TYPE dept_type IS RECORD(
  deptno dept.deptno%TYPE,
  dname dept.dname%TYPE,
  loc dept.loc%TYPE
 );
 v_dept dept_type;
BEGIN
 v_dept.dname := 'Oracle'; -- 為紀錄類型成員賦值
 v_dept.loc := '美國'; -- 為紀錄類型成員賦值
 v_dept.deptno := 80;
 INSERT INTO dept VALUES v_dept; -- 直接插入紀錄類型數據
 DBMS_OUTPUT.put_line('部門編號: ' || v_dept.deptno 
 || ', 名稱: ' || v_dept.dname 
 || ', 位置: ' || v_dept.loc);
END;
/
ROLLBACK;


-- ex:利用紀錄賴型保存數據，實現數據的更新
DECLARE
 TYPE dept_type IS RECORD(
  deptno dept.deptno%TYPE,
  dname dept.dname%TYPE,
  loc dept.loc%TYPE
 );
 v_dept dept_type;
BEGIN
 v_dept.dname := 'OracleJAVA'; -- 為紀錄類型成員賦值
 v_dept.loc := '美國'; -- 為紀錄類型成員賦值
 v_dept.deptno := 80;
 UPDATE dept SET ROW=v_dept WHERE deptno=v_dept.deptno;
 DBMS_OUTPUT.put_line('部門編號: ' || v_dept.deptno 
 || ', 名稱: ' || v_dept.dname 
 || ', 位置: ' || v_dept.loc);
END;
/
ROLLBACK;
-- 語句中使用到ROW，是按照一橫列更新，就是按照部門的紀錄類型實現更新。
--============================================================================--
--                                                                            --
/* ※集合-索引表                                                              */
--                                                                            --
--============================================================================--
-- 說明:索引表類似於程式語言中的陣列，可以保存多個數據，並且透過下標來訪問每一個
-- 數據，但在Oracle中可用來定義索引表下標的數據類型可以是整數也可以是字串。
-- 但是在Oracle之中定義的索引表與程序中的陣列還有以下區別:
-- ①索引表不需要進行初始化，可以直接為指定索引賦值，開闢的索引表的索引不一定必
-- 須連續。
-- ②索引表不僅可以使用數字作為索引下標，也可以利用字串表示索引下標，使用數字作
-- 為索引下標時也可以設置負數。
-- 定義索引表語法:
-- TYPE 類型名稱 IS TABLE OF 類型數據 [NOT NULL]
-- INDEX BY [PLS_INTEGER|BINARY_INTEGER|VARCHAR2(長度)];

-- ex:定義索引表
DECLARE
 TYPE info_index IS TABLE OF VARCHAR2(20) INDEX BY PLS_INTEGER;
 v_info info_index;
BEGIN
 v_info(1) := 'JAVA'; -- 在第1個索引保存JAVA字串
 v_info(10) := 'Oracle'; -- 在第10個索引保存Oracle字串
 DBMS_OUTPUT.put_line(v_info(1));
 DBMS_OUTPUT.put_line(v_info(10));
 DBMS_OUTPUT.put_line(v_info(99)); -- 訪問第99個索引
END;
/
/*
錯誤報告:
ORA-01403: 找不到資料
ORA-06512: 在 line 9
*/
-- 如果訪問沒有定義的索引，那麼就會出現找不到數據的異常。
-- 但是索引表中的內容不是順序的，也就是說有的索引值可能存在，也可能不存在，為了
-- 方便操作，提供了EXISTS()函數進行判斷。
DECLARE
 TYPE info_index IS TABLE OF VARCHAR2(20) INDEX BY PLS_INTEGER;
 v_info info_index;
BEGIN
 v_info(1) := 'JAVA'; -- 在第1個索引保存JAVA字串
 v_info(10) := 'Oracle'; -- 在第10個索引保存Oracle字串
 DBMS_OUTPUT.put_line(v_info(1));
 IF v_info.EXISTS(10) THEN 
  DBMS_OUTPUT.put_line(v_info(10));
 ELSE
  DBMS_OUTPUT.put_line('索引號為10的數據不存在');
 END IF;
 IF v_info.EXISTS(30) THEN 
  DBMS_OUTPUT.put_line(v_info(30));
 ELSE
  DBMS_OUTPUT.put_line('索引號為30的數據不存在'); 
 END IF;
END;
/
-- 以上都是使用了數字，PLS_INTEGER是NUMBER子類型。


-- ex:使用字串作為索引
DECLARE
 TYPE info_index IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(30);
 v_info info_index;
BEGIN
 v_info('公司名稱') := '甲骨文(Oracle)';
 v_info('培訓項目') := 'Java-Android高級培訓';
 DBMS_OUTPUT.put_line(v_info('公司名稱'));
 DBMS_OUTPUT.put_line(v_info('培訓項目'));
END;
/
-- 以上的一系列操作都使用了基本類型實現的，那麼也可以直接使用ROWTYPE定義保存類型


-- ex:定義ROWTYPE
DECLARE
 TYPE dept_index IS TABLE OF dept%ROWTYPE INDEX BY PLS_INTEGER;
 v_dept dept_index;
BEGIN
 v_dept(0).deptno := 80;
 v_dept(0).dname := 'Oracle公司';
 v_dept(0).loc := '美國';
 IF v_dept.EXISTS(0) THEN 
  DBMS_OUTPUT.put_line('部門編號: ' || v_dept(0).deptno 
  || ', 名稱: ' || v_dept(0).dname 
  || ', 位置: ' || v_dept(0).loc);
 END IF;
END;
/


-- ex:使用紀錄類型作為索引表保存數據類型
DECLARE
 TYPE dept_type IS RECORD(
  deptno dept.deptno%TYPE := 80,
  dname dept.dname%TYPE,
  loc dept.loc%TYPE);
 TYPE dept_index IS TABLE OF dept_type INDEX BY PLS_INTEGER;
 v_dept dept_index;
BEGIN
 v_dept(0).deptno := 80;
 v_dept(0).dname := 'Oracle公司';
 v_dept(0).loc := '美國';
 IF v_dept.EXISTS(0) THEN 
  DBMS_OUTPUT.put_line('部門編號: ' || v_dept(0).deptno 
  || ', 名稱: ' || v_dept(0).dname 
  || ', 位置: ' || v_dept(0).loc);
 END IF;
END;
/
--============================================================================--
--                                                                            --
/* ※集合-嵌套表                                                              */
--                                                                            --
--============================================================================--
-- 說明:嵌套表是一種類似於索引表的結構，也可以用於保存多個數據，而且也可以保存複
-- 合類型的數據。嵌套表指的是在一個數據表定義時同時加入其他內部表的定義，這一概
-- 念是在Oracle 8中引入的，它們使用SQL進行訪問，也可以進行動態擴展。

-- ➤如果要想實現一對多的存儲關係，一定需要兩張數據表，一張為主表(需要定義主鍵或
-- 唯一約束)，另一張子表(設置外鍵)，其中主表的一行紀錄會對應多行子表紀錄。而如
-- 果將主表和子表合為一體的話，那麼子表就可以理解為主表的一個嵌套表，所以嵌套表
-- 是多行子表關聯數據的集合，他在主表之中表示為其中的某一個直行。

-- 嵌套表並不屬於普通的數據類型，所以必須先創造出數據類型。
/*
創建嵌套表類型:
CREATE [OR REPLACE] TYPE 類型名稱 AS|IS TABLE OF 數據類型 [NOT NULL];
/

創建表指定嵌套表存儲哭間名稱:
CREATE TABLE 表名稱(
 欄位名稱 類型
 ...
 嵌套表欄位名稱 嵌套表類型
) NESTED TABLE 嵌套表欄位名稱 STORE AS 存儲空間名稱;

查詢嵌套表內容
SELECT * FROM TABLE(
SELECT 嵌套表欄位名稱 FROM 表名稱 WHERE 條件);
*/


-- ➤簡單類型嵌套表
-- ex:創建表示多個項目的嵌套表類型:
CREATE OR REPLACE TYPE project_nested AS TABLE OF VARCHAR2(50) NOT NULL;
/
-- 編寫AS或IS沒有任何區別。
-- 現在就定義出了一個嵌套表類型。那麼最終嵌套表還是要在數據表中使用。


-- ex:定義數據表，使用嵌套表類型
DROP TABLE department PURGE;
CREATE TABLE department(
 did NUMBER,
 deptname VARCHAR2(30) NOT NULL,
 projects project_nested,
 CONSTRAINT pk_did PRIMARY KEY(did)
) NESTED TABLE projects STORE AS project_nested_table;
-- 查詢department表結構
DESC department;


-- ex:向department表增加紀錄
INSERT INTO department (did,deptname,projects) 
VALUES (10,'甲骨文',project_nested('JAVA實戰開發','Android實戰開發'));
INSERT INTO department (did,deptname,projects) 
VALUES (20,'ORACLE出版部',project_nested('<JAVA開發實戰經典>',
'<JAVA WEB開發實戰經典>','<Android開發實戰經典>'));
COMMIT;
-- 現在都是以嵌套表的形式進行數據保存。


-- 查看department表中數據
SELECT * FROM department;
-- 現在返回的實際上是一個嵌套表的數據。


-- 單獨查詢projects語句
SELECT projects FROM department WHERE did=20;
-- 現在返回的內容是一個對象，但所需要的是不應該是一個對象，而是對象中的內容。


-- ex:查詢嵌套表內容
SELECT * FROM TABLE(
SELECT projects FROM department WHERE did=20);
-- 此時嵌套表之中多個數據內容就會以數據表的形式返回。
-- 現在都是以嵌套表的形式進行數據保存。


-- ex:修改department表中20部門項目訊息
UPDATE  TABLE(SELECT projects FROM department WHERE did=20) pro 
SET VALUE(pro)='<ORACLE開發實戰經典>' 
WHERE pro.column_value='<JAVA開發實戰經典>';


-- ex:刪除department表中紀錄
DELETE FROM TABLE(SELECT projects FROM department WHERE did=20) pro 
WHERE pro.column_value='<JAVA WEB開發實戰經典>';


-- ➤複合類型嵌套表
/*
創建新的對象類型
語法:
CREATE TYPE 類型名稱 AS OBJECT(
 直行名稱 數據類型,
 直行名稱 數據類型,
 ...
 直行名稱 數據類型
);
/
*/
-- ex:創建一個新對象類型
CREATE OR REPLACE TYPE project_type AS OBJECT(
projectid NUMBER,
projectname VARCHAR2(50),
projectfunds NUMBER,
pubdate DATE
);
/
-- 隨後要根據此類型定義新的嵌套表類型。


-- ex:定義嵌套表類型
CREATE OR REPLACE TYPE project_nested AS TABLE OF project_type NOT NULL;
/
-- 錯誤報告:ORA-02303: 無法刪除或取代具有類型或表格相依項目的類型
-- 解決:
DROP TABLE department PURGE;


-- ex:創建部門表，使用複合類型嵌套表
DROP TABLE department PURGE;
CREATE TABLE department(
 did NUMBER,
 deptname VARCHAR2(30) NOT NULL,
 projects project_nested,
 CONSTRAINT pk_did PRIMARY KEY(did)
) NESTED TABLE projects STORE AS project_nested_table;


-- ex:向department表增加紀錄
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


-- 查看department表中數據
SELECT * FROM department;


-- 查看一個部門的全部項目訊息
SELECT * FROM TABLE(
SELECT projects FROM department WHERE did=20);


-- 修改某個部門的一個項目訊息
UPDATE  TABLE(SELECT projects FROM department WHERE did=20) pro 
SET VALUE(pro)=project_type(11,'<ORACLE開發實戰經典>',108.8,
 TO_DATE('2013-06-20','YYYY-MM-DD')) 
WHERE pro.projectid=11;
COMMIT;


-- 刪除表中紀錄
DELETE FROM TABLE(SELECT projects FROM department WHERE did=20) pro 
WHERE pro.projectid=12;
COMMIT;


-- ➤在PL/SQL中使用嵌套表
-- 簡述:嵌套表就是一種新定義的數據類性，這個類型是可以直接在PL/SQL中去使用的。
-- 在有了嵌套表變量和數據之後，可使用"嵌套表.COUNT"找到嵌套表長度，透過FOR迴圈
-- 進行迭代。
-- ex:在PL/SQL中定義新類型
-- note:PL/SQL中創建嵌套表的語法中"AS"無法使用。
DECLARE 
 TYPE project_nested 
 IS TABLE OF VARCHAR2(50) NOT NULL; --簡單類型(VARCHAR2)嵌套表
 v_projects project_nested := project_nested('JAVA SE','JAVA EE','Android'); 
BEGIN
 -- 使用FOR循環將projects嵌套表中的元素迭代
 FOR i IN 1 .. v_projects.COUNT LOOP 
  DBMS_OUTPUT.put_line(v_projects(i));
 END LOOP;
END;
/


-- 現在對於集合採用的是FOR循環完成的，那麼也可以使用"集合.FIRST~集合.LAST"的方式
-- 完成操作。
DECLARE 
 TYPE project_nested 
 IS TABLE OF VARCHAR2(50) NOT NULL; --簡單類型(VARCHAR2)嵌套表
 v_projects project_nested := project_nested('JAVA SE','JAVA EE','Android'); 
BEGIN
 -- 使用FOR循環將projects嵌套表中的元素迭代
 FOR i IN v_projects.FIRST .. v_projects.LAST LOOP 
  DBMS_OUTPUT.put_line(v_projects(i));
 END LOOP;
END;
/


-- 如果用戶自己有需要，也可以在外部先定義出嵌套表的類型，而後在PL/SQL中使用此類
-- 型。
-- ex:在PL/SQL外部定義類型
-- 創建簡單類型(VARCHAR2)嵌套表
CREATE OR REPLACE TYPE project_nested IS TABLE OF VARCHAR2(50) NOT NULL;  
/
DECLARE  
 v_projects project_nested := project_nested('JAVA SE','JAVA EE','Android'); 
BEGIN
 -- 使用FOR循環將projects嵌套表中的元素迭代
 FOR i IN v_projects.FIRST .. v_projects.LAST LOOP 
  DBMS_OUTPUT.put_line(v_projects(i));
 END LOOP;
END;
/


-- 利用嵌套表進行數據的更新操作。
-- ex:準備過程
DROP TABLE department PURGE;
CREATE OR REPLACE TYPE project_nested IS TABLE OF VARCHAR2(50) NOT NULL;  
/
CREATE TABLE department(
 did NUMBER,
 deptname VARCHAR2(30) NOT NULL,
 projects project_nested,
 CONSTRAINT pk_did PRIMARY KEY(did)
) NESTED TABLE projects STORE AS project_nested_table;
-- 外部建立新的類型，隨後在departmnet表中也使用了此嵌套表類型。


-- ex:利用PL/SQL實現數據增加
DECLARE  
 v_projects_list project_nested := 
 project_nested('<JAVA開發實戰經典>','<C#開發實戰經典>','<Android開發實戰經典>'); 
 v_dept department%ROWTYPE; -- 將一橫列數據存到v_dpet變數
BEGIN 
 v_dept.did := 88;
 v_dept.deptname := 'ORACLE';
 v_dept.projects := v_projects_list; -- 直接使用嵌套表數據
 INSERT INTO department VALUES v_dept; 
END;
/

select * from department;

































