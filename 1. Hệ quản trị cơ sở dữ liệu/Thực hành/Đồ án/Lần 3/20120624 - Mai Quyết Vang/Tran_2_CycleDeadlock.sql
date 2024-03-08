use GIAONHANHANG
go

/*Tranh chấp 8 - Cycle Deadlock*/
--Người làm: 20120624 - Mai Quyết Vang
--T1: cập nhật số lượng của món ăn trong đơn hàng
--T2: thêm món ăn vào đơn hàng

-- select * from CHITIETDONDATHANG
-- select * from CHITIETDONDATHANG
exec sp_themChiTietDonHang '01', '01', '0004', 5
go