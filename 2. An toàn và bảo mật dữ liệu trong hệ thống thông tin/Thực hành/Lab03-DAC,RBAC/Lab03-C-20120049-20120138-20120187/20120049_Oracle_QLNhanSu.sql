--Họ và tên: Nguyễn Hải Đăng
--MSSV: 20120049
--------------------------------------------------
--Câu 1: Tạo CSDL và insert dữ liệu
/*
    ALTER TABLE LUONG DROP CONSTRAINT FK_LUONG_NHANVIEN cascade;
    drop table LUONG cascade constraints;
    drop table NHANVIEN cascade constraints;
    drop table TONGHOP cascade constraints;

    select CONSTRAINT_NAME, CONSTRAINT_TYPE, TABLE_NAME
from USER_CONSTRAINTS;
*/
CREATE TABLE NHANVIEN (
    MaNV CHAR(5),
    MaPB CHAR(5),
    ChucVu CHAR(20),
    CONSTRAINT NHANVIEN_PK PRIMARY KEY (MaNV)
);

CREATE TABLE LUONG (
    MaNV CHAR(5),
    Thang INT,
    LuongCB FLOAT,
    PhuCap FLOAT,
    TongLuong FLOAT,
    CONSTRAINT LUONG_PK PRIMARY KEY (MaNV, Thang)
);

CREATE TABLE TONGHOP (
    Nam INT,
    MaPB CHAR(5),
    Thu FLOAT,
    Chi FLOAT,
    CONSTRAINT TONGHOP_PK PRIMARY KEY (Nam, MaPB)
);

ALTER TABLE LUONG
ADD CONSTRAINT FK_LUONG_NHANVIEN
FOREIGN KEY (MaNV) 
REFERENCES NHANVIEN(MaNV);
/

CREATE OR REPLACE PROCEDURE SP_InsertData_QLNS
IS
BEGIN
    --Insert giám đốc
    INSERT INTO NHANVIEN (MaNV, MaPB, ChucVu) VALUES ('GD001', 'PB001', 'Giám đốc');
    INSERT INTO LUONG VALUES ('GD001', 3, 20000000, 5000000, 25000000);

    --Insert trưởng phòng + bảng TONGHOP
    --PB002 là phòng kế toán, PB003 là phòng kế hoạch, PB004 là phòng kỹ thuật
    FOR i IN 1..3
    LOOP 
        INSERT INTO NHANVIEN VALUES ('TP' || TO_CHAR(i,'fm000'), 'PB' || TO_CHAR(i + 1,'fm000'), 'Trưởng phòng');
        INSERT INTO LUONG VALUES ('TP' || TO_CHAR(i,'fm000'), 3, 12000000, 3000000, 15000000);
    END LOOP;

    --Insert phòng kế toán (KT)
    FOR i IN 1..10
    LOOP 
        INSERT INTO NHANVIEN VALUES ('KT' || TO_CHAR(i,'fm000'), 'PB002', 'Nhân viên');
        INSERT INTO LUONG VALUES ('KT' || TO_CHAR(i,'fm000'), 3, 8000000, 2000000, 10000000);
    END LOOP;

    --Insert phòng kế hoạch (KH)
    FOR i IN 1..15
    LOOP 
        INSERT INTO NHANVIEN VALUES ('KH' || TO_CHAR(i,'fm000'), 'PB003', 'Nhân viên');
        INSERT INTO LUONG VALUES ('KH' || TO_CHAR(i,'fm000'), 3, 6000000, 1500000, 7500000);
    END LOOP;

    --Insert phòng kỹ thuật (KS)
    FOR i IN 1..10
    LOOP 
        INSERT INTO NHANVIEN VALUES ('KS' || TO_CHAR(i,'fm000'), 'PB004', 'Nhân viên');
        INSERT INTO LUONG VALUES ('KS' || TO_CHAR(i,'fm000'), 3, 6000000, 1000000, 7000000);
    END LOOP;

    --Insert bảng TONGHOP 
    INSERT INTO TONGHOP VALUES (2023, 'PB002', 550000000, 450000000);
    INSERT INTO TONGHOP VALUES (2023, 'PB003', 350000000, 300000000);
    INSERT INTO TONGHOP VALUES (2023, 'PB004', 150000000, 120000000);
END;
/
EXEC SP_InsertData_QLNS();

