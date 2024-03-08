/*
    MSSV: 20120138
    Họ và tên: Lê Thành Nam
    Thực hiện câu: 1, 3
*/

-- DROP user ACCMASTER CASCADE;

-- 1. Create table ACCOUNTS for the ACCMASTER's schema
ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;
/*
DROP USER DANG CASCADE;
DROP USER NAM CASCADE;
DROP USER ACCMASTER CASCADE;
DROP TABLE ACCMASTER.ACCOUNTS ;
*/
CREATE USER ACCMASTER IDENTIFIED BY ACCMASTER;
CREATE USER DANG IDENTIFIED BY DANG;
CREATE USER NAM IDENTIFIED BY NAM;

GRANT CONNECT TO ACCMASTER;
GRANT CONNECT TO DANG;
GRANT CONNECT TO NAM;


GRANT UNLIMITED TABLESPACE TO ACCMASTER;

CREATE TABLE ACCMASTER.ACCOUNTS (
   ACCNO NUMBER(10) PRIMARY KEY,
   ACCNAME VARCHAR2(20),
   BAL NUMBER
);

INSERT INTO ACCMASTER.ACCOUNTS VALUES(1, 'Alex', 10000);

INSERT INTO ACCMASTER.ACCOUNTS VALUES(2, 'Bill', 15000);

INSERT INTO ACCMASTER.ACCOUNTS VALUES(3, 'Charlie', 20000);

INSERT INTO ACCMASTER.ACCOUNTS VALUES(4, 'David', 25000);

/*
    MSSV: 20120049
    Họ và tên: Nguyễn Hải Đăng
    Thực hiện câu: 2
*/
-- 2. Giám sát khi một user nào đó truy cập vào bảng ACCOUNTS và xem số dư lớn hơn hoặc bằng 20000.
GRANT SELECT ON ACCMASTER.ACCOUNTS TO DANG;
GRANT SELECT ON ACCMASTER.ACCOUNTS TO NAM;
BEGIN
    DBMS_FGA.drop_policy(object_schema => 'ACCMASTER',
                        object_name => 'ACCOUNTS',
                        policy_name => 'ACC_MORE20000');
    EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -28102 THEN
            RAISE;
        END IF;
END;
/
BEGIN
    DBMS_FGA.ADD_POLICY(OBJECT_SCHEMA  => 'ACCMASTER',
                        OBJECT_NAME => 'ACCOUNTS',
                        POLICY_NAME => 'ACC_MORE20000',
                        AUDIT_CONDITION => 'BAL >= 20000',
                        AUDIT_COLUMN_OPTS =>  dbms_fga.all_columns
                       );
END;
/
SELECT * FROM ACCMASTER.ACCOUNTS WHERE ACCNO = 4;
--Kiểm tra các chính sách FGA
select * from DBA_AUDIT_POLICIES;
--Kiểm tra xem có audit thành công chưa
SELECT * FROM unified_audit_trail where audit_type = 'FineGrainedAudit';
/*
BEGIN
    DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(
    audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
    use_last_arch_timestamp => FALSE);
END;
*/
--SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Unified Auditing';

/*
    MSSV: 20120138
    Họ và tên: Lê Thành Nam
    Thực hiện câu: 1, 3
*/
-- 3. Answer:
/*
Theo chính sách đã được cung cấp thì:
 - Nếu có bất kỳ truy vấn nào đang được thực hiện trên bảng ACCOUNTS trả ra thông tin liên quan điều kiện BAL >=20000, các cột ACCNO và BAL đều có vai trò trong truy vấn và có kết quả trả về thì sẽ bị giám sát.
==> Đáp án a và c gây ra giám sát, đáp án b và d không gây ra giám sát
Câu d không trả ra kết quả nên ko giám sát.
Câu b trả ra kết quả nhưng ko thỏa cột chịu giám sát là (ACCNO,BAL) nên ko gây ra giám sát.
*/



