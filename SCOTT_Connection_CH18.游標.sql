--============================================================================--
--                                                                            --
/* ※游標(紀錄指針)                                                           */
--                                                                            --
--============================================================================--
-- 說明:在JDBC服務之中存在一個ResultSet，那麼所謂的游標只的就是與ResultSet同樣的
-- 功能。ResultSet特徵是可以把數據取出來放在集合之中，然後逐列進行操作。
-- ▲PL/SQL基本結構 + 集合 + 游標 = 開發的基礎。

-- ➤游標簡介
-- 在使用SQL編寫查詢語句時，所有的查詢結果會直接顯示給用戶，但是在很多情況下，用
-- 戶需要對返回結果中的每一條數據分別進行操作，則這個時候普通的查詢語句就無法使
-- 用了，那麼就可以透過結果集(由查詢語句返回完整的列集合叫做結果集)來接收，之後
-- 就可以利用游標來進行操作。
-- 既然會將所有的紀錄都保存在內存裡面，所以游標操作的數據量一定不能太大。

-- 在Oracle數據庫之中，游標分為以下兩種類型:
-- ①靜態游標:結果集已經存在(靜態定義)的游標。分為隱式和顯示游標。
--    隱式游標:所有DML語句為隱式游標，透過隱式游標屬性可以獲取SQL語句訊息。
--    顯示游標:用戶顯示聲明，即指定結果集。當查詢返回結果超過一列時，就需要一個
--    顯示游標。
-- ②REF游標:動態關聯結果集的臨時對象。


-- ➤隱式游標
-- 說明:在PL/SQL塊之中所編寫的每條SQL語句實際上是隱式游標。透過在DML操作之後使用
-- "SQL%ROWCOUNT"屬性，可以知道語句所改變的橫列數(INSERT、UPDATE、DELETE返回更新
-- 橫列數，SELECT返回查詢橫列數)。


-- ➤隱式屬性
-----------------------------------------------------------------------
|No.|屬性     |描述                                                   |
-----------------------------------------------------------------------
|1  |%FOUND   |當用戶使用DML操作數據時，該屬性返回TRUE                |
-----------------------------------------------------------------------
|2  |%ISOPEN  |判斷游標是否打開，該屬性對於任何的隱式游標總是返回FALSE|
|   |         |，表示已經打開                                         |
-----------------------------------------------------------------------
|3  |%NOTFOUND|如果執行DML操作時沒有返回的數據橫列，返回TRUE，否則返回|
|   |         |FALSE                                                  |
-----------------------------------------------------------------------
|4  |%ROWCOUNT|返回更新操作的橫列數或SELECT INTO返回的橫列數          |
-----------------------------------------------------------------------


-- ex:驗證ROWCOUNT
DECLARE 
 v_count NUMBER;
BEGIN 
 SELECT COUNT(*) INTO v_count FROM dept; -- 返回一橫列紀錄
 DBMS_OUTPUT.put_line('SQL%ROWCOUNT = ' || SQL%ROWCOUNT);
END;
/


-- ex:透過新增操作觀察ROWCOUNT
DECLARE 
 v_count NUMBER;
BEGIN 
 INSERT INTO dept (deptno,dname,loc) VALUES (90,'oracle','加州');
 DBMS_OUTPUT.put_line('SQL%ROWCOUNT = ' || SQL%ROWCOUNT);
END;
/


-- ex:透過更新操作觀察ROWCOUNT
DECLARE 
 v_count NUMBER;
BEGIN 
 UPDATE dept SET dname='甲骨文';
 DBMS_OUTPUT.put_line('SQL%ROWCOUNT = ' || SQL%ROWCOUNT);
END;
/
-- 由以上的操作可以發現隱式游標一直存在。


-- 隱式游標也分為兩種:單行隱式游標、多行隱式游標。
-- ➤單行隱式游標
-- 說明:當使用SQL查詢的時候，可以採用"SELECT...INTO..."這樣的結構來把查詢結果設
-- 置給指定變量，那麼這時返回的結果一般都是一橫列數據。
-- ex:操作單行隱式游標
DECLARE 
 v_empRow emp%ROWTYPE; -- 保存emp一橫列數據
BEGIN 
 SELECT * INTO v_empRow FROM emp WHERE empno=7369;
 IF SQL%FOUND THEN
  DBMS_OUTPUT.put_line('員工姓名: ' || v_empRow.ename 
  || '職位: ' || v_empRow.job);
 END IF;
