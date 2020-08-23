--============================================================================--
--                                                                            --
/* ※PL/SQL編程基礎-PL/SQL簡介                                                */
--                                                                            --
--============================================================================--
-- 說明:PL/SQL是Oracle在關係數據庫結構化查詢語言SQL基礎上擴展得到的一種過程化查
-- 尋語言。SQL與編程語言支的不同在於，SQL沒有變量，SQL沒有流程控制(分支，循環)。
-- 而PL/SQL是結構化的和過程化的結合體，而且最為重要的是，用戶執行多條SQL語句時
-- ，每條SQL語句都是逐一的發送給數據庫，而PL/SQL可以一次性將多條SQL語句一起發送
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
--============================================================================--
--                                                                            --
/* ※PL/SQL編程基礎-數據類型劃分                                              */
--                                                                            --
--============================================================================--
-- ➤在Oracle之中所提供的數據類型，一共分為四類:
-- ①變量類型(SCALAR，或稱基本數據類型):用於保存單個值，如:字串、數字、日期、
-- 布爾。
-- ②複合類型(COMPOSIT):複合類型可以在內部存放多種數值，類似於多個變量的集合，
-- 如:紀錄類型、嵌套表、索引表、可變數組等都稱為複合類型。
-- ③引用類型(REFERENCE):用於指向另一不同的對象，如:REF CURSOR、REF。
-- ④LOB類型:大數據類型，最多可以存儲4G的訊息，主要用來處理二進制數據。


-- ➤數值型
-- 說明:數執行數據可以保存整數、浮點數，可以使用NUMBER、PLS_INTEGER、
-- BINARY_INTEGER、BINARY_FLOAT、BINARY_DOUBLE進行定義。


-- ➤NUMBER類型
-- NUMBER數據類型即可以定義整數(NUMBER(n))也可以定義浮點數型數據(NUMBER(n,m))。


-- ➤NUMBER類型
-- NUMBER數據類型即可以定義整數(NUMBER(n))也可以定義浮點數型數據(NUMBER(n,m))。
-- ex:定義NUMBER變量
SET SERVEROUTPUT ON;
DECLARE 
 v_x NUMBER(3); -- 最多只能為3位數字
 v_y NUMBER(5,2); -- 3位整數，2位小數
BEGIN 
 v_x := -500; -- 設置內容
 v_y := 999.88; -- 設置內容
 DBMS_OUTPUT.put_line('v_x = ' || v_x);
 DBMS_OUTPUT.put_line('v_y = ' || v_y);
 DBMS_OUTPUT.put_line('加法計算: ' || (v_x + v_y));
END;
/


-- ➤PLS_INTEGER、BINARY_INTEGER類型
-- 說明:使用BINARY_INTEGER操作的數據大於其數據範圍定義時，會自動將其變為NUMBER
-- 型數據保存，而使用PLS_INTEGER操作的數據大於其數據範圍定義時，會拋出異常。
-- ex:
DECLARE 
 v_x PLS_INTEGER := 10; 
 v_y PLS_INTEGER := 20; 
BEGIN  
 DBMS_OUTPUT.put_line('加法計算: ' || (v_x + v_y));
END;
/


-- ➤BINARY_FLOAT、BINARY_DOUBLE類型
-- 在Oracle 10g之後引入，使用這兩個類型要比使用NUMBER節省空間，同時表示的範圍也
-- 越大，最為重要的是這兩個數據類型並不像NUMBER採用了十進制方式存儲，而直接採用
-- 二進制方式存儲，
DECLARE 
 v_float BINARY_FLOAT := 8909.51F; 
 v_double BINARY_DOUBLE := 8909.51D; 
BEGIN  
 DBMS_OUTPUT.put_line('BINARY_FLOAT變量內容: ' || v_float);
 DBMS_OUTPUT.put_line('BINARY_DOUBLE變量內容: ' || v_double);
END;
/

DECLARE 
 v_float BINARY_FLOAT := 8909.51F; 
 v_double BINARY_DOUBLE := 8909.51D; 
BEGIN 
 v_float := v_float + 1000.16;
 v_double := v_double + 1000.16;
 DBMS_OUTPUT.put_line('BINARY_FLOAT變量內容: ' || v_float);
 DBMS_OUTPUT.put_line('BINARY_DOUBLE變量內容: ' || v_double);
END;
/


-- ➤BINARY_FLOAT、BINARY_DOUBLE常量
-- ex:觀察BINARY_FLOAT、BINARY_DOUBLE常量內容
BEGIN 
 DBMS_OUTPUT.put_line('BINARY_FLOAT_MIN_NORMAL = ' 
 || BINARY_FLOAT_MIN_NORMAL);
 DBMS_OUTPUT.put_line('BINARY_FLOAT_MAX_NORMAL = ' 
 || BINARY_FLOAT_MAX_NORMAL);
 DBMS_OUTPUT.put_line('BINARY_FLOAT_MIN_SUBNORMAL = ' 
 || BINARY_FLOAT_MIN_SUBNORMAL);
 DBMS_OUTPUT.put_line('BINARY_FLOAT_MAX_SUBNORMAL = ' 
 || BINARY_FLOAT_MAX_SUBNORMAL);
 DBMS_OUTPUT.put_line('---------------------');
 DBMS_OUTPUT.put_line('BINARY_DOUBLE_MIN_NORMAL = ' 
 || BINARY_DOUBLE_MIN_NORMAL);
 DBMS_OUTPUT.put_line('BINARY_DOUBLE_MAX_NORMAL = ' 
 || BINARY_DOUBLE_MAX_NORMAL);
 DBMS_OUTPUT.put_line('BINARY_DOUBLE_MIN_SUBNORMAL = ' 
 || BINARY_DOUBLE_MIN_SUBNORMAL);
 DBMS_OUTPUT.put_line('BINARY_DOUBLE_MAX_SUBNORMAL = ' 
 || BINARY_DOUBLE_MAX_SUBNORMAL);
