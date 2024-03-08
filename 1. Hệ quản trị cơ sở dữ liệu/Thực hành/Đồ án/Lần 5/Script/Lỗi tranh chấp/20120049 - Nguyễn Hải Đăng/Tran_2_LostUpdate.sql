use GIAONHANHANG
go

--T2
select * from DONDATHANG d where d.MaDH = '13'
exec sp_DoiTacCapNhatTinhTrangDon_fix '13', N'Đã tiếp nhận'