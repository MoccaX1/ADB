use QLBongDa
go
------Create user-------
--BDAdmin
create login BDAdmin with PASSWORD = 'qwe123!@#'
GO
create user BDAdmin for login BDAdmin;
GO
--BDBK
create login BDBK with PASSWORD = 'qwe123!@#'
GO
create user BDBK for login BDBK;
GO
--BDRead
create login BDRead with PASSWORD = 'qwe123!@#'
GO
create user BDRead for login BDRead;
GO

--BDU01
create login BDU01 with PASSWORD = 'qwe123!@#'
GO
create user BDU01 for login BDU01;
GO

--BDU02
create login BDU02 with PASSWORD = 'qwe123!@#'
GO
create user BDU02 for login BDU02;
GO

--BDU03
create login BDU03 with PASSWORD = 'qwe123!@#'
GO
create user BDU03 for login BDU03;
GO

--BDU04
create login BDU04 with PASSWORD = 'qwe123!@#'
GO
create user BDU04 for login BDU04;
GO

--BDProfile
create login BDProfile with PASSWORD = 'qwe123!@#'
GO
create user BDProfile for login BDProfile
GO

------Database Role-----
--BDAdmin
EXEC sp_addrolemember 'db_owner', 'BDAdmin'

--BDBK
EXEC sp_addrolemember 'db_backupoperator', 'BDBK'

--BDRead
EXEC sp_addrolemember 'db_datareader', 'BDRead'

--BDU01
grant create table to BDU01
go

--BDU02
grant update to BDU02
go

--BDU03
grant select, insert, delete, update on dbo.CAULACBO to BDU03
go

--BDU04
grant select, insert, delete, update on dbo.CAUTHU to BDU04
deny select on dbo.CAUTHU(NGAYSINH) to BDU04
deny update on dbo.CAUTHU(VITRI) to BDU04
go

--BDProfile
use master
go
GRANT ALTER TRACE TO BDProfile 
go
use QLBongDa
go

------Drop user-------
drop user BDAdmin
drop user BDBK
drop user BDRead
drop user BDU01
drop user BDU02
drop user BDU03
drop user BDU04
drop user BDProfile
go

------Drop login-------
drop login BDAdmin
drop login BDBK
drop login BDRead
drop login BDU01
drop login BDU02
drop login BDU03
drop login BDU04
drop login BDProfile
go

----drop user is currently logged in ----
-- select id --
SELECT session_id
FROM sys.dm_exec_sessions
WHERE login_name = 'BDU02'
---kill login by id ---
KILL 63

---- test----
create table abc
(Test int)
go

--Result of user permission
/*
Security Audit Report
1) List all access provisioned to a sql user or windows user/group directly 
2) List all access provisioned to a sql user or windows user/group through a database or application role
3) List all access provisioned to the public role

Columns Returned:
UserName        : SQL or Windows/Active Directory user cccount.  This could also be an Active Directory group.
UserType        : Value will be either 'SQL User' or 'Windows User'.  This reflects the type of user defined for the 
                  SQL Server user account.
DatabaseUserName: Name of the associated user as defined in the database user account.  The database user may not be the
                  same as the server user.
Role            : The role name.  This will be null if the associated permissions to the object are defined at directly
                  on the user account, otherwise this will be the name of the role that the user is a member of.
PermissionType  : Type of permissions the user/role has on an object. Examples could include CONNECT, EXECUTE, SELECT
                  DELETE, INSERT, ALTER, CONTROL, TAKE OWNERSHIP, VIEW DEFINITION, etc.
                  This value may not be populated for all roles.  Some built in roles have implicit permission
                  definitions.
PermissionState : Reflects the state of the permission type, examples could include GRANT, DENY, etc.
                  This value may not be populated for all roles.  Some built in roles have implicit permission
                  definitions.
ObjectType      : Type of object the user/role is assigned permissions on.  Examples could include USER_TABLE, 
                  SQL_SCALAR_FUNCTION, SQL_INLINE_TABLE_VALUED_FUNCTION, SQL_STORED_PROCEDURE, VIEW, etc.   
                  This value may not be populated for all roles.  Some built in roles have implicit permission
                  definitions.          
ObjectName      : Name of the object that the user/role is assigned permissions on.  
                  This value may not be populated for all roles.  Some built in roles have implicit permission
                  definitions.
ColumnName      : Name of the column of the object that the user/role is assigned permissions on. This value
                  is only populated if the object is a table, view or a table value function.                 
*/

