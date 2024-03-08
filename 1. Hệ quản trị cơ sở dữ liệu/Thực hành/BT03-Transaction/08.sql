create database QLTaiKhoan
go
use QLTaiKhoan
go
create table KhachHang
(
	MaKH varchar(10),
	HoTen nvarchar(30),
	NgaySinh datetime,
	CMND varchar(10),
	DiaChi nvarchar(30),
	Constraint PK_KhachHang Primary key(MaKH)
)
create table LoaiTaiKhoan
(
	MaLoai varchar(10),
	TenLoai nvarchar(30),
	Constraint PK_LoaiTaiKhoan Primary key(MaLoai)
)

create table TaiKhoan
(
	MaTK varchar(10),
	NgayLap datetime,
	SoDu int,
	TrangThai nvarchar(30),
	LoaiTK varchar(10),
	MaKH varchar(10),
	Constraint PK_TaiKhoan Primary key(MaTK)
)
create table GiaoDich
(
	MaGD varchar(10),
	MaTK varchar(10),
	SoTien int,
	ThoiGianGD datetime,
	GhiChu nvarchar(30),
	Constraint PK_GiaoDich Primary key(MaGD,MaTK)
)

alter table TaiKhoan
add constraint FK_TaiKhoan_LoaiTaiKhoan foreign key (LoaiTK) references LoaiTaiKhoan(MaLoai)

alter table TaiKhoan
add constraint FK_TaiKhoan_KhachHang foreign key (MaKH) references KhachHang(MaKH)

alter table GiaoDich
add constraint FK_GiaoDich_TaiKhoan foreign key (MaTK) references TaiKhoan(MaTK)

insert into KhachHang values('01234',N'Lê Minh Tiến','2002-10-26','0123456789',N'Phu Tho')
insert into KhachHang values('01235',N'Lê Minh Chiến','2000-10-2','0123456788',N'Nam Định')
insert into KhachHang values('01236',N'Lê Tiến Minh','2002-10-26','0123456789',N'Vũng Tàu')

insert into LoaiTaiKhoan values('00001',N'Vip')
insert into LoaiTaiKhoan values('00002',N'Thường')
insert into LoaiTaiKhoan values('00003',N'Doanh nghiệp')


insert into TaiKhoan values ('10000','2020-10-10',200000,N'Đang dùng','00001','01234')
insert into TaiKhoan values ('10001','2020-10-10',101000,N'Đã khóa','00001','01235')
insert into TaiKhoan values ('10002','2020-10-10',130000,N'Đang dùng','00001','01236')
insert into TaiKhoan values ('10003','2020-10-10',150000,N'Bị hủy','00001','01234')

insert into GiaoDich values ('10000','10000',50000,'2021-10-09 13:21:40',NULL)
insert into GiaoDich values ('10001','10001',50000,'2021-10-08 10:21:40',NULL)
insert into GiaoDich values ('10002','10002',30000,'2021-11-09 13:21:45',NULL)
insert into GiaoDich values ('10003','10003',80000,'2022-10-09 13:21:40',NULL)
go

/*BÀI TẬP TRÊN LỚP*/
/* Phần 1: Số dư tài khoản
Người làm: 20120049 - Nguyễn Hải Đăng*/
create proc SPT_SoDuTaiKhoan(
	@MaTK numeric(18,0)
)
as
begin transaction
	begin try
	if @MaTK not in (select MaTK from TaiKhoan)
		print N'Mã tài khoản ' + cast(@MaTK as nchar(5)) + N' không tồn tại'
		rollback transaction
		return
	end try

	BEGIN CATCH
		PRINT N'Lỗi tra cứu'
		ROLLBACK TRANSACTION
	END CATCH

	declare @TrangThai nchar(10)
	declare @ThongBao nchar(50)
	set @TrangThai = (select TrangThai from TaiKhoan where MaTK = @MaTK) 
	if @TrangThai = N'Đã khóa'
		set @ThongBao = cast(@MaTK as nchar(5)) + N' đã bị khóa' + N' - Số dư tài khoản là ' + cast((select SoDu from TaiKhoan where MaTK = @MaTK) as nchar(10))
	else
	begin
		set @ThongBao = cast(@MaTK as nchar(5)) + ' ' + lower(@TrangThai) + N' - Số dư tài khoản là ' + cast((select SoDu from TaiKhoan where MaTK = @MaTK) as nchar(10))
	end
	print @ThongBao 
	commit transaction
