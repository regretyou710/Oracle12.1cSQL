/*==============================================================*/
/* DBMS name:      ORACLE Version 11g                           */
/* Created on:     2020/8/16 ¤U¤È 04:50:47                        */
/*==============================================================*/


drop table EMP purge;
drop table DEPT purge;


/*==============================================================*/
/* Table: DEPT                                                  */
/*==============================================================*/
create table DEPT 
(
   "deptno"             NUMBER(2)            not null,
   "dname"              VARCHAR2(14),
   "loc"                VARCHAR2(13),
   constraint PK_DEPT primary key ("deptno")
);

/*==============================================================*/
/* Table: EMP                                                   */
/*==============================================================*/
create table EMP 
(
   "empno"              NUMBER(4)            not null,
   "deptno"             NUMBER(2),
   "mgr"                NUMBER(4),
   "ename"              VARCHAR2(10),
   "job"                VARCHAR2(9),
   "hiredate"           DATE,
   "sal"                NUMBER(7,2),
   "comm"               NUMBER(7,2),
   constraint PK_EMP primary key ("empno"), 
   constraint FK_EMP_REFERENCE_DEPT foreign key ("deptno")
      references DEPT ("deptno"), 
   constraint FK_EMP_REFERENCE_EMP foreign key ("mgr")
      references EMP ("empno")
);