use QLSV
go
--4: Truy vấn

--4.1:
select *
from SinhVien sv
join Lop l on sv.maLop = l.ma
join Khoa k on l.maKhoa = k.ma
where k.tenKhoa = N'Công nghệ thông tin' and l.maKhoaHoc = 'K2002'

--4.2:
select sv.ma, sv.hoTen, sv.namSinh
from SinhVien sv
join Lop l on sv.maLop = l.ma
join KhoaHoc kh on l.maKhoaHoc = kh.ma
where kh.namBatDau - sv.namSinh < 18

--4.3:
select *
from SinhVien sv
join Lop l on sv.maLop = l.ma
join Khoa k on l.maKhoa = k.ma
where k.tenKhoa = N'Công nghệ thông tin' and
	l.maKhoaHoc = 'K2002'  and not exists (
		select *
		from KetQua kq
		join MonHoc mh on kq.maMonHoc = mh.ma
		where mh.tenMonHoc = N'Cấu trúc dữ liệu 1' and kq.maSinhVien = sv.ma)

--4.4:
select sv.ma, sv.hoTen, sv.namSinh
from SinhVien sv
join KetQua kq on sv.ma = kq.maSinhVien
join MonHoc mh on kq.maMonHoc = mh.ma
where kq.diem < 5 and mh.tenMonHoc = N'Cấu trúc dữ liệu 1'
and not exists (
	select * 
	from KetQua kq2 
	where kq2.maSinhVien = kq.maSinhVien and kq2.lanThi > 1)

--4.5:
select l.ma, l.maKhoaHoc, ct.tenChuongTrinh, count(*) as 'soSV'
from Lop l
join ChuongTrinh ct on l.maChuongTrinh = ct.ma
join SinhVien sv on l.ma = sv.maLop
where l.maKhoa = 'CNTT'
group by l.ma, l.maKhoaHoc, ct.tenChuongTrinh

--4.6:
select avg(kq.diem) as 'DiemTB'
from KetQua kq
where kq.maSinhVien = '0212001' and lanthi = (
	select max(lanthi) 
	from KetQua kq2 
	where kq2.maMonHoc = kq.maMonHoc and kq2.maSinhVien = kq.maSinhVien)
go
--5: Function:

--5.1:
create function F_checkSVthuocKhoa 
(
	@maSV varchar(10),
	@maKhoa varchar(10)
)
returns varchar(4)
as
begin
	declare @check varchar(4)
	declare @Khoa varchar(10)
	set @Khoa = (select l.maKhoa
		from SinhVien sv
		join Lop l on sv.maLop = l.ma
		where sv.ma = @maSV)
	if (@Khoa = @maKhoa) set @check = N'Đúng'
	else set @check = N'Sai'
	return @check
end
go

declare @check varchar(10)
set @check = dbo.F_checkSVthuocKhoa('0212001', 'CNTT')
print @check
go

--5.2:
create function F_diemSauCung 
(
	@maSV varchar(10),
	@maMonHoc varchar(10)
)
returns float
as
begin
	declare @diem float
	set @diem = (
		select kq.diem
		from KetQua kq
		where kq.maSinhVien = @maSV and kq.maMonHoc = @maMonHoc
		and kq.lanThi = (
			select max(kq2.lanthi)
			from KetQua kq2
			where kq2.maSinhVien = kq.maSinhVien and kq2.maMonHoc = kq.maMonHoc
		)
	)
	return @diem
end
go

declare @diem float
set @diem = dbo.F_diemSauCung('0212003', 'THCS01')
print @diem 
go

--5.3:
create function f_DiemTB(
	@maSV varchar(10)
)
returns float
as
begin
	declare @diemtb float

	select @diemtb = avg(dbo.F_diemSauCung(sv.ma, mh.ma))
	from SinhVien sv
	join Lop l on sv.maLop = l.ma
	join MonHoc mh on l.maKhoa = mh.maKhoa
	where sv.ma = @maSV

	return @diemtb
end
go

select dbo.f_DiemTB('0212001')
go

