--============================================================================--
--                                                                            --
/* ※物件導向-物件導向基本慨念                                                */
--                                                                            --
--============================================================================--
-- ▲物件導向的主要特性:封裝、繼承、多型。
-- ▲在物件導向中類和實例(物件)是最基本、最重要的組成單元。


--============================================================================--
--                                                                            --
/* ※物件導向-定義對象類型-類                                                 */
--                                                                            --
--============================================================================--
-- ➤類的定義
-- 說明:在PL/SQL中對象類型的定義與包的定義格式是非常相似的，由兩部份組成:
-- ①對象規範(或稱為類規範):定義對象的公共操作標準，例如:公共屬性或子程序。
-- ②對象體(或稱為類體):實現對象類型規範中的公共子程序。
/*
類規範定義格式:
CREATE [OR REPLACE] TYPE 類規範名稱
[AUTHID CURRENT_USER|DEFINER]
[IS|AS] OBJECT|UNDER 父規範類型名稱(
 屬性名稱 數據類型 ,...
 [MAP|ORDER] MEMBER 函數名稱 ,
 [FINAL|NOTFINAL] MEMBER 函數名稱 ,
 [INSTANTIABLE|NOTINSTANTIABLE] MEMBER 函數名稱 ,
 CONSTRUCTOR MEMBER 子程序名稱 ,...
 OVERRIDING MEMBER 子程序名稱 ,...
 [MEMBER|STATIC] 子程序名稱 ,...
)[FINAL|NOTFINAL]
[INSTANTIABLE|NOTINSTANTIABLE];
/
*/

-- ➤物件導向的實現語法差別
-- 說明:
----------------------------------------------------------------------------------
|No.|結構              |PL/SQL                        |Java                      |
----------------------------------------------------------------------------------
|1  |類名稱            |對象規範名稱                  |[public|protected]        |
----------------------------------------------------------------------------------
|   |                  |                              |class 類名稱              |
----------------------------------------------------------------------------------
|2  |屬性              |屬性名稱 數據類型 ,...        |[public|protected|private]|
|   |                  |                              | 數據類型 屬性名稱        |
----------------------------------------------------------------------------------
|3  |排序              |[MAP|ORDER] MEMBER 函數名稱   |實現Comparable或Comparator|
|   |                  |                              |介面                      |
----------------------------------------------------------------------------------
|4  |方法(函數)        |[FINAL|NOTFINAL] MEMBER       |[public|protected|private]|
|   |                  |函數名稱                      |[final]返回值類型 方法名稱|
|   |                  |                              |(參數列表)                |
----------------------------------------------------------------------------------
|5  |抽象方法          |[INSTANTIABLE|NOTINSTANTIABLE]|[public|protected|private]|
|   |                  |MEMBER 函數名稱               |abstrsct 返回值類型 方法名|
|   |                  |                              |稱(參數列表)              |
----------------------------------------------------------------------------------
|6  |普通方法與靜態方法|[MEMBER|STATIC] 子程序名稱    |[public|protected|private]|
|   |                  |                              |[final][static] 返回值類型|
|   |                  |                              | 方法名稱(參數列表)       |
----------------------------------------------------------------------------------
|7  |不能被繼承的父類  |[FINAL|NOTFINAL]              |[public|protected] final  |
|   |                  |                              |class 類名稱              |
----------------------------------------------------------------------------------

-- ➤定義類體
-- 說明:除了定義對象規範外，還需要針對對象規範定義實現對象體。
/*
CREATE [OR REPLACE] TYPE BODY 對象規範名稱 [IS|AS]
[MAP|ORDER] MEMBER 函數體;
[MEMBER|STATIC] 子程序體 ,...
END;
/
*/

-- ex:定義類規範
CREATE OR REPLACE TYPE emp_object IS OBJECT(
 -- 定義對象屬性，與emp表對應
 atri_empno NUMBER(4), -- 員工編號
 atri_sal NUMBER(7,2), -- 員工工資
 atri_deptno NUMBER(2), -- 部門編號
 
 -- 定義對象操作方法
 -- 此過程的功能是根據部門編號按照一定的百分比增長員工工資
 MEMBER PROCEDURE change_dept_sal_proc(
  p_deptno NUMBER,
  p_precent NUMBER
 ),
 
 -- 取得指定員工的工資(基本工資和傭金)
 MEMBER FUNCTION get_sal_fun(
  p_empno NUMBER
 ) RETURN NUMBER
) NOT FINAL;
/


-- ex:定義類體
CREATE OR REPLACE TYPE BODY emp_object 
IS 
 -- 實現過程
 MEMBER PROCEDURE change_dept_sal_proc(
  p_deptno NUMBER,
  p_precent NUMBER
 )
 IS 
 BEGIN 
  UPDATE emp SET sal=sal*(1+p_precent) WHERE deptno=p_deptno;
 END;
 
 -- 實現函數
 MEMBER FUNCTION get_sal_fun(
  p_empno NUMBER
 ) RETURN NUMBER 
 IS 
  v_sal emp.sal%TYPE;
  v_comm emp.comm%TYPE;
 BEGIN 
  SELECT sal, NVL(comm,0) INTO v_sal, v_comm FROM emp WHERE empno=p_empno;
  RETURN v_sal+v_comm;
 END;
END;
/
-- ▲類規範 + 類體 = 類


-- 現在有了類，如果想操作類，那麼就必須存在對象，而有了對象後就可以使用
-- "對象.屬性"、"對象.函數()"進行類結構的操作。
-- ex:聲明並使用對象
DECLARE 
 v_emp emp_object; -- 宣告物件
BEGIN 
 -- 實例化物件，對類規範屬性賦值
 v_emp := emp_object(8871,880.5,20);
 
 -- 修改物件中的工資數據
 v_emp.atri_sal := 1000;
 DBMS_OUTPUT.put_line(v_emp.atri_empno || '員工修改後的工資: ' 
 || v_emp.atri_sal);
 
 -- 調用函數
 DBMS_OUTPUT.put_line('部門工資修改前, 7566員工的總工資: ' || 
 v_emp.get_sal_fun(7566));
 
 -- 調用過程
 v_emp.change_dept_sal_proc(20, 0.3);
 DBMS_OUTPUT.put_line('部門工資修改後, 7566員工的總工資: ' || 
 v_emp.get_sal_fun(7566));
