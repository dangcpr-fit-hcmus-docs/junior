USE GIAONHANHANG
GO
--Khi T1 đang cập nhật giá: 
--T2: Tìm kiếm thực phẩm: MaTP: 01, MaDT: 0001
Exec sp_TimKiemThucPham '01','0001'

--kết quả: do đã đặt lại mức cô lập từ read uncommitted sang
--read committed nên lúc này T1 thực hiện hết giao tác T2 mới 
--có thể đọc.
--KHÔNG CÒN LỖI
