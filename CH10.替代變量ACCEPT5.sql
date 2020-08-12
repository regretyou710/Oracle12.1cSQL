ACCEPT inputDate DATE FORMAT 'YYYY-MM-DD' PROMPT '請輸入要查詢的雇用日期: ' 
SELECT empno, ename, job, hiredate 
FROM emp  
WHERE hiredate=TO_DATE('&inputDate','YYYY-MM-DD');