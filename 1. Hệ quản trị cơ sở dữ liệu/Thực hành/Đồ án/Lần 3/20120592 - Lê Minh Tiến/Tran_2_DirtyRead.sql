USE GIAONHANHANG
GO
--Khi T1 đang cập nhật giá: 
--T2: Tìm kiếm thực phẩm: MaTP: 01, MaDT: 0001
Exec sp_TimKiemThucPham '01','0001'

--kết quả: Khi update do giá không hợp lệ nên dữ liệu rollback. Do đó dữ liệu T2 đọc được trước đó là dữ liệu rác.
