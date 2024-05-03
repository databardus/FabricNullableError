
/*

	This script simulates an error in Microsoft Fabric that says one column doesn't allow nulls, but it's actually calling out another column.

	The definition of DimCustomer is pulled from AdventureWorks. If you don't have an instance already, google for AdventureWorksDW download and download a copy for source data.
		-Or use GPT to generate data. Whatever you prefer.


*/


/***Table Creation ***/
CREATE TABLE [dbo].[DimCustomer_test]
(
	[CustomerKey] [int]  NULL,
	[GeographyKey] [int]  NULL,
	[CustomerAlternateKey] [varchar](8000)  NULL,
	[Title] [varchar](8000)  NULL,
	[FirstName] [varchar](8000)  NULL,
	[MiddleName] [varchar](8000)  NULL,
	[LastName] [varchar](8000)  NULL,
	[NameStyle] [bit]  NULL,
	[BirthDate] [date]  NULL,
	[MaritalStatus] [char](1)  NULL,
	[Suffix] [varchar](8000)  NULL,
	[Gender] [varchar](8000)  NULL,
	[EmailAddress] [varchar](8000)  NULL,
	[YearlyIncome] [decimal](19,4)  NULL,
	[TotalChildren] [int]  NULL,
	[NumberChildrenAtHome] [int]  NULL,
	[EnglishEducation] [varchar](8000)  NULL,
	[SpanishEducation] [varchar](8000)  NULL,
	[FrenchEducation] [varchar](8000)  NULL,
	[EnglishOccupation] [varchar](8000)  NOT NULL,
	[SpanishOccupation] [varchar](8000)  NULL,
	[FrenchOccupation] [varchar](8000)  NULL,
	[HouseOwnerFlag] [char](1)  NULL,
	[NumberCarsOwned] [int]  NULL,
	[AddressLine1] [varchar](8000)  NULL,
	[AddressLine2] [varchar](8000)  NULL,
	[Phone] [varchar](8000)  NULL,
	[DateFirstPurchase] [date]  NULL,
	[CommuteDistance] [varchar](8000)  NULL,
	[IsCurrent] [varchar](5)  NOT NULL,
	[InsertDate] [datetime2](6)  NOT NULL,
	[UpdateDate] [datetime2](6)  NULL
)

CREATE TABLE [dbo].[DimCustomer_test_dest]
(
	[CustomerKey] [int]  NULL,
	[GeographyKey] [int]  NULL,
	[CustomerAlternateKey] [varchar](8000)  NULL,
	[Title] [varchar](8000)  NULL,
	[FirstName] [varchar](8000)  NULL,
	[MiddleName] [varchar](8000)  NULL,
	[LastName] [varchar](8000)  NULL,
	[NameStyle] [bit]  NULL,
	[BirthDate] [date]  NULL,
	[MaritalStatus] [char](1)  NULL,
	[Suffix] [varchar](8000)  NULL,
	[Gender] [varchar](8000)  NULL,
	[EmailAddress] [varchar](8000)  NULL,
	[YearlyIncome] [decimal](19,4)  NULL,
	[TotalChildren] [int]  NULL,
	[NumberChildrenAtHome] [int]  NULL,
	[EnglishEducation] [varchar](8000)  NULL,
	[SpanishEducation] [varchar](8000)  NULL,
	[FrenchEducation] [varchar](8000)  NULL,
	[EnglishOccupation] [varchar](8000)  NOT NULL,
	[SpanishOccupation] [varchar](8000)  NULL,
	[FrenchOccupation] [varchar](8000)  NULL,
    --Columns missing from insert statement
    [Test1] [bit] NULL,         --When not null, HouseOwnerFlag is the error
    [Test2] [varchar](20) NULL, --When not null, NumberCarsOwned is the error
    [Test3] [datetime2](6) NOT NULL, --When not null, AddressLine1 is the error
	--End columns missing from insert statement
    [HouseOwnerFlag] [char](1)  NULL,
	[NumberCarsOwned] [int]  NULL,
	[AddressLine1] [varchar](8000)  NULL,
	[AddressLine2] [varchar](8000)  NULL,
	[Phone] [varchar](8000)  NULL,
	[DateFirstPurchase] [date]  NULL,
	[CommuteDistance] [varchar](8000)  NULL,
    [IsCurrent] varchar(5) NOT NULL,
    [InsertDate] [datetime2](6) NOT NULL,
    [UpdateDate] [datetime2](6) NULL
)
GO

/**Table Creation End**/

/*

    Summary of the issue (I think): Error message shifts column references by X, where X is the number of columns omitted from the INSERT statement...sort of

*/

/*************DEMO query**************/

--Populate a DimCustomer

--Create a unique identifier (Fabric currently does not support identity columns
DECLARE @MaxID2 AS BIGINT;
IF EXISTS(SELECT * FROM [dbo].[DimCustomer_test_dest])
    SET @MaxID2 = (SELECT MAX([CustomerKey]) FROM [dbo].[DimCustomer_test_dest]);
ELSE
    SET @MaxID2 = 0;

--Now insert records into the destination table. Depending on how you reference Test1, Test2, and Test3, the error may change
--Regardless of the alterations, the error message does not reference the actual column that is causing the failure.
INSERT INTO [AdventureWorksWarehouse].[dbo].[DimCustomer_test_dest]
(
            [CustomerKey]
            ,[GeographyKey]
            ,[CustomerAlternateKey]
            ,[Title]
            ,[FirstName]
            ,[MiddleName]
            ,[LastName]
            ,[NameStyle]
            ,[BirthDate]
            ,[MaritalStatus]
            ,[Suffix]
            ,[Gender]
            ,[EmailAddress]
            ,[YearlyIncome]
            ,[TotalChildren]
            ,[NumberChildrenAtHome]
            ,[EnglishEducation]
            ,[SpanishEducation]
            ,[FrenchEducation]
            ,[EnglishOccupation]
            ,[SpanishOccupation]
            ,[FrenchOccupation]
            --Missing test columns
            -- ,[Test3]
            ,[HouseOwnerFlag]
            ,[NumberCarsOwned]
            ,[AddressLine1]
            ,[AddressLine2]
            ,[Phone]
            ,[DateFirstPurchase]
            ,[CommuteDistance]
            ,[IsCurrent]
            ,[InsertDate]
)

SELECT 
            @MaxID2 + ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS [CustomerKey]
            ,[GeographyKey]
            ,[CustomerAlternateKey]
            ,[Title]
            ,[FirstName]
            ,[MiddleName]
            ,[LastName]
            ,[NameStyle]
            ,[BirthDate]
            ,[MaritalStatus]
            ,[Suffix]
            ,[Gender]
            ,[EmailAddress]
            ,[YearlyIncome]
            ,[TotalChildren]
            ,[NumberChildrenAtHome]
            ,[EnglishEducation]
            ,[SpanishEducation]
            ,[FrenchEducation]
            ,[EnglishOccupation]
            ,[SpanishOccupation]
            ,[FrenchOccupation]
            --Missing columns here. AddressLine1 should show up as an error.
            --  ,GETDATE()
            ,[HouseOwnerFlag]
            ,[NumberCarsOwned]
            ,[AddressLine1]
            ,[AddressLine2]
            ,[Phone]
            ,[DateFirstPurchase]
            ,[CommuteDistance]
            ,[IsCurrent]
            ,[InsertDate]
FROM [AdventureWorksWarehouse].[dbo].[DimCustomer_test]

/*

	Try adjusting the columns in the INSERT and SELECT statements, and you should find that while the error column may change, it's still not the correct column. 
	If you reorder the columns in their entirety, it gets crazy.

*/