select * from NHANVIEN;
select * from LUONG;
SELECT * FROM TONGHOP;

--------------------------------------------------
--Câu 2: Tạo user với danh sách nhân sự trên
alter session set "_ORACLE_SCRIPT"=true;
CREATE OR REPLACE PROCEDURE SP_CreateUser_QLNS
IS
    user_ CHAR(5);
    cursor_ SYS_REFCURSOR;
BEGIN
    OPEN cursor_ FOR
        SELECT MaNV FROM NHANVIEN; 
    LOOP 
        FETCH cursor_ INTO user_;
        EXIT WHEN cursor_%NOTFOUND;
        EXECUTE IMMEDIATE 'CREATE USER '||user_||' IDENTIFIED BY '||user_;
    END LOOP;

    EXCEPTION
        when no_data_found then
        dbms_output.put_line('No record found');
    CLOSE cursor_;
END;
/
EXEC SP_CreateUser_QLNS();
SELECT * FROM dba_users;
/
--Drop User (nếu cần)
CREATE OR REPLACE PROCEDURE SP_DropUser_QLNS
IS
    user_ CHAR(5);
    cursor_ SYS_REFCURSOR;
BEGIN
    OPEN cursor_ FOR
        SELECT MaNV FROM NHANVIEN; 
    LOOP 
        FETCH cursor_ INTO user_;
        EXIT WHEN cursor_%NOTFOUND;
        EXECUTE IMMEDIATE 'DROP USER '||user_ || ' CASCADE';
    END LOOP;

    EXCEPTION
        when no_data_found then
        dbms_output.put_line('No record found');
    CLOSE cursor_;
END;
/
--EXEC SP_DropUser_QLNS();
SELECT * FROM dba_users 
WHERE USERNAME LIKE '%GD%'
    OR USERNAME LIKE '%TP%'
    OR USERNAME LIKE '%KH%'
    OR USERNAME LIKE '%KT%'
    OR USERNAME LIKE '%KS%'
ORDER BY USERNAME;
/*
    drop procedure SP_InsertData_QLNS;
    drop procedure SP_CreateUser_QLNS;
    drop procedure SP_DropUser_QLNS;
*/

--------------------------------------------------
--Câu 3: Cài đặt cơ chế DAC
--a. Cấp quyền truy cập treo ma trận truy xuất
CREATE OR REPLACE VIEW V_NHANVIEN AS
SELECT MaNV, MaPB, ChucVu FROM NHANVIEN;
--drop view V_NHANVIEN;

CREATE OR REPLACE VIEW V_LUONG AS
SELECT MaNV, Thang, LuongCB, PhuCap, TongLuong FROM LUONG;
--drop view V_LUONG;

CREATE OR REPLACE VIEW V_TONGHOP AS
SELECT Nam, MaPB, Thu, Chi FROM TONGHOP;
--drop view V_TONGHOP;

CREATE OR REPLACE VIEW V_TONGHOP_NotChi AS
SELECT Nam, MaPB, Thu FROM TONGHOP;
/*
drop view V_NHANVIEN;
drop view V_LUONG;
drop view V_TONGHOP;
drop view V_TONGHOP_NotChi;
*/
CREATE OR REPLACE PROCEDURE SP_DAC_QLNS
IS
    user_ CHAR(5);
    cursor_ SYS_REFCURSOR;
