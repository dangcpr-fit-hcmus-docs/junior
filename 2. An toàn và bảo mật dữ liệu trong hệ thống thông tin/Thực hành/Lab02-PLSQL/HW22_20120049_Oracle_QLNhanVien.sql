--Họ và tên: Nguyễn Hải Đăng
--MSSV: 20120049

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
--drop procedure sp_DanhSachNV_Luongtang15_20120049; drop procedure sp_HienThi_20120049;
