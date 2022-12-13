GO
CREATE DATABASE QLSV
GO
GO
USE  QLSV
GO

CREATE TABLE Lop(
Malop varchar(5) NOT NULL PRIMARY KEY,
TenLop nvarchar(20) NOT NULL,
SiSo int NOT NULL
)

CREATE TABLE Sinhvien(
MaSV int NOT NULL PRIMARY KEY,
Hoten nvarchar(30) NOT NULL,
Ngaysinh Date,
Malop varchar(5) NOT NULL FOREIGN KEY REFERENCES Lop(Malop)
)

CREATE TABLE MonHoc(
MaMH varchar(5) NOT NULL PRIMARY KEY,
TenMH nvarchar(20) NOT NULL
)

CREATE TABLE KetQua(
MaSV int NOT NULL FOREIGN KEY REFERENCES Sinhvien(MaSV),
MaMH varchar(5) NOT NULL FOREIGN KEY REFERENCES MonHoc(MaMH),
Diemthi float NOT NULL,
CONSTRAINT ketqua_pk PRIMARY KEY (MaSV,MaMH)
)

insert Lop values
('a','lop a',0),
('b','lop b',0),
('c','lop c',0)
insert Sinhvien values
(1,'Le Minh','2000-1-1','a'),
(2,'Le Hung','2001-11-1','a'),
(3,'Le Tri','2001-12-12','a')
insert MonHoc values
('PPLT','Phuong phap LT'),
('CSDL','Co so du lieu'),
('SQL','He quan tri CSDL'),
('PTW','Phat trien Web')
insert KetQua values
(1,'PPLT',8),
(1,'SQL',7),
(2,'PPLT',8),
(1,'CSDL',5),
(2,'PTW',5)
--Cau 1
go
create function diemTB (@Masv int)
returns float
as
begin  
DECLARE @DiemTB float
SET @DiemTB= (SELECT AVG(Diemthi) from KetQua where MaSV = @Masv group by MaSV )
return @DiemTB 
end
go
go
--test
print dbo.diemTB (1)
go
--Cau 2
go
create function trbinhlop(@malop char(5))
returns table
as
return
 select s.masv, Hoten, trungbinh=dbo.diemTB(s.MaSV)
 from Sinhvien s join KetQua k on s.MaSV=k.MaSV
 where MaLop=@malop

 group by s.masv, Hoten
go

go
--test
select*from trbinhlop('a')
go

--cau 3
go
create proc ktra @msv char(5)
as
begin 
 declare @n int
 set @n=(select count(*) from KetQua where Masv=@msv)
 if @n=0 
 print 'sinh vien '+@msv + 'khong thi mon nao'
 else
 print 'sinh vien '+ @msv+ 'thi '+cast(@n as char(2))+ 'mon'
end 
go
exec ktra '01'

--cau 4

go
create trigger updatesslop
on Sinhvien
for insert
as
begin
 declare @ss int
 set @ss=(select count(*) from Sinhvien s 
 where Malop in(select Malop from inserted))
 if @ss>10
 begin
 print 'Lop day'
 rollback tran
 end
 else
 begin
 update Lop
 set SiSo=@ss
 where Malop in (select Malop from inserted)
 end

 --cau 5

 create login user1 with password = '123'
create login user2 with password = '456'

create user user1 for login user1
create user user2 for login user2

-- cau 6

grant Insert, Update on Sinhvien to user1
grant select on Sinhvien to user2