END;
/

ROLLBACK;
-- 有了類之後，利用對象就可以結構化的方式進行操作。


-- ex:刪除類規範
DROP TYPE emp_object;
--============================================================================--
--                                                                            --
/* ※物件導向-操作類中的其他結構                                              */
--                                                                            --
--============================================================================--
-- ➤定義函數
-- 說明:在PL/SQL定義的類中，函數的定義有兩種方式
-- ①MEMBER型函數:此函數需要透過對象來進行定義，使用MEMBER定義的函數可以利用
-- "SELF"關鍵字來訪問類中的屬性內容。
-- ②STATIC型函數:此函數獨立於類之外，可以直接透過類名稱進行調用，使用STATIC定義
-- 的函數無法訪問類中的屬性。

-- ▲SELF關鍵字與Java中的this關鍵字的作用是相同，在Java中，this.屬性訪問的是本類
-- 屬性，那麼SELF.屬性訪問的也是本類中定義的屬性。
-- ▲Java中使用ststic定義的方法可以透過對象與類名稱進行調用，雖然是在類之中，但是
-- 卻不受類對象的控制，獨立於類之外。
-- ex:使用兩種不同的方式來定義函數
-- 1.定義類規範
CREATE OR REPLACE TYPE emp_object IS OBJECT(
 -- 員工編號
 atri_empno NUMBER(4),
 
 -- 修改當前員工編號的工資，員工編號透過屬性設置
 MEMBER PROCEDURE change_emp_sal_proc(
  p_sal NUMBER
 ),
 
 -- 取得當前員工工資
 MEMBER FUNCTION get_emp_sal_fun 
 RETURN NUMBER,
 
 -- 修改指定部門中的所有員工工資
 STATIC PROCEDURE change_dept_sal_proc(
  p_deptno NUMBER,
  p_sal NUMBER
 ),
 
 -- 取的此部門員工的工資總和
 STATIC FUNCTION get_dept_sal_sum_fun(
  p_deptno NUMBER
 ) RETURN NUMBER
) NOT FINAL;
/
-- 2.定義類體
CREATE OR REPLACE TYPE BODY emp_object 
IS 
 -- 實現過程
 MEMBER PROCEDURE change_emp_sal_proc(
  p_sal NUMBER
 ) 
 IS
 BEGIN 
  UPDATE emp SET sal=p_sal WHERE empno=SELF.atri_empno;
 END;
 
 STATIC PROCEDURE change_dept_sal_proc(
  p_deptno NUMBER,
  p_sal NUMBER
 ) 
 IS 
 BEGIN 
  UPDATE emp SET sal=p_sal WHERE deptno=p_deptno;
 END;
 
 -- 實現函數
 MEMBER FUNCTION get_emp_sal_fun 
 RETURN NUMBER 
 IS 
  v_sal emp.sal%TYPE;
  v_comm emp.comm%TYPE;
 BEGIN 
  SELECT sal, NVL(comm,0) INTO v_sal, v_comm FROM emp 
  WHERE empno=SELF.atri_empno;
  RETURN v_sal + v_comm;
 END;
 
 STATIC FUNCTION get_dept_sal_sum_fun(
  p_deptno NUMBER
 ) RETURN NUMBER 
 IS 
  v_sum NUMBER;
 BEGIN 
  SELECT SUM(sal) INTO v_sum FROM emp WHERE deptno=p_deptno;
  RETURN v_sum;
 END;
END;
/


-- ex:編寫PL/SQL塊來驗證以上的程序代碼
DECLARE 
 v_emp emp_object; -- 宣告對象變數
BEGIN 
 v_emp := emp_object(7369); -- 實例化對象，對atri_empno賦值
 
 v_emp.change_emp_sal_proc(3800);
 DBMS_OUTPUT.put_line('員工編號'|| v_emp.atri_empno || '工資: ' 
 || v_emp.get_emp_sal_fun());
 
 -- static函數使用類名稱調用
 DBMS_OUTPUT.put_line('10部門工資總和: ' || 
 emp_object.get_dept_sal_sum_fun(10));
 
 emp_object.change_dept_sal_proc(10,7000);
 
 DBMS_OUTPUT.put_line('10部門工資總和: ' || 
 emp_object.get_dept_sal_sum_fun(10)); 
END;
/

ROLLBACK;
MEMBER定義的函數使用對象調用，STATIC定義的函數使用類名稱調用。


-- ➤構造函數
-- 說明:當創建一個類的對象時，如果希望可以自動的完成某些操作，例如:為對象的屬性
-- 賦值，則可以利用構造函數完成。對於構造函數的定義有如下要求:
-- 構造函數的名稱必須與類名稱保持一致。
-- 構造函數必須使用CONSTRUCTOR關鍵字進行定義。
-- 構造函數必須定義返回值，且返回值類型必須為"SELF AS RESULT"。
-- 構造函數也可以進行重載，重新重載的構造函數參數的類型及個數不同。
-- ex:定義構造函數
-- 1.定義類規範
CREATE OR REPLACE TYPE emp_object IS OBJECT(
 atri_empno NUMBER(4),
 atri_sal NUMBER(7,2),
 atri_comm NUMBER(7,2),
 CONSTRUCTOR FUNCTION emp_object(
  p_empno NUMBER
 ) RETURN SELF AS RESULT,
 CONSTRUCTOR FUNCTION emp_object(
  p_empno NUMBER,
  p_comm NUMBER
 ) RETURN SELF AS RESULT
);
/
-- 2.定義類體
CREATE OR REPLACE TYPE BODY emp_object 
IS 
 -- 實作建構函式
 CONSTRUCTOR FUNCTION emp_object(
  p_empno NUMBER
 ) RETURN SELF AS RESULT 
 IS 
 BEGIN 
  SELF.atri_empno := p_empno;
  SELECT sal INTO atri_sal FROM emp WHERE empno=p_empno;
  RETURN;
 END;
 
 CONSTRUCTOR FUNCTION emp_object(
  p_empno NUMBER,
  p_comm NUMBER
 ) RETURN SELF AS RESULT 
 IS 
 BEGIN 
  SELF.atri_empno := p_empno;
  SELF.atri_comm := p_comm;
  SELF.atri_sal := 200.0; -- 設置默認值
  RETURN;
 END;
