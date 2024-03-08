use QLTaiKhoan
go
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
