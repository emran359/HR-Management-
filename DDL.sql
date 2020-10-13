--Create Database-------
Create database DB_HR_Management
go
use DB_HR_Management
go
--Create table Using 3rd Normalization From------
Create table Employee
(
	EmployeeId				int				identity	primary key,
	EmployeeName			varchar(20)		not null,
	Gender					varchar(10)		not null, 
	DateOfBirth				date			not null,
	Salary					money			not null,
	PhoneNumber				varchar(11)		not null,
	Email					varchar(40)		not null,
	ParentId				int				not null,
	Address					varchar(50)		not null,
	Location				varchar(30)		not null
)
create table Department
(
	DepartmentId			int				identity		primary key,
	DepartmentName			varchar(20)		not null
)
create table Designation
(
	DesignationId			int				identity		primary key,
	DesignationName			varchar(30)		not null
)
create table SalaryHistory
(
	SalaryHistoryId			int				identity		primary key,
	DesignationId			int				not null		references Designation(DesignationId),
	BasicSalary				money			not null,
	ProvidentFund			money			not null,
	HouseRentAllowance		money			not null,
	MedicalAllowance		money			not null,
	ConvenceAllowance		money			not	null,
	IncrementSalary			decimal(18,2)	not null
)
create table JobHistroy
(
	JobHistroyId			int				identity	not null,
	JoiningDate				date			not null,
	EmployeeID				int				not null	references Employee(EmployeeId),
	DepartmentId			int				not null	references Department(DepartmentId),
	DesignationId			int				not null	references Designation(DesignationId)
)
go
----create table using for merge
Create table EmployeeCopy
(
	EmployeeId				int				identity	primary key,
	EmployeeName			varchar(20)		not null,
	Gender					varchar(10)		not null, 
	DateOfBirth				date			not null,
	Salary					money			not null,
	PhoneNumber				varchar(11)		not null,
	Email					varchar(40)		not null,
	ParentId				int				not null,
	Address					varchar(50)		not null,
	Location				varchar(30)		not null
)
go
--Create non-clustered index-----
create index ix_gender
on [dbo].[Employee]([Gender]);
go
exec sp_helpindex [Employee];
go
--create Clustered index-----
Create  clustered index ix_JobHistory
on [dbo].[JobHistroy]([JobHistroyId]);
go
exec sp_helpindex [JobHistroy];
--Create non-clustered index-----
create index ix_jobhistory1
on [dbo].[JobHistroy]([JoiningDate]);
go
exec sp_helpindex [JobHistroy];
go
-- Created Store Procedure--------
--Using insert
Create proc Sp_InsertEmployee
@eName varchar(20),@egender varchar(10),@ebirth date,@esalary money,@enumber varchar(11),@email varchar(40),
@eparentid int,@eadd varchar(50),@elocation varchar(30)
as
Begin
Insert into Employee values (@eName, @egender ,@ebirth ,@esalary ,@enumber, @email, @eparentid, @eadd, @elocation)
End
go

----Using Update
create proc Sp_UpdateEmployee
@eName varchar(20),@gen varchar(10),@DOfBrith date,@Sal money,@pNumber varchar(11),
@Email varchar(40),@pId int,@Add varchar(50),@Loc varchar(30),@eId int
as
Begin
update [Employee] set EmployeeName= @eName,[Gender]=@gen,[DateOfBirth]=@DOfBrith,[Salary]=@Sal,
[PhoneNumber]=@pNumber,[Email]=@Email,[ParentId]=@pId,[Address]=@Add,[Location]=@Loc 
where [EmployeeId]=@eId
end

go
--Using delete
Create proc Sp_DeleteEmployee
@eId int
as
begin
	delete from [dbo].[Employee] where [EmployeeId]=@eId
end
go

--create procedure using transaction, try and catch
Create proc Sp_InsertSalaryHistory
@Did int,@bSalary money,@pFund money,@hRent money,@mAllowance money,@Callowance money,@iSalary decimal(18,2)
as
begin
	set Nocount on;
		begin tran
		begin try
			insert into [SalaryHistory] ([DesignationId],[BasicSalary],[ProvidentFund],[HouseRentAllowance],
			[MedicalAllowance],[ConvenceAllowance],[IncrementSalary]) 
			values (@Did,@bSalary,@pFund,@hRent,@mAllowance,@Callowance,@iSalary)
			commit
		end try
		begin catch
			print Error_message()
		Raiserror ('Error in inserting table: ',16,1)
			print @@trancount
		if @@TRANCOUNT>0
			rollback;
		end catch
end

go
----Trigger--------
------create trigger using instead of insert with transaction-----
Create trigger Tri_Employee
on [dbo].[Employee]
instead of insert
as
begin
		declare @salary	money
		select @salary=Salary from inserted
		if @salary>=10000
				begin
				Begin tran
					Begin try
						insert into [dbo].[Employee]
						select [EmployeeName],[Gender],[DateOfBirth],[Salary],[PhoneNumber],[Email],
						[ParentId],[Address],[Location] from inserted
				commit tran
					end try
					begin catch
						print 'error occured for '+ error_message()
				rollback tran
					end catch
		end
		else
			Print 'Salary must be greater than equal 10000'
end

go


--------Using after delete trigger
Create trigger Tri_SalaryHistory_Delete
on [SalaryHistory]
after delete
as
insert into SalaryHistoryCopy
([SalaryHistoryId],[DesignationId],[BasicSalary],[ProvidentFund],[HouseRentAllowance],[MedicalAllowance],
[ConvenceAllowance],[IncrementSalary])
select [SalaryHistoryId],[DesignationId],[BasicSalary],[ProvidentFund],[HouseRentAllowance],
[MedicalAllowance],[ConvenceAllowance],[IncrementSalary]
from deleted
go

---Function--------------
---Using scalar function
create function Fn_TotalSalary()
returns int
as
begin
	declare @totalSalary	int
	select @totalSalary =Sum( Employee.Salary) from Employee
	return @totalSalary;
end

go
-- Create table valued function
create function Fn_SalaryHistroy(@ShID int)
returns table
as
return
	select [DesignationId],[BasicSalary],[ProvidentFund],[HouseRentAllowance],
	[ConvenceAllowance],[IncrementSalary] from SalaryHistory 
	where [SalaryHistoryId]=@ShID

go

--------------------View-------
--create view
create view VW_Salaryhistory
as
select [SalaryHistoryId],[BasicSalary]-[ProvidentFund]+[HouseRentAllowance]+[MedicalAllowance] as grossSalary
from [dbo].[SalaryHistory]
where BasicSalary-ProvidentFund>20000;
go

---create view using transaction
Begin try
		declare @error varchar(100)
	begin tran
	exec
	('Create view vw_Employee
	as
	select [EmployeeId],[EmployeeName],[Gender],[DateOfBirth],[Salary],[PhoneNumber],[Address]
	from [dbo].[Employee] ')
	commit tran
end try
begin catch
		if @@TRANCOUNT>0 rollback
		select @error=ERROR_MESSAGE()
		raiserror ('error occured in employee table-', 16,1 )
end catch



