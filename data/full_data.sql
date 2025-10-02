-- ===================================================================
-- Complete SQL Data Insertions for Restaurant Management System
-- Enhanced version with professional fields
-- ===================================================================

----------------------------------------------------------
-- 01_Departments
----------------------------------------------------------
IF OBJECT_ID('dbo.Departments','U') IS NOT NULL DROP TABLE dbo.Departments;
CREATE TABLE Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(50) NOT NULL
);

INSERT INTO Departments (DepartmentName) VALUES
('Management'),
('Accounting'),
('Hall'),
('Kitchen'),
('Bar'),
('Delivery');

----------------------------------------------------------
-- 02_JobTitles
----------------------------------------------------------
IF OBJECT_ID('dbo.JobTitles','U') IS NOT NULL DROP TABLE dbo.JobTitles;
CREATE TABLE JobTitles(
    JobID INT IDENTITY(1,1) PRIMARY KEY,
    JobTitle NVARCHAR(50) NOT NULL,
    DepartmentID INT NOT NULL,
    CONSTRAINT FK_JobTitles_Departments FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- Management
INSERT INTO JobTitles (JobTitle, DepartmentID) VALUES
('Restaurant Manager',1),
('Executive Chef',1),
('Hall Manager',1),
('Supervisor',1);

-- Accounting
INSERT INTO JobTitles (JobTitle, DepartmentID) VALUES
('Head Cashier',2),
('Cashier',2);

-- Hall
INSERT INTO JobTitles (JobTitle, DepartmentID) VALUES
('Head Captain',3),
('Captain',3),
('Waiter',3),
('BusBoy',3);

-- Kitchen
INSERT INTO JobTitles (JobTitle, DepartmentID) VALUES
('Chef',4),
('Assistant Chef',4),
('Steward',4);

-- Bar
INSERT INTO JobTitles (JobTitle, DepartmentID) VALUES
('Bar Man',5),
('Assistant Bar',5),
('Steward',5);

-- Delivery
INSERT INTO JobTitles (JobTitle, DepartmentID) VALUES
('Delivery Supervisor',6),
('Delivery',6);

----------------------------------------------------------
-- 03_Employees
----------------------------------------------------------
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
    Email NVARCHAR(100) NULL,
    Address NVARCHAR(200) NULL,
    EmergencyContact NVARCHAR(50) NULL,
    CONSTRAINT FK_Employees_JobTitles FOREIGN KEY (JobID) REFERENCES JobTitles(JobID),
    CONSTRAINT FK_Employees_Departments FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- Sample Employee Insertions
INSERT INTO Employees (FullName, JobID, DepartmentID, BirthDate, Salary, PhoneNumber, Email, Address, EmergencyContact)
VALUES
('Ahmed Ibrahim',1,1,'1984-08-01',15000,'01025512521','ahmed.ibrahim@restaurant.com','Cairo, Egypt','01011111111'),
('Sayed Mahmoud',2,1,'1986-02-01',9000,'010255125241','sayed.mahmoud@restaurant.com','Giza, Egypt','01022222222'),
('Khaled Mansour',3,1,'1978-08-01',8000,'01025512521','khaled.mansour@restaurant.com','Alexandria, Egypt','01033333333'),
('Wael Ibrahim',3,1,'1982-08-01',7500,'01025525821','wael.ibrahim@restaurant.com','Cairo, Egypt','01044444444');

----------------------------------------------------------
-- 04_Tables
----------------------------------------------------------
IF OBJECT_ID('dbo.Tabels','U') IS NOT NULL DROP TABLE dbo.Tabels;
CREATE TABLE Tabels (
    TableID INT PRIMARY KEY,
    TableNumber INT NOT NULL,
    CaptinID INT NULL,
    NumberOfGuests INT DEFAULT 1,
    Location NVARCHAR(20) DEFAULT 'Indoor',
    TableStatus NVARCHAR(20) DEFAULT 'Available',
    CONSTRAINT FK_Tabels_Captin FOREIGN KEY (CaptinID) REFERENCES Employees(EmployeeID)
);

INSERT INTO Tabels (TableID, TableNumber, CaptinID, NumberOfGuests, Location, TableStatus)
VALUES
(1,1,NULL,4,'Indoor','Available'),
(2,2,NULL,2,'Outdoor','Available'),
(3,3,NULL,6,'Bar','Available');

----------------------------------------------------------
-- 05_Customers
----------------------------------------------------------
IF OBJECT_ID('dbo.Customers','U') IS NOT NULL DROP TABLE dbo.Customers;
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    Phone1 NVARCHAR(20) NULL,
    Phone2 NVARCHAR(20) NULL,
    Address1 NVARCHAR(200) NULL,
    Address2 NVARCHAR(200) NULL,
    Note NVARCHAR(200) NULL,
    Email NVARCHAR(100) NULL,
    DateOfBirth DATE NULL,
    LoyaltyPoints INT DEFAULT 0,
    PreferredPaymentMethod NVARCHAR(20) DEFAULT 'Cash'
);

