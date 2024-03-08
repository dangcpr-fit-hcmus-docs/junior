use GIAONHANHANG
go

--T1: (Khách hàng) xem danh sách đối tác
create proc sp_DSDoiTac
as
begin tran
	select [MaDT],[Email],[NgDaiDien],[SLChiNhanh],[TenQuan],[LoaiTP] from DOITAC
	waitfor delay '0:0:10'
	select [MaDT],[Email],[NgDaiDien],[SLChiNhanh],[TenQuan],[LoaiTP] from DOITAC
commit
go

--T2: (Đối tác) Đăng ký thông tin - insert thông tin trong bảng DOITAC
CREATE PROC sp_ThemDoiTac (
	@MaDT VARCHAR(10),
	@Email VARCHAR(30),
	@NgDaiDien NVARCHAR(30),
	@SLChiNhanh SMALLINT,
	@TenQuan NVARCHAR(30),
	@LoaiTP NVARCHAR(30),
	@Username VARCHAR(20)
)
AS
BEGIN TRAN sp_ThemDoiTac
		BEGIN TRY
			IF @MaDT='' OR @Email='' OR @NgDaiDien=''  OR @TenQuan='' OR @LoaiTP=''
			BEGIN 
				PRINT N'Thông tin trống'
				SELECT 1
				ROLLBACK TRAN ThemDoiTac
			END
			IF EXISTS(SELECT* FROM DoiTac WHERE MaDT=@MaDT)
			BEGIN
				PRINT N'Mã đối tác đã tồn tại'
				SELECT 2
				ROLLBACK TRAN ThemDoiTac
			END
			INSERT INTO DOITAC VALUES(@MaDT,@Email,@NgDaiDien,@SLChiNhanh,@TenQuan,@LoaiTP,@Username)
		end try
		begin catch
			print N'Lỗi hệ thống!'
			ROLLBACK TRAN sp_ThemDoiTac
		END CATCH
COMMIT TRAN sp_ThemDoiTac
select 0
GO