END;
/


-- ➤多行隱式游標
-- 說明:在更新的時候，會返回多橫列的紀錄。
-- ex:操作多行隱式游標
DECLARE 
 
BEGIN 
 --UPDATE emp SET sal=sal*1.2;
 UPDATE emp SET sal=sal*1.2 WHERE 1=2;
 IF SQL%FOUND THEN
  DBMS_OUTPUT.put_line('更新紀錄橫列數: ' || SQL%ROWCOUNT);
 ELSE 
  DBMS_OUTPUT.put_line('沒有紀錄被修改');
 END IF;
END;
/


-- ➤顯式游標
-- 說明:隱式游標是用戶操作SQL時自動生成的，而顯示游標指的是在聲明塊中直接定義的
-- 游標，而在每一個游標之中，都會保存SELECT查詢後的返回結果。
/*
創建語法:
CURSOR 游標名稱([參數列表])[RETURN 返回值類型]
 IS 子查詢
[FOR UPDATE[OF 數據直行,數據直行][NOWAIT]];

在PL/SQL中顯示游標的操作步驟如下:
①聲明游標(CURSOR 游標名稱 IS 查詢語句)。使用CURSOR定義。
②為查詢打開游標(語法:OPEN游標名稱)。使用OPEN操作，當游標打開時會首先檢查綁定此游
標的變量內容，之後再確定所使用的查詢結果集，最後游標將指針指向結果集的第1橫列。
如果用戶定義的是一個帶有參數的游標，則會在打開游標時位游標設置指定的參數值。
③取得結果放入PL/SQL變量中(語法:FETCH 游標名稱 INTO ROWTYPE變量)。使用循環和
 FETCH...INTO...操作。
④關閉游標(語法:CLOSE 游標名稱)。使用CLOSE操作。
*/
-- ▲游標每一次是取得一橫列紀錄，所以這一橫列都會使用ROWTYPE進行保存。

-- ➤顯式游標屬性
-----------------------------------------------------------------------
|No.|屬性     |描述                                                   |
-----------------------------------------------------------------------
|1  |%FOUND   |光標打開後未曾執行FETCH，則值為NULL;如果最近一次在該光 |
|   |         |標上執行的FETCH返回一橫列，則值為TRUE，否則為FALSE     |
-----------------------------------------------------------------------
|2  |%ISOPEN  |如果光標示打開的狀態則值為TRUE，否則值為FALSE          |
-----------------------------------------------------------------------
|3  |%NOTFOUND|如果光標最近一次FETCH語句沒有返回橫列，則值為TRUE，否則|
|   |         |值為FALSE。如果光標剛剛打開還未執行FETCH，則值為NULL   |
-----------------------------------------------------------------------
|4  |%ROWCOUNT|其值在該光標上到目前為止執行FETCH語句所返回的橫列數。光|
|   |         |標打開時，%ROWTYPE初始化為零，每執行一次FETCH如果返回一|
|   |         |橫列則%ROWTYPE增加1                                    |
-----------------------------------------------------------------------


-- ex:定義顯式游標
DECLARE 
 CURSOR cur_emp IS SELECT * FROM emp;
 v_empRow emp%ROWTYPE; -- 保存一橫列紀錄
BEGIN  
 -- 游標如果要操作一定要保證其已經打開
 IF cur_emp%ISOPEN THEN
  NULL; -- 什麼都不做 
 ELSE 
  OPEN cur_emp; --  打開游標
 END IF;
  -- 默認情況架游標在第一橫列紀錄上
 FETCH cur_emp INTO v_empRow; -- 取得當前橫列數據 
  DBMS_OUTPUT.put_line(cur_emp%ROWCOUNT || 
  ', 員工姓名: ' || v_empRow.ename || 
  ', 職位: ' || v_empRow.job || 
  ', 工資: ' || v_empRow.sal);
 CLOSE cur_emp; 
END;
/
-- 此時是利用FETCH取得第一橫列數據，因為打開游標默認就在第一橫列數據上。但所取出
-- 的數據一共有14條紀錄。


-- ex:取得全部數據
DECLARE 
 CURSOR cur_emp IS SELECT * FROM emp;
 v_empRow emp%ROWTYPE; -- 保存一橫列紀錄
