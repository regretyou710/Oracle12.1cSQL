-- ※多表查詢-內連接

-- 消除笛卡爾積
SELECT * FROM emp, dept WHERE emp.deptno=dept.deptno;


-- 查詢pdborcl sh用戶中的sales表、costs表
SELECT COUNT(*) FROM sh.sales;
SELECT COUNT(*) FROM sh.costs;
SELECT COUNT(*) FROM sh.sales,sh.costs;


-- 查詢出每個員工的編號、姓名、雇用日期、基本工資、工資等級
SELECT e.empno, e.ename, e.hiredate, e.sal, s.grade 
FROM emp e, salgrade s WHERE e.sal BETWEEN s.losal AND s.hisal;


-- 為了更加清楚地顯示出工資等級訊息，現在希望可以按下格式進行替換顯示:
-- grade=1: 顯示為"E等工資"
-- grade=2: 顯示為"D等工資"
-- grade=3: 顯示為"C等工資"
-- grade=4: 顯示為"B等工資"
-- grade=5: 顯示為"A等工資"
SELECT e.empno, e.ename, e.hiredate, e.sal,
DECODE(s.grade,'1','E等工資',
      '2','D等工資', 
      '3','C等工資', 
      '4','B等工資', 
      '5','A等工資') salgrade
FROM emp e, salgrade s WHERE e.sal BETWEEN s.losal AND s.hisal;


-- 查詢出每個員工姓名、職位、基本工資、部門名稱、工資所在公司的員工等級
-- 分析:
-- 1.確定所需要的資料表:
--    emp表:每個員工的姓名、職位、基本工資
--    dept表:部門名稱
--    salgrade表:工資等級
-- 2.確定已知的關聯欄位:
--    員工和部門:emp.deptno=dept.deptno
--    員工和工資等級:emp.sal BETWEEN salgrade.losal AND salgrade.hisal
-- 如果現在是多個消除笛卡爾積的條件，那麼往往使用AND將這些條件連接在一起。
-- 只要增加一張表，那麼就一定需要一個可以消除增加表所帶來笛卡爾積的問題。


SELECT e.empno, e.ename, e.job, e.sal, d.dname, 
DECODE(s.grade,'1','E等工資',
      '2','D等工資', 
      '3','C等工資', 
      '4','B等工資', 
      '5','A等工資') salgrade 
FROM emp e, dept d, salgrade s 
WHERE e.deptno=d.deptno AND e.sal BETWEEN s.losal AND s.hisal;


-- ※多表查詢-外連接
-- 增加一筆沒有部門編號的員工姓名為張三豐的紀錄，然後後進行多表關聯查詢
-- 查詢結果出現兩個問題:
-- 1.沒有部門的員工沒有顯示
-- 2.有一個40部門沒有顯示
-- 此時可以發現，使用內連接只有滿足連接條件的數據才會全部顯示。
-- 可是如果現在希望emp或dept表中的數據顯示完整，那麼就可以利用外連接進行，而現在外連接主要
-- 使用兩種:左外連接、右外連接。
-- 左外連接:左關係屬性=右關係屬性(+)，放在等號的右邊，表示左連接
-- 右外連接:左關係屬性(+)=右關係屬性，放在等號的左邊，表示右連接
SELECT * FROM emp e, dept d WHERE e.deptno=d.deptno;


-- 使用左外連接，顯示員工是8888的訊息
SELECT * FROM emp e, dept d WHERE e.deptno=d.deptno(+);


-- 使用右外連接，顯示部門是40的訊息
-- 分析:因為40部門沒有員工，所以所有的員工訊息就都是null
SELECT * FROM emp e, dept d WHERE e.deptno(+)=d.deptno;

-- 使用外連接的環境:如果所需要的數據訊息沒有顯示出來，那麼就使用外連接，而具體是左外連接還
-- 是右外連接，透過測試後結果進行判斷即可。


-- ※多表查詢-自身關聯
-- 查詢出員工對應的主管訊息
-- 分析:確定所要的資料表
-- emp表:員工的編號、姓名
-- emp表:主管的編號、姓名
-- 確定已知的關聯欄位:
-- 員工和主管:e.mgr=m.empno(員工的主管編號=主管訊息)
-- 在emp表中的king這個員工是沒有主管的，這個時候就必須考慮外連接
SELECT e.empno eempno, e.ename eename, 
m.empno mempno ,m.ename mename 
FROM emp e, emp m WHERE e.mgr=m.empno(+);


