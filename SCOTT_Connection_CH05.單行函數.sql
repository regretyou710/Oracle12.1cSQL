--============================================================================--
--                                                                            --
/* ※單行函數-字串函數                                                        */
--                                                                            --
--============================================================================--
-- 在Oracle中所有的驗證操作必須存在在完整的SQL語句之中，所以如果現在只是進行
-- 功能驗證，使用的是一張具體的表，可利用dual虛擬表進行操作。
-- ➤UPPER():內容轉成大寫、LOWER():內容轉成小寫
SELECT UPPER('OracleDataBase'),LOWER('OracleDataBase') FROM dual;


-- ex:查詢員工姓名是'smith'的完整訊息，但是由於失誤，沒有考慮到數據的大小寫
-- 問題，此時可以使用UPPER()函數將全部內容轉為大寫。
SELECT * FROM emp WHERE ename=UPPER('smith');


-- ➤INITCAP():首字母以大寫方式呈現
-- ex:查詢所有員工的姓名，要求將每個員工的姓名以首字母大寫的形式出現
SELECT INITCAP(ename) FROM emp;


-- ➤REPLACE(欄位,被替換字元,替換字元):字元替換
-- ex:查詢所有員工的姓名，但是要求基員工姓名中的所有字母'A'替換成字母'_'
SELECT REPLACE(ename,'A','_') FROM emp;


-- ➤LENGTH():字串長度
-- ex:查詢出姓名長度是5的所有員工訊息
SELECT * FROM emp WHERE LENGTH(ename)=5;


-- ➤SUBSTR(欄位,起始索引值,結束索引值):範圍內字串
-- ➤SUBSTR(欄位,起始索引值):起始索引值到結尾內字串
-- note:Oracle數據庫中，下標都是從1開始，如果設置為0也會自動將其轉換為1。
-- ex:查詢員工姓名前三個字母是'JAM'的員工訊息
SELECT * FROM emp WHERE SUBSTR(ename,0,3)='JAM';


-- ex:查詢所有10部門員工的姓名，但不顯示每個員工姓名的前三個字母
SELECT ename befroe, substr(ename,4) after FROM emp WHERE deptno=10;


-- ex:顯示每個員工姓名及其姓名後三個字母
SELECT ename, substr(ename, LENGTH(ename)-2 )姓名後三個字母 FROM emp ;
SELECT ename, substr(ename, -3)姓名後三個字母 FROM emp ;


-- ➤ASCII():返回指定字元的ASCII CODE
SELECT ASCII('a'), ASCII('A') FROM dual ;


-- ➤CHR():將ASCII瑪轉回字元
SELECT CHR(97) ,CHR(65) FROM dual ;


-- ➤LTRIM():去掉字串左邊空格
SELECT LTRIM('  Oracle  DataBase  ') 去除左邊空格後字串
, LENGTH('  Oracle  DataBase  ') 原始字串長度
, LENGTH(LTRIM('  Oracle  DataBase  ')) 去除左邊空格後長度
FROM dual;


-- ➤RTRIM():去掉字串右邊空格
SELECT RTRIM('  Oracle  DataBase  ') 去除左邊空格後字串
, LENGTH('  Oracle  DataBase  ') 原始字串長度
, LENGTH(RTRIM('  Oracle  DataBase  ')) 去除左邊空格後長度
FROM dual;


-- ➤TRIM():去掉字串兩邊空格
SELECT TRIM('  Oracle DataBase  ') 去除左邊空格後字串
, LENGTH('  Oracle  DataBase  ') 原始字串長度
, LENGTH(TRIM('  Oracle  DataBase  ')) 去除左邊空格後長度
FROM dual;


-- ➤字串左邊填充:LPAD(被填充字串,填充後字串長度,填充字元)
-- ➤字串右邊填充:RPAD(被填充字串,填充後字串長度,填充字元)
SELECT LPAD('Oracle',10,'*') FROM dual;
SELECT RPAD('Oracle',10,'*') FROM dual;
-- ex:LPAD()、RPAD()組合使用
SELECT LPAD(RPAD('Oracle',10,'*'),14,'*') FROM dual;