--5.4:
create function F_diemCacLanThi 
(
	@maSV varchar(10),
	@maMonHoc varchar(10)
)
returns table as return (
	select 
        kq.lanThi, kq.diem
    FROM
        KetQua kq
    WHERE
        kq.maSinhVien = @maSV and kq.maMonHoc = @maMonHoc
)
go

select * from F_diemCacLanThi('0212003', 'THCS01')
go

--5.5:
create function F_cacMonPhaiHoc
(
	@maSV varchar(10)
)
returns table as return (
	select mh.ma, mh.maKhoa, mh.tenMonHoc
	from SinhVien sv
	join Lop l on sv.maLop = l.ma
	join MonHoc mh on l.maKhoa = mh.maKhoa
	where sv.ma = @maSV
)
go

select * from F_cacMonPhaiHoc('0312001')
go
--6: Store Procedure

--6.1:
create proc SP_dssvLop (
	@maLop varchar(10)
)
as
begin
	select *
	from SinhVien sv
	where sv.maLop = @maLop
end
go

exec SP_dssvLop 'TH2002/01'
go

--6.2
create proc SP_diemCaoHon (
	@maSV1 varchar(10),
	@maSV2 varchar(10),
	@maMH varchar(10)
)
as
begin
	declare @diem1 float = 0, @diem2 float = 0
	set @diem1 = (select kq.diem from KetQua kq where kq.maSinhVien = @maSV1 and kq.maMonHoc = @maMH and kq.lanThi = 1)
	set @diem2 = (select kq.diem from KetQua kq where kq.maSinhVien = @maSV2 and kq.maMonHoc = @maMH and kq.lanThi = 1)
	if (@diem1 > @diem2)
		print N'Sinh viên có mã ' + @maSV1 + N' có điểm thi lần 1 môn có mã ' + @maMH + ' cao hơn sinh viên có mã ' + @maSV2
	else if (@diem1 < @diem2)
		print N'Sinh viên có mã ' + @maSV2 + N' có điểm thi lần 1 môn có mã ' + @maMH + ' cao hơn sinh viên có mã ' + @maSV1
	else
		print N'Sinh viên có mã ' + @maSV1 + N' có điểm thi lần 1 môn có mã ' + @maMH + ' bằng sinh viên có mã ' + @maSV2
end
go

exec SP_diemCaoHon '0212001','0212003','THCS01'
go

--6.3:
create proc SP_dauRot (
	@maSV varchar(10),
	@maMH varchar(10)
)
as
begin
	declare @diem float = NULL
	set @diem = (select kq.diem from KetQua kq where kq.maSinhVien = @maSV and kq.maMonHoc = @maMH and kq.lanThi = 1)
	if (@diem >= 5)
		print N'Đậu'
	else if (@diem < 5)
		print N'Rớt'
	else if (@diem is null)
		print N'Không có dữ liệu'
end
go

exec SP_dauRot '0212004','THCS01'
go

--6.4:
create proc SP_dssvKhoa (
	@maKhoa varchar(10)
)
as
begin
	select sv.ma, sv.hoTen, sv.namSinh
	from SinhVien sv
	join Lop l on sv.maLop = l.ma
	where l.maKhoa = @maKhoa
end
go

exec SP_dssvKhoa 'VL'
go

--6.5:
create proc SP_dsKetQuaThi (
	@maSV varchar(10),
	@maMH varchar(10)
)
as
begin
	declare @index int = 1, @soLanThi int = 0, @diemThi float
	set @soLanThi = (select count(*) from KetQua kq where kq.maSinhVien = @maSV and kq.maMonHoc = @maMH)
	if (@soLanThi = 0)
	begin
		print N'Thí sinh không thi môn này'
		return
	end
	while (@index <= @soLanThi)
	begin
		set @diemThi = (select kq.diem from KetQua kq where kq.maSinhVien = @maSV and kq.maMonHoc = @maMH and kq.lanThi = @index)
		print N'Lần ' + CAST(@index AS varchar(2)) + ': ' + CAST(@diemThi AS varchar(4))
		set @index = @index + 1
	end
end
go

exec SP_dsKetQuaThi '0212003', 'THCS01'
go

