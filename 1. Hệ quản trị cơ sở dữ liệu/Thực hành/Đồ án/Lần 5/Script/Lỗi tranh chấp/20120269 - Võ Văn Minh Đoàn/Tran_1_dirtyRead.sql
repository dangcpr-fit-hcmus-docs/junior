USE GIAONHANHANG
GO
/*Tranh chấp 1 - Dirty Read*/
--Người làm: 20120269 - Võ Văn Minh Đoàn
/*T1 đang thêm khách hàng có mã 0010
T2 tìm kiếm và xem thông tin khách hàng có mã 0010
Sau đó, T1 bị rollback do số điện thoại bị trùng
-> T2 đọc dữ liệu rác*/

--Thêm dữ liệu vào bảng KHACHHANG để demo
insert into KHACHHANG values ('0009',N'Trần Hữu Thiên',N'85,Tôn Đức Thắng,Q.1,TP.HCM','0123456846','ththien85@gmail.com')

--T1 thêm khách hàng có mã 0010
exec themKhachHang '0010',N'Nguyễn Thành Nam',N'72,Tôn Đức Thắng,Q.1,TP.HCM','0123456846','ntnam72@gmail.com'
--Kiểm tra lại
select * from KHACHHANG where MaKH = '0010'