BEGIN
    --Cấp quyền đọc dữ liệu cho giám đốc
    
    OPEN cursor_ FOR
        SELECT MaNV FROM NHANVIEN
        WHERE ChucVu = 'Giám đốc'; 
    LOOP 
        FETCH cursor_ INTO user_;
        EXIT WHEN cursor_%NOTFOUND;
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO '||user_;
        EXECUTE IMMEDIATE 'GRANT CONNECT TO '||user_;
        EXECUTE IMMEDIATE 'GRANT SELECT ON NHANVIEN TO '||user_;
        EXECUTE IMMEDIATE 'GRANT SELECT ON LUONG TO '||user_;
        EXECUTE IMMEDIATE 'GRANT SELECT ON TONGHOP TO '||user_;
    END LOOP;
    CLOSE cursor_;

    --Cấp quyền ghi dữ liệu cho giám đốc trên V_TONGHOP
    OPEN cursor_ FOR
        SELECT MaNV FROM NHANVIEN
        WHERE ChucVu = 'Giám đốc'; 
    LOOP 
        FETCH cursor_ INTO user_;
        EXIT WHEN cursor_%NOTFOUND;
        EXECUTE IMMEDIATE 'GRANT INSERT (Nam, Thu, Chi), UPDATE (Nam, Thu, Chi) ON TONGHOP TO '||user_;
        EXECUTE IMMEDIATE 'GRANT DELETE ON TONGHOP TO '||user_;
    END LOOP;
    CLOSE cursor_;

    --Cấp quyền đọc, ghi dữ liệu V_NHANVIEN và V_LUONG cho trưởng phòng
    OPEN cursor_ FOR
        SELECT MaNV FROM NHANVIEN
        WHERE ChucVu = 'Trưởng phòng'; 
    LOOP 
        FETCH cursor_ INTO user_;
        EXIT WHEN cursor_%NOTFOUND;
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO '||user_;
        EXECUTE IMMEDIATE 'GRANT CONNECT TO '||user_;
        EXECUTE IMMEDIATE 'GRANT SELECT ON NHANVIEN TO '||user_;
        EXECUTE IMMEDIATE 'GRANT SELECT ON LUONG TO '||user_;
        EXECUTE IMMEDIATE 'GRANT INSERT, UPDATE, DELETE ON NHANVIEN TO '||user_;
        EXECUTE IMMEDIATE 'GRANT INSERT, UPDATE, DELETE ON LUONG TO '||user_;
    END LOOP;
    CLOSE cursor_;

    --Cấp quyền đọc trên V_NHANVIEN cho nhân viên
    OPEN cursor_ FOR
        SELECT MaNV FROM NHANVIEN
        WHERE ChucVu = 'Nhân viên'; 
    LOOP 
        FETCH cursor_ INTO user_;
        EXIT WHEN cursor_%NOTFOUND;
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO '||user_;
        EXECUTE IMMEDIATE 'GRANT CONNECT TO '||user_;
        EXECUTE IMMEDIATE 'GRANT SELECT ON NHANVIEN TO '||user_;
    END LOOP;
    CLOSE cursor_;
END;
/
EXEC SP_DAC_QLNS();
select * from table_privileges
WHERE grantee LIKE '%GD%'
    OR grantee LIKE '%TP%'
    OR grantee LIKE '%KH%'
    OR grantee LIKE '%KT%'
    OR grantee LIKE '%KS%'
order by owner, table_name;
--drop procedure SP_DAC_QLNS;

--b. Giám đốc có thể cấp quyền đọc trên quan hệ TONGHOP cho các trưởng phòng
CREATE OR REPLACE PROCEDURE SP_GDGrantTongHopToTP
IS
    user_ CHAR(5);
    cursor_ SYS_REFCURSOR;
BEGIN
    OPEN cursor_ FOR
        SELECT MaNV FROM NHANVIEN
        WHERE ChucVu = 'Giám đốc'; 
    LOOP 
        FETCH cursor_ INTO user_;
        EXIT WHEN cursor_%NOTFOUND;
        EXECUTE IMMEDIATE 'GRANT SELECT ON TONGHOP TO '||user_ || ' WITH GRANT OPTION';
    END LOOP;
    CLOSE cursor_;
END;
/
EXEC SP_GDGrantTongHopToTP();
--drop procedure SP_GDGrantTongHopToTP;
/* Chạy đoạn lệnh này để TP cấp quyền đọc quan hệ TONGHOP cho NV.
CONNECT GD001/GD001;
GRANT SELECT ON sys.TONGHOP TO TP001;
GRANT SELECT ON sys.TONGHOP TO TP002;
GRANT SELECT ON sys.TONGHOP TO TP003;
*/

--c. Trưởng phòng có thể cấp quyền đọc trên quan hệ NHANVIEN cho các nhân viên
CREATE OR REPLACE PROCEDURE SP_TPGrantNhanVienToNV
IS
    user_ CHAR(5);
    cursor_ SYS_REFCURSOR;
BEGIN
    OPEN cursor_ FOR
        SELECT MaNV FROM NHANVIEN
        WHERE ChucVu = 'Trưởng phòng'; 
    LOOP 
        FETCH cursor_ INTO user_;
        EXIT WHEN cursor_%NOTFOUND;
        EXECUTE IMMEDIATE 'GRANT SELECT ON TONGHOP TO '||user_ || ' WITH GRANT OPTION';
    END LOOP;
    CLOSE cursor_;