END;
/
-- 現在構造函數定義完成後，就可以在實例化對象的時候進行調用。現在定義了兩個構造
-- 函數，但是實際上存在了三個構造函數，有一個構造函數是需要全部傳遞所有屬性內容
-- 的。


-- ex:實例化對象
DECLARE 
 v_emp1 emp_object;
 v_emp2 emp_object;
 v_emp3 emp_object;
BEGIN 
 v_emp1 := emp_object(7369); -- 自定義建構函數
 v_emp2 := emp_object(7566,2400); -- 自定義建構函數
 v_emp3 := emp_object(7839,0,0); -- 默認建構函數
 
 DBMS_OUTPUT.put_line(v_emp1.atri_empno || '員工薪資: ' || v_emp1.atri_sal);
 DBMS_OUTPUT.put_line(v_emp2.atri_empno || '員工薪資: ' || v_emp2.atri_sal);
 DBMS_OUTPUT.put_line(v_emp3.atri_empno || '員工薪資: ' || v_emp3.atri_sal);
END;
/
-- 構造函數的主要功能就是為類中的屬性初始化。


-- ➤定義MAP與ORDER函數
-- 簡述:這兩個語法的特性在Java中是有支持的，不過使用的形式和定義的作用是完全不
-- 相同的。
-- 說明:當用戶聲明了多個類對象之後，那麼這個時候如果想對這些對象的訊息進行排序
-- ，就不能像NUMBER或VARCHAR2這種基本數據類型的方式進行，必須專門指定比較的規則
-- ，在Oracle中比較規則的設置主要利用MAP函數或ORDER函數完成。

-- MAP函數:使用MAP定義的函數將會按照用戶定義的數據組合值來區分大小，然後利用
-- ORDER BY子句進行排序。
-- ORDER函數:ORDER函數與MAP函數類似，也是定義了一個排序規則，在進行數據排序時會
-- 默認調用，同時ORDER函數還可以比較兩個對象的大小關係，所以如果要比較多個對象
-- 時ORDER函數會被重複調用，性能不如MAP函數。
-- ▲對於MAP和ORDER而言是一種二選一的關係。

-- ex:定義MAP函數
-- 1.定義類規範
CREATE OR REPLACE TYPE emp_object_map IS OBJECT(
 atri_empno NUMBER(4),
 atri_ename VARCHAR2(10),
 atri_sal NUMBER(7,2),
 atri_comm NUMBER(7,2),
 MAP MEMBER FUNCTION compare RETURN NUMBER
) NOT FINAL;
/
-- 2.定義類體
CREATE OR REPLACE TYPE BODY emp_object_map 
IS 
 -- 實現MAP排序
 MAP MEMBER FUNCTION compare 
 RETURN NUMBER 
 IS 
 BEGIN 
  RETURN SELF.atri_sal + SELF.atri_comm;
 END;
END;
/


-- 現在類體中定義了操作的規則，按照"基本工資 + 傭金"的方式計算結果排序。但如果
-- 想驗證MAP函數，那麼必須創建對象表。
-- ex:創建對象表
CREATE TABLE emp_object_map_tab OF emp_object_map;
INSERT INTO emp_object_map_tab(atri_empno, atri_ename, atri_sal, atri_comm)
VALUES (7369, 'SMITH', 800, 0);
INSERT INTO emp_object_map_tab(atri_empno, atri_ename, atri_sal, atri_comm)
VALUES (7902, 'FORD', 3000, 0);
INSERT INTO emp_object_map_tab(atri_empno, atri_ename, atri_sal, atri_comm)
VALUES (7499, 'ALLEN', 1600, 300);
INSERT INTO emp_object_map_tab(atri_empno, atri_ename, atri_sal, atri_comm)
VALUES (7521, 'WARD', 1250, 500);
INSERT INTO emp_object_map_tab(atri_empno, atri_ename, atri_sal, atri_comm)
VALUES (7839, 'KING', 5000, 0);
COMMIT;
SELECT * FROM emp_object_map_tab;


-- ex:透過查詢實現排序
-- SELECT * FROM emp_object_map_tab ORDER BY atri_sal + atri_comm;
SELECT VALUE(e) ve, atri_empno, atri_ename, atri_sal + atri_comm 
FROM emp_object_map_tab e
ORDER BY ve;
-- 此時會自動調用MAP函數(compare)實現排序。


-- ORDER函數也可以實現排序，與Java中的Compareable介面類似。ORDER是兩個對象間的
-- 比較。
-- ex:定義ORDER函數
-- 1.定義類規範
CREATE OR REPLACE TYPE emp_object_order IS OBJECT(
 atri_empno NUMBER(4),
 atri_ename VARCHAR2(10),
 atri_sal NUMBER(7,2),
 atri_comm NUMBER(7,2),
 ORDER MEMBER FUNCTION compare(obj emp_object_order) RETURN NUMBER
) NOT FINAL;
/
-- 2.定義類體
CREATE OR REPLACE TYPE BODY emp_object_order 
IS 
 -- 實現MAP排序
 ORDER MEMBER FUNCTION compare(obj emp_object_order) 
 RETURN NUMBER 
 IS 
 BEGIN 
  IF (SELF.atri_sal + SELF.atri_comm) > (obj.atri_sal + obj.atri_comm) THEN
   RETURN 1;
  ELSIF (SELF.atri_sal + SELF.atri_comm) < (obj.atri_sal + obj.atri_comm) THEN 
   RETURN -1;
  ELSE 
   RETURN 0;
  END IF;
 END;
END;
/


-- ex:編寫PL/SQL塊實現對象比較
DECLARE 
 v_emp1 emp_object_order;
 v_emp2 emp_object_order;
