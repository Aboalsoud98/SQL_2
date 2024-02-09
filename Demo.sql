
==========================================================
------------------------- Top ----------------------------

-- First 5 Students From Table
select top(5)*
from  student

select top(5)st_fname
from  student

-- Last 5 Students From Table
select top(5)*
from  student
order by st_id desc

-- Get The Maximum 2 Salaries From Instractors Table
select Max(Salary)
from Instructor

select Max(Salary)
from Instructor
where Salary <> (Select Max(Salary) from Instructor)

select top(2)salary
from Instructor
order by Salary desc


-- Top With Ties, Must Make Order by
select top(5) st_age
from student 
order by st_age desc

select top(5) with ties st_age
from student
order by st_age  desc


-- Randomly Select
select newid()   -- Return GUID Value (Global Universal ID)

select St_Fname, newid()
from Student

select top(3)*
from student
order by newid()
============================================================
------------------------------------------------------------
------------------- Ranking Function -----------------------



-- 1. Row_Number()
-- 2. Dense_Rank()
-- 3. Rank()

select Ins_Name, Salary,
	Row_Number() over (Order by Salary desc) as RNumber,
	Dense_Rank() over (Order by Salary desc) as DRank,
	Rank()       over (Order by Salary desc) as R
from Instructor


-- 1. Get The 2 Older Students at Students Table

-- Using Ranking 
select *
from (select St_Fname, St_Age, Dept_Id,
		Row_number() over(order by St_Age desc) as RN
	from Student) as newtable
where RN <= 2

-- Using Top(Recommended)
Select top(2) St_Fname, St_Age, Dept_Id
from Student
Order By St_Age Desc

-- 2. Get The 5th Younger Student 

-- Using Ranking (Recommended)
select * from 
(select St_Fname, St_Age, Dept_Id,
		row_number() over(order by St_age desc) as RN
from Student) as newtable
where RN = 5

-- Using Top
select top(1)* from
(select top(5)*
from Student
order by St_Age desc) as newTable
order by St_Age

-- 2. Get The Younger Student At Each Department

-- Using Ranking Only
select * from 
(select Dept_Id, St_Fname, St_Age, 
		row_number() over(partition by Dept_id order by St_age desc) as RN
from Student) as newtable
where RN = 1



-- 4.NTile

-- We Have 15 Instructors, and We Need to Get The 5th Instructors Who Take the lowest salary
select *
from
(
select Ins_Name, Salary, Ntile(3) over(order by Salary) as G
from Instructor
) as newTable
where G = 3


=========================================================
---------------------------------------------------------
-- Execution Order
Select CONCAT(St_FName, ' ', St_Lname) as FullName
from Student
Where FullName = 'Ahmed Hassan' -- Not Valid


Select CONCAT(St_FName, ' ', St_Lname) as FullName
from Student
Where CONCAT(St_FName, ' ', St_Lname) = 'Ahmed Hassan'

Select *
from  (Select CONCAT(St_FName, ' ', St_Lname) as FullName
	   from Student) as Newtable
Where FullName = 'Ahmed Hassan'

Select CONCAT(St_FName, ' ', St_Lname) as FullName
from Student
Order By FullName


--execution order
----from
----join
----on
----where 
----group by
----having
----select
----order by
----top

=========================================================
---------------------------------------------------------
---------------------------- Schema ---------------------

-- Schema Solved 3 Problems:
-- 1.You Can't Create Object With The Same Name
--	[Table, View, Index, Trigger, Stored Procedure, Rule]
-- 2. There Is No Logical Meaning (Logical Name)
-- 3. Permissions
select *
from Student

-- DBO [Default Schema] => Database Owner
select *
from ServerName.DBName.SchemaName.objectName

select *
from  [DESKTOP-VF50P25].iti.dbo.student

select *
from Company_SD.dbo.Project

Create Schema HR

Create Schema Sales


Alter Schema HR 
Transfer student


select * from Student  -- not valid

select * from Hr.Student -- valid

Alter Schema HR
Transfer Department

Select *
from HR.Department


ALter Schema Dbo
Transfer HR.Department


======================================================
------------------------------------------------------
-- Union Family (union | union all | intersect | except)
-- Have 2 Conditions:
-- 1- The Same Datatype
-- 2- The Same Number Of Selected Columns

Select St_Id, St_FName from Student
-- except --intersect --union all --union
Select Ins_Id, Ins_Name from Instructor

-- Example (Select The Student Names At All Route Branches)

===============================================================
---------------------------------------------------------------
-- DDL [Create, Alter, Drop, Select Into]    
-- Create Physical Table


Select * into NewEmployees
From MyCompany.Dbo.Employee


-- Create Just The Structure Without Data
Select * into NewProjects
From MyCompany.Dbo.Project
Where 1 = 2



-- Take Just The Data Without Table Structure, 
-- but 2 tables must have same structure (Insert Based On Select)
Insert Into NewProjects
Select * from MyCompany.Dbo.Project


=========================================================
---------------------------------------------------------
---------------- User Defined Function ------------------

-- Any SQL Server Function must return value
-- Specify Type Of User Defined Function That U Want Based On The Type Of Return
-- User Defined Function Consist Of
--- 1. Signature (Name, Parameters, ReturnType)
--- 2. Body
-- Body Of Function Must be Select Statement Or Insert Based On Select
-- May Take Parameters Or Not

=================================================================
-- 1. Scalar Fun (Return One Value)


Create Function GetStudentNameByStudentId(@StId int)
returns varchar(20) -- Function Signature
begin
	declare @StudentName varchar(20)
	Select @StudentName = St_FName
	from Student
	where St_Id = @StId
	return @StudentName
end
     
Select	Dbo.GetStudentNameByStudentId(8)


-----------------------------------------------------

Create Function GetDepartmentManagerNameByDepartmentName(@DeptName varchar(20))
Returns varchar(20) -- Function Signature
begin
	declare @MangerName varchar(20)
	Select @MangerName = E.FName
	From Employee E, Departments D
	where E.SSN = D.MGRSSN and D.DName =  @DeptName
	return @MangerName
end

Select	Dbo.GetDepartmentManagerNameByDepartmentName('DP2')




=================================================================
-- 2. Inline Table Function (Return Table)

Create Function GetDepartmenInstructorsByDepartmentId(@DeptId int)
Returns Table  -- Function Signature
as
	Return
	(
		Select Ins_Id, Ins_Name, Dept_Id
		from Instructor
		Where Dept_Id = @DeptId
	)

	Select * from dbo.GetDepartmenInstructorsByDepartmentId(20)

=================================================================
-- 3. Multistatment Table Fuction
--    => Return Table With Logic [Declare, If, While] Inside Its Body

Alter Function GetStudentDataBasedPassedFormat(@Format varchar(20))
Returns @t table
		(
			StdId int,
			StdName varchar(20)
		)
With Encryption
as
	Begin
		if @format = 'first'
			Insert Into @t
			Select St_Id, St_FName
			from Student
		else if @format = 'last'
			Insert Into @t
			Select St_Id, St_LName
			from Student
		else if @format = 'full'
			Insert Into @t
			Select St_Id, Concat(St_FName, ' ', St_LName)
			from Student
		
		return 
	End

select * from dbo.GetStudentDataBasedPassedFormat('fullname')
select * from dbo.GetStudentDataBasedPassedFormat	('FIRST')