END;
/
EXEC SP_TPGrantNhanVienToNV();
--drop procedure SP_TPGrantNhanVienToNV;

/* Chạy đoạn lệnh này để TP cấp quyền đọc quan hệ TONGHOP cho NV.
CONNECT TP001/TP001;
GRANT SELECT ON sys.TONGHOP TO KT001;
GRANT SELECT ON sys.TONGHOP TO KT002;
GRANT SELECT ON sys.TONGHOP TO KT003;
GRANT SELECT ON sys.TONGHOP TO KT004;
GRANT SELECT ON sys.TONGHOP TO KT005;
GRANT SELECT ON sys.TONGHOP TO KT006;
GRANT SELECT ON sys.TONGHOP TO KT007;
GRANT SELECT ON sys.TONGHOP TO KT008;
GRANT SELECT ON sys.TONGHOP TO KT009;
GRANT SELECT ON sys.TONGHOP TO KT010;
GRANT SELECT ON sys.TONGHOP TO KH001;
GRANT SELECT ON sys.TONGHOP TO KH002;
GRANT SELECT ON sys.TONGHOP TO KH003;
GRANT SELECT ON sys.TONGHOP TO KH004;
GRANT SELECT ON sys.TONGHOP TO KH005;
GRANT SELECT ON sys.TONGHOP TO KH006;
GRANT SELECT ON sys.TONGHOP TO KH007;
GRANT SELECT ON sys.TONGHOP TO KH008;
GRANT SELECT ON sys.TONGHOP TO KH009;
GRANT SELECT ON sys.TONGHOP TO KH010;
GRANT SELECT ON sys.TONGHOP TO KH011;
GRANT SELECT ON sys.TONGHOP TO KH012;
GRANT SELECT ON sys.TONGHOP TO KH013;
GRANT SELECT ON sys.TONGHOP TO KH014;
GRANT SELECT ON sys.TONGHOP TO KH015;
GRANT SELECT ON sys.TONGHOP TO KS001;
GRANT SELECT ON sys.TONGHOP TO KS002;
GRANT SELECT ON sys.TONGHOP TO KS003;
GRANT SELECT ON sys.TONGHOP TO KS004;
GRANT SELECT ON sys.TONGHOP TO KS005;
GRANT SELECT ON sys.TONGHOP TO KS006;
GRANT SELECT ON sys.TONGHOP TO KS007;
GRANT SELECT ON sys.TONGHOP TO KS008;
GRANT SELECT ON sys.TONGHOP TO KS009;
GRANT SELECT ON sys.TONGHOP TO KS010;
*/

--d. Giám đốc lấy lại quyền đọc trên thuộc tính Chi.
REVOKE SELECT ON TONGHOP FROM GD001;
GRANT SELECT ON V_TONGHOP_NotChi TO GD001;
SELECT * FROM V_TONGHOP_NotChi;

--e. Vẽ lại ma trận truy xuất
/*
                | MANV | MaPB | ChucVu | Thang | LuongCB | PhuCap | TongLuong | Nam | Thu | Chi |
| ------------- | ---- | ---- | ------ | ----- | ------- | ------ | --------- | --- | --- | --- |
| Giám đốc      |  01  |  01  |   01   |  01   |   01    |   01   |    01     | 11  | 11  | 10  |
| Trưởng phòng  |  11  |  11  |   11   |  11   |   11    |   11   |    11     | 01  | 01  | 01  |
| Nhân viên     |  01  |  01  |   01   |  00   |   00    |   00   |    00     | 01  | 01  | 01  |
*/

----------------------------------------------
-- Câu 4: Cài đặt cơ chế RBAC
CREATE ROLE GD;
CREATE ROLE TP;
CREATE ROLE NV;

/*
DROP ROLE GD;
DROP ROLE TP;
DROP ROLE NV;
*/

CREATE OR REPLACE PROCEDURE SP_RoleToUser_QLNS
IS
    user_ CHAR(5);
    cursor_ SYS_REFCURSOR;