--List all access provisioned to a sql user or windows user/group directly 
SELECT  
    [UserName] = CASE princ.[type] 
                    WHEN 'S' THEN princ.[name]
                    WHEN 'U' THEN ulogin.[name] COLLATE Latin1_General_CI_AI
                 END,
    [UserType] = CASE princ.[type]
                    WHEN 'S' THEN 'SQL User'
                    WHEN 'U' THEN 'Windows User'
                 END,  
    [DatabaseUserName] = princ.[name],       
    [Role] = null,      
    [PermissionType] = perm.[permission_name],       
    [PermissionState] = perm.[state_desc],       
    [ObjectType] = obj.type_desc,--perm.[class_desc],       
    [ObjectName] = OBJECT_NAME(perm.major_id),
    [ColumnName] = col.[name]
FROM    
    --database user
    sys.database_principals princ  
LEFT JOIN
    --Login accounts
    sys.login_token ulogin on princ.[sid] = ulogin.[sid]
LEFT JOIN        
    --Permissions
    sys.database_permissions perm ON perm.[grantee_principal_id] = princ.[principal_id]
LEFT JOIN
    --Table columns
    sys.columns col ON col.[object_id] = perm.major_id 
                    AND col.[column_id] = perm.[minor_id]
LEFT JOIN
    sys.objects obj ON perm.[major_id] = obj.[object_id]
WHERE 
    princ.[type] in ('S','U')
UNION
--List all access provisioned to a sql user or windows user/group through a database or application role
SELECT  
    [UserName] = CASE memberprinc.[type] 
                    WHEN 'S' THEN memberprinc.[name]
                    WHEN 'U' THEN ulogin.[name] COLLATE Latin1_General_CI_AI
                 END,
    [UserType] = CASE memberprinc.[type]
                    WHEN 'S' THEN 'SQL User'
                    WHEN 'U' THEN 'Windows User'
                 END, 
    [DatabaseUserName] = memberprinc.[name],   
    [Role] = roleprinc.[name],      
    [PermissionType] = perm.[permission_name],       
    [PermissionState] = perm.[state_desc],       
    [ObjectType] = obj.type_desc,--perm.[class_desc],   
    [ObjectName] = OBJECT_NAME(perm.major_id),
    [ColumnName] = col.[name]
FROM    
    --Role/member associations
    sys.database_role_members members
JOIN
    --Roles
    sys.database_principals roleprinc ON roleprinc.[principal_id] = members.[role_principal_id]
JOIN
    --Role members (database users)
    sys.database_principals memberprinc ON memberprinc.[principal_id] = members.[member_principal_id]
LEFT JOIN
    --Login accounts
    sys.login_token ulogin on memberprinc.[sid] = ulogin.[sid]
LEFT JOIN        
    --Permissions
    sys.database_permissions perm ON perm.[grantee_principal_id] = roleprinc.[principal_id]
LEFT JOIN
    --Table columns
    sys.columns col on col.[object_id] = perm.major_id 
                    AND col.[column_id] = perm.[minor_id]
LEFT JOIN
    sys.objects obj ON perm.[major_id] = obj.[object_id]
UNION
--List all access provisioned to the public role, which everyone gets by default
SELECT  
    [UserName] = '{All Users}',
    [UserType] = '{All Users}', 
    [DatabaseUserName] = '{All Users}',       
    [Role] = roleprinc.[name],      
    [PermissionType] = perm.[permission_name],       
    [PermissionState] = perm.[state_desc],       
    [ObjectType] = obj.type_desc,--perm.[class_desc],  
    [ObjectName] = OBJECT_NAME(perm.major_id),
    [ColumnName] = col.[name]
