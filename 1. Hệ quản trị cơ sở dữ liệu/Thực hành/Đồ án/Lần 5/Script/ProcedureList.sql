USE [GIAONHANHANG]
GO
/****** Object:  UserDefinedFunction [dbo].[DemSoLuongBan]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[DemSoLuongBan](@MaTP varchar(10), @MaDT varchar(10))
returns int
as
begin
	declare @out int
	set @out = (select (SUM(SoLuong+0)) from CHITIETDONDATHANG ct where ct.MaTP = @MaTP and ct.MaDT = @MaDT)
	if @out is null
		set @out = 0
	return @out
end	
GO
/****** Object:  StoredProcedure [dbo].[Block_Unblock]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Block_Unblock]
	@Username varchar(20)
AS
BEGIN TRAN Block_Unblock
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM USERS WHERE Username = @Username)
		BEGIN
			Print @Username + N' không tồn tại!'
			SELECT 1
			ROLLBACK TRAN Block_Unblock
		END
		IF (SELECT TrangThai FROM USERS WHERE Username = @Username) = N'Bị khóa'
		BEGIN
			UPDATE USERS
			SET TrangThai = N'Hoạt động'
			WHERE Username = @Username
			SELECT 2
		END
		ELSE IF (SELECT TrangThai FROM USERS WHERE Username = @Username) = N'Hoạt động'
		BEGIN
			UPDATE USERS
			SET TrangThai = N'Bị khóa'
			WHERE Username = @Username
			SELECT 3
		END
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN Block_Unblock
	END CATCH
COMMIT TRAN Block_Unblock

GO
/****** Object:  StoredProcedure [dbo].[capNhatDoiTac]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*Xử lý tranh chấp 2 - Conversion Deadlock*/
--Giải quyết tranh chấp bằng cách thiết lập update lock thay vì shared lock cho câu lệnh select do tại mỗi thời điểm chỉ được phát 1 update lock trên 1 đơn vị dữ liệu
--Người làm: 20120269 - Võ Văn Minh Đoàn
--T1: cập nhật thông tin đối tác
--T2: xóa đối tác

--T1
create proc [dbo].[capNhatDoiTac]
	@MaDT varchar(10),
	@Email varchar(30),
	@NgDaiDien nvarchar(30),
	@SLChiNhanh smallint,
	@TenQuan nvarchar(30),
	@LoaiTP nvarchar(30)
as
begin tran capNhatDoiTac
	set tran isolation level serializable
	-- Kiểm tra thông tin rỗng
	if (@MaDT='' or @Email='' or @NgDaiDien=''  or @TenQuan='' or @LoaiTP='')
	begin 
		print N'Thông tin trống'
		rollback tran capNhatDoiTac
		return 1
	end
	-- Kiểm tra mã đối tác đã tồn tại chưa
	-- Thiết lập update lock thay vì shared lock khi đọc
	if not exists(select* from DoiTac with (updlock) where MaDT=@MaDT)
	begin
		print N'Mã đối tác chưa tồn tại'
		rollback tran capNhatDoiTac
		return 1
	end
	waitfor delay '0:0:10'
	update DOITAC
	set Email = @Email,NgDaiDien = @NgDaiDien,SLChiNhanh = @SLChiNhanh,TenQuan = @TenQuan,LoaiTP = @LoaiTP
	where MaDT = @MaDT
