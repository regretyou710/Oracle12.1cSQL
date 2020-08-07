-- ※簡單查詢 --

-- 透過數據庫查詢出所有員工的編號、姓名和年基本工資、日基本工資，以作為年終獎金的發放標準。
SELECT EMPNO, ENAME, SAL*12 AS 年基本工資, SAL/30 AS 日基本工資 FROM EMP;

-- 現在公司每個雇員在年底的時候可以領取5000元的年終獎金，要求查詢員工編號、姓名、和增長後的年基本工資(不包括佣金)。
SELECT EMPNO, ENAME, SAL*12+5000 AS 年基本工資 FROM EMP;

-- 公司每個月為員工增加200元的補助金，此時，要求可以查詢出每個員工的編號、姓名、基本年工資。
SELECT EMPNO, ENAME, (SAL+200)*12+5000 AS 年基本工資, '$' AS 貨幣 FROM EMP;

-- ※使用 || 進行連接顯示
SELECT '編號是:' || EMPNO || '的員工, 姓名是:' || ENAME || ', 基本工資是:' || SAL AS 員工訊息 FROM EMP;


-- ※限定查詢 --
-- 子句優先順序 1.FROM 2.WHERE 3.SELECT
-- note:WHERE不能用SELECT別名，因為WHERE優於SELECT執行


-- 統計出基本工資高於1500的全部雇員訊息
SELECT * FROM EMP WHERE SAL>1500;


-- 要求查詢出所有基本工資小於等於2000的全部員工訊息
SELECT * FROM emp WHERE sal<=2000;


-- 根據之前的查詢結果發現SMITH的工資最低，所以現在希望可以取得SMITH的詳細資料
SELECT * FROM emp WHERE ename='SMITH';


-- 查詢出所有辦事員(CLERK)的員工訊息
SELECT * FROM emp WHERE job='CLERK';


-- 取得所有CLERK的資料後，為了和其他職位的員工對比，現在決定再查詢所有不是辦事員的員工訊息
SELECT * FROM emp WHERE job<>'CLERK';
SELECT * FROM emp WHERE job!='CLERK';


-- 查詢出工資範圍再1500~3000(包含1500和3000)的全部員工訊息
SELECT * FROM emp WHERE sal>=1500 AND sal<=3000;


-- 查詢職位是銷售人員，並且基本工資高於1200的所有員工訊息
SELECT * FROM emp WHERE job='SALESMAN' AND sal>1200;


-- 要求查詢出10部門中的經理或是20部門的業務員訊息
SELECT * FROM emp WHERE (deptno=10 AND job='MANAGER') OR (deptno=20 AND job='CLERK');


-- 查詢不是辦事員且基本工資大於2000的全部員工訊息
SELECT * FROM emp WHERE job!='CLERK' AND sal>2000;
SELECT * FROM emp WHERE NOT(job='CLERK' OR sal<=2000);


-- ※範圍查詢: BETWEEN 最小值 AND 最大值
-- 查詢出工資範圍再1500~3000(包含1500和3000)的全部員工訊息
SELECT * FROM emp WHERE sal BETWEEN 1500 AND 3000;


-- 查詢在1981年雇用的全部員工訊息
SELECT * FROM emp WHERE hiredate BETWEEN '31-1月 -81' AND '31-12月 -81';
SELECT * FROM emp WHERE hiredate BETWEEN '31-1月 -1981' AND '31-12月 -1981';


-- null是一個未知的數據
-- ※判斷內容是否為空(null): IS NULL、IS NOT NULL

-- 此時不會有任何結果返回，因為null不能使用等於來判斷
SELECT * FROM emp WHERE comm=null AND empno=7369;


-- 查詢所有領取佣金的員工完整訊息
SELECT * FROM emp WHERE comm IS NOT NUll;
SELECT * FROM emp WHERE NOT comm IS NUll;


-- 查詢所有不領取佣金的員工完整訊息
SELECT * FROM emp WHERE comm IS NULL;


-- 列出所有不領取獎金的員工，而且同時要求這些員工的基本工資大於2000的全部員工訊息
SELECT * FROM emp WHERE comm IS NULL AND sal>2000;


-- 找出不收取佣金或收取的佣金低於100的員工
SELECT * FROM emp WHERE comm IS NULL OR comm<100;
SELECT * FROM emp WHERE NOT (comm IS NOT NULL AND comm>=100);


-- 找出收取佣金的員工的不同工作
SELECT DISTINCT job FROM emp WHERE comm IS NOT NULL;


-- ※列表範圍查找:IN、NOT IN。須注意:使用NOT IN時不可判斷內容為null，會返回無資料的結果。
-- 查詢員工編號是7369、7788、7566的員工訊息
SELECT * FROM emp WHERE empno IN(7369,7788,7566);


-- 查詢員工編號是7369、7788、7566之外的員工訊息
SELECT * FROM emp WHERE empno NOT IN(7369,7788,7566);


-- ※模糊查詢:LIKE、NOT LIKE。須注意:若查詢內容不設置關鍵字，則返回查詢全部結果。
-- 查詢出員工姓名是以S開頭的全部員工訊息
SELECT * FROM emp WHERE ename LIKE 'S%';


-- 要求查詢員工姓名的第二個字母是'M'的全部員工訊息
SELECT * FROM emp WHERE ename LIKE '_M%';


-- 查詢出姓名中任意位置包含字母'F'的員工訊息
SELECT * FROM emp WHERE ename LIKE '%F%';


-- 查詢員工姓名長度為6或超過6的員工訊息
SELECT * FROM emp WHERE ename LIKE '______%';


-- 查詢出員工基本工資中包含1或者是在81年雇佣的全部員工訊息
SELECT * FROM emp WHERE sal LIKE '%1%' OR hiredate LIKE '%81%';


-- 找出部門10中所有經理(MANAGER)，部門20中所有辦事員(CLERK)，既不是經理又不是辦事員但是其餘工資大於或
-- 等於2000的所有員工詳細資料，並且要求這些員工姓名中包含有字母'S'或字母'K'。
SELECT * FROM emp 
WHERE ((deptno=10 AND job='MANAGER')
OR (deptno=20 AND job='CLERK')
OR ((job NOT IN('MANAGER','CLERK')) AND sal >=2000)) 
AND (ename LIKE '%S%' OR ename LIKE'%K%')
;