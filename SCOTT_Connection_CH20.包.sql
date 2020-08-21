--============================================================================--
--                                                                            --
/* ※包-包的定義及使用                                                        */
--                                                                            --
--============================================================================--
-- 簡述:對若干程序進行統一管理。
-- ➤包的基本概念
-- 包是一種程序模塊化設計的主要實現手段，透過包中可以將一個模塊之中所要使用的各
-- 個程序結構(過程、函數、游標、類型、變量)放在一起進行管理，同時包中所定義的程
-- 序結構也可以方便的進行互調用。
/*
在Oracle中如果要定義包則需要兩個組成部分:
①包規範(PACKAGE):定義包中可以被外部訪問的部份，在包規範中聲明的內容可以從應用程序
和包的任何地方訪問，其定義語法如下所示。
CREATE [REPLACE] PACKAGE 包名稱
[AUTHID CURRENT_USER|DEFINER]
IS|AS
 結構名稱定義(過程、函數、游標、類型、異常等)
END[包名稱];
/

②包體(PACKAGE BODY):負責包規範中定義的函數或過程的具體實現代碼，如果在包體之中定
義了包規範中沒有的內容，則此部份內容將被設置為私有訪問，包體的定義語法如下所示。
CREATE [REPLACE] PACKAGE BODY 包名稱
IS|AS
 結構實現(過程、函數、游標、類型、異常等)
BEGIN 
 包初始化程序代碼;
END[包名稱];
/

▲包規範:相當於Java中的介面，包體:相當於Java中的實現類。
*/


-- ex:定義包規範
CREATE OR REPLACE PACKAGE orcl_pkg
AS 
 FUNCTION get_emp_fun(
  p_dno dept.deptno%TYPE
 ) RETURN SYS_REFCURSOR; 
END;
/
-- 此時返回的是多條紀錄，所以使用弱類型的游標變量進行操作。單是只有包規範韓無法
-- 使用包，還需要定義包體，包體的名字一定要和包規範是統一的。


-- ex:定義包體，實現裡面的方法
CREATE OR REPLACE PACKAGE BODY orcl_pkg
AS 
 FUNCTION get_emp_fun(
  p_dno dept.deptno%TYPE
 ) RETURN SYS_REFCURSOR
 AS 
  cur_var SYS_REFCURSOR; -- 定義游標變量
 BEGIN 
  -- 打開游標並決定游標類型
  OPEN cur_var FOR SELECT * FROM emp WHERE deptno=p_dno;
  
  RETURN cur_var;
 END; 
END;
/
-- 既然創建語法中存在CREATE，那麼現在所創建的就一定是一個對象，所以對象就可以利
-- 用user_objects數據字典查看。


-- ex:查看數據字典
SELECT * FROM user_objects 
WHERE object_type IN ('PACKAGE','PACKAGE BODY')
AND object_name='ORCL_PKG';


-- ex:使用user_source查看源代碼
SELECT * FROM user_source WHERE name like '%ORCL_PKG%';


-- ex:編寫PL/SQL調用包中的子程序
DECLARE 
 v_receive SYS_REFCURSOR;
 v_empRow emp%ROWTYPE;
BEGIN 
 v_receive := orcl_pkg.get_emp_fun(10); -- 調用包中的函數操作
 LOOP
  FETCH v_receive INTO v_empRow; -- 取得當前游標數據
  EXIT WHEN v_receive%NOTFOUND;
  DBMS_OUTPUT.put_line(' 員工姓名: ' || v_empRow.ename 
  || ', 職位: ' || v_empRow.job);
 END LOOP; 
END;
/
-- 有了包之後，程序就可以進行統一的管理操作。對於包而言，由於其本身是屬於數據庫
-- 對象，那麼也可以利用DROP語句刪除包。


-- 如果刪除的是包規範，那麼對應的包體也一定會被刪除。
/*
刪除包語法
DROP PACKAGE 包名稱;

刪除包體語法
DROP PACKAGE BODY 包名稱;
*/
-- ex:刪除包
DROP PACKAGE orcl_pkg;
SELECT * FROM user_objects 
WHERE object_type IN ('PACKAGE','PACKAGE BODY')
AND object_name LIKE '%ORCL_PKG%';


