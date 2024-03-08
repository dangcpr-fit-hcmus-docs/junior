use GIAONHANHANG
go

/*Tranh chấp 8 - Cycle Deadlock*/
--Người làm: 20120624 - Mai Quyết Vang
--T1: cập nhật thông tin đối tác
--T2: xóa đối tác

-- select * from CHITIETDONDATHANG
exec sp_capNhatDonHang '01', '01', '0004', 2
go