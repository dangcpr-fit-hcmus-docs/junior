USE GIAONHANHANG
GO
/*Tranh chấp 2 - Conversion Deadlock*/
--Người làm: 20120269 - Võ Văn Minh Đoàn

--T2 xóa đối tác có mã 0005
exec xoaDoiTac '0005'
select * from DoiTac