-- ➤包的重新編譯
-- 簡述:與子程序一樣，包也可以進行重新的編譯操作。
/*
當包定義完成之後，如果謀些原因需要對包巾型重新編譯，可以使用如下的語法完成。
ALTER PACKAGE 包名稱 COMPILE [DEBUG] PACKAGE|SPECIFICATION|BODY [REUSE SETTINGS];

在進行包重新編譯時有三種編譯形式:
①PACKAGE:重新編譯包規範和包體。
②SPECIFICATION:重新編譯包規範。
③BODY:重新編譯包體。
*/
-- ex:重新編譯包規範
ALTER PACKAGE orcl_pkg COMPILE SPECIFICATION;


-- ex:重新編譯包體
ALTER PACKAGE orcl_pkg COMPILE BODY;


-- ➤包的作用域
-- 簡述:包中除了可以定義子程序外，也可以進行相應的變量定義。
-- 說明:由於採用了包規範與包體相分離的方式，所有某些私有的操作就可以非常方便的進
-- 行定義(只要不再包規範中定義而包體定義的結構為私有)。而且在默認情況下，所有的
-- 包是在第一次被調用時才會進行初始化操作，而後包的運行狀態保存到用戶全局區的會
-- 化之中，在一個會話期間內，此包會一直被用戶所佔用，直到會話結束後才會將包釋放
-- 。因此在包中的任何一個變量或游標等可以在一個會話期間一直存在，相當於全局變量
-- ，同時可以被所有的子程序所共享。

-- ex:在包規範中定義一個全局變量
CREATE OR REPLACE PACKAGE orcl_pkg
AS 
 v_deptno dept.deptno%TYPE :=10; -- 全局變量
 FUNCTION get_emp_fun(
  p_eno emp.empno%TYPE
 ) RETURN emp%ROWTYPE;
END;
/
-- 本次操作含意:希望取得自訂部門中的某個員工訊息，但是部門的編號是在包規範中定義
-- 好的全局變量。


-- ex:定義包體
CREATE OR REPLACE PACKAGE BODY orcl_pkg
AS  
 FUNCTION get_emp_fun(
  p_eno emp.empno%TYPE
 ) RETURN emp%ROWTYPE
 AS 
  v_empRow emp%ROWTYPE;
 BEGIN 
  SELECT * INTO v_empRow FROM emp 
  WHERE empno=p_eno AND deptno=v_deptno; -- v_deptno來自包規範
  RETURN v_empRow;
 END;
END;
/


-- 為了更好的證明此時的變量屬於全局變量，所以下面使用兩個PL/SQL塊調用。
-- ex:編寫一個PL/SQL塊，設置v_dpetno的內容
BEGIN 
  orcl_pkg.v_deptno := 20;
END;
/

DECLARE 
 v_empResult emp%ROWTYPE;
BEGIN 
  v_empResult := orcl_pkg.get_emp_fun(7369);
  DBMS_OUTPUT.put_line('員工姓名: ' || v_empResult.ename
  || ', 員工編號: ' ||orcl_pkg.v_deptno
  ||', 職位: '|| v_empResult.job);
END;
/


-- 如果現在不希望設置全局變量的話，可以使用SERIALLY_REUSABLE選項，這個選項不建議
-- 使用，因為它每次都需要重新加載和釋放包，這樣併發量大的時候性能會非常差。
-- ex:修改包規範定義
CREATE OR REPLACE PACKAGE orcl_pkg
AS 
 PRAGMA SERIALLY_REUSABLE;-- 不使用全局變量前置
 v_deptno dept.deptno%TYPE :=10; -- 全局變量
 FUNCTION get_emp_fun(
  p_eno emp.empno%TYPE
 ) RETURN emp%ROWTYPE;
END;
/


-- ex:修改包定義
CREATE OR REPLACE PACKAGE BODY orcl_pkg
AS 
 PRAGMA SERIALLY_REUSABLE;-- 不使用全局變量前置
 FUNCTION get_emp_fun(
  p_eno emp.empno%TYPE
 ) RETURN emp%ROWTYPE
 AS 
  v_empRow emp%ROWTYPE;
 BEGIN 
  SELECT * INTO v_empRow FROM emp 
  WHERE empno=p_eno AND deptno=v_deptno; -- v_deptno來自包規範
  RETURN v_empRow;
 END;