BEGIN  
 -- 游標如果要操作一定要保證其已經打開
 IF cur_emp%ISOPEN THEN
  NULL; -- 什麼都不做 
 ELSE 
  OPEN cur_emp; --  打開游標
 END IF;
  -- 默認情況架游標在第一橫列紀錄上
 FETCH cur_emp INTO v_empRow; -- 取得當前橫列數據 
 WHILE cur_emp%FOUND LOOP
  DBMS_OUTPUT.put_line(cur_emp%ROWCOUNT || 
  ', 員工姓名: ' || v_empRow.ename || 
  ', 職位: ' || v_empRow.job || 
  ', 工資: ' || v_empRow.sal);
  FETCH cur_emp INTO v_empRow; -- 把游標指向下一橫列
 END LOOP;
 CLOSE cur_emp; 
END;
/
 

-- note:游標在操作之前一定要保證是打開的，而且游標關閉後也無法再使用。
-- ex:游標尚未開啟
DECLARE 
 CURSOR cur_emp IS SELECT * FROM emp;
 v_empRow emp%ROWTYPE; -- 保存一橫列紀錄
BEGIN 
  -- 默認情況架游標在第一橫列紀錄上
 FETCH cur_emp INTO v_empRow; -- 取得當前橫列數據 
 WHILE cur_emp%FOUND LOOP
  DBMS_OUTPUT.put_line(cur_emp%ROWCOUNT || 
  ', 員工姓名: ' || v_empRow.ename || 
  ', 職位: ' || v_empRow.job || 
  ', 工資: ' || v_empRow.sal);
  FETCH cur_emp INTO v_empRow; -- 把游標指向下一橫列
 END LOOP;
 CLOSE cur_emp;
EXCEPTION 
 WHEN INVALID_CURSOR THEN 
  DBMS_OUTPUT.put_line('程序出錯 SQLCODE = ' || SQLCODE 
  || ', SQLERRM = ' || SQLERRM);  
END;
/
-- 錯誤報告:ORA-01001: 無效的游標


-- ex:游標關閉後無法在進行操作
DECLARE 
 CURSOR cur_emp IS SELECT * FROM emp;
 v_empRow emp%ROWTYPE; -- 保存一橫列紀錄
BEGIN  
 -- 游標如果要操作一定要保證其已經打開
 IF cur_emp%ISOPEN THEN
  NULL; -- 什麼都不做 
 ELSE 
  OPEN cur_emp; --  打開游標
 END IF; 
 CLOSE cur_emp; 
  -- 默認情況架游標在第一橫列紀錄上
 FETCH cur_emp INTO v_empRow; -- 取得當前橫列數據 
 WHILE cur_emp%FOUND LOOP
  DBMS_OUTPUT.put_line(cur_emp%ROWCOUNT || 
  ', 員工姓名: ' || v_empRow.ename || 
  ', 職位: ' || v_empRow.job || 
  ', 工資: ' || v_empRow.sal);
  FETCH cur_emp INTO v_empRow; -- 把游標指向下一橫列
 END LOOP;
END;
/
-- 錯誤報告:ORA-01001: 無效的游標


-- ex:使用LOOP循環操作游標
DECLARE 
 CURSOR cur_emp IS SELECT * FROM emp;
 v_empRow emp%ROWTYPE; -- 保存一橫列紀錄
BEGIN  
 -- 游標如果要操作一定要保證其已經打開
 IF cur_emp%ISOPEN THEN
  NULL; -- 什麼都不做 
 ELSE 
  OPEN cur_emp; --  打開游標
 END IF; 
  -- 默認情況架游標在第一橫列紀錄上 
 LOOP
  FETCH cur_emp INTO v_empRow; -- 取得當前橫列數據 
  EXIT WHEN cur_emp%NOTFOUND; -- 沒有數據退出循環
  DBMS_OUTPUT.put_line(cur_emp%ROWCOUNT || 
  ', 員工姓名: ' || v_empRow.ename || 
  ', 職位: ' || v_empRow.job || 
  ', 工資: ' || v_empRow.sal);
 END LOOP;
 CLOSE cur_emp;
END;
/

-- 無論是WHILE或是LOOP都需要先打開游標然後再操作游標，所以對於游標最方便的作法是
-- 使用FOR循環完成。
-- ex:使用FOR循環操作游標
DECLARE 
 CURSOR cur_emp IS SELECT * FROM emp;
 v_empRow emp%ROWTYPE; -- 保存一橫列紀錄
