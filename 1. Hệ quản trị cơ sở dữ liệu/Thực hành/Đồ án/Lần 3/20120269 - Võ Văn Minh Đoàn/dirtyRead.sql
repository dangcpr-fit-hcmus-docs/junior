USE GIAONHANHANG
GO
/*Tranh chấp 1 - Dirty Read*/
--Người làm: 20120269 - Võ Văn Minh Đoàn
--T1: thêm 1 khách hàng
--T2: tìm kiếm 1 khách hàng

--T1
create proc themKhachHang
	@MaKH varchar(10),
	@HoTen nvarchar(30),
	@DiaChi nvarchar(100),
	@SDT char(10),
	@Email varchar(30)
as
begin tran
	set tran isolation level read uncommitted
	-- Kiểm tra thông tin rỗng
	if (@MaKH='' or @HoTen='' or @DiaChi='' or @SDT='' or @Email='')
	begin 
		print N'Thông tin trống'
		rollback tran
		return 1
	end
	-- Kiểm tra mã khách hàng đã tồn tại chưa
	if exists(select* from KHACHHANG where MaKH=@MaKH)
	begin 
		print N'Mã khách hàng đã tồn tại'
		rollback tran
		return 1
	end
	insert into KHACHHANG values(@MaKH,@HoTen,@DiaChi,@SDT,@Email)
	waitfor delay '0:0:10'
	-- Kiểm tra số điện thoại bị trùng
	if exists(select * from KHACHHANG where SDT = @SDT and MaKH != @MaKH)
	begin
		print N'Số điện thoại bị trùng!'
		rollback tran
		return 1
	end
COMMIT TRAN
RETURN 0
GO

--T2
CREATE PROC timKiemKhachHang
	@MaKH varchar(10)
AS
BEGIN TRAN
	set tran isolation level read uncommitted
	IF NOT EXISTS (SELECT * FROM KHACHHANG WHERE MaKH = @MaKH)
	BEGIN
		Print @MaKH + N' không tồn tại!'
		ROLLBACK TRAN
		RETURN 1
	END
	SELECT * FROM KHACHHANG WHERE MaKH = @MaKH
COMMIT TRAN
RETURN 0
GO