--6.6:
create proc SP_cacMonPhaiHoc
(
	@maSV varchar(10)
)
as
begin
	select mh.ma, mh.maKhoa, mh.tenMonHoc
	from SinhVien sv
	join Lop l on sv.maLop = l.ma
	join MonHoc mh on l.maKhoa = mh.maKhoa
	where sv.ma = @maSV
end
go

exec SP_cacMonPhaiHoc '0212003'
go

--6.7:
create proc SP_dsDauMonLanDau (
	@maMH varchar(10)
)
as
begin
	select sv.ma, sv.hoTen, sv.namSinh
	from SinhVien sv
	join KetQua kq on sv.ma = kq.maSinhVien
	where kq.maMonHoc = @maMH and kq.lanThi = 1 and kq.diem >= 5
end
go

exec SP_dsDauMonLanDau 'THT01'
go

--6.8.1:
create proc SP_inDiem (
	@maSV varchar(10)
)
as
begin
	select kq.maSinhVien, kq.maMonHoc, kq.lanThi, kq.diem
	from KetQua kq
	where kq.maSinhVien = @maSV and lanthi = (
		select max(lanthi) 
		from KetQua kq2 
		where kq2.maMonHoc = kq.maMonHoc and kq2.maSinhVien = kq.maSinhVien)
end
go

--6.8.2:
create proc SP_inDiemNULL (
	@maSV varchar(10)
)
as
begin
	select sv.ma as MaSV, mh.ma as MaMonHoc, kq.diem
	from SinhVien sv
	join Lop l on sv.maLop = l.ma and sv.ma = @maSV
	left join MonHoc mh on l.maKhoa = mh.maKhoa
	left join KetQua kq on sv.ma = kq.maSinhVien and kq.maMonHoc = mh.ma
		and lanthi = (
			select max(lanthi) 
			from KetQua kq2 
			where kq2.maMonHoc = kq.maMonHoc and kq2.maSinhVien = kq.maSinhVien)
end
go

exec SP_inDiemNULL '0212004'
go

--6.8.3:
create proc SP_inDiemReplaceNULL (
	@maSV varchar(10)
)
as
begin
	select sv.ma as MaSV, mh.ma as MaMonHoc, isnull(cast(kq.diem as nvarchar(14)), N'<Chưa có điểm>') as Diem
	from SinhVien sv
	join Lop l on sv.maLop = l.ma and sv.ma = @maSV
	left join MonHoc mh on l.maKhoa = mh.maKhoa
	left join KetQua kq on sv.ma = kq.maSinhVien and kq.maMonHoc = mh.ma
		and lanthi = (
			select max(lanthi) 
			from KetQua kq2 
			where kq2.maMonHoc = kq.maMonHoc and kq2.maSinhVien = kq.maSinhVien)
end
go

exec SP_inDiemReplaceNULL '0212001'
go

--6.9
create table XepLoai(
	maSV varchar(10),
	diemTB float,
	ketQua nvarchar(12),
	hocLuc nvarchar(12)
	primary key (maSV)
)
go

create function f_SoMonDuoi4(
	@masv varchar(10)
)
returns float
as
begin
	declare @soMon int

	select @soMon = count(kq.diem)
	from KetQua kq 
	where kq.maSinhVien = @masv and kq.diem is not null and kq.diem < 4

	return @soMon
end
go

create proc SP_ThemBangHocLuc
as 
	insert into XepLoai(maSV, ketQua, hocLuc)
	select sv.ma, 
		case 
			when dbo.f_DiemTB(sv.ma)>=5 and dbo.f_SoMonDuoi4(sv.ma) <=2  then N'Đạt' else N'Không đạt' 
		end as ketQua,
		case 
			when dbo.f_DiemTB(sv.ma) >=8 then N'Giỏi'
			when dbo.f_DiemTB(sv.ma) >=7 then N'Khá'
			when dbo.f_DiemTB(sv.ma) >=5 then N'Trung bình'
		end
		as hocLuc
	from SinhVien sv
go

exec SP_ThemBangHocLuc
go

