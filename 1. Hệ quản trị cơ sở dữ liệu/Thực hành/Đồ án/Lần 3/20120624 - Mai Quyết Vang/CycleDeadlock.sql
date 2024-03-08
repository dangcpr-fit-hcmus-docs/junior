use GIAONHANHANG
go

/*Tranh chấp 8 - Cycle Deadlock*/
--Người làm: 20120624 - Mai Quyết Vang
--T1: cập nhật số lượng của món ăn trong đơn hàng
--T2: thêm món ăn vào đơn hàng

create -- alter
proc sp_capNhatDonHang
		@MaDH varchar(10), @MaTP varchar(10), @MaDT varchar(10),@SoLuong varchar(10)
as
begin transaction
	begin try
		-- Kiểm tra thông tin (1) đơn hàng

		-- B1: Kiểm tra thông tin (1) đơn hàng
		IF NOT EXISTS (SELECT * FROM DONDATHANG A WHERE A.MaDH=@MaDH)
		BEGIN
			print N'Đơn hàng này không tồn tại'
			rollback tran
			return 1
		END
		-- B2: Kiểm tra thông tin (2) thực phẩm
		IF NOT EXISTS (SELECT * FROM THUCPHAM A WHERE A.MaTP=@MaTP and A.MaDT=@MaDT)
		BEGIN
			print N'Thực phẩm này không tồn tại'
			rollback tran
			return 1 
		END
		-- B3: Cập nhật tổng giá của đơn đặt hàng
		declare @SLCu int
		declare @DonGia int
		set @SLCu = (select SoLuong from CHITIETDONDATHANG where MaDH = @MaDH and MaTP = @MaTP and MaDT = @MaDT)
		set @DonGia = (select Gia from THUCPHAM where MaTP = @MaTP and MaDT = @MaDT)
		UPDATE DONDATHANG 
		SET GiaTriDH = GiaTriDH + (@SoLuong - @SLCu)*@DonGia
		WHERE MaDH=@MaDH 
		WAITFOR DELAY '00:00:20'

		-- B4: Cập nhật số lượng của chi tiết đơn hàng
		UPDATE CHITIETDONDATHANG 
		SET SoLuong = @SoLuong
		WHERE MaDH = @MaDH and MaTP = @MaTP and MaDT = @MaDT
	end try
	begin catch
		print N'Lỗi hệ thống!'
		rollback tran
		return 1
	end catch
commit tran
return 0
go



create -- alter
proc sp_themChiTietDonHang
		@MaDH varchar(10), @MaTP varchar(10), @MaDT varchar(10),@SoLuong varchar(10)
as
begin transaction
	begin try

	-- B1: Kiểm tra thông tin (1) đơn hàng
	IF NOT EXISTS (SELECT * FROM DONDATHANG A WHERE A.MaDH=@MaDH)
	BEGIN
		print N'Đơn hàng này không tồn tại'
		rollback tran
		return 1
	END
	-- B2: Kiểm tra thông tin (2) thực phẩm
	IF NOT EXISTS (SELECT * FROM THUCPHAM WHERE MaTP=@MaTP and MaDT=@MaDT)
	BEGIN
		print N'Thực phẩm này không tồn tại'
		rollback tran
		return 1 
	END
	-- B3: Cập nhật số lượng hoặc thêm món ăn vào đơn đặt hàng
	IF EXISTS (SELECT * FROM THUCPHAM WHERE MaTP=@MaTP and MaDT=@MaDT)
	BEGIN
		UPDATE CHITIETDONDATHANG 
		SET SoLuong = @SoLuong
		WHERE MaDH = @MaDH and MaTP = @MaTP and MaDT = @MaDT
	END
	ELSE 
	BEGIN
		INSERT INTO CHITIETDONDATHANG 
		VALUES (@MaDH, @MaTP, @MaDT, @SoLuong, NULL)
	END
	WAITFOR DELAY '00:00:20'

	
	declare @SLCu int
	declare @DonGia int
	set @SLCu = (select SoLuong from CHITIETDONDATHANG where MaDH = @MaDH and MaTP = @MaTP and MaDT = @MaDT)
	set @DonGia = (select Gia from THUCPHAM where MaTP = @MaTP and MaDT = @MaDT)
	-- B4: Cập nhật tổng giá của đơn đặt hàng
	UPDATE DONDATHANG 
	SET GiaTriDH = GiaTriDH + (@SoLuong - @SLCu)*@DonGia
	WHERE MaDH=@MaDH


	end try

	begin catch
		print N'Lỗi hệ thống!'
		rollback tran
		return 1
	end catch
commit tran
return 0
go