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

-- 
SELECT FROM ;