FROM    
    --Roles
    sys.database_principals roleprinc
LEFT JOIN        
    --Role permissions
    sys.database_permissions perm ON perm.[grantee_principal_id] = roleprinc.[principal_id]
LEFT JOIN
    --Table columns
    sys.columns col on col.[object_id] = perm.major_id 
                    AND col.[column_id] = perm.[minor_id]                   
JOIN 
    --All objects   
    sys.objects obj ON obj.[object_id] = perm.[major_id]
WHERE
    --Only roles
    roleprinc.[type] = 'R' AND
    --Only public role
    roleprinc.[name] = 'public' AND
    --Only objects of ours, not the MS objects
    obj.is_ms_shipped = 0
ORDER BY
    princ.[Name],
    OBJECT_NAME(perm.major_id),
    col.[name],
    perm.[permission_name],
    perm.[state_desc],
    obj.type_desc--perm.[class_desc] 


    use QLBongDa;
go





/* câu e*/
Create Proc SP_SEL_NO_ENCRYPT 
	@TenCLB nvarchar(100) ,
	@TenQG nvarchar(60)
as
	select ct.MACT N'Mã cầu thủ',ct.HOTEN N'Họ và tên',ct.NGAYSINH N'Ngày sinh',ct.DIACHI N'Địa chỉ',ct.VITRI N'Vị trí'
	from dbo.CAUTHU ct join dbo.CAULACBO clb on ct.MACLB = clb.MACLB
			 join dbo.QUOCGIA qg on ct.MAQG = qg.MAQG
	where clb.TENCLB = @TenCLB and qg.TENQG = @TenQG
go



/* câu f*/
Create Proc SP_SEL_ENCRYPT 
	@TenCLB nvarchar(100) ,
	@TenQG nvarchar(60) 
	with Encryption	
as
	select ct.MACT N'Mã cầu thủ',ct.HOTEN N'Họ và tên',ct.NGAYSINH N'Ngày sinh',ct.DIACHI N'Địa chỉ',ct.VITRI N'Vị trí'
	from dbo.CAUTHU ct join dbo.CAULACBO clb on ct.MACLB = clb.MACLB
			 join dbo.QUOCGIA qg on ct.MAQG = qg.MAQG
	where clb.TENCLB = @TenCLB and qg.TENQG = @TenQG
go


/*câu g*/
exec SP_SEL_NO_ENCRYPT N'SHB Đà Nẵng', N'Brazil';
go

exec SP_SEL_ENCRYPT N'SHB Đà Nẵng', N'Brazil';
go

sp_helptext SP_SEL_NO_ENCRYPT
go
sp_helptext SP_SEL_ENCRYPT
go


/* câu h */
/* Có nhiều cách để encrypt toàn bộ stored procedure trong database (Dùng SMO của Microsoft,chạy lện trên powershell,hoặc dùng lện replace)
	-- link tài liệu: https://docs.microsoft.com/en-us/sql/relational-databases/server-management-objects-smo/getting-started-in-smo?view=sql-server-2017
	-- ý chính là thêm -- with encryption vào từng lệnh procedure
	-- trường hợp này chọn cách dùng powreshell (đối với phiên bản 2008 trở lên)
	-- 1. (*)back up store procedure (có thể tạo script dùng task của ssms hoặc dùng source control)
	-- 2. Click vào database cần xử lý -> Programmability -> click chuột phải vào stored procedure chọn powershell( phải cài powershell trước nếu chư có)
	-- 3. chạy lệnh bênh dưới và đợi hoàn tất tiến trình (Thay engine name thành tên của engine object đang sử dụng)
		//
			$db = (new-Object Microsoft.SqlServer.Management.Smo.Server("[engine name]")).Databases.Item("[DataBase Name]") 
			Foreach ($sp in $db.StoredProcedures){
			  if(!$sp.IsSystemObject){
				if (!$sp.IsEncrypted){
					$sp.TextMode = $false;
					$sp.IsEncrypted = $true;
					$sp.TextMode = $true;
					try{
						$sp.Alter();
					}catch{
						Write-Host "$sp.Name fail to encrypted."
					}
				 }
			  }
			}			
		//
	-- 4. dùng sp_texthelp để check xem procedures đã được encrypt chưa , có thể dùng profiler để kiểm tra hoặc set plan routine để kiểm tra.
*/



