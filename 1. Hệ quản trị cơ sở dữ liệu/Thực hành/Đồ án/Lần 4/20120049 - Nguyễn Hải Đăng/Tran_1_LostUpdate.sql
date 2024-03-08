use GIAONHANHANG
go

--T1
select * from DONDATHANG d where d.MaDH = '001'
exec sp_KhachHangHuyDon_fix '001'