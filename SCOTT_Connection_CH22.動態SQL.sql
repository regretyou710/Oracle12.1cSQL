--============================================================================--
--                                                                            --
/* ※動態SQL-動態SQL                                                          */ 
--                                                                            --
--============================================================================--
-- ▲使用動態SQL可以在依賴對象不存在時創建子程序。

-- 在一個函數中，能否編寫DDL創建語句?
-- ex:試驗在函數中編寫DDL
CREATE OR REPLACE FUNCTION get_table_count_fun(p_table_name VARCHAR2) 
RETURN NUMBER 
AS  
BEGIN 
 CREATE TABLE p_table_name(
  id NUMBER,
  name VARCHAR2(30) NOT NULL,
  CONSTRAINT pk_id PRIMARY KEY(id)
 );
 RETURN 0;
END;
/
/*
Errors: check compiler log
5/2            PLS-00103: 發現了符號 "CREATE" 當您等待下列事項之一發生時: 

   ( begin case declare exit for goto if loop mod null pragma
   raise return select 更新 while with <ID>
   <外加雙引號的分界 ID> <連結變數> << continue
   close current delete fetch lock insert open rollback
   savepoint set sql execute commit forall merge pipe purge  
*/
-- 發現裡面無法編寫DDL。如果想再函數中創建數據表，那就必須使用動態SQL完成。


-- ex:使用動態SQL
CREATE OR REPLACE FUNCTION get_table_count_fun(p_table_name VARCHAR2) 
RETURN NUMBER 
AS 
 v_sql_statement VARCHAR2(200);
BEGIN 
 v_sql_statement := 'CREATE TABLE ' || p_table_name || '(
  id NUMBER,
  name VARCHAR2(30) NOT NULL,
  CONSTRAINT pk_id PRIMARY KEY(id)
 )';
 
 -- 執行動態SQL
 EXECUTE IMMEDIATE v_sql_statement;
 RETURN 0;
END;
/


-- ex:在PL/SQL塊測試函數
BEGIN 
 -- 因為函數有返回值所以在輸出中輸入
 DBMS_OUTPUT.put_line(get_table_count_fun('hello'));
END;
/
-- 錯誤報告:ORA-01031: 權限不足


-- 現在需要進行表的創建，所以可以將創建任意表的權限授予c##scott用戶。
-- ex:實現授權
CONN sys/change_on_install AS SYSDBA;
GRANT CREATE ANY TABLE TO c##scott;
CONN c##scott/tiger;


-- ex:再次使用動態SQL
CREATE OR REPLACE FUNCTION get_table_count_fun(p_table_name VARCHAR2) 
RETURN NUMBER 
AS 
 v_sql_statement VARCHAR2(200);
BEGIN 
 v_sql_statement := 'CREATE TABLE ' || p_table_name || '(
  id NUMBER,
  name VARCHAR2(30) NOT NULL,
  CONSTRAINT pk_id1 PRIMARY KEY(id)
 )';
 
 -- 執行動態SQL
 EXECUTE IMMEDIATE v_sql_statement;
 RETURN 0;
END;
/
-- 已編譯 FUNCTION GET_TABLE_COUNT_FUN


-- ex:再次在PL/SQL塊測試函數
BEGIN 
 -- 因為函數有返回值所以在輸出中輸入
 DBMS_OUTPUT.put_line(get_table_count_fun('hello'));
END;
/


-- 此時動態SQL的創建是非常方便的。下面繼續完善此函數，此函數的主要功能實際上是
-- 希望可以取得表的數據量。如果此時的表存在，那麼可以直接統計查詢，如果不存在
-- 進行創建。
-- ex:修改函數
CREATE OR REPLACE FUNCTION get_table_count_fun(p_table_name VARCHAR2) 
RETURN NUMBER 
AS 
 v_sql_statement VARCHAR2(200);
 v_count NUMBER;