/*  CÂU i */

Create View vCau1 
as
	select ct.MACT N'Mã cầu thủ',ct.HOTEN N'Họ và tên',ct.NGAYSINH N'Ngày sinh',ct.DIACHI N'Địa chỉ',ct.VITRI N'Vị trí'
	from dbo.CAUTHU ct join dbo.CAULACBO clb on ct.MACLB = clb.MACLB
			 join dbo.QUOCGIA qg on ct.MAQG = qg.MAQG
	where clb.TENCLB = N'SHB Đà Nẵng' and qg.TENQG = N'Brazil'
go
select * from vCau1
go


Create View vCau2 
as
	select td.MATRAN N'Mã trận', td.NGAYTD N'Ngày trận đấu', svd.TENSAN N'Tên sân', clb1.TENCLB N'Câu lạc bộ 1',
			clb2.TENCLB N'Câu lạc bộ 2',td.KETQUA N'Kết quả'
	from dbo.CAULACBO clb1 join dbo.TRANDAU td on clb1.MACLB = td.MACLB1 
			join dbo.CAULACBO clb2 on td.MACLB2=clb2.MACLB
			join SANVD svd on td.MASAN = svd.MASAN
	where td.VONG ='3' and td.NAM = '2009'
go
select * from vCau2
go

create View vCau3
as
	select hlv.MAHLV N'Mã huấn luyện viên', hlv.TENHLV N'Tên huấn luyện viên', hlv.NGAYSINH N'Ngày sinh', hlv.DIACHI N'Địa chỉ' , hlvclb.VAITRO N'Vai trò'
	from dbo.CAULACBO clb join dbo.HLV_CLB hlvclb on clb.MACLB = hlvclb.MACLB 
	join dbo.HUANLUYENVIEN hlv on hlvclb.MAHLV = hlv.MAHLV
	join QUOCGIA qg on hlv.MAQG = qg.MAQG
	where qg.TENQG = N'Việt Nam'
go
select * from vCau3
go


Create View vCau4
as 
	select clb.TENCLB , count(ct.MACT) N'số lượng ct'
			from dbo.CAULACBO clb join dbo.CAUTHU ct on ct.MACLB = clb.MACLB join QUOCGIA qg on ct.MAQG = qg.MAQG
			where qg.TENQG != N'Việt Nam'
			group by clb.TENCLB
			having count(ct.MACT) > 2			
go
select * from vCau4
go

create View vCau5
as
	select t.TENTINH N'Tên tỉnh', clb.TENCLB N'Tên câu lạc bộ', count(ct.MACT) as N'Số lượng cầu thủ'
	from dbo.TINH t join dbo.CAULACBO clb on t.MATINH = clb.MATINH join CAUTHU ct on clb.MACLB = ct.MACLB
	where ct.VITRI = N'Tiền đạo'
	group by t.TENTINH,clb.TENCLB
go
select * from vCau5
go	

/* câu 6 ->10 */
create view vCau6 as
select top(1) TENCLB,TENTINH
from CAULACBO,BANGXH,TINH
where CAULACBO.MACLB = BANGXH.MACLB and CAULACBO.MATINH = TINH.MATINH and BANGXH.NAM = 2009 and BANGXH.VONG = 3
order by HANG
go

create view vCau7 as
select TENHLV
from HUANLUYENVIEN,HLV_CLB, CAULACBO
where HUANLUYENVIEN.MAHLV = HLV_CLB.MAHLV and HLV_CLB.MACLB = CAULACBO.MACLB and VAITRO is not null and DIENTHOAI is null
go

