--============================================================================--
--                                                                            --
/* ※更新及事務處理-更新操作前的準備                                          */
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
/* ※更新及事務處理-數據的增加操作                                            */
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
/* ※更新及事務處理-數據的更新操作                                            */
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
--============================================================================--
--                                                                            --
/* ※更新及事務處理-數據的刪除操作                                            */
--                                                                            --
--============================================================================--
-- 簡述:在刪除數據時如果沒有指定刪除條件，那麼就表示刪除全部數據，而對於刪除條件
-- ，用戶也可以直接編寫子查詢完成。

-- ex:刪除員工編號是7566的員工訊息
DELETE FROM myemp WHERE empno=7566;
SELECT * FROM myemp;


-- ex:刪除30部門內的所有員工
DELETE FROM myemp WHERE deptno=30;
SELECT * FROM myemp;

-- ex:刪除員工編號為7369、7566、7788的員工訊息
DELETE FROM myemp WHERE empno IN(7369,7566,7788);
SELECT * FROM myemp;

-- ex:刪除公司工資最高的員工
DELETE FROM myemp WHERE sal=(SELECT MAX(sal) FROM myemp);
SELECT * FROM myemp;


-- ex:刪除所有在1987年僱用的員工
DELETE FROM myemp WHERE TO_CHAR(hiredate,'YYYY')=1981;
SELECT * FROM myemp;

/*
-- ▲note:
對於更新的三個操作:增加、修改、刪除，每一次都一定會返回當前操作所影響到的數據行數
，在JAVA的JDBC操作中更新數據的操作Statement和PreparedStatement兩個介面，調用的
方法是executeUpdate()，返回的是一個int行數據，就是接收更新的行數。如果沒有數據被
更新，一定返回的是0行。
*/
--============================================================================--
--                                                                            --
/* ※更新及事務處理-事務處理                                                  */
--                                                                            --
--============================================================================--
-- 說明:事務處理在數據庫開發中有著非常重要的作用，所謂的事務核心概念就是指一個
-- SESSION所進行的所有更新操作要不一起成功，要不一起失敗，事務本身具有:
-- ①原子性(Atomicity)
-- ②一致性(Consistency)
-- ③隔離性或獨立性(Isolation)
-- ④持久性(Durabilily)
-- 四個特徵，以上的四個特徵也被稱為ACID特徵。

-- ➤SESSION:指的是會話，每一個連接到服務器上的用戶都透過SESSION表示，服務器依靠
-- SESSION來區分不同的用戶，所以在所有的開發中，會話都表示用戶。

-- ➤Oracle中事務操作命令
-- note:在默認情況下，所有的事務都不屬於自動提交，必須由用戶自己手動提交。
-- SET AUTOCOMMIT=OFF:取消掉自動提交處理，開始事務處理。
-- SET AUTOCOMMIT=ON:打開自動提交處理，關閉事務處理。
-- COMMIT:提交事務。
-- ROLLBACK TO [回滾點]:回滾操作。
-- SAVEPOINT 事務保存點名稱:設置事務保存點。

/*
所有的命令，每一個SESSION全都具備。為了更好的觀察出事務的特點，所以下面會使用多個
sqlplus窗口進行功能的展示。
*/
conn c##scott/tiger;
set linesize 300;
set pagesiz 30;
SELECT * FROM myemp;
-- 此時myemp一共存在14行的數據。

-- ex:將第一個SESSION執行數據的刪除操作，刪除超過年雇用的員工
DELETE FROM myemp WHERE MONTHS_BETWEEN(SYSDATE,hiredate)/12>40;
-- ex:打開第二個SESSION窗口，執行查詢操作，此時會發現數據應該被刪除了，但是查詢後還在。
conn c##scott/tiger;
set linesize 300;
set pagesiz 30;
SELECT * FROM myemp;


