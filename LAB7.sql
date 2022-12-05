--Bai 1:Viết các hàm:
--➢ Nhập vào MaNV cho biết tuổi của nhân viên này.
go
create function fn_TuoiNV(@MaNV nvarchar(9))
returns int
as
begin
	return(select YEAR(getdate())-YEAR(NGSINH) as N'Tuổi'
		from NHANVIEN where MANV = @MaNV)
end
go
go
print 'Tuoi nhan vien:'+ convert(nvarchar,dbo.fn_TuoiNV('001'))

go

--➢ Nhập vào Manv cho biết số lượng đề án nhân viên này đã tham gia
go
create function fn_DemDeAnNV(@MaNV varchar(9))
returns int
as
	begin
		return(select COUNT(MADA) from PHANCONG where MA_NVIEN= @MaNV)
	end
go

go
print 'so Du an nhan vien da lam'+ convert(varchar, dbo.fn_DemDeAnNV('003'))
go
--➢ Truyền tham số vào phái nam hoặc nữ, xuất số lượng nhân viên theo phái
go
create function fn_DemNV_Phai(@Phai nvarchar(5)=N'%')
returns int
as 
	begin
		return(select COUNT(*) from NHANVIEN where PHAI like @phai)
	end
go

go
print 'So luong nhan vien nu:'+ convert(varchar, fn_DemNV_Phai(N'Nữ'))
go

--➢ Truyền tham số đầu vào là tên phòng, tính mức lương trung bình của phòng đó, Cho biết
--họ tên nhân viên (HONV, TENLOT, TENNV) có mức lương trên mức lương trung bình
--của phòng đó.
go
create function fn_Luong_NhanVien_PB(@TenPhongBan nvarchar(20))
returns @tbLuongNV table(fullname nvarchar(50),luong float)
as 
	begin
		declare @LuongTB float
		select @LuongTB = AVG(LUONG) from NHANVIEN
		inner join PHONGBAN on PHONGBAN.MAPHG = NHANVIEN.PHG
		where TENPHG = @TenPhongBan
		--print 'Luong Trung Binh:'+ convert(nvarchar,@LuongTB)
		--insert vao table
		insert into @tbLuongNV
			select HONV+ ''+TENLOT+''+TENNV, LUONG from NHANVIEN
			where LUONG > @LuongTB
		return
	end
go

--➢ Tryền tham số đầu vào là Mã Phòng, cho biết tên phòng ban, họ tên người trưởng phòng
--và số lượng đề án mà phòng ban đó chủ trì.
go
create function fn_SoLuongDeAnTheoPB(@MaPB int)
returns @tbListPB table(TenPB nvarchar(20),MaTB nvarchar(10), TenTP nvarchar(50), soluong int)
as
begin
	insert into @tbListPB
	select TENPHG,TRPHG,HONV+''+TENLOT+ ' ' + TENNV as 'Ten Truong Phog', COUNT(MADA) as 'SoLuongDeAn'
		from PHONGBAN
		inner join DEAN on DEAN.PHONG = PHONGBAN.MAPHG
		inner join NHANVIEN on NHANVIEN.MANV = PHONGBAN.TRPHG
		where PHONGBAN.MAPHG = @MaPB
		group by TENPHG,TRPHG,TENNV,HONV,TENLOT
	return
end
go

--Bài 2: 
--Tạo các view:
--➢ Hiển thị thông tin HoNV,TenNV,TenPHG, DiaDiemPhg.
go
create view v_DD_PhongBan
as
select HONV, TENNV, DIADIEM from PHONGBAN
inner join DIADIEM_PHG on DIADIEM_PHG.MAPHG = PHONGBAN.MAPHG
inner join NHANVIEN on NHANVIEN.PHG = PHONGBAN.MAPHG 

go

--➢ Hiển thị thông tin TenNv, Lương, Tuổi.
go
create view v_TuoiNV
as
select TENNV,LUONG,YEAR(GETDATE())-YEAR(NGSINH) as 'Tuoi' from NHANVIEN
go

--➢ Hiển thị tên phòng ban và họ tên trưởng phòng của phòng ban có đông nhân viên nhất
go
create view v_LuongNV_PB
as
select top(1) TENPHG,TRPHG,B.HONV+' '+B.TENLOT+' '+B.TENNV as 'TENTP',COUNT(A.MANV) as 'SoLuongNV' from NHANVIEN A 
inner join PHONGBAN on PHONGBAN.MAPHG = A.PHG
inner join NHANVIEN B on B.MANV = PHONGBAN.TRPHG
group by TENPHG,TRPHG,B.TENNV,B.HONV,B.TENLOT 
order by SoLuongNV desc
go