BEGIN  
 FOR v_empRow IN cur_emp LOOP -- 游標所在的一橫列紀錄(v_empRow)上
  DBMS_OUTPUT.put_line(cur_emp%ROWCOUNT || 
  ', 員工姓名: ' || v_empRow.ename || 
  ', 職位: ' || v_empRow.job || 
  ', 工資: ' || v_empRow.sal);
 END LOOP;
END;
/
-- 使用FOR循環進行游標操作的時候，可以不再處理打開和關閉等操作，所以這種操作是最
-- 方便的。


-- 還有更方便的方式是，連游標都不必聲明。
-- ex:
DECLARE 
BEGIN  
 FOR v_empRow IN (SELECT * FROM emp) LOOP 
  DBMS_OUTPUT.put_line(
  '員工姓名: ' || v_empRow.ename || 
  ', 職位: ' || v_empRow.job || 
  ', 工資: ' || v_empRow.sal);
 END LOOP;
END;
/
-- 但這種方式就無法進行游標屬性的操作。


-- 對於游標中的數據也可以將其保存在索引表中，那麼就可以直接採用下標的方式進行數
-- 據的訪問。
-- ex:將游標保存在索引表中
DECLARE 
 CURSOR cur_emp IS SELECT * FROM emp;
 TYPE emp_index  IS TABLE OF emp%ROWTYPE INDEX BY PLS_INTEGER;
 v_emp emp_index;
BEGIN  
 FOR emp_row IN cur_emp LOOP -- 游標所在的一橫列(emp_row)紀錄
 
  -- 游標所在的一橫列(emp_row)紀錄的內容 = v_emp索引變數的下標
  -- 帶入游標所在的一橫列紀錄的員工編號。
  v_emp(emp_row.empno) := emp_row; 
 END LOOP;
 -- 現在索引表中存放14條完整的員工訊息，可透過v_emp(員工編號)取得。
 DBMS_OUTPUT.put_line('員工編號: ' || v_emp(7369).empno ||
  '員工姓名: ' || v_emp(7369).ename || 
  ', 職位: ' || v_emp(7369).job || 
  ', 工資: ' || v_emp(7369).sal);
END;
/


-- 以上都是在一個固定的SQL語句之中使用游標，那麼也可以透過替代變量設置一個動態的
-- SELECT查詢。
-- ex:在動態SELECT中使用游標
DECLARE 
 v_lowsal emp.sal%TYPE := &inputLowsal; 
 v_highsal emp.sal%TYPE := &inputHighsal;
 CURSOR cur_emp IS SELECT * FROM emp WHERE sal BETWEEN v_lowsal AND v_highsal;
BEGIN  
 FOR emp_row IN cur_emp LOOP -- 游標所在的一橫列(emp_row)紀錄  
  DBMS_OUTPUT.put_line(cur_emp%ROWCOUNT || 
  ', 員工姓名: ' || emp_row.ename || 
  ', 職位: ' || emp_row.job || 
  ', 工資: ' || emp_row.sal);
 END LOOP;
END;
/


-- 游標本身也可以進行參數傳遞，這種操作稱為參數游標。
-- ex:定義參數游標
DECLARE 
 CURSOR cur_emp(p_dno emp.deptno%TYPE) IS 
 SELECT * FROM emp WHERE deptno=p_dno;
BEGIN  
 FOR emp_row IN cur_emp(&inputDeptno) LOOP -- 游標所在的一橫列(emp_row)紀錄  
  DBMS_OUTPUT.put_line(cur_emp%ROWCOUNT || 
  ', 員工姓名: ' || emp_row.ename || 
  ', 職位: ' || emp_row.job || 
  ', 工資: ' || emp_row.sal);
 END LOOP;
END;
/


-- 如果用戶現在使用的是嵌套表保存游標內容，那麼在游標中還有一個方便的支持，利用
-- FETCH BULK COLLECT語句可以一次性取出游標中的全部內容。
-- ex:嵌套表接收游標數據
DECLARE 
 TYPE dept_nested IS TABLE OF dept%ROWTYPE; -- 定義一橫列紀錄的嵌套表類型
 v_dept dept_nested;
 CURSOR cur_dept IS SELECT * FROM dept;
