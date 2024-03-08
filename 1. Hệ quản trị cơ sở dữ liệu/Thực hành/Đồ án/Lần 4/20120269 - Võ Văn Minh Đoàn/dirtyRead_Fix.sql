USE GIAONHANHANG
GO
/*Xử lý tranh chấp 1 - Dirty Read*/
--Giải quyết tình huống tranh chấp bằng cách đổi mức cô lập 2 giao tác từ read uncommitted sang read committed
--Người làm: 20120269 - Võ Văn Minh Đoàn
--T1: thêm 1 khách hàng
--T2: tìm kiếm 1 khách hàng

--T1
create proc themKhachHang
	@MaKH varchar(10),
	@HoTen nvarchar(30),
	@DiaChi nvarchar(100),
	@SDT char(10),
	@Email varchar(30),
	@Username VARCHAR(20)
as
begin tran themKhachHang
	set tran isolation level read committed
	-- Kiểm tra thông tin rỗng
	if (@MaKH='' or @HoTen='' or @DiaChi='' or @SDT='' or @Email='' OR @Username='')
	begin 
		print N'Thông tin trống'
		SELECT 1
		rollback tran themKhachHang
	end
	-- Kiểm tra mã khách hàng đã tồn tại chưa
	if exists(select* from KHACHHANG where MaKH=@MaKH)
	begin 
		print N'Mã khách hàng đã tồn tại'
		SELECT 2
		rollback tran themKhachHang
	end

	-- Kiểm tra số điện thoại bị trùng
	if exists(select * from KHACHHANG where SDT = @SDT and MaKH != @MaKH)
	begin
		print N'Số điện thoại bị trùng!'
		SELECT 3
		rollback tran themKhachHang
	END
    	insert into KHACHHANG values(@MaKH,@HoTen,@DiaChi,@SDT,@Email,@Username)
	waitfor delay '0:0:10'
COMMIT TRAN themKhachHang
SELECT 0
GO

--T2
CREATE PROC timKiemKhachHang
	@MaKH varchar(10)
AS
BEGIN TRAN timKiemKhachHang
	set tran isolation level read committed
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
