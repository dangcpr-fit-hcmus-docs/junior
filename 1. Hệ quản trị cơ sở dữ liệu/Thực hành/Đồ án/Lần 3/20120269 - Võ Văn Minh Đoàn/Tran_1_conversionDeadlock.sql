USE GIAONHANHANG
GO
/*Tranh chấp 2 - Conversion Deadlock*/
--Người làm: 20120269 - Võ Văn Minh Đoàn

/*T1 đang cập nhật đối tác có mã 0005
T2 xóa đối tác có mã 0005 -> T1, T2 ban đầu cùng giữ khóa S và T1, T2 cùng chuyển sang khóa X nên xảy ra conversion deadlock*/

--Thêm đối tác có mã 0005 để demo
insert into DOITAC values ('0005','0005@gmail.com',N'Nguyên Văn Kí',0,N'Cơm Nguyên Kí',N'Cơm')
--T1 cập nhật đối tác có mã 0005
exec capNhatDoiTac '0005','0005@gmail.com',N'Vũ Văn Long',0,N'Coffee Long',N'Cà phê'