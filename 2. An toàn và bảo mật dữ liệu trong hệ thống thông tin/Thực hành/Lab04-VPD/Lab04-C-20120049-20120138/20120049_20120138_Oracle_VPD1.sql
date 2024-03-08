/*
    THÔNG TIN NHÓM
    20120049 - NGUYỄN HẢI ĐĂNG
    20120138 - LÊ THÀNH NAM
*/

/*
    Họ và Tên: Lê Thành Nam
    MSSV: 20120138
    Thực hiện câu: 1,2,3a
*/
ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;
--ALTER SYSTEM SET "_allow_insert_with_update_check"=TRUE scope=spfile;
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

-- 2. Create user (từ câu này trở về sau, đăng nhập vào user SYSDBA để thực hiện)
CREATE USER HANN IDENTIFIED BY HANN;

GRANT CONNECT TO HANN;



CREATE USER ANNU IDENTIFIED BY ANNU;

GRANT CONNECT TO ANNU;

SHOW CON_NAME;

CREATE USER THEOTA IDENTIFIED BY THEOTA;

GRANT CONNECT TO THEOTA;

--3a. ANNU chỉ được xem và chỉnh sửa thông tin của chính mình
grant insert, delete, update, select ON DANG.EMPHOLIDAY to THEOTA;
grant update, select ON DANG.EMPHOLIDAY to ANNU;

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

/*
    Họ và Tên: Nguyễn Hải Đăng
    MSSV: 20120049
    Thực hiện câu: 3b,3c
*/
-- 3b. Theota không được xem hay chỉnh sửa bất kì thông tin nào.
CREATE OR REPLACE FUNCTION HolidayControl_funcpolicy (
    p_schema in VARCHAR2,
    p_object in VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
    IF (USER = 'THEOTA') THEN
        RETURN 'USER != ''THEOTA''';
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
        POLICY_NAME => 'HolidayControl',
        POLICY_FUNCTION => 'HolidayControl_funcpolicy',
        statement_types =>  'INSERT, UPDATE, DELETE, SELECT',
        update_check => TRUE
    );
END;
/
/*
BEGIN
DBMS_RLS.DROP_POLICY (
        OBJECT_SCHEMA => 'DANG',
        OBJECT_NAME => 'EMPHOLIDAY',
        POLICY_NAME => 'HolidayControl'
    );
END;
*/
/
grant insert, update, select, delete ON DANG.EMPHOLIDAY to HANN;


--3c. HANN không được chỉnh sửa thông tin của những ngày nghỉ trong quá khứ, nhưng được xem thông tin toàn bảng EMPHOLIDAY (đã cài đặt trong câu 3b).
CREATE OR REPLACE FUNCTION HolidayControl_funcpolicy_2 (
    p_schema in VARCHAR2,
    p_object in VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
    IF (USER = 'HANN') THEN
        RETURN 'HOLIDAY >= TRUNC(SYSDATE)';
    ELSE
        RETURN '1=1';
    END IF;
END;
/
BEGIN
    DBMS_RLS.ADD_POLICY (
        OBJECT_SCHEMA => 'DANG',
        OBJECT_NAME => 'EMPHOLIDAY',
        POLICY_NAME => 'HolidayControl_2',
        statement_types => 'INSERT, UPDATE, DELETE',
        update_check => TRUE,
        POLICY_FUNCTION => 'HolidayControl_funcpolicy_2',
        enable           => TRUE
    );
END;
/*
BEGIN
DBMS_RLS.DROP_POLICY (
        OBJECT_SCHEMA => 'DANG',
        OBJECT_NAME => 'EMPHOLIDAY',
        POLICY_NAME => 'HolidayControl_2'
    );
END;

set serveroutput on;
 dbms_output.put_line(trunc(SYSDATE));
 */