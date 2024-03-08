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
