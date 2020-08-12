ACCEPT inputGroupByColume PROMPT '請輸入要分組的欄位: ' FORMAT A10
SELECT &&inputGroupByColume, SUM(sal), AVG(sal) FROM emp  
GROUP BY &inputGroupByColume ;