--6.10:
create proc SP_ThemDiemTrungBinh
as 
	update XepLoai
	set diemTB = dbo.f_DiemTB(sv.ma)
	from SinhVien sv
	where (select count(*) from dbo.F_cacMonPhaiHoc(sv.ma)) = (select count(kq.maMonHoc) from KetQua kq where sv.ma = kq.maSinhVien)
go

exec SP_ThemDiemTrungBinh
go

--7: RBTV

--7.1:
alter table ChuongTrinh
add constraint Check_maCT check (Ma = 'CQ' or Ma = 'CD' or Ma = 'TC')
go

--7.2:
alter table GiangKhoa
add constraint Check_HK check (hocKy = 1 or hocKy = 2)
go

--7.3:
alter table GiangKhoa
add constraint Check_soTietLT check (soTietLyThuyet <= 120)
go

--7.4:
alter table GiangKhoa
add constraint Check_soTietTH check (soTietThucHanh <= 120)
go

--7.5:
alter table GiangKhoa
add constraint Check_soTinChi check (soTinChi <= 6)
go

--7.6: Cách 1
create trigger Check_DiemLamTron 
on KetQua
for insert, update
as
	if exists (select i.diem FROM inserted I where i.diem <> round(i.diem * 2, 0)/2)
	BEGIN
		RAISERROR(N'Điểm chưa được làm tròn tới 0.5',16,1)
		ROLLBACK TRAN
	END
go

--7.6: Cách 2
create trigger Check_DiemLamTronReplaced
on KetQua
for insert, update
as
	if exists (select i.diem FROM inserted I where i.diem <> round(i.diem * 2, 0)/2)
	BEGIN
		update KetQua
		set diem = round(diem * 2, 0)/2
		where diem <> round(diem * 2, 0)/2
	END
go


--7.7:
alter table KhoaHoc
add constraint Check_namKTvaBD check (namKetThuc >= namBatDau)
go

--7.8:
alter table GiangKhoa
add constraint Check_soTietLTvaTH check (soTietLyThuyet >= soTietThucHanh)
go

--7.9:
alter table ChuongTrinh
add constraint Check_TenCTPhanBiet unique (tenChuongTrinh)
go

--7.10:
alter table Khoa
add constraint Check_TenKhoaPhanBiet unique (tenKhoa)
go

--7.11:
alter table MonHoc
add constraint Check_TenMonHocPhanBiet unique (tenMonHoc)
go

--7.12:
create trigger Check_ThiToiDa2Lan
on KetQua
for insert, update
as
	if (select count(*) FROM KetQua kq, inserted i where i.maSinhVien = kq.maSinhVien and i.maMonHoc = kq.maMonHoc) > 2
	BEGIN
		RAISERROR(N'Sinh viên đã thi quá 2 lần môn này',16,1)
		ROLLBACK TRAN
	END
go

--7.14:
create trigger check_NamBatDauVaNamRaDoi
ON KhoaHoc
FOR insert, update
AS
	if EXISTS (select * from inserted i
				join Lop l on i.ma = l.maKhoaHoc
				join Khoa k on l.maKhoa = k.ma
			   where l.maKhoa = k.ma AND i.namBatDau < k.namThanhLap) 
	begin
		raiserror(N'Năm bắt đầu khóa học của một lớp không thể nhỏ hơn năm thành lập của khoa quản lý lớp đó', 16, 1)
		rollback
	end
go

--7.15:
create trigger check_SVChiDangKyMonTheoCTVaKhoa
on KetQua
for insert, update
as
	if exists (select *
				from inserted i 
				join SinhVien sv on sv.ma = i.maSinhVien
				join Lop l on l.ma = sv.maLop
				where not exists (select gk.maMonHoc
									from GiangKhoa gk
									where gk.maChuongTrinh = l.maChuongTrinh
									and gk.maKhoa = l.maKhoa and i.maMonHoc = gk.maMonHoc))
	begin
		raiserror(N'Sinh viên chỉ được đăng kí những môn học thuộc chương trình và khoa của sinh viên theo học.',16,1)
		rollback tran
	end
go

--7.16:
--Em xin lỗi, em không biết làm, mong cô có thể chữa bài này giúp em