BEGIN 
 IF cur_dept%ISOPEN THEN
  NULL; -- 什麼都不做 
 ELSE 
  OPEN cur_dept; --  打開游標
 END IF; 
 
 -- 保存整個游標;所有游標數據都保存在v_dept集合(嵌套表)裡面 
 FETCH cur_dept BULK COLLECT INTO v_dept;
 
 FOR i IN v_dept.FIRST .. v_dept.LAST LOOP  
  DBMS_OUTPUT.put_line(
  '部門編號: ' || v_dept(i).deptno || 
  ', 名稱: ' || v_dept(i).dname || 
  ', 位置: ' || v_dept(i).loc);
 END LOOP;
 CLOSE cur_dept;
END;
/
-- 這種操作即使在游標被關閉之後，數據也可以使用，但數據不應該太大。若萬一害怕數
-- 據太大，那最簡單的做法是使用可變陣列保存。


-- 想限制取得數據量，使用FETCH 游標名稱 BULK COLLECT INTO ... LIMIT操作。
-- ex:將游標數據保存在可變陣列中
DECLARE 
 TYPE dept_varray IS VARRAY(2) OF dept%ROWTYPE; -- 定義一橫列紀錄的可變陣列類型
 v_dept dept_varray;
 CURSOR cur_dept IS SELECT * FROM dept;
 v_rows NUMBER := 2; -- 每次提取2橫列紀錄
 --v_count NUMBER := 1; -- 每次少顯示1橫列紀錄
BEGIN 
 IF cur_dept%ISOPEN THEN
  NULL; -- 什麼都不做 
 ELSE 
  OPEN cur_dept; --  打開游標
 END IF; 
 
 -- 保存指定橫列數;指定橫列範圍數據都保存在v_dept集合(可變陣列)裡面 
 FETCH cur_dept BULK COLLECT INTO v_dept LIMIT v_rows;
 
 CLOSE cur_dept;
 FOR i IN v_dept.FIRST .. v_dept.LAST LOOP 
 --FOR i IN v_dept.FIRST .. v_dept.LAST-v_count LOOP 
  DBMS_OUTPUT.put_line(
  '部門編號: ' || v_dept(i).deptno || 
  ', 名稱: ' || v_dept(i).dname || 
  ', 位置: ' || v_dept(i).loc);
 END LOOP;
END;
/


-- ➤修改游標數據
-- 簡述:游標是數據一條一條進行操作的，以下利用游標完成一個簡單的數據更新操作。
-- ex:一次上漲所有人的工資，工資上漲原則如下，但工資上漲上限為5000:
-- 10部門上漲15%
-- 20部門上漲22%
-- 30部門上漲39%
DECLARE 
 CURSOR cur_emp IS SELECT * FROM emp; -- emp表游標數據
BEGIN 
 FOR emp_row IN cur_emp LOOP 
  IF emp_row.deptno=10 THEN 
   IF emp_row.sal*1.15<5000 THEN 
    UPDATE emp SET sal=sal*1.15 WHERE empno=emp_row.empno;
   ELSE 
    UPDATE emp SET sal=5000 WHERE empno=emp_row.empno;
   END IF;	
  ELSIF emp_row.deptno=20 THEN 
    IF emp_row.sal*1.15<5000 THEN 
    UPDATE emp SET sal=sal*1.22 WHERE empno=emp_row.empno;
   ELSE 
    UPDATE emp SET sal=5000 WHERE empno=emp_row.empno;
   END IF;
  ELSIF emp_row.deptno=30 THEN 
    IF emp_row.sal*1.15<5000 THEN 
    UPDATE emp SET sal=sal*1.39 WHERE empno=emp_row.empno;
   ELSE 
    UPDATE emp SET sal=5000 WHERE empno=emp_row.empno;
   END IF;
  ELSE 
   NULL;
  END IF;
 END LOOP;
EXCEPTION 
 WHEN OTHERS THEN
  DBMS_OUTPUT.put_line('SQLCODE = ' || SQLCODE);
  DBMS_OUTPUT.put_line('SQLERRM = ' || SQLERRM);
  ROLLBACK;
END;
/
SELECT * FROM emp;