-- Example Insertions
INSERT INTO Customers (CustomerID, CustomerName, Phone1, Phone2, Address1, Address2, Note, Email, DateOfBirth, LoyaltyPoints, PreferredPaymentMethod)
VALUES
(1,'Mohamed Hassan','01000000001','01100000001','Street 1','Cairo','Regular','mohamed.hassan@gmail.com','1990-05-12',120,'Cash'),
(2,'Ahmed Ibrahim','01000000002','01100000002','Street 2','Giza','VIP','ahmed.ibrahim@gmail.com','1985-03-20',250,'Credit');

----------------------------------------------------------
-- 06_Categories & MenuItems & Promotions
----------------------------------------------------------
IF OBJECT_ID('dbo.Categories','U') IS NOT NULL DROP TABLE dbo.Categories;
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL
);

INSERT INTO Categories (CategoryName) VALUES
('Pizza'),
('Pasta'),
('Grills'),
('Rice Dishes'),
('Drinks');

IF OBJECT_ID('dbo.MenuItems','U') IS NOT NULL DROP TABLE dbo.MenuItems;
CREATE TABLE MenuItems (
    ItemID INT IDENTITY(1,1) PRIMARY KEY,
    ItemName NVARCHAR(150) NOT NULL,
    CategoryID INT NOT NULL,
    [Size] NVARCHAR(20) NULL,
    Price DECIMAL(10,2) NOT NULL,
    IsAvailable BIT DEFAULT 1,
    Calories INT NULL,
    PreparationTime INT NULL,
    Brand NVARCHAR(50) NULL,
    CONSTRAINT FK_MenuItems_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

INSERT INTO MenuItems (ItemName, CategoryID, [Size], Price, Calories, PreparationTime)
VALUES
('Vegetarian Pizza',1,'Small',100,250,15),
('Vegetarian Pizza',1,'Medium',150,400,20),
('Vegetarian Pizza',1,'Large',200,550,25);

IF OBJECT_ID('dbo.Promotions','U') IS NOT NULL DROP TABLE dbo.Promotions;
CREATE TABLE Promotions (
    PromotionID INT IDENTITY(1,1) PRIMARY KEY,
    PromotionName NVARCHAR(100) NOT NULL,
    DiscountType NVARCHAR(10) CHECK (DiscountType IN ('PERCENT','AMOUNT')),
    DiscountValue DECIMAL(10,2) NOT NULL,
    StartDate DATETIME NOT NULL,
    EndDate DATETIME NOT NULL,
    PromoCode NVARCHAR(50) NULL,
    UsageLimit INT NULL
);

IF OBJECT_ID('dbo.PromotionItems','U') IS NOT NULL DROP TABLE dbo.PromotionItems;
CREATE TABLE PromotionItems (
    PromotionID INT NOT NULL,
    ItemID INT NOT NULL,
    PRIMARY KEY (PromotionID, ItemID),
    FOREIGN KEY (PromotionID) REFERENCES Promotions(PromotionID),
    FOREIGN KEY (ItemID) REFERENCES MenuItems(ItemID)
);

----------------------------------------------------------
-- 07_Ingredients, Suppliers, Purchases, StockTransactions, ItemIngredients
----------------------------------------------------------
IF OBJECT_ID('dbo.Ingredients','U') IS NOT NULL DROP TABLE dbo.Ingredients;
CREATE TABLE Ingredients (
    IngredientID INT IDENTITY(1,1) PRIMARY KEY,
    IngredientName NVARCHAR(100) NOT NULL,
    Unit NVARCHAR(20) NOT NULL,
    CurrentStock DECIMAL(10,2) DEFAULT 0
);

INSERT INTO Ingredients (IngredientName, Unit, CurrentStock) VALUES
('Tomatoes','Kg',100),
('Chicken Breast','Kg',50);

IF OBJECT_ID('dbo.Suppliers','U') IS NOT NULL DROP TABLE dbo.Suppliers;
CREATE TABLE Suppliers (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    Address NVARCHAR(200)
);

INSERT INTO Suppliers (SupplierName, Phone, Address)
VALUES
('Fresh Farms Co.','+1-555-1234','45 Market Street, New York');

IF OBJECT_ID('dbo.Purchases','U') IS NOT NULL DROP TABLE dbo.Purchases;
CREATE TABLE Purchases (
    PurchaseID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT NOT NULL,
    IngredientID INT NOT NULL,
    Quantity DECIMAL(10,2) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    PurchaseDate DATETIME DEFAULT GETDATE(),
    InvoiceNumber NVARCHAR(50) NULL,
    ExpiryDate DATE NULL,
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

----------------------------------------------------------
-- 08_Orders & OrderItems
----------------------------------------------------------
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
    OrderNotes NVARCHAR(200) NULL,
    DeliveryTime DATETIME NULL,
    TipAmount DECIMAL(10,2) NULL,
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
