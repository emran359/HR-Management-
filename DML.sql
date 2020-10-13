--insert value
Insert into [dbo].[Employee]
values ('Kamal','male','1990-1-1',14000,'01812131415','kamal123@yahoo.com',5,'39/1 Dhanmondi-27','Dhanmondi'),
('Jamal','male','1989-5-1',16500,'01515141213','jamalvhi2016@gmail.com',2,'12/a sikdar bila Mohakhali-1212','Mohakhali DOSH'),
('Bisti','female','1992-1-19',20500,'01712131718','bisti213@yahoo.com',3,'28/1 ross graden Mirpur-10','Mirpur-10'),
('Dollar mahamud','male','1990-6-18',24500,'01818191613','dollarmah123@gmail.com',5,'13/12 concot tower Gulshan-1','Gulshan-1'),
('Hasan','male','1988-6-1',27000,'01789456123','hasanali725@gmail.com',1,'49/e hazi bari farmgate-1210','Farmgate'),
('amena','female','1988-11-11',28500,'01712345689','begumamena123@yahoo.com',2,'48/18 kanta bila Banani-1212','Banani'),
('jannat','female','1984-11-4',30000,'01745678912','jannat987@gmail.com',1,'1/2 janata palace Airport-1208','Airport'),
('Jony','male','1994-5-23',33000,'01987654321','jon123@yahoo.com',4,'13/c shanti bari towanhall','Mohammadpur'),
('Abdur Rahman','male','1987-12-29',36500,'01879456321','Rahmanabdur613@gmail.com',1,'12/18 bonolata house','Mirpur-11'),
('Ripon ali','male','1980-09-24',40000,'01714785236','alipon4890@gmail.com',1,'17/k bilas bari','Gulshan-1')
go
Insert into Department
values ('Accounting'),('Finance'),('HR'),('Marketing'),('IT')
go
insert into [Designation]
values('Manager'),('Senior Executive'),('Assistant Executive'),('Clerk'),('Jonior Executive')
go
insert into [SalaryHistory]
values (4,10000,1000,3000,1500,500,0.05),(5,12000,1000,3500,1500,500,0.05),
	(5,15000,1500,4000,2000,1000,0.10),(3,18000,2000,4500,2500,1500,0.10),
	(3,20000,2000,5000,2500,1500,0.05),(2,22000,2500,5000,2500,1500,0.10),
	(2,23000,2500,5500,2500,1500,0.05),(2,25000,3000,6000,3000,2000,0.10),
	(1,28000,3500,6000,3500,2500,0.15),(1,30000,4000,6500,4000,2500,0.20)
go
insert into [JobHistroy]
values ('2011-05-18',1,1,4),('2012-09-28',2,3,5),('2011-11-11',3,2,5),
	('2017-03-19',4,2,3),('2016-12-25',5,5,3),('2018-07-11',6,4,2),
	('2019-03-23',7,3,2),('2018-08-18',8,1,2),('2016-11-09',9,5,1),
	('2012-06-17',10,3,1)
go
exec Sp_InsertEmployee 'Ariful','male','1996-02-18',12000,'01896374152','arifvhi379@yahoo.com',11,'12/13 Dhanmondi 27','Dhanmondi'
go
exec Sp_UpdateEmployee 'Tamim','male','1985-06-15',30000,'01778659413','tamimrahman219@yahoo.com',6,'28/29 block-c,road-10,Zigatola','Dhanmondi',5
go
exec Sp_DeleteEmployee 11
go
exec Sp_InsertSalaryHistory 4,25000,4500,6000,3000,1500,0.15
go
select * from [dbo].[Employee]
go
select * into SalaryHistoryCopy
from [dbo].[SalaryHistory]
go
select * from Designation
go
select [dbo].[Fn_TotalSalary]() as TotalSalary
go
select * from [dbo].[SalaryHistory]
go
Delete [dbo].[SalaryHistoryCopy]
where [SalaryHistoryId]=6;
go
select * from[dbo].[SalaryHistoryCopy]
go
select * from VW_Salaryhistory
go
select * from vw_Employee where EmployeeId=10
go
select * from [dbo].[Fn_SalaryHistroy] (9)
go
insert into Employee
values ('Sanim','male','1992-02-19',28500,'01312987456','sanimhasan987@gmail.com',7,'12/a,Mohakhali Dosh','Mohakhali')
go

--create simple query fine who male
select [EmployeeName],[Gender],[DateOfBirth],[Salary],[PhoneNumber],[ParentId],[JoiningDate]
from Employee as e
join JobHistroy as j
on e. [EmployeeId]= j.[EmployeeID]
where Gender= 'male';

go

--subquery
select [EmployeeName],[DesignationName],[Gender],[Salary],[JoiningDate],[DepartmentName],(BasicSalary + HouseRentAllowance +
MedicalAllowance +ConvenceAllowance -ProvidentFund) as PayableSalary
from [dbo].[Employee] E
join [dbo].[JobHistroy] J
on E.EmployeeId= J.EmployeeID
join [dbo].[Department] D
on D.DepartmentId= J.DepartmentId
join [dbo].[SalaryHistory] SH
on SH.DesignationId= D.DepartmentId
join Designation DN
on DN.DesignationId= J.DesignationId
where DN.DesignationName in(select DesignationName from dbo.Designation where DepartmentName='HR')
order by DepartmentName ;
go

