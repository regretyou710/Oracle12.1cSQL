-- 刪除數據表
DROP TABLE grade;
DROP TABLE sporter;
DROP TABLE item;
PURGE RECYCLEBIN;
-- 創建運動員表
CREATE TABLE sporter(
sporterid NUMBER(4),
name VARCHAR2(30) NOT NULL,
sex VARCHAR2(10) NOT NULL,
department VARCHAR2(30) NOT NULL,
CONSTRAINT pk_sporterid PRIMARY KEY(sporterid),
CONSTRAINT ck_sex CHECK(sex IN('男','女'))
);
COMMENT ON TABLE sporter IS '運動員數據表';
COMMENT ON COLUMN sporter.sporterid IS '主鍵,唯一標記';
COMMENT ON COLUMN sporter.name IS '運動員姓名不能為空';
COMMENT ON COLUMN sporter.sex IS '運動員性別只能是男或女';
COMMENT ON COLUMN sporter.department IS '每個運動員都要在一個系';
-- 創建項目表
CREATE TABLE item(
itemid VARCHAR2(4),
itemname VARCHAR2(30) NOT NULL,
location VARCHAR2(30) NOT NULL,
CONSTRAINT pk_itemid PRIMARY KEY(itemid)
);
COMMENT ON TABLE item IS '項目數據表';
COMMENT ON COLUMN item.itemid IS '主鍵,唯一標記';
COMMENT ON COLUMN item.itemname IS '項目名稱不能為空';
COMMENT ON COLUMN item.location IS '舉辦場地不能為空';
-- 創建成績表
CREATE TABLE grade(
sporterid NUMBER(4),
itemid VARCHAR2(4),
mark NUMBER(1),
CONSTRAINT fk_sporterid FOREIGN KEY(sporterid) 
	REFERENCES sporter(sporterid) ON DELETE CASCADE,
CONSTRAINT fk_itemid FOREIGN KEY(itemid) 
	REFERENCES item(itemid) ON DELETE CASCADE,
CONSTRAINT ck_mark CHECK(mark IN(6,4,2,0))
);
COMMENT ON TABLE grade IS '成績數據表';
COMMENT ON COLUMN grade.sporterid IS '與運動員表的sporterid對應';
COMMENT ON COLUMN grade.itemid IS '與項目表的itemid對應';
COMMENT ON COLUMN grade.mark IS '成績的取值範圍:6、4、2、0';
-- DDL可以不用事務提交，但是跟DML一起執行會產生錯誤
COMMIT;
-- 測試數據
INSERT INTO sporter (sporterid,name,sex,department) VALUES (1001,'李明','男','計算機系');
INSERT INTO sporter (sporterid,name,sex,department) VALUES (1002,'張三','男','數學系');
INSERT INTO sporter (sporterid,name,sex,department) VALUES (1003,'李四','男','計算機系');
INSERT INTO sporter (sporterid,name,sex,department) VALUES (1004,'王二','男','物理系');
INSERT INTO sporter (sporterid,name,sex,department) VALUES (1005,'李娜','女','心理系');
INSERT INTO sporter (sporterid,name,sex,department) VALUES (1006,'孫麗','女','數學系');
INSERT INTO item (itemid,itemname,location) VALUES ('x001','男子五千米','一操場');
INSERT INTO item (itemid,itemname,location) VALUES ('x002','男子標槍','一操場');
INSERT INTO item (itemid,itemname,location) VALUES ('x003','男子跳遠','二操場');
INSERT INTO item (itemid,itemname,location) VALUES ('x004','女子跳高','二操場');
INSERT INTO item (itemid,itemname,location) VALUES ('x005','女子三千米','三操場');
INSERT INTO grade (sporterid,itemid,mark) VALUES (1001,'x001',6);
INSERT INTO grade (sporterid,itemid,mark) VALUES (1002,'x001',4);
INSERT INTO grade (sporterid,itemid,mark) VALUES (1003,'x001',2);
INSERT INTO grade (sporterid,itemid,mark) VALUES (1004,'x001',0);
INSERT INTO grade (sporterid,itemid,mark) VALUES (1001,'x003',4);
INSERT INTO grade (sporterid,itemid,mark) VALUES (1002,'x003',6);
INSERT INTO grade (sporterid,itemid,mark) VALUES (1004,'x003',2);
INSERT INTO grade (sporterid,itemid,mark) VALUES (1003,'x003',0);
INSERT INTO grade (sporterid,itemid,mark) VALUES (1005,'x004',6);
INSERT INTO grade (sporterid,itemid,mark) VALUES (1006,'x004',4);
INSERT INTO grade (sporterid,itemid,mark) VALUES (1001,'x004',2);
INSERT INTO grade (sporterid,itemid,mark) VALUES (1002,'x004',0);
INSERT INTO grade (sporterid,itemid,mark) VALUES (1003,'x002',6);
INSERT INTO grade (sporterid,itemid,mark) VALUES (1005,'x002',4);
INSERT INTO grade (sporterid,itemid,mark) VALUES (1006,'x002',2);
INSERT INTO grade (sporterid,itemid,mark) VALUES (1004,'x002',0);
-- 提交事務
COMMIT;