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

/* Phần 1: Xem số dư tài khoản 
Người làm: 20120049 - Nguyễn Hải Đăng */
create proc SoDuTaiKhoan(
	@MaTK numeric(18,0)
)
as
begin
	if @MaTK not in (select MaTK from TaiKhoan)
		print N'Mã tài khoản ' + cast(@MaTK as nchar(5)) + N' không tồn tại'
	else
	begin
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
	end
end
go

exec SoDuTaiKhoan 10001
exec SoDuTaiKhoan 10002
exec SoDuTaiKhoan 10003
exec SoDuTaiKhoan 10006

/*Phần 2: Thêm tài khoản
Người làm: 20120592 - Lê Minh Tiến */
create proc sp_ThemTaiKhoan
(
	@MaTK varchar(10),
	@NgayLap datetime,
	@SoDu int,
	@TrangThai nvarchar(30),
	@LoaiTK varchar(10),
	@MaKH varchar(10)
)
as
	if(exists(select* from TaiKhoan where @MaTK=MaTK))
	begin 
		print N'Mã tài khoản '+@MaTK+N' đã tồn tại'
		return 0
	end
	else if(@SoDu<100000)
	begin
		print N'Số dư không hợp lệ'
		return 0
	end
	else if(not exists(select* from LoaiTaiKhoan where @LoaiTK=MaLoai))
	begin
		print N'Loại tài khoản '+@LoaiTK+N' không tồn tại'
		return 0
	end
	else if(not exists(select* from KhachHang where @MaKH=MaKH))
	begin 
		print N'Mã khách hàng '+@MaKH+ N' không tồn tại'
		return 0
	end
	else
	begin 
		if(@TrangThai is NULL)
			set @TrangThai=N'Đang dùng'
		insert into TaiKhoan values(@MaTK,@NgayLap,@SoDu,@TrangThai,@LoaiTK,@MaKH)
		print N'Thêm thành công'
		return 1
	end
go

declare @check int
Exec @check=sp_ThemTaiKhoan '10000','2020-10-10',50000,NULL,'00001','01234'
print @check
go

Exec sp_ThemTaiKhoan '20000','2020-10-10',50000, N'Đang dùng','00001','01234'
Exec sp_ThemTaiKhoan '20000','2020-10-10',150000,NULL,'00009','01234'
Exec sp_ThemTaiKhoan '20000','2020-10-10',150000,NULL,'00002','01239'
Exec sp_ThemTaiKhoan '20000','2020-10-10',120000,N'Đã khóa','00001','01234'
Exec sp_ThemTaiKhoan '30000','2020-10-11',140000,N'Đã khóa','00002','01235'
Exec sp_ThemTaiKhoan '50000','2020-10-11',260000,N'Bị hủy','00002','01235'
Exec sp_ThemTaiKhoan '60000','2020-10-10',150000,N'Đang dùng','00001','01234'
Exec sp_ThemTaiKhoan '70000','2020-10-10',200000,NULL,'00001','01234'
Exec sp_ThemTaiKhoan '90000','2020-10-10',150000,N'Bị hủy','00001','01234'

/*Phần 3: Xóa tài khoản
Người làm: 20120624 - Mai Quyết Vang*/
create 
--alter 
proc p_XoaTaiKhoan (@MaTK VARCHAR(10))
AS
	if not exists (select * from TaiKhoan where MaTK = @MaTK)
	begin
		print(N'Mã tài khoản '+@MaTK+N' không tồn tại')
		Return 1
	end
	if exists (select * from GiaoDich where MaTK = @MaTK)
	begin
		print(N'Mã tài khoản '+@MaTK+N' không thể xoá')
		Return 1
	end
	delete from TaiKhoan where MaTK = @MaTK
	return 0
go

declare @out int
exec @out = p_xoaTaiKhoan '10006'
print @out
go

declare @out int
exec @out = p_xoaTaiKhoan '10000'
print @out
go

declare @out int
exec @out = p_xoaTaiKhoan '20000'
print @out
go

/* Phần 4: Cập nhật thông tin tài khoản
Người làm: 20120269 - Võ Văn Minh Đoàn*/
CREATE PROC UpdateData 
	@MaTK varchar(10), 
	@NgayLap date, 
	@SoDu bigint, 
	@TrangThai nvarchar(9)
AS
	DECLARE @check int
	SET @check = 0
	IF (NOT EXISTS(SELECT MaTK FROM TaiKhoan WHERE MaTK = @MaTK))
	BEGIN
		print @MaTK + N' không tồn tại!'
		SET @check = 1
		RETURN @check
	END
	IF (@NgayLap IS NULL)
	BEGIN
		print N'Ngày lập không hợp lệ!'
		SET @check = 1
		RETURN @check
	END
	IF (@SoDu <= 100000)
	BEGIN
		print N'Số dư không hợp lệ!'
		SET @check = 1
		RETURN @check
	END
	IF (@TrangThai != N'Đang dùng' AND @TrangThai != N'Đã khóa' AND @TrangThai != N'Bị hủy')
	BEGIN
		print N'Trạng thái không hợp lệ!'
		SET @check = 1
		RETURN @check
	END
	UPDATE TaiKhoan
	SET	NgayLap = @NgayLap, SoDu = @SoDu, TrangThai = @TrangThai
	WHERE MaTK = @MaTK
	RETURN @check
GO

SELECT * from TaiKhoan
exec UpdateData '10006', '2022-08-09', 82500, N'Bị hủy'
SELECT * from TaiKhoan
go

SELECT * from TaiKhoan
exec UpdateData '10002', '2022-08-09', 82500, N'Bị hủy'
SELECT * from TaiKhoan
go

SELECT * from TaiKhoan
exec UpdateData '10003', NULL, 82500, N'Bị hủy'
SELECT * from TaiKhoan
go

SELECT * from TaiKhoan
exec UpdateData '10000', '2021-10-10', 200500, N'abc'
SELECT * from TaiKhoan
go

SELECT * from TaiKhoan
exec UpdateData '10001', '2021-10-08', 125000, N'Đã khóa'
SELECT * from TaiKhoan
go

SELECT * from TaiKhoan
exec UpdateData '50000', '2021-10-10', 125000, N'Đã khóa'
SELECT * from TaiKhoan
go