BEGIN 
 v_emp1 := emp_object_order(7499, 'ALLEN', 1600, 300);
 v_emp2 := emp_object_order(7521, 'WARD', 1250, 500);
 IF v_emp1 > v_emp2 THEN
  DBMS_OUTPUT.put_line('7499的工資高於7521的工資');
 ELSIF v_emp1 < v_emp2 THEN 
  DBMS_OUTPUT.put_line('7499的工資低於7521的工資');
 ELSE  
  DBMS_OUTPUT.put_line('7499的工資等於7521的工資');
 END IF;
END;
/
-- 以上是透過PL/SQL進行編寫的比較，那麼也可以利用emp_object_order創建數據表。


- ex:創建對象表
CREATE TABLE emp_object_order_tab OF emp_object_order;
INSERT INTO emp_object_order_tab(atri_empno, atri_ename, atri_sal, atri_comm)
VALUES (7369, 'SMITH', 800, 0);
INSERT INTO emp_object_order_tab(atri_empno, atri_ename, atri_sal, atri_comm)
VALUES (7902, 'FORD', 3000, 0);
INSERT INTO emp_object_order_tab(atri_empno, atri_ename, atri_sal, atri_comm)
VALUES (7499, 'ALLEN', 1600, 300);
INSERT INTO emp_object_order_tab(atri_empno, atri_ename, atri_sal, atri_comm)
VALUES (7521, 'WARD', 1250, 500);
INSERT INTO emp_object_order_tab(atri_empno, atri_ename, atri_sal, atri_comm)
VALUES (7839, 'KING', 5000, 0);
COMMIT;
SELECT * FROM emp_object_order_tab;


-- ex:透過查詢實現排序
-- SELECT * FROM emp_object_order_tab ORDER BY atri_sal + atri_comm;
SELECT VALUE(e) ve, atri_empno, atri_ename, atri_sal + atri_comm 
FROM emp_object_order_tab e
ORDER BY ve;


-- ➤對象嵌套關係
-- 簡述:在講解Java中強調的簡單Java類對象就可以互相定義的關係，而對於Oracle中的
-- PL/SQL也是一樣可以實現對象間的嵌套關係。
-- 說明:利用PL/SQL的物件導向編程除了可以將基本數據類型定義為屬性之外，還可以結
-- 合對象的引用傳遞方式，進行對象類型的嵌套，例如:在部門員工關係之中，每一個員
-- 工都有一個所在部門訊息，那麼就可以將這樣的關係透過嵌套的方式來表示。
-- ex:實現嵌套關係
DROP TYPE emp_object;
DROP TYPE dept_object;
-- 1.定義類規範
CREATE OR REPLACE TYPE dept_object IS OBJECT(
 atri_deptno NUMBER(2),
 atri_dname VARCHAR2(14),
 atri_loc VARCHAR2(13),
 MEMBER FUNCTION tostring RETURN VARCHAR2
) NOT FINAL;
/

CREATE OR REPLACE TYPE emp_object IS OBJECT(
 atri_empno NUMBER(4),
 atri_ename VARCHAR2(10),
 atri_job VARCHAR2(9),
 atri_hiredate DATE,
 atri_sal NUMBER(7,2),
 atri_comm NUMBER(7,2),
 atri_dept dept_object,
 MEMBER FUNCTION tostring RETURN VARCHAR2
) NOT FINAL;
/
-- 2.定義類體
CREATE OR REPLACE TYPE BODY dept_object 
IS 
 MEMBER FUNCTION tostring 
 RETURN VARCHAR2 
 IS 
 BEGIN 
  RETURN '部門編號: ' || SELF.atri_deptno 
  || ', 名稱: ' || SELF.atri_dname 
  || ', 位置: ' || SELF.atri_loc;
 END;
END;
/

CREATE OR REPLACE TYPE BODY emp_object 
IS 
 MEMBER FUNCTION tostring 
 RETURN VARCHAR2 
 IS 
 BEGIN 
  RETURN '員工編號: ' || SELF.atri_empno 
  || ', 姓名: ' || SELF.atri_ename 
  || ', 職位: ' || SELF.atri_job 
  || ', 僱用日期: ' || SELF.atri_hiredate 
  || ', 工資: ' || SELF.atri_sal 
  || ', 傭金: ' || SELF.atri_comm;
 END;
END;
/


-- ex:編寫PL/SQL塊，建立對象間的關係
DECLARE 
 v_dept dept_object;
 v_emp emp_object;
BEGIN 
 v_dept := dept_object(10, 'ACCOUNTING', 'NEW YORK');
 v_emp := emp_object(7839, 'KING' ,'PRESIDENT', 
 TO_DATE('1981-11-11','YYYY-MM-DD'), 5000, null, v_dept);
 DBMS_OUTPUT.put_line(v_emp.tostring());
 DBMS_OUTPUT.put_line(v_emp.atri_dept.tostring());
 DBMS_OUTPUT.put_line(v_dept.tostring());
END;
/
現在透過關係的建立，就可以藉由員工的訊息找到部門的訊息。


-- ➤繼承性
-- 說明:在物件導向中，如果要擴充已有類的功能，那麼就可以利用繼承性來解決，被繼
-- 承的類稱為父類，繼承它的類稱為子類，例如:在人與員工的關係之中，因為人表示的
-- 範圍更大一些，所以人就是父類，而員工一定是人，同時表示的範圍小些，所以員工就
-- 是子類。當發生繼承關係後，子類可以繼續將父類中定義的屬性或函數繼承下來。如果
-- 要在PL/SQL之中實現繼承，可以使用UNDER關鍵字實現。
-- ex:實現繼承關係
-- 1.定義類規範
CREATE OR REPLACE TYPE person_object IS OBJECT(
 atri_pid NUMBER,
 atri_name VARCHAR2(10),
 atri_sex VARCHAR2(10),
 MEMBER FUNCTION get_person_info_fun RETURN VARCHAR2
) NOT FINAL;
/
-- 2.定義類體
CREATE OR REPLACE TYPE BODY person_object 
IS 
 MEMBER FUNCTION get_person_info_fun 
 RETURN VARCHAR2 
 IS 
 BEGIN 
  RETURN '人員編號: ' || SELF.atri_pid 
  || ', 姓名: ' || SELF.atri_name 
  || ', 性別: ' || SELF.atri_sex;
 END;
END;
/