END;
/


-- 此時再次執行語句，發現orcl_pkg.v_deptno不保存20這個的值，只能操作員工是10部門
-- 的員工編號。
BEGIN 
  orcl_pkg.v_deptno := 20;
END;
/

DECLARE 
 v_empResult emp%ROWTYPE;
BEGIN 
  -- v_empResult := orcl_pkg.get_emp_fun(7369); -- 20部門員工編號
  v_empResult := orcl_pkg.get_emp_fun(7839); -- 10部門員工編號
  DBMS_OUTPUT.put_line('員工姓名: ' || v_empResult.ename
  || ', 員工編號: ' ||orcl_pkg.v_deptno
  ||', 職位: '|| v_empResult.job);
END;
/


-- ➤重載包中的子程序

-- 在之前包中定義的全部都是函數，那麼對於過程也是可以在包中進行定義，所以本次操作
-- 採用過程完成。
-- ex:編寫包規範，同時進行子程序重載
CREATE OR REPLACE PACKAGE emp_delete_pkg
AS 
 -- 根據員工編號刪除員工訊息
 PROCEDURE delete_emp_proc(
  p_eno emp.empno%TYPE
 );
 
 -- 根據員工姓名刪除員工訊息
 PROCEDURE delete_emp_proc(
  p_ename emp.ename%TYPE
 );
 
 -- 根據員工所在部門及職位刪除員工訊息
 PROCEDURE delete_emp_proc(
  p_deptno emp.deptno%TYPE,
  p_job emp.job%TYPE
 );
 
 -- 刪除員工時所發生的異常
 emp_delete_exception EXCEPTION;
END;
/


-- ex:定義包體，實現包規範
CREATE OR REPLACE PACKAGE BODY emp_delete_pkg
AS 
 -- 根據員工編號刪除員工訊息
 PROCEDURE delete_emp_proc(
  p_eno emp.empno%TYPE
 )
 AS 
 BEGIN 
  -- SQL%NOTFOUND 是一個布爾值。與最近的sql語句(update,insert,delete,select)發生
  -- 交互，當最近的一條sql語句沒有涉及任何行的時候，則返回true。否則返回false。
  DELETE FROM emp WHERE empno=p_eno;
  IF SQL%NOTFOUND THEN
   RAISE emp_delete_exception; -- 拋出異常
  END IF;
 END delete_emp_proc;
 
 -- 根據員工姓名刪除員工訊息
 PROCEDURE delete_emp_proc(
  p_ename emp.ename%TYPE
 )
 AS 
 BEGIN 
  DELETE FROM emp WHERE ename=UPPER(p_ename);
  IF SQL%NOTFOUND THEN
   RAISE emp_delete_exception; -- 拋出異常
  END IF;
 END delete_emp_proc;
 -- 根據員工所在部門及職位刪除員工訊息
 PROCEDURE delete_emp_proc(
  p_deptno emp.deptno%TYPE,
  p_job emp.job%TYPE
 )
 AS 
 BEGIN 
  DELETE FROM emp WHERE deptno=p_deptno AND job=p_job;
  IF SQL%NOTFOUND THEN
   RAISE emp_delete_exception; -- 拋出異常
  END IF;
 END delete_emp_proc;
END;
/


-- ex:調用過程，根據員工編號刪除，輸入一個不存在的編號
EXEC emp_delete_pkg.delete_emp_proc(8888);
-- 錯誤報告:ORA-06510: PL/SQL: 無法處理的使用者自訂異常狀況


-- ex:調用過程，根據員工編號刪除，輸入7369編號
EXEC emp_delete_pkg.delete_emp_proc(7369);
SELECT * FROM emp;


-- ex:調用過程，根據員工姓名刪除員工訊息
EXEC emp_delete_pkg.delete_emp_proc('king');
SELECT * FROM emp;


-- ex:調用過程，根據部門及職位刪除員工訊息
EXEC emp_delete_pkg.delete_emp_proc(20,'CLERK');
SELECT * FROM emp;


