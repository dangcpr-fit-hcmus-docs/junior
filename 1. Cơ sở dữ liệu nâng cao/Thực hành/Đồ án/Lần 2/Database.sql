USE master
GO
IF DB_ID('SellingDatabase') IS NOT NULL
	DROP DATABASE SellingDatabase
GO
	CREATE DATABASE SellingDatabase
GO
	USE SellingDatabase
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ContractStatus]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[ContractStatus] (
	[ContractStatusID] [INT] IDENTITY(1,1),
	[ContractID] [INT],
	[StatusID] [INT] DEFAULT 6,
	[ContractStatusTime] [DATETIME] DEFAULT GETDATE(),
	CONSTRAINT [PK_ContractStatus]  PRIMARY KEY CLUSTERED (ContractStatusID)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProductStatus]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[ProductStatus] (
	[ProductStatusID] [INT] IDENTITY(1,1),
	[ProductID] [INT],
	[StatusID] [INT] DEFAULT 6,
	[ProductStatusTime] [DATETIME] DEFAULT GETDATE()
	CONSTRAINT [PK_ProductStatus] PRIMARY KEY CLUSTERED (ProductStatusID)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Product]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[Product] (
	[ProductID] [INT] IDENTITY(1000,1),
	[ProductName] [NCHAR](80),
	[ProductDescription] [NVARCHAR](200),
	[ProductPrice] [MONEY] DEFAULT 0,
	[BranchProductTypeID] [INT],
	[ProductTypeID] [INT],
	CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED (ProductID)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProductOption]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[ProductOption] (
	[ProductOptionID] [INT] IDENTITY(1,1),
	[ProductOptionName] [NCHAR](40),
	[ProductOptionPrice] [MONEY] DEFAULT 0,	
	[ProductTypeID] [INT],
	CONSTRAINT [PK_ProductOption] PRIMARY KEY CLUSTERED  (ProductOptionID)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[BranchStatus]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[BranchStatus] (
	[BranchStatusID] INT IDENTITY (1,1),
	[BranchID] [INT],
	[StatusID] [INT] DEFAULT 0,
	[BranchStatusTime] [DATETIME] DEFAULT GETDATE(),
	CONSTRAINT [PK_BranchStatus] PRIMARY KEY CLUSTERED (BranchStatusID)
) ON [PRIMARY]
END
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProductType]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[ProductType](
	[ProductTypeId] [INT] IDENTITY(1, 1),
	[ProductTypeName] [NCHAR](20) NOT NULL,
	CONSTRAINT [PK_ProductType] PRIMARY KEY CLUSTERED (ProductTypeId)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[BranchProductType]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[BranchProductType] (
	[BranchProductTypeID] [INT] IDENTITY(1000,1),
	[BranchID] [INT],
	[ProductTypeID] [INT],
	CONSTRAINT [PK_BranchProductType] PRIMARY KEY CLUSTERED (BranchProductTypeID)
) ON [PRIMARY]
END
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Branch]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[Branch] (
	[BranchID] [INT] IDENTITY(1000,1),
	[BranchName] [NCHAR](40),
	[BranchAddressNoR] [CHAR](20),
	[BranchAddressRoad] [NCHAR](20),
	[BranchAddressWard] [NCHAR](20),
	[BranchAddressDistrict] [NCHAR](20),
	[BranchAddressCity] [NCHAR](20),
	[BranchUpdateNameDate] [DATETIME],
	[BranchOpenTime] [TIME],
	[BranchCloseTime] [TIME],
	[BranchTotalRevenue] [MONEY] DEFAULT 0,
	[ContractID] [INT],
	[AreaID] [INT],
	CONSTRAINT [PK_Branch] PRIMARY KEY CLUSTERED (BranchID)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Contract]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[Contract] (
	[ContractID] [INT] IDENTITY(1000,1),
	[ContractDate] [DATETIME],
	[ContractRepresentative] [NCHAR](40),
	[ContractNoBranch] [INT],
	[ContractStartDay] [DATETIME],
	[ContractEndDay] [DATETIME],
	[ContractCommission] [FLOAT],
	[ContractTotalRevenue] [INT] DEFAULT 0,
	[PartnerID] [INT] NOT NULL,
	CONSTRAINT [PK_Contract]  PRIMARY KEY CLUSTERED (ContractID)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Partner]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[Partner] (
	[PartnerID] [INT] IDENTITY(1000,1),
	[PartnerName] [NCHAR](40),
	[PartnerEmail] [CHAR](40),
	[PartnerTaxCode] [CHAR](13),
	[PartnerRepresentative] [NCHAR](40),
	[PartnerNoBranch] [INT] DEFAULT 0,
	[PartnerNoOrderMin] [INT] DEFAULT 0,
	[PartnerNoOrderMax] [INT] DEFAULT 0,
	[PartnerPhone] [CHAR](10),
	[PartnerAddressNoR] [INT],
	[PartnerAddressRoad] [NCHAR](20),
	[PartnerAddressWard] [NCHAR](20),
	[PartnerAddressDistrict] [NCHAR](20),
	[PartnerAddressCity] [NCHAR](20),
	[PartnerRegisterTime] [DATETIME] DEFAULT GETDATE(),
	[WalletID] [INT],
	[StaffID] [INT]
	CONSTRAINT [PK_Partner]  PRIMARY KEY CLUSTERED (PartnerID)
) ON [PRIMARY]
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[OrderProduct]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[OrderProduct] (
	[OrderID] [INT],
	[ProductID] [INT],
	[OrderProductFinalPrice] [MONEY] DEFAULT 0,
	[OrderProductQuantity] [INT] DEFAULT 1,
	[OrderProductNote] [NCHAR](200)
	CONSTRAINT [PK_OrderProduct]  PRIMARY KEY CLUSTERED (OrderID, ProductID)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[OrderForm]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[OrderForm] (
	[OrderID] [INT] IDENTITY(100000,1),
	[OrderPhone] [CHAR](10),
	[OrderDate] [DATETIME] DEFAULT GETDATE(),
	[OrderAddressNoR] [CHAR](20),
	[OrderAddressRoad] [NCHAR](20),
	[OrderAddressWard] [NCHAR](20),
	[OrderAddressDistrict] [NCHAR](20),
	[OrderAddressCity] [NCHAR](20),
	[OrderShippingCharges] [MONEY] DEFAULT 25000,
	[OrderFinalPrice] [MONEY] DEFAULT 0,
	[OrderArea] [INT],
	[CustomerID] [INT],
	[BranchID] [INT],
	[DriverID] [INT],
	[AreaID] [INT]
	CONSTRAINT [PK_Order] PRIMARY KEY CLUSTERED (OrderID)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[OrderStatus]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[OrderStatus] (
	[OrderStatusID] [INT] IDENTITY(1,1),
	[OrderID] [INT],
	[StatusID] [INT],
	[OrderStatusTime] [DATETIME] DEFAULT GETDATE()
	CONSTRAINT PK_OrderStatus primary key (OrderStatusID)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[StatusCategory]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[StatusCategory](
	[StatusId] [INT] IDENTITY(-1, 1),
	[StatusName] [CHAR](20) NOT NULL,
	CONSTRAINT [PK_Status] PRIMARY KEY CLUSTERED (StatusId)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Customer]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
create table [dbo].[Customer] (
	[CustomerID] [INT] IDENTITY(100000,1),
	[CustomerName] [NCHAR](40),	
	[CustomerPhone] [CHAR](10),
	[CustomerEmail] [CHAR](40),
	[CustomerAddressNoR] [CHAR](20),
	[CustomerAddressRoad] [NCHAR](20),
	[CustomerAddressWard] [NCHAR](20),
	[CustomerAddressDistrict] [NCHAR](20),
	[CustomerAddressCity] [NCHAR](20),
	[WalletID] [INT],
	CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED (CustomerID)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Rating]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[Rating] (
	[RatingID] [INT] IDENTITY(1,1),
	[CustomerID] [INT],
	[RatingStar] [INT] CHECK ([RatingStar] >= 1 AND [RatingStar] <= 5),
	[RatingComment] [NVARCHAR](200),
	[RatingTime] DATETIME DEFAULT GETDATE(),
	[DriverID] [INT],
	[ProductID] [INT],
	[BranchID] [INT],
	CONSTRAINT [PK_Rating] PRIMARY KEY CLUSTERED (RatingID, CustomerID)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[CustomerStatus]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[CustomerStatus] (
	[CustomerStatusID] [INT] IDENTITY(1,1),
	[CustomerID] [INT],
	[StatusID] [INT] DEFAULT 0,
	[CustomerStatusTime] [DATETIME] DEFAULT GETDATE(),
	CONSTRAINT PK_CustomerStatus primary key (CustomerStatusID)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Driver]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[Driver] (
	[DriverID] [INT] IDENTITY (1000,1),
	[DriverName] [NCHAR](40),	
	[DriverCitizenID] [CHAR](12),
	[DriverPhone] [CHAR](10),
	[DriverAddressNoR] [NCHAR](20),
	[DriverAddressRoad] [NCHAR](20),
	[DriverAddressWard] [NCHAR](20),
	[DriverAddressDistrict] [NCHAR](20),
	[DriverAddressCity] [NCHAR](20),
	[DriverLicensePlates] [CHAR](12),
	[DriverEmail] [CHAR](40),
	[DriverFee] [MONEY] DEFAULT 300000,
	[WalletID] [INT],
	CONSTRAINT [PK_Driver] PRIMARY KEY CLUSTERED (DriverID)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DriverStatus]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[DriverStatus] (
	[DriverStatusID] [INT] IDENTITY(1,1),
	[DriverID] [INT],
	[StatusID] [INT] DEFAULT 0 CHECK ([StatusID] >= 0 AND [StatusID] <= 6),
	[DriverStatusTime] [DATETIME] DEFAULT GETDATE(),
	CONSTRAINT PK_DriverStatus PRIMARY KEY CLUSTERED (DriverStatusID)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DriverArea]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[DriverArea] (
	[DriverID] [INT],
	[AreaID] [INT],
	CONSTRAINT PK_DriverArea primary key (DriverID, AreaID)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Area]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[Area](
	[AreaId] [INT] IDENTITY(1, 1),
	[AreaWard] [NCHAR](20) NOT NULL,
	[AreaDistrict] [NCHAR](20) NOT NULL,
	[AreaCity] [NCHAR](20) NOT NULL,
	CONSTRAINT [PK_Area] PRIMARY KEY CLUSTERED (AreaId)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Wallet]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[Wallet] (
	[WalletID] [INT] IDENTITY(100000,1),
	[WalletBankID] [CHAR](12),
	[WalletBankName] [NCHAR](30),
	[WalletDeposits] [MONEY] DEFAULT 0,
	CONSTRAINT [PK_Wallet] PRIMARY KEY CLUSTERED (WalletID)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Report]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[Report] (
	[ReportID] [INT] IDENTITY(1,1),
	[ReportEarning] [MONEY] DEFAULT 0,
	[ReportTotalOrder] [INT] DEFAULT 0,
	[ReportStartTime] [DATETIME],
	[ReportEndTime] [DATETIME],
	[DriverID] [INT],
	CONSTRAINT [PK_Report] PRIMARY KEY CLUSTERED (ReportID)
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[WalletStatus]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[WalletStatus] (
	[WalletStatusID] [INT] IDENTITY(1,1),
	[WalletID] [INT],
	[StatusID] [INT] DEFAULT 6 CHECK ([StatusID] >= 0 AND [StatusID] <= 6),
	[WalletStatusTime] [DATETIME] DEFAULT GETDATE(),
	CONSTRAINT [PK_WalletStatus]  PRIMARY KEY CLUSTERED (WalletStatusID)
) ON [PRIMARY]
end
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Staff]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[Staff] (
	[StaffID] [INT] IDENTITY(1000,1) ,
	[StaffName] [NCHAR](40),
	[StaffCitizenID] [CHAR](12),
	[StaffPhone] [CHAR](10),
	[StaffEmail] [CHAR](40),
	[StaffAddressNoR] [INT] CHECK ([StaffAddressNoR] >= 100 AND [StaffAddressNoR] <= 999),
	[StaffAddressRoad] [NCHAR](20),
	[StaffAddressWard] [NCHAR](20),
	[StaffAddressDistrict] [NCHAR](20),
	[StaffAddressCity] [NCHAR](20),
	[StaffWorkingTime] [INT] CHECK ([StaffWorkingTime] >= 0 AND [StaffWorkingTime] <= 1500),
	[StaffCoefficient] [FLOAT],
	[StaffAdmin] [INT],
	CONSTRAINT [PK_Staff] PRIMARY KEY CLUSTERED (StaffID)
)  ON [PRIMARY]
end
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[StaffStatus]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
create table [dbo].[StaffStatus] (
	[StaffStatusID] [INT] IDENTITY(1,1),
	[StaffID] [INT],
	[StatusID] [INT] DEFAULT 0,
	[StaffStatusTime] [DATETIME] DEFAULT GETDATE(),
	CONSTRAINT [PK_StaffStatus]  PRIMARY KEY CLUSTERED  (StaffStatusID)
) ON [PRIMARY]
END
GO

ALTER TABLE ContractStatus ADD CONSTRAINT FK_ContractStatus_Contract
FOREIGN KEY (ContractID) REFERENCES [dbo].[Contract](ContractID)
go

ALTER TABLE ContractStatus ADD CONSTRAINT FK_ContractStatus_Status
FOREIGN KEY (StatusID) REFERENCES StatusCategory(StatusID)
go

ALTER TABLE ProductStatus ADD CONSTRAINT FK_ProductStatus_Product
FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
go

ALTER TABLE ProductStatus ADD CONSTRAINT FK_ProductStatus_Status
FOREIGN KEY (StatusID) REFERENCES StatusCategory(StatusID)
go

ALTER TABLE Product ADD CONSTRAINT FK_Product_BranchProductType
FOREIGN KEY (BranchProductTypeID) REFERENCES BranchProductType(BranchProductTypeID) ON DELETE SET NULL
go

ALTER TABLE ProductOption ADD CONSTRAINT FK_ProductOption_ProductType
FOREIGN KEY (ProductTypeID) REFERENCES ProductType(ProductTypeID) ON DELETE SET NULL
go

ALTER TABLE BranchStatus ADD CONSTRAINT FK_BranchStatus_Branch
FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
go

ALTER TABLE BranchStatus ADD CONSTRAINT FK_BranchStatus_Status
FOREIGN KEY (StatusID) REFERENCES StatusCategory(StatusID)
go

ALTER TABLE BranchProductType ADD CONSTRAINT FK_BranchProductType_Branch
FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
go

ALTER TABLE BranchProductType ADD CONSTRAINT FK_BranchProductType_ProductType
FOREIGN KEY (ProductTypeID) REFERENCES ProductType(ProductTypeID)
go

ALTER TABLE Branch ADD CONSTRAINT FK_Branch_Contract
FOREIGN KEY (ContractID) REFERENCES [dbo].[Contract](ContractID) ON DELETE SET NULL
go

ALTER TABLE Branch ADD CONSTRAINT FK_Branch_Area
FOREIGN KEY (AreaID) REFERENCES Area(AreaID)
go

ALTER TABLE [dbo].[Contract] ADD CONSTRAINT FK_Contract_Partner
FOREIGN KEY (PartnerID) REFERENCES [dbo].[Partner](PartnerID)
go

ALTER TABLE [dbo].[Partner] ADD CONSTRAINT FK_Partner_Wallet
FOREIGN KEY (WalletID) REFERENCES Wallet(WalletID) ON DELETE SET NULL
go

ALTER TABLE [dbo].[Partner] ADD CONSTRAINT FK_Partner_Staff
FOREIGN KEY (StaffID) REFERENCES Staff(StaffID) ON DELETE SET NULL
go


ALTER TABLE OrderProduct ADD CONSTRAINT FK_OrderProduct_Order
FOREIGN KEY (OrderID) REFERENCES [dbo].[OrderForm](OrderID)
go

ALTER TABLE OrderProduct ADD CONSTRAINT FK_OrderProduct_Product
FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
go

ALTER TABLE OrderForm ADD CONSTRAINT FK_Order_Customer
FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE SET NULL
go

ALTER TABLE OrderForm ADD CONSTRAINT FK_Order_Branch
FOREIGN KEY (BranchID) REFERENCES Branch(BranchID) ON DELETE SET NULL
go

ALTER TABLE OrderForm ADD CONSTRAINT FK_Order_Driver
FOREIGN KEY (DriverID) REFERENCES Driver(DriverID) ON DELETE SET NULL
GO

ALTER TABLE OrderForm ADD CONSTRAINT FK_Order_Area
FOREIGN KEY (AreaID) REFERENCES Area(AreaID) ON DELETE SET NULL
go


ALTER TABLE OrderStatus ADD CONSTRAINT FK_OrderStatus_Order
FOREIGN KEY (OrderID) REFERENCES OrderForm(OrderID) ON DELETE SET NULL
go

ALTER TABLE OrderStatus ADD CONSTRAINT FK_OrderStatus_Status
FOREIGN KEY (StatusID) REFERENCES StatusCategory(StatusID) ON DELETE SET NULL
go

ALTER TABLE Customer ADD CONSTRAINT FK_Customer_Wallet
FOREIGN KEY (WalletID) REFERENCES Wallet(WalletID) ON DELETE SET NULL
go

ALTER TABLE Rating ADD CONSTRAINT FK_Rating_Customer
FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
go

ALTER TABLE Rating ADD CONSTRAINT FK_Rating_Driver
FOREIGN KEY (DriverID) REFERENCES Driver(DriverID) ON DELETE SET NULL
go

ALTER TABLE Rating ADD CONSTRAINT FK_Rating_Product
FOREIGN KEY (ProductID) REFERENCES Product(ProductID) ON DELETE SET NULL
go

ALTER TABLE Rating ADD CONSTRAINT FK_Rating_Branch
FOREIGN KEY (BranchID) REFERENCES Branch(BranchID) ON DELETE SET NULL
go

ALTER TABLE CustomerStatus ADD CONSTRAINT FK_CustomerStatus_Customer
FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE SET NULL
go

ALTER TABLE CustomerStatus ADD CONSTRAINT FK_CustomerStatus_Status
FOREIGN KEY (StatusID) REFERENCES StatusCategory(StatusID) ON DELETE SET NULL
go

ALTER TABLE Driver ADD CONSTRAINT FK_Driver_Wallet
FOREIGN KEY (WalletID) REFERENCES Wallet(WalletID) ON DELETE SET NULL
go


ALTER TABLE DriverStatus ADD CONSTRAINT FK_DriverStatus_Driver
FOREIGN KEY (DriverID) REFERENCES Driver(DriverID) ON DELETE SET NULL
go

ALTER TABLE DriverStatus ADD CONSTRAINT FK_DriverStatus_Status
FOREIGN KEY (StatusID) REFERENCES StatusCategory(StatusID)
go

ALTER TABLE DriverArea ADD CONSTRAINT FK_DriverArea_Driver
FOREIGN KEY (DriverID) REFERENCES Driver(DriverID)
go

ALTER TABLE DriverArea ADD CONSTRAINT FK_DriverArea_Area
FOREIGN KEY (AreaID) REFERENCES Area(AreaID)
go

ALTER TABLE WalletStatus ADD CONSTRAINT FK_WalletStatus_Wallet
FOREIGN KEY (WalletID) REFERENCES Wallet(WalletID) ON DELETE SET NULL
go

ALTER TABLE WalletStatus ADD CONSTRAINT FK_WalletStatus_Status
FOREIGN KEY (StatusID) REFERENCES StatusCategory(StatusID) ON DELETE SET NULL
go

ALTER TABLE Staff ADD CONSTRAINT FK_Staff_Staff
FOREIGN KEY (StaffAdmin) REFERENCES Staff(StaffID)
go

ALTER TABLE StaffStatus ADD CONSTRAINT FK_StaffStatus_Staff
FOREIGN KEY (StaffID) REFERENCES Staff(StaffID) ON DELETE SET NULL
GO 

ALTER TABLE StaffStatus ADD CONSTRAINT FK_StaffStatus_Status
FOREIGN KEY (StatusID) REFERENCES StatusCategory(StatusID) ON DELETE SET NULL
GO

ALTER TABLE Report ADD CONSTRAINT FK_Report_Driver
FOREIGN KEY (DriverID) REFERENCES Driver(DriverID)
go