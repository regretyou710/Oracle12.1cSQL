-- 刪除已有的類
DROP TABLE emp_object_tab PURGE;
DROP TYPE emp_object FORCE;
DROP TYPE dept_object FORCE;
DROP TYPE person_object FORCE;


-- 定義dept_object類規範
CREATE OR REPLACE TYPE dept_object IS OBJECT(
 atri_deptno NUMBER(2),
 atri_dname VARCHAR2(14),
 atri_loc VARCHAR2(13),
 MEMBER FUNCTION tostring RETURN VARCHAR2
) NOT FINAL;
/

-- 定義dept_object類體
CREATE OR REPLACE TYPE BODY dept_object 
IS 
 MEMBER FUNCTION tostring 
 RETURN VARCHAR2 
 IS 
 BEGIN 
  RETURN '部門編號: ' || SELF.atri_deptno 
  || ', 名稱: ' || SELF.atri_dname 
  || ', 位置: ' || SELF.atri_loc;
 END;
END;
/

-- 定義person_object類規範(抽象類)
CREATE OR REPLACE TYPE person_object IS OBJECT(
 atri_pid NUMBER,
 atri_name VARCHAR2(10),
 atri_sex VARCHAR2(10),
 NOT INSTANTIABLE MEMBER FUNCTION tostring RETURN VARCHAR2, -- 定義抽象函數
 NOT INSTANTIABLE MAP MEMBER FUNCTION compare RETURN NUMBER -- 定義抽象MAP排序
) NOT FINAL NOT INSTANTIABLE; -- 定義抽象類
/

-- 定義emp_object子類類規範
CREATE OR REPLACE TYPE emp_object UNDER person_object(
 atri_job VARCHAR2(9), 
 atri_sal NUMBER(7,2),
 atri_comm NUMBER(7,2),
 atri_dept dept_object, -- 對象嵌套關係
 OVERRIDING MEMBER FUNCTION tostring RETURN VARCHAR2, -- 複寫抽象函數
 OVERRIDING MAP MEMBER FUNCTION compare RETURN NUMBER -- 複寫抽象MAP排序
);
/

-- 定義emp_object子類類體
CREATE OR REPLACE TYPE BODY emp_object 
IS 
 -- 實現抽象函數
 OVERRIDING MEMBER FUNCTION tostring 
 RETURN VARCHAR2 
 IS 
 BEGIN 
  RETURN '人員編號: ' || SELF.atri_pid 
  || ', 姓名: ' || SELF.atri_name 
  || ', 性別: ' || SELF.atri_sex 
  || ', 職位: ' || SELF.atri_job 
  || ', 工資: ' || SELF.atri_sal 
  || ', 傭金: ' || SELF.atri_comm;
 END;
 
 OVERRIDING MAP MEMBER FUNCTION compare 
 RETURN NUMBER 
 IS 
 BEGIN 
  RETURN SELF.atri_sal + SELF.atri_comm;
 END;
END;
/


-- 創建對象表
CREATE TABLE emp_object_tab OF emp_object;


-- 增加數據
-- 部門屬性為空
INSERT INTO emp_object_tab(atri_pid, atri_name, atri_sex, 
atri_job, atri_sal, atri_comm) 
VALUES (10, '伊森', '男', '辦事員', 3500, 100);

-- 部門屬性不為空，嵌套類型(建構函數的形式添加)
INSERT INTO emp_object_tab(atri_pid, atri_name, atri_sex, 
atri_job, atri_sal, atri_comm, atri_dept) 
VALUES (20, '茱蒂', '女', '技術員', 5500, 200, 
dept_object(10, '開發部', '東岸'));


-- 事務提交
COMMIT;