-- ➤FOR UPDATE子句
-- 說明:如果創建的游標需要執行更新或刪除的操作必須帶有FOR UPDATE子句。FOR UPDATE
-- 子句會將游標提取出來的數據進行行級鎖定，這樣在本會話更新期間，其他用戶的會話
-- 就不能對當前游標中的數據橫列進行更新操作，而在使用FOR UPDATE語句時可使用如下
-- 兩種形式:
-- ①FOR UPDATE[OF 直行,直行...]
-- 此語句將位游標中的數據直行進行行級鎖定，這樣游標在更新時，其他用戶的會話將無
-- 法更新指定數據。
-- ②FOR UPDATE NOWAIT
-- 在Oracle之中，所有的事務都是具備隔離性的，當一個用戶會話更新數據且事務位提交
-- 時，其他用戶會話是無法對數據進行更新的，如果此時執行游標數據的更新操作，那麼
-- 就會進入到死鎖的狀態。為了避免游標出現死鎖的情況，可以在創建的時候使用
-- FOR UPDATE NOWAIT子句，如果發現所操作的數據橫列已經被鎖定，將不會等待，立即
-- 返回。

-- ex:創建不等待的游標
-- 用戶1:操作數據更新，未提交事務，不等待資源
DECLARE 
 CURSOR cur_emp IS SELECT * FROM emp WHERE deptno=10 FOR UPDATE NOWAIT;
BEGIN 
 FOR emp_row IN cur_emp LOOP 
  UPDATE emp SET sal=9999 WHERE empno=emp_row.empno;
 END LOOP;
END;
/
ROLLBACK;
-- 用戶2:操作數據刪除，未提交事務，鎖定資源
CONN c##scott/tiger;
DELETE FROM emp;
ROLLBACK;
--錯誤報告:ORA-00054: 資源正被使用中, 請設定 NOWAIT 來取得它, 否則逾時到期


-- 使用FOR UPDATE語句可以設置行級鎖定操作，此時可以利用WHERE CURRENT OF子句來進
-- 行當前橫列的更新或刪除操作。
-- ex:使用:WHERE CURRENT OF子句
DECLARE 
 CURSOR cur_emp IS SELECT * FROM emp WHERE deptno=10 FOR UPDATE;
BEGIN 
 FOR emp_row IN cur_emp LOOP 
  UPDATE emp SET sal=9999 WHERE CURRENT OF cur_emp;-- 表示更新"當前橫列"游標數據
 END LOOP;
END;
/
ROLLBACK;


-- 在直行上也可以進行設置，就算設置的是直行也表示行級鎖定的概念。
-- ex:直行行級鎖定
DECLARE 
 CURSOR cur_emp IS SELECT * FROM emp WHERE deptno=10 FOR UPDATE OF sal,comm;
BEGIN 
 FOR emp_row IN cur_emp LOOP 
  UPDATE emp SET sal=9999 WHERE CURRENT OF cur_emp;-- 表示更新"當前橫列"游標數據
 END LOOP;
END;
/
ROLLBACK;
-- 鎖定欄位和橫列的區別不大，是完全相同的。


-- ex:刪除游標數據橫列
DECLARE 
 CURSOR cur_emp IS SELECT * FROM emp WHERE deptno=10 FOR UPDATE OF sal,comm;
BEGIN 
 FOR emp_row IN cur_emp LOOP 
  DELETE FROM emp WHERE CURRENT OF cur_emp;-- 表示刪除"當前橫列"游標數據
 END LOOP;
END;
/
ROLLBACK;


-- 問題:那麼FOR UPDATE和FOR UPDATE OF 欄位有什麼區別呢?
-- 如果想解釋這兩者的區別，則須結合多表查詢來觀察。
-- ex:創建一個多表查詢操作(FOR UPDATE)
DECLARE 
 CURSOR cur_emp IS 
 SELECT e.ename, e.job, e.sal, d.dname, d.loc
 FROM emp e, dept d 
 WHERE e.deptno=d.deptno AND e.deptno=10 FOR UPDATE;
BEGIN 
 FOR emp_row IN cur_emp LOOP 
  UPDATE emp SET sal=9999 WHERE CURRENT OF cur_emp;-- 表示更新"當前橫列"游標數據
 END LOOP;
END;
/
ROLLBACK;
-- 執行後結果數據並沒有更新


-- ex:使用FOR UPDATE OF 欄位，針對要更新的欄位進行鎖定
DECLARE 
 CURSOR cur_emp IS 
 SELECT e.ename, e.job, e.sal, d.dname, d.loc
 FROM emp e, dept d 
 WHERE e.deptno=d.deptno AND e.deptno=10 FOR UPDATE OF sal;
