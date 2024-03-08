use GIAONHANHANG
go

/*Tranh chấp 7 - Unrepeatable Read*/
--Người làm: 20120624 - Mai Quyết Vang
--T1: kiểm tra trạng thái đơn hàng đã đặt
--T2: cập nhật trạng thái đặt hàng
create -- alter
proc sp_TimKiemThucPham_fix
		@MaTP varchar(10),
		@MaDT varchar(10)
as
begin transaction
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ 
	begin try
		-- Kiểm tra thông tin (1) đơn hàng
		IF @MaDT = '' or @MaTP = ''
		begin
			print N'Thông tin không được trống'
			rollback tran
			return 1
		end

		IF NOT EXISTS (SELECT * FROM THUCPHAM WHERE MaTP=@MaTP and MaDT = @MaDT)
		begin
			print N'Thực phẩm này không tồn tại'
			rollback tran
			return 1
		end

		WAITFOR DELAY '00:00:10'
		
		SELECT * FROM THUCPHAM WHERE MaTP=@MaTP and MaDT = @MaDT

	end try

	begin catch
		print N'Lỗi hệ thống!'
		rollback tran
		return 1
	end catch
commit tran
return 0
go


--Xóa thực phẩm
create -- alter
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