END;
/


-- ex:超過範圍的計算
BEGIN  
 DBMS_OUTPUT.put_line('超過範圍計算的結果: ' || BINARY_DOUBLE_MAX_SUBNORMAL 
 * BINARY_DOUBLE_MAX_SUBNORMAL);
END;
/

BEGIN  
 DBMS_OUTPUT.put_line('超過範圍計算的結果: ' || BINARY_DOUBLE_MAX_SUBNORMAL 
 / 0);
END;
/


-- ➤字串型
-- 說明:字串是使用單引號聲明的內容，常用的是VARCHAR2。
/*
其他字串類型:
①CHAR與VARCHAR2:CHAR數據類型使用定長的方式保存字串，如果用戶為其設置的內容不足
其定義長度，會自動補充空格。
②NCHAR與NVARCHAR2:NCHAR與NVARCHAR2的操作特點與CHAR和VARCHAR2一樣，唯一不同的是
，NCHAR和NVARCHAR2保存的數據為UNICODE編碼，即:中文或英文都會變為16進制編碼保存。
③LONG與LONG RAW:LONG與LONG RAW數據類型只用於後向兼容，一般在使用LONG的地方都會
使用CLOB或NCLOB，而使用LONG RAW的地方都替換為BLOB或BILE。LONG數據類型主要存儲字
串流，而LONG RAW主要存儲二進制數據流。
④ROWID與UROWID:ROWID表示的是一條數據的物理行地址，由18個字串組合而成，這一點與
Oracle數據庫表中的ROWID偽列功能相同。UROWID(UNIVERSAL ROWID，通用性ROWID)除了表
示數據的物理行地址之外還增加了一個邏輯行地址，在PL/SQL編程之中應該將所有的ROWID
交給UROWID管理。
*/
-- ex:CHAR與VARCHAR2區別
DECLARE 
 v_info_char CHAR(10); 
 v_info_varchar2 VARCHAR2(10);
BEGIN  
 v_info_char := 'ORACLE'; -- 長度不足10
 v_info_varchar2 := 'java'; -- 長度不足10
 DBMS_OUTPUT.put_line('v_info_char內容長度: ' || LENGTH(v_info_char));
 DBMS_OUTPUT.put_line('v_info_varchar2內容長度: ' || LENGTH(v_info_varchar2));
END;
/
-- 發現如果是CHAR內容長度不夠，會使用空格自動填充。


-- ex:驗證NCHAR與NVARCHAR2
DECLARE 
 v_info_nchar NCHAR(10); 
 v_info_nvarchar2 NVARCHAR2(10);
BEGIN  
 v_info_nchar := '甲骨文'; -- 長度不足10
 v_info_nvarchar2 := 'java專業培訓'; -- 長度不足10
 DBMS_OUTPUT.put_line('v_info_nchar內容長度: ' || LENGTH(v_info_nchar));
 DBMS_OUTPUT.put_line('v_info_nvarchar2內容長度: ' || LENGTH(v_info_nvarchar2));
END;
/
-- 此時每一位中文只能佔一位。


-- ex:使用LONG與LONG RAW操作
DECLARE 
 v_info_long LONG; 
 v_info_longraw LONG RAW;
BEGIN  
 v_info_long := '甲骨文'; -- 長度不足10
 v_info_longraw := 'java專業培訓'; -- 長度不足10
 DBMS_OUTPUT.put_line('v_info_long內容長度: ' || v_info_long);
 DBMS_OUTPUT.put_line('v_info_longraw內容長度: ' || v_info_longraw);
END;
/
-- ORA-06502: PL/SQL: 數字或值錯誤: 十六進位到原始格式轉換錯誤

DECLARE 
 v_info_long LONG; 
 v_info_longraw LONG RAW;
BEGIN  
 v_info_long := '甲骨文'; -- 長度不足10
 v_info_longraw := UTL_RAW.cast_to_raw('java專業培訓'); -- 長度不足10 
 DBMS_OUTPUT.put_line('v_info_long內容長度: ' || v_info_long);
 DBMS_OUTPUT.put_line('v_info_longraw內容長度: ' || 
 UTL_RAW.cast_to_varchar2(v_info_longraw));
END;
/


-- ex:ROWID與UROWID
DECLARE 
 v_emp_rowid ROWID; 
 v_emp_urowid UROWID;
BEGIN
 SELECT ROWID INTO v_emp_rowid FROM emp WHERE empno=7369;
 SELECT ROWID INTO v_emp_urowid FROM emp WHERE empno=7369;
 DBMS_OUTPUT.put_line('7369員工的ROWID ' || v_emp_rowid);
 DBMS_OUTPUT.put_line('7369員工的UROWID ' || v_emp_urowid);
END;
/


-- ➤日期型
-- 說明:在Oracle中，日期類型的數據主要包含DATE、TIMESTAMP、INTEVAL這幾個類型，
-- 透過這幾個類型允許用戶操作日期、時間、時間間隔。
-- ex:定義DATE型變量
DECLARE 
 v_date1 DATE := SYSDATE;
 v_date2 DATE := SYSTIMESTAMP;
 v_date3 DATE := '19-9月-1981';
BEGIN
 DBMS_OUTPUT.put_line('日期數據: ' || 
 TO_CHAR(v_date1,'YYYY-MM-DD HH24:MI:SS'));
 DBMS_OUTPUT.put_line('日期數據: ' || 
 TO_CHAR(v_date2,'YYYY-MM-DD HH24:MI:SS'));
 DBMS_OUTPUT.put_line('日期數據: ' || 
 TO_CHAR(v_date3,'YYYY-MM-DD HH24:MI:SS'));