commit tran capNhatDoiTac
return 0
GO
/****** Object:  StoredProcedure [dbo].[CapNhatNhanVien]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[CapNhatNhanVien]
	@MaNV varchar(10),
	@HoTen nvarchar(30),
	@Username varchar(20)
AS
BEGIN TRAN CapNhatNhanVien
	BEGIN TRY
		DECLARE @OldUsername varchar(20)
		SET @OldUsername = (Select Username from NHANVIEN where MaNV = @MaNV)
		IF NOT EXISTS (SELECT * FROM NHANVIEN WHERE MaNV = @MaNV)
		BEGIN
			Print N'Nhân viên không tồn tại!'
			Select 1
			ROLLBACK TRAN CapNhatNhanVien
		END
		IF EXISTS (SELECT * FROM USERS WHERE Username != @OldUsername AND Username = @Username)
		BEGIN
			Print N'Username mới đã tồn tại!'
			Select 2
			ROLLBACK TRAN CapNhatNhanVien
		END
		Update NHANVIEN
		SET Username = null
		where MaNV = @MaNV
		Update USERS
		SET Username = @Username
		where Username = @OldUsername
		Update NHANVIEN
		SET HoTen = @HoTen, Username = @Username
		where MaNV = @MaNV
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN CapNhatNhanVien
	END CATCH
COMMIT TRAN CapNhatNhanVien
Select 0

GO
/****** Object:  StoredProcedure [dbo].[CapNhatQuanTri]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[CapNhatQuanTri]
	@MaQT varchar(10),
	@HoTen nvarchar(30),
	@Username varchar(20)
AS
BEGIN TRAN CapNhatQuanTri
	BEGIN TRY
		DECLARE @OldUsername varchar(20)
		SET @OldUsername = (Select Username from QUANTRI where MaQT = @MaQT)
		IF NOT EXISTS (SELECT * FROM QUANTRI WHERE MaQT = @MaQT)
		BEGIN
			Print N'Quản trị viên không tồn tại!'
			Select 1
			ROLLBACK TRAN CapNhatQuanTri
		END
		IF EXISTS (SELECT * FROM USERS WHERE Username != @OldUsername AND Username = @Username)
		BEGIN
			Print N'Username mới đã tồn tại!'
			Select 2
			ROLLBACK TRAN CapNhatQuanTri
		END
		Update QUANTRI
		SET Username = null
		where MaQT = @MaQT
		Update USERS
		SET Username = @Username
		where Username = @OldUsername
		Update QUANTRI
		SET HoTen = @HoTen, Username = @Username
		where MaQT = @MaQT
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN CapNhatQuanTri
	END CATCH
COMMIT TRAN CapNhatQuanTri
Select 0

GO
/****** Object:  StoredProcedure [dbo].[CapNhatUser]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[CapNhatUser]
	@Username varchar(20),
	@Pass varchar(30),
	@RoleName varchar(9)
AS
BEGIN TRAN CapNhatUser
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM USERS WHERE Username = @Username)
		BEGIN
			Print N'Username không tồn tại!'
			Select 1
			ROLLBACK TRAN CapNhatUser
		END

		Update USERS
		SET Pass = @Pass, RoleName = @RoleName
		where Username = @Username
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN CapNhatUser
	END CATCH
COMMIT TRAN CapNhatUser
Select 0

GO
/****** Object:  StoredProcedure [dbo].[CheckUserValid]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[CheckUserValid] (
	@Username varchar(20)
)
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM USERS WHERE Username = @Username)
		BEGIN
			Print @Username + N' không tồn tại!'
			select 0 as code
			ROLLBACK TRAN
		END
		ELSE
		BEGIN
			select 1 as code
		END
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO
/****** Object:  StoredProcedure [dbo].[deleteAccount]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[deleteAccount] (
	@user char(15)
)
as
BEGIN TRAN
	BEGIN TRY
		IF (@user = '')
		BEGIN
			Print N'Username không được bỏ trống'
			ROLLBACK TRAN
		END

		exec sp_droplogin @user
	END TRY
	BEGIN CATCH
		print N'Lỗi phát sinh, có thể là username không tồn tại hoặc lỗi hệ thống!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO
/****** Object:  StoredProcedure [dbo].[disableLogin]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[disableLogin] (
	@user char(15)
)
as
BEGIN TRAN
	BEGIN TRY
		IF (@user = '')
		BEGIN
			Print N'Username không được bỏ trống'
			ROLLBACK TRAN
		END

		DECLARE @sql nvarchar(500)
		SET @sql = 'ALTER LOGIN ' + @user + ' DISABLE'
		EXEC sp_executesql @sql
		print N'Username ' + @user + N' đã được vô hiệu hóa'

	END TRY
	BEGIN CATCH
		print N'Lỗi phát sinh, có thể là username không tồn tại hoặc lỗi hệ thống!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO
/****** Object:  StoredProcedure [dbo].[DoiMatKhau]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[DoiMatKhau]
	@Username varchar(20),
	@OldPass varchar(30),
	@NewPass varchar(30)
AS
BEGIN TRAN DoiMatKhau
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM USERS WHERE Username = @Username)
		BEGIN
			Print N'Username không tồn tại!'
			Select 1
			ROLLBACK TRAN DoiMatKhau
		END
		IF EXISTS (SELECT * FROM USERS WHERE Username = @Username AND Pass != @OldPass)
		BEGIN
			Print N'Sai mật khẩu!'
			Select 2
			ROLLBACK TRAN DoiMatKhau
		END
		Update USERS
		SET Pass = @NewPass
		where Username = @Username
		
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN DoiMatKhau
	END CATCH
COMMIT TRAN DoiMatKhau
Select 0

GO
/****** Object:  StoredProcedure [dbo].[DsChiNhanh]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[DsChiNhanh]  
	@mahd varchar(10)
as
	begin try
		select * from CHINHANH where MaHopDong = @mahd
	end try
	begin catch
	end catch
GO
/****** Object:  StoredProcedure [dbo].[DsChiNhanhNull]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc [dbo].[DsChiNhanhNull] 
	@madt varchar(10)
as
	begin try
		select * from CHINHANH where MaDT = @madt and MaHopDong Is null
	end try
	begin catch
	end catch
GO
/****** Object:  StoredProcedure [dbo].[DuyetHopDong]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[DuyetHopDong]
	@MaHD varchar(10),
	@ThoiHan nvarchar(10),
	@MaNV VARCHAR(10),
	@NgayHetHan date
AS
BEGIN TRAN DuyetHopDong
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM HOPDONG WHERE MaHD = @MaHD)
		BEGIN
			Print @MaHD + N' không tồn tại!'
			select 1
			ROLLBACK TRAN DuyetHopDong
		END
		IF (SELECT TrangThai FROM HOPDONG WHERE MaHD = @MaHD) = N'Đã duyệt'
		BEGIN
			Print @MaHD + N' đã được duyệt!'
			select 2
			ROLLBACK TRAN DuyetHopDong
		END
		update HOPDONG
		set TrangThai = N'Đã duyệt', NgayKy = GETDATE(), ThoiHan = @ThoiHan, NgayHetHan = @NgayHetHan, MaNV = @MaNV
		where MaHD = @MaHD
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN DuyetHopDong
	END CATCH
COMMIT TRAN DuyetHopDong
select 0
GO
/****** Object:  StoredProcedure [dbo].[enableLogin]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[enableLogin] (
	@user char(15)
)
as
BEGIN TRAN
	BEGIN TRY
		IF (@user = '')
		BEGIN
			Print N'Username không được bỏ trống'
			ROLLBACK TRAN
		END

		DECLARE @sql nvarchar(500)
		SET @sql = 'ALTER LOGIN ' + @user + ' ENABLE'
		EXEC sp_executesql @sql
		print N'Username ' + @user + N' đã được kích hoạt'

	END TRY
	BEGIN CATCH
		print N'Lỗi phát sinh, có thể là username không tồn tại hoặc lỗi hệ thống!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO
/****** Object:  StoredProcedure [dbo].[grantPermission]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[grantPermission] (
	@roleOrUser char(15),
	@table char(30),
	@permiss char(15)
)
as
BEGIN TRAN
	BEGIN TRY
		IF (@roleOrUser = '' or @table = '' or @permiss = '')
		BEGIN
			Print N'Role or user, table và permission không được bỏ trống'
			ROLLBACK TRAN
		END
		DECLARE @sql nvarchar(500)
		SET @sql = 'GRANT ' + @permiss + ' on ' + @table + ' to ' + @roleOrUser
		EXEC sp_executesql @sql
	END TRY
	BEGIN CATCH
		print N'Lỗi phát sinh!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO
/****** Object:  StoredProcedure [dbo].[insertAccount]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[insertAccount] (
	@user char(15),
	@pass char(15),
	@role char(15)
)
as
BEGIN TRAN
	BEGIN TRY
		IF (@user = '' or @pass = '' or @role = '')
		BEGIN
			Print N'Username, pass và role không được bỏ trống'
			ROLLBACK TRAN
		END

		exec sp_addlogin @user, @pass

	END TRY
	BEGIN CATCH
		print N'Lỗi phát sinh, có thể là username đã tồn tại hoặc lỗi hệ thống!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO
/****** Object:  StoredProcedure [dbo].[LoginUser]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[LoginUser]
	@Username varchar(20),
	@Pass varchar(30)
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM USERS WHERE Username = @Username AND Pass = @Pass)
		BEGIN
			Print N'Sai tên đăng nhập hoặc mật khẩu!'
			SELECT 1
			ROLLBACK TRAN
		END
		IF (SELECT TrangThai FROM USERS WHERE Username = @Username) = N'Bị khóa'
		BEGIN
			Print N'Tài khoản bị khóa!'
			SELECT 2
			ROLLBACK TRAN
		END
		
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		SELECT 3
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
SELECT 0
GO
/****** Object:  StoredProcedure [dbo].[SoLuongDonTheoNam]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create --alter
proc [dbo].[SoLuongDonTheoNam]
	@MaDT varchar(10)
as
	begin tran
		begin try
			if not exists(select* from DoiTac where @MaDT=MaDT)
			begin
				print N'Mã đối tác không tồn tại'
				rollback tran
				select -1
				return
			end
			if not exists(select* from CHITIETDONDATHANG where MaDT=@MaDT)
			begin
				print N'Đối tác không có đơn hàng nào'
				rollback tran
				select -2
				return
			end
			select year(dh.NgayDat) as N'Năm',count(*) as SLDon
			from (select ddh.NgayDat,ddh.MaDH from DONDATHANG ddh, CHITIETDONDATHANG ct where ddh.MaDH=ct.MaDH and ct.MaDT=@MaDT) dh
			group by year(dh.NgayDat) 
			order by year(dh.NgayDat) desc

		end try
		begin catch
			print N'Lỗi hệ thống!'
			ROLLBACK TRAN
			select -10
			return
		END CATCH
COMMIT TRAN
return
GO
/****** Object:  StoredProcedure [dbo].[SoLuongDonTheoNgay]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Exec SuaThucPham '1',N'Ca phê phân chồn',N'Đậm vị cà phê',200000,N'Có bán',N'Đường/Nhiệt độ','1'
Exec SuaThucPham '2',N'Cà phê đá xay',N'Đậm vị cà phê',20000,N'Có bán',N'Đường/Nhiệt độ','5'
Exec SuaThucPham '3',N'Cà phê bọt biển',N'Hương vị mới',50000,N'Có bán',N'Đường/Nhiệt độ','1'
Exec SuaThucPham '1',N'Gà chiêm nước mắm',N'Hương vị mới',30000,N'Có bán',N'Đường/Nhiệt độ','1'
Exec SuaThucPham '2',N'Sườn non',N'Hương vị mới',30000,N'Có bán',N'Đường/Nhiệt độ','1'
Exec SuaThucPham '3',N'Sườn nướng',N'Hương vị mới',30000,N'Có bán',N'Đường/Nhiệt độ','1'
Exec ThemThucPham '1',N'Gà xối mỡa',N' ','25000.0',N'Có bán',N' '
*/


