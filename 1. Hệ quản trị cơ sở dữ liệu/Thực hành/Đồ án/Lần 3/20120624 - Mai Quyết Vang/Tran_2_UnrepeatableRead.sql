use GIAONHANHANG
go

/*Tranh chấp 7 - Unrepeatable Read*/
--Người làm: 20120624 - Mai Quyết Vang
--T1: kiểm tra trạng thái đơn hàng đã đặt
--T2: cập nhật trạng thái đặt hàng

select * from THUCPHAM where MaDT = '1'
go
Exec XoaThucPham '5', '1' 
go
select * from THUCPHAM where MaDT = '1'
go