END;
/


-- ➤TIMESTAMP
-- 說明:TIMESTAMP與DATE類型相同，但是相比較DATE類型而言，TIMESTAMP可以提供
-- 更為精確的時間，但是此時就必須使用SYSTIMESTAMP偽列來為其賦值，如果使用的只
-- 是SYSDATE，那麼TIMESTAMP與DATE沒有任何區別。
-- ex:
DECLARE 
 v_timestamp1 TIMESTAMP := SYSDATE;
 v_timestamp2 TIMESTAMP := SYSTIMESTAMP;
 v_timestamp3 TIMESTAMP := '19-9月-1981';
BEGIN
 DBMS_OUTPUT.put_line('日期數據: ' || v_timestamp1);
 DBMS_OUTPUT.put_line('日期數據: ' || v_timestamp2);
 DBMS_OUTPUT.put_line('日期數據: ' || v_timestamp3);
END;
/


-- ➤TIMESTAMP兩個子類型
-- 說明:在TIMESTAMP之中還定義了兩個擴充的子類型:
-- TIMESTAMP WITH TIME ZONE:包含與格林威治時間的時區偏移量。
-- TIMESTAMP WITH LOCAL TIME ZONE:不管是何種時區的數據，都使用當前數據庫
-- 的時區。
-- ex:使用TIMESTAMP WITH TIME ZONE
DECLARE 
 v_timestamp TIMESTAMP WITH TIME ZONE := SYSTIMESTAMP;
BEGIN
 DBMS_OUTPUT.put_line('日期數據: ' || v_timestamp);
END;
/


-- ex:使用TIMESTAMP WITH LOCAL TIME ZONE
DECLARE 
 v_timestamp TIMESTAMP WITH LOCAL TIME ZONE := SYSTIMESTAMP;
BEGIN
 DBMS_OUTPUT.put_line('日期數據: ' || v_timestamp);
END;
/


-- ➤INTERVAL
-- 說明:之前的兩種日期時間類型都只是單純的紀錄某個日期時間點的數據，如果現在想
-- 保存兩個時間戳之間的時間間隔，則可以使用INTERVAL數據類型，分為兩種子類型:
-- ①INTERVAL YEAR[(年的精度)] TO MONTH:保存的操作年和月之間的時間間隔，用
-- 戶可以指定設置的數據精度，如果不設置精度，則默認值為2。
-- 賦值字串格式:'年-月'。
-- ②INTERVAL DAY[(天的精度)] TO SECOND[(秒的精度)]:保存和操作天、時、分、
-- 秒之間的時間間隔，如果未設置天的精度數字，則默認值為2。如果沒有設置秒的精度
-- 則默認為6。
-- 賦值字串格式:'天 時:分:秒.毫秒'。
-- ex:定義INTERVAL YEAR TO MONTH類型
DECLARE 
 v_interval INTERVAL YEAR(3) TO MONTH := 
 INTERVAL '19-11' YEAR TO MONTH;
BEGIN
 DBMS_OUTPUT.put_line('時間間隔: ' || v_interval);
 DBMS_OUTPUT.put_line('當前時間戳 + 時間間隔: ' || 
 (SYSTIMESTAMP + v_interval));
  DBMS_OUTPUT.put_line('當前日期 + 時間間隔: ' || 
 (SYSDATE + v_interval));
END;
/


-- ex:定義INTERVAL DAY TO SECOND類型
DECLARE 
 v_interval INTERVAL DAY(6) TO SECOND(3) := 
 INTERVAL '8 18:19:27.367123909' DAY TO SECOND;
BEGIN
 DBMS_OUTPUT.put_line('時間間隔: ' || v_interval);
 DBMS_OUTPUT.put_line('當前時間戳 + 時間間隔: ' || 
 (SYSTIMESTAMP + v_interval));
  DBMS_OUTPUT.put_line('當前日期 + 時間間隔: ' || 
 (SYSDATE + v_interval));
END;
/


-- ➤布爾型
-- ex:使用布爾型變量
DECLARE 
 v_flag BOOLEAN;
BEGIN
 v_flag := TRUE;
 IF v_flag THEN
  DBMS_OUTPUT.put_line('條件滿足');
 END IF; 
END;
/
-- ➤ 子類型
-- 說明:雖然Oracle為用戶提供了許多的標量類型數據，但是很多時候用戶會希望在某
-- 一標量類型的基礎上定義更多的約束，從而創建一個新的類型，此時這種新的類型就
-- 被稱為子類性，子類型的創建語法如下:
-- SUBTYPE 子類型名稱 IS 父數據類型[(約束)][NOT NULL];
-- ex:定義NUMBER子類型
DECLARE 
 SUBTYPE score_subtype IS NUMBER(5,2) NOT NULL;
 v_score score_subtype := 99.35;
BEGIN 
  DBMS_OUTPUT.put_line('成績為:' || v_score);
END;
/


-- ex:定義VARCHAR2子類型
DECLARE 
 SUBTYPE string_subtype IS VARCHAR2(200);
 v_company string_subtype := '甲骨文股份有限公司(www.oracle.com)';
BEGIN 
  DBMS_OUTPUT.put_line(v_company);
END;
/
--============================================================================--
--                                                                            --
/* ※PL/SQL編程基礎-程序結構                                                  */
--                                                                            --
--============================================================================--
-- 說明:PL/SQL程序與其他程式語言一樣，也擁有自己的三種程序結構:順序結構、
-- 分支結構、循環結構。這三種不同的結構都有一個共同點，他們都只有一個入口
-- ，也只有一個出口，這些單一入、出口可以讓程序易讀、好維護，也可以減少調
-- 適時間。

