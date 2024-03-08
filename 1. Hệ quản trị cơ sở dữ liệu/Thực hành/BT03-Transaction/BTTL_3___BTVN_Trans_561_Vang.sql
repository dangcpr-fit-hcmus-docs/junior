use QLTaiKhoan
go

if OBJECT_ID ( N'usp_XoaTaiKhoan', N'P' ) IS not NULL   
    DROP PROCEDURE usp_XoaTaiKhoan;  
	go  

create -- alter 
PROC usp_XoaTaiKhoan 
	@MaTK varchar(10)
as
begin tran
	begin try
		if not exists(select * from TaiKhoan where MaTK = @MaTK)
		begin
			print @MaTK + N' không tồn tại!'
			rollback tran
			return 1
		end
		if exists(select * from GiaoDich where @MaTK = MaTK)
		begin
			print N'Tài khoản đã thực hiện giao dịch không thể xoá'
			rollback tran
			return 1
		end
		delete from TaiKhoan where MaTK = @MaTK
	end try
	begin catch
		print N'Lỗi hệ thống!'
		rollback tran
		return 1
	end catch
commit tran
print N'Its cù lao time!'
return 0
go


-- test1
select * from TaiKhoan
DECLARE @out int
EXEC @out = usp_XoaTaiKhoan '10009'
print @out
select * from TaiKhoan

-- test2
insert into TaiKhoan values ('10009',getdate(), 5000000,'','00001','01234')
insert into GiaoDich values ('99999','10009',9999,getdate(), '')
go
select * from TaiKhoan
DECLARE @out int
EXEC @out = usp_XoaTaiKhoan '10009'
print @out
select * from TaiKhoan
go
delete  from GiaoDich where MaGD = '99999'



-- BTVN
-- 20120624-Mai Quyết Vang
use HQTCSDL_QLDT
go
--5. Cập nhật đề tài 
if OBJECT_ID ( N'usp_CapNhatDeTai', N'P' ) IS not NULL   
    DROP PROCEDURE usp_CapNhatDeTai;  
go  

create -- alter
proc usp_CapNhatDeTai
		@MADT CHAR(3),
		@TENDT NVARCHAR(50),
		@CAPQL NVARCHAR(10),
		@KINHPHI DECIMAL(5,1),
		@NGAYBD DATE,
		@NGAYKT DATE,
		@MACD NVARCHAR(4),
		@GVCNDT CHAR(3)