go

exec SoDuTaiKhoan 10001
exec SoDuTaiKhoan 10002
exec SoDuTaiKhoan 10003
exec SoDuTaiKhoan 10006
go
use QLTaiKhoan
go

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

/* Phần 3: Xóa tài khoản
Người làm: 20120624 - Mai Quyết Vang*/
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
go

/* Phần 4: Cập nhật thông tin tài khoản
Người làm: 20120269 - Võ Văn Minh Đoàn*/
CREATE PROC UpdateData 
	@MaTK varchar(10), 
	@NgayLap date, 
	@SoDu bigint, 
	@TrangThai nvarchar(9)
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS(SELECT MaTK FROM TaiKhoan WHERE MaTK = @MaTK)
		BEGIN
			print @MaTK + N' không tồn tại!'
			ROLLBACK TRAN
			RETURN 1
		END
		IF (@NgayLap IS NULL)
		BEGIN
			print N'Ngày lập không hợp lệ!'
			ROLLBACK TRAN
			RETURN 1
		END
		IF (@SoDu <= 100000)
		BEGIN
			print N'Số dư không hợp lệ!'
			ROLLBACK TRAN
			RETURN 1
		END
		IF (@TrangThai != N'Đang dùng' AND @TrangThai != N'Đã khóa' AND @TrangThai != N'Bị hủy')
		BEGIN
			print N'Trạng thái không hợp lệ!'
			ROLLBACK TRAN
			RETURN 1
		END
		UPDATE TaiKhoan
		SET	NgayLap = @NgayLap, SoDu = @SoDu, TrangThai = @TrangThai
		WHERE MaTK = @MaTK
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

/*BÀI TẬP VỀ NHÀ*/
/*Bài 1-2-3-4*/
/*Người làm: 20120269 - Võ Văn Minh Đoàn*/
--1. Thêm công việc
CREATE PROC THEM_CONG_VIEC
	@MADT CHAR(3),
	@SOTT INT,
	@TENCV NVARCHAR(30),
	@NGAYBD DATE,
	@NGAYKT DATE
AS
BEGIN TRAN
	BEGIN TRY
		IF (@MADT = '' OR @SOTT = '' OR @TENCV = '' OR @NGAYBD = '' OR @NGAYKT = '')
		BEGIN
			print N'Thông tin rỗng!'
			ROLLBACK TRAN
			RETURN 1
		END
		IF NOT EXISTS (SELECT * FROM DETAI WHERE MADT = @MADT)
		BEGIN
			print N'Mã đề tài không tồn tại!'
			ROLLBACK TRAN
			RETURN 1
		END
		IF EXISTS (SELECT * FROM CONGVIEC WHERE MADT = @MADT AND SOTT = @SOTT)
		BEGIN
			print N'Thông tin công việc đã tồn tại!'
			ROLLBACK TRAN
			RETURN 1
		END
		IF (@NGAYBD <= (SELECT NGAYBD FROM DETAI WHERE MADT = @MADT) OR @NGAYBD >= (SELECT NGAYKT FROM DETAI WHERE MADT = @MADT))
		BEGIN
			print N'Ngày bắt đầu công việc trước ngày bắt đầu đề tài hoặc sau ngày kết thúc đề tài!'
			ROLLBACK TRAN
			RETURN 1
		END
		INSERT INTO CONGVIEC
		VALUES (@MADT, @SOTT, @TENCV, @NGAYBD, @NGAYKT)
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

--test case
SELECT * FROM CONGVIEC
DECLARE @out int
EXEC @out = THEM_CONG_VIEC '',0,'','',''
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM CONGVIEC

SELECT * FROM CONGVIEC
DECLARE @out int
EXEC @out = THEM_CONG_VIEC '001',2,N'Xác định yêu cầu','03/19/2009','12/20/2010'
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM CONGVIEC

SELECT * FROM CONGVIEC
DECLARE @out int
EXEC @out = THEM_CONG_VIEC '008',2,N'Xác định yêu cầu','03/19/2009','12/20/2010'
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM CONGVIEC

SELECT * FROM CONGVIEC
DECLARE @out int
EXEC @out = THEM_CONG_VIEC '003',3,N'Phân tích hệ thống','05/14/2008','12/20/2010'
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM CONGVIEC

