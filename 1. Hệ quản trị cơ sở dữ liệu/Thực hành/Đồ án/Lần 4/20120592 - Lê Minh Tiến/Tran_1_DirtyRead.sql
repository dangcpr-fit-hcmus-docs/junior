USE GIAONHANHANG
GO
--T1: Cập nhật giá cho thực phẩm có MaTP: 01, MaDT: 0001 với giá -50000
select* from ThucPham
Exec sp_CapNhatGiaTP '01','0001',-50000
