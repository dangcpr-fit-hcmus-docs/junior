use QLTaiKhoan
go
CREATE PROC UpdateData 
	@MaTK varchar(10), 
	@NgayLap date, 
	@SoDu bigint, 
	@TrangThai nvarchar(9)
AS
	DECLARE @check int
	SET @check = 0
	IF (NOT EXISTS(SELECT MaTK FROM TaiKhoan WHERE MaTK = @MaTK))
	BEGIN
		print @MaTK + N' không tồn tại!'
		SET @check = 1
		RETURN @check
	END
	IF (@NgayLap IS NULL)
	BEGIN
		print N'Ngày lập không hợp lệ!'
		SET @check = 1
		RETURN @check
	END
	IF (@SoDu <= 100000)
	BEGIN
		print N'Số dư không hợp lệ!'
		SET @check = 1
		RETURN @check
	END
	IF (@TrangThai != N'Đang dùng' AND @TrangThai != N'Đã khóa' AND @TrangThai != N'Bị hủy')
	BEGIN
		print N'Trạng thái không hợp lệ!'
		SET @check = 1
		RETURN @check
	END
	UPDATE TaiKhoan
	SET	NgayLap = @NgayLap, SoDu = @SoDu, TrangThai = @TrangThai
	WHERE MaTK = @MaTK
	RETURN @check
GO

SELECT * from TaiKhoan
exec UpdateData '10006', '2022-08-09', 82500, N'Bị hủy'
SELECT * from TaiKhoan
go

SELECT * from TaiKhoan
exec UpdateData '10002', '2022-08-09', 82500, N'Bị hủy'
SELECT * from TaiKhoan
go

SELECT * from TaiKhoan
exec UpdateData '10003', NULL, 82500, N'Bị hủy'
SELECT * from TaiKhoan
go

SELECT * from TaiKhoan
exec UpdateData '10000', '2021-10-10', 200500, N'abc'
SELECT * from TaiKhoan
go

SELECT * from TaiKhoan
exec UpdateData '10001', '2021-10-08', 125000, N'Đã khóa'
SELECT * from TaiKhoan
go

SELECT * from TaiKhoan
exec UpdateData '50000', '2021-10-10', 125000, N'Đã khóa'
SELECT * from TaiKhoan
go