ACCEPT inputEname PROMPT '請輸入要查詢訊息的員工姓名: '
SELECT empno, ename, job, hiredate, sal FROM emp 
WHERE ename=UPPER('&inputEname');