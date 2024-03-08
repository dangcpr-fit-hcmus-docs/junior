/*BÀI TẬP TẠI LỚP*/
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

SELECT * from TaiKhoan
DECLARE @out int
exec @out = UpdateData '10006', '2022-08-09', 82500, N'Bị hủy'
SELECT * from TaiKhoan
print 'OUTPUT: ' + cast(@out as char(1))
go

SELECT * from TaiKhoan
DECLARE @out int
exec @out = UpdateData '10002', '2022-08-09', 82500, N'Bị hủy'
SELECT * from TaiKhoan
print 'OUTPUT: ' + cast(@out as char(1))
go

SELECT * from TaiKhoan
DECLARE @out int
exec @out = UpdateData '10003', NULL, 82500, N'Bị hủy'
SELECT * from TaiKhoan
print 'OUTPUT: ' + cast(@out as char(1))
go

SELECT * from TaiKhoan
DECLARE @out int
exec @out = UpdateData '10000', '2021-10-10', 200500, N'abc'
SELECT * from TaiKhoan
print 'OUTPUT: ' + cast(@out as char(1))
go

SELECT * from TaiKhoan
DECLARE @out int
exec @out = UpdateData '10001', '2021-10-08', 125000, N'Đã khóa'
SELECT * from TaiKhoan
print 'OUTPUT: ' + cast(@out as char(1))
go

SELECT * from TaiKhoan
DECLARE @out int
exec @out = UpdateData '50000', '2021-10-10', 125000, N'Đã khóa'
SELECT * from TaiKhoan
print 'OUTPUT: ' + cast(@out as char(1))
go

/*BÀI TẬP VỀ NHÀ*/
CREATE DATABASE QLDT
GO
USE QLDT
GO

----TẠO BẢNG VÀ KHÓA CHÍNH
CREATE TABLE GIAOVIEN
(
	MAGV CHAR(3),
	HOTEN NVARCHAR(30),
	LUONG DECIMAL(5,1),
	PHAI NVARCHAR(3),
	NGSINH DATE,
	DIACHI NVARCHAR(50),
	GVQLCM CHAR(3),
	MABM NVARCHAR(4)
	CONSTRAINT PK_GIAOVIEN
	PRIMARY KEY(MAGV)
)

CREATE TABLE GV_DT
(
	MAGV CHAR(3),
	DIENTHOAI CHAR(10)
	CONSTRAINT PK_GV_DT
	PRIMARY KEY(MAGV,DIENTHOAI)
)

CREATE TABLE BOMON
(
	MABM NVARCHAR(4),
	TENBM NVARCHAR(20),
	PHONG CHAR(3),
	DIENTHOAI CHAR(10),
	TRUONGBM CHAR(3),
	MAKHOA VARCHAR(4),
	NGAYNHAMCHUC DATE
	CONSTRAINT PK_BOMON
	PRIMARY KEY(MABM)
)

CREATE TABLE KHOA
(
	MAKHOA VARCHAR(4),
	TENKHOA NVARCHAR(20),
	NAMTL INT, 
	PHONG CHAR(3),
	DIENTHOAI CHAR(10),
	TRUONGKHOA CHAR(3),
	NGAYNHANCHUC DATE
	CONSTRAINT PK_KHOA
	PRIMARY KEY(MAKHOA)
)

CREATE TABLE DETAI
(
	MADT CHAR(3),
	TENDT NVARCHAR(50),
	CAPQL NVARCHAR(10),
	KINHPHI DECIMAL(5,1),
	NGAYBD DATE,
	NGAYKT DATE,
	MACD NVARCHAR(4),
	GVCNDT CHAR(3)
	CONSTRAINT PK_DETAI
	PRIMARY KEY(MADT)
)

CREATE TABLE CHUDE
(
	MACD NVARCHAR(4),
	TENCD NVARCHAR(30),
	CONSTRAINT PK_CHUDE
	PRIMARY KEY(MACD)
)

CREATE TABLE CONGVIEC
(
	MADT CHAR(3),
	SOTT INT,
	TENCV NVARCHAR(30),
	NGAYBD DATE,
	NGAYKT DATE
	CONSTRAINT PK_CONGVIEC
	PRIMARY KEY(MADT,SOTT)
)

CREATE TABLE THAMGIADT
(
	MAGV CHAR(3),
	MADT CHAR(3),
	STT INT,
	PHUCAP DECIMAL(2,1),
	KETQUA NVARCHAR(4)
	CONSTRAINT PK_THAMGIADT
	PRIMARY KEY(MAGV,MADT,STT)
)