BEGIN
    OPEN cursor_ FOR
        SELECT MaNV FROM NHANVIEN 
        WHERE ChucVu = 'Giám đốc';
    LOOP 
        FETCH cursor_ INTO user_;
        EXIT WHEN cursor_%NOTFOUND;
        EXECUTE IMMEDIATE 'GRANT GD TO '||user_;
    END LOOP;
    CLOSE cursor_;

    OPEN cursor_ FOR
        SELECT MaNV FROM NHANVIEN 
        WHERE ChucVu = 'Trưởng phòng';
    LOOP 
        FETCH cursor_ INTO user_;
        EXIT WHEN cursor_%NOTFOUND;
        EXECUTE IMMEDIATE 'GRANT TP TO '||user_;
    END LOOP;
    CLOSE cursor_;

    OPEN cursor_ FOR
        SELECT MaNV FROM NHANVIEN 
        WHERE ChucVu = 'Nhân viên';
    LOOP 
        FETCH cursor_ INTO user_;
        EXIT WHEN cursor_%NOTFOUND;
        EXECUTE IMMEDIATE 'GRANT NV TO '||user_;
    END LOOP;
    CLOSE cursor_; 
END;
/
EXEC SP_RoleToUser_QLNS();
--drop procedure SP_RoleToUser_QLNS;

--a. Cấp quyền theo ma trận quyền truy xuất
    --Cấp quyền đọc dữ liệu cho giám đốc
GRANT CREATE SESSION TO GD;
GRANT CONNECT TO GD;
GRANT SELECT ON NHANVIEN TO GD;
GRANT SELECT ON LUONG TO GD;
GRANT SELECT ON TONGHOP TO GD;

    --Cấp quyền ghi dữ liệu cho giám đốc trên TONGHOP
GRANT INSERT (Nam, Thu, Chi), UPDATE (Nam, Thu, Chi) ON TONGHOP TO GD;
GRANT DELETE ON TONGHOP TO GD;

    --Cấp quyền đọc, ghi dữ liệu NHANVIEN và LUONG cho trưởng phòng
GRANT CREATE SESSION TO TP;
GRANT CONNECT TO TP;
GRANT SELECT ON NHANVIEN TO TP;
GRANT SELECT ON LUONG TO TP;
GRANT INSERT, UPDATE, DELETE ON NHANVIEN TO TP;
GRANT INSERT, UPDATE, DELETE ON LUONG TO TP;

    --Cấp quyền đọc trên V_NHANVIEN cho nhân viên
GRANT CREATE SESSION TO NV;
GRANT CONNECT TO NV;
GRANT SELECT ON NHANVIEN TO NV;

--b. Giám đốc cấp quyền đọc trên quan hệ TONGHOP cho trưởng phòng
GRANT SELECT ON TONGHOP TO GD001 WITH GRANT OPTION;
/* Câu lệnh kết nối với role GD
CONNECT GD001/GD001;
GRANT SELECT ON sys.TONGHOP TO TP;
*/

--c. Trưởng phòng cấp quyền đọc trên quan hệ TONGHOP cho nhân viên
GRANT SELECT ON TONGHOP TO TP001 WITH GRANT OPTION;
GRANT SELECT ON TONGHOP TO TP002 WITH GRANT OPTION;
GRANT SELECT ON TONGHOP TO TP003 WITH GRANT OPTION;
/* Câu lệnh kết nối với role TP
CONNECT TP001/TP001;
GRANT SELECT ON sys.TONGHOP TO NV;
*/

--d. Giám đốc lấy lại quyền đọc trên thuộc tính Chi.
REVOKE SELECT ON TONGHOP FROM GD;
REVOKE SELECT ON TONGHOP FROM GD001;
GRANT SELECT ON V_TONGHOP_NotChi TO GD;

--e. Vẽ lại ma trận truy xuất
/*
                | MANV | MaPB | ChucVu | Thang | LuongCB | PhuCap | TongLuong | Nam | Thu | Chi |
| ------------- | ---- | ---- | ------ | ----- | ------- | ------ | --------- | --- | --- | --- |
| Giám đốc      |  01  |  01  |   01   |  01   |   01    |   01   |    01     | 11  | 11  | 10  |
| Trưởng phòng  |  11  |  11  |   11   |  11   |   11    |   11   |    11     | 01  | 01  | 01  |
| Nhân viên     |  01  |  01  |   01   |  00   |   00    |   00   |    00     | 01  | 01  | 01  |
*/