create view vCau8 as
select TENHLV, NGAYSINH, DIENTHOAI
from HUANLUYENVIEN, HLV_CLB, CAULACBO, QUOCGIA
where HUANLUYENVIEN.MAHLV = HLV_CLB.MAHLV and QUOCGIA.MAQG = HUANLUYENVIEN.MAQG and
	  HLV_CLB.MACLB = CAULACBO.MACLB and VAITRO is null  and HUANLUYENVIEN.MAQG = 'VN'
go

create view vCau9 as
	select NGAYTD, TENSAN,a.TENCLB as CLB1, b.TENCLB as CLB2, KETQUA
	from TRANDAU,SANVD,CAULACBO a, CAULACBO b
	where TRANDAU.MASAN = SANVD.MASAN and a.MACLB = TRANDAU.MACLB1 and b.MACLB = TRANDAU.MACLB2 
		and ( MACLB1 in (
			select Top(1) CAULACBO.MACLB
			from CAULACBO,BANGXH
			where  CAULACBO.MACLB = BANGXH.MACLB and BANGXH.NAM = 2009 and BANGXH.VONG = 3 order by HANG) 
		or MACLB2 in (
			select Top(1) CAULACBO.MACLB
			from CAULACBO,BANGXH
			where  CAULACBO.MACLB = BANGXH.MACLB and BANGXH.NAM = 2009 and BANGXH.VONG = 3 order by HANG) 
			) 
	
go

create view vCau10 as
	select NGAYTD,TENSAN,a.TENCLB as CLB1, b.TENCLB as CLB2,KETQUA
	from TRANDAU,SANVD,CAULACBO a, CAULACBO b
	where TRANDAU.MASAN = SANVD.MASAN and ( MACLB1 in (select Top(1) CAULACBO.MACLB
	from CAULACBO,BANGXH
	where  CAULACBO.MACLB = BANGXH.MACLB and BANGXH.NAM = 2009 and BANGXH.VONG = 3 order by HANG desc) or MACLB2 in (select Top(1) CAULACBO.MACLB
	from CAULACBO,BANGXH
	where  CAULACBO.MACLB = BANGXH.MACLB and BANGXH.NAM = 2009 and BANGXH.VONG = 3 order by HANG desc) ) and a.MACLB = TRANDAU.MACLB1 and b.MACLB = TRANDAU.MACLB2
go		
	/*
	select * from sys.all_views viewcollection  where viewcollection.name like 'vCau%'
	/* chạy các dòng dưới trong quyền admin
	create schema ViewCollection authorization dbo;
	go
	alter schema ViewCollection transfer dbo.views
	go*/

/* phân quyền*/
/*BDRead*/

grant select on dbo to BDRead


/*BDU01*/
grant select on dbo.vCau5 to BDU01
grant select on dbo.vCau6 to BDU01
grant select on dbo.vCau7 to BDU01
grant select on dbo.vCau8 to BDU01
grant select on dbo.vCau9 to BDU01
grant select on dbo.vCau10 to BDU01
go

/*BDU03 , BDU04*/
grant select on dbo.vCau1 to BDU03,BDU04
grant select on dbo.vCau2 to BDU03,BDU04
grant select on dbo.vCau3 to BDU03,BDU04
grant select on dbo.vCau4 to BDU03,BDU04
go
/* trả lời câu hỏi 
 -- 1. user DBRead 
		select * from vCau1          |v| 
		select * from vCau5			 |v|					
 -- 2 . BDU01
		select * from vCau2			 |x| : Không thấy view , cố tình nhập lệnh select view sẽ bị lỗi deny permission "The SELECT permission was denied on the object 'vCau2', database 'QLBongDa', schema 'dbo'."
		select * from vCay10		 |v|
 -- 3 . BDU03
		SELECT * FROM vCau1			 |v|
		SELECT * FROM vCau2			 |v|
		SELECT * FROM vCau3			 |v|
		SELECT * FROM vCau4			 |v|
 -- 4 . BDU04
		SELECT * FROM vCau1			 |v|
		SELECT * FROM vCau2			 |v|
		SELECT * FROM vCau3			 |v|
		SELECT * FROM vCau4			 |v|

*/



/* câu j*/