BEGIN 
 -- 使用數據字典user_tables判斷表是否存在
 SELECT COUNT(*) INTO v_count FROM user_tables 
 WHERE table_name=UPPER(p_table_name);
 IF v_count=0 THEN 
  v_sql_statement := 'CREATE TABLE ' || p_table_name || '(
   id NUMBER,
   name VARCHAR2(30) NOT NULL,
   CONSTRAINT pk_id_' || p_table_name ||' PRIMARY KEY(id)
  )';
  
  -- 執行動態SQL
  EXECUTE IMMEDIATE v_sql_statement;
 END IF; 
 
 v_sql_statement := 'SELECT COUNT(*) FROM '|| p_table_name;
 EXECUTE IMMEDIATE v_sql_statement INTO v_count;
 RETURN v_count;
END;
/


-- ex:在PL/SQL塊測試函數
BEGIN 
 -- 因為函數有返回值所以在輸出中輸入
 DBMS_OUTPUT.put_line(get_table_count_fun('orcljava'));
END;
/
SELECT * FROM tab;
DESC orcljava;
-- 現在可以發現，裡面的所有內容都不是固定的SQL操作。


-- ➤EXECUTE IMMEDIATE語句
-- 說明:在動態SQL中EXECUTE IMMEDIATE是最為重要執行命令，使用此語句可以方便的在
-- PL/SQL程序中執行DML(INSERT、UPDATE、DELETE、單橫列SELECT)、DDL(CREATE、ALTER
-- DROP)、DCL(GRANT、REVOKE)語句。
/*
EXECUTE IMMEDIATE語法:
EXECUTE IMMEDIATE 動態SQL字串 [[BULK COLLECT] INTO 自定義變量,...|紀錄類型]
[[USING [IN|OUT|IN OUT]]綁定參數,...]
[[RETURNING|RETURN][BULK COLLECT] INTO 綁定參數,...];

在EXECUTE IMMEDIATE由以下三個主要子句組成:
INTO:保存動態SQL執行結果，如果返回多條紀錄可以透過BULK COLLECT設置批量保存。
USING:用來為動態SQL設置佔位符設置內容。
RETURNING|RETURN:兩者使用效果一樣，是取得更新表紀錄被影響的數據，透過BULK COLLECT
來設置批量綁定。
*/


-- ➤執行動態SQL
-- ex:使用動態SQL創建表和PL/SQL
DECLARE 
 v_sql_statement VARCHAR2(200);
 v_count NUMBER;
BEGIN 
 -- 使用動態SQL創建表
 SELECT COUNT(*) INTO v_count FROM user_tables
 WHERE table_name='ORCL_TAB';
 IF v_count=0 THEN 
  v_sql_statement := 'CREATE TABLE orcl_tab(
   id NUMBER,
   url VARCHAR2(50) NOT NULL,
   CONSTRAINT pk_id_orcl_tab PRIMARY KEY(id)
  )';
  EXECUTE IMMEDIATE v_sql_statement;
 ELSE 
  v_sql_statement := 'TRUNCATE TABLE orcl_tab';
  EXECUTE IMMEDIATE v_sql_statement;
 END IF;
 
 -- 使用PL/SQL塊增加數據
 v_sql_statement := '
  BEGIN 
   FOR i IN 1 .. 10 LOOP 
    INSERT INTO orcl_tab(id, url) VALUES (i, ''www.oracle.com-'' || i);
   END LOOP;
  END;  
 ';
 EXECUTE IMMEDIATE v_sql_statement;
 COMMIT;
END;
/

SELECT * FROM orcl_tab;
-- 使用EXECUTE IMMEDIATE語句可以同時實現DDL、PL/SQL塊的動態執行。


-- ➤設置綁定變量
-- 說明:在使用動態SQL時，可以在定義SQL字裡面採用佔位符的方式設置綁定變量，而所設
-- 置的綁定變量，需要在程序運行時，動態使用USING語句設置內容。而設置的方式是使用
-- ":佔位符名稱"。
-- ex:使用綁定變量
DECLARE 
 v_sql_statement VARCHAR2(200);
 v_deptno dept.deptno%TYPE := 60;
 v_dname dept.dname%TYPE := 'Oracle';
 v_loc dept.loc%TYPE := '加州';
BEGIN 
 -- 使用佔位符
 v_sql_statement := '
  INSERT INTO dept(deptno, dname, loc) VALUES (:dno, :dna, :dl)
 ';
 EXECUTE IMMEDIATE v_sql_statement USING v_deptno, v_dname, v_loc;
 COMMIT;
