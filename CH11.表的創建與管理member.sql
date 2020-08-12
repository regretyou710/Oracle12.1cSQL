-- 刪除數據表
DROP TABLE member PURGE;
-- 創建數據表
CREATE TABLE member(
mid NUMBER, 
name VARCHAR(50) DEFAULT '無名氏'
);
-- 增加測試數據
INSERT INTO member (mid,name) VALUES (1,'張無忌');
INSERT INTO member (mid,name) VALUES (2,'趙敏');
INSERT INTO member (mid,name) VALUES (3,'周芷若');
-- 提交事務
COMMIT;