SELECT * FROM CONGVIEC
DECLARE @out int
EXEC @out = THEM_CONG_VIEC '003',3,N'Phân tích hệ thống','05/16/2010','12/20/2010'
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM CONGVIEC

SELECT * FROM CONGVIEC
DECLARE @out int
EXEC @out = THEM_CONG_VIEC '003',3,N'Phân tích hệ thống','05/16/2008','12/20/2010'
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM CONGVIEC

SELECT * FROM CONGVIEC
DECLARE @out int
EXEC @out = THEM_CONG_VIEC '007',3,N'Phân tích hệ thống','05/16/2009','12/20/2010'
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM CONGVIEC
go

--2. Cập nhật công việc
CREATE PROC CAP_NHAT_CONG_VIEC
	@MADT CHAR(3),
	@SOTT INT,
	@TENCV NVARCHAR(30),
	@NGAYBD DATE,
	@NGAYKT DATE
AS
BEGIN TRAN
	BEGIN TRY
		IF (@MADT = '' OR @SOTT = '' OR @TENCV = '' OR @NGAYBD = '' OR @NGAYKT = '')
		BEGIN
			print N'Thông tin rỗng!'
			ROLLBACK TRAN
			RETURN 1
		END
		IF NOT EXISTS (SELECT * FROM CONGVIEC WHERE MADT = @MADT AND SOTT = @SOTT)
		BEGIN
			print N'Thông tin công việc cần cập nhật không tồn tại!'
			ROLLBACK TRAN
			RETURN 1
		END
		IF (@NGAYBD <= (SELECT NGAYBD FROM DETAI WHERE MADT = @MADT) OR @NGAYBD >= (SELECT NGAYKT FROM DETAI WHERE MADT = @MADT))
		BEGIN
			print N'Ngày bắt đầu công việc trước ngày bắt đầu đề tài hoặc sau ngày kết thúc đề tài!'
			ROLLBACK TRAN
			RETURN 1
		END
		IF EXISTS (SELECT * FROM CONGVIEC 
			WHERE MADT = @MADT AND SOTT = @SOTT AND TENCV = @TENCV AND NGAYBD = @NGAYBD AND NGAYKT = @NGAYKT)
		BEGIN
			print N'Thông tin ngoài khóa không có thay đổi so với ban đầu!'
			ROLLBACK TRAN
			RETURN 1
		END
		UPDATE CONGVIEC
		SET TENCV = @TENCV, NGAYBD = @NGAYBD, NGAYKT = @NGAYKT
		WHERE MADT = @MADT AND SOTT = @SOTT
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

--test case
SELECT * FROM CONGVIEC
DECLARE @out int
EXEC @out = CAP_NHAT_CONG_VIEC '',0,'','',''
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM CONGVIEC

SELECT * FROM CONGVIEC
DECLARE @out int
EXEC @out = CAP_NHAT_CONG_VIEC '006',4,N'Thiết kế hệ thống','03/19/2009','12/20/2010'
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM CONGVIEC

SELECT * FROM CONGVIEC
DECLARE @out int
EXEC @out = CAP_NHAT_CONG_VIEC '001',3,N'Phân tích hệ thống','10/19/2007','12/20/2010'
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM CONGVIEC

SELECT * FROM CONGVIEC
DECLARE @out int
EXEC @out = CAP_NHAT_CONG_VIEC '001',3,N'Phân tích hệ thống','10/21/2008','12/20/2010'
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM CONGVIEC

SELECT * FROM CONGVIEC
DECLARE @out int
EXEC @out = CAP_NHAT_CONG_VIEC '001',3,N'Phân tích hệ thống','03/22/2008','05/22/2008'
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM CONGVIEC

SELECT * FROM CONGVIEC
DECLARE @out int
EXEC @out = CAP_NHAT_CONG_VIEC '001',3,N'Phân tích hệ thống','10/19/2008','12/20/2010'
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM CONGVIEC

