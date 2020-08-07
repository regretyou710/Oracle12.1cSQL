-- ※單行函數-字串函數

-- 在Oracle中所有的驗證操作必須存在在完整的SQL語句之中，所以如果現在只是進行功能驗證，
-- 使用的是一張具體的表，可利用dual虛擬表進行操作。
-- UPPER():內容轉成大寫、LOWER():內容轉成小寫
SELECT UPPER('OracleDataBase'),LOWER('OracleDataBase') FROM dual;


-- 查詢員工姓名是'smith'的完整訊息，但是由於失誤，沒有考慮到數據的大小寫問題，此時可以
-- 使用UPPER()函數將全部內容轉為大寫。
SELECT * FROM emp WHERE ename=UPPER('smith');


-- INITCAP():首字母以大寫方式呈現
-- 查詢所有員工的姓名，要求將每個員工的姓名以首字母大寫的形式出現
SELECT INITCAP(ename) FROM emp;


-- REPLACE(欄位,被替換字元,替換字元):字元替換
-- 查詢所有員工的姓名，但是要求基員工姓名中的所有字母'A'替換成字母'_'
SELECT REPLACE(ename,'A','_') FROM emp;


-- LENGTH():字串長度
-- 查詢出姓名長度是5的所有員工訊息
SELECT * FROM emp WHERE LENGTH(ename)=5;


-- SUBSTR(欄位,起始索引值,結束索引值):範圍內字串
-- SUBSTR(欄位,起始索引值):起始索引值到結尾內字串
-- 查詢員工姓名前三個字母是'JAM'的員工訊息
SELECT * FROM emp WHERE SUBSTR(ename,0,3)='JAM';


-- 查詢所有10部門員工的姓名，但不顯示每個員工姓名的前三個字母
SELECT ename befroe, substr(ename,4) after FROM emp WHERE deptno=10;


-- 顯示每個員工姓名及其姓名後三個字母
SELECT ename, substr(ename, LENGTH(ename)-2 )姓名後三個字母 FROM emp ;
SELECT ename, substr(ename, -3)姓名後三個字母 FROM emp ;


-- 返回指定字元的ASCII CODE
SELECT ASCII('a'), ASCII('A') FROM dual ;


-- 驗證CHR()函數，將ASCII瑪轉回字元
SELECT CHR(97) ,CHR(65) FROM dual ;


-- LTRIM():去掉字串左邊空格
SELECT LTRIM('  Oracle  DataBase  ') 去除左邊空格後字串
, LENGTH('  Oracle  DataBase  ') 原始字串長度
, LENGTH(LTRIM('  Oracle  DataBase  ')) 去除左邊空格後長度
FROM dual;


--  RTRIM():去掉字串右邊空格
SELECT RTRIM('  Oracle  DataBase  ') 去除左邊空格後字串
, LENGTH('  Oracle  DataBase  ') 原始字串長度
, LENGTH(RTRIM('  Oracle  DataBase  ')) 去除左邊空格後長度
FROM dual;


-- TRIM():去掉字串兩邊空格
SELECT TRIM('  Oracle DataBase  ') 去除左邊空格後字串
, LENGTH('  Oracle  DataBase  ') 原始字串長度
, LENGTH(TRIM('  Oracle  DataBase  ')) 去除左邊空格後長度
FROM dual;


-- 字串左邊填充:LPAD(被填充字串,填充後字串長度,填充字元)
-- 字串右邊填充:RPAD(被填充字串,填充後字串長度,填充字元)
SELECT LPAD('Oracle',10,'*') FROM dual;
SELECT RPAD('Oracle',10,'*') FROM dual;


-- LPAD()、RPAD()組合使用
SELECT LPAD(RPAD('Oracle',10,'*'),14,'*') FROM dual;


-- INSTR():字串查找:返回找到的第一個字元位置索引(Oracle SQL的索引由1開始)
-- 與JAVA中的indexOf()函數能相同
SELECT INSTR('Oracle JAVA','JAVA') 找得到,
INSTR('Oracle JAVA','Oracle') 找得到,
INSTR('Oracle JAVA','Java') 找不到
FROM dual;