BEGIN 
 FOR emp_row IN cur_emp LOOP 
  UPDATE emp SET sal=9999 WHERE CURRENT OF cur_emp;-- 表示更新"當前橫列"游標數據
 END LOOP;
END;
/
ROLLBACK;
-- 執行後結果數據成功更新


-- ➤游標變量
-- 說明:在前面所定義的游標都是針對一條固定的SQL查詢語句而定義的，這樣的游標可以
-- 統一稱為靜態游標。而除了這種靜態游標之外也可以在定義游標時不綁定具體的查詢，
-- 而是動態的打開指定類型的查詢，這樣的作法就會更加靈活。
/*
定義游標變量類型語法:
TYPE 游標變量類型名稱 IS REF CURSOR [RETURN 數據類型];
如果寫上了RETURN那麼就表示是一種強類型的定義，如果不寫RETURN就表示弱類型定義，強
類型的話其查詢的語句結構必須與聲明的一致，而如果是弱類型就可以在使用的時候動態決
定操作。
*/
-- note:在使用游標變量的時候無法使用FOR循環輸出，只能夠利用LOOP循環完成。

-- ex:觀察強類型的游標變量，使用dept
DECLARE 
 TYPE dept_ref IS REF CURSOR RETURN dept%ROWTYPE; -- 定義強類型的游標類型
 cur_dept dept_ref; -- 定義游標變量
 v_dpetRow dept%ROWTYPE; -- 定義橫列類型
BEGIN 
 OPEN cur_dept FOR SELECT * FROM dept;-- 打開游標並決定游標類型
 LOOP 
  FETCH cur_dept INTO v_dpetRow; -- 取得游標數據
  EXIT WHEN cur_dept%NOTFOUND; -- 如果沒有數據就離開迴圈
  DBMS_OUTPUT.put_line('部門名稱 : ' || v_dpetRow.dname 
  || ', 部門位置: ' || v_dpetRow.loc);
 END LOOP;
 CLOSE cur_dept;
END;
/


-- ex:觀察弱類型的游標變量，使用dept決定游標類型
DECLARE 
 TYPE dept_ref IS REF CURSOR; -- 定義弱類型的游標類型
 cur_dept dept_ref; -- 定義游標變量
 v_dpetRow dept%ROWTYPE; -- 定義橫列類型
BEGIN 
 OPEN cur_dept FOR SELECT * FROM dept;-- 打開游標並決定游標類型
 LOOP 
  FETCH cur_dept INTO v_dpetRow; -- 取得游標數據
  EXIT WHEN cur_dept%NOTFOUND; -- 如果沒有數據就離開迴圈
  DBMS_OUTPUT.put_line('部門名稱 : ' || v_dpetRow.dname 
  || ', 部門位置: ' || v_dpetRow.loc);
 END LOOP;
 CLOSE cur_dept;
END;
/
-- 操作弱類型須注意的是，操作的游標類型(v_dpetRow)要與設置的SQL的返回類型
-- (cur_dept)一致。


-- ex:錯誤的操作，使用emp決定游標類型
DECLARE 
 TYPE dept_ref IS REF CURSOR; -- 定義弱類型的游標類型
 cur_dept dept_ref; -- 定義游標變量
 v_dpetRow dept%ROWTYPE; -- 定義橫列類型
BEGIN 
 OPEN cur_dept FOR SELECT * FROM emp;-- 打開游標並決定游標類型
 LOOP 
  FETCH cur_dept INTO v_dpetRow; -- 取得游標數據
  EXIT WHEN cur_dept%NOTFOUND; -- 如果沒有數據就離開迴圈
  DBMS_OUTPUT.put_line('部門名稱 : ' || v_dpetRow.dname 
  || ', 部門位置: ' || v_dpetRow.loc);
 END LOOP;
 CLOSE cur_dept;
END;
/
-- 錯誤報告:ORA-06504: PL/SQL: 傳回結果設定變數的類型或查詢不相符


-- ex:增加異常處理，解決錯誤操作
DECLARE 
 TYPE dept_ref IS REF CURSOR; -- 定義弱類型的游標類型
 cur_dept dept_ref; -- 定義游標變量
 v_dpetRow dept%ROWTYPE; -- 定義橫列類型