create --alter
proc [dbo].[SoLuongDonTheoNgay]
	@MaDT varchar(10)
as
	begin tran
		begin try
			if not exists(select* from DoiTac where @MaDT=MaDT)
			begin
				print N'Mã đối tác không tồn tại'
				rollback tran
				select -1
				return
			end
			if not exists(select* from CHITIETDONDATHANG where MaDT=@MaDT)
			begin
				print N'Đối tác không có đơn hàng nào'
				rollback tran
				select -2
				return
			end
			select dh.NgayDat,count(*) as SLDon
			from (select ddh.NgayDat,ddh.MaDH from DONDATHANG ddh, CHITIETDONDATHANG ct where ddh.MaDH=ct.MaDH and ct.MaDT=@MaDT) dh
			group by dh.NgayDat
			order by dh.NgayDat desc
		end try
		begin catch
			print N'Lỗi hệ thống!'
			ROLLBACK TRAN
			select -10
			return
		END CATCH
COMMIT TRAN
return
GO
/****** Object:  StoredProcedure [dbo].[SoLuongDonTheoThang]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create --alter
proc [dbo].[SoLuongDonTheoThang]
	@MaDT varchar(10)
as
	begin tran
		begin try
			if not exists(select* from DoiTac where @MaDT=MaDT)
			begin
				print N'Mã đối tác không tồn tại'
				rollback tran
				select -1
				return
			end
			if not exists(select* from CHITIETDONDATHANG where MaDT=@MaDT)
			begin
				print N'Đối tác không có đơn hàng nào'
				rollback tran
				select -2
				return
			end
			select year(dh.NgayDat) as Nam, month(dh.NgayDat) as Thang,count(*) as SLDon
			from (select ddh.NgayDat,ddh.MaDH from DONDATHANG ddh, CHITIETDONDATHANG ct where ddh.MaDH=ct.MaDH and ct.MaDT=@MaDT) dh
			group by year(dh.NgayDat),month(dh.NgayDat)
			order by year(dh.NgayDat) desc, month(dh.NgayDat) desc

		end try
		begin catch
			print N'Lỗi hệ thống!'
			ROLLBACK TRAN
			select -10
			return
		END CATCH
COMMIT TRAN
return
GO
/****** Object:  StoredProcedure [dbo].[sp_DoiTacCapNhatTinhTrangDon]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--T1: (Đối tác) cập nhật tình trạng đơn hàng
create proc [dbo].[sp_DoiTacCapNhatTinhTrangDon] (
	@MaDonDH varchar(10),
	@TinhTrang nvarchar(30)
)
as
begin tran
	--Kiểm tra thông tin trống không
	if (@MaDonDH='' or @TinhTrang='')
	begin 
		print N'Thông tin trống'
		rollback tran
		return 1
	end

	--Kiểm tra xem mã đối tác tồn tại chưa
	if not exists (select* from DONDATHANG where MaDH = @MaDonDH)
	begin 
		print N'Mã đơn đặt hàng không tồn tại'
		rollback tran
		return 1
	end

	waitfor delay '0:0:5'
	update DONDATHANG SET TinhTrang = @TinhTrang where MaDH = @MaDonDH
	select * from DONDATHANG d where d.MaDH = @MaDonDH
commit
GO
/****** Object:  StoredProcedure [dbo].[sp_DoiTacCapNhatTinhTrangDon_fix]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--T2: (Đối tác) cập nhật tình trạng đơn hàng
create proc [dbo].[sp_DoiTacCapNhatTinhTrangDon_fix] (
	@MaDonDH varchar(10),
	@TinhTrang nvarchar(30)
)
as
set tran isolation level repeatable read
begin tran
	--Kiểm tra thông tin trống không
	if (@MaDonDH='' or @TinhTrang='')
	begin 
		print N'Thông tin trống'
		rollback tran
		return 1
	end

	--Kiểm tra xem mã đối tác tồn tại chưa
	if not exists (select* from DONDATHANG where MaDH = @MaDonDH)
	begin 
		print N'Mã đơn đặt hàng không tồn tại'
		rollback tran
		return 1
	end

	waitfor delay '0:0:5'
	update DONDATHANG SET TinhTrang = @TinhTrang where MaDH = @MaDonDH
	select * from DONDATHANG d where d.MaDH = @MaDonDH
commit
GO
/****** Object:  StoredProcedure [dbo].[sp_DSDoiTac]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[sp_DSDoiTac]
as
begin tran
	select [MaDT],[Email],[NgDaiDien],[SLChiNhanh],[TenQuan],[LoaiTP] from DOITAC
	waitfor delay '0:0:10'
	select [MaDT],[Email],[NgDaiDien],[SLChiNhanh],[TenQuan],[LoaiTP] from DOITAC
commit
GO
/****** Object:  StoredProcedure [dbo].[sp_DSDoiTac_fix]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[sp_DSDoiTac_fix]
as
set transaction isolation level serializable
begin tran
	select [MaDT],[Email],[NgDaiDien],[SLChiNhanh],[TenQuan],[LoaiTP] from DOITAC
	waitfor delay '0:0:10'
	select [MaDT],[Email],[NgDaiDien],[SLChiNhanh],[TenQuan],[LoaiTP] from DOITAC
commit
GO
/****** Object:  StoredProcedure [dbo].[sp_KhachHangHuyDon]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--T2: (Khách hàng) hủy đơn hàng
create proc [dbo].[sp_KhachHangHuyDon] (
	@MaDonDH varchar(10)
)
as
begin tran
	--Kiểm tra thông tin trống không
	if (@MaDonDH='')
	begin 
		print N'Thông tin trống'
		rollback tran
		return 1
	end

	--Kiểm tra xem mã đối tác tồn tại chưa
	if not exists (select* from DONDATHANG where MaDH = @MaDonDH)
	begin 
		print N'Mã đơn đặt hàng không tồn tại'
		rollback tran
		return 1
	end

	waitfor delay '0:0:5'
	update DONDATHANG SET TinhTrang = N'Đã hủy đơn' where MaDH = @MaDonDH
	select * from DONDATHANG d where d.MaDH = @MaDonDH
commit
GO
/****** Object:  StoredProcedure [dbo].[sp_KhachHangHuyDon_fix]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--T1: (Khách hàng) hủy đơn hàng
create proc [dbo].[sp_KhachHangHuyDon_fix] (
	@MaDonDH varchar(10)
)
as
set tran isolation level repeatable read
begin tran
	--Kiểm tra thông tin trống không
	if (@MaDonDH='')
	begin 
		print N'Thông tin trống'
		rollback tran
		return 1
	end

	--Kiểm tra xem mã đối tác tồn tại chưa
	if not exists (select* from DONDATHANG where MaDH = @MaDonDH)
	begin 
		print N'Mã đơn đặt hàng không tồn tại'
		rollback tran
		return 1
	end

	waitfor delay '0:0:5'
	update DONDATHANG SET TinhTrang = N'Đã hủy đơn' where MaDH = @MaDonDH
	select * from DONDATHANG d where d.MaDH = @MaDonDH
commit
GO
/****** Object:  StoredProcedure [dbo].[sp_ThemDoiTac]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_ThemDoiTac] (
	@MaDT VARCHAR(10),
	@Email VARCHAR(30),
	@NgDaiDien NVARCHAR(30),
	@SLChiNhanh SMALLINT,
	@TenQuan NVARCHAR(30),
	@LoaiTP NVARCHAR(30),
	@Username VARCHAR(20)
)
AS
BEGIN TRAN sp_ThemDoiTac
		BEGIN TRY
			IF @MaDT='' OR @Email='' OR @NgDaiDien=''  OR @TenQuan='' OR @LoaiTP=''
			BEGIN 
				PRINT N'Thông tin trống'
				SELECT 1
				ROLLBACK TRAN ThemDoiTac
			END
			IF EXISTS(SELECT* FROM DoiTac WHERE MaDT=@MaDT)
			BEGIN
				PRINT N'Mã đối tác đã tồn tại'
				SELECT 2
				ROLLBACK TRAN ThemDoiTac
			END
			INSERT INTO DOITAC VALUES(@MaDT,@Email,@NgDaiDien,@SLChiNhanh,@TenQuan,@LoaiTP,@Username)
		end try
		begin catch
			print N'Lỗi hệ thống!'
			ROLLBACK TRAN sp_ThemDoiTac
		END CATCH
COMMIT TRAN sp_ThemDoiTac
select 0
GO
/****** Object:  StoredProcedure [dbo].[sp_ThemDoiTac_fix]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[sp_ThemDoiTac_fix] (
	@MaDT varchar(10),
	@Email varchar(30),
	@NgDaiDien nvarchar(30),
	@SLChiNhanh SMALLINT,
	@TenQuan NVARCHAR(30),
	@LoaiTP NVARCHAR(30),
	@Username VARCHAR(20)
)
AS
BEGIN TRAN sp_ThemDoiTac_fix
		BEGIN TRY
			IF @MaDT='' OR @Email='' OR @NgDaiDien=''  OR @TenQuan='' OR @LoaiTP=''
			BEGIN 
				PRINT N'Thông tin trống'
				SELECT 1
				ROLLBACK TRAN ThemDoiTac
			END
			IF EXISTS(SELECT* FROM DoiTac WHERE MaDT=@MaDT)
			BEGIN
				PRINT N'Mã đối tác đã tồn tại'
				SELECT 2
				ROLLBACK TRAN ThemDoiTac
			END
			insert into DOITAC values(@MaDT,@Email,@NgDaiDien,@SLChiNhanh,@TenQuan,@LoaiTP,@Username)
		end try
		begin catch
			print N'Lỗi hệ thống!'
			ROLLBACK TRAN sp_ThemDoiTac_fix
		END CATCH
COMMIT TRAN sp_ThemDoiTac_fix
select 0
GO
/****** Object:  StoredProcedure [dbo].[SuaChiNhanh]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create --  alter
proc [dbo].[SuaChiNhanh]
	@MaDT varchar(10),
	@TP nvarchar(30),
	@Quan nvarchar(30),
	@DiaChiCuThe nvarchar(50),
	@SDT char(10),
	@TinhTrang nvarchar(30),
	@NgayLap date,
	@stt varchar(10)
as 
	begin tran
		begin try
			if @MaDT='' or @TP='' or @Quan='' or @DiaChiCuThe='' 
			or @SDT='' or @NgayLap='' or @stt =''
			begin
				print N'Thông tin trống'
				rollback tran
				select 1
				return
			end
			if not exists(select* from DOITAC where MaDT=@MaDT)
			begin
				print N'Mã đối tác không tồn tại'
				rollback tran
				select 2 
				return
			end
			if exists(select *from CHINHANH where SDT=@SDT and (MaDT!= @MaDT or STT != @stt)
			)
			begin
				print N'Số điện thoại đã tồn tại'
				rollback tran 
				select 3
				return
			end
			if @TinhTrang<>N'Bình thường' and @TinhTrang<>N'Tạm nghỉ'
			begin
				print N'Tình trạng không hợp lệ'
				rollback tran
				select 4
				return
			end
			update ChiNhanh set 
				MaDT=@MaDT,
				TP=@TP,
				Quan=@Quan,
				DiaChiCuThe=@DiaChiCuThe,
				SDT=@SDT,
				TinhTrang=@TinhTrang,
				NgayLap=@NgayLap
				where
				STT=@stt and MaDT =@MaDT
		end try
		begin catch
			print N'Lỗi hệ thống!'
			ROLLBACK TRAN
			select 10
			return 
		END CATCH
COMMIT TRAN
select 0 
return
GO
/****** Object:  StoredProcedure [dbo].[SuaThucPham]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
select * from ThucPham
exec XoaThucPham '2','3'
*/


