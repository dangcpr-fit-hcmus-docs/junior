/*
    H�? và Tên: Lê Thành Nam
    MSSV: 20120138
*/

ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;
CREATE USER DANG IDENTIFIED BY DANG;
GRANT CONNECT TO DANG;
GRANT ALL PRIVILEGES TO DANG;
CONNECT DANG/DANG
/*
DROP TABLE DANG.EMPHOLIDAY;
DROP USER HANN CASCADE;
DROP USER ANNU CASCADE;
DROP USER THEOTA CASCADE;
DROP USER DANG CASCADE;
*/

-- 1. Create table and enter data
CREATE TABLE EMPHOLIDAY(
    EMPNO NUMBER(5) PRIMARY KEY,
    NAME VARCHAR2(60),
    HOLIDAY DATE
);

INSERT INTO EMPHOLIDAY VALUES (
    1,
    'Hann',
    TO_DATE('02/01/2019', 'DD/MM/YYYY')
);

INSERT INTO EMPHOLIDAY VALUES (
    2,
    'Annu',
    TO_DATE('22/05/2019', 'DD/MM/YYYY')
);

INSERT INTO EMPHOLIDAY VALUES (
    3,
    'Theota',
    TO_DATE('26/08/2018', 'DD/MM/YYYY')
);

-- 2. Create user
CREATE USER HANN IDENTIFIED BY HANN;

GRANT CONNECT TO HANN;



CREATE USER ANNU IDENTIFIED BY ANNU;

GRANT CONNECT TO ANNU;



CREATE USER THEOTA IDENTIFIED BY THEOTA;

GRANT CONNECT TO THEOTA;

-- 3. Use VPD to build policy HolidayControl
-- a. Annu only see and update her personal information

GRANT SELECT, UPDATE on DANG.EMPHOLIDAY to ANNU;

select * from DANG.EMPHOLIDAY;

CREATE OR REPLACE FUNCTION HolidayControl_funcpolicy_1 (
    p_schema in VARCHAR2,
    p_object in VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
    IF (USER = 'ANNU') THEN
        RETURN 'NAME = ''Annu''';
    ELSE
        RETURN '1=1';
    END IF;
END;
/
--drop function theota_limit;
--Thêm quyền ALTER ANY OBJECT cho người dùng hiện tại
BEGIN
    DBMS_RLS.ADD_POLICY (
        OBJECT_SCHEMA => 'DANG',
        OBJECT_NAME => 'EMPHOLIDAY',
        POLICY_NAME => 'HolidayControl_1',
        POLICY_FUNCTION => 'HolidayControl_funcpolicy_1',
        statement_types =>  'UPDATE, SELECT',
        update_check => TRUE
    );
END;
/

grant execute on DBMS_RLS to DANG;

SELECT * FROM DANG.EMPHOLIDAY;
/*
BEGIN
  DBMS_RLS.DROP_POLICY(
    object_schema   => 'DANG',
    object_name     => 'EMPHOLIDAY',
    policy_name     => 'HolidayControl_1'
  );
END;
*/