CREATE TABLE NGUOITHAN
(
	MAGV CHAR(3),
	TEN NVARCHAR(10),
	NGSINH DATE,
	PHAI NVARCHAR(3)
	CONSTRAINT PK_NGUOITHAN
	PRIMARY KEY(MAGV,TEN)
)

----TẠO KHÓA NGOẠI
ALTER TABLE GIAOVIEN
ADD 
CONSTRAINT FK_GIAOVIEN_GIAOVIEN
FOREIGN KEY(GVQLCM)
REFERENCES GIAOVIEN(MAGV)

ALTER TABLE GV_DT
ADD 
CONSTRAINT FK_GV_DT_GIAOVIEN
FOREIGN KEY(MAGV)
REFERENCES GIAOVIEN(MAGV)

ALTER TABLE BOMON
ADD 
CONSTRAINT FK_BOMON_GIAOVIEN
FOREIGN KEY(TRUONGBM)
REFERENCES GIAOVIEN(MAGV)

ALTER TABLE KHOA
ADD
CONSTRAINT FK_KHOA_GIAOVIEN
FOREIGN KEY(TRUONGKHOA)
REFERENCES GIAOVIEN(MAGV)

ALTER TABLE DETAI
ADD
CONSTRAINT FK_DETAI_GIAOVIEN
FOREIGN KEY(GVCNDT)
REFERENCES GIAOVIEN(MAGV)

ALTER TABLE THAMGIADT
ADD
CONSTRAINT FK_THAMGIADT_GIAOVIEN
FOREIGN KEY(MAGV)
REFERENCES GIAOVIEN(MAGV)

ALTER TABLE NGUOITHAN
ADD 
CONSTRAINT FK_NGUOITHAN_GIAOVIEN
FOREIGN KEY(MAGV)
REFERENCES GIAOVIEN(MAGV)

ALTER TABLE GIAOVIEN
ADD 
CONSTRAINT FK_GIAOVIEN_BOMON
FOREIGN KEY(MABM)
REFERENCES BOMON(MABM)

ALTER TABLE BOMON
ADD
CONSTRAINT FK_BOMON_KHOA
FOREIGN KEY(MAKHOA)
REFERENCES KHOA(MAKHOA)

ALTER TABLE THAMGIADT
ADD
CONSTRAINT FK_THAMGIADT_CONGVIEC
FOREIGN KEY(MADT,STT)
REFERENCES CONGVIEC(MADT,SOTT)

ALTER TABLE CONGVIEC
ADD 
CONSTRAINT FK_CONGVIEC_DETAI
FOREIGN KEY(MADT)
REFERENCES DETAI(MADT)

ALTER TABLE DETAI
ADD
CONSTRAINT FK_DETAI_CHUDE
FOREIGN KEY(MACD)
REFERENCES CHUDE(MACD)

----NHẬP DỮ LIỆU
INSERT INTO GIAOVIEN
VALUES('001', N'Nguyễn Hoài An',
		'2000.0', N'Nam',
		'02/15/1973',N'25/3 Lạc Long Quân, Q.10, TP HCM',
		NULL,NULL),
		('002', N'Trần Trà Hương',
		'2500.0', N'Nữ',
		'06/20/1960',N'125 Trần Hưng Đạo, Q.1, TP HCM',
		NULL, NULL),
		('003', N'Nguyễn Ngọc Ánh',
		'2200.0',N'Nữ',
		'05/11/1975',N'12/21 Võ Văn Ngân Thủ Đức, TP HCM',
		NULL,NULL),
		('004',N'Trương Nam Sơn',
		'2300.0', N'Nam',
		'06/20/1959',N'215 Lý Thường Kiệt, TP Biên Hòa',
		NULL, NULL),
		('005',N'Lý Hoàng Hà',
		'2500.0',N'Nam',
		'10/23/1954',N'22/5 Nguyễn Xí, Q.Bình Thạnh, TP HCM',
		NULL,NULL),
		('006',N'Trần Bạch Tuyết',
		'1500.0',N'Nữ',
		'05/20/1980',N'127 Hùng Vương, TP Mỹ Tho',
		NULL,NULL),
		('007',N'Nguyễn An Trung',
		'2100.0',N'Nam',
		'06/05/1976',N'234 3/2, TP Biên Hòa',
		NULL,NULL),
		('008',N'Trần Trung Hiếu',
		'1800.0',N'Nam',
		'08/06/1977',N'22/11 Lý Thường Kiệt, TP Mỹ Tho',
		NULL,NULL),
		('009',N'Trần Hoàng Nam',
		'2000.0',N'Nam',
		'11/22/1975', N'234 Trần Não, An Phú, TP HCM',
		NULL,NULL),
		('010', N'Phạm Nam Thanh',
		'1500.0',N'Nam',
		'12/12/1980',N'221 Hùng Vương, Q.5, TP HCM',
		NULL, NULL)

