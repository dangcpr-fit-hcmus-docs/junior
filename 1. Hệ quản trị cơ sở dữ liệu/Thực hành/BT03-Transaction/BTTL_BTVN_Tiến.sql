--BTTL
/*Phần 2: Thêm tài khoản
Người làm: 20120592 - Lê Minh Tiến */
create proc sp_Bai2
	@MaTK varchar(10),
	@NgayLap datetime,
	@SoDu int,
	@TrangThai nvarchar(30),
	@LoaiTK varchar(10),
	@MaKH varchar(10)
as
begin tran
	begin try
		if(exists(select* from TaiKhoan where @MaTK=MaTK))
		begin 
			print N'Mã tài khoản '+@MaTK+N' đã tồn tại'
			rollback tran
			return 1
		end
		if(@SoDu<100000)
		begin
			print N'Số dư không hợp lệ'
			rollback tran
			return 1
		end
		if(not exists(select* from LoaiTaiKhoan where @LoaiTK=MaLoai))
		begin
			print N'Loại tài khoản '+@LoaiTK+N' không tồn tại'
			rollback tran
			return 1
		end
		if(not exists(select* from KhachHang where @MaKH=MaKH))
		begin 
			print N'Mã khách hàng '+@MaKH+ N' không tồn tại'
			rollback tran
			return 1
		end
		if(@TrangThai is NULL)
		begin
			set @TrangThai=N'Đang dùng'
		end
		insert into TaiKhoan values(@MaTK,@NgayLap,@SoDu,@TrangThai,@LoaiTK,@MaKH)
	end try
	begin catch
		print N'Lỗi hệ thống!'
		rollback tran
		return 1
	end catch
commit tran
return 0
GO

select *from TaiKhoan

declare @check int
Exec @check=sp_Bai2 '10000','2020-10-10',200000,N'Đang dùng','00001','01234'
print 'OUTPUT: ' + cast(@check as char(1))

declare @check int
Exec @check=sp_Bai2 '20000','2020-10-10',2000,N'Đang dùng','00001','01234'
print 'OUTPUT: ' + cast(@check as char(1))

declare @check int
Exec @check=sp_Bai2 '20000','2020-10-10',2000000,N'Đang dùng','99999','01234'
print 'OUTPUT: ' + cast(@check as char(1))

declare @check int
Exec @check=sp_Bai2 '20000','2020-10-10',2000000,NULL,'00001','01234'
print 'OUTPUT: ' + cast(@check as char(1))

declare @check int
Exec @check=sp_Bai2 '20000','2020-10-10',2000000,N'Đang dùng','00001','78945'
print 'OUTPUT: ' + cast(@check as char(1))

select *from TaiKhoan

--BTVN: Lê Minh Tiến Câu 2, 3, 4
--2. Thêm giáo viên
--Mô tả:
--input:các thông tin của giáo viên
--output:0- Thêm thành công 1- Thêm không thành công
--Kiểm tra thông tin nhập không được rỗng
--Kiểm tra mã giáo viên đã tồn tại
--Kiểm tra phái có là nam hoặc nữ
--Kiểm tra gvqlcm có tồn tại
--Kiểm tra mã bộ môn có tồn tại
--Kiểm tra gvqlcm có cùng Bộ môn không
--Thêm giáo viên
CREATE PROC THEM_GIAO_VIEN
	@MAGV CHAR(3),
	@HOTEN NVARCHAR(30),
	@LUONG DECIMAL(5,1),
	@PHAI NVARCHAR(3),
	@NGSINH DATE,
	@DIACHI NVARCHAR(50),
	@GVQLCM CHAR(3),
	@MABM NVARCHAR(4)
