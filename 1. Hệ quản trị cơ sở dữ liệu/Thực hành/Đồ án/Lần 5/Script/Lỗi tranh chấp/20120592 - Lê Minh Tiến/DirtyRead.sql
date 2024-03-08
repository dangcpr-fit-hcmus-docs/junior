USE GIAONHANHANG
GO


--Dirty read: 
--Người làm:20120592-Lê Minh Tiến
--Tình huống: Đối tác đang cập nhật giá cho 1 thực phẩm,
--thì khách hàng tìm kiếm thông tin thực phẩm đó, nhưng 
--do giá đối tác nhập không hợp lệ (vô tình nhập số âm) dẫn đến Dirty read
--T1 (User = Đối tác): Cập nhật giá cho một loại thực phẩm
--T2 (User = Khách hàng): Tìm kiếm thông tin thực phẩm T1 đang cập nhật.

--T1: cập nhật giá cho 1 thực phẩm
create proc sp_CapNhatGiaTP
	@MaTP varchar(10),
	@MaDT varchar(10),
	@Gia decimal(10,1)
as
	begin tran 
	--Set mức cô lập
	set tran isolation level read uncommitted
	--Kiểm tra thực phẩm có tồn tại
	if not exists(select* from ThucPham
	where MaTP=@MaTP and MaDT=@MaDT)
	begin 
		print N'Thực phẩm này không tồn tại'
		rollback tran
		return 1
	end
	--Update giá cho thực phẩm
	update ThucPham
	set Gia=@Gia
	where MaTP=@MaTP and MaDT=@MaDT
	waitfor delay '0:0:10'
	--Kiểm tra giá có hợp lệ
	if @Gia<0
	begin
		print N'Giá không hợp lệ'
		rollback tran
		return 1
	end
COMMIT TRAN
return 0
GO
Exec sp_CapNhatGiaTP '01','0001',-50000

--T2: Tìm kiếm thực phẩm T1 đang cập nhật giá
create proc sp_TimKiemThucPham
	@MaTP varchar(10),
	@MaDT varchar(10)
AS
BEGIN TRAN
	--Set mức cô lập
	set tran isolation level read uncommitted
	--Kiểm tra tồn tại
	if not exists(select* from ThucPham
	where MaTP=@MaTP and MaDT=@MaDT)
	begin 
		print N'Thực phẩm này không tồn tại'
		rollback tran
		return 1
	end
	--Đọc thông tin thực phẩm
	select *from ThucPham where MaTP=@MaTP and MaDT=@MaDT 
COMMIT TRAN
return 0
GO

