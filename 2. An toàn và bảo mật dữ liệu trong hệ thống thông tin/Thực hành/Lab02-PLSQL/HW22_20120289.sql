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
    
EXEC sp_DanhSachNhanVienLuong_20120289();

--drop procedure sp_DanhSachNhanVienLuong_20120289; drop procedure sp_DanhSachNV20_Hienthi_20120289;