-- 3.編寫子類
-- 定義子類類規範
CREATE OR REPLACE TYPE emp_object UNDER person_object(
 atri_job VARCHAR2(9), 
 atri_sal NUMBER(7,2),
 atri_comm NUMBER(7,2), 
 MEMBER FUNCTION get_emp_info_fun RETURN VARCHAR2
);
/
-- 定義子類類體
CREATE OR REPLACE TYPE BODY emp_object 
IS 
 MEMBER FUNCTION get_emp_info_fun 
 RETURN VARCHAR2 
 IS 
 BEGIN 
  RETURN '人員編號: ' || SELF.atri_pid 
  || ', 姓名: ' || SELF.atri_name 
  || ', 性別: ' || SELF.atri_sex 
  || ', 職位: ' || SELF.atri_job 
  || ', 工資: ' || SELF.atri_sal 
  || ', 傭金: ' || SELF.atri_comm;
 END;
END;
/
-- 子類定義完成後，是可以繼續訪問父類中的相關操作的。


-- ex:產生子類對象
DECLARE 
 v_emp emp_object;
BEGIN 
 v_emp := emp_object(7369, 'SMITH', 'FEMALE', 'CLERK', 800.0, 0.0);
 DBMS_OUTPUT.put_line('person_object父類的函數: ' 
 || v_emp.get_person_info_fun());
 DBMS_OUTPUT.put_line('emp_object子類的函數: ' 
 || v_emp.get_emp_info_fun());
END;
/
-- 調用函數(get_emp_info_fun)的時候一定要將父類中的參數內容一起進行傳遞。而現在
-- 子類是在父類的基礎之上功能的進一步的擴充。


-- ➤函數複寫
-- 說明:當子類繼承父類之後子類會將父類中的全部操作進行繼承，但是很多時候子類希
-- 望繼續使用父類中所定義過的函數名稱，這樣就會發生函數的複寫問題。如果想實現複
-- 寫操作，那麼必須在子類規範定義時明確的使用"OVERRIDING"關鍵字定義某一個函數為
-- 複寫的函數。
-- ex:實現複寫
DROP TYPE person_object;
DROP TYPE emp_object;
-- 1.定義類規範(get_person_info_fun()函數修改為tostring())
CREATE OR REPLACE TYPE person_object IS OBJECT(
 atri_pid NUMBER,
 atri_name VARCHAR2(10),
 atri_sex VARCHAR2(10),
 MEMBER FUNCTION tostring RETURN VARCHAR2
) NOT FINAL;
/
-- 2.定義類體
CREATE OR REPLACE TYPE BODY person_object 
IS 
 MEMBER FUNCTION tostring  
 RETURN VARCHAR2 
 IS 
 BEGIN 
  RETURN '人員編號: ' || SELF.atri_pid 
  || ', 姓名: ' || SELF.atri_name 
  || ', 性別: ' || SELF.atri_sex;
 END;
END;
/
-- 此時在父類中使用了熟悉的tostring()函數名稱取得對象訊息，但問題是，此時子類
-- 中的屬性絕對要比父類中的多，所以父類中的tostring()函數的功能就不能夠滿足子
-- 類的要求。


-- 3.編寫子類
-- 定義子類類規範(子類對tostring()函數進行overriding)
CREATE OR REPLACE TYPE emp_object UNDER person_object(
 atri_job VARCHAR2(9), 
 atri_sal NUMBER(7,2),
 atri_comm NUMBER(7,2), 
 OVERRIDING MEMBER FUNCTION tostring RETURN VARCHAR2
);
/
-- 定義子類類體
CREATE OR REPLACE TYPE BODY emp_object 
IS 
 OVERRIDING MEMBER FUNCTION tostring 
 RETURN VARCHAR2 
 IS 
 BEGIN 
  RETURN '人員編號: ' || SELF.atri_pid 
  || ', 姓名: ' || SELF.atri_name 
  || ', 性別: ' || SELF.atri_sex 
  || ', 職位: ' || SELF.atri_job 
  || ', 工資: ' || SELF.atri_sal 
  || ', 傭金: ' || SELF.atri_comm;
 END;
END;
/


-- ex:編寫PL/SQL塊驗證
DECLARE 
 v_emp emp_object;
BEGIN 
 v_emp := emp_object(7369, 'SMITH', 'FEMALE', 'CLERK', 800.0, 0.0);
 DBMS_OUTPUT.put_line(v_emp.tostring());
END;
/
-- 複寫之後使用子類對象的時候就不會再去思考父類中的實現了。


-- ➤對象多型
-- 說明:多型是物件導向中的重要特性，多型的特點體現在兩個方面:
-- ①函數的多型:體現為函數的重載與函數的複寫。
-- ②對象的多型:子類對象可以為父類對象進行實例化。
-- ▲對象的多型指的是透過子類為父類對象實例化，然後調用的函數名稱以父類中定義的
-- 名稱為主，但是函數的實現體以子類為主。
-- ex:觀察對象的多型
DROP TYPE person_object;
DROP TYPE emp_object;
-- 1.定義類規範
CREATE OR REPLACE TYPE person_object IS OBJECT(
 atri_pid NUMBER,
 atri_name VARCHAR2(10),
 atri_sex VARCHAR2(10),
 MEMBER FUNCTION tostring RETURN VARCHAR2
) NOT FINAL;
/
-- 2.定義類體
CREATE OR REPLACE TYPE BODY person_object 
IS 
 MEMBER FUNCTION tostring  
 RETURN VARCHAR2 
 IS 
 BEGIN 
  RETURN '人員編號: ' || SELF.atri_pid 
  || ', 姓名: ' || SELF.atri_name 
  || ', 性別: ' || SELF.atri_sex;
 END;
END;
/
-- 3.編寫emp子類
-- 定義子類類規範
CREATE OR REPLACE TYPE emp_object UNDER person_object(
 atri_job VARCHAR2(9), 
 atri_sal NUMBER(7,2),
 atri_comm NUMBER(7,2), 
 OVERRIDING MEMBER FUNCTION tostring RETURN VARCHAR2
);
/
-- 定義子類類體
CREATE OR REPLACE TYPE BODY emp_object 
IS 
 OVERRIDING MEMBER FUNCTION tostring 
 RETURN VARCHAR2 
 IS 
 BEGIN 
  RETURN '人員編號: ' || SELF.atri_pid 
  || ', 姓名: ' || SELF.atri_name 
  || ', 性別: ' || SELF.atri_sex 
  || ', 職位: ' || SELF.atri_job 
  || ', 工資: ' || SELF.atri_sal 
  || ', 傭金: ' || SELF.atri_comm;
 END;
