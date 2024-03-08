--T2
Use GIAONHANHANG
GO
--T2 (User = Quản trị viên): xóa user mà T1 đang tìm .
EXEC XoaUserQuanTri 'admin'
--Kết quả: T1 lần 1 đọc ra được user cần tìm kiếm, nhưng do T2 xóa user đó nên lần 2 T1 đọc được về dữ liệu trống. Như vậy 2 lần đọc của T1 cho dữ liệu trả về là khác nhau nhau dẫn đến unrepeatable read.


--Xảy ra Unrepeatable Read



