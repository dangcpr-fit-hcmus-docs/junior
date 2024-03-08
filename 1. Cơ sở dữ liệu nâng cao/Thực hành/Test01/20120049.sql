-----Bài làm
---Câu 1
CREATE FUNCTION SOMATHANGNCC (
	@MANCC char(6)
)
RETURNS INT
AS
BEGIN
	DECLARE @SOMATHANG INT = 0
	SET @SOMATHANG = (SELECT COUNT(DISTINCT MaMatHang) FROM CUNG_UNG WHERE MaNhaCungCap = @MANCC)
	RETURN @SOMATHANG
END
go
DECLARE @SOMH INT, @MANCC char(6)
SET @MANCC = 'NCC003'
EXEC @SOMH = SOMATHANGNCC @MANCC
print N'Số mặt hàng của nhà cung ứng ' + @MANCC + N' là ' + cast(@SOMH as char(3))
go

---Câu 2a
CREATE TRIGGER TR_DATHANG ON CHI_TIET_DAT_HANG
FOR INSERT
AS
	IF NOT EXISTS (
		SELECT *
		FROM inserted I
		JOIN DAT_HANG DH ON  DH.SoMatHang = I.SoDatHang
		WHERE EXISTS (
			SELECT *
			FROM CUNG_UNG CU
			WHERE DH.MaNhaCungCap = CU.MaNhaCungCap))
		BEGIN
			RAISERROR('Không thể đặt hàng mà nhà cung cấp không cung ứng',16,1)
			ROLLBACK TRAN
		END
GO
INSERT CHI_TIET_DAT_HANG VALUES ('DH0001','MH0002', 5, 200000)
GO
--Câu 2b
CREATE TRIGGER TR_KIEMTRATONGSOTIEN ON DAT_HANG
FOR INSERT
AS
	IF EXISTS (SELECT *
			FROM inserted i 
			WHERE I.ThanhTien != (SELECT SUM(CTDH.SoLuongDat * CTDH.DonGiaDat)
							FROM CHI_TIET_DAT_HANG CTDH
							WHERE CTDH.SoDatHang=I.So
							GROUP BY CTDH.SoDatHang))

			BEGIN
				RAISERROR(N'Thành tiền không hợp lệ, phải = Tổng (Số lượng đặt * đơn giá đặt)',16,1)
				ROLLBACK TRAN
			END
GO

--Câu 3
CREATE PROC PROC_GIAOHANG (
	@SOGH char(6),
	@NGAYGIAO datetime,
	@SODATHANG char(6),
	@MAMATHANG char(6),
	@SLGIAO int
)
AS
BEGIN
	IF ((SELECT COUNT(*) FROM GIAO_HANG WHERE SoDatHang = @SODATHANG) > 3)
		PRINT N'Đã quá số lần giao'
	ELSE IF EXISTS (
		SELECT *
		FROM 
END