--3. Xóa công việc
CREATE PROC XOA_CONG_VIEC
	@MADT CHAR(3),
	@SOTT INT
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM CONGVIEC WHERE MADT = @MADT AND SOTT = @SOTT)
		BEGIN
			print N'Thông tin công việc cần xóa không tồn tại!'
			ROLLBACK TRAN
			RETURN 1
		END
		IF EXISTS (SELECT * FROM THAMGIADT WHERE MADT = @MADT AND STT = @SOTT)
		BEGIN
			print N'Thông tin công việc đã được phân công!'
			ROLLBACK TRAN
			RETURN 1
		END
		DELETE FROM CONGVIEC WHERE MADT = @MADT AND SOTT = @SOTT
		IF NOT EXISTS (SELECT * FROM CONGVIEC WHERE MADT = @MADT)
			DELETE FROM DETAI WHERE MADT = @MADT
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

--test case
SELECT * FROM CONGVIEC
DECLARE @out int
EXEC @out = XOA_CONG_VIEC '',0
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM CONGVIEC

SELECT * FROM CONGVIEC
DECLARE @out int
EXEC @out = XOA_CONG_VIEC '002',1
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM CONGVIEC


SELECT * FROM CONGVIEC
DECLARE @out int
EXEC @out = XOA_CONG_VIEC '001',3
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM CONGVIEC

SELECT * FROM CONGVIEC
DECLARE @out int
EXEC @out = XOA_CONG_VIEC '007',3
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM CONGVIEC
SELECT * FROM DETAI


--4. Thêm đề tài
CREATE PROC THEM_DE_TAI
	@MADT CHAR(3),
	@TENDT NVARCHAR(50),
	@CAPQL NVARCHAR(10),
	@KINHPHI DECIMAL(5,1),
	@NGAYBD DATE,
	@NGAYKT DATE,
	@MACD NVARCHAR(4),
	@GVCNDT CHAR(3)
AS
BEGIN TRAN
	BEGIN TRY
		IF (@MADT = '' OR
			@TENDT = '' OR
			@CAPQL = '' OR
			@KINHPHI = '0' OR
			@NGAYBD = '' OR
			@NGAYKT = '' OR
			@MACD = '' OR
			@GVCNDT = '')
		BEGIN
			print N'Thông tin rỗng!'
			ROLLBACK TRAN
			RETURN 1
		END
		IF @MADT IN (SELECT MADT FROM DETAI)
		BEGIN
			print N'Đề tài đã tồn tại!'
			ROLLBACK TRAN
			RETURN 1
		END
		IF (@CAPQL != N'Trường' AND @CAPQL != N'ĐHQG' AND @CAPQL != N'Nhà nước')
		BEGIN
			print N'Cấp quản lí không hợp lệ!'
			ROLLBACK TRAN
			RETURN 1
		END
		IF (@MACD NOT IN (SELECT MACD FROM CHUDE))
		BEGIN
			print N'Mã chủ đề không hợp lệ!'
			ROLLBACK TRAN
			RETURN 1
		END
		IF (@GVCNDT NOT IN (SELECT MAGV FROM GIAOVIEN))
		BEGIN
			print N'Giáo viên chủ nhiệm đề tài không hợp lệ!'
			ROLLBACK TRAN
			RETURN 1
		END
		IF NOT EXISTS (SELECT * FROM BOMON, KHOA WHERE TRUONGBM = @GVCNDT OR TRUONGKHOA = @GVCNDT)
		BEGIN
			print N'Giáo viên chủ nhiệm đề tài không là trưởng bộ môn và trưởng khoa!'
			ROLLBACK TRAN
			RETURN 1
		END
		IF (@CAPQL = N'Trường' AND @KINHPHI >= (SELECT MIN(KINHPHI) FROM DETAI WHERE CAPQL = N'ĐHQG' OR CAPQL = N'Nhà nước'))
		BEGIN
			print N'Cấp quản lí cao hơn nhưng kinh phí thấp hơn hoặc cấp quản lí thấp hơn nhưng kinh phí cao hơn!'
			ROLLBACK TRAN
			RETURN 1
		END
		IF (@CAPQL = N'ĐHQG' AND (@KINHPHI <= (SELECT MAX(KINHPHI) FROM DETAI WHERE CAPQL = N'Trường') 
									OR @KINHPHI >= (SELECT MIN(KINHPHI) FROM DETAI WHERE CAPQL = N'Nhà nước')))
		BEGIN
			print N'Cấp quản lí cao hơn nhưng kinh phí thấp hơn hoặc cấp quản lí thấp hơn nhưng kinh phí cao hơn!'
			ROLLBACK TRAN
			RETURN 1
		END
		IF (@CAPQL = N'Nhà nước' AND @KINHPHI <= (SELECT MAX(KINHPHI) FROM DETAI WHERE CAPQL = N'Trường' OR CAPQL = N'ĐHQG'))
		BEGIN
			print N'Cấp quản lí cao hơn nhưng kinh phí thấp hơn hoặc cấp quản lí thấp hơn nhưng kinh phí cao hơn!'
			ROLLBACK TRAN
			RETURN 1
		END
		INSERT INTO DETAI
		VALUES (@MADT,@TENDT,@CAPQL,@KINHPHI,@NGAYBD,@NGAYKT,@MACD,@GVCNDT)
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