Create proc SPCau1 @TenCLB nvarchar(100), @TenQG nvarchar(100)
as
	select ct.MACT N'Mã cầu thủ',ct.HOTEN N'Họ và tên',ct.NGAYSINH N'Ngày sinh',ct.DIACHI N'Địa chỉ',ct.VITRI N'Vị trí'
	from dbo.CAUTHU ct join dbo.CAULACBO clb on ct.MACLB = clb.MACLB
			 join dbo.QUOCGIA qg on ct.MAQG = qg.MAQG
	where clb.TENCLB = @TenCLb and qg.TENQG = @TenQG
go



Create proc SPCau2 @Vong int, @Nam int
as
	select td.MATRAN N'Mã trận', td.NGAYTD N'Ngày trận đấu', svd.TENSAN N'Tên sân', clb1.TENCLB N'Câu lạc bộ 1',
			clb2.TENCLB N'Câu lạc bộ 2',td.KETQUA N'Kết quả'
	from dbo.CAULACBO clb1 join dbo.TRANDAU td on clb1.MACLB = td.MACLB1 
			join dbo.CAULACBO clb2 on td.MACLB2=clb2.MACLB
			join SANVD svd on td.MASAN = svd.MASAN
	where td.VONG =@Vong and td.NAM = @Nam
go

create proc SPCau3  @TenQG nvarchar(100)
as
	select hlv.MAHLV N'Mã huấn luyện viên', hlv.TENHLV N'Tên huấn luyện viên', hlv.NGAYSINH N'Ngày sinh', hlv.DIACHI N'Địa chỉ' , hlvclb.VAITRO N'Vai trò'
	from dbo.CAULACBO clb join dbo.HLV_CLB hlvclb on clb.MACLB = hlvclb.MACLB 
	join dbo.HUANLUYENVIEN hlv on hlvclb.MAHLV = hlv.MAHLV
	join QUOCGIA qg on hlv.MAQG = qg.MAQG
	where qg.TENQG = @TenQG
go



Create proc SPCau4 @TenQG nvarchar(100)
as 
	select clb.TENCLB , count(ct.MACT) N'số lượng ct'
			from dbo.CAULACBO clb join dbo.CAUTHU ct on ct.MACLB = clb.MACLB join QUOCGIA qg on ct.MAQG = qg.MAQG
			where qg.TENQG != @TenQG
			group by clb.TENCLB
			having count(ct.MACT) > 2			
go


create proc SPCau5 @Vitri nvarchar(20)
as
	select t.TENTINH N'Tên tỉnh', clb.TENCLB N'Tên câu lạc bộ', count(ct.MACT) as N'Số lượng cầu thủ'
	from dbo.TINH t join dbo.CAULACBO clb on t.MATINH = clb.MATINH join CAUTHU ct on clb.MACLB = ct.MACLB
	where ct.VITRI = @Vitri
	group by t.TENTINH,clb.TENCLB
go

/* câu 6 ->10 */
create proc SPCau6 @Vong int, @Nam int
as
	select top(1) TENCLB,TENTINH
	from CAULACBO,BANGXH,TINH
	where CAULACBO.MACLB = BANGXH.MACLB and CAULACBO.MATINH = TINH.MATINH and BANGXH.NAM = @Nam and BANGXH.VONG = @Vong
	order by HANG
go

create proc SPCau7 
as
	select TENHLV
	from HUANLUYENVIEN,HLV_CLB, CAULACBO
	where HUANLUYENVIEN.MAHLV = HLV_CLB.MAHLV and HLV_CLB.MACLB = CAULACBO.MACLB and VAITRO is not null and DIENTHOAI is null
go

create proc SPCau8 @MaQG nvarchar(5)
as
	select TENHLV, NGAYSINH, DIENTHOAI
	from HUANLUYENVIEN, HLV_CLB, CAULACBO, QUOCGIA
	where HUANLUYENVIEN.MAHLV = HLV_CLB.MAHLV and QUOCGIA.MAQG = HUANLUYENVIEN.MAQG and
		  HLV_CLB.MACLB = CAULACBO.MACLB and VAITRO is null  and HUANLUYENVIEN.MAQG = @MaQG
