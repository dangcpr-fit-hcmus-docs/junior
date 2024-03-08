use GIAONHANHANG
go

/*Tranh chấp 7 - Unrepeatable Read*/
--Người làm: 20120624 - Mai Quyết Vang
--T1: kiểm tra trạng thái đơn hàng đã đặt
--T2: cập nhật trạng thái đặt hàng

-- select * from DONDATHANG 
exec sp_TimKiemThucPham '5', '1' 