-- A select statement that using join
select[EmployeeName],[Gender],[Salary],[JoiningDate],[DepartmentName],[BasicSalary],[HouseRentAllowance],[MedicalAllowance],[ConvenceAllowance],[ProvidentFund],
(BasicSalary + HouseRentAllowance + MedicalAllowance +ConvenceAllowance -ProvidentFund) as PayableSalary
from [dbo].[Employee] E
join [dbo].[JobHistroy] J
on E.EmployeeId= J.EmployeeID
join [dbo].[Department] D
on D.DepartmentId= J.DepartmentId
join [dbo].[SalaryHistory] SH
on SH.DesignationId= D.DepartmentId
where Salary>= 25000
order by [EmployeeName],[DepartmentName],[Salary],PayableSalary desc;

go

--create CTE
With YearlyIncrementSalary 
as
(
	select [EmployeeName],[Salary],[JoiningDate],([BasicSalary]+[HouseRentAllowance]+[MedicalAllowance]+[ConvenceAllowance]-[ProvidentFund]) as payableSalary,
	([BasicSalary]+[HouseRentAllowance]+[MedicalAllowance]+[ConvenceAllowance]-[ProvidentFund])+([BasicSalary]*[IncrementSalary]) as Salaryincrement
	from [dbo].[Employee] E join [dbo].[JobHistroy] JH
	on E.EmployeeId=JH.EmployeeID
	join [dbo].[Designation] D
	on D.DesignationId=JH.DesignationId
	join [dbo].[SalaryHistory] SH
	on SH.DesignationId= JH.DesignationId
),
IncrementSalaryinfo as
(select * from YearlyIncrementSalary)
select yis.EmployeeName,yis.Salary,yis.JoiningDate,isi.payableSalary,isi.Salaryincrement
from YearlyIncrementSalary yis
join IncrementSalaryinfo as isi
on yis.EmployeeName=isi.EmployeeName and
yis.payableSalary=isi.payableSalary and
yis.Salaryincrement= isi.Salaryincrement
order by isi.Salaryincrement ;
go


--create a Merge statement that insert & updates row
Merge EmployeeCopy as EC
Using Employee as E
on E.[EmployeeId] = EC.[EmployeeId]
when matched and
	E.Salary = EC.Salary
  then
  update set
  EC.[EmployeeName] = E.[EmployeeName],
  EC.[Gender]=E.[Gender],
  EC.[Salary]= E.[Salary],
  EC.[PhoneNumber]= E.[PhoneNumber],
  EC.Email=E.Email
when not matched then
  insert ([EmployeeName],[Gender],[DateOfBirth],[Salary],[PhoneNumber],[Email],[ParentId],[Address],[Location])
  values (E.[EmployeeName],E.[Gender],E.[DateOfBirth],E.[Salary],E.[PhoneNumber],E.[Email],E.[ParentId],E.[Address],E.[Location])
;
go
  select * from EmployeeCopy;

go
---Union all
select SUM([BasicSalary]+[HouseRentAllowance]+[MedicalAllowance]+[ConvenceAllowance]-[ProvidentFund]) payableSalary,
CAST([SalaryHistoryId] as varchar)
from [dbo].[SalaryHistory]
group by [SalaryHistoryId]
union all
select SUM([BasicSalary]+[HouseRentAllowance]+[MedicalAllowance]+[ConvenceAllowance]-[ProvidentFund]) payableSalary,
'all'
from [dbo].[SalaryHistory];
go
---Convert data using Cast Function
select [DateOfBirth],[Salary], 
Cast([DateOfBirth] as varchar) as VarcharBirth,
CAST([Salary] as int) as intsalary,
CAST([DateOfBirth] as datetime) as TimeBirth,
CAST([Salary] as decimal) as DecimalSalary,
CAST([Salary] as varchar) as varsalary
from[dbo].[Employee]
go
--Convert data using Convert Function
select [DateOfBirth],[Salary],
CONVERT(Varchar,[DateOfBirth]) as varcharBirth,
CONVERT(varchar,[DateOfBirth],107) as vardatetime,
CONVERT(varchar,[DateOfBirth],100) as vardatetime1,
CONVERT(varchar,[Salary],2) as vardatetime,
CONVERT(varchar,[Salary],1) as vardatetime1
from [dbo].[Employee]
go
--using a simple case
select EmployeeName,
		case
			when EmployeeId=19 then 'Salary yearly increment 5%'
			when EmployeeId=20 then 'Salary yearly increment 10%'
			when EmployeeId=21 then 'Salary yearly increment 5%'
			when EmployeeId=22 then 'Salary yearly increment 15%'
			when EmployeeId=23 then 'Salary yearly increment 20%'
			else 'Salary yearly increment 13%'
		 end as  IncrementPercent
from [dbo].[Employee]
go
-- Using serached case function
select [EmployeeName],[Gender],[Salary],[DesignationName],[JoiningDate],
		case
			when DATEDIFF(year,[JoiningDate],GETDATE()) >1
				then 'get Increment 10%'
			when DATEDIFF(year,[JoiningDate],GETDATE()) >2
				then 'get increment 20%'
			else 'No increment'
		end as IncrementPercentage
from [dbo].[Employee] E 
join [dbo].[JobHistroy] JH
on E.EmployeeId= JH.EmployeeID
join [dbo].[Designation] D
on D.DesignationId=JH.DesignationId
join [dbo].[SalaryHistory] SH
on SH.DesignationId= D.DesignationId
where [BasicSalary]+[HouseRentAllowance]+[MedicalAllowance]+[ConvenceAllowance]-[ProvidentFund]>=20000;