END;
/

SELECT * FROM dept;


-- ex:利用集合更新多條紀錄
DECLARE 
 v_sql_statement VARCHAR2(200);
 TYPE deptno_nested IS TABLE OF dept.deptno%TYPE NOT NULL; -- 定義簡單嵌套表類型
 TYPE dname_nested IS TABLE OF dept.dname%TYPE NOT NULL; -- 定義簡單嵌套表類型 
 v_deptno deptno_nested := deptno_nested(10, 20, 30, 40); 
 v_dname dname_nested := dname_nested('財務部', '研發部', '銷售部', '操作部');
BEGIN  
 v_sql_statement := 'UPDATE dept SET dname=:dna WHERE deptno=:dno';
 FOR i in 1 .. v_deptno.COUNT LOOP 
  EXECUTE IMMEDIATE v_sql_statement USING v_dname(i), v_deptno(i);
 END LOOP;
 COMMIT;
END;
/

SELECT * FROM dept;
-- 以上實現了更新，下面繼續在查詢中使用佔位符。


-- ex:在查詢中使用佔位符
DECLARE 
 v_sql_statement VARCHAR2(200); 
 v_empno emp.empno%TYPE := 7369;
 v_emprow emp%ROWTYPE;
BEGIN  
 v_sql_statement := 'SELECT * FROM emp WHERE empno=:eno'; 
 EXECUTE IMMEDIATE v_sql_statement INTO v_emprow USING v_empno;
 DBMS_OUTPUT.put_line('員工編號 :' || v_emprow.empno 
 || ', 姓名: ' || v_emprow.ename  
 || ', 職位: ' || v_emprow.job
 || ', 工資: ' || v_emprow.sal); 
END;
/


-- note:在此處必須提醒的是，如果在創建表的使用佔位符會出現錯誤。
-- ex:錯誤的應用
DECLARE 
 v_sql_statement VARCHAR2(200); 
 v_table_name VARCHAR2(200) := 'ORACLE';
 v_id_column VARCHAR2(200) := 'id';
BEGIN  
 v_sql_statement := 'CREATE TABLE :tn(
  :ci NUMBER PRIMARY KEY
 )'; 
 EXECUTE IMMEDIATE v_sql_statement USING v_table_name, v_id_column;  
END;
/
-- 錯誤報告:ORA-00903: 表格名稱無效
-- 這個時候根本就不可能使用佔位符完成操作，只能夠採用拼接字串的方式完成。


-- ex:修改錯誤的應用
DECLARE 
 v_sql_statement VARCHAR2(200); 
 v_table_name VARCHAR2(200) := 'ORACLE';
 v_id_column VARCHAR2(200) := 'id';
BEGIN  
 v_sql_statement := 'CREATE TABLE ' || v_table_name ||'(
  ' || v_id_column || ' NUMBER PRIMARY KEY
 )'; 
 EXECUTE IMMEDIATE v_sql_statement;  
END;
/

DESC ORACLE;


-- ➤接收DML更新橫列數
-- 說明:當用戶使用DML的更新操作後，可以使用RETURNING INTO子句接收更新的數據量。
-- ex:更新數據，取得更新後的結果
DECLARE 
 v_sql_statement VARCHAR2(200); 
 v_empno emp.empno%TYPE := 7369;
 v_empsal emp.sal%TYPE;
 v_empjob emp.job%TYPE;
BEGIN  
 v_sql_statement := 'UPDATE emp SET sal=sal*1.2, job=''開發'' 
  WHERE empno=:eno RETURNING sal, job INTO :sal, :job
 '; 
 EXECUTE IMMEDIATE v_sql_statement USING v_empno 
 RETURNING INTO v_empsal, v_empjob;  
 DBMS_OUTPUT.put_line( '新職位: ' || v_empjob || ', 調整後工資: ' || v_empsal);
END;
/

SELECT * FROM emp;


-- 使用RETURN也可以的到相同結果
DECLARE 
 v_sql_statement VARCHAR2(200); 
 v_empno emp.empno%TYPE := 7369;
 v_empsal emp.sal%TYPE;
 v_empjob emp.job%TYPE;