-- ➤包的初始化
-- 說明:在程序第一次調用數據包中的子程序、相關變量或是類型引用時，就表示對包進行
-- 默認的實例化操作，此時會將包的內容從硬碟讀入到內存，而此包將一直持續到整個會話
-- 結束。如果當某一會話第一次使用某個包時可以由用戶定義自訂一些屬於自己的初始化操
-- 作，如:為集合數據進行內容填充或是一些更加複雜的業務功能。如果要編寫包初始化的
-- 代碼可以直接在包中定義BEGIN語句，即，在此部份編寫初始化代碼。

-- ex:定義包規範
CREATE OR REPLACE PACKAGE init_pkg
AS 
 -- 定義索引表類型，裡面將保存多條dept橫列紀錄，使用數字作為訪問索引
 TYPE dept_index IS TABLE OF dept%ROWTYPE INDEX BY PLS_INTEGER;
 
  -- 定義索引表變量
 v_dept dept_index;

 -- 定義強類型游標變量(未實例化)
 CURSOR dept_cur RETURN dept%ROWTYPE;
 
 FUNCTION dept_insert_fun(
  p_deptno dept.deptno%TYPE,
  p_dname dept.dname%TYPE,
  p_loc dept.loc%TYPE
 ) RETURN BOOLEAN; 
END;
/


-- ex:定義包體，實現裡面的方法
CREATE OR REPLACE PACKAGE BODY init_pkg
AS 
 -- 實例化強類型游標
 CURSOR dept_cur RETURN dept%ROWTYPE IS SELECT * FROM dept;
 
 FUNCTION dept_insert_fun(
  p_deptno dept.deptno%TYPE,
  p_dname dept.dname%TYPE,
  p_loc dept.loc%TYPE
 ) RETURN BOOLEAN 
 AS 
 BEGIN 
  -- 2.此時透過索引表數據判斷，要增加的數據不存在則insert
  IF NOT v_dept.EXISTS(p_deptno) THEN
   INSERT INTO dept(deptno,dname,loc) VALUES (p_deptno,p_dname,p_loc);
   -- insert語句做完後還要將該筆資料添加到索引表中
   v_dept(p_deptno).deptno := p_deptno;
   v_dept(p_deptno).dname := p_dname;
   v_dept(p_deptno).loc := p_loc;
   RETURN TRUE;
  ELSE
   RETURN FALSE;  
  END IF;
 END dept_insert_fun;
BEGIN 
 -- 1.包初始化操作，所有的紀錄都保存在索引表中
 FOR dept_row IN dept_cur LOOP -- 游標所在的一橫列(dept_row)紀錄
  v_dept(dept_row.deptno) := dept_row; 
 END LOOP;
EXCEPTION 
 WHEN OTHERS THEN
  DBMS_OUTPUT.put_line('程序出現錯誤');
END;
/


-- ex:在PL/SQL塊實現包中結構的調用
BEGIN 
 -- 在索引表中查詢10部門訊息
  DBMS_OUTPUT.put_line('部門編號: ' || init_pkg.v_dept(10).deptno 
  || ', 名稱: ' || init_pkg.v_dept(10).dname 
  || ', 位置: ' || init_pkg.v_dept(10).loc 
  );
  
 -- 執行部門新增函數
 IF init_pkg.dept_insert_fun(55,'google','澳洲') THEN 
  DBMS_OUTPUT.put_line('新增部門增加成功');
  DBMS_OUTPUT.put_line('新增部門編號: ' || init_pkg.v_dept(55).deptno 
  || ', 名稱: ' || init_pkg.v_dept(55).dname 
  || ', 位置: ' || init_pkg.v_dept(55).loc 
  );
 ELSE
  DBMS_OUTPUT.put_line('新增門增加失敗');
 END IF; 
END;
/
-- 發現初始化之中取出了全部的數據，但是這種操作只是一個演示，實際之中不建議取很多
-- 數據到內存之中。
-- ▲如果新增成功後，從數據表中刪除，此時再次新增相同數據會失敗，因為索引表中還存
-- 在該筆紀錄未刪除。