-- ➤INSTR():字串查找:返回找到的第一個字元位置索引(Oracle SQL的索引由1開始)
-- 與JAVA中的indexOf()函數能相同
SELECT INSTR('Oracle JAVA','JAVA') 找得到,
INSTR('Oracle JAVA','Oracle') 找得到,
INSTR('Oracle JAVA','Java') 找不到
FROM dual;
--============================================================================--
--                                                                            --
/* ※單行函數-數值函數                                                        */
--                                                                            --
--============================================================================--
-- ➤ROUND():四捨五入
-- 1 2 3 4 5 6 . 7  8  9
-- 5 4 3 2 1 0  -1 -2 -3 
SELECT ROUND(123456.789) 不保留小數,
ROUND(12345.6789,2) 保留兩位小數,
ROUND(123456.789,-1) 處理整數進位
FROM dual;


-- ex:列出每個員工的一些基本訊息和日工資情況
SELECT empno, ename, job,hiredate, sal, ROUND(sal/30,2) FROM emp;


-- ➤TRUNC():不進位
SELECT TRUNC(789.652) 擷取小數,
TRUNC(789.652,2) 擷取兩位小數,
TRUNC(789.652,-2) 取整數
FROM dual;


-- ➤MOD():求餘數
SELECT MOD(10,3) FROM dual;
--============================================================================--
--                                                                            --
/* ※單行函數-日期函數                                                        */
--                                                                            --
--============================================================================--
-- SYSDATE:取得系統當前日期。默認情況下顯示內容只包含年、月、日，如果想顯示
-- 更多數據，那麼需修改語言環境。
-- ALTER SESSION SET NLS_DATE_FORMAT='yyyy-mm-dd hh24:mi:ss';
-- 重新連線後就恢復默認格式
ALTER SESSION SET NLS_DATE_FORMAT='yyyy-mm-dd hh24:mi:ss';
SELECT SYSDATE FROM dual;


-- 日期操作公式:
-- 日期 - 數字 = 日期
-- 日期 + 數字 = 日期
-- 日期 - 日期 = 數字
-- 不存在(日期 + 日期)的計算
SELECT SYSDATE+3 三天之後的日期,
SYSDATE-3 三天之前的日期
FROM dual;


-- ex:查詢出每個員工的到今天為止的雇用天數，以及十天前每個員工的雇用天數
-- 其中使用TRUNC()函數來捨棄小數點
SELECT ename,
empno,
TRUNC(SYSDATE-hiredate) 今天為止的雇用天數,
TRUNC((SYSDATE-10)-hiredate) 十天前的雇用天數
FROM emp;


-- ➤ADD_MONTHS():加上n個月或加上-n個月
SELECT ADD_MONTHS(SYSDATE,3),
ADD_MONTHS(SYSDATE,-3),
ADD_MONTHS(SYSDATE,60)
FROM dual;


-- ex:要求顯示所有員工被雇用三個月之後的日期
SELECT ename,empno, job, sal, hiredate, ADD_MONTHS(hiredate,3)FROM emp;


-- ➤NEXT_DAY():
SELECT SYSDATE, NEXT_DAY(SYSDATE,'星期三') 下一個星期三 FROM dual;


-- ➤LAST_DAY():指定日期所在月份的最後一天
SELECT SYSDATE, LAST_DAY(SYSDATE) FROM dual;


-- ex:查詢所有是在其雇用所在月的倒數第三天被公司雇用的完整員工訊息
SELECT ename, empno, job, hiredate, LAST_DAY(hiredate) 
FROM emp WHERE hiredate=LAST_DAY(hiredate)-3;