AS
	BEGIN TRAN
		BEGIN TRY
			IF(@MAGV='' OR @HOTEN='' OR @LUONG='0' OR @PHAI='' OR @NGSINH='' OR @DIACHI='' OR @GVQLCM='' OR @MABM='')
			BEGIN
				PRINT N'THÔNG TIN RỖNG'
				ROLLBACK TRAN
				RETURN 1
			END
			IF(EXISTS(SELECT* FROM GIAOVIEN WHERE MAGV=@MAGV))
			BEGIN
				PRINT N'MÃ GIÁO VIÊN ĐÃ TỒN TẠI'
				ROLLBACK TRAN
				RETURN 1
			END
			IF(@PHAI NOT LIKE N'NAM' AND @PHAI NOT LIKE N'Nữ')
			BEGIN
				PRINT N'PHÁI CHỈ LÀ NAM HOẶC NỮ'
				ROLLBACK TRAN
				RETURN 1
			END
			IF(NOT EXISTS(SELECT* FROM GIAOVIEN WHERE MAGV=@GVQLCM))
			BEGIN
				PRINT N'MÃ GVQLCM KHÔNG TỒN TẠI'
				ROLLBACK TRAN
				RETURN 1
			END
			IF(NOT EXISTS(SELECT* FROM BOMON WHERE MABM=@MABM))
			BEGIN
				PRINT N'MÃ BỘ MÔN KHÔNG TỒN TẠI'
				ROLLBACK TRAN
				RETURN 1
			END
			IF(@MABM NOT LIKE(SELECT MABM FROM GIAOVIEN WHERE MAGV=@GVQLCM))
			BEGIN
				PRINT N'GVQLCM PHẢI THUỘC VỀ CÙNG MỘT BỘ MÔN'
				ROLLBACK TRAN
				RETURN 1
			END
			INSERT INTO GIAOVIEN VALUES(@MAGV,@HOTEN,@LUONG,@PHAI,@NGSINH,@DIACHI,@GVQLCM,@MABM)
		END TRY
		BEGIN CATCH
			print N'Lỗi hệ thống!'
			ROLLBACK TRAN
			RETURN 1
		END CATCH
COMMIT TRAN
RETURN 0
GO
select *from GiaoVien
declare @out int
Exec @out=THEM_GIAO_VIEN '','','0.0','','','','',''
print 'OUTPUT: ' + cast(@out as char(1))

declare @out int
Exec @out=THEM_GIAO_VIEN '001', N'Nguyễn An','2000.0', N'Nam','02/15/1973',N'25/3 Lạc Long Quân, Q.10, TP HCM',NULL,NULL
print 'OUTPUT: ' + cast(@out as char(1))

declare @out int
Exec @out=THEM_GIAO_VIEN '011', N'Nguyễn An','2000.0', N'A','02/15/1983',N'24,Thanh Ba, Phú Thọ',NULL,NULL
print 'OUTPUT: ' + cast(@out as char(1))

declare @out int
Exec @out=THEM_GIAO_VIEN '011', N'Nguyễn An','2000.0', N'Nam','02/15/1983',N'24,Thanh Ba, Phú Thọ','012',NULL
print 'OUTPUT: ' + cast(@out as char(1))

declare @out int
Exec @out=THEM_GIAO_VIEN '011', N'Nguyễn An','2000.0', N'Nam','02/15/1983',N'24,Thanh Ba, Phú Thọ','012',NULL
print 'OUTPUT: ' + cast(@out as char(1))

declare @out int
Exec @out=THEM_GIAO_VIEN '011', N'Nguyễn An','2000.0', N'Nam','02/15/1983',N'24,Thanh Ba, Phú Thọ','001','VL'
print 'OUTPUT: ' + cast(@out as char(1))

declare @out int
Exec @out=THEM_GIAO_VIEN '011', N'Nguyễn An','2000.0', N'Nam','02/15/1983',N'24,Thanh Ba, Phú Thọ','001','HPT'
print 'OUTPUT: ' + cast(@out as char(1))

declare @out int
Exec @out=THEM_GIAO_VIEN '011', N'Nguyễn An','2000.0', N'Nam','02/15/1983',N'24,Thanh Ba, Phú Thọ','001','MMT'
print 'OUTPUT: ' + cast(@out as char(1))

select* from GiaoVien

--3.Cập nhật trưởng bộ môn
--Mô tả:
--input: Mã bộ môn cần cập nhật,Mã trưởng bộ môn 
--output:0- Thêm thành công 1- Thêm không thành công
--Kiểm tra thông tin nhập không được rỗng
--Kiểm tra mã bộ môn có tồn tại
--Kiểm tra mã trưởng bộ môn mới có tồn tại
--Kiểm tra mã trưởng bộ môn mới có trùng mã cũ
--Kiểm tra trưởng bộ môn mới có thuộc bộ môn
--update thông tin

create proc Cap_nhat_truong_BM
	@MaBM NVARCHAR(4),
	@TruongBM CHAR(3)
