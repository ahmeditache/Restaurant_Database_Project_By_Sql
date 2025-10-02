/* ===========================================================================
   Advanced Professional Procedures for Restaurant Management System
   Includes:
   - Transactions
   - Error Handling
   - Stock Validation
   - Automatic Discount Calculation
   =========================================================================== */

/* ===========================================================================
   01_Employees Module
   =========================================================================== */

-- Add Employee
CREATE PROCEDURE sp_AddEmployee
    @FullName NVARCHAR(100),
    @JobID INT,
    @DepartmentID INT,
    @BirthDate DATE = NULL,
    @Salary DECIMAL(10,2) = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Address NVARCHAR(200) = NULL,
    @EmergencyContact NVARCHAR(50) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO Employees (FullName, JobID, DepartmentID, BirthDate, Salary, PhoneNumber, Email, Address, EmergencyContact)
            VALUES (@FullName, @JobID, @DepartmentID, @BirthDate, @Salary, @PhoneNumber, @Email, @Address, @EmergencyContact);
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Update Employee
CREATE PROCEDURE sp_UpdateEmployee
    @EmployeeID INT,
    @FullName NVARCHAR(100) = NULL,
    @JobID INT = NULL,
    @DepartmentID INT = NULL,
    @Salary DECIMAL(10,2) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            UPDATE Employees
            SET
                FullName = ISNULL(@FullName, FullName),
                JobID = ISNULL(@JobID, JobID),
                DepartmentID = ISNULL(@DepartmentID, DepartmentID),
                Salary = ISNULL(@Salary, Salary)
            WHERE EmployeeID = @EmployeeID;
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Delete Employee
CREATE PROCEDURE sp_DeleteEmployee
    @EmployeeID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DELETE FROM Employees WHERE EmployeeID = @EmployeeID;
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

/* ===========================================================================
   02_Customers Module
   =========================================================================== */

-- Add Customer
CREATE PROCEDURE sp_AddCustomer
    @CustomerName NVARCHAR(100),
    @Phone1 NVARCHAR(20) = NULL,
    @Phone2 NVARCHAR(20) = NULL,
    @Address1 NVARCHAR(200) = NULL,
    @Address2 NVARCHAR(200) = NULL,
    @Email NVARCHAR(100) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO Customers (CustomerName, Phone1, Phone2, Address1, Address2, Email)
            VALUES (@CustomerName, @Phone1, @Phone2, @Address1, @Address2, @Email);
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Update Customer
CREATE PROCEDURE sp_UpdateCustomer
    @CustomerID INT,
    @CustomerName NVARCHAR(100) = NULL,
    @Phone1 NVARCHAR(20) = NULL,
    @Phone2 NVARCHAR(20) = NULL,
    @Address1 NVARCHAR(200) = NULL,
    @Address2 NVARCHAR(200) = NULL,
    @Email NVARCHAR(100) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            UPDATE Customers
            SET
                CustomerName = ISNULL(@CustomerName, CustomerName),
                Phone1 = ISNULL(@Phone1, Phone1),
                Phone2 = ISNULL(@Phone2, Phone2),
                Address1 = ISNULL(@Address1, Address1),
                Address2 = ISNULL(@Address2, Address2),
                Email = ISNULL(@Email, Email)
            WHERE CustomerID = @CustomerID;
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

/* ===========================================================================
   03_MenuItems Module
   =========================================================================== */

-- Add MenuItem
CREATE PROCEDURE sp_AddMenuItem
    @ItemName NVARCHAR(150),
    @CategoryID INT,
    @Size NVARCHAR(20) = NULL,
    @Price DECIMAL(10,2),
    @Calories INT = NULL,
    @PreparationTime INT = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO MenuItems (ItemName, CategoryID, [Size], Price, Calories, PreparationTime)
            VALUES (@ItemName, @CategoryID, @Size, @Price, @Calories, @PreparationTime);
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Update MenuItem
CREATE PROCEDURE sp_UpdateMenuItem
    @ItemID INT,
    @ItemName NVARCHAR(150) = NULL,
    @CategoryID INT = NULL,
    @Size NVARCHAR(20) = NULL,
    @Price DECIMAL(10,2) = NULL,
    @Calories INT = NULL,
    @PreparationTime INT = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            UPDATE MenuItems
            SET
                ItemName = ISNULL(@ItemName, ItemName),
                CategoryID = ISNULL(@CategoryID, CategoryID),
                [Size] = ISNULL(@Size, [Size]),
                Price = ISNULL(@Price, Price),
                Calories = ISNULL(@Calories, Calories),
                PreparationTime = ISNULL(@PreparationTime, PreparationTime)
            WHERE ItemID = @ItemID;
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

/* ===========================================================================
   04_Orders Module with Stock & Promotion Logic
   =========================================================================== */

-- Add Order
CREATE PROCEDURE sp_AddOrderAdvanced
    @OrderType NVARCHAR(20),
    @CustomerId INT = NULL,
    @TableId INT = NULL,
    @CaptinId INT = NULL,
    @DeliveryId INT = NULL,
    @CashierId INT = NULL,
    @PaymentMethod NVARCHAR(20) = 'Cash',
    @OrderNotes NVARCHAR(200) = NULL