go

create proc SPCau9  @Vong int, @Nam int
as
	select NGAYTD, TENSAN,a.TENCLB as CLB1, b.TENCLB as CLB2, KETQUA
	from TRANDAU,SANVD,CAULACBO a, CAULACBO b
	where TRANDAU.MASAN = SANVD.MASAN and a.MACLB = TRANDAU.MACLB1 and b.MACLB = TRANDAU.MACLB2 
		and ( MACLB1 in (
			select Top(1) CAULACBO.MACLB
			from CAULACBO,BANGXH
			where  CAULACBO.MACLB = BANGXH.MACLB and BANGXH.NAM = @Nam and BANGXH.VONG = @Vong order by HANG) 
		or MACLB2 in (
			select Top(1) CAULACBO.MACLB
			from CAULACBO,BANGXH
			where  CAULACBO.MACLB = BANGXH.MACLB and BANGXH.NAM = @Nam and BANGXH.VONG = @Vong order by HANG) 
			) 
	
go

create proc SPCau10 @Vong int, @Nam int
as
	select NGAYTD,TENSAN,a.TENCLB as CLB1, b.TENCLB as CLB2,KETQUA
	from TRANDAU,SANVD,CAULACBO a, CAULACBO b
	where TRANDAU.MASAN = SANVD.MASAN and ( MACLB1 in (select Top(1) CAULACBO.MACLB
	from CAULACBO,BANGXH
	where  CAULACBO.MACLB = BANGXH.MACLB and BANGXH.NAM = @Nam and BANGXH.VONG = @Vong order by HANG desc) or MACLB2 in (select Top(1) CAULACBO.MACLB
	from CAULACBO,BANGXH
	where  CAULACBO.MACLB = BANGXH.MACLB and BANGXH.NAM = @Nam and BANGXH.VONG = @Vong order by HANG desc) ) and a.MACLB = TRANDAU.MACLB1 and b.MACLB = TRANDAU.MACLB2
go	

/*DBRead*/
grant execute to BDRead

/*BDU01*/
grant execute on dbo.SPCau5 to BDU01
grant execute on dbo.SPCau6 to BDU01
grant execute on dbo.SPCau7 to BDU01
grant execute on dbo.SPCau8 to BDU01
grant execute on dbo.SPCau9 to BDU01
grant execute on dbo.SPCau10 to BDU01
go

/*BDU03 , BDU04*/
grant execute on dbo.SPCau1 to BDU03,BDU04
grant execute on dbo.SPCau2 to BDU03,BDU04
grant execute on dbo.SPCau3 to BDU03,BDU04
grant execute on dbo.SPCau4 to BDU03,BDU04
go	
/*
 -- 1. user DBRead 
		EXEC SPCau1 ‘SHB Đà Nẵng’, ‘Brazil’          |v| 
		EXEC SPCau9 3, 2009							 |v|					
 -- 2 . BDU01
		EXEC SPCau3 ‘Việt Nam’						 |x| : bị lỗi deny permission "The EXECUTE permission was denied on the object 'SPCau3', database 'QLBongDa', schema 'dbo'."
		EXEC SPCau10 3, 2009						 |v|
 -- 3 . BDU03
		EXEC SPCau1 ‘SHB Đà Nẵng’, ‘Brazil’			 |v|
		EXEC SPCau10 3, 2009						 |x| The EXECUTE permission was denied on the object 'SPCau10', database 'QLBongDa', schema 'dbo'
		EXEC SPCau3 ‘Việt Nam’						 |v|
		EXEC SPCau4 ‘Việt Nam’						 |v|
 -- 4 . BDU04										
		EXEC SPCau1 ‘SHB Đà Nẵng’, ‘Brazil’			 |v|
		EXEC SPCau10 3, 2009						 |x| The EXECUTE permission was denied on the object 'SPCau10', database 'QLBongDa', schema 'dbo'
		EXEC SPCau3 ‘Việt Nam’						 |v|
		EXEC SPCau4 ‘Việt Nam’						 |v|

*/
