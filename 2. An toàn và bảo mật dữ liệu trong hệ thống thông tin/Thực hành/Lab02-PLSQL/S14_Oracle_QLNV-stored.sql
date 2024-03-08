/*
    THÔNG TIN NHÓM S14:
    20120049 - Nguyễn Hải Đăng,
    20120138 - Lê Thành Nam,
    20120187 - Nguyễn Viết Thái
    20120289 - Võ Minh Hiếu
*/

 /*
    drop procedure SP_SALHIREDATE_20120138; drop procedure SP_CAUTRUCBANGEMP_20120138; drop procedure SP_CAU1_THUNHAPNV_20120138;
    drop procedure sp_DanhSachNV_vao1983_20120187; drop procedure sp_DanhSachNV_THLL_20120187; drop procedure sp_DanhSachNVLuong_20120187;
    drop procedure sp_DanhSachNV_Luongtang15_20120049; drop procedure sp_HienThi_20120049;
    drop procedure sp_DanhSachNhanVienLuong_20120289; drop procedure sp_DanhSachNV20_Hienthi_20120289;
 */
-- Câu 1: Hiển thị tên nhân viên và thu nhập của nhân viên đó trong năm
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE SP_Cau1_ThuNhapNV_20120138(
    CURSOR_ OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN CURSOR_ FOR
        SELECT
            ENAME, SAL*12 + NVL(COMM, 0) AS THUNHAP
        FROM
            EMP_20120138;
    DBMS_SQL.RETURN_RESULT(CURSOR_);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No record found');
        CLOSE CURSOR_;
END;
/

VARIABLE CURSOR_ REFCURSOR;

EXECUTE SP_Cau1_ThuNhapNV_20120138(:CURSOR_);

-- Câu 2: Hiển thị cấu trúc bảng
CREATE OR REPLACE PROCEDURE SP_CauTrucBangEMP_20120138
IS
    CURSOR1 SYS_REFCURSOR;
BEGIN
    OPEN CURSOR1 FOR
        SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, DATA_DEFAULT
        FROM ALL_TAB_COLUMNS 
        WHERE TABLE_NAME='EMP_20120138';
    DBMS_SQL.RETURN_RESULT(CURSOR1);

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No record found');
        CLOSE CURSOR1;
END;
/

EXECUTE SP_CauTrucBangEMP_20120138;

-- Câu 3: Thay đổi nhãn và định dạng hiển thị của cột sal và hiredate trong bảng emp
CREATE OR REPLACE PROCEDURE SP_SalHireDate_20120138 IS
    CURSOR1 SYS_REFCURSOR;
BEGIN
    OPEN CURSOR1 FOR
        SELECT
            EMPNO, ENAME, JOB, MGR, TO_CHAR(HIREDATE, 'dd-mm-yyyy') AS HD, SAL AS SALARY, COMM, DEPTNO
        FROM
            EMP_20120138;
    DBMS_SQL.RETURN_RESULT(CURSOR1);

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No record found');
        CLOSE CURSOR1;
END;
/

EXECUTE SP_SalHireDate_20120138;


--Câu 4: Thông tin nhân viên có mức lương từ 1000 đến 2000
CREATE OR REPLACE 
PROCEDURE sp_DanhSachNVLuong_20120187(cursor_ OUT SYS_REFCURSOR)
AS
BEGIN
  OPEN cursor_ FOR
    SELECT * FROM EMP_20120187 emp WHERE emp.SAL >= 1000 AND emp.SAL <= 2000; 
  dbms_sql.return_result(cursor_);
  EXCEPTION
    when no_data_found then
    dbms_output.put_line('No record found');
  CLOSE cursor_;
END;
/
VARIABLE cursor_ refcursor;
EXEC sp_DanhSachNVLuong_20120187(:cursor_);


--Câu 5: Hiển thị tất cả các nhân viên mà tên bắt đầu bằng ký tự TH hoặc LL
CREATE OR REPLACE 
PROCEDURE sp_DanhSachNV_THLL_20120187(cursor_ OUT SYS_REFCURSOR)
AS
BEGIN
  OPEN cursor_ FOR
    SELECT * FROM EMP_20120187 emp WHERE emp.ENAME LIKE '%TH%' OR  emp.ENAME LIKE '%LL%'; 
  dbms_sql.return_result(cursor_);
  EXCEPTION
    when no_data_found then
    dbms_output.put_line('No record found');
  CLOSE cursor_;
END;
/
VARIABLE cursor_ refcursor;
EXEC sp_DanhSachNV_THLL_20120187(:cursor_);


--Câu 6: Hiển thị tên nhân viên, mã phòng ban, ngày vào làm của nhân viên vào năm 1983
CREATE OR REPLACE 
PROCEDURE sp_DanhSachNV_vao1983_20120187(cursor_ OUT SYS_REFCURSOR)
AS
BEGIN
  OPEN cursor_ FOR
    SELECT emp.ENAME, emp.DEPTNO, emp.HIREDATE FROM EMP_20120187 emp WHERE EXTRACT(YEAR FROM emp.HIREDATE) = 1983;
  dbms_sql.return_result(cursor_);
  EXCEPTION
    when no_data_found then
    dbms_output.put_line('No record found');
  CLOSE cursor_;
END;
/
VARIABLE cursor_ refcursor;
EXEC sp_DanhSachNV_vao1983_20120187(:cursor_);


--Câu 7: Danh sách nhân viên có lương tăng 25% so với lương cũ
CREATE OR REPLACE 
PROCEDURE sp_DanhSachNV_Luongtang15_20120049
IS 
    cursor_ SYS_REFCURSOR;
BEGIN
  OPEN cursor_ FOR
    SELECT emp.ENAME, emp.DEPTNO, emp.SAL * 1.25 AS SAL25 FROM EMP_20120049 emp; 
  dbms_sql.return_result(cursor_);

  EXCEPTION
    when no_data_found then
    dbms_output.put_line('No record found');
    CLOSE cursor_;
END;
/
EXEC sp_DanhSachNV_Luongtang15_20120049;

--Câu 8: Thủ tục hiển thị tên phòng ban và chức vụ
CREATE OR REPLACE
PROCEDURE sp_HienThi_20120049
IS
    emp_name VARCHAR2(20);
    emp_job VARCHAR2(20);
    cursor_ SYS_REFCURSOR;
BEGIN
  OPEN cursor_ FOR
    SELECT emp.ENAME, emp.JOB FROM EMP_20120049 emp; 

  DBMS_OUTPUT.PUT_LINE('EMPLOYEE' ||chr(13)||chr(10));
  LOOP 
    FETCH cursor_ INTO emp_name, emp_job;
    EXIT WHEN cursor_%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(emp_name || ' (' || emp_job || ')');
  END LOOP;

  EXCEPTION
    when no_data_found then
    dbms_output.put_line('No record found');
    CLOSE cursor_;
END;
/
EXEC sp_HienThi_20120049;

--Câu 9: Tìm thông tin về tên nhân viên, ngày gia nhập công ty của nhân viên phòng số 20
CREATE OR REPLACE PROCEDURE sp_DanhSachNV20_Hienthi_20120289
IS
BEGIN
    dbms_output.put_line('ENAME' || '   ' || 'DATE_HIRE');
    DECLARE 
        C_name EMP_20120289.ENAME%type;
        C_hiredate varchar2(30);
    CURSOR C is
    SELECT ENAME, TO_CHAR (HIREDATE, 'month, DDSPTH YYYY') DATE_HIRE
    FROM EMP_20120289
    WHERE DEPTNO = 20;

    BEGIN
        OPEN C;
        LOOP
            FETCH C INTO C_name, C_hiredate;
            EXIT WHEN C%notfound;
            dbms_output.put_line(C_name || '    ' || C_hiredate);
        END LOOP;
        CLOSE C;
    END;
END;
/
EXEC sp_DanhSachNV20_Hienthi_20120289();


--Câu 10: Tìm lương thấp nhất, lớn nhất và lương trung bình của tất cả các nhân viên
CREATE OR REPLACE PROCEDURE sp_DanhSachNhanVienLuong_20120289
IS
    minSal  number;
    maxSal  number;
    avgSal  number(4);
BEGIN

    BEGIN
    SELECT MIN(SAL), MAX(SAL), AVG(SAL)
    INTO minSal, maxSal, avgSal
    FROM EMP_20120289;
    dbms_output.put_line('Min salary: ' || minSal);
    dbms_output.put_line('Max salary: ' || maxSal);
    dbms_output.put_line('Average salary: ' || avgSal);
    END;
END;
/
EXEC sp_DanhSachNhanVienLuong_20120289();