-- ➤MONTHS_BETWEEN():取得兩個日期之間所經歷過的月份間隔
-- ex:查詢出每個員工編號、姓名、雇用日期、雇用的月數及年份
SELECT empno, ename, hiredate,
TRUNC(MONTHS_BETWEEN(SYSDATE,hiredate)) 雇用總月數,
TRUNC(MONTHS_BETWEEN(SYSDATE,hiredate)/12) 雇用總年數
FROM emp;


-- ex:查詢出每個員工的編號、姓名、雇用日期、已雇用的年數、月數、天數
-- note:在MONTHS_BETWEEN(SYSDATE,hiredate)/12計算後的小數指的是不滿一年的月數
SELECT empno, ename, hiredate,
TRUNC(MONTHS_BETWEEN(SYSDATE,hiredate)/12) || '年' ||
TRUNC(MOD(MONTHS_BETWEEN(SYSDATE,hiredate),12)) || '個月' ||
TRUNC(SYSDATE-
ADD_MONTHS(hiredate,MONTHS_BETWEEN(SYSDATE,hiredate))) || '天' 已雇用的時間
FROM emp;


-- ➤EXTRACT()
-- 從日期時間中取得年、月、日數據
SELECT 
EXTRACT(YEAR FROM SYSDATE) 年,
EXTRACT(MONTH FROM SYSDATE) 月,
EXTRACT(DAY FROM SYSDATE) 日 
FROM dual;

SELECT 
EXTRACT(YEAR FROM SYSTIMESTAMP) 年,
EXTRACT(MONTH FROM SYSTIMESTAMP) 月,
EXTRACT(DAY FROM SYSTIMESTAMP) 日,
EXTRACT(HOUR FROM SYSTIMESTAMP) 時,
EXTRACT(MINUTE FROM SYSTIMESTAMP) 分,
EXTRACT(SECOND FROM SYSTIMESTAMP) 秒
FROM dual;

-- 自訂日期
SELECT 
EXTRACT(YEAR FROM DATE '1970-06-30') 年,
EXTRACT(MONTH FROM DATE '1970-06-30') 月,
EXTRACT(DAY FROM DATE '1970-06-30') 日 
FROM dual;


-- ➤TO_TIMESTAMP():字串轉換日期格式。時間戳
SELECT TO_TIMESTAMP('1970-06-30 02:12:14','yyyy-mm-dd hh24:mi:ss') FROM dual;

SELECT 
EXTRACT(DAY FROM TO_TIMESTAMP('1980-06-30 02:12:14','yyyy-mm-dd hh24:mi:ss') -
TO_TIMESTAMP('1974-02-02 06:03:12','yyyy-mm-dd hh24:mi:ss')) DAYS 
FROM dual;
--============================================================================--
--                                                                            --
/* ※單行函數-轉換函數                                                        */
--                                                                            --
--============================================================================--
-- ➤TO_CHAR(日期數據,轉換格式):將數據類型轉換成字串
SELECT SYSDATE, TO_CHAR(SYSDATE,'YYYY-MM-DD'),
TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS'),
TO_CHAR(SYSDATE,'FMYYYY-MM-DD HH24:MI:SS') 去掉查詢後前導0 
FROM dual;


-- ex:查詢出所有在每年2月份雇用的員工訊息
SELECT * FROM emp WHERE TO_CHAR(hiredate,'MM')='02';
SELECT * FROM emp WHERE TO_CHAR(hiredate,'MM')=2;


-- ex:將每個員工的雇用期進行格式化顯示，要求所的雇用日期可以按照"年-月-日"的
-- 形式也可以將雇用的年、月、日拆開分別顯示。
SELECT empno, ename, hiredate,
TO_CHAR(hiredate,'YYYY-MM-DD') 格式化雇用時間,
TO_CHAR(hiredate,'YYYY') 格式化雇用年,
TO_CHAR(hiredate,'MM') 格式化雇用月,
TO_CHAR(hiredate,'DD') 格式化雇用日
FROM emp;


-- 另一種格式化時間
SELECT empno, ename, hiredate,
TO_CHAR(hiredate,'YEAR-MONTH-DY') 格式化雇用時間
FROM emp;


