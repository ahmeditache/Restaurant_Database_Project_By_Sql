--This schema is divided into seven stages.

-- 01_departments.sql
IF OBJECT_ID('dbo.Departments','U') IS NOT NULL DROP TABLE dbo.Departments;
CREATE TABLE Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(50) NOT NULL
);
________________________________________

-- 02_jobtitles.sql
IF OBJECT_ID('dbo.JobTitles','U') IS NOT NULL DROP TABLE dbo.JobTitles;
CREATE TABLE JobTitles(
    JobID INT IDENTITY(1,1) PRIMARY KEY,
    JobTitle NVARCHAR(50) NOT NULL,
    DepartmentID INT NOT NULL,
    CONSTRAINT FK_JobTitles_Departments FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);
________________________________________

-- 03_employees.sql
IF OBJECT_ID('dbo.Employees','U') IS NOT NULL DROP TABLE dbo.Employees;
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    JobID INT NOT NULL,
    DepartmentID INT NOT NULL,
    HireDate DATE NOT NULL DEFAULT GETDATE(),
    BirthDate DATE NULL,
    Salary DECIMAL(10,2) NULL,
    PhoneNumber NVARCHAR(20) NULL,
    [Status] BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Employees_JobTitles FOREIGN KEY (JobID) REFERENCES JobTitles(JobID),
    CONSTRAINT FK_Employees_Departments FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);
________________________________________

-- 04_tables.sql
IF OBJECT_ID('dbo.Tabels','U') IS NOT NULL DROP TABLE dbo.Tabels;
CREATE TABLE Tabels (
    TableID INT PRIMARY KEY,
    TableNumber INT NOT NULL,
    CaptinID INT NULL,
    NumberOfGuests INT DEFAULT 1,
    CONSTRAINT FK_Tabels_Captin FOREIGN KEY (CaptinID) REFERENCES Employees(EmployeeID)
);
________________________________________

-- 05_customers.sql
IF OBJECT_ID('dbo.Customers','U') IS NOT NULL DROP TABLE dbo.Customers;
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    Phone1 NVARCHAR(20) NULL,
    Phone2 NVARCHAR(20) NULL,
    Address1 NVARCHAR(200) NULL,
    Address2 NVARCHAR(200) NULL,
    Note NVARCHAR(200) NULL
);
________________________________________

-- 06_categories_menu_promotions.sql
IF OBJECT_ID('dbo.Categories','U') IS NOT NULL DROP TABLE dbo.Categories;
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL
);