BEGIN  
 v_sql_statement := 'UPDATE emp SET sal=sal*1.2, job=''開發'' 
  WHERE empno=:eno RETURN sal, job INTO :sal, :job
 '; 
 EXECUTE IMMEDIATE v_sql_statement USING v_empno 
 RETURN INTO v_empsal, v_empjob;  
 DBMS_OUTPUT.put_line( '新職位: ' || v_empjob || ', 調整後工資: ' || v_empsal);
END;
/

SELECT * FROM emp;


-- ex:刪除數據，取得刪除前的結果
DECLARE 
 v_sql_statement VARCHAR2(200);
 v_empno emp.empno%TYPE := 7369; -- 刪除的員工編號
 v_ename emp.ename%TYPE; -- 刪除的員工姓名
 v_empsal emp.sal%TYPE; -- 刪除的員工薪資 
BEGIN  
 v_sql_statement := 'DELETE FROM emp WHERE empno=:eno 
  RETURNING ename, sal INTO :name, :sal
 '; 
 EXECUTE IMMEDIATE v_sql_statement  USING v_empno 
 RETURNING INTO v_ename, v_empsal;  
 DBMS_OUTPUT.put_line('刪除的員工編號: ' || v_empno 
 || ', 刪除的員工姓名: ' || v_ename 
 || ', 刪除的員工薪資: ' || v_empsal);
END;
/

SELECT * FROM emp;
ROLLBACK;


-- 對於USING和RETURNING語句也可以設置參數模式，IN、OUT、IN OUT，默認的模式是IN
-- 模式，而對於RETURNING採用的是OUT模式。
-- ex:編寫一個增加部門的過程
CREATE OR REPLACE PROCEDURE dpet_insert_proc(
 p_deptno IN OUT dept.deptno%TYPE,
 p_dname dept.dname%TYPE,
 p_loc dept.loc%TYPE
) 
AS 
BEGIN 
 -- 取得部門編號最大值
 SELECT MAX(deptno) INTO p_deptno FROM dept;
 -- OUT參數p_deptno時加1
 p_deptno := p_deptno+1;
 INSERT INTO dept(deptno, dname, loc) VALUES (p_deptno, p_dname, p_loc);
END;
/


-- 希望動態SQL執行的時候可以將p_deptno內容帶回來。
-- ex:編寫PL/SQL塊，調用過程
DECLARE 
 v_sql_statement VARCHAR2(200);
 v_deptno dept.deptno%TYPE;
 v_dname dept.dname%TYPE := 'orcl公關部';
 v_loc dept.loc%TYPE := '東岸';
BEGIN 
 v_sql_statement := '
  BEGIN 
   dpet_insert_proc(:dno, :dna, :dl);
  END; 
 ';
 EXECUTE IMMEDIATE v_sql_statement USING IN OUT v_deptno, IN v_dname, v_loc;
 DBMS_OUTPUT.put_line('新增部門編號為: ' || v_deptno);
END;
/

SELECT * FROM dept;
ROLLBACK;
-- 使用IN OUT傳輸後可以把過程中的內容繼續帶回來。


-- ➤批量綁定
-- 說明:透過動態SQL進行查詢或更新操作時，每次都是向數據庫提交一條操作語句，如果
-- 現在希望數據庫可以一次性接收多條SQL，以及數據庫可以一次性將操作結果返回到某一
-- 個集合中時，就可以採用批量處理操作完成，在進行批量處理操作中，主要依靠
-- BULK COLLECT進行操作。
-- ex:更新的時候使用BULK COLLECT語句;將10部門的員工工資增長20%
DECLARE 
 -- 使用索引表接收10部門修改的數據
 TYPE ename_index IS TABLE OF emp.ename%TYPE INDEX BY PLS_INTEGER;
 TYPE job_index IS TABLE OF emp.job%TYPE INDEX BY PLS_INTEGER;
 TYPE sal_index IS TABLE OF emp.sal%TYPE INDEX BY PLS_INTEGER;
 v_ename ename_index;
 v_job job_index;
 v_sal sal_index;
 v_deptno emp.deptno%TYPE := 10;
 v_sql_statement VARCHAR2(200);