--Update Thực phẩm
--Sửa thực phẩm
create -- alter
proc [dbo].[SuaThucPham]
	@MaDT varchar(10),
	@TenMon nvarchar(30),
	@MieuTa nvarchar(50),
	@Gia decimal(10,1),
	@TinhTrang nvarchar(30),
	@TuyChon nvarchar(50),
	@MaTP varchar(10)
as
	begin tran
		begin try
			if @MaDT='' or @TenMon='' 
			or @TinhTrang=''   or @MaTP=''
			begin
				print N'Thông tin trống'
				rollback tran
				select 1
				return
			end
			if not exists(select* from DoiTac where MaDT=@MaDT)
			begin
				print N'Mã đối tác không tồn tại'
				rollback tran
				select 2
				return
			end
			if exists(select* from ThucPham where @TenMon=TenMon and (MaDT!=@MaDT or MaTP!=@MaTP))
			begin
				print N'Tên thực phẩm này đã tồn tại'
				rollback tran
				select 3
				return
			end
			if @TinhTrang<>N'Có bán' and @TinhTrang<>N'Hết hàng hôm nay' and @TinhTrang<>N'Tạm ngưng'
			begin
				print N'Tình trạng không hợp lệ'
				rollback tran
				select 4
				return
			end
			update THUCPHAM
			set TenMon=@TenMon,MieuTa=@MieuTa,Gia=@Gia,TinhTrang=@TinhTrang,TuyChon=@TuyChon
			where MaTP=@MaTp and MaDT=@MaDT
			if @Gia<=0
			begin 
				print N'Giá phải lớn hơn 0'
				rollback tran
				select 7
				return
			end
		end try
		begin catch
			print N'Lỗi hệ thống!'
			rollback tran
			select 10
			return
		END CATCH