-- ➤分支結構
-- 說明:在PL/SQL程序中的分支語句只要有兩種:IF語句、CASE語句。這兩種語句都
-- 是需要進行條件的判斷。
-- IF語句、IF...ELSE語句、IF...ELSIF...ELSE語句。
-- ex:IF語句
DECLARE 
 v_countResult NUMBER;
BEGIN 
 SELECT COUNT(empno) INTO v_countResult FROM emp;
  IF v_countResult > 10 THEN
   DBMS_OUTPUT.put_line('EMP表中的紀錄大於10條');
  END IF;
END;
/


-- ex:IF...ELSE語句
DECLARE 
 v_countResult NUMBER;
BEGIN 
 SELECT COUNT(deptno) INTO v_countResult FROM dept;
  IF v_countResult > 10 THEN
   DBMS_OUTPUT.put_line('DEPT表中的紀錄大於10條');
  ELSE
   DBMS_OUTPUT.put_line('DEPT表中的紀錄小於10條');
  END IF;
END;
/


-- ex:IF...ELSIF...ELSE語句
DECLARE 
 v_countResult NUMBER;
BEGIN 
 SELECT COUNT(empno) INTO v_countResult FROM emp;
  IF v_countResult > 10 THEN
   DBMS_OUTPUT.put_line('EMP表中的紀錄大於10條');
  ELSIF v_countResult < 10 THEN
   DBMS_OUTPUT.put_line('EMP表中的紀錄小於10條');
  ELSE 
   DBMS_OUTPUT.put_line('EMP表中的紀錄等於10條');
  END IF;
END;
/


-- ex:查詢emp表工資，輸入員工編號，根據編號查詢工資，如果工資高於3000
-- 元則顯示高工資，如果工資大於2000元則顯示中等工資，如果工資小於2000元
-- 則顯示低工資。
DECLARE 
 v_empSal emp.sal%TYPE; -- 定義變量與emp.sal欄位類型相同
 v_empName emp.ename%TYPE; -- 定義變量與emp.ename欄位類型相同
 v_eno emp.empno%TYPE; -- 定義變量與emp.empno欄位類型相同
BEGIN 
v_eno := &inputEmpno;
 SELECT ename,sal INTO v_empName,v_empSal 
 FROM emp WHERE empno=v_eno;
  IF v_empSal > 3000 THEN
   DBMS_OUTPUT.put_line(v_empName || '的工資屬於高工資');
  ELSIF v_empSal > 2000 THEN
   DBMS_OUTPUT.put_line(v_empName || '的工資屬於中等工資');
  ELSE DBMS_OUTPUT.put_line(v_empName || '的工資屬於低工資');
  END IF;
END;
/


-- ex:用戶輸入一個員工編號，根據他所在的部門給上漲工資，規則:
-- 10部門上漲10%，20上漲20%，30上漲30%
-- 但是要求最高不能超過5000，超過5000就停留在5000
DECLARE 
 v_empSal emp.sal%TYPE;  
 v_eno emp.empno%TYPE; 
 v_empDeptno emp.deptno%TYPE;
BEGIN 
v_eno := &inputEmpno;
 SELECT sal,deptno INTO v_empSal,v_empDeptno 
 FROM emp WHERE empno=v_eno;
  IF v_empDeptno = 10 THEN
   IF v_empSal*1.1 <5000 THEN
    UPDATE emp SET sal=v_empSal*1.1 WHERE empno=v_eno;
   ELSE
    UPDATE emp SET sal=5000 WHERE empno=v_eno;
   END IF;
  ELSIF v_empDeptno = 20 THEN
   IF v_empSal*1.2 <5000 THEN
    UPDATE emp SET sal=v_empSal*1.2 WHERE empno=v_eno;
   ELSE
    UPDATE emp SET sal=5000 WHERE empno=v_eno;
   END IF;
  ELSIF v_empDeptno = 30 THEN    
   IF v_empSal*1.3 <5000 THEN
    UPDATE emp SET sal=v_empSal*1.3 WHERE empno=v_eno;
   ELSE
    UPDATE emp SET sal=5000 WHERE empno=v_eno;
   END IF;  
  ELSE 
   NULL;
  END IF;
END;
/
ROLLBACK;


-- ➤常用比較運算符
-- ex:操作比較運算符AND
DECLARE  
BEGIN 
 IF 'ORACLE'='ORACLE' AND 100=100 THEN 
  DBMS_OUTPUT.put_line('結果為TRUE，滿足條件');
 END IF;
END;
/


-- ex:操作比較運算符BETWEEN...AND...
DECLARE  
BEGIN 
 IF TO_DATE('1983-09-19','YYYY-MM-DD') BETWEEN 
 TO_DATE('1980-01-01','YYYY-MM-DD') AND 
 TO_DATE('1989-12-31','YYYY-MM-DD') THEN 
  DBMS_OUTPUT.put_line('結果為TRUE，滿足條件');
 END IF;
END;
/


-- ex:操作比較運算符IN
BEGIN 
 IF 10 IN(10,20,30) THEN 
  DBMS_OUTPUT.put_line('結果為TRUE，滿足條件');
 END IF;
END;
/


-- ex:操作比較運算符IS NULL
DECLARE
 v_temp BOOLEAN;
BEGIN 
 IF v_temp IS NULL THEN 
  DBMS_OUTPUT.put_line('結果為TRUE，滿足條件');
 END IF;
END;
/


-- ex:操作比較運算符LIKE
BEGIN 
 IF 'www.oracle.com' LIKE '%oracle%' THEN 
  DBMS_OUTPUT.put_line('結果為TRUE，滿足條件');
 END IF;
END;
/