END;
/
-- 4.創建學生類別子類
-- 定義子類類規範
CREATE OR REPLACE TYPE student_object UNDER person_object(
 atri_school VARCHAR2(15),
 atri_score NUMBER(5,2),
 OVERRIDING MEMBER FUNCTION tostring RETURN VARCHAR2 
);
/
-- 定義子類類體
CREATE OR REPLACE TYPE BODY student_object 
IS
  OVERRIDING MEMBER FUNCTION tostring 
  RETURN VARCHAR2 
  IS 
  BEGIN 
   RETURN '人員編號: ' || SELF.atri_pid 
  || ', 姓名: ' || SELF.atri_name 
  || ', 性別: ' || SELF.atri_sex 
  || ', 學校: ' || SELF.atri_school 
  || ', 成績: ' || SELF.atri_score;
  END;  
END;
/


-- 這個時候person_object有兩個子類，所以這兩個子類都可以為父類實例化。
-- ex:透過子類實例化父類對象
DECLARE 
 v_emp person_object; -- 父類對象
 v_student person_object; -- 父類對象
BEGIN 
 -- 向上轉型 
 v_emp := emp_object(7369, 'SMITH', 'FEMALE', 'CLERK', 800.0, 0.0);
 v_student := student_object(7566, 'ALLEN', 'FEMALE', 'GOOGLE', 99.9); 
 DBMS_OUTPUT.put_line('<員工訊息>: ' || v_emp.tostring());
 DBMS_OUTPUT.put_line('<學生訊息>: ' || v_student.tostring());
END;
/


-- ➤FINAL
-- 在PL/SQL中用戶可以利用FINAL關鍵字定義不能被繼承的類，與不能被覆寫的函數。
-- ex:使用FINAL定義不能被繼承繼承的類
DROP TYPE emp_object;
DROP TYPE student_object;
DROP TYPE person_object;
-- 創建父類
CREATE OR REPLACE TYPE person_object IS OBJECT(
 atri_pid NUMBER
) FINAL; -- 不能被繼承
/
-- 子類進行繼承動作
CREATE OR REPLACE TYPE emp_object UNDER person_object(
 atri_job VARCHAR2(9)
);
/
-- 錯誤(1,1): PLS-00590: 嘗試在 FINAL 類型之下建立子類型


-- ex:定義不能被覆寫的函數
DROP TYPE emp_object;
DROP TYPE student_object;
DROP TYPE person_object;
-- 創建父類
CREATE OR REPLACE TYPE person_object IS OBJECT(
 atri_pid NUMBER,
 FINAL MEMBER FUNCTION tostring RETURN VARCHAR2 -- 不能被複寫
) NOT FINAL;
/
-- 子類進行複寫動作
CREATE OR REPLACE TYPE emp_object UNDER person_object(
 atri_job VARCHAR2(9),
 OVERRIDING MEMBER FUNCTION tostring RETURN VARCHAR2
);
/
-- PLS-00637: 無法覆寫或隱藏 FINAL 方法
-- 如果要編寫程序，大部分而言很少這樣考慮。如果自訂的是規範，那麼就需要考慮。


-- ➤定義抽象函數
-- 說明:當用戶定義完一個類後，默認情況下用戶就可以直接利用此類的實例化對象
-- 進行類中結構的操作。如果現在類中的函數不希望由被類對象直接使用，而需要透
-- 過繼承它子類來實現時，那麼就可以在定義函數的時候使用"NOT INSTANTIABLE"
-- 標記即可，這樣的函數就被稱為抽象函數，同時包含有抽象函數所在的類也必須使
-- 用"NOT INSTANTIABLE"定義，這樣的類也同樣被稱為抽象類。
-- ex:定義抽象類與抽象函數
DROP TYPE emp_object;
DROP TYPE person_object;
-- 1.定義類規範(抽象類不能實體化)
CREATE OR REPLACE TYPE person_object IS OBJECT(
 atri_pid NUMBER,
 atri_name VARCHAR2(10),
 atri_sex VARCHAR2(10),
 NOT INSTANTIABLE MEMBER FUNCTION tostring RETURN VARCHAR2 -- 定義抽象函數
) NOT FINAL NOT INSTANTIABLE; -- 定義抽象類
/
-- 2.編寫emp子類
-- 定義子類類規範
CREATE OR REPLACE TYPE emp_object UNDER person_object(
 atri_job VARCHAR2(9), 
 atri_sal NUMBER(7,2),
 atri_comm NUMBER(7,2), 
 OVERRIDING MEMBER FUNCTION tostring RETURN VARCHAR2
);
/
-- 定義子類類體
CREATE OR REPLACE TYPE BODY emp_object 
IS 
 OVERRIDING MEMBER FUNCTION tostring 
 RETURN VARCHAR2 
 IS 
 BEGIN 
  RETURN '人員編號: ' || SELF.atri_pid 
  || ', 姓名: ' || SELF.atri_name 
  || ', 性別: ' || SELF.atri_sex 
  || ', 職位: ' || SELF.atri_job 
  || ', 工資: ' || SELF.atri_sal 
  || ', 傭金: ' || SELF.atri_comm;
 END;
END;
/
-- 透過子類實例化父類對象，所調用的函數一定是被覆寫過的函數。


-- ex:編寫程序測試
DECLARE 
 v_emp emp_object;
BEGIN 
 v_emp := emp_object(7369, 'SMITH', 'FEMALE', 'CLERK', 800.0, 0.0);
 DBMS_OUTPUT.put_line(v_emp.tostring());
