use GIAONHANHANG
go

--T1: (Khách hàng) xem danh sách đối tác
create proc sp_DSDoiTac
as
begin tran
	select * from DOITAC
	waitfor delay '0:0:10'
	select * from DOITAC
commit
go

--T2: (Đối tác) Đăng ký thông tin - insert thông tin trong bảng DOITAC
create proc sp_ThemDoiTac (
	@MaDT varchar(10),
	@Email varchar(30),
	@NgDaiDien nvarchar(30),
	@SLChiNhanh smallint,
	@TenQuan nvarchar(30),
	@LoaiTP nvarchar(30)
)
as
begin tran

	--Kiểm tra thông tin trống không
	if (@MaDT='' or @Email='' or @NgDaiDien='' or @SLChiNhanh='' or @TenQuan='')
	begin 
		print N'Thông tin trống'
		rollback tran
		return 1
	end

	--Kiểm tra xem mã đối tác tồn tại chưa
	if exists(select* from DOITAC where MaDT = @MaDT)
	begin 
		print N'Mã đối tác đã tồn tại'
		rollback tran
		return 1
	end

	insert into DOITAC values (@MaDT, @Email, @NgDaiDien, @SLChiNhanh, @TenQuan, @LoaiTP)
commit