-- ➤包的純度級別
-- 說明:如果在包中定義了函數，那麼可以直接透過SQL語句進行調用，如果現在要對包中的
-- 函數進行限制，例如:不能包含DML語句，如果要設置包的純度級別可以使用如下語法完成
-- :PRAGMA RESTRICT_REFERENCES(函數名稱,WNDS[,WNPS][,RNDS][,RNPS]);

-----------------------------------------------------------
|No.|純度等級|說明                                        |
-----------------------------------------------------------
|1  |WNDS    |函數不能修改數據庫表數據(即:無法使用DML更新)|
-----------------------------------------------------------
|2  |RNDS    |函數不能讀數據庫表(即:無法使用SELECT查詢)   |
-----------------------------------------------------------
|3  |WNPS    |函數不允許修改包中的變量內容                |
-----------------------------------------------------------
|4  |RNPS    |函數不允許讀取包中的變量內容                |
-----------------------------------------------------------

-- ex:定義包規範
CREATE OR REPLACE PACKAGE purity_pkg 
AS 
 -- 定義包中的變量
 v_name VARCHAR2(10) := 'orcl';
 
 -- 根據員工編號刪除數據，但是此函數不能夠執行更新操作
 FUNCTION emp_delete_fun_wnds(
  p_eno emp.ename%TYPE
 ) RETURN NUMBER;
 
 -- 根據員工編號查詢員工訊息，但是此函數不能執行SELECT操作
 FUNCTION emp_find_fun_rnds(
  p_eno emp.empno%TYPE
 ) RETURN NUMBER;
 
 -- 修改包中的變量，但現在不允許修改
 FUNCTION change_name_fun_wnps(
  p_param VARCHAR2
 ) RETURN VARCHAR2;
 
 -- 讀取v_name變量內容，但此函數不能讀取包中的變量
 FUNCTION get_name_fun_rnps(
  p_param VARCHAR2
 ) RETURN VARCHAR2;
 
 -- 設置函數的純度級別
 PRAGMA RESTRICT_REFERENCES(emp_delete_fun_wnds,WNDS);
 PRAGMA RESTRICT_REFERENCES(emp_find_fun_rnds,RNDS);
 PRAGMA RESTRICT_REFERENCES(change_name_fun_wnps,WNPS);
 PRAGMA RESTRICT_REFERENCES(get_name_fun_rnps,RNPS);
END;
/


-- ex:定義包體，驗證純度級別
CREATE OR REPLACE PACKAGE BODY purity_pkg 
AS 
 -- 根據員工編號刪除數據，但是此函數不能夠執行更新操作
 FUNCTION emp_delete_fun_wnds(
  p_eno emp.ename%TYPE
 ) RETURN NUMBER
 AS 
 BEGIN 
  -- WNDS純度，無法執行更新操作
  DELETE FROM emp WHERE empno=p_eno;
  RETURN 0;
 END;
 
 -- 根據員工編號查詢員工訊息，但是此函數不能執行SELECT操作
 FUNCTION emp_find_fun_rnds(
  p_eno emp.empno%TYPE
 ) RETURN NUMBER  
 AS 
  v_emp emp%ROWTYPE;
 BEGIN 
  -- RNDS純度，無法執行查詢操作
  SELECT * INTO v_emp FROM emp WHERE empno=p_eno;
  RETURN 0;
 END;
 
 -- 修改包中的變量，但現在不允許修改
 FUNCTION change_name_fun_wnps(
  p_param VARCHAR2
 ) RETURN VARCHAR2
 AS 
 BEGIN 
  -- WNPS純度，無法修改包中的變量
  v_name := p_param;
  RETURN '';
 END;
 
 -- 讀取v_name變量內容，但此函數不能讀取包中的變量
 FUNCTION get_name_fun_rnps(
  p_param VARCHAR2
 ) RETURN VARCHAR2
 AS 
 BEGIN 
  -- RNPS純度，無法讀取包中的變量
  RETURN v_name;
 END; 
