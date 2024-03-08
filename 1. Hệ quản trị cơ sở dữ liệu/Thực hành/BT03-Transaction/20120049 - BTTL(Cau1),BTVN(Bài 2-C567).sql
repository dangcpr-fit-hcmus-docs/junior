use QLTaiKhoan
go

/*20120049 - Nguyen Hai Dang*/
/* Bai tap tren lop */
--Cau 1
create proc SPT_SoDuTaiKhoan(
	@MaTK numeric(18,0)
)
as
begin transaction
	begin try
	if @MaTK not in (select MaTK from TaiKhoan)
		print N'Mã tài khoản ' + cast(@MaTK as nchar(5)) + N' không tồn tại'
		rollback transaction
		return
	end try

	BEGIN CATCH
		PRINT N'Lỗi tra cứu'
		ROLLBACK TRANSACTION
	END CATCH

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
	commit transaction
go

exec SoDuTaiKhoan 10001
exec SoDuTaiKhoan 10002
exec SoDuTaiKhoan 10003
exec SoDuTaiKhoan 10006
go

/* Bai 2 */
use QLDT
go
-- Cau 5: Insert
/*
	Input: MAGV, MADT, STT, PHUCAP, KETQUA.
	Output: 1 - Them thanh cong, 0 -  Them khong thanh cong.
	- Kiem tra MAGV co ton tai khong.
		+ Neu khong ton tai: xuat thong bao, thoat.
	- Kiem tra MADT kem STT tuong ung co ton tai khong.
		+ Neu khong ton tai: xuat thong bao, thoat.
	- Them de tai.
		+ Ket qua chi co the la DAT hoac NULL, neu khong bao loi, thoat
		+ Neu de tai DAT thi KETQUA = DAT
		+ Nguoc lai KETQUA = NULL
		+ Neu truong @KetQua bo trong thi mac dinh la NULL (khong dat)
*/
create proc SP_ThemThamGiaDT (
	@MAGV char(3),
	@MADT char(3),
	@STT int,
	@PhuCap decimal(2,1),
	@KetQua nvarchar(4) = NULL
)
as
begin tran
	begin try
		if not exists (select * from GIAOVIEN gv where gv.MAGV = @MAGV)
		begin
			print N'Giáo viên không tồn tại'
			rollback transaction
			return 0
		end
		if not exists (select * from CONGVIEC cv where cv.MADT = @MADT and cv.SOTT = @STT)
		begin
			print N'Đề tài và số thứ tự tương ứng không tồn tại'
			rollback transaction
			return 0
		end
		if (@KetQua <> N'Đạt' and @KetQua is not null)
		begin
			print N'Kết quả đề tài không phù hợp'
			rollback transaction
			return 0
		end
	end try

	BEGIN CATCH
		PRINT N'Lỗi thêm tham gia đề tài'
		return 0
		ROLLBACK TRANSACTION
	END CATCH

	insert THAMGIADT values (@MAGV, @MADT, @STT, @PhuCap, @KetQua)
	commit transaction
	return 1
go

exec SP_ThemThamGiaDT '008','001',1,3.0
exec SP_ThemThamGiaDT '008','001',2,3.0,N'Đạt'
exec SP_ThemThamGiaDT '008','001',1,3.0,'aaa'
exec SP_ThemThamGiaDT '012','001',1,3.0,'aaa'
exec SP_ThemThamGiaDT '008','001',10,3.0,'aaa'
go

-- Cau 6: Update
/*
	Input: MAGV, MADT, STT, PhuCapUpdate, KetQuaUpdate.
	Output: 1 - Them thanh cong, 0 -  Them khong thanh cong.
	- Kiem tra input co ton tai trong bang THAMGIADT khong
		+ Neu khong: bao loi thoat
	- Kiem tra MADT kem STT tuong ung co ton tai khong.
		+ Neu khong ton tai: xuat thong bao, thoat.
	- Cap nhat thong tin
		+ Ket qua chi co the la DAT hoac NULL, neu khong bao loi, thoat
		+ Neu truong @KetQuaUpdate bo trong thi mac dinh la NULL (khong dat)
*/
create proc SP_UpdateThamGiaDT (
	@MAGV char(3),
	@MADT char(3),
	@STT int,
	@PhuCapUpdate decimal(2,1),
	@KetQuaUpdate nvarchar(4) = NULL
)
as
begin tran
	begin try
		if not exists (select * from THAMGIADT TGDT where TGDT.MAGV = @MAGV and TGDT.MADT = @MADT and TGDT.STT = @STT)
		begin
			print N'Thông tin tham gia đề tài không tồn tại'
			rollback transaction
			return 0
		end
		if (@KetQuaUpdate <> N'Đạt' and @KetQuaUpdate is not null)
		begin
			print N'Kết quả đề tài không phù hợp'
			rollback transaction
			return 0
		end
	end try

	BEGIN CATCH
		PRINT N'Lỗi cập nhật tham gia đề tài'
		return 0
		ROLLBACK TRANSACTION
	END CATCH

	update THAMGIADT
	set PHUCAP = @PhuCapUpdate, KETQUA = @KetQuaUpdate
	where MAGV = @MAGV and MADT = @MADT and STT = @STT
	commit transaction
	return 1
go

exec SP_UpdateThamGiaDT '008','001',2,2.0,N'Đạt'
exec SP_UpdateThamGiaDT '008','001',2,2.0,'aaa'
go

-- Cau 7: Delete
/*
	Input: MAGV, MADT, STT
	Output: 1 - Them thanh cong, 0 -  Them khong thanh cong.
	- Kiem tra input co ton tai trong bang THAMGIADT khong
		+ Neu khong: bao loi thoat
	- Xoa thong tin
*/
create proc SP_XoaThamGiaDT (
	@MAGV char(3),
	@MADT char(3),
	@STT int
)
as
begin tran
	begin try
		if not exists (select * from THAMGIADT TGDT where TGDT.MAGV = @MAGV and TGDT.MADT = @MADT and TGDT.STT = @STT)
		begin
			print N'Thông tin tham gia đề tài không tồn tại'
			rollback transaction
			return 0
		end
	end try

	BEGIN CATCH
		PRINT N'Lỗi xoá tham gia đề tài'
		return 0
		ROLLBACK TRANSACTION
	END CATCH

	DELETE FROM THAMGIADT WHERE MADT = @MADT and MAGV = @MAGV and STT = @STT
	commit transaction
	return 1
go

exec SP_XoaThamGiaDT '008', '001', 1
exec SP_XoaThamGiaDT '008', '001', 3