-- ➤TO_CHAR()對數字的格式化
SELECT TO_CHAR(987654321.123,'999,999,999,999,999.99999'),
TO_CHAR(987654321.123,'000,000,000,000,000.00000')
FROM dual;

SELECT TO_CHAR(987654321.123,'L999,999,999,999,999.99999') 顯示貨幣,
TO_CHAR(987654321.123,'$000,000,000,000,000.00000') 顯示美元
FROM dual;


-- ➤TO_DATE():將字串轉成日期數據類型
SELECT TO_DATE('1970-06-03','YYYY-MM-DD')
FROM dual;


-- ➤TO_NUMBER():將字串轉成數字
SELECT TO_NUMBER('09')+TO_NUMBER('19') 加法操作,
TO_NUMBER('09') * TO_NUMBER('19') 乘法操作
FROM dual;
-- Oracle支持自動轉型
SELECT '09' + '19' 加法操作,
'09' * '19' 乘法操作
FROM dual;
--============================================================================--
--                                                                            --
/* ※單行函數-通用函數                                                        */
--                                                                            --
--============================================================================--
-- ➤NVL(目標值,若為空要顯示的值):使用NVL()函數處理null
-- 要求查詢出每個員工的編號、姓名、職位、雇用日期、年薪
SELECT ename, empno, job, hiredate, (sal+NVL(comm,0))*12 年薪, sal, comm FROM emp;


-- ➤NVL2()
SELECT 
ename, 
empno, 
job, 
hiredate, 
NVL2(comm,(sal+comm),sal)*12 年薪, 
sal, 
comm FROM emp
;


-- ➤NULLIF():判斷兩個表達式的結果是否相等，相等返回null，不相等返回表達式一
-- ex1:
SELECT  NULLIF(1,1), NULLIF(1,2) FROM dual;
-- ex2:
SELECT  empno, ename, job, LENGTH(ename), LENGTH(job),
NULLIF(LENGTH(ename),LENGTH(job)) NULLIF 
FROM emp;


-- ➤DECODE(列|表達式,值1,輸出結果,值2,輸出結果,...,默認值):
-- 類似於if...else，但是判斷的內容都是一個具體的值
SELECT  DECODE(2,1,'內容為一',2,'內容為二'),
DECODE(2,1,'內容為一','沒有滿足條件')
FROM dual;


-- ex:要求可以查詢員工的姓名、職位、基本工資等訊息，但是要求將所有的職位訊息
-- 都替換成中文顯示
SELECT  
ename, sal, 
DECODE(job,'CLERK','業務員' ,
'SALESMAN','銷售員',
'MANAGER','經理',
'ANALYST','分析員',
'PRESIDENT','總裁') job 
FROM emp;


-- ➤CASE
-- CASE [expr]
--    WHEN  comp_expr  THEN  return_expr
--    [WHEN comp_expr THEN return_expr]
--    [ELSE   else_expr]
-- END; 

-- ex:顯示每個員工的姓名、工資、職位，同事顯示新的工資(新工資的標準為:辦事員
-- 增長10%、銷售員增長20%、經理增長30%、其他職位的人增長50$)
SELECT  
ename, sal, 
CASE job WHEN 'CLERK' THEN sal * 1.1
  WHEN 'SALSEMAN' THEN sal * 1.2
  WHEN 'MANAGER' THEN sal * 1.3
ELSE sal * 1.5
END 新工資 
FROM emp;


-- ➤COALESCE(表達式1,表達式2,表達式3,...表達式n):對null進行操作，採用依次判斷
-- 表達式的方式完成，如果表達式1為null，則顯示表達式2的內容，如果表達式2為null
-- ，則顯示表達式3的內容，依次類推，判斷到最後如果還是null，則最終的顯示結果
-- 就是null。
SELECT ename, sal, comm,
COALESCE(comm,100,2000),
COALESCE(comm,null,2000),
COALESCE(comm,null,null)
FROM emp;