END;
/
--============================================================================--
--                                                                            --
/* ※物件導向-對象表                                                          */
--                                                                            --
--============================================================================--
-- 說明:Oracle屬於物件導向的數據庫，所以在Oracle中也允許用戶基於類的結構進行數據
-- 表的創建，同時採用類的關係進行表中的數據的維護。
-- ex:先定義出要使用的類
@C:\Users\user\Desktop\Oracle12.1cSQL\CH23.物件導向對象-對象表1.sql;


-- ➤創建對象表
-- 說明:當用戶定義完一個類後，就可以依據此類中的屬性結構創建指定的對象表。
-- 語法:
-- CREATE TABLE 表名稱 OF 類;
-- ex:利用emp_object創建表
CREATE TABLE emp_object_tab OF emp_object;
-- 這個時候就是一張對象表。
/*
DESC emp_object_tab;
名稱        空值 類型            
--------- -- ------------- 
ATRI_PID     NUMBER        
ATRI_NAME    VARCHAR2(10)  
ATRI_SEX     VARCHAR2(10)  
ATRI_JOB     VARCHAR2(9)   
ATRI_SAL     NUMBER(7,2)   
ATRI_COMM    NUMBER(7,2)   
ATRI_DEPT    DEPT_OBJECT()
發現此時對於dept是嵌套的操作關係。
*/


-- ➤數據增加
-- ex:增加數據不增加部門訊息
INSERT INTO emp_object_tab(atri_pid, atri_name, atri_sex, 
atri_job, atri_sal, atri_comm) 
VALUES (10, '伊森', '男', '辦事員', 3500, 100);


-- ex:增加一個有部門的數據，使用嵌套類型(建構函數的形式添加)
INSERT INTO emp_object_tab(atri_pid, atri_name, atri_sex, 
atri_job, atri_sal, atri_comm, atri_dept) 
VALUES (20, '茱蒂', '女', '技術員', 5500, 200, 
dept_object(10, '開發部', '東岸'));


-- ➤查詢數據
-- 此時是屬於類結構的表，那麼下面直接發出查詢指令。
-- ex:查詢全部員工訊息
SELECT * FROM emp_object_tab;
-- 發現嵌套的類型無法顯示，因為是一個對象。


-- ➤VALUE()函數
-- 說明:在查詢中，利用VALUE()函數可以將對象表中的數據轉化為對象返回，這樣用戶就
-- 可以利用查詢後的對象訊息進行排序，例如:本程序已經在emp_object類之中已經定義
-- 了MAP函數，所以用戶就可以直接按照工資和傭金的組合進行數據的排序。
-- ex:使用VALUE()函數
SELECT VALUE(e) ve, 
atri_pid, atri_name, atri_sex, atri_job, atri_sal, atri_comm 
FROM emp_object_tab e
ORDER BY ve DESC;


-- ex:取出對象訊息，可以利用PL/SQL塊完成。
-- 將emp_object_tab對像表轉回emp_object對象，取出對象訊息
DECLARE 
 v_emp emp_object; 
BEGIN 
 SELECT VALUE(e) INTO v_emp FROM emp_object_tab e WHERE e.atri_pid=20;
 DBMS_OUTPUT.put_line(v_emp.tostring);
 DBMS_OUTPUT.put_line(v_emp.atri_dept.tostring);
END;
/


-- 現在有了對象表之後，也可以利用游標進行數據取出。
-- ex:使用游標取出數據
DECLARE 
 v_emp emp_object;
 CURSOR cur_emp IS SELECT VALUE(e) ve FROM emp_object_tab e; -- 弱類型靜態游標
BEGIN 
 -- 使用自動打開自動關閉的FOR
 FOR v_emprow IN cur_emp LOOP 
  v_emp := v_emprow.ve;
  DBMS_OUTPUT.put_line(v_emp.tostring);
  
  -- 因為部門資料有null，進行判斷
  IF v_emp.atri_dept IS NOT NULL THEN 
   DBMS_OUTPUT.put_line(v_emp.atri_dept.tostring);
  END IF;
 END LOOP;
END;
/
-- 此時的判斷就保證是存在了部門之後才會進行數據的輸出。


-- ➤REF()函數
-- 說明:利用VALUE()函數是將嵌套表的對象訊息直接保存在對象表中，但是這種作法很多
-- 時候就會造成數據的冗餘。


-- 但是如果一旦使用ref()操作，那麼首先必須修改的就是類規範。
-- ex:修改emp_object子類類規範及類體
-- @C:\Users\user\Desktop\Oracle12.1cSQL\CH23.物件導向對象-對象表2.sql;
DROP TABLE emp_object_ref_tab;
DROP TABLE dept_object_ref_tab;
-- DROP TYPE emp_object_ref FORCE;
CREATE OR REPLACE TYPE emp_object_ref UNDER person_object(
 atri_job VARCHAR2(9), 
 atri_sal NUMBER(7,2),
 atri_comm NUMBER(7,2),
 atri_dept REF dept_object, -- 修改為引用對象嵌套關係
 OVERRIDING MEMBER FUNCTION tostring RETURN VARCHAR2, -- 複寫抽象函數
 OVERRIDING MAP MEMBER FUNCTION compare RETURN NUMBER -- 複寫抽象MAP排序
);
/

CREATE OR REPLACE TYPE BODY emp_object_ref 
IS 
 -- 實現抽象函數
 OVERRIDING MEMBER FUNCTION tostring 
 RETURN VARCHAR2 
 IS 
 BEGIN 
  RETURN '人員編號: ' || SELF.atri_pid 
  || ', 姓名: ' || SELF.atri_name 
  || ', 性別: ' || SELF.atri_sex 
  || ', 職位: ' || SELF.atri_job 
  || ', 工資: ' || SELF.atri_sal 
  || ', 傭金: ' || SELF.atri_comm;
 END;
 
 OVERRIDING MAP MEMBER FUNCTION compare 
 RETURN NUMBER 
 IS 
 BEGIN 
  RETURN SELF.atri_sal + SELF.atri_comm;
 END;
END;
/


-- ex:創建表
CREATE TABLE emp_object_ref_tab OF emp_object_ref;
CREATE TABLE dept_object_ref_tab OF dept_object;

