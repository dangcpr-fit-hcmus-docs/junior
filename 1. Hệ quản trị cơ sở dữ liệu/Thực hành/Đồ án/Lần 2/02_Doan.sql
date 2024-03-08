CREATE DATABASE GIAONHANHANG
GO
USE GIAONHANHANG
GO

CREATE TABLE NHANVIEN
(
	MaNV varchar(10),
	HoTen nvarchar(30),
	Primary key(MaNV)
)

CREATE TABLE DOITAC
(
	MaDT varchar(10),
	Email varchar(30),
	NgDaiDien nvarchar(30),
	SLChiNhanh smallint,
	TenQuan nvarchar(30),
	LoaiTP nvarchar(30),
	Primary key(MaDT)
)

CREATE TABLE HOPDONG
(
	MaHD varchar(10),
	NgDaiDien nvarchar(30),
	SLChiNhanh smallint,
	SoTaiKhoan varchar(20),
	NganHang nvarchar(30),
	CNNganHang nvarchar(30),
	MaSoThue varchar(13),
	NgayKy date,
	ThoiHan nvarchar(10),
	NgayHetHan date,
	MaDT varchar(10),
	MaNV varchar(10)
	Primary key(MaHD),
	Foreign key(MaDT) references DOITAC(MaDT),
	Foreign key(MaNV) references NHANVIEN(MaNV)
)

CREATE TABLE CHINHANH
(
	STT int,
	MaDT varchar(10),
	TP nvarchar(30),
	Quan nvarchar(30),
	DiaChiCuThe nvarchar(50),
	SDT	char(10),
	TinhTrang nvarchar(30),
	Primary key(STT,MaDT),
	Foreign key(MaDT) references DOITAC(MaDT)
)

CREATE TABLE THUCPHAM
(
	MaTP varchar(10),
	MaDT varchar(10),
	TenMon nvarchar(30),
	MieuTa nvarchar(50),
	Gia decimal(10,1),
	TinhTrang nvarchar(30),
	TuyChon nvarchar(50),
	Primary key(MaTP,MaDT),
	Foreign key (MaDT) references DOITAC(MaDT)
)

CREATE TABLE KHACHHANG
(
	MaKH varchar(10),
	HoTen nvarchar(30),
	DiaChi nvarchar(100),
	SDT char(10),
	Email varchar(30),
	Primary key(MaKH)
)

CREATE TABLE TAIXE
(
	MaTX varchar(10),
	CMND varchar(12),
	HoTen nvarchar(30),
	SDT char(10),
	DiaChi nvarchar(100),
	BienSoXe varchar(10),
	KhuVucHoatDong nvarchar(30),
	Email varchar(30),
	SoTaiKhoan varchar(20),
	NganHang nvarchar(30),
	CNNganHang nvarchar(30),
	Primary key(MaTX)
)

CREATE TABLE DONDATHANG
(
	MaDH varchar(10),
	GioDat varchar(6),
	NgayDat date,
	GiaTriDH decimal(10,1),
	TinhTrang nvarchar(30),
	MaKH varchar(10),
	MaTX varchar(10),
	Primary key(MaDH),
	Foreign key(MaKH) references KHACHHANG(MaKH),
	Foreign key(MaTX) references TAIXE(MaTX)
)

CREATE TABLE CHITIETDONDATHANG
(
	MaDH varchar(10),
	MaTP varchar(10),
	MaDT varchar(10),
	SoLuong int,
	DanhGia nvarchar(100),
	Primary key(MaDH,MaTP,MaDT),
	Foreign key(MaDH) references DONDATHANG(MaDH),
	Foreign key(MaTP,MaDT) references THUCPHAM(MaTP,MaDT)
)

CREATE PROC TimKiemNhanVien
	@MaNV varchar(10)
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM NHANVIEN WHERE MaNV = @MaNV)
		BEGIN
			Print @MaNV + N' không tồn tại!'
			ROLLBACK TRAN
		END
		SELECT * FROM NHANVIEN WHERE MaNV = @MaNV
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO

CREATE PROC TimKiemDoiTac
	@MaDT varchar(10)
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM DOITAC WHERE MaDT = @MaDT)
		BEGIN
			Print @MaDT + N' không tồn tại!'
			ROLLBACK TRAN
		END
		SELECT * FROM DOITAC WHERE MaDT = @MaDT
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO

CREATE PROC TimKiemHopDong
	@MaHD varchar(10)
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM HOPDONG WHERE MaHD = @MaHD)
		BEGIN
			Print @MaHD + N' không tồn tại!'
			ROLLBACK TRAN
		END
		SELECT * FROM HOPDONG WHERE MaHD = @MaHD
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO

CREATE PROC TimKiemChiNhanh
	@STT int,
	@MaDT varchar(10)
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM CHINHANH WHERE STT = @STT AND MaDT = @MaDT)
		BEGIN
			Print N'STT: ' + @STT + N', MaDT: ' + @MaDT + N' không tồn tại!'
			ROLLBACK TRAN
		END
		SELECT * FROM CHINHANH WHERE STT = @STT AND MaDT = @MaDT
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO

CREATE PROC TimKiemThucPham
	@MaTP varchar(10),
	@MaDT varchar(10)
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM THUCPHAM WHERE MaTP = @MaTP AND MaDT = @MaDT)
		BEGIN
			Print N'MaTP: ' + @MaTP + N', MaDT: ' + @MaDT + N' không tồn tại!'
			ROLLBACK TRAN
		END
		SELECT * FROM THUCPHAM WHERE MaTP = @MaTP AND MaDT = @MaDT
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO

CREATE PROC TimKiemKhachHang
	@MaKH varchar(10)
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM KHACHHANG WHERE MaKH = @MaKH)
		BEGIN
			Print @MaKH + N' không tồn tại!'
			ROLLBACK TRAN
		END
		SELECT * FROM KHACHHANG WHERE MaKH = @MaKH
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO

CREATE PROC TimKiemTaiXe
	@MaTX varchar(10)
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM TAIXE WHERE MaTX = @MaTX)
		BEGIN
			Print @MaTX + N' không tồn tại!'
			ROLLBACK TRAN
		END
		SELECT * FROM TAIXE WHERE MaTX = @MaTX
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO

CREATE PROC TimKiemDonDatHang
	@MaDH varchar(10)
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM DONDATHANG WHERE MaDH = @MaDH)
		BEGIN
			Print @MaDH + N' không tồn tại!'
			ROLLBACK TRAN
		END
		SELECT * FROM DONDATHANG WHERE MaDH = @MaDH
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO

CREATE PROC TimKiemChiTietDonDatHang
	@MaDH varchar(10),
	@MaTP varchar(10),
	@MaDT varchar(10)
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM CHITIETDONDATHANG WHERE MaDH = @MaDH AND MaTP = @MaTP AND MaDT = @MaDT)
		BEGIN
			Print N'MaTP: ' + @MaTP + N', MaDT: ' + @MaDT + N' không tồn tại!'
			ROLLBACK TRAN
		END
		SELECT * FROM CHITIETDONDATHANG WHERE MaDH = @MaDH AND MaTP = @MaTP AND MaDT = @MaDT
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO