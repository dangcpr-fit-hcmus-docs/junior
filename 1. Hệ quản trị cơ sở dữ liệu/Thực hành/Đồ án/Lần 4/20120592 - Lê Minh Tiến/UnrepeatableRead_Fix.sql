Use GIAONHANHANG
GO

--Unrepeatable Read:
--Người thực hiện: 20120592- Lê Minh Tiến

Tình huống: Quản trị viên đầu tìm kiếm một user bằng username, lúc đầu kiểm tra thì user đó có tồn tại, tại thời điểm đó
quản trị viên khác thực hiện thao tác xóa user đó, khiến các trường trong username Quản trị viên tìm trả về bị trống
dẫn đến Unrepeatable Read.
T1 (User = Quản trị viên): tìm kiếm 1 user qua username.
T2 (User = Quản trị viên): xóa user mà T1 đang tìm .*/


--T1:
CREATE PROC DoiTac_TimKiemUser
	@Username varchar(20)
AS
BEGIN TRAN DoiTac_TimKiemUser
	set tran isolation level Repeatable Read
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM USERS WHERE Username = @Username)
		BEGIN
			Print @Username + N' không tồn tại!'
			ROLLBACK TRAN DoiTac_TimKiemUser
		END
		Waitfor delay '00:00:10'
		Select * from USERS where Username = @Username
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN DoiTac_TimKiemUser
	END CATCH
COMMIT TRAN DoiTac_TimKiemUser
GO
EXEC DoiTac_TimKiemUser 'admin'
--T2:
create proc XoaUserQuanTri
	@user char(15)
as
BEGIN TRAN XoaUserQuanTri
	set tran isolation level Repeatable Read
	BEGIN TRY
		IF (@user = '')
		BEGIN
			Print N'Username không được bỏ trống'
			ROLLBACK TRAN XoaUserQuanTri
		END
		IF not exists (SELECT * FROM USERS WHERE Username = @user)
		BEGIN
			Print N'Username không tồn tại!'
			ROLLBACK TRAN XoaUserQuanTri
		END
		Delete from QuanTri where Username=@user
		Delete from USERS  where Username=@user
	END TRY
	BEGIN CATCH
		print N'Lỗi hệ thống!'
		ROLLBACK TRAN XoaUserQuanTri
	END CATCH
COMMIT TRAN XoaUserQuanTri
GO
EXEC XoaUserQuanTri 'admin'

--Do đổi mức cô lập từ read uncommitted sang repeatable read nên khi T2 yêu cầu khóa S trên USERS thì không được cấp và phải chờ T1 commit thì T2 mới được phát khóa. Sau khi T1 đọc xong 2 lần T2 mới được cấp khóa S nên dữ liệu ở 2 lần đọc của T1 là không khác nhau. Vì vậy, không xảy ra repeatable read. 