as
begin transaction
	begin try
		-- Kiểm tra thông tin nhập không đượcc rỗng.
		if (@MADT	= '' or	
			@TENDT	 = '' or
			@CAPQL	= '' or	
			@KINHPHI = '0' or
			@NGAYBD = '' or
			@NGAYKT	 = '' or
			@MACD	= '' or	
			@GVCNDT	 = '')
			begin
				print N'Thông tin nhập không được rỗng'
				rollback tran
				return 1
			end
		-- Kiểm tra thông tin nhập hợp lệ. 
		if (@CAPQL <> N'Trường' and @CAPQL <> N'ĐHQG'and @CAPQL <> N'Nhà nước')
			begin
				print N'Thông tin cấp quản lý không hợp lệ'
				rollback tran
				return 1
			end
		if (@KINHPHI < 0)
			begin
				print(N'Kinh phí phải lớn hơn 0')
				rollback tran
				return 1
			end
		if (@NGAYBD > @NGAYKT)
			begin
				print(N'Ngày bắt đầu phải nhỏ hơn ngày kết thúc')
				rollback tran
				return 1
			end
		if (@MACD != N'QLGD' and @MACD != N'NCPT'and @MACD != N'ƯDCN')
			begin
				print(N'Thông tin mã chủ đề không hợp lệ')
				rollback tran
				return 1
			end
		-- Kiếm tra thông tin đầu vào tồn tại
		if not exists (select * from DETAI where @MADT = MADT)
			begin
				print(N'Mã đề tài không tồn tại')
				rollback tran
				return 1
			end
		if not exists (select * from GIAOVIEN where @GVCNDT = MAGV)
			begin
				print(N'Thông tin GVCNDT không tồn tại')
				rollback tran
				return 1
			end
		-- GVCNDT phải là trưởng bộ môn hoặc trưởng khoa
		if not exists (select * from KHOA where @GVCNDT = TRUONGKHOA) and 
			not exists (select * from BOMON where @GVCNDT = TRUONGBM)
			begin
				print(N'GVCNDT phải là trưởng bộ môn hoặc trưởng khoa')
				rollback tran
				return 1
			end
		-- Cấp quản lí cao hơn thì kinh phí cho đề tài phải cao hơn
		if (@CAPQL = N'Trường' and @KINHPHI >= (select MIN(KINHPHI) from DETAI where CAPQL = N'ĐHQG' or CAPQL = N'Nhà nước'))
			begin
				print N'Cấp quản lí cao hơn nhưng kinh phí thấp hơn hoặc cấp quản lí thấp hơn nhưng kinh phí cao hơn!'
				rollback tran
				return 1
			end
		if (@CAPQL = N'ĐHQG' and (@KINHPHI <= (select MAX(KINHPHI) from DETAI where CAPQL = N'Trường') 
			or @KINHPHI >= (select MIN(KINHPHI) from DETAI where CAPQL = N'Nhà nước')))
			begin
				print N'Cấp quản lí cao hơn nhưng kinh phí thấp hơn hoặc cấp quản lí thấp hơn nhưng kinh phí cao hơn!'
				rollback tran
				return 1
			end
		if (@CAPQL = N'Nhà nước' and @KINHPHI <= (select MAX(KINHPHI) from DETAI where CAPQL = N'Trường' or CAPQL = N'ĐHQG'))
			begin
				print N'Cấp quản lí cao hơn nhưng kinh phí thấp hơn hoặc cấp quản lí thấp hơn nhưng kinh phí cao hơn!'
				rollback tran
				return 1
			end

		update DETAI set 
				TENDT = @TENDT, 
				CAPQL = @CAPQL, 
				KINHPHI = @KINHPHI, 
				NGAYBD = @NGAYBD, 
				NGAYKT = @NGAYKT, 
				MACD = @MACD, 
				GVCNDT = @GVCNDT
				where MADT = @MADT
	end try

	begin catch
		print N'Lỗi hệ thống!'
		rollback tran
		return 1
	end catch
commit tran
return 0
go


-- test 1
DECLARE @out int
EXEC @out = usp_CapNhatDeTai '','','',0,'','','',''
print @out
select * from DETAI
go

-- test 2
DECLARE @out int
EXEC @out = usp_CapNhatDeTai '006',N'Nghiên cứu tế bào gốc',N'Nhà nước','4000.0','2006/10/20','2009/10/20',N'NCPT','003'
print @out
select * from DETAI
go

-- test 3
DECLARE @out int
EXEC @out = usp_CapNhatDeTai '006',N'Nghiên cứu tế bào gốc',N'Nhà nước','4000.0','2006/10/20','2009/10/20',N'NCPT','004'
print @out
select * from DETAI
go


-- 6. Xoá đề tài
if OBJECT_ID ( N'usp_1_6_XoaDeTai', N'P' ) IS not NULL   
    DROP PROCEDURE usp_1_6_XoaDeTai;  
go  
create -- alter
proc usp_1_6_XoaDeTai
		@MADT CHAR(3)