-- ex:增加數據
INSERT INTO dept_object_ref_tab(atri_deptno, atri_dname, atri_loc) 
VALUES (10, 'orcl教學', '東岸');
INSERT INTO dept_object_ref_tab(atri_deptno, atri_dname, atri_loc) 
VALUES (20, 'orcl開發', '墨爾本');
INSERT INTO dept_object_ref_tab(atri_deptno, atri_dname, atri_loc) 
VALUES (30, 'orcl移動', '西岸');

INSERT INTO emp_object_ref_tab(atri_pid, atri_name, atri_sex, 
atri_job, atri_sal, atri_comm, atri_dept) 
VALUES (3010, '伊森', '男', '辦事員', 3500, 100, 
(SELECT REF(d) FROM dept_object_ref_tab d WHERE atri_deptno=10));
INSERT INTO emp_object_ref_tab(atri_pid, atri_name, atri_sex, 
atri_job, atri_sal, atri_comm, atri_dept) 
VALUES (3020, '茱蒂', '女', '技術員', 5500, 200, 
SELECT REF(d) FROM dept_object_ref_tab d WHERE atri_deptno=20));
COMMIT;

-- ex:使用sqlplus查看訊息
SELECT atri_pid, atri_name, atri_sex, atri_job, atri_sal, atri_comm,
DEREF(atri_dept) dept 
FROM emp_object_ref_tab;

-- ➤數據更新
-- ex:將emp_object__tab對象表編號為10的訊息進行更新(原本為部門為null)
-- @C:\Users\user\Desktop\Oracle12.1cSQL\CH23.物件導向對象-對象表1.sql;
UPDATE emp_object_tab SET atri_job='經理', 
atri_dept=dept_object(30, '谷歌', '紐約') WHERE atri_pid=10;

-- ex:查看訊息
DECLARE 
 v_emp emp_object; 
BEGIN 
 SELECT VALUE(e) INTO v_emp FROM emp_object_tab e WHERE e.atri_pid=10;
 DBMS_OUTPUT.put_line(v_emp.tostring);
 DBMS_OUTPUT.put_line(v_emp.atri_dept.tostring);
END;
/


-- 完成了數值關係(非引用關係)操作後，下面再來實現引用的關係。
-- ex:修改員工訊息
-- @C:\Users\user\Desktop\Oracle12.1cSQL\CH23.物件導向對象-對象表2.sql;
UPDATE emp_object_ref_tab SET 
atri_dept=(SELECT REF(d) FROM dept_object_ref_tab d WHERE atri_deptno=30) 
WHERE atri_pid=3020;

-- 使用sqlplus查看訊息
SELECT atri_pid, atri_name, atri_sex, atri_job, atri_sal, atri_comm,
DEREF(atri_dept) dept 
FROM emp_object_ref_tab;


-- ex:將emp_object_ref_tab表中的所有10部門員工訊息進行修改
UPDATE emp_object_ref_tab SET atri_name='ORCL', atri_sal=5000 
WHERE atri_dept=(SELECT REF(d) FROM dept_object_ref_tab d WHERE atri_deptno=10);
-- 此時採用的是對象的形式進行的操作。


-- ➤刪除數據
-- ex:刪除emp_object_ref_tab表中所有10部門的員工
DELETE FROM emp_object_ref_tab 
WHERE atri_dept=(SELECT REF(d) FROM dept_object_ref_tab d WHERE atri_deptno=10);
-- 對象操作的形式就是以對象為判斷條件，但是這種做法與物件導向相符合。可是使用的
-- 感覺非常不好。
--============================================================================--
--                                                                            --
/* ※物件導向-對象視圖                                                        */
--                                                                            --
--============================================================================--
-- 說明:如果現在用戶需要將一張數據表中的數據轉為對象的形式操作，那麼就可以利用
-- 對象視圖來完成此操作。利用對象視圖，可以將指定視圖查詢語句的數據按照順序填充
-- 到相應的對象的屬性中，這樣用戶在操作視圖時就可以直接將數據以對象的形式返回。
-- ex:創建一個類
DROP TABLE emp_object_tab PURGE;
DROP TABLE emp_object_ref_tab PURGE;
DROP TABLE dept_object_ref_tab PURGE;
DROP TYPE emp_object FORCE;
DROP TYPE dept_object FORCE;
DROP TYPE person_object FORCE;

CREATE OR REPLACE TYPE emp_table_object IS OBJECT(
 atri_empno NUMBER(4),
 atri_ename VARCHAR2(10),
 atri_job VARCHAR2(9),
 atri_mgr NUMBER(4),
 atri_hiredate DATE,
 atri_sal NUMBER(7,2),
 atri_comm NUMBER(7,2),
 atri_deptno NUMBER(2),
 MEMBER FUNCTION tostring RETURN VARCHAR2
) NOT FINAL;
/

CREATE OR REPLACE TYPE BODY emp_table_object 
IS 
 MEMBER FUNCTION tostring 
 RETURN VARCHAR2 
 IS 
 BEGIN 
  RETURN '員工編號: ' || SELF.atri_empno 
  || ', 姓名: ' || SELF.atri_ename 
  || ', 職位: ' || SELF.atri_job 
  || ', 僱用日期: ' || SELF.atri_hiredate 
  || ', 工資: ' || SELF.atri_sal 
  || ', 傭金: ' || SELF.atri_comm;
 END;
END;
/


-- ➤創建對象視圖
-- 語法:
-- CREATE OR REPLACE VIEW 視圖名稱 OF 類 
-- WITH OBJECT IDENTIFIER(主鍵對象) 
-- AS 子查詢;
-- ex:創建對象視圖
CREATE OR REPLACE VIEW v_myview OF emp_table_object 
 WITH OBJECT IDENTIFIER(atri_empno) 
AS 
 SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno FROM emp; 
 
SELECT * FROM v_myview;
 -- 這個時候emp表中的數據就都以對象的形式存在了。 
 
 
 -- ex:利用對象視圖取數據
 DECLARE 
  v_emp emp_table_object;
 BEGIN 
  SELECT VALUE(ev) INTO v_emp FROM v_myview ev WHERE atri_empno=7839;
  DBMS_OUTPUT.put_line(v_emp.tostring());
 END;
 /
 -- 視圖中的數據可以直接以對象的形式返回。