--test case
SELECT * FROM DETAI
DECLARE @out int
EXEC @out = THEM_DE_TAI '','','','0.0','','','',''
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM DETAI

SELECT * FROM DETAI
DECLARE @out int
EXEC  @out = THEM_DE_TAI '001',N'HTTT quản lý các trường CĐ',N'Trường','10.0','10/20/2007','10/20/2008',N'QLGD','003'
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM DETAI

SELECT * FROM DETAI
DECLARE @out int
EXEC  @out = THEM_DE_TAI '008',N'HTTT quản lý các trường CĐ',N'Xã','10.0','10/20/2007','10/20/2008',N'QLGD','003'
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM DETAI

SELECT * FROM DETAI
DECLARE @out int
EXEC  @out = THEM_DE_TAI '008',N'HTTT quản lý các trường CĐ',N'Trường','10.0','10/20/2007','10/20/2008',N'QLCN','003'
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM DETAI

SELECT * FROM DETAI
DECLARE @out int
EXEC  @out = THEM_DE_TAI '008',N'HTTT quản lý các trường CĐ',N'Trường','10.0','10/20/2007','10/20/2008',N'QLGD','011'
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM DETAI

SELECT * FROM DETAI
DECLARE @out int
EXEC  @out = THEM_DE_TAI '009',N'HTTT quản lý các trường CĐ',N'Trường','10.0','10/20/2007','10/20/2008',N'QLGD','010'
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM DETAI

SELECT * FROM DETAI
DECLARE @out int
EXEC  @out = THEM_DE_TAI '009',N'HTTT quản lý các trường CĐ',N'Nhà nước','10.0','10/20/2007','10/20/2008',N'QLGD','002'
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM DETAI

SELECT * FROM DETAI
DECLARE @out int
EXEC  @out = THEM_DE_TAI '009',N'HTTT quản lý các trường CĐ',N'Nhà nước','310.0','10/20/2007','10/20/2008',N'QLGD','002'
print 'OUTPUT: ' + cast(@out as char(1))
SELECT * FROM DETAI
use QLDT
go

/* Bài 2 - Câu 5-6
Người làm: 20120624 - Mai Quyết Vang*/
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

/* Câu 1: Thêm người thân
Người làm: 20120624 - Mai Quyết Vang*/
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

/* Bài 2 - Câu 2-3-4
Người làm: 20120592 - Lê Minh Tiến */
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

/* Bài 2 - Câu 5-6-7
Người làm: 20120049 - Nguyễn Hải Đăng */
-- Cau 5: Insert
/*
	Input: MAGV, MADT, STT, PHUCAP, KETQUA.
	Output: 1 - Them thanh cong, 0 -  Them khong thanh cong.
	- Kiem tra MAGV co ton tai khong.
		+ Neu khong ton tai: xuat thong bao, thoat.
	- Kiem tra MADT kem STT tuong ung co ton tai khong.
		+ Neu khong ton tai: xuat thong bao, thoat.
	- Them de tai.
		+ Ket qua chi co the la DAT hoac NULL, neu khong bao loi, thoat
		+ Neu de tai DAT thi KETQUA = DAT
		+ Nguoc lai KETQUA = NULL
		+ Neu truong @KetQua bo trong thi mac dinh la NULL (khong dat)
*/
create proc SP_ThemThamGiaDT (
	@MAGV char(3),
	@MADT char(3),
	@STT int,
	@PhuCap decimal(2,1),
	@KetQua nvarchar(4) = NULL
)
as
begin tran
	begin try
		if not exists (select * from GIAOVIEN gv where gv.MAGV = @MAGV)
		begin
			print N'Giáo viên không tồn tại'
			rollback transaction
			return 0
		end
		if not exists (select * from CONGVIEC cv where cv.MADT = @MADT and cv.SOTT = @STT)
		begin
			print N'Đề tài và số thứ tự tương ứng không tồn tại'
			rollback transaction
			return 0
		end
		if (@KetQua <> N'Đạt' and @KetQua is not null)
		begin
			print N'Kết quả đề tài không phù hợp'
			rollback transaction
			return 0
		end
	end try

	BEGIN CATCH
		PRINT N'Lỗi thêm tham gia đề tài'
		return 0
		ROLLBACK TRANSACTION
	END CATCH

	insert THAMGIADT values (@MAGV, @MADT, @STT, @PhuCap, @KetQua)
	commit transaction
	return 1
