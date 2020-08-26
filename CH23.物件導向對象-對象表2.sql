/*使用REF()函數引用dept_object對象屬性*/
-- 刪除已有的類
DROP TABLE emp_object_ref_tab PURGE;
DROP TABLE dept_object_ref_tab PURGE;
-- DROP TYPE emp_object_ref FORCE;


-- 定義emp_object子類類規範
CREATE OR REPLACE TYPE emp_object_ref UNDER person_object(
 atri_job VARCHAR2(9), 
 atri_sal NUMBER(7,2),
 atri_comm NUMBER(7,2),
 atri_dept REF dept_object, -- 修改為引用對象嵌套關係
 OVERRIDING MEMBER FUNCTION tostring RETURN VARCHAR2, -- 複寫抽象函數
 OVERRIDING MAP MEMBER FUNCTION compare RETURN NUMBER -- 複寫抽象MAP排序
);
/

CREATE OR REPLACE TYPE BODY emp_object_ref 
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
CREATE TABLE emp_object_ref_tab OF emp_object_ref;
CREATE TABLE dept_object_ref_tab OF dept_object;


-- 增加數據
INSERT INTO dept_object_ref_tab(atri_deptno, atri_dname, atri_loc) 
VALUES (10, 'orcl教學', '東岸');
INSERT INTO dept_object_ref_tab(atri_deptno, atri_dname, atri_loc) 
VALUES (20, 'orcl開發', '墨爾本');
INSERT INTO dept_object_ref_tab(atri_deptno, atri_dname, atri_loc) 
VALUES (30, 'orcl移動', '西岸');

INSERT INTO emp_object_ref_tab(atri_pid, atri_name, atri_sex, 
atri_job, atri_sal, atri_comm, atri_dept) 
VALUES (3010, '伊森', '男', '辦事員', 3500, 100, 
(SELECT REF(d) FROM dept_object_ref_tab d WHERE atri_deptno=10));
INSERT INTO emp_object_ref_tab(atri_pid, atri_name, atri_sex, 
atri_job, atri_sal, atri_comm, atri_dept) 
VALUES (3020, '茱蒂', '女', '技術員', 5500, 200, 
(SELECT REF(d) FROM dept_object_ref_tab d WHERE atri_deptno=20));


-- 事務提交
COMMIT;