--============================================================================--
--                                                                            --
/* ※更新及事務處理-更新操作前的準備                                              */
--                                                                            --
--============================================================================--
-- ➤複製表
-- ex:複製emp表，新的表明稱為myemp。複製的表不存在約束條件。
DROP TABLE myemp;
CREATE TABLE myemp AS SELECT * FROM emp;
SELECT * FROM tab;
SELECT * FROM myemp;
DESC myemp;
--============================================================================--
--                                                                            --
/* ※更新及事務處理-數據的增加操作                                                */
--                                                                            --
--============================================================================--
-- 對於數據庫插入數據時有兩種形式:
-- ①插入一條新的數據
-- ②插入子查詢的返回結果

-- ex:向myemp數據表之中增加一條新的數據
-- 推薦:使用完整語法進行數據增加時需要寫上要增加數據的欄位名稱
INSERT INTO myemp (empno, job, hiredate, ename, mgr, sal, comm, deptno) 
VALUES (8888, 'CLERK', SYSDATE, '張三豐', 7369, 800, 100, 20);
-- 不推薦:使用簡化語法增加數據時需要按照橫列順序增加，否則將出現錯誤
INSERT INTO myemp  
VALUES (8899, 'CLERK', TO_DATE(SYSDATE, 'YYYY-MM-DD')
, '張三豐', 7369, 1000, 100, 20);

INSERT INTO myemp 
VALUES (8899, '張無忌', 'MANAGER', 
7369, TO_DATE('1981-09-19', 'YYYY-MM-DD'), 1000, 100, 20);


-- ex:增加部份數據，有些數據設置為null
-- 如果沒有增加數據的部分，那麼自動使用null進行表示。
-- 完整語法:
INSERT INTO myemp (empno, ename, job, hiredate, sal) 
VALUES (6612, '周芷若', 'CLERK', TO_DATE('1889-09-19', 'YYYY-MM-DD'), 600);
-- 簡單語法:
INSERT INTO myemp  
VALUES (6616, '周芷若', 'CLERK', null, TO_DATE('1889-09-19', 'YYYY-MM-DD'), 
600, null, null);

SELECT * FROM myemp WHERE empno IN(6612,6616);


-- ex:透過子查詢增加myemp表數據
-- 說明:要與增加的子查詢表結構相同
-- 完整語法:
INSERT INTO myemp (empno, ename, job, mgr, hiredate, sal, comm, deptno) 
SELECT * FROM emp WHERE deptno=20;
-- 簡單語法:
INSERT INTO myemp SELECT * FROM emp WHERE deptno=10;

SELECT * FROM myemp;
--============================================================================--
--                                                                            --
/* ※更新及事務處理-數據的更新操作                                                */
--                                                                            --
--============================================================================--
-- 在數據庫修改時有兩種形式:
-- ①由用戶自己指定要更新的數據內容
-- ②基於子查詢的更新

-- ex:將SMITH(員工編號為7369)的工資修改為3000元，並且每個月有500元的獎金
UPDATE myemp SET sal=3000, comm=500 WHERE empno=7369;
SELECT * FROM myemp WHERE empno=7369;


-- ex:將工資低於公司的平均工資的員工的基本工資上漲20%
SELECT AVG(sal) FROM myemp;
UPDATE myemp SET sal=sal*1.2 WHERE sal<(SELECT AVG(sal) FROM myemp);
SELECT * FROM myemp;
-- 如果此時在更新的時候沒有寫出更新條件，表示的就是更新全部數據。
UPDATE myemp SET sal=0;
-- 如果真的執行了這樣的操作，假設現在數據表中有500萬條紀錄，那麼如果按照每一條更新的時間
-- 為0.01s，那麼這500萬條紀錄總體的更新時間是50000，5萬秒=13小時，那麼就意味著這13個小時
-- 之內，所有的數據都無法被其他用戶修改，所以這種更新全部的操作是不可能出現的。
-- 但現實工作中出現了此類問題並非沒有辦法解決，對於軟件問題的解決，實際上就只有兩句話:
-- 時間換空間、空間換時間。

ROLLBACK;
-- ex:將員工7369的職位、基本工資、雇用日期更新為與7839相同的訊息
-- SELECT job, sal, hiredate FROM myemp WHERE empno IN(7839);
UPDATE myemp SET (job, sal, hiredate)=
(SELECT job, sal, hiredate FROM myemp WHERE empno IN(7839)) 
WHERE empno=7369;

SELECT * FROM myemp;