BEGIN 
 v_sql_statement := '
  UPDATE emp SET sal=sal*1.2 WHERE deptno=:dno 
  RETURNING ename, job, sal INTO :ena, :ej, :es
 ';
 EXECUTE IMMEDIATE v_sql_statement USING v_deptno 
 RETURNING BULK COLLECT INTO v_ename, v_job, v_sal;
 FOR i IN v_ename.FIRST .. v_ename.COUNT LOOP 
  DBMS_OUTPUT.put_line(
   '員工姓名: ' || v_ename(i) 
   || ', 職位: ' || v_job(i) 
   || ', 薪資: ' || v_sal(i) 
  );
 END LOOP;
END;
/

SELECT * FROM emp;
ROLLBACK;
-- 一次性返回了多個更新後的結果。


-- ex:查詢的時候使用批量接收
DECLARE 
 -- 使用索引表接收10部門查詢的數據
 TYPE ename_index IS TABLE OF emp.ename%TYPE INDEX BY PLS_INTEGER;
 TYPE job_index IS TABLE OF emp.job%TYPE INDEX BY PLS_INTEGER;
 TYPE sal_index IS TABLE OF emp.sal%TYPE INDEX BY PLS_INTEGER;
 v_ename ename_index;
 v_job job_index;
 v_sal sal_index;
 v_deptno emp.deptno%TYPE := 10;
 v_sql_statement VARCHAR2(200);
BEGIN 
 v_sql_statement := '
  SELECT ename, job, sal FROM emp WHERE deptno=:dno  
 ';
 EXECUTE IMMEDIATE v_sql_statement 
 BULK COLLECT INTO v_ename, v_job, v_sal USING v_deptno;
 FOR i IN v_ename.FIRST .. v_ename.COUNT LOOP 
  DBMS_OUTPUT.put_line(
   '員工姓名: ' || v_ename(i) 
   || ', 職位: ' || v_job(i) 
   || ', 薪資: ' || v_sal(i) 
  );
 END LOOP;
END;
/


-- ➤FORALL
-- 說明:如果要向動態SQL中設置多個綁定參數，則必須利用FORALL語句完成
/*
語法:
FORALL 索引變量 IN 參數集合最小值 .. 參數集合最大值
EXECUTE IMMEDIATE 動態SQL字串
[USING 綁定參數|綁定參數(索引), ...] 
[[RETURNING|RETURN] BULK COLLECT INTO 綁定參數集合, ...];
*/
-- ex:使用FORALL設置多個參數;一次刪除嵌套表中的3個員工編號
DECLARE 
 TYPE empno_nested IS TABLE OF emp.empno%TYPE; -- 定義簡單嵌套表類型
 TYPE ename_index IS TABLE OF emp.ename%TYPE INDEX BY PLS_INTEGER;
 TYPE job_index IS TABLE OF emp.job%TYPE INDEX BY PLS_INTEGER;
 TYPE sal_index IS TABLE OF emp.sal%TYPE INDEX BY PLS_INTEGER;
 v_ename ename_index;
 v_job job_index;
 v_sal sal_index; 
 v_sql_statement VARCHAR2(200);
 v_empno empno_nested := empno_nested(7369, 7566 ,7788);
BEGIN 
 v_sql_statement := '
  DELETE FROM emp WHERE empno=:eno 
  RETURNING ename, job, sal INTO :en, :ej, :es 
 ';
 
 -- 對簡單嵌套表一次性刪除3條紀錄
 FORALL i IN v_empno.FIRST .. v_empno.COUNT 
  EXECUTE IMMEDIATE v_sql_statement USING v_empno(i)
  RETURNING BULK COLLECT INTO v_ename, v_job, v_sal; 
 
 
 -- 從索引表中迭代出刪除的紀錄
 FOR i IN v_ename.FIRST .. v_ename.COUNT LOOP 
  DBMS_OUTPUT.put_line(
   '員工姓名: ' || v_ename(i) 
   || ', 職位: ' || v_job(i) 
   || ', 薪資: ' || v_sal(i) 
  );
 END LOOP;
END;
/

SELECT * FROM emp;
ROLLBACK;