BEGIN 
 OPEN cur_dept FOR SELECT * FROM emp;-- 打開游標並決定游標類型
 LOOP 
  FETCH cur_dept INTO v_dpetRow; -- 取得游標數據
  EXIT WHEN cur_dept%NOTFOUND; -- 如果沒有數據就離開迴圈
  DBMS_OUTPUT.put_line('部門名稱 : ' || v_dpetRow.dname 
  || ', 部門位置: ' || v_dpetRow.loc);
 END LOOP;
 CLOSE cur_dept;
EXCEPTION 
 WHEN ROWTYPE_MISMATCH THEN
  DBMS_OUTPUT.put_line('游標數據類型不批配異常 SQLCODE = ' || 
  SQLCODE || ', SQLERRM = ' || SQLERRM);
END;
/


-- 雖然弱類型的游標變量存在一些問題，但它也是有自己的優點。觀察如下代碼:
-- ex:使用弱類型操作
DECLARE 
 TYPE cursor_ref IS REF CURSOR; -- 定義弱類型的游標類型
 cur_var cursor_ref; -- 定義游標變量
 v_dpetRow dept%ROWTYPE; -- 定義橫列類型
 v_empRow emp%ROWTYPE; -- 定義橫列類型
BEGIN 
 OPEN cur_var FOR SELECT * FROM dept;-- 打開游標並決定游標類型
 LOOP 
  FETCH cur_var INTO v_dpetRow; -- 取得游標數據
  EXIT WHEN cur_var%NOTFOUND; -- 如果沒有數據就離開迴圈
  DBMS_OUTPUT.put_line('<1> 部門名稱 : ' || v_dpetRow.dname 
  || ', 部門位置: ' || v_dpetRow.loc);
 END LOOP;
 CLOSE cur_var;
 DBMS_OUTPUT.put_line('------------------------');
 OPEN cur_var FOR SELECT * FROM emp WHERE deptno=10;-- 打開游標並決定游標類型
 LOOP 
  FETCH cur_var INTO v_empRow; -- 取得游標數據
  EXIT WHEN cur_var%NOTFOUND; -- 如果沒有數據就離開迴圈
  DBMS_OUTPUT.put_line('<2> 員工姓名 : ' || v_empRow.ename
  || ', 職位: ' || v_empRow.job);
 END LOOP;
 CLOSE cur_var;
EXCEPTION 
 WHEN ROWTYPE_MISMATCH THEN
  DBMS_OUTPUT.put_line('游標數據類型不批配異常 SQLCODE = ' || 
  SQLCODE || ', SQLERRM = ' || SQLERRM);
END;
/


-- 在Oracle 9i中為了方便用戶使用弱類型定義，提供了一個"SYS_REFCURSOR"來代替之前
-- 的游標變量的聲明。
-- ex:使用SYS_REFCURSOR定義弱類型游標
DECLARE 
 --TYPE cursor_ref IS REF CURSOR; -- 定義弱類型的游標類型
 cur_var SYS_REFCURSOR; -- 定義游標變量
 v_dpetRow dept%ROWTYPE; -- 定義橫列類型
 v_empRow emp%ROWTYPE; -- 定義橫列類型
BEGIN 
 OPEN cur_var FOR SELECT * FROM dept;-- 打開游標並決定游標類型
 LOOP 
  FETCH cur_var INTO v_dpetRow; -- 取得游標數據
  EXIT WHEN cur_var%NOTFOUND; -- 如果沒有數據就離開迴圈
  DBMS_OUTPUT.put_line('<1> 部門名稱 : ' || v_dpetRow.dname 
  || ', 部門位置: ' || v_dpetRow.loc);
 END LOOP;
 CLOSE cur_var;
 DBMS_OUTPUT.put_line('------------------------');
 OPEN cur_var FOR SELECT * FROM emp WHERE deptno=10;-- 打開游標並決定游標類型
 LOOP 
  FETCH cur_var INTO v_empRow; -- 取得游標數據
  EXIT WHEN cur_var%NOTFOUND; -- 如果沒有數據就離開迴圈
  DBMS_OUTPUT.put_line('<2> 員工姓名 : ' || v_empRow.ename
  || ', 職位: ' || v_empRow.job);
 END LOOP;
 CLOSE cur_var;
EXCEPTION 
 WHEN ROWTYPE_MISMATCH THEN
  DBMS_OUTPUT.put_line('游標數據類型不批配異常 SQLCODE = ' || 
  SQLCODE || ', SQLERRM = ' || SQLERRM);
END;
/