COMMIT TRAN
select 0 
return
GO
/****** Object:  StoredProcedure [dbo].[ThemChiNhanh]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[ThemChiNhanh]
	@MaDT varchar(10),
	@TP nvarchar(30),
	@Quan nvarchar(30),
	@DiaChiCuThe nvarchar(50),
	@SDT char(10),
	@TinhTrang nvarchar(30),
	@NgayLap date
as 
	begin tran
		begin try
			if @MaDT='' or @TP='' or @Quan='' or @DiaChiCuThe='' 
			or @SDT='' or @TinhTrang='' or @NgayLap=''
			begin
				print N'Thông tin trống'
				rollback tran
				select 1
				return
			end
			if not exists(select* from DOITAC where MaDT=@MaDT)
			begin
				print N'Mã đối tác không tồn tại'
				rollback tran
				select 2 
				return
			end
			if exists(select* from CHINHANH where SDT=@SDT)
			begin
				print N'Số điện thoại đã tồn tại'
				rollback tran 
				select 3
				return
			end
			if @TinhTrang<>N'Bình thường' and @TinhTrang<>N'Tạm nghỉ'
			begin
				print N'Tình trạng không hợp lệ'
				rollback tran
				select 4
				return
			end
			declare @stt int
			set @stt=0
			if exists (select * from ChiNhanh where MaDT=@MaDT)
			begin 
				set @stt=(select max(STT) from ChiNhanh where MaDT=@MaDT) 
			end
			set @stt=@stt+1
			insert into ChiNhanh values
			(@stt,@MaDT,@TP,@Quan,@DiaChiCuThe,@SDT,@TinhTrang,@NgayLap,NULL)
			update DoiTac
			set SLChiNhanh=SLChiNhanh+1
			where @MaDT=MaDT
		end try
		begin catch
			print N'Lỗi hệ thống!'
			ROLLBACK TRAN
			select 10
			return 
		END CATCH
COMMIT TRAN
select 0 
return
GO
/****** Object:  StoredProcedure [dbo].[ThemHopDong]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create --alter
proc [dbo].[ThemHopDong]
	@SLChiNhanh smallint,
	@SoTaiKhoan varchar(20),
	@NganHang nvarchar(30),
	@CNNganHang nvarchar(30),
	@MaSoThue varchar(13),
	@NgayKy date,
	@ThoiHan nvarchar(10),
	@NgayHetHan date,
	@MaDT varchar(10)
as
	begin tran
		begin try
			if @SLChiNhanh<=0  or  @SoTaiKhoan='' or @CNNganHang='' or @NganHang='' or
			@MaSoThue='' or @NgayKy='' or @ThoiHan='' or @NgayHetHan='' or @MaDT=''
			begin
				print N'Thông tin trống'
				rollback tran
				select 1
				return
			end
			if not exists(select* from DoiTac where @MaDT=MaDT)
			begin
				print N'Mã đối tác không tồn tại'
				select 2
				return
			end
			if @NgayKy>@NgayHetHan
			begin
				print N'Ngày hết hạn phải sau ngày ký'
				rollback tran
				select 3
				return
			end
			declare @ngDaiDien nvarchar(30)
			select @ngDaiDien=ngDaiDien 
			from DoiTac
			where MaDT=@MaDT


			declare @MaHD int
			set @MaHD=0
			if (select count(*) from HopDong)>0
			begin
				set @MaHD=(select max(CAST(MaHD as int)) from HopDong)
			end
			set @MaHD=@MaHD+1

			select (@MaHD*-1)
			insert into HopDong values (CONVERT(varchar(10), @MaHD),@NgDaiDien,@SLChiNhanh,@SoTaiKhoan,@NganHang,@CNNganHang,@MaSoThue,@NgayKy,@ThoiHan,@NgayHetHan,@MaDT,NULL,N'Chờ duyệt')
			
		end try
		begin catch
			print N'Lỗi hệ thống!'
			ROLLBACK TRAN
			select 10
			return
		END CATCH
COMMIT TRAN
GO
/****** Object:  StoredProcedure [dbo].[themKhachHang]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[themKhachHang]
	@MaKH varchar(10),
	@HoTen nvarchar(30),
	@DiaChi nvarchar(100),
	@SDT char(10),
	@Email varchar(30),
	@Username VARCHAR(20)
as
begin tran
	set tran isolation level read uncommitted
	-- Kiểm tra thông tin rỗng
	if (@MaKH='' or @HoTen='' or @DiaChi='' or @SDT='' or @Email='' OR @Username='')
	begin 
		print N'Thông tin trống'
		SELECT 1
		rollback tran
	end
	-- Kiểm tra mã khách hàng đã tồn tại chưa
	if exists(select* from KHACHHANG where MaKH=@MaKH)
	begin 
		print N'Mã khách hàng đã tồn tại'
		SELECT 2
		rollback tran
	end

	-- Kiểm tra số điện thoại bị trùng
	if exists(select * from KHACHHANG where SDT = @SDT and MaKH != @MaKH)
	begin
		print N'Số điện thoại bị trùng!'
		SELECT 3
		rollback tran
	END
    	insert into KHACHHANG values(@MaKH,@HoTen,@DiaChi,@SDT,@Email,@Username)
	waitfor delay '0:0:10'
COMMIT TRAN
RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[ThemNhanVien]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[ThemNhanVien]
	@MaNV varchar(10),
	@HoTen nvarchar(30),
	@Username varchar(20)
as
begin tran ThemNhanVien
	begin try
		if @MaNV='' or @HoTen=''
		begin 
			print N'Thông tin trống'
			Select 1
			rollback tran ThemNhanVien
			
		end
		if exists(select* from NHANVIEN where MaNV=@MaNV)
		begin
			print N'Mã nhân viên đã tồn tại'
			Select 2
			rollback tran ThemNhanVien
			
		end
		insert into NhanVien values(@MaNV,@HoTen,@Username)
	end try
	begin catch
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN ThemNhanVien
	END CATCH
COMMIT TRAN ThemNhanVien
Select 0
GO
/****** Object:  StoredProcedure [dbo].[ThemQuanTri]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[ThemQuanTri]
	@MaQT varchar(10),
	@HoTen nvarchar(30),
	@Username varchar(20)
as
begin tran ThemQuanTri
	begin try
		if @MaQT='' or @HoTen=''
		begin 
			print N'Thông tin trống'
			Select 1
			rollback tran ThemQuanTri
			
		end
		if exists(select* from QUANTRI where MaQT=@MaQT)
		begin
			print N'Mã quản trị viên đã tồn tại'
			Select 2
			rollback tran ThemQuanTri
			
		end
		insert into QUANTRI values(@MaQT,@HoTen,@Username)
	end try
	begin catch
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN ThemQuanTri
	END CATCH
COMMIT TRAN ThemQuanTri
Select 0
GO
/****** Object:  StoredProcedure [dbo].[ThemTaiXe]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[ThemTaiXe]
	@MaTX varchar(10),
	@CMND varchar(12),
	@HoTen nvarchar(30),
	@SDT char(10),
	@DiaChi nvarchar(100),
	@BienSoXe varchar(10),
	@KhuVucHoatDong nvarchar(30),
	@Email varchar(30),
	@SoTaiKhoan varchar(20),
	@NganHang nvarchar(30),
	@CNNganHang nvarchar(30),
	@Username varchar(20)
as 
	begin tran ThemTaiXe
		begin try
			if @MaTX='' or @CMND='' or @HoTen=''
			or @SDT='' or @DiaChi='' or @BienSoXe=''
			or @KhuVucHoatDong='' or @Email='' or @SoTaiKhoan=''
			or @NganHang='' or @CNNganHang='' OR @Username =''
			begin 
				print N'Thông tin trống'
				select 1
				rollback tran ThemTaiXe
			end
			if exists(SELECT * from TAIXE where MaTX = @MaTX)
			begin
				print N'Mã tài xế đã tồn tại'
				select 2
				rollback tran ThemTaiXe
			end
			insert into TAIXE values(@MaTX, @CMND,@HoTen,@SDT,@DiaChi,@BienSoXe,@KhuVucHoatDong,@Email,@SoTaiKhoan,@NganHang,@CNNganHang,@Username)
		end try
		begin catch
			print N'Lỗi hệ thống!'
			ROLLBACK TRAN ThemTaiXe
		END CATCH
COMMIT TRAN ThemTaiXe
select 0
GO
/****** Object:  StoredProcedure [dbo].[ThemThucPham]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Thêm thực phẩm 
create -- alter
proc [dbo].[ThemThucPham]
	@MaDT varchar(10),
	@TenMon nvarchar(30),
	@MieuTa nvarchar(50),
	@Gia decimal(10,1),
	@TinhTrang nvarchar(30),
	@TuyChon nvarchar(50)
as
	begin tran
		begin try
			if @MaDT='' or @TenMon='' --or @MieuTa='' 
			or @TinhTrang=''-- or @TuyChon=''
			begin
				print N'Thông tin trống'
				rollback tran
				select 1
				return
			end
			if not exists(select* from DoiTac where MaDT=@MaDT)
			begin
				print N'Mã đối tác không tồn tại'
				rollback tran
				select 2
				return
			end
			if exists(select* from ThucPham where @TenMon=TenMon and MaDT=@MaDT)
			begin
				print N'Tên thực phẩm này đã tồn tại'
				rollback tran
				select 3
				return
			end
			if @TinhTrang<>N'Có bán' and @TinhTrang<>N'Hết hàng hôm nay' and @TinhTrang<>N'Tạm ngưng'
			begin
				print N'Tình trạng không hợp lệ'
				rollback tran
				select 4
				return
			end
			declare @MaTP int
			set @MaTP=0
			if exists (select * from ThucPham where MaDT=@MaDT)
			begin 
				set @MaTP=(select max(MaTP) from ThucPham where MaDT=@MaDT) 
			end
			set @MaTP=@MaTP+1
			insert into ThucPham values 
			(CONVERT(varchar(10), @MaTP),@MaDT,@TenMon,@MieuTa,@Gia,@TinhTrang,@TuyChon)
		end try
		begin catch
			print N'Lỗi hệ thống!'
			rollback tran
			select 10
			return
		END CATCH
COMMIT TRAN
select 0 
return
GO
/****** Object:  StoredProcedure [dbo].[ThemUser]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[ThemUser]
	@Username varchar(20),
	@Pass varchar(30),
	@RoleName varchar(9)
as
begin tran ThemUser
	begin try
		if @Username='' or @Pass=''
		begin 
			print N'Thông tin trống'
			select 1 as code
			ROLLBACK TRAN ThemUser
		end
		if exists(select* from USERS where Username = @Username)
		begin
			print N'Username đã tồn tại'
			select 2 as code
			ROLLBACK TRAN ThemUser
		end
		if @RoleName != 'DoiTac' and @RoleName != 'KhachHang' and @RoleName != 'TaiXe' and @RoleName != 'NhanVien' and @RoleName != 'QuanTri'
		begin
			print N'Role name không hợp lệ!'
			select 3 as code
			ROLLBACK TRAN ThemUser
		end
		insert into USERS values(@Username,@Pass,@RoleName,N'Hoạt động')
	end try
	begin catch
		print N'Lỗi hệ thống!'
		select 4 as code
		ROLLBACK TRAN ThemUser
	END CATCH
COMMIT TRAN ThemUser
select 0 as code

GO
/****** Object:  StoredProcedure [dbo].[TimKiemChiNhanh]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[TimKiemChiNhanh]
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
/****** Object:  StoredProcedure [dbo].[TimKiemChiTietDonDatHang]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[TimKiemChiTietDonDatHang]
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
/****** Object:  StoredProcedure [dbo].[TimKiemDoiTac]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[TimKiemDoiTac]
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
/****** Object:  StoredProcedure [dbo].[TimKiemDonDatHang]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[TimKiemDonDatHang]
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
/****** Object:  StoredProcedure [dbo].[TimKiemHopDong]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[TimKiemHopDong]
	@MaHD varchar(10)
AS
BEGIN TRAN TimKiemHopDong
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM HOPDONG WHERE MaHD = @MaHD)
		BEGIN
			Print @MaHD + N' không tồn tại!'
			ROLLBACK TRAN TimKiemHopDong
		END
		SELECT * FROM HOPDONG WHERE MaHD = @MaHD
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN TimKiemHopDong
	END CATCH
COMMIT TRAN TimKiemHopDong

GO
/****** Object:  StoredProcedure [dbo].[timKiemKhachHang]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[timKiemKhachHang]
	@MaKH varchar(10)
AS
BEGIN TRAN timKiemKhachHang
	set tran isolation level read uncommitted
	IF NOT EXISTS (SELECT * FROM KHACHHANG WHERE MaKH = @MaKH)
	BEGIN
		Print @MaKH + N' không tồn tại!'
		ROLLBACK TRAN timKiemKhachHang
		Select 1
	END
	SELECT * FROM KHACHHANG WHERE MaKH = @MaKH
COMMIT TRAN timKiemKhachHang
Select 0

GO
/****** Object:  StoredProcedure [dbo].[TimKiemNhanVien]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[TimKiemNhanVien]
	@Username varchar(20)
AS
BEGIN TRAN TimKiemNhanVien
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM NHANVIEN WHERE Username = @Username)
		BEGIN
			Print @Username + N' không tồn tại!'
			ROLLBACK TRAN TimKiemNhanVien
		END
		SELECT * FROM NHANVIEN WHERE Username = @Username
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN TimKiemNhanVien
	END CATCH
COMMIT TRAN TimKiemNhanVien

GO
/****** Object:  StoredProcedure [dbo].[TimKiemQuanTri]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[TimKiemQuanTri]
	@Username varchar(20)
AS
BEGIN TRAN TimKiemQuanTri
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM QUANTRI WHERE Username = @Username)
		BEGIN
			Print @Username + N' không tồn tại!'
			ROLLBACK TRAN TimKiemQuanTri
		END
		SELECT * FROM QUANTRI WHERE Username = @Username
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN TimKiemQuanTri
	END CATCH
COMMIT TRAN TimKiemQuanTri

GO
/****** Object:  StoredProcedure [dbo].[TimKiemTaiXe]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[TimKiemTaiXe]
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
/****** Object:  StoredProcedure [dbo].[TimKiemThucPham]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[TimKiemThucPham]
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
/****** Object:  StoredProcedure [dbo].[TimKiemUser]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[TimKiemUser]
	@Username varchar(20)
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM USERS WHERE Username = @Username)
		BEGIN
			Print @Username + N' không tồn tại!'
			ROLLBACK TRAN
		END
		Select * from USERS where Username = @Username
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN

GO
/****** Object:  StoredProcedure [dbo].[TimKiemUserPass]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[TimKiemUserPass] (
	@Username varchar(20),
	@Password VARCHAR(30)
)
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM USERS WHERE Username = @Username)
		BEGIN
			Print @Username + N' không tồn tại!'
			select 0 as code
			ROLLBACK TRAN
		END
		ELSE
		BEGIN
			IF ((SELECT Pass FROM USERS WHERE Username = @Username) = @Password)
				select 1 as code
			ELSE 
				select 0 as code
		END
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO
/****** Object:  StoredProcedure [dbo].[updateAccount]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[updateAccount] (
	@user char(15),
	@oldPass char(15),
	@newPass char(15)
)
as
BEGIN TRAN
	BEGIN TRY
		IF (@user = '' or @oldPass = '' or @newPass = '')
		BEGIN
			Print N'Username, Old password và New password không được bỏ trống'
			ROLLBACK TRAN
		END
		exec sp_password @oldPass, @newPass, @user
	END TRY
	BEGIN CATCH
		print N'Lỗi phát sinh, có thể là username không tồn tại hoặc lỗi hệ thống!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO
/****** Object:  StoredProcedure [dbo].[usp_xoaChiNhanh]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- usp_xoaChiNhanh
create -- alter
proc [dbo].[usp_xoaChiNhanh]
		@STT int,
		@MaDT varchar(10)
as
begin transaction
	begin try
		-- Kiểm tra thông tin nhập không đượcc rỗng.
		if (@MaDT = '' or
			@STT = '')
			begin
				print N'Thông tin nhập không được rỗng'
				rollback tran
				return 1
			end
		-- Kiểm tra tồn tại
		if not exists(select * from CHINHANH where STT = @STT and MaDT = @MaDT)
			begin
				print N'Không thể xoá, chi nhánh không tồn tại'
				rollback tran
				return 1
			end
		delete from CHINHANH where MaDT = @MaDT and STT = @STT
	end try

	begin catch
		print N'Lỗi hệ thống!'
		rollback tran
		return 1
	end catch
commit tran
return 0
GO
/****** Object:  StoredProcedure [dbo].[usp_xoaChiTietDonHang]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- usp_xoaChiTietDonHang
create -- alter
proc [dbo].[usp_xoaChiTietDonHang]
		@MaDH varchar(10),
		@MaTP varchar(10),
		@MaDT varchar(10)
as
begin transaction
	begin try
		-- Kiểm tra thông tin nhập không đượcc rỗng.
		if (@MaDH = '' or
			@MaTP = ''or
			@MaDT = '')
			begin
				print N'Thông tin nhập không được rỗng'
				rollback tran
				return 1
			end
		-- Kiểm tra tồn tại
		if not exists(select * from CHITIETDONDATHANG where @MaDH = @MaDH and MaTP = @MaTP and MaDT = @MaDT)
			begin
				print N'Không thể xoá, chi tiết đơn hàng không tồn tại'
				rollback tran
				return 1
			end
		delete from CHITIETDONDATHANG where @MaDH = MaDH and @MaTP = MaTP and
			@MaDT = MaDT
	end try

	begin catch
		print N'Lỗi hệ thống!'
		rollback tran
		return 1
	end catch
commit tran
return 0
GO
/****** Object:  StoredProcedure [dbo].[usp_xoaDoiTac]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- usp_xoaDoiTac
create -- alter
proc [dbo].[usp_xoaDoiTac]
		@MaDT varchar(10)
as
begin transaction
	begin try
		-- Kiểm tra thông tin nhập không đượcc rỗng.
		if (@MaDT = '')
			begin
				print N'Thông tin nhập không được rỗng'
				rollback tran
				return 1
			end
		-- Kiểm tra tồn tại
		if not exists(select * from DOITAC where MaDT = @MaDT)
			begin
				print N'Không thể xoá, hợp đồng không tồn tại'
				rollback tran
				return 1
			end
		delete from DOITAC where MaDT = @MaDT
	end try

	begin catch
		print N'Lỗi hệ thống!'
		rollback tran
		return 1
	end catch
commit tran
return 0
GO
/****** Object:  StoredProcedure [dbo].[usp_xoaDonDatHang]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- usp_xoaDonDatHang
create -- alter
proc [dbo].[usp_xoaDonDatHang]
		@MaDH varchar(10)
as
begin transaction
	begin try
		-- Kiểm tra thông tin nhập không đượcc rỗng.
		if (@MaDH = '')
			begin
				print N'Thông tin nhập không được rỗng'
				rollback tran
				return 1
			end
		if exists(select * from CHITIETDONDATHANG where MaDH = @MaDH)
			begin
				print N'Không thể xoá, chi tiết hơn hàng vẫn tồn tại'
				rollback tran
				return 1
			end
		-- Kiểm tra tồn tại
		if not exists(select * from DONDATHANG where @MaDH = @MaDH)
			begin
				print N'Không thể xoá, đơn hàng không tồn tại'
				rollback tran
				return 1
			end
		delete from DONDATHANG where @MaDH = MaDH
	end try

	begin catch
		print N'Lỗi hệ thống!'
		rollback tran
		return 1
	end catch
commit tran
return 0
GO
/****** Object:  StoredProcedure [dbo].[usp_xoaHopDong]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- usp_xoaHopDong
create -- alter
proc [dbo].[usp_xoaHopDong]
		@MaHD varchar(10)
as
begin transaction
	begin try
		-- Kiểm tra thông tin nhập không đượcc rỗng.
		if (@MaHD = '')
			begin
				print N'Thông tin nhập không được rỗng'
				rollback tran
				return 1
			end
		-- Kiểm tra tồn tại
		if not exists(select * from HOPDONG where MaHD = @MaHD)
			begin
				print N'Không thể xoá, hợp đồng không tồn tại'
				rollback tran
				return 1
			end
		delete from HOPDONG where MaHD = @MaHD
	end try

	begin catch
		print N'Lỗi hệ thống!'
		rollback tran
		return 1
	end catch
commit tran
return 0
GO
/****** Object:  StoredProcedure [dbo].[usp_xoaKhachHang]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- usp_xoaKhachHang
create -- alter
proc [dbo].[usp_xoaKhachHang]
		@MaKH varchar(10)
as
begin transaction
	begin try
		-- Kiểm tra thông tin nhập không đượcc rỗng.
		if (@MaKH = '')
			begin
				print N'Thông tin nhập không được rỗng'
				rollback tran
				return 1
			end
		if exists(select * from DONDATHANG where MaKH = @MaKH)
			begin
				print N'Không thể xoá, khách hàng đã có đơn hàng'
				rollback tran
				return 1
			end
		-- Kiểm tra tồn tại
		if not exists(select * from KHACHHANG where @MaKH = MaKH)
			begin
				print N'Không thể xoá, khách hàng không tồn tại'
				rollback tran
				return 1
			end
		delete from KHACHHANG where @MaKH = MaKH
	end try

	begin catch
		print N'Lỗi hệ thống!'
		rollback tran
		return 1
	end catch
commit tran
return 0
GO
/****** Object:  StoredProcedure [dbo].[usp_xoaNhanVien]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create -- alter
proc [dbo].[usp_xoaNhanVien]
		@MaNV varchar(10)
as
begin transaction
	begin try
		-- Kiểm tra thông tin nhập không đượcc rỗng.
		if (@MaNV = '')
			begin
				print N'Thông tin nhập không được rỗng'
				rollback tran
				return 1
			end

		-- Kiểm tra thông tin nhập hợp lệ. 
		if exists(select * from HOPDONG where MaNV = @MaNV)
			begin
				print N'Nhân viên tồn tại hợp đồng'
				rollback tran
				return 1
			end
		-- Kiểm tra tồn tại
		if not exists(select * from NHANVIEN where MaNV = @MaNV)
			begin
				print N'Không thể xoá, nhân viên không tồn tại'
				rollback tran
				return 1
			end
		delete from NHANVIEN where MaNV = @MaNV
	end try

	begin catch
		print N'Lỗi hệ thống!'
		rollback tran
		return 1
	end catch
commit tran
return 0
GO
/****** Object:  StoredProcedure [dbo].[usp_xoaTaiXe]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- usp_xoaTaiXe
create -- alter
proc [dbo].[usp_xoaTaiXe]
		@CMND varchar(10)
as
begin transaction
	begin try
		-- Kiểm tra thông tin nhập không đượcc rỗng.
		if (@CMND = '')
			begin
				print N'Thông tin nhập không được rỗng'
				rollback tran
				return 1
			end
		if exists(select * from DONDATHANG where MaTX = @CMND)
			begin
				print N'Không thể xoá, khách hàng đã có đơn hàng'
				rollback tran
				return 1
			end
		-- Kiểm tra tồn tại
		if not exists(select * from TAIXE where CMND = @CMND)
			begin
				print N'Không thể xoá, tài xế không tồn tại'
				rollback tran
				return 1
			end
		delete from TAIXE where @CMND = CMND
	end try

	begin catch
		print N'Lỗi hệ thống!'
		rollback tran
		return 1
	end catch
commit tran
return 0
GO
/****** Object:  StoredProcedure [dbo].[usp_xoaThucPham]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- usp_xoaThucPham
create -- alter
proc [dbo].[usp_xoaThucPham]
		@MaTP varchar(10),
		@MaDT varchar(10)
as
begin transaction
	begin try
		-- Kiểm tra thông tin nhập không đượcc rỗng.
		if (@MaTP = '' or
			@MaDT = '')
			begin
				print N'Thông tin nhập không được rỗng'
				rollback tran
				return 1
			end
		if exists(select * from CHITIETDONDATHANG where MaTP = @MaTP and
			MaDT = @MaDT)
			begin
				print N'Không thể xoá, món ăn đã từng được lên đơn'
				rollback tran
				return 1
			end
		-- Kiểm tra tồn tại
		if not exists(select * from THUCPHAM where MaTP = @MaTP and
			MaDT = @MaDT)
			begin
				print N'Không thể xoá, món ăn không tồn tại'
				rollback tran
				return 1
			end
		delete from THUCPHAM where MaTP = @MaTP and
			MaDT = @MaDT
	end try

	begin catch
		print N'Lỗi hệ thống!'
		rollback tran
		return 1
	end catch
commit tran
return 0
GO
/****** Object:  StoredProcedure [dbo].[XoaChiNhanh]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create -- alter
proc [dbo].[XoaChiNhanh]
	@MaDT varchar(10),
	@STT int
as 
	begin tran
		begin try
			if @MaDT='' or @STT =''
			begin
				print N'Thông tin trống'
				rollback tran
				select 1
				return
			end
			if not exists(select* from DOITAC where MaDT=@MaDT)
			begin
				print N'Mã đối tác không tồn tại'
				rollback tran
				select 2 
				return
			end
			if not exists(select STT from CHINHANH where MaDT=@MaDT and @STT = STT)
			begin
				print N'Số thứ tự không tồn tại'
				rollback tran
				select 5
				return
			end
			delete CHINHANH 
				where MaDT = @MaDT and STT = @STT
			update DoiTac
			set SLChiNhanh=SLChiNhanh-1
			where @MaDT=MaDT



		end try
		begin catch
			print N'Lỗi hệ thống!'
			ROLLBACK TRAN
			select 10
			return 
		END CATCH
COMMIT TRAN
select 0 
return
GO
/****** Object:  StoredProcedure [dbo].[xoaDoiTac]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[xoaDoiTac]
	@MaDT varchar(10)
as
begin tran xoaDoiTac
	set tran isolation level serializable
	-- Kiểm tra thông tin nhập không được rỗng.
	if (@MaDT = '')
	begin
		print N'Thông tin nhập không được rỗng'
		rollback tran xoaDoiTac
		return 1
	end
	-- Kiểm tra tồn tại
	-- Thiết lập update lock thay vì shared lock khi đọc
	if not exists(select * from DOITAC with (updlock) where MaDT = @MaDT)
	begin
		print N'Không thể xoá, đối tác không tồn tại'
		rollback tran xoaDoiTac
		return 1
	END
    delete from CHITIETDONDATHANG where MaDT = @MaDT
	delete from THUCPHAM where MaDT = @MaDT
	delete from CHINHANH where MaDT = @MaDT
	delete from HOPDONG where MaDT = @MaDT
	delete from DOITAC where MaDT = @MaDT
commit tran xoaDoiTac
return 0
GO
/****** Object:  StoredProcedure [dbo].[XoaThucPham]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Xóa thực phẩm
create -- create
proc [dbo].[XoaThucPham]
		@MaTP varchar(10),
		@MaDT varchar(10)
as
begin transaction
	begin try
		-- Kiểm tra thông tin nhập không đượcc rỗng.
		if (@MaTP = '' or
			@MaDT = '')
			begin
				print N'Thông tin nhập không được rỗng'
				rollback tran
				select 1
				return
			end
		if exists(select * from CHITIETDONDATHANG where MaTP = @MaTP and
			MaDT = @MaDT)
			begin
				print N'Không thể xoá, món ăn đã từng được lên đơn'
				rollback tran
				select 5
				return 
			end
		-- Kiểm tra tồn tại
		if not exists(select * from THUCPHAM where MaTP = @MaTP and
			MaDT = @MaDT)
			begin
				print N'Không thể xoá, món ăn không tồn tại'
				rollback tran
				select 6
				return
			end
		delete from THUCPHAM where MaTP = @MaTP and
			MaDT = @MaDT
	end try

	begin catch
		print N'Lỗi hệ thống!'
		rollback tran
		select 10
		return 
	end catch
commit tran
select 0
return 
GO
/****** Object:  StoredProcedure [dbo].[XoaUser]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[XoaUser]
	@user char(15)
as
BEGIN TRAN
	BEGIN TRY
		IF (@user = '')
		BEGIN
			Print N'Username không được bỏ trống'
			ROLLBACK TRAN
		END
		IF not exists (SELECT * FROM USERS WHERE Username = @user)
		BEGIN
			Print N'Username không tồn tại!'
			ROLLBACK TRAN
		END
		exec sp_droplogin @user

	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO
/****** Object:  StoredProcedure [dbo].[XuHuongBan]    Script Date: 11/12/2022 20:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create -- alter 
proc [dbo].[XuHuongBan]
	@madt varchar(10)
as
	begin try		
		select tp.MaDT, tp.MaTP, tp.TenMon,
			(select COUNT(MaDH) from CHITIETDONDATHANG ct where ct.MaTP = tp.MaTP and ct.MaDT = tp.MaDT and DanhGia = 'Like') Like_,
			(dbo.DemSoLuongBan(tp.MaTP,tp.MaDT)) Ban
		from THUCPHAM tp
		where MaDT =@madt

	end try
		
	begin catch
	end catch
GO