-- ※單行函數-數值函數

-- ROUND():四捨五入
-- 1 2 3 4 5 6 . 7  8  9
-- 5 4 3 2 1 0  -1 -2 -3 
SELECT ROUND(123456.789) 不保留小數,
ROUND(12345.6789,2) 保留兩位小數,
ROUND(123456.789,-1) 處理整數進位
FROM dual;


-- 列出每個員工的一些基本訊息和日工資情況
SELECT empno, ename, job,hiredate, sal, ROUND(sal/30,2) FROM emp;


-- TRUNC():不進位
SELECT TRUNC(789.652) 擷取小數,
TRUNC(789.652,2) 擷取兩位小數,
TRUNC(789.652,-2) 取整數
FROM dual;


-- MOD():求餘數
SELECT MOD(10,3) FROM dual;


-- ※單行函數-日期函數

-- SYSDATE:取得系統當前日期。默認情況下顯示內容只包含年、月、日，如果想顯示更多數據，那麼
-- 需修改語言環境。ALTER SESSION SET NLS_DATE_FORMAT='yyyy-mm-dd hh24:mi:ss';
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


-- 查詢出每個員工的到今天為止的雇用天數，以及十天前每個員工的雇用天數
-- 其中使用TRUNC()函數來捨棄小數點
SELECT ename,
empno,
TRUNC(SYSDATE-hiredate) 今天為止的雇用天數,
TRUNC((SYSDATE-10)-hiredate) 十天前的雇用天數
FROM emp;


-- ADD_MONTHS():加上n個月或加上-n個月
SELECT ADD_MONTHS(SYSDATE,3),
ADD_MONTHS(SYSDATE,-3),
ADD_MONTHS(SYSDATE,60)
FROM dual;


-- 要求顯示所有員工被雇用三個月之後的日期
SELECT ename,empno, job, sal, hiredate, ADD_MONTHS(hiredate,3)FROM emp;


-- NEXT_DAY():
SELECT SYSDATE, NEXT_DAY(SYSDATE,'星期三') 下一個星期三 FROM dual;


-- LAST_DAY():指定日期所在月份的最後一天
SELECT SYSDATE, LAST_DAY(SYSDATE) FROM dual;


-- 查詢所有是在其雇用所在月的倒數第三天被公司雇用的完整員工訊息
SELECT ename, empno, job, hiredate, LAST_DAY(hiredate) 
FROM emp WHERE hiredate=LAST_DAY(hiredate)-3;


-- MONTHS_BETWEEN():取的兩個日期之間所經歷過的月份間格
-- 查詢出每個員工編號、姓名、雇用日期、雇用的月數及年份
SELECT empno, ename, hiredate,
TRUNC(MONTHS_BETWEEN(SYSDATE,hiredate)) 雇用總月數,
TRUNC(MONTHS_BETWEEN(SYSDATE,hiredate)/12) 雇用總年數
FROM emp;


-- 查詢出每個員工的編號、姓名、雇用日期、已雇用的年數、月數、天數
-- 在MONTHS_BETWEEN(SYSDATE,hiredate)/12計算後的小數指的是不滿一年的月數
SELECT empno, ename, hiredate,
TRUNC(MONTHS_BETWEEN(SYSDATE,hiredate)/12) || '年' ||
TRUNC(MOD(MONTHS_BETWEEN(SYSDATE,hiredate),12)) || '個月' ||
TRUNC(SYSDATE-ADD_MONTHS(hiredate,MONTHS_BETWEEN(SYSDATE,hiredate))) || '天' 已雇用的時間
FROM emp;


-- EXTRACT()
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


-- TO_TIMESTAMP():字串轉換日期格式
SELECT TO_TIMESTAMP('1970-06-30 02:12:14','yyyy-mm-dd hh24:mi:ss') FROM dual;

SELECT 
EXTRACT(DAY FROM TO_TIMESTAMP('1980-06-30 02:12:14','yyyy-mm-dd hh24:mi:ss') -
TO_TIMESTAMP('1974-02-02 06:03:12','yyyy-mm-dd hh24:mi:ss')) DAYS 
FROM dual;


-- 