END;
/
-- PLS-00452: 子程式 'GET_NAME_FUN_RNPS' 違反其相關的編譯指示
-- PLS-00452: 子程式 'CHANGE_NAME_FUN_WNPS' 違反其相關的編譯指示
-- PLS-00452: 子程式 'EMP_FIND_FUN_RNDS' 違反其相關的編譯指示
-- PLS-00452: 子程式 'EMP_DELETE_FUN_WNDS' 違反其相關的編譯指示


-- note:如果用戶定義的是一些公共的SQL函數，那麼就必須要符合三個純度級別:
-- WNDS、WNDS、RNPS。
-- ex:定義包的公共函數
CREATE OR REPLACE PACKAGE purity2_pkg 
AS   
 FUNCTION tax_fun(
  p_sal emp.sal%TYPE
 ) RETURN NUMBER;
 
 PRAGMA RESTRICT_REFERENCES(tax_fun,WNDS,WNPS,RNPS);
END;
/
-- 此時的fax_fun()函數就表示為一個公共函數。
--============================================================================--
--                                                                            --
/* ※包-系統工具包                                                            */
--                                                                            --
--============================================================================--
-- ➤DBMS_OUTPUT包
/*
DBMS_OUTPUT.chararr:作為get_lines的參數lines的類型。
DBMS_OUTPUT.enable:在當前作用域啟用DBMS_OUTPUT，並可修改緩衝區大小。
DBMS_OUTPUT.disable:在當前作用域停用DBMS_OUTPUT。
DBMS_OUTPUT.put:向緩衝區輸入文本，不輸出。
DBMS_OUTPUT.put_line:向緩衝區輸入文本和一個換行符，將緩衝區中的所有文本輸出，之後
清空換行符。
DBMS_OUTPUT.new_line:向緩衝區一個換行符，將緩衝區中的所有文本輸出，之後清空換行符
。
DBMS_OUTPUT.get_line:status：0=調用成功,1=沒有更多行 將緩衝區中的第一行文本提取到
line，並將緩衝區清空。
DBMS_OUTPUT.get_lines:將緩衝區中從第一行開始的numlines行文本提取到lines，並將緩衝
區清空。
*/

-- ▲使用數據字典查尋
SELECT * FROM all_source WHERE name='DBMS_OUTPUT';


-- ➤DBMS_OUTPUT包操作
-- ex:打開緩衝和關閉緩衝
BEGIN 
 DBMS_OUTPUT.enable;
 DBMS_OUTPUT.put_line('此訊息可以正常輸出'); 
END;
/
BEGIN 
 DBMS_OUTPUT.disable;
 DBMS_OUTPUT.put_line('此訊息無法輸出');
END;
/


-- ex:操作緩衝區
BEGIN 
 DBMS_OUTPUT.enable;
 DBMS_OUTPUT.put('www.'); -- 設置緩衝區內容
 DBMS_OUTPUT.put('oracle.com'); -- 設置緩衝區內容
 DBMS_OUTPUT.new_line; -- 換行，輸出之前緩衝區內容
 DBMS_OUTPUT.put('www.google.com');
 DBMS_OUTPUT.new_line;
 DBMS_OUTPUT.put('www.yahoo.com.tw'); -- 向緩衝區增加內容，沒有換行所以沒輸出
END;
/


-- ex:使用get_line()取回緩衝數據
DECLARE 
 v_line1 VARCHAR2(200);
 v_line2 VARCHAR2(200);
 v_line3 VARCHAR2(200);
 v_status NUMBER;
BEGIN 
 DBMS_OUTPUT.enable; -- 開啟緩衝區
 DBMS_OUTPUT.put('www.oracle.com'); -- 設置緩衝區內容
 DBMS_OUTPUT.new_line; -- 換行，輸出之前緩衝區內容
 DBMS_OUTPUT.put('www.google.com');
 DBMS_OUTPUT.new_line;
 DBMS_OUTPUT.put('www.yahoo.com.tw');
 DBMS_OUTPUT.new_line;
 DBMS_OUTPUT.get_line(v_line1, v_status); -- 讀取緩衝區一行數據
 DBMS_OUTPUT.get_line(v_line2, v_status); -- 讀取緩衝區一行數據
 DBMS_OUTPUT.get_line(v_line3, v_status); -- 讀取緩衝區一行數據
 DBMS_OUTPUT.put_line('取得數據: ' || v_line1);
 DBMS_OUTPUT.put_line('取得數據: ' || v_line2); 
 DBMS_OUTPUT.put_line('取得數據: ' || v_line3);