-- ex:操作比較運算符NOT
BEGIN 
 IF NOT FALSE THEN 
  DBMS_OUTPUT.put_line('結果為TRUE，滿足條件');
 END IF;
END;
/


-- ex:操作比較運算符OR
BEGIN 
 IF 'ORACLE'='JAVA' OR 10=10 THEN 
  DBMS_OUTPUT.put_line('結果為TRUE，滿足條件');
 END IF;
END;
/


-- ➤CASE語句
-- 說明:CASE語句是一種多條件的判斷語句，其功能與IF...ELSIF...ELSE類似。
-- ex:使用CASE語句判斷
DECLARE
 v_chooese NUMBER := 1;
BEGIN 
 CASE v_chooese
  WHEN 0 THEN
   DBMS_OUTPUT.put_line('您選擇的是第0項');
  WHEN 1 THEN
   DBMS_OUTPUT.put_line('您選擇的是第1項');
  ELSE
   DBMS_OUTPUT.put_line('沒有選項滿足');
 END CASE;
END;
/


-- ex:輸入員工編號，根據員工編號的職位進行工資提升，提升要求如下
-- 如果職位是辦事員(CLERK)，工資增長5%
-- 如果職位是銷售員(SALESMAN)，工資增長8%
-- 如果職位是經理(MANAGER)，工資增長10%
-- 如果職位是分析員(ANALYST)，工資增長20%
-- 如果職位是總裁(PRESIDENT)，工資不增長
DECLARE
 v_eno emp.empno%TYPE;
 v_empJob emp.job%TYPE; 
BEGIN 
 v_eno := &inputEno;
 SELECT job INTO v_empJob 
 FROM emp WHERE empno=v_eno;
 CASE v_empJob
  WHEN 'CLERK' THEN
   UPDATE emp SET sal=sal*1.05 WHERE empno=v_eno;
  WHEN 'SALESMAN' THEN
   UPDATE emp SET sal=sal*1.08 WHERE empno=v_eno;
  WHEN 'MANAGER' THEN 
   UPDATE emp SET sal=sal*1.1 WHERE empno=v_eno;
  WHEN 'ANALYST' THEN 
   UPDATE emp SET sal=sal*1.2 WHERE empno=v_eno;
  WHEN 'PRESIDENT' THEN 
   UPDATE emp SET sal=sal WHERE empno=v_eno;
  ELSE
   DBMS_OUTPUT.put_line('員工:' || v_eno || '不具工資上漲資格');
 END CASE;
END;
/
ROLLBACK;


-- ➤循環結構
-- ➤LOOP循環
-- 說明:先執行後判斷，至少執行一次。(DO WHILE)
/*
語法:
LOOP 
 循環執行的語句快;
 EXIT WHEN 循環結束條件;
 循環結束條件修改;
END LOOP;
*/
-- ex:使用LOOP循環
DECLARE
 v_i NUMBER := 1;
BEGIN 
 LOOP
  DBMS_OUTPUT.put_line('v_i = ' || v_i);
  EXIT WHEN v_i >= 3;
  v_i := v_i + 1;
 END LOOP;
END;
/


-- ➤WHILE...LOOP循環
-- 說明:先判斷再執行(WHILE)
/*
語法:
WHILE(循環結束條件)LOOP 
 循環執行的語句塊;
 循環結束條件修改;
END LOOP;
*/
-- ex:使用WHILE...LOOP循環
DECLARE
 v_i NUMBER := 1;
BEGIN 
 WHILE(v_i <= 3)LOOP
  DBMS_OUTPUT.put_line('v_i = ' || v_i);  
  v_i := v_i + 1;
 END LOOP;
END;
/


-- ➤FOR循環
/*
語法:
FOR 循環索引 IN[REVERSE] 循環區域下限 .. 循環區域上限 LOOP
 循環執行的語句塊;
END LOOP;
*/
-- ex:使用FOR循環
DECLARE
 v_i NUMBER := 1;
BEGIN 
 FOR v_i IN 1 .. 3 LOOP
  DBMS_OUTPUT.put_line('v_i = ' || v_i);   
 END LOOP;
END;
/


-- ex:反轉循環
DECLARE
 v_i NUMBER := 1;
BEGIN 
 FOR v_i IN REVERSE 1 .. 3 LOOP
  DBMS_OUTPUT.put_line('v_i = ' || v_i);   
 END LOOP;
END;
/


-- ➤控制循環
-- 說明:在正常循環操作之中，如果需要結束循環或者是退出當前循環，則可以
-- 使用EXIT與CONTINUE語句完成。一般這兩種控制語句都要結合分支語句進行
-- 判斷。
-- ex:使用EXIT
DECLARE
 v_i NUMBER := 1;
BEGIN 
 FOR v_i IN 1 .. 10 LOOP
  IF v_i = 3 THEN
   EXIT;
  END IF; 
  DBMS_OUTPUT.put_line('v_i = ' || v_i);   
 END LOOP;
END;
/


-- ex:使用CONTINUE
DECLARE
 v_i NUMBER := 1;
BEGIN 
 FOR v_i IN 1 .. 10 LOOP
  IF MOD(v_i,2)=0 THEN
   CONTINUE;
  END IF; 
  DBMS_OUTPUT.put_line('v_i = ' || v_i);   
 END LOOP;
END;
/


-- ➤GOTO語句
-- 說明:指的是無條件跳轉指令。
DECLARE
 v_result NUMBER := 1;
BEGIN 
 FOR v_result IN 1 .. 10 LOOP
  IF v_result=2 THEN
   GOTO endPoint;
  END IF; 
  DBMS_OUTPUT.put_line('v_result = ' || v_result);   
 END LOOP;
 <<endPoint>>
  DBMS_OUTPUT.put_line('FOR循環提前結束。');