UPDATE GIAOVIEN
SET GVQLCM ='002'
WHERE MAGV ='003'

UPDATE GIAOVIEN
SET GVQLCM ='004'
WHERE MAGV ='006'

UPDATE GIAOVIEN
SET GVQLCM ='007'
WHERE MAGV ='008'

UPDATE GIAOVIEN
SET GVQLCM ='001'
WHERE MAGV ='009'

UPDATE GIAOVIEN
SET GVQLCM ='007'
WHERE MAGV ='010'

INSERT INTO BOMON
VALUES(N'CNTT',N'Công nghệ tri thức','B15','0838126126',NULL, NULL, NULL),
(N'HHC',N'Hóa hữu cơ','B44','838222222',NULL,NULL,NULL),
(N'HL',N'Hóa lý','B42','0838878787',NULL,NULL,NULL),
(N'HPT',N'Hóa phân tích','B43','0838777777','007',NULL, '10/15/2007'),
(N'HTTT',N'Hệ thống thông tin','B13','0838125125','002',NULL,'09/20/2004'),
(N'MMT',N'Mạng máy tính','B16','0838676767','001',NULL,'05/15/2005'),
(N'SH',N'Sinh hóa','B33','0838898989',NULL,NULL,NULL),
(N'VLĐT',N'Vật lý điện tử','B23','0838234234',NULL,NULL,NULL),
(N'VLƯD',N'Vật lý ứng dụng','B24','0838454545','005',NULL,'02/18/2006'),
(N'VS',N'Vi sinh','B32','0838909090','004',NULL,'01/01/2007')

UPDATE GIAOVIEN
SET MABM = N'MMT'
WHERE MAGV = '001'

UPDATE GIAOVIEN 
SET MABM = N'HTTT'
WHERE MAGV = '002'

UPDATE GIAOVIEN 
SET MABM = N'HTTT'
WHERE MAGV = '003'

UPDATE GIAOVIEN
SET MABM = N'VS'
WHERE MAGV = '004'

UPDATE GIAOVIEN
SET MABM = N'VLĐT'
WHERE MAGV = '005'

UPDATE GIAOVIEN 
SET MABM = N'VS'
WHERE MAGV = '006'

UPDATE GIAOVIEN
SET MABM = N'HPT'
WHERE MAGV = '007'

UPDATE GIAOVIEN
SET MABM = N'HPT'
WHERE MAGV = '008'

UPDATE GIAOVIEN
SET MABM = N'MMT'
WHERE MAGV = '009'

UPDATE GIAOVIEN
SET MABM = N'HPT'
WHERE MAGV = '010'

INSERT INTO KHOA
VALUES('CNTT',N'Công nghệ thông tin', 1995,'B11','0838123456','002','02/20/2005'),
('HH',N'Hóa học',1980,'B41','0838456456','007','10/15/2001'),
('SH',N'Sinh học',1980,'B31','0838454545','004','10/11/2000'),
('VL',N'Vật lý',1976,'B21','0838223223','005','09/18/2003')

UPDATE BOMON
SET MAKHOA = 'CNTT'
WHERE MABM = N'CNTT'

UPDATE BOMON 
SET MAKHOA = 'HH'
WHERE MABM = N'HHC'

UPDATE BOMON 
SET MAKHOA = 'HH'
WHERE MABM = N'HL'

UPDATE BOMON 
SET MAKHOA = 'HH'
WHERE MABM = N'HPT'

UPDATE BOMON 
SET MAKHOA = 'CNTT'
WHERE MABM = N'HTTT'

UPDATE BOMON 
SET MAKHOA = 'CNTT'
WHERE MABM = N'MMT'

UPDATE BOMON 
SET MAKHOA = 'SH'
WHERE MABM = N'SH'

UPDATE BOMON 
SET MAKHOA = 'VL'
WHERE MABM = N'VLĐT'

UPDATE BOMON 
SET MAKHOA = 'SH'
WHERE MABM = N'VS'