END;
/


-- ex:使用get_lines()取回緩衝數據
DECLARE 
 v_lines DBMS_OUTPUT.chararr;
 v_status NUMBER := 3;
BEGIN 
 DBMS_OUTPUT.enable; -- 開啟緩衝區
 DBMS_OUTPUT.put('www.oracle.com'); -- 設置緩衝區內容
 DBMS_OUTPUT.new_line; -- 換行，輸出之前緩衝區內容
 DBMS_OUTPUT.put('www.google.com');
 DBMS_OUTPUT.new_line;
 DBMS_OUTPUT.put('www.yahoo.com.tw');
 DBMS_OUTPUT.new_line;
 DBMS_OUTPUT.get_lines(v_lines, v_status);
 FOR i IN 1 .. v_lines.COUNT LOOP 
  DBMS_OUTPUT.put_line('緩衝區' || i ||'數據: ' || v_lines(i)); 
 END LOOP;
END;
/


-- ➤DBMS_JOB包
-- 簡述:此包主要功能是實現Oracle的後台作業。
-- 說明:在Oracle的開發過程中，經常需要Oracle定義一些後台進程，以方便數據庫自動的
-- 執行某些操作。而想要實現這樣的後台進程，則可以建立多個調度任務，而調度任務又被
-- 稱為作業，可直接利用DBMS_JOB包來實現。
-- ▲這些後台操作不適合過多，如果過多數據庫的性能會降低。

-- 建立一個自動保存數據的作業
-- ex:定義一個腳本
DROP SEQUENCE job_seq;
DROP TABLE job_data PURGE;
CREATE SEQUENCE job_seq;
CREATE TABLE job_data(
 jid NUMBER,
 title VARCHAR2(20),
 job_date TIMESTAMP,
 CONSTRAINTS pk_jid PRIMARY KEY(jid)
);
-- 現在的作業事項這張表中定時保存數據，而且jid是透過序列生成的。


-- ex:定義一個過程，實現數據的增加
CREATE OR REPLACE PROCEDURE insert_demo_proc(
 p_title job_data.title%TYPE
)
AS 
BEGIN 
 INSERT INTO job_data(jid,title,job_date) 
 VALUES (job_seq.nextval,p_title,SYSDATE);
END;
/


-- 由用戶傳遞title欄位的內容，實現數據的增加。
-- ex:定義作業，每秒執行一次
DECLARE 
 v_jobno NUMBER;
BEGIN 
 DBMS_JOB.submit(
  v_jobno, -- 第一個參數是OUT參數模式，透過OUT取得作業號
  'insert_demo_proc(''作業A'');', -- 執行作業調用的過程
  SYSDATE, -- 作業開始日期
  'SYSDATE+(1/(24*60*60))' -- 作業間隔
 );
 COMMIT;
END;
/


-- 使用數據字典查看作業
SELECT * FROM user_jobs;


-- 查看數據表
SELECT * FROM job_data;


-- ex:修改作業運行間隔，每分鐘執行一次
-- 第一個參數是從數據字典user_jobs中查詢的排稱編號
EXEC DBMS_JOB.interval(5,'SYSDATE+(1/(24*60))');


-- ex:刪除作業
EXEC DBMS_JOB.remove(5);
/*
SYSDATE+1 加一天
SYSDATE+1/24 加1小時
SYSDATE+1/(24*60) 加1分鐘
SYSDATE+1/(24*60*60) 加1秒鐘
*/


-- ➤DBMS_ASSERT包
-- 說明:在編寫SQL語句過程中，經常會出現一些敏感字元無法使用，例如:"'"等。在Oracle
-- 中提供了DBMS_ASSERT包，透過這些包，可以將字串進行轉換。
-- ex:為字串前後加上單引號
SELECT DBMS_ASSERT.enquote_literal('www.google.com') FROM dual;


-- ex:為字串前後加上雙引號
SELECT DBMS_ASSERT.enquote_name('www.google.com') FROM dual;