END;
/
--============================================================================--
--                                                                            --
/* ※PL/SQL編程基礎-內部程序塊                                                */
--                                                                            --
--============================================================================--
-- 說明:對於每一個PL/SQL程序塊其基本的組成部分就是DECLARE、BEGIN、END，
-- 如果用戶有需要也可以在一個程序塊之中定義多個子程序塊。

-- ex:操作內部程序塊
DECLARE
 v_x NUMBER := 30; -- 全局變量
BEGIN 
  DECLARE
   v_x VARCHAR2(40) := 'ORACLEJAVA'; -- 局部變量
   v_y NUMBER := 20;
  BEGIN  
   DBMS_OUTPUT.put_line('內部程序塊輸出: v_x = ' || v_x);
   DBMS_OUTPUT.put_line('內部程序塊輸出: v_y = ' || v_y);
  END;
 DBMS_OUTPUT.put_line('外部程序塊輸出: v_x = ' || v_x);
END;
/
--============================================================================--
--                                                                            --
/* ※PL/SQL編程基礎-異常處理                                                  */
--                                                                            --
--============================================================================--
-- 說明:在程序開發之中經常會由於設計錯誤、編碼錯誤、硬件故障或其他原因引起程序
-- 的運行錯誤。雖然不可能預測所有錯誤，但在程序中可以規畫處理某些類型的錯誤。在
-- PL/SQL程序中的異常處理機制使得在出現某些錯誤的時候程序仍然可以執行。比如內部
-- 溢出或者零除等等。在PL/SQL程序之中一共分為兩種異常類型:
-- 編譯型異常:程序的語法出現了錯誤所導致的異常。
-- 運行時異常:程序沒有語法問題，但在運行時會因為程序運算或者返回結果而出現錯誤。
-- ▲用戶可以處理的只有運行時異常，而對於編譯的異常，只能透過語法解決。

-- ex:語法錯誤異常
DECLARE
 v_result NUMBER := 1;
BEGIN
 IF v_result = 1 -- 缺少THEN
  DBMS_OUTPUT.put_line('滿足條件');
 END IF;
END;
/


-- ex:運行時異常
DECLARE
 v_result NUMBER;
BEGIN
  v_result := 10/0; -- 被除數為0
END;
/


-- ➤異常處理
-- 如果要進行異常處理，需使用EXCEPTION子句完成，這個子句裡面要針對於異常進行捕
-- 獲，而後針對於捕獲的異常進行處理。
-- 語法:
-- WHEN 異常類型|用戶定義異常|異常代碼|OTHERS THEN 異常處理;
-- ex:處理被除數是0的異常(zero_divide)
DECLARE
 v_result NUMBER;
BEGIN
  v_result := 10/0; -- 被除數為0
  DBMS_OUTPUT.put_line('異常之後的代碼將不再執行');
EXCEPTION 
 WHEN zero_divide THEN 
 DBMS_OUTPUT.put_line('被除數不能為零');
 DBMS_OUTPUT.put_line('SQLCODE = ' || SQLCODE);
END;
/


-- ex:處理賦值異常(value_error)
DECLARE
 v_varA VARCHAR2(1);
 v_varB VARCHAR2(4) := 'java';
BEGIN
 v_varA := v_varB;
DBMS_OUTPUT.put_line('異常之後的代碼將不再執行');
EXCEPTION 
 WHEN value_error THEN 
 DBMS_OUTPUT.put_line('數據賦值錯誤。');
 DBMS_OUTPUT.put_line('SQLCODE = ' || SQLCODE);
END;
/


-- ex:查詢的異常，員工編號不存在(no_data_found)
DECLARE
 v_eno emp.empno%TYPE;
 v_ename emp.ename%TYPE; 