AS
BEGIN
    DECLARE @NewOrderID INT;
    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO Orders (OrderType, CustomerId, TableId, CaptinId, DeliveryId, CashierId, PaymentMethod, OrderNotes)
            VALUES (@OrderType, @CustomerId, @TableId, @CaptinId, @DeliveryId, @CashierId, @PaymentMethod, @OrderNotes);

            SET @NewOrderID = SCOPE_IDENTITY();
        COMMIT TRANSACTION

        SELECT @NewOrderID AS NewOrderID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Add OrderItem with Stock Validation & Promotion
CREATE PROCEDURE sp_AddOrderItemAdvanced
    @OrderID INT,
    @ItemID INT,
    @Quantity INT = 1,
    @PromotionID INT = NULL
AS
BEGIN
    DECLARE @InsufficientStock BIT = 0;
    DECLARE @RequiredQty DECIMAL(10,2);
    DECLARE @IngredientID INT;
    DECLARE @AvailableStock DECIMAL(10,2);
    DECLARE @Price DECIMAL(10,2);
    DECLARE @FinalPrice DECIMAL(10,2);

    BEGIN TRY
        BEGIN TRANSACTION
            -- Check stock
            DECLARE curIngredients CURSOR FOR
                SELECT IngredientID, QuantityPerItem FROM ItemIngredients WHERE ItemID = @ItemID;

            OPEN curIngredients;
            FETCH NEXT FROM curIngredients INTO @IngredientID, @RequiredQty;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                SELECT @AvailableStock = CurrentStock FROM Ingredients WHERE IngredientID = @IngredientID;
                IF @AvailableStock < (@RequiredQty * @Quantity)
                    SET @InsufficientStock = 1;

                FETCH NEXT FROM curIngredients INTO @IngredientID, @RequiredQty;
            END

            CLOSE curIngredients;
            DEALLOCATE curIngredients;

            IF @InsufficientStock = 1
            BEGIN
                RAISERROR('Insufficient stock for one or more ingredients.',16,1);
                ROLLBACK TRANSACTION;
                RETURN;
            END

            -- Calculate final price
            SELECT @Price = Price FROM MenuItems WHERE ItemID = @ItemID;
            SET @FinalPrice = @Price * @Quantity;

            IF @PromotionID IS NOT NULL
            BEGIN
                DECLARE @DiscountType NVARCHAR(10);
                DECLARE @DiscountValue DECIMAL(10,2);

                SELECT @DiscountType = DiscountType, @DiscountValue = DiscountValue
                FROM Promotions WHERE PromotionID = @PromotionID;

                IF @DiscountType = 'PERCENT'
                    SET @FinalPrice = @FinalPrice * (1 - @DiscountValue/100);
                ELSE
                    SET @FinalPrice = @FinalPrice - @DiscountValue;
            END

            -- Insert OrderItem
            INSERT INTO OrderItems (OrderID, ItemID, Quantity, Price, FinalPrice, PromotionID)
            VALUES (@OrderID, @ItemID, @Quantity, @Price, @FinalPrice, @PromotionID);

            -- Update stock
            DECLARE curIngredients2 CURSOR FOR
                SELECT IngredientID, QuantityPerItem FROM ItemIngredients WHERE ItemID = @ItemID;

            OPEN curIngredients2;
            FETCH NEXT FROM curIngredients2 INTO @IngredientID, @RequiredQty;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                UPDATE Ingredients
                SET CurrentStock = CurrentStock - (@RequiredQty * @Quantity)
                WHERE IngredientID = @IngredientID;

                FETCH NEXT FROM curIngredients2 INTO @IngredientID, @RequiredQty;
            END

            CLOSE curIngredients2;
            DEALLOCATE curIngredients2;

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

/* ===========================================================================
   05_Stock Module
   =========================================================================== */

-- Add Purchase & Update Stock
CREATE PROCEDURE sp_AddPurchase
    @SupplierID INT,
    @IngredientID INT,
    @Quantity DECIMAL(10,2),
    @Price DECIMAL(10,2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO Purchases (SupplierID, IngredientID, Quantity, Price)
            VALUES (@SupplierID, @IngredientID, @Quantity, @Price);

            UPDATE Ingredients
            SET CurrentStock = CurrentStock + @Quantity
            WHERE IngredientID = @IngredientID;
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Stock Transaction (IN/OUT)
CREATE PROCEDURE sp_AddStockTransaction
    @IngredientID INT,
    @Quantity DECIMAL(10,2),
    @TransactionType NVARCHAR(10)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO StockTransactions (IngredientID, Quantity, TransactionType)
            VALUES (@IngredientID, @Quantity, @TransactionType);

            IF @TransactionType = 'IN'
                UPDATE Ingredients SET CurrentStock = CurrentStock + @Quantity WHERE IngredientID = @IngredientID;
            ELSE
                UPDATE Ingredients SET CurrentStock = CurrentStock - @Quantity WHERE IngredientID = @IngredientID;
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

/* ===========================================================================
   06_Promotions Module
   =========================================================================== */

-- Add Promotion
CREATE PROCEDURE sp_AddPromotion
    @PromotionName NVARCHAR(100),
    @DiscountType NVARCHAR(10),
    @DiscountValue DECIMAL(10,2),
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO Promotions (PromotionName, DiscountType, DiscountValue, StartDate, EndDate)
            VALUES (@PromotionName, @DiscountType, @DiscountValue, @StartDate, @EndDate);
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Link Promotion to Item
CREATE PROCEDURE sp_AddPromotionItem
    @PromotionID INT,
    @ItemID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO PromotionItems (PromotionID, ItemID)
            VALUES (@PromotionID, @ItemID);
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
