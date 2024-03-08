use GIAONHANHANG
GO

--T1: (Khách hàng) hủy đơn hàng
create proc sp_KhachHangHuyDon_fix (
	@MaDonDH varchar(10)
)
as
set tran isolation level repeatable read
begin tran
	--Kiểm tra thông tin trống không
	IF (@MaDonDH='')
	BEGIN 
		PRINT N'Thông tin trống'
		ROLLBACK TRAN
		RETURN 1
	END

	--Kiểm tra xem mã đối tác tồn tại chưa
	IF NOT EXISTS (select* from DONDATHANG where MaDH = @MaDonDH)
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

EXEC sp_KhachHangHuyDon_fix '3'

--T2: (Đối tác) cập nhật tình trạng đơn hàng
create proc sp_DoiTacCapNhatTinhTrangDon_fix (
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
go

