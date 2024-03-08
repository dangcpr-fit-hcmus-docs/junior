use QLTaiKhoan
go
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
go