as
	begin tran
		begin try
			if(@MaBM='' or @TruongBM='')
			begin
				print N'Thông tin rỗng'
				rollback tran
				return 1
			end
			if(not exists(select* from BoMon where MaBM=@MaBM))
			begin
				print N'Mã bộ môn không tồn tại'
				rollback tran
				return 1
			end
			if(not exists(select* from GiaoVien where MaGV=@TruongBM))
			begin
				print N'Mã trưởng bộ môn mới không tồn tại'
				rollback tran
				return 1
			end
			if(@TruongBM like (select TruongBM from BoMon where MaBM=@MaBM))
			begin
				print N'Mã trưởng bộ môn mới trùng với mã cũ'
				rollback tran
				return 1
			end
			if(@MaBM not like (select MaBM from GiaoVien where MaGV=@TruongBM))
			begin
				print N'Trưởng bộ môn phải thuộc bộ môn này'
				rollback tran
				return 1
			end
			update BoMon
			set TruongBM=@TruongBM
			where MaBM=@MaBM
		end try
		begin catch
			print N'Lỗi hệ thống!'
			ROLLBACK TRAN
			RETURN 1
		END CATCH
COMMIT TRAN
RETURN 0
GO
select* from BoMon
declare @out int
Exec @out=Cap_nhat_truong_BM 'TOAN','001'
print 'OUTPUT: ' + cast(@out as char(1))

declare @out int
Exec @out=Cap_nhat_truong_BM 'MMT','013'
print 'OUTPUT: ' + cast(@out as char(1))

declare @out int
Exec @out=Cap_nhat_truong_BM 'MMT','001'
print 'OUTPUT: ' + cast(@out as char(1))

declare @out int
Exec @out=Cap_nhat_truong_BM 'MMT','002'
print 'OUTPUT: ' + cast(@out as char(1))

declare @out int
Exec @out=Cap_nhat_truong_BM 'MMT','009'
print 'OUTPUT: ' + cast(@out as char(1))

select* from BoMon
select* from GiaoVien



--4.Cập nhật chủ nhiệm đề tài
--Mô tả:
--input: Mã đề tài, mã chủ nhiệm đề tài
--output:0- Thêm thành công 1- Thêm không thành công
--Kiểm tra thông tin nhập không được rỗng
--Kiểm tra mã đề tài có tồn tại
--Kiểm tra mã chủ nhiệm đề tài mới có tồn tại
--Kiểm tra mã chủ nhiệm đề tài mới có trùng mã cũ
--update chủ nhiệm đề tài

select* from DeTai
select* from ThamGiaDT
create proc Cap_Nhat_Chu_Nhiem_DT
	@MaDT char(3),
	@GVCNDT char(3)
as
	begin tran
		begin try
			if(@MaDT='' or @GVCNDT='')
			begin
				print N'Thông tin rỗng'
				rollback tran
				return 1
			end
			if(not exists(select* from DeTai where MaDT=@MaDT))
			begin
				print N'Mã đề tài không tồn tại'
				rollback tran
				return 1
			end
			if(not exists(select* from GiaoVien where MaGV=@GVCNDT))
			begin
				print N'Mã giáo viên không tồn tại'
				rollback tran
				return 1
			end
			if(@GVCNDT like (select GVCNDT from DeTai where MaDT=@MaDT))
			begin
				print N'Mã giáo viên chủ nhiệm mới trùng với mã cũ'
				rollback tran
				return 1
			end
			update DeTai
			set GVCNDT=@GVCNDT
			where MaDT=@MaDT
		end try
		begin catch
			print N'Lỗi hệ thống!'
			ROLLBACK TRAN
			RETURN 1
		END CATCH
COMMIT TRAN
RETURN 0
GO
select* from DeTai
select* from ThamGiaDT
declare @out int
Exec @out=Cap_Nhat_Chu_Nhiem_DT '',''
print 'OUTPUT: ' + cast(@out as char(1))

declare @out int
Exec @out=Cap_Nhat_Chu_Nhiem_DT '010','002'
print 'OUTPUT: ' + cast(@out as char(1))

declare @out int
Exec @out=Cap_Nhat_Chu_Nhiem_DT '001','013'
print 'OUTPUT: ' + cast(@out as char(1))

declare @out int
Exec @out=Cap_Nhat_Chu_Nhiem_DT '001','002'
print 'OUTPUT: ' + cast(@out as char(1))

declare @out int
Exec @out=Cap_Nhat_Chu_Nhiem_DT '001','003'
print 'OUTPUT: ' + cast(@out as char(1))

declare @out int
Exec @out=Cap_Nhat_Chu_Nhiem_DT '001',NULL
print 'OUTPUT: ' + cast(@out as char(1))