-- ➤處理游標操作
-- 說明:動態SQL操作中，除了可以處理單橫列查詢操作外，也可以利用游標完成多橫列
-- 數據的操作，而在游標定義時也同樣可以使用動態綁定變量的方式，此時就需要在打
-- 開游標變量時增加USING子句操作。
-- 語法:
-- OPEN 游標變量名稱 FOR 動態SQL語句 [USING 綁定變量, 綁定變量, ...];

-- ex:在游標中使用動態SQL
DECLARE 
 cur_emp SYS_REFCURSOR; -- 定義弱類型的游標類型
 v_empRow emp%ROWTYPE;
 v_deptno emp.deptno%TYPE := 10;
BEGIN 
 OPEN cur_emp FOR 'SELECT * FROM emp WHERE deptno=:dno' USING v_deptno;
 
 LOOP
  FETCH cur_emp INTO v_empRow; -- 取得游標數據
  EXIT WHEN cur_emp%NOTFOUND;
  DBMS_OUTPUT.put_line('員工姓名: ' || v_empRow.ename 
  || ', 編號: ' || v_empRow.empno 
  || ', 職位: ' || v_empRow.job);
 END LOOP;
 CLOSE cur_emp;
END;
/


-- ➤FETCH
-- 說明:在FETCH語句中利用BULK COLLECT一次性將多個數據保存到集合類型中。
-- 語法:
-- FETCH 動態游標 BULK COLLECT INTO 集合變量 ...;
-- ex:利用FETCH保存多個數據到集合變量
DECLARE 
 cur_emp SYS_REFCURSOR; -- 定義弱類型的游標類型
 
 -- 定義索引表(存放一橫列紀錄)
 TYPE emp_index IS TABLE OF emp%ROWTYPE INDEX BY PLS_INTEGER;
 v_empRow emp_index;
 v_deptno emp.deptno%TYPE := 10;
BEGIN 
 OPEN cur_emp FOR 'SELECT * FROM emp WHERE deptno=:dno' USING v_deptno;
 
 FETCH cur_emp BULK COLLECT INTO v_empRow; -- 一次取得多個游標數據(數據全部取出)
 CLOSE cur_emp;
 
 FOR i IN v_empRow.FIRST .. v_empRow.COUNT LOOP 
  DBMS_OUTPUT.put_line('員工姓名: ' || v_empRow(i).ename 
  || ', 編號: ' || v_empRow(i).empno 
  || ', 職位: ' || v_empRow(i).job);
 END LOOP;
END;
/
-- 一次性取出多條數據後，游標就可以直接關閉了。


-- ➤DBMS_SQL包簡介
-- 說明:Oracle數據庫為了解決對象依賴關係的問題，從Oracle 7版本開始就引入了
-- DBMS_SQL包，而到了Oracle 8i版本中其進行了增強，而到了Oracle 9i之後，動態SQL
-- 的發展方向逐步轉移到了NDS，也就是在之前所講解過的動態SQL操作的相關知識，而
-- 對於DBMS_SQL包的操作也就使用的越來越少。
/*
DBMS_SQL包操作步驟
第一步:打開游標。
操作函數:"function open_cursor return integer;"，此函數在打開游標時會返回一個游標
的ID，用戶必須透過此ID才可以進行相應操作。

第二步:解析要執行的SQL語句。
操作過程:"procedure parse(c in integer, statement in varchar2, language_flag in 
integer);"，此函數需要接收操作游標的CID，同時和要解析的SQL語句，最後需要給定解析
數據庫的操作版本，從Oracle 8i之後主要使用的是"DBMS_SQL.native"，如果為Oracle 7
版本則可以使用"DBMS_SQL.Oracle_v7"。

第三步:如果現在用戶執行的查詢操作(SELECT)，則需要指定游標中某個具體位置的元素值。
不設置列長度:"procedure define_column(c in integer, position in integer, column 
in char character set any_cs);"，需要用戶設置游標編號，操作變量的索引，以及要操
作列名稱，一般使用此方式設置數字型列較多。
設置列長度:"procedure define_column(c in integer, position in integer, column 
in char character set any_cs, column_size in integer);"，需要用戶設置游標編號，
操作變量的索引，以及要操作列名稱，在操作字串時需要給出字串的列長度。

第四步:如果游標中設置了綁定參數，則需要為綁定參數賦值具體的內容。
設置數值數據:"procedure bind_variable(c in integer, name in varchar2, 
value in number);"。
設置字串數據:"procedure bind_variable(c in integer, name in varchar2, 
value in number, value in varchar2 character set any_cs);"。

第五步:執行游標。
操作過程:"function execute(c in integer) return integer;"，操作指定編號的游標，
同時返回影響的行數。

第六步:從游標中取出紀錄。
操作過程:"function fetch_rows(c in integer) return integer;"，此過程需要接收一個
游標編號，同時返回行數，如果返回的內容為0，則表示沒有數據。

第七步:關閉游標。
操作過程:"procedure close_cursor(c in out integer);"，需要接收一個游標編號。
*/


