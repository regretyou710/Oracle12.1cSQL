--============================================================================--
--                                                                            --
/* ※PL/SQL編程基礎-PL/SQL簡介                                                */
--                                                                            --
--============================================================================--
-- 說明:PL/SQL是Oracle在關係數據庫結構化查詢語言SQL基礎上擴展得到的一種過程化查
-- 尋語言。SQL與編程語言支的不同在於，SQL沒有變量，SQL沒有流程控制(分支，循環)。
-- 而PL/SQL是結構化的和過程化的結合體，而且最為重要的是，用戶執行多條SQL語句時
-- ，每條SQL語句都是逐一的發送給數據庫，而PL/SQL可以以次性將多條SQL語句一起發送
-- 給數據庫，減少網路流量。

/*
PL/SQL語法結構:
DECLARE
  --聲明部份，如:定義變量、常量、游標
BEGIN
  --程序編寫、SQL語句
EXCETPION
  --異常處理
END;
/

①聲明部份(DECLARE):包含變量定義、用戶定義的PL/SQL類型、游標、引用的函數或過程
。
②執行部份(BEGIN):包含變量賦值、對象初始化、條件結構、迭代結構、嵌套的PL/SQL匿
名塊、或是對局部或存儲PL/SQL命名塊的調用。
③異常部份(EXCEPTION):包含錯誤處理語句，該語句可以像執行部份一樣使用所有項。
④結束部份(END):程序執行到END表示結束，分號用於結束匿名塊，而正斜線執行塊程序。
*/

-- ex:最簡單的PL/SQL塊 
BEGIN
 NULL;
END;
/


-- ex:輸出Hello World
BEGIN
 DBMS_OUTPUT.put_line('Hello World.');
END;
/
-- note:默認情況下系統輸出的顯示是被關閉的，所以必須修改顯示的設定。
SET SERVEROUTPUT ON;


-- ex:編寫一個簡單PL/SQL程序
DECLARE
 v_num NUMBER; -- 定義變量
BEGIN
 v_num := 30; -- 為變量賦值
 DBMS_OUTPUT.put_line('v_num變量內容是:' || v_num);
END;
/


-- ex:輸入一個員工編號，然後取得指定的員工姓名
DECLARE
 v_eno NUMBER; -- 接收員工編號
 v_ename VARCHAR2(10); -- 接收員工姓名
BEGIN
 v_eno := &empno; -- 由鍵盤輸入數據(替代變量)
 SELECT ename INTO v_ename FROM emp WHERE empno=v_eno;
 DBMS_OUTPUT.put_line('編號為:' || v_eno || '雇員的名字是:' || v_ename);
END;
/
--============================================================================--
--                                                                            --
/* ※PL/SQL編程基礎-變量的聲明與賦值                                          */
--                                                                            --
--============================================================================--
-- ➤聲明並使用變量
-- PL/SQL是一種強類型的程式語言，所有的變量都必須在它聲明之後才可以使用，變量都
-- 要求在DECLARE部份進行聲明，而對於變量的名稱也有一些規定:
-- ①變量名稱的組成可以由字母、數字、_、$、#等組成，
-- ②所有的變量名稱要求以字母開頭，不能是Oracle中的保留字(關鍵字)。
-- ③變量的長度最多只能30個字元。

-- ex:定義變量不設置默認值
DECLARE
 v_result VARCHAR2(30); -- 此處沒有賦值
BEGIN
 DBMS_OUTPUT.put_line('v_result的內容是(' || v_result || ')');
END;
/
-- 此時v_result變量沒有任何內容，都是空字串。


-- 所有的變量都要求在DECLARE部份之中進行，在定義變量的時候也可以位其賦默認值。
/*
變量聲明語法:
變量名稱 [CONSTANT] 類型 [NOT NULL][:=value];

CONSTANT:定義常量，必須在聲明時為其賦予默認值。
NOT NULL:表示此變量不允許設置為NULL。
value:表示在變量聲明時，設置好其初始化內容。
*/
DECLARE
 v_resultA NUMBER := 100;
 v_resultB NUMBER;
BEGIN
 v_resultb := 30; -- 沒有區分大小寫
 DBMS_OUTPUT.put_line('加法計算:' || (v_resultA + v_resultB));
END;
/


-- ex:定義非空變量
DECLARE 
 v_resultA NUMBER NOT NULL := 100; -- 此變量不能為空
BEGIN 
 DBMS_OUTPUT.put_line('v_resultA變量內容為:' || v_resultA);
END;
/

DECLARE 
 v_resultA NUMBER NOT NULL;
BEGIN 
 DBMS_OUTPUT.put_line('v_resultA變量內容為:' || v_resultA);
END;
/
-- PLS-00218: 宣告為 NOT NULL 的變數必須要有初始化指定


-- ex:定義常量
DECLARE 
 v_resultA CONSTANT NUMBER NOT NULL :=100; -- 此變量不能為空
