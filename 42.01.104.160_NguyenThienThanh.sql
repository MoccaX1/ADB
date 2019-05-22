/*----------------------------------------------------------
MASV: 42.01.104.160
HO TEN: Nguyễn Thiện Thanh
MA ĐE: 2    - CA THI: Sáng thứ 3
----------------------------------------------------------*/

use QLSinhvien
GO
--Câu1
create procedure themMHOC
@mamh varchar(10), @tenmh nvarchar(100), @tinchi int, @makhoa varchar(10)
AS
    BEGIN  
        insert into Monhoc
        VALUES (@mamh, @tenmh, @tinchi, @makhoa)
    END
drop procedure themMHOC

exec themMHOC 'HH11003', N'Hóa đại cương 3', 15, 'Hoa'
go

--Câu2
create TRIGGER tg_kosua_MHOCtrongHPHAN ON Hocphan
for UPDATE
as 
    BEGIN
    DECLARE @mamh varchar(10)
    select @mamh=MaMh from Monhoc 
        IF update(MaMh)
        begin
            RAISERROR(N'Không thể sửa',15,1)
            ROLLBACK TRAN
            RETURN
        end
    END

DROP TRIGGER tg_kosua_MHOCtrongHPHAN;

update Monhoc
set TenMh=N'Hóa Đại Cương A1'
WHERE MaMh='HH0001'
GO

select * from Monhoc
GO

--Câu3
create procedure sp_dsHocphan @gvien nvarchar(100)
as
begin
	Declare curDSHP cursor for
	select MaHp, hp.MaMh, mh.TenMh from Hocphan hp join Monhoc mh on hp.MaMh=mh.MaMh where hp.Giangvien = @gvien order by MaHp

	open curDSHP
	declare @mahp varchar(10), @mamh varchar(10), @tenmh nvarchar(100)

	fetch next from curDSHP
	into @mahp, @mamh, @tenmh
	
	while @@FETCH_STATUS = 0
	begin
		print(N'Mã học phần: ' + @mahp + N', 
        Mã môn học: ' + @mamh +N',
        Tên môn học: ' + @tenmh)

		fetch next from curDSHP
		into @mahp, @mamh, @tenmh
	end
	--đóng cursor--
	close curDSHP
	--hủy cursor--
	deallocate curDSHP
end


drop procedure sp_dsHocphan
exec sp_dsHocphan N'N.D.Lâm'
go