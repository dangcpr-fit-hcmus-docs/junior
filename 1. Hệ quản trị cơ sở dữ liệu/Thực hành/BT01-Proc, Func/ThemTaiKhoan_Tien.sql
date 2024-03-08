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