go

exec SP_ThemThamGiaDT '008','001',1,3.0
exec SP_ThemThamGiaDT '008','001',2,3.0,N'Đạt'
exec SP_ThemThamGiaDT '008','001',1,3.0,'aaa'
exec SP_ThemThamGiaDT '012','001',1,3.0,'aaa'
exec SP_ThemThamGiaDT '008','001',10,3.0,'aaa'
go

-- Cau 6: Update
/*
	Input: MAGV, MADT, STT, PhuCapUpdate, KetQuaUpdate.
	Output: 1 - Update thanh cong, 0 -  Update khong thanh cong.
	- Kiem tra input co ton tai trong bang THAMGIADT khong
		+ Neu khong: bao loi thoat
	- Kiem tra MADT kem STT tuong ung co ton tai khong.
		+ Neu khong ton tai: xuat thong bao, thoat.
	- Cap nhat thong tin
		+ Ket qua chi co the la DAT hoac NULL, neu khong bao loi, thoat
		+ Neu truong @KetQuaUpdate bo trong thi mac dinh la NULL (khong dat)
*/
create proc SP_UpdateThamGiaDT (
	@MAGV char(3),
	@MADT char(3),
	@STT int,
	@PhuCapUpdate decimal(2,1),
	@KetQuaUpdate nvarchar(4) = NULL
)
as
begin tran
	begin try
		if not exists (select * from THAMGIADT TGDT where TGDT.MAGV = @MAGV and TGDT.MADT = @MADT and TGDT.STT = @STT)
		begin
			print N'Thông tin tham gia đề tài không tồn tại'
			rollback transaction
			return 0
		end
		if (@KetQuaUpdate <> N'Đạt' and @KetQuaUpdate is not null)
		begin
			print N'Kết quả đề tài không phù hợp'
			rollback transaction
			return 0
		end
	end try

	BEGIN CATCH
		PRINT N'Lỗi cập nhật tham gia đề tài'
		return 0
		ROLLBACK TRANSACTION
	END CATCH

	update THAMGIADT
	set PHUCAP = @PhuCapUpdate, KETQUA = @KetQuaUpdate
	where MAGV = @MAGV and MADT = @MADT and STT = @STT
	commit transaction
	return 1
go

exec SP_UpdateThamGiaDT '008','001',2,2.0,N'Đạt'
exec SP_UpdateThamGiaDT '008','001',2,2.0,'aaa'
go

-- Cau 7: Delete
/*
	Input: MAGV, MADT, STT
	Output: 1 - Delete thanh cong, 0 -  Delete khong thanh cong.
	- Kiem tra input co ton tai trong bang THAMGIADT khong
		+ Neu khong: bao loi thoat
	- Xoa thong tin
*/
create proc SP_XoaThamGiaDT (
	@MAGV char(3),
	@MADT char(3),
	@STT int
)
as
begin tran
	begin try
		if not exists (select * from THAMGIADT TGDT where TGDT.MAGV = @MAGV and TGDT.MADT = @MADT and TGDT.STT = @STT)
		begin
			print N'Thông tin tham gia đề tài không tồn tại'
			rollback transaction
			return 0
		end
	end try

	BEGIN CATCH
		PRINT N'Lỗi xoá tham gia đề tài'
		return 0
		ROLLBACK TRANSACTION
	END CATCH

	DELETE FROM THAMGIADT WHERE MADT = @MADT and MAGV = @MAGV and STT = @STT
	commit transaction
	return 1
go

exec SP_XoaThamGiaDT '008', '001', 1
exec SP_XoaThamGiaDT '008', '001', 3