BEGIN
 v_eno := &empno; -- 由鍵盤輸入員工編號
 SELECT ename INTO v_ename FROM emp WHERE empno=v_eno;
 DBMS_OUTPUT.put_line('編號為: ' || v_eno || ', 
 員工的名字為: ' || v_ename);
EXCEPTION 
 WHEN no_data_found THEN 
 DBMS_OUTPUT.put_line('員工編號不存在!');
 DBMS_OUTPUT.put_line('SQLCODE = ' || SQLCODE);
END;
/


-- ex:返回多條數據(too_many_rows)
-- ORA-01422: 精確擷取傳回的列數超過所要求的列數
-- 因為一個變量只能接收一個內容，而10部門的員工姓名是多條數據。
DECLARE
 v_dno dept.deptno%TYPE;
 v_ename emp.ename%TYPE; 
BEGIN
 v_dno := &deptno; -- 由鍵盤輸入部門編號
 SELECT ename INTO v_ename FROM emp WHERE deptno=v_dno; 
END;
/
-- 解決:
DECLARE
 v_dno dept.deptno%TYPE;
 v_ename emp.ename%TYPE; 
BEGIN
 v_dno := &deptno; -- 由鍵盤輸入部門編號
 SELECT ename INTO v_ename FROM emp WHERE deptno=v_dno;
EXCEPTION 
 WHEN too_many_rows THEN 
 DBMS_OUTPUT.put_line('返回數據過多!');
 DBMS_OUTPUT.put_line('SQLCODE = ' || SQLCODE);
END;
/


-- 分別去記不同類型的異常是一件很麻煩的事情，所以PL/SQL中提中了一種更為
-- 簡便的異常處理方案，使用OTHERS。
-- ex:使用OTHERS處理
DECLARE
 v_dno dept.deptno%TYPE;
 v_ename emp.ename%TYPE; 
BEGIN
 v_dno := &deptno; -- 由鍵盤輸入部門編號
 SELECT ename INTO v_ename FROM emp WHERE deptno=v_dno;
EXCEPTION 
 WHEN OTHERS THEN 
 DBMS_OUTPUT.put_line('返回數據過多!');
 DBMS_OUTPUT.put_line('SQLCODE = ' || SQLCODE);
 DBMS_OUTPUT.put_line('SQLERRM = ' || SQLERRM);
END;
/


-- ex:使用OTHERS處理
DECLARE
 v_result NUMBER;
 v_title VARCHAR2(50) := 'www.oracle.com'; 
BEGIN
 v_result := v_title; -- 此處出現異常 
EXCEPTION 
 WHEN OTHERS THEN  
 DBMS_OUTPUT.put_line('SQLCODE = ' || SQLCODE);
 DBMS_OUTPUT.put_line('SQLERRM = ' || SQLERRM);
END;
/


-- ➤用戶自定義異常
-- 方式一:在聲明塊中聲明EXCEPTION對象，此方式有兩種選擇:
--   選擇一:聲明異常對象並用名稱來引用他，此方式使用普通的OTHERS異常捕獲
--         用戶定義異常。
--   選擇二:聲明異常對象並將他與有效的Oracle錯誤代碼映射，需要編寫單獨的
--         WHEN語句區塊捕獲。
-- 方式二:在執行塊中建構動態異常。透過"RAISE_APPLICATION_ERROR"函數可以
--       建構動態異常。在觸發動態異常時，可使用-20000~-20999範圍的數字。
--       如果使用動態異常，可以在運行時指派錯誤消息。
-- ex:操作自定義異常
DECLARE
 v_data NUMBER;
 v_myexp EXCEPTION; -- 定義一個異常變量
BEGIN
 v_data := &inputData; -- 輸入數據
 IF v_data > 10 AND v_data <100 THEN
  RAISE v_myexp; -- 拋出異常
 END IF;
END;
/
-- 錯誤報告:ORA-06510: PL/SQL: 無法處理的使用者自訂異常狀況
-- 此時不存在EXCEPTION處理，所以這個時候會直接中斷程序的執行。


-- ex:加入EXCEPTION進行處理
DECLARE
 v_data NUMBER;
 v_myexp EXCEPTION; -- 定義一個異常變量
BEGIN
 v_data := &inputData; -- 輸入數據
 IF v_data > 10 AND v_data <100 THEN
  RAISE v_myexp; -- 拋出異常
 END IF;
EXCEPTION 
 WHEN v_myexp THEN -- 出現指定的異常
 --WHEN OTHERS THEN
 DBMS_OUTPUT.put_line('輸入數據有誤');
 DBMS_OUTPUT.put_line('SQLCODE = ' || SQLCODE);
 DBMS_OUTPUT.put_line('SQLERRM = ' || SQLERRM);
END;
/
/*
輸入數據有誤
SQLCODE = 1
SQLERRM = User-Defined Exception
*/
-- 如果現在不想使用自定義的v_myexp進行異常類型捕獲，那麼使用OTHERS
-- 也是可以的。


-- 在進行人為拋出異常的時候，默認的SQLCODE的內容是1，而SQLERRM的內容
-- 為用戶定義異常。而用戶也可以直接為自定義異常設置名稱。
-- ex:設置自定義異常
DECLARE
 v_data NUMBER;
 v_myexp EXCEPTION; -- 定義一個異常變量
 PRAGMA EXCEPTION_INIT(v_myexp, -20789);
BEGIN
 v_data := &inputData; -- 輸入數據
 IF v_data > 10 AND v_data <100 THEN
  RAISE v_myexp; -- 拋出異常
 END IF;
EXCEPTION 
 WHEN v_myexp THEN -- 出現指定的異常
 DBMS_OUTPUT.put_line('輸入數據有誤');
 DBMS_OUTPUT.put_line('SQLCODE = ' || SQLCODE);
 DBMS_OUTPUT.put_line('SQLERRM = ' || SQLERRM);
END;
/
/*
輸入數據有誤
SQLCODE = -20789
SQLERRM = ORA-20789: 
*/


-- 除了用戶自己設置的錯誤編碼，也可以和一個已存在的編碼進行連接
-- ex:和ROWID異常的錯誤編碼-01410進行連接
DECLARE
 v_input_rowid VARCHAR2(18);
 v_myexp EXCEPTION;
 PRAGMA EXCEPTION_INIT(v_myexp, -01410);
BEGIN
 v_input_rowid := '&inputRowid'; -- 輸入一個ROW數據,www.roacle.com
 IF LENGTH(v_input_rowid) != 18 THEN
  RAISE v_myexp; -- 拋出異常
 END IF;
EXCEPTION 
 WHEN v_myexp THEN -- 出現指定的異常 
 DBMS_OUTPUT.put_line('SQLCODE = ' || SQLCODE);
 DBMS_OUTPUT.put_line('SQLERRM = ' || SQLERRM);
END;
/
/*
SQLCODE = -1410
SQLERRM = ORA-01410: ROWID 無效
*/


-- ➤建構動態異常
-- 說明:程序之中，也可以將用戶定義的異常添加到異常列表(異常堆棧)之中
/*
語法:
RAISE_APPLICATION_ERROR(錯誤號，錯誤訊息[,是否添加到錯誤堆棧])

語法參數
錯誤號:只接受-20000~-20999範圍的錯誤號，和聲明的錯誤號一致。
錯誤訊息:用於定義在使用SQLERRM輸出時的錯誤提示訊息。
是否添加到錯誤堆棧:如果設置為TRUE，則表示將錯誤添加到任意已有的錯誤堆棧，
默認為FALSE，可選。
*/
-- ex:構建動態異常
DECLARE
 v_data NUMBER;
 v_myexp EXCEPTION; -- 定義一個異常變量
 PRAGMA EXCEPTION_INIT(v_myexp, -20789);
BEGIN
 v_data := &inputData; -- 輸入數據
 IF v_data > 10 AND v_data <100 THEN
  RAISE_APPLICATION_ERROR(-20789, 
  '輸入數字不能在10~100之間'); -- 拋出異常
 END IF;
EXCEPTION 
 WHEN v_myexp THEN -- 出現指定的異常
 DBMS_OUTPUT.put_line('輸入數據有誤');
 DBMS_OUTPUT.put_line('SQLCODE = ' || SQLCODE);
 DBMS_OUTPUT.put_line('SQLERRM = ' || SQLERRM);
END;
/
/*
輸入數據有誤
SQLCODE = -20789
SQLERRM = ORA-20789: 輸入數字不能在10~100之間
*/


-- note:如果使用RAISE_APPLICATION_ERROR中的錯誤代碼與本身定義的異常錯誤
-- 代碼不相同，那麼就會出現語法錯誤。
-- ex:異常代碼不一致
DECLARE
 v_data NUMBER;
 v_myexp EXCEPTION; -- 定義一個異常變量
 PRAGMA EXCEPTION_INIT(v_myexp, -20689);
BEGIN
 v_data := &inputData; -- 輸入數據
 IF v_data > 10 AND v_data <100 THEN
  RAISE_APPLICATION_ERROR(-20789, 
  '輸入數字不能在10~100之間'); -- 拋出異常
 END IF;
EXCEPTION 
 WHEN v_myexp THEN -- 出現指定的異常
 DBMS_OUTPUT.put_line('輸入數據有誤');
 DBMS_OUTPUT.put_line('SQLCODE = ' || SQLCODE);
 DBMS_OUTPUT.put_line('SQLERRM = ' || SQLERRM);
END;
/
/*
錯誤報告:
ORA-20789: 輸入數字不能在10~100之間
ORA-06512: 在 line 8
*/


-- ex:沒有定義異常而拋出定義異常
DECLARE
 v_data NUMBER;
 v_myexp EXCEPTION; -- 定義一個異常變量
 --PRAGMA EXCEPTION_INIT(v_myexp, -20689);
BEGIN
 v_data := &inputData; -- 輸入數據
 IF v_data > 10 AND v_data <100 THEN
  RAISE_APPLICATION_ERROR(-20789, 
  '輸入數字不能在10~100之間'); -- 拋出異常
 END IF;
EXCEPTION 
 WHEN v_myexp THEN -- 出現指定的異常
 DBMS_OUTPUT.put_line('輸入數據有誤');
 DBMS_OUTPUT.put_line('SQLCODE = ' || SQLCODE);
 DBMS_OUTPUT.put_line('SQLERRM = ' || SQLERRM);
END;
/
/*
錯誤報告:
ORA-20789: 輸入數字不能在10~100之間
ORA-06512: 在 line 8
*/


-- 但事實上並不一定要如此複雜，觀察以上程序後，第一:需要設置錯誤代號，第二:
-- 要設置錯誤訊息，第三:要在EXCEPTION中使用指定異常對象。
-- 能否直接使用RAISE_APPLICATION_ERROR操作呢?別再設置具體的類型，直接使用
-- OTHERS。
DECLARE
 v_data NUMBER;
 --v_myexp EXCEPTION; -- 定義一個異常變量
 --PRAGMA EXCEPTION_INIT(v_myexp, -20689);
BEGIN
 v_data := &inputData; -- 輸入數據
 IF v_data > 10 AND v_data <100 THEN
  RAISE_APPLICATION_ERROR(-20789, 
  '輸入數字不能在10~100之間'); -- 拋出異常
 END IF;
EXCEPTION 
 --WHEN v_myexp THEN -- 出現指定的異常
 WHEN OTHERS THEN
 DBMS_OUTPUT.put_line('輸入數據有誤');
 DBMS_OUTPUT.put_line('SQLCODE = ' || SQLCODE);
 DBMS_OUTPUT.put_line('SQLERRM = ' || SQLERRM);
END;
/
/*
輸入數據有誤
SQLCODE = -20789
SQLERRM = ORA-20789: 輸入數字不能在10~100之間
*/


-- 那麼在開發之中，使用此類的形式是比較多的，因為很方便，但是此類方式還有一個
-- 問題，所有的異常都交給OTHERS一起處理了，不能分割，如果異常要求嚴格的話，那
-- 麼還是需要分割的。
-- ex:使用PL/SQL增加部門訊息。要增加部門訊息一定要輸入編號、名稱、位置等等，
-- 如果編號重複，那麼就不能進行增加。
DECLARE
 v_dno dept.deptno%TYPE;
 v_dna dept.dname%TYPE;
 v_dloc dept.loc%TYPE;
 v_department NUMBER; -- 保存COUNT()函數結果 
BEGIN
 v_dno := &inputDeptno;
 v_dna := '&inputDname';
 v_dloc := '&inputLoc';
-- 統計要增加的部門編號在dept表中的訊息，如果返回0表示沒有此部門
 SELECT COUNT(deptno) INTO v_department 
 FROM dept WHERE deptno=v_dno;
 IF v_department >0 THEN 
  RAISE_APPLICATION_ERROR(-20888, 
  '此部門編號已經存在,請重新輸入!');
 ELSE
  INSERT INTO dept (deptno,dname,loc) 
  VALUES (v_dno,v_dna,v_dloc);
  DBMS_OUTPUT.put_line('新部門增加成功!');
  COMMIT;
 END IF;
EXCEPTION
 WHEN OTHERS THEN 
 DBMS_OUTPUT.put_line('SQLCODE = ' || SQLCODE);
 DBMS_OUTPUT.put_line('SQLERRM = ' || SQLERRM);
 ROLLBACK;
END;
/