IF OBJECT_ID('dbo.MenuItems','U') IS NOT NULL DROP TABLE dbo.MenuItems;
CREATE TABLE MenuItems (
    ItemID INT IDENTITY(1,1) PRIMARY KEY,
    ItemName NVARCHAR(150) NOT NULL,
    CategoryID INT NOT NULL,
    [Size] NVARCHAR(20) NULL,
    Price DECIMAL(10,2) NOT NULL,
    IsAvailable BIT DEFAULT 1,
    CONSTRAINT FK_MenuItems_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

IF OBJECT_ID('dbo.Promotions','U') IS NOT NULL DROP TABLE dbo.Promotions;
CREATE TABLE Promotions (
    PromotionID INT IDENTITY(1,1) PRIMARY KEY,
    PromotionName NVARCHAR(100) NOT NULL,
    DiscountType NVARCHAR(10) CHECK (DiscountType IN ('PERCENT','AMOUNT')),
    DiscountValue DECIMAL(10,2) NOT NULL,
    StartDate DATETIME NOT NULL,
    EndDate DATETIME NOT NULL
);

IF OBJECT_ID('dbo.PromotionItems','U') IS NOT NULL DROP TABLE dbo.PromotionItems;
CREATE TABLE PromotionItems (
    PromotionID INT NOT NULL,
    ItemID INT NOT NULL,
    PRIMARY KEY (PromotionID, ItemID),
    FOREIGN KEY (PromotionID) REFERENCES Promotions(PromotionID),
    FOREIGN KEY (ItemID) REFERENCES MenuItems(ItemID)
);
________________________________________

-- 07_ingredients_suppliers_purchases.sql
IF OBJECT_ID('dbo.Ingredients','U') IS NOT NULL DROP TABLE dbo.Ingredients;
CREATE TABLE Ingredients (
    IngredientID INT IDENTITY(1,1) PRIMARY KEY,
    IngredientName NVARCHAR(100) NOT NULL,
    Unit NVARCHAR(20) NOT NULL,
    CurrentStock DECIMAL(10,2) DEFAULT 0
);

IF OBJECT_ID('dbo.Suppliers','U') IS NOT NULL DROP TABLE dbo.Suppliers;
CREATE TABLE Suppliers (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    Address NVARCHAR(200)
);

IF OBJECT_ID('dbo.Purchases','U') IS NOT NULL DROP TABLE dbo.Purchases;
CREATE TABLE Purchases (
    PurchaseID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT NOT NULL,
    IngredientID INT NOT NULL,
    Quantity DECIMAL(10,2) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    PurchaseDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    FOREIGN KEY (IngredientID) REFERENCES Ingredients(IngredientID)
);

IF OBJECT_ID('dbo.StockTransactions','U') IS NOT NULL DROP TABLE dbo.StockTransactions;
CREATE TABLE StockTransactions (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    IngredientID INT NOT NULL,
    Quantity DECIMAL(10,2) NOT NULL,
    TransactionType NVARCHAR(10) CHECK (TransactionType IN ('IN','OUT')),
    TransactionDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (IngredientID) REFERENCES Ingredients(IngredientID)
);

IF OBJECT_ID('dbo.ItemIngredients','U') IS NOT NULL DROP TABLE dbo.ItemIngredients;
CREATE TABLE ItemIngredients (
    ItemID INT NOT NULL,
    IngredientID INT NOT NULL,
    QuantityPerItem DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (ItemID, IngredientID),
    FOREIGN KEY (ItemID) REFERENCES MenuItems(ItemID),
    FOREIGN KEY (IngredientID) REFERENCES Ingredients(IngredientID)
);
________________________________________

-- 08_orders_orderitems.sql
IF OBJECT_ID('dbo.Orders','U') IS NOT NULL DROP TABLE dbo.Orders;
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    OrderDate DATETIME NOT NULL DEFAULT GETDATE(),
    OrderType NVARCHAR(20) NOT NULL,
    CustomerId INT NULL,
    TableId INT NULL,
    CaptinId INT NULL,
    DeliveryId INT NULL,
    CashierId INT NULL,
    TotalAmount DECIMAL(10,2) NULL,
    Status NVARCHAR(20) DEFAULT 'Open',
    PaymentMethod NVARCHAR(20) NOT NULL DEFAULT 'Cash',
    DiscountPercent DECIMAL(5,2) NULL,
    ServiceCharge DECIMAL(10,2) NULL,
    Tax DECIMAL(10,2) NULL,
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Orders_Tables FOREIGN KEY (TableId) REFERENCES Tabels(TableID),
    CONSTRAINT FK_Orders_Captin FOREIGN KEY (CaptinId) REFERENCES Employees(EmployeeID),
    CONSTRAINT FK_Orders_Delivery FOREIGN KEY (DeliveryId) REFERENCES Employees(EmployeeID),
    CONSTRAINT FK_Orders_Cashier FOREIGN KEY (CashierId) REFERENCES Employees(EmployeeID),
    CONSTRAINT CHK_PaymentMethod CHECK (PaymentMethod IN ('Cash','Credit','Visa'))
);

IF OBJECT_ID('dbo.OrderItems','U') IS NOT NULL DROP TABLE dbo.OrderItems;
CREATE TABLE OrderItems (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ItemID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    Price DECIMAL(10,2) NOT NULL,
    FinalPrice DECIMAL(10,2) NULL,
    PromotionID INT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ItemID) REFERENCES MenuItems(ItemID),
    FOREIGN KEY (PromotionID) REFERENCES Promotions(PromotionID)
);
________________________________________