UPDATE BOMON 
SET MAKHOA = 'VL'
WHERE MABM = N'VLƯD'
SELECT *FROM GIAOVIEN
SELECT *FROM BOMON
SELECT *FROM KHOA

INSERT INTO CHUDE
VALUES(N'NCPT',N'Nghiên cứu phát triển'),
(N'QLGD',N'Quản lý giáo dục'),
(N'ƯDCN',N'Ứng dụng công nghệ')
SELECT *FROM CHUDE

INSERT INTO DETAI
VALUES('001',N'HTTT quản lý các trường ĐH',N'ĐHQG', '20.0','10/20/2007','10/20/2008',N'QLGD','002'),
('002',N'HTTT quản lý giáo vụ cho một Khoa',N'Trường','20.0','10/12/2000','10/12/2001',N'QLGD','002'),
('003',N'Nghiên cứu chế tạo sợi Nanô Platin',N'ĐHQG','300.0','05/15/2008','05/15/2010',N'NCPT','005'),
('004',N'Tạo vật liệu sinh học bằng mang ối người',N'Nhà nước','100.0','01/01/2007','12/31/2009',N'NCPT','004'),
('005',N'Ứng dụng hóa học xanh',N'Trường','200.0','10/10/2003','12/10/2004',N'ƯDCN','007'),
('006',N'Nghiên cứu tế bào gốc',N'Nhà nước','4000.0','10/20/2006','10/20/2009',N'NCPT','004'),
('007',N'HTTT quản lý thư viện ở các trường ĐH',N'Trường','20.0','05/10/2009','05/10/2010', N'QLGD','001')
SELECT *FROM DETAI

INSERT INTO CONGVIEC
VALUES('001',1,N'Khởi tạo và Lập kế hoạch','10/20/2007','12/20/2008'),
('001',2,N'Xác định yêu cầu','12/21/2008','03/21/2008'),
('001',3,N'Phân tích hệ thống','03/22/2008','05/22/2008'),
('001',4,N'Thiết kế hệ thống','05/23/2008','06/23/2008'),
('001',5,N'Cài đặt thử nghiệm','06/24/2008','10/20/2008'),
('002',1,N'Khởi tạo và Lập kế hoạch','05/10/2009','07/10/2009'),
('002',2,N'Xác định yêu cầu','07/11/2009','10/11/2009'),
('002',3,N'Phân tích hệ thống','10/12/2009','12/20/2009'),
('002',4,N'Thiết kế hệ thống','12/21/2009','03/22/2010'),
('002',5,N'Cài đặt thử nghiệm','03/23/2010','05/10/2010'),
('006',1,N'Lấy mẫu','10/20/2006','02/20/2007'),
('006',2,N'Nuôi cấy','02/21/2007','08/21/2008')
SELECT *FROM CONGVIEC

INSERT INTO THAMGIADT
VALUES('001','002',1,'0.0',NULL),
('001','002',2,'2.0',NULL),
('002','001',4,'2.0',N'Đạt'),
('003','001',1,'1.0',N'Đạt'),
('003','001',2,'0.0',N'Đạt'),
('003','001',4,'1.0',N'Đạt'),
('003','002',2,'0.0',NULL),
('004','006',1,'0.0',N'Đạt'),
('004','006',2,'1.0',N'Đạt'),
('006','006',2,'1.5',N'Đạt'),
('009','002',3,'0.5',NULL),
('009','002',4,'1.5',NULL)
SELECT *FROM THAMGIADT

INSERT INTO GV_DT
VALUES('001','0838912112'),
('001','0903123123'),
('002','0913454545'),
('003','0838121212'),
('003','0903656565'),
('003','0937125125'),
('006','0937888888'),
('008','0653717171'),
('008','0913232323')
SELECT *FROM GV_DT

INSERT INTO NGUOITHAN
VALUES('001',N'Hùng','01/14/1990',N'Nam'),
('001',N'Thủy','12/08/1994',N'Nữ'),
('003',N'Hà','09/03/1998',N'Nữ'),
('003',N'Thu','09/03/1998',N'Nữ'),
('007',N'Mai','03/26/2003',N'Nữ'),
('007',N'Vy','02/14/2000',N'Nữ'),
('008',N'Nam','05/06/1991',N'Nam'),
('009',N'An','08/19/1996',N'Nam'),
('010',N'Nguyệt','01/14/2006',N'Nữ')
SELECT *FROM NGUOITHAN
/*Bài 1*/
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
drop proc THEM_DE_TAI

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