-- ex:驗證是否為有效模式對象名稱
SELECT DBMS_ASSERT.qualified_sql_name('sun_oracle') FROM dual;
-- ex:錯誤對象名稱
SELECT DBMS_ASSERT.qualified_sql_name('123') FROM dual;
-- ORA-44004: 無效的限定 SQL 名稱


-- ex:驗證字串是否為有效模式名
SELECT DBMS_ASSERT.schema_name('C##SCOTT') FROM dual;
-- ex:錯誤模式名稱
SELECT DBMS_ASSERT.schema_name('EASON') FROM dual;
-- ORA-44001: 無效的綱要


-- ➤DBMS_LOB包
-- 說明:DBMS_LOB包提供了大對象的操作支持，用戶可以直接利用此包實現對CLOB(大文本)
-- 或BLOB(二進制數據，如:圖片、音樂、文字等)類型的直行進行操作。
-- 不建議在開發中使用BLOB類型進行保存，如果真要操作，建議使用程序完成，Java就可
-- 以設置LOB操作。


-- ➤BFILE與DIRECTORY
-- 如果想實現文件的讀取，那麼還需要一種BFILE數據類型。BFILE是外部大型對象(LOB)，
-- 此數據類型存儲在數據庫表空間外的操作系統文件中，BFILE提供了一個指向硬碟物理
-- 文件的一個定位器，所以其只是讀數據，不參與事務處理。
-- 如果想操作BFILE，還需要另一個數據庫對象:DIRECTORY，此對象提供的是BFILE所在服
-- 務器中的文件系統目錄指定別名(映射路徑)。透過給使用者相應的權限，可以直接訪問
-- 此映射路徑來進行文件的安全訪問，而且此目錄的對象所有者是SYS，即:需要透過管理
-- 員進行創建。
-- 創建目錄語法：
-- CREATE OR REPLACE DIRECTORY 映射目錄名稱 AS '硬碟目錄路徑';

-- 第一步:創建一個目錄，目錄路徑為C:\orcls_dir，同時在此目錄中保存一個duke.jpg圖片
-- 文件。


-- 第二步:使用sys登入，創建目錄
CONN sys/change_on_install AS SYSDBA;
CREATE OR REPLACE DIRECTORY orcls_files AS 'C:\orcls_dir';


-- 第三步:由c##scott用戶執行此目錄的操作，所以將目錄的讀寫權限授予c##scott用戶
GRANT READ ON DIRECTORY orcls_files TO c##scott;
GRANT WRITE ON DIRECTORY orcls_files TO c##scott;


-- 第四步:回到c##scott用戶，同時創建數據表
DROP SEQUENCE teacher_seq;
DROP TABLE teacher;
CREATE SEQUENCE teacher_seq;
CREATE TABLE teacher(
 tid NUMBER,
 name VARCHAR2(50) NOT NULL,
 note CLOB,
 photo BLOB,
 CONSTRAINT pk_tid PRIMARY KEY(tid);
 
);


-- 第五步:
DECLARE 
 v_photo teacher.photo%TYPE;
 v_srcfile BFILE; -- 指向來源文件
 v_pos_write INTEGER; -- 文件長度(大小)
BEGIN 
 INSERT INTO teacher(tid,name,note,photo) 
 VALUES (teacher_seq.nextval,'JAVADUKE','吉祥物',empty_blob())
 RETURN photo INTO v_photo; -- 表示把photo的內容交給v_photo進行處理
 v_srcfile := BFILENAME('ORCLS_FILES','DUKE.jpg');
 v_pos_write := DBMS_LOB.getlength(v_srcfile);
 
 -- 文件從硬碟讀入內存
 DBMS_LOB.fileopen(v_srcfile, DBMS_LOB.file_readonly);
 
 -- 把來源文件存到v_photo變數並設置大小
 DBMS_LOB.loadfromfile(v_photo, v_srcfile, v_pos_write);
 
 -- 關閉文件操作
 DBMS_LOB.fileclose(v_srcfile);
END;
/
SELECT * FROM teacher;
ROLLBACK;
-- 首先保存的時候需要設置一個空的blob，同時取得blob欄位的引用關係，然後在單獨
-- 向裡面保存讀取進來的二進制數據。