BEGIN 
 DBMS_OUTPUT.put_line('v_resultA變量內容為:' || v_resultA);
END;
/

DECLARE 
 v_resultA CONSTANT NUMBER NOT NULL :=100; -- 此變量不能為空
BEGIN 
 v_resultA := 20;
 DBMS_OUTPUT.put_line('v_resultA變量內容為:' || v_resultA);
END;
/
-- PLS-00363: 表示式 'V_RESULTA' 無法作為指定目標使用


-- ➤使用%TYPE聲明變量類型
-- 說明:在編寫PL/SQL程序的時候，如果希望一個變量與指定數據表中某一直行的類型一
-- 樣，則可以採用"變量定義 表名稱.欄位名稱%TYPE"的格式，這樣指定的變量就具備了
-- 與指定的欄位相同的類型。
-- ex:使用%TYPE定義
DECLARE 
 v_eno emp.empno%TYPE;
 v_ename emp.ename%TYPE;
BEGIN 
 DBMS_OUTPUT.put_line('請輸入員工編號');
 v_eno := &empno;
 SELECT ename INTO v_ename FROM emp WHERE empno=v_eno;
 DBMS_OUTPUT.put_line('編號為:' || v_eno || '員工姓名為:' || v_ename) ;
END;
/
-- 使用此種方式，在之後進行數據查詢時是非常方便的。


-- ex:使用%TYPE定義
DECLARE 
 v_eno emp.empno%TYPE;
 v_ename emp.ename%TYPE;
BEGIN 
 DBMS_OUTPUT.put_line('請輸入員工編號');
 v_eno := &empno;
 SELECT ename INTO v_ename FROM emp WHERE empno=v_eno;
 DBMS_OUTPUT.put_line('編號為:' || v_eno || '員工姓名為:' || v_ename) ;
END;
/


-- ➤使用%ROWTYPE聲明變量類型
-- 說明:使用"%ROWTYPE"標記可以定義表中一橫列紀錄的類型。
-- 當用戶使用了"SELECT...INTO..."將表中的一橫列紀錄設置到了ROWTYPE類型的變量之中
-- ，就可以利用"ROWTYPE.變量.表欄位"的方式取得表中每橫列的對應直行數據。
-- ex:使用%ROWTYPE定義
DECLARE 
 v_deptRow dept%ROWTYPE; -- 可以裝下一橫列dept內容
BEGIN  
 SELECT * INTO v_deptRow FROM dept WHERE deptno=10;
 DBMS_OUTPUT.put_line('部門編號為:' || v_deptRow.deptno 
 || ', 名稱為:' || v_deptRow.dname || ', 位置' || v_deptRow.loc) ;
END;
/
--============================================================================--
--                                                                            --
/* ※PL/SQL編程基礎-運算符                                                    */
--                                                                            --
--============================================================================--
-- ➤賦值運算符
-- 說明:賦值運算符的主要功能是將一個數值賦予指定數據類型的變量。變量:=表達式;
-- ex:使用賦值運算符
DECLARE 
 v_info VARCHAR(50) := '谷歌';
 v_url VARCHAR(50); -- 沒有設置內容
BEGIN  
 v_url := 'www.google.com';
 DBMS_OUTPUT.put_line(v_info);
 DBMS_OUTPUT.put_line(v_url);
END;
/


-- ➤連接運算符
-- 說明:使用"||"即可完成操作。
-- ex:字串連接操作
DECLARE 
 v_info VARCHAR(50) := '谷歌';
 v_url VARCHAR(50); -- 沒有設置內容
BEGIN  
 v_url := 'www.google.com';
 DBMS_OUTPUT.put_line(v_info || '網址:' || v_url);
END;
/


-- ➤比較運算符
-- ex:使用關係運算符
DECLARE 
 v_url VARCHAR(50) := 'www.google.com';
 v_num1 NUMBER := 80;
 v_num2 NUMBER := 30;
BEGIN 
 IF v_num1>v_num2 THEN
  DBMS_OUTPUT.put_line('第一個數字比第二個數字大。');
 END IF;
  IF v_url LIKE '%google%' THEN
  DBMS_OUTPUT.put_line('網址之中包含google單詞。');
 END IF;
END;
/


-- ➤邏輯運算符
-- ex:觀察邏輯運算結果
DECLARE
 v_flag1 BOOLEAN := TRUE;
 v_flag2 BOOLEAN := FALSE;
 v_flag3 BOOLEAN;
BEGIN
 IF v_flag1 AND (NOT v_flag2) THEN 
  DBMS_OUTPUT.put_line('v_flag1 AND (NOT v_flag2) = TRUE');
 END IF;
 IF v_flag1 OR v_flag3 THEN 
  DBMS_OUTPUT.put_line('v_flag1 OR v_flag3) = TRUE');
 END IF;
 IF v_flag1 AND v_flag3 IS NULL THEN 
  DBMS_OUTPUT.put_line('v_flag1 AND v_flag3的結果為NULL');
 END IF;
END;
/