-- ex:利用DBMS_SQL包查詢數據
DECLARE 
  v_sql_statement VARCHAR2(200);
  v_cid NUMBER; -- 保存游標ID，為了關閉
  v_ename emp.ename%TYPE;
  v_job emp.job%TYPE;
  v_sal emp.sal%TYPE;
  v_deptno emp.deptno%TYPE := 10;
  v_stat NUMBER; -- 接收執行游標返回橫列數
BEGIN 
 -- 1.打開游標
 v_cid := DBMS_SQL.open_cursor;
 
 -- 2.解析要執行的SQL語句
 v_sql_statement := 'SELECT ename, job, sal FROM emp WHERE deptno=:dno';
 DBMS_SQL.parse(v_cid, v_sql_statement, DBMS_SQL.native);
 
 -- 3.指定游標中某個具體位置的元素值
 DBMS_SQL.define_column(v_cid, 1, v_ename, 10);
 DBMS_SQL.define_column(v_cid, 2, v_job, 9);
 DBMS_SQL.define_column(v_cid, 3, v_sal);
 
 -- 4.為綁定參數賦值具體的內容
 DBMS_SQL.bind_variable(v_cid, ':dno', v_deptno);
 
 -- 5.執行游標
 v_stat := DBMS_SQL.execute(v_cid);
 
 -- 6.從游標中取出紀錄
 LOOP 
  EXIT WHEN DBMS_SQL.fetch_rows(v_cid)=0;  
  DBMS_SQL.column_value(v_cid, 1, v_ename);
  DBMS_SQL.column_value(v_cid, 2, v_job);
  DBMS_SQL.column_value(v_cid, 3, v_sal);
  DBMS_OUTPUT.put_line('員工姓名: ' || v_ename 
   || ', 職位: ' || v_job 
   || ', 工資: ' || v_sal
  );
 END LOOP;
 
 -- 7.關閉游標
 DBMS_SQL.close_cursor(v_cid);
END;
/


-- ex:利用DBMS_SQL包執行更新操作
DECLARE 
  v_sql_statement VARCHAR2(200);
  v_cid NUMBER; -- 保存游標ID，為了關閉
  v_empno emp.empno%TYPE := 7369;
  v_comm emp.comm%TYPE := 1000;  
  v_stat NUMBER; -- 接收執行游標返回橫列數
BEGIN 
 -- 1.打開游標
 v_cid := DBMS_SQL.open_cursor;
 
 -- 2.解析要執行的SQL語句
 v_sql_statement := 'UPDATE emp SET comm=:ec WHERE empno=:eno';
 DBMS_SQL.parse(v_cid, v_sql_statement, DBMS_SQL.native);
 
 -- 3.指定游標中某個具體位置的元素值
 
 -- 4.為綁定參數賦值具體的內容
 DBMS_SQL.bind_variable(v_cid, ':ec', v_comm);
 DBMS_SQL.bind_variable(v_cid, ':eno', v_empno); 
 
 -- 5.執行游標
 v_stat := DBMS_SQL.execute(v_cid);
 DBMS_OUTPUT.put_line('更新行數為: ' || v_stat);
 
 -- 6.從游標中取出紀錄  
 
 -- 7.關閉游標
 DBMS_SQL.close_cursor(v_cid);
END;
/

ROLLBACK;
-- 這就是傳統的動態SQL作法。