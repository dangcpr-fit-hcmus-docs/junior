CREATE DATABASE BT2
GO
USE BT2
GO

create table Lop
(
	MaLop varchar(10),
	NamBD smallint,
	NamKT smallint,
	SiSo smallint,
	primary key (MaLop),
)
create table SinhVien
(
	MaSV varchar(8),
	HoTen nvarchar(30),
	NamSinh smallint,
	GioiTinh nvarchar(3),
	DiemTB float,
	MaLop varchar(10),
	primary key (MaSV),
	foreign key (MaLop) references Lop(MaLop)
)
create table GiaoVien
(
	MaGV varchar(8),
	HoTen nvarchar(30),
	NgaySinh date,
	LoaiGV nvarchar(15),
	primary key (MaGV)
)
create table MonHoc
(
	MaMH varchar(8),
	TenMH nvarchar(40),
	SoChi smallint,
	primary key (MaMH)
)
create table KetQua
(
	MaSV varchar(8),
	MaMH varchar(8),
	LanThi nvarchar(7),
	Diem float,
	primary key (MaSV,MaMH,LanThi),
	foreign key (MaSV) references SinhVien(MaSV),
	foreign key (MaMH) references MonHoc(MaMH)
)
create table GV_Lop
(
	MaLop varchar(10),
	MaMH varchar(8),
	MaGV varchar(8),
	primary key (MaLop,MaMH),
	foreign key (MaLop) references Lop(MaLop),
	foreign key (MaMH) references MonHoc(MaMH),
	foreign key (MaGV) references GiaoVien(MaGV)
) 

insert into Lop values('20CTT2',2020,2021,110)
insert into Lop values('21CTT2',2021,2022,123)
insert into Lop values('22CTT2',2022,2023,104)

insert into SinhVien values('20120269',N'Võ Văn Minh Đoàn',2002,'Nam',8.9,'20CTT2')
insert into SinhVien values('21120049',N'Nguyễn Hải Đăng',2003,'Nam',9.3,'21CTT2')
insert into SinhVien values('22120592',N'Lê Minh Tiến',2004,'Nam',8.8,'22CTT2')

insert into GiaoVien values('GV01',N'Lê Minh Nghĩa','1989-08-03',N'Chính thức')
insert into GiaoVien values('GV02',N'Nguyễn Thị Thảo','1992-12-10',N'Thỉnh giảng')
insert into GiaoVien values('GV03',N'Trần Thanh Bình','1984-02-03',N'Chính thức')

insert into MonHoc values('CSC12003',N'Hệ quản trị cơ sở dữ liệu',4)
insert into MonHoc values('CSC12109',N'Hệ thống thông tin doanh nghiệp',4)
insert into MonHoc values('CSC13002',N'Nhập môn công nghệ phần mềm',4)

insert into KetQua values('20120269','CSC12003',N'Cuối kỳ',10)
insert into KetQua values('21120049','CSC12109',N'Giữa kỳ',10)
insert into KetQua values('22120592','CSC13002',N'Cuối kỳ',10)

insert into GV_Lop values('20CTT2','CSC12003','GV01')
insert into GV_Lop values('21CTT2','CSC12109','GV02')
insert into GV_Lop values('22CTT2','CSC13002','GV03')

--Slide đầu tiên

--Câu 1-4: 20120269 - Võ Văn Minh Đoàn
--1: 
exec sp_addlogin 'GV01', '123456'
exec sp_addlogin 'GV02', '123456'
exec sp_addlogin 'GV03', '123456'
exec sp_addlogin 'SV01', '123456'
exec sp_addlogin 'SV02', '123456'
exec sp_addlogin 'SV03', '123456'
go
--2
create user SV01 for login SV01
create user SV02 for login SV02
create user SV03 for login SV03
go
create view sp_grantsv as select HoTen, NamSinh, GioiTinh from SinhVien
go
GRANT select, update
ON sp_grantsv
TO SV01,SV02,SV03
go
--3
create role GiaoVien
create role QuanLi
go
--4
create user GV01 for login GV01
create user GV02 for login GV02
create user GV03 for login GV03
exec sp_addrolemember 'QuanLi', 'GV01'
exec sp_addrolemember 'GiaoVien', 'GV02'
exec sp_addrolemember 'GiaoVien', 'GV03'
go
--Câu 5-7: 20120049 - Nguyễn Hải Đăng
--5: Giáo viên được xem thông tin tất cả môn học
GRANT select
ON MonHoc
TO GiaoVien
go

--6: Giáo viên được thêm một kết quả và cập nhật điểm của môn học do mình phụ trách.
GRANT insert, update
ON KetQua
TO GiaoVien
go

--7: Quản lí được xem, cập nhật, thêm thông tin môn học, sinh viên và được phép cấp các quyền cho user khác.
GRANT select, update, insert
ON MonHoc
TO QuanLi
WITH GRANT OPTION
go

GRANT select, update, insert
ON SinhVien
TO QuanLi
WITH GRANT OPTION
go

--Slide tiếp theo--

--Câu 1-4: 20120592 - Lê Minh Tiến
--1. Tất cả các sinh viên đều được phép xem thông tin các môn học hiện có ở trường.
--Cách 1:
--create role SinhVien
--exec sp_addrolemember 'SinhVien', 'SV01'
--exec sp_addrolemember 'SinhVien', 'SV02'
--exec sp_addrolemember 'SinhVien', 'SV03'
--Grant select
--on MonHoc
--to SinhVien
--Nhược điểm là khi cấm quyền một user nào đó trong role thì phải xóa user đó khỏi role
--Cách 2:
Grant select
on MonHoc
to SV01,SV02,SV03
go

--2. Giáo viên GV03 không còn giản dạy ở trường. Hãy hủy các quyền đã cấp cho GV03.
Exec sp_droprolemember 'GiaoVien', 'GV03'
revoke select on MonHoc from GV03
revoke all on KetQua from GV03
go

--3. Cấm quyền truy cập thông tin của SV03.
deny select on MonHoc to SV03
deny update on sp_grantsv to SV03
go

--4. Thêm GV01 vào nhóm sysadmin.
Exec sp_addsrvrolemember 'GV01','sysadmin'
go

--Câu 5-7: 20120624 - Mai Quyết Vang
-- 5. Có thể cập nhật lại mật khẩu của login GV03 thành '111111' được không? Ai được phép thực hiện?
exec sp_password '123456',' 111111', 'GV03'
go
-- Chỉ sysadmin	và securityadmin mới có quyền cập nhật mật khẩu

-- 6. Cấp toàn quyền thao tác trên CSDL cho GV01.
grant all privileges to GV01
go

-- 7. Cấp quyền thực thi các thủ tục usp_TinhDiem cho GV02.
grant usp_TinhDiem to GV02