-- ➤更新緩衝
-- 說明:對於每一個SESSION而言，每一個數據庫的更新操作在事務沒有被提交之前都只是暫時
-- 保存在了一段緩衝區之中，並不會真正的向數據庫中發出命令，如果現在用戶發現操作有問
-- 題了，則可以進行事務的回滾。

-- ex:如果覺得刪除有錯誤，那麼在第一個SESSION中使用ROLLBACK
ROLLBACK;


-- ex:操作第一個SESSION執行刪除語句後進行提交動作
DELETE FROM myemp WHERE MONTHS_BETWEEN(SYSDATE,hiredate)/12>40;
COMMIT;


-- ex:操作第二個SESSION查詢myemp表的全部數據
SELECT * FROM myemp;


-- ➤回滾存儲點
-- 說明:在默認情況下，執行ROLLBACK命令意味著全部的操作都要回滾，如果現在希望可以回滾到
-- 指定操作的話，則可以採用SVAEPOINT設置一些保存點，這樣在回滾的時候就可以透過ROLLBACK
-- 返回指定的保存點上。
-- note:在沒有執行COMMIT指令前，卻執行了ROLLBACK回滾操作，那麼會回到原點上。所以為了操
-- 作方便，提供了保存點。


-- ex:在第一個SESSION窗口，執行一系列操作，觀察存儲點
INSERT INTO myemp (empno,ename,hiredate,job,sal) 
VALUES (1234,'張三豐',SYSDATE,'CLERK',800);
UPDATE myemp SET sal=5000 WHERE empno=1234;
SAVEPOINT sp_a;
INSERT INTO myemp (empno,ename,hiredate,job,sal) 
VALUES (5678,'謝遜',SYSDATE,'MANAGER',2000);
UPDATE myemp SET job='總監' WHERE empno=5678;
SAVEPOINT sp_b;
DELETE FROM myemp;
-- 當前的myemp表中是沒有紀錄的
-- ex:回到sp_b的保存點。
ROLLBACK TO sp_b;
SELECT * FROM myemp;
-- ex:回到sp_a的保存點。
ROLLBACK TO sp_a;
SELECT * FROM myemp;


-- ➤事務自動提交
-- ex:在第一個SESSION窗口設置事務自動提交
SET AUTOCOMMIT ON;
--============================================================================--
--                                                                            --
/* ※更新及事務處理-鎖                                                        */
--                                                                            --
--============================================================================--
-- 說明:不同的SESSION同時操作了同一資源所發生的問題。
-- 在Oracle中的鎖有以下兩種基本類型:
-- ①行級鎖定(又稱紀錄鎖定)
-- ②表級鎖定

-- ex:第一個SESSION窗口執行以下語句(FOR UPDATE的用處就是加入鎖定在查詢上)
SELECT * FROM myemp WHERE deptno=10 FOR UPDATE;
-- ex:第二個SESSION窗口執行相同語句
SELECT * FROM myemp WHERE deptno=10 FOR UPDATE;
-- 在第二個SESSION窗口會發現被鎖住不會動作，因為所有的數據只能夠被一個SESSION操作。
-- 在第一個SESSION窗口執行ROLLBACK解鎖後，第二個SESSION窗口便可執行語句


-- ➤行級鎖定
-- 說明:用戶執行了INSERT、UPDATE、DELETE以及SELECT FOR UPDATE語句時，Oracle將隱式的
-- 實現紀錄的鎖定，這種鎖定被稱為排他鎖。行級鎖定主要特點是:當一個事務執行了相應的數
-- 據操作之後，如果此時事務沒有提交，那麼會一直以獨占的方式鎖定這些操作的數據，其他
-- 事務一直到此事務釋放鎖後才可以進行操作。
-- ex:在第一個SESSION窗口更新7788的員工訊息
UPDATE myemp SET sal=6000 WHERE empno=7788;
-- ex:在第二個SESSION窗口更新7788的員工訊息
UPDATE myemp SET job='CLERK' WHERE empno=7788;
-- 此時更新的紀錄和第一個SESSION是相同的，而且第一個SESSION沒有提交事務。如果更新了同
-- 一條紀錄，那麼第二的SESSION也會出現鎖的情況。
-- ex:在第一個SESSION窗口執行COMMIT後，第二個SESSION窗口就會更新7788的員工訊息。