-- 查詢在1981年雇用的全部員工的編號、姓名、雇用日期(按照年-月-日顯示)、工作、主管姓名、
-- 員工月薪資、員工年薪資(基本工資+獎金)、員工工資等級、部門編號、部門名稱、部門位置，
-- 並且要求這些員工的月基本工資在1500~3500之間，將最後的結果按照年工資的降序排列，如果
-- 年工資相等，則按照工作進行排序
-- 分析:
-- 確定所需要的資料表:
-- emp表:編號、姓名、雇用日期、工作、月薪資、計算年薪資
-- emp表:主管名稱
-- dept表:部門編號、名稱、位置
-- salgrade表:工資等級
-- 確定已知關聯欄位:
-- 員工和主管:emp.mgr=memp.empno
-- 員工和部門:emp.deptno=dept.deptno
-- 員工和薪資等級:emp.sal BETWEEN salgreade.losal AND salgrade.hisal


SELECT 
e.empno 員工編號, e.ename 員工姓名, TO_CHAR(e.hiredate,'YYYY-MM-DD') 雇用日期, 
e.job 工作, m.ename 主管姓名, 
e.sal 月薪資, NVL2(e.comm,(e.sal+e.comm),e.sal)*12 年薪資, 
DECODE(s.grade,'1','E等工資',
      '2','D等工資', 
      '3','C等工資', 
      '4','B等工資', 
      '5','A等工資') 工資等級, 
d.deptno 部門編號, d.dname 部門名稱, d.loc 部門位置 
FROM emp e, emp m, salgrade s,dept d 
WHERE TO_CHAR(e.hiredate,'YYYY')='1981' 
AND e.mgr=m.empno(+) 
AND e.sal BETWEEN s.losal AND s.hisal 
AND e.deptno=d.deptno 
AND e.sal BETWEEN 1500 AND 3500 
ORDER BY 年薪資 DESC, e.job
;


-- ※多表查詢-SQL1999語法
SELECT FROM emp, dept WHERE;


-- 交查連接:主要功能就是產生笛卡爾積
-- 一般而言，在進行多表連接的時候都一定會存在關聯欄位以消除笛卡爾積，而關聯欄位的名稱一般
-- 都會一樣，如果不一樣也會有部分相同。
SELECT * FROM emp CROSS JOIN dept;


-- 自然連接:消除笛卡爾積
-- 使用自然連接會將連接的欄位放在第一行顯示，而這種方式就是一種內連接
SELECT * FROM emp NATURAL JOIN dept;


-- USING子句:設置連接欄位。透過自然連接可以直接使用關聯欄位消除笛可爾積，那如果現在的兩
-- 張表中沒有存在這種關聯欄位的話，就可以透過USING子句完稱笛卡爾積的消除。
SELECT * FROM emp JOIN dept USING(deptno);


-- ON子句:設置連接條件。
SELECT * FROM emp e JOIN salgrade s ON(e.sal BETWEEN s.losal AND s.hisal);


-- RIGHT OUTER:右外連接
SELECT * FROM emp e RIGHT OUTER JOIN dept d ON (e.deptno=d.deptno);


-- LEFT OUTER:左外連接
SELECT * FROM emp e LEFT OUTER JOIN dept d ON (e.deptno=d.deptno);


-- FULL OUTER:全外連接，只能透過SQL1999語法實現
SELECT * FROM emp e FULL OUTER JOIN dept d ON (e.deptno=d.deptno);


-- ※多表查詢-數據的集合運算。數據的集合指的是查詢結果的操作
-- 須注意:集合操作時，各個查詢語句返回的結構要求一致
-- UNION(並集):返回若干個查詢結果的全部內容，但是重複資料不顯示
-- UNION ALL(並集):返回若干個查詢結果的全部內容，重複資料也會顯示
-- MINUS(差集):返回若干個查詢結果中的不同部分
-- INTERSECT(交集):返回若干個查詢結果中相同的部分

-- UNION操作:將多個查詢結果連接到一起
-- 第一個查詢已經包含第二個查詢的內容，所以重複數據不顯示
SELECT * FROM dept
UNION 
SELECT * FROM dept WHERE deptno=10;


-- UNION ALL操作
SELECT * FROM dept
UNION ALL
SELECT * FROM dept WHERE deptno=10;


-- 在進行查詢操作過程中，建議盡量使用UNION或UNION ALL來替代OR
SELECT * FROM emp WHERE job='SALESMAN' OR job='CLERK';
SELECT * FROM emp WHERE job IN('SALESMAN', 'CLERK');
-- 兩個單表的查詢，效能相對較高
SELECT * FROM emp WHERE job='SALESMAN'
UNION 
SELECT * FROM emp WHERE job='CLERK';


-- MINUS操作
SELECT * FROM dept
MINUS 
SELECT * FROM dept WHERE deptno=10;


-- INTERSECT操作
SELECT * FROM dept
INTERSECT
SELECT * FROM dept WHERE deptno=10;
