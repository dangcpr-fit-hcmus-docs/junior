USE GIAONHANHANG
GO
/*Xử lý tranh chấp 2 - Conversion Deadlock*/
--Giải quyết tranh chấp bằng cách thiết lập update lock thay vì shared lock cho câu lệnh select do tại mỗi thời điểm chỉ được phát 1 update lock trên 1 đơn vị dữ liệu
--Người làm: 20120269 - Võ Văn Minh Đoàn
--T1: cập nhật thông tin đối tác
--T2: xóa đối tác

--T1
create proc capNhatDoiTac
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
go

--T2
create proc xoaDoiTac
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
	end
	delete from CHITIETDONDATHANG where MaDT = @MaDT
	delete from THUCPHAM where MaDT = @MaDT
	delete from CHINHANH where MaDT = @MaDT
	delete from HOPDONG where MaDT = @MaDT
	delete from DOITAC where MaDT = @MaDT
commit tran xoaDoiTac
return 0
go