-- ➤表級鎖定
-- 說明:表級鎖定需要用戶明確的使用"LOCK TABLE"語句手動進行鎖定
/*
表級鎖定語法:
LOCK TABLE 表名稱|視圖名稱,表名稱|視圖名稱,... IN 鎖定模式 MODE [NOWAIT]
NOWAIT:這是一個可選項，當視圖鎖定一張數據表時，如果發現已經被其他事務鎖定，就不會等待。
鎖定模式有如下幾種常見模式:
①ROW SHARE:行共享鎖，在鎖定期間允許其他事務併發對表進行各種操作，但不允許任何事務對同一
            張表進行獨占操作(禁止排他鎖)。
②ROW EXCLUSIVE:行排他鎖，允許用戶進行任何操作，與行共享鎖不同的是不能防止別的事務對同一
                張表進行手動鎖定或獨占操作。
③SHARE:共享鎖，其他事務指允許執行查詢操作，不能執行修改操作。
④SHARE ROW EXCLUSIVE:共享排他鎖，允許任何用戶進行查詢操作，但不允許其它用戶使用共享鎖，
                      之前所用的"SELECT FOR UPDATE"就是共享排他鎖的常見應用。
⑤EXCLUSIVE:排他鎖，事務將以獨占方式鎖定表，其他用戶允許查詢，但是不能修改，也不能設置任
            何的鎖。
*/

-- ex:在第一個SESSION窗口上針對myemp表使用共享鎖
LOCK TABLE myemp IN SHARE MODE NOWAIT;
-- ex:在第二個SESSION窗口執行更新
DELETE FROM myemp;
-- 在第一個SESSION窗口執行ROLLBACK
-- 在第二個SESSION窗口執行ROLLBACK


-- ➤解除鎖定
-- 說明:盡管用戶清楚了鎖產生的原因，但是在很多的時候由於業務量增加，並不會明確的列出鎖
-- 的種種可能，所以此時就必須透過其他方式查看是否出現了鎖定以及透過命令手動的解除鎖定。
/*
解除鎖定語法:
ALTER SYSTEM KILL SESSION 'SID,SERIAL#';
在此格式之中發現如果要想結束一個SESSION(結束一個SESSION就表示解鎖)，則需要兩個標記:
SESSION ID(SID)、另一個就是序列號(SERIAL#)，而這兩個內容可以利用"v$locked_object"
和"v$session"兩個數據字典查詢得到。
*/
-- ex:在第一個SESSION窗口使用FOR UPDATE鎖定數據
SELECT * FROM myemp WHERE deptno=10 FOR UPDATE;
-- ex:在第二個SESSION窗口使用FOR UPDATE鎖定數據
SELECT * FROM myemp WHERE deptno=10 FOR UPDATE;
-- 於是現在出現鎖的情況，下面就必須察看鎖的問題，但要使用超級管理員登入。

-- ex:使用超級管理員查看鎖的情況
-- SELECT * FROM v$locked_object;
DESC v$locked_object;
SELECT session_id, oracle_username, process FROM v$locked_object;
-- 此處就出現了一個SESSION ID(每一個用戶的SESSION由管理員分配)。但是只知道SESSION ID
-- 還是無法解除鎖定，所以還必須查看v$session數據字典。
-- SELECT * FROM v$session WHERE sid IN(171,333);
DESC v$session;
SELECT sid, serial#, lockwait, status FROM v$session WHERE sid IN(171,333);

-- ex:KILL一個進程(SESSION)，KILL掉lockwait不為空的(表示在等待中進入鎖的狀態)
-- 此時，鎖定的一方就會出現被KILL SESSIONN的提示
ALTER SYSTEM KILL SESSION '333,55407';