as
begin transaction
	begin try
		-- Kiểm tra thông tin nhập không đượcc rỗng.
		if (@MADT = '')
			begin
			print(N'Thông tin nhập không được rỗng')
			rollback tran
			return 1
			end
		-- Kiếm tra thông tin đầu vào tồn tại
		if not exists (select * from DETAI where @MADT = MADT)
			begin
			print(N'Mã đề tài không tồn tại')
			rollback tran
			return 1
			end
		-- Kiểm tra đề tài chưa có tham gia. 
		if exists (select * from THAMGIADT where MADT = @MADT)
			begin
			print(N'Mã đề tài đã có tham gia')
			rollback tran
			return 1
			end
		-- Kiểm tra đề tài chưa kết thúc
		if exists (select * from CONGVIEC where MADT = @MADT and NGAYKT > GETDATE())
			begin
			print(N'Đề tài chưa còn công việc chưa kết thúc')
			rollback tran
			return 1
			end
		delete from  DETAI where MADT = @MADT
	end try

	begin catch
		print N'Lỗi hệ thống!'
		rollback tran
		return 1
	end catch	
commit transaction

return 0
go
--Test 1
declare @out int
exec @out = usp_1_6_XoaDeTai ''
print @out
go
--Test 2
declare @out int
exec @out = usp_1_6_XoaDeTai '001'
print @out
go
--Test 3
INSERT INTO DETAI
VALUES('008',N'HTTT quản lý các trường ĐH',N'ĐHQG', '20.0','10/20/2007','10/20/2008',N'QLGD','002')
declare @out int
exec @out = usp_1_6_XoaDeTai '008'
print @out
go
select * from DETAI
go

-- Bài 2 
-- 1. Thêm người thân
-- Mô tả
-- Input: thông tin người thân
-- Output: 0 - Xoá thành công. 1 - Xoá không thành công
		-- Kiểm tra thông tin nhập không đượcc rỗng.
		-- Kiểm tra thông tin đầu vào tồn tại
		-- Kiểm tra thông tin nhập hợp lệ
		-- Thêm người thân

create -- alter
proc usp_2_1_ThemNguoiThan
	@MAGV CHAR(3),
	@TEN NVARCHAR(10),
	@NGSINH DATE,
	@PHAI NVARCHAR(3)
as
begin transaction
	begin try
		-- Kiểm tra thông tin nhập không được rỗng.
		if (@MAGV = '' or
			@TEN = '' or
			@NGSINH = '' or
			@PHAI = '')
			begin
			print(N'Thông tin nhập không được rỗng')
			rollback tran
			return 1
			end
		-- Kiểm tra thông tin đầu vào tồn tại
		if not exists (select * from GIAOVIEN where @MAGV = MAGV)
			begin
			print(N'Mã giáo viên không tồn tại')
			rollback tran
			return 1
			end
		if exists (select * from NGUOITHAN where @TEN = TEN and @MAGV = MAGV)
			begin
			print(N'Giáo viên '+ @MAGV + N' đã có người thân với tên ' + @TEN)
			rollback tran
			return 1
			end
		-- Kiểm tra thông tin nhập hợp lệ
		if (@PHAI <> N'Nam' and @PHAI <> N'Nữ')
			begin
			print(N'Giới tính phải là Nam hoặc Nữ')
			rollback tran
			return 1
			end
		-- Thêm người thân
		insert into NGUOITHAN values (@MAGV,@TEN,@NGSINH,@PHAI)

	end try
	begin catch
		print N'Lỗi hệ thống'
		rollback tran
		return 1
	end catch
commit transaction
return 0
go

-- test 1
declare @out int
exec @out = usp_2_1_ThemNguoiThan '','Vang', '2002-04-15' ,'Nam' 
print @out
go

-- test 2
declare @out int
exec @out = usp_2_1_ThemNguoiThan '000','Hùng', '2002-04-15' ,'Nam' 
print @out
go

-- test 3
declare @out int
exec @out = usp_2_1_ThemNguoiThan '001','Hùng', '2002-04-15' ,'Nam' 
print @out
go

-- test 
declare @out int
exec @out = usp_2_1_ThemNguoiThan '002','Vang', '2002-04-15' ,'Nan' 
print @out
go