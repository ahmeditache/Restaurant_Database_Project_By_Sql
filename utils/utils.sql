/* ===========================================================================
   Restaurant Management System - Utility Scripts
   =========================================================================== */

/* ===========================================================================
   01_GetCurrentDateTime
   Returns the current server datetime in a standard format
   =========================================================================== */
CREATE FUNCTION fn_GetCurrentDateTime()
RETURNS DATETIME
AS
BEGIN
    RETURN GETDATE()
END
GO

/* ===========================================================================
   02_CalculateOrderTotal
   Calculates the total amount for a given order including discounts, tax, service charge
   =========================================================================== */
CREATE FUNCTION fn_CalculateOrderTotal(@OrderID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Total DECIMAL(10,2) = 0
    SELECT @Total = SUM(FinalPrice)
    FROM OrderItems
    WHERE OrderID = @OrderID

    DECLARE @Discount DECIMAL(5,2), @Tax DECIMAL(10,2), @Service DECIMAL(10,2)
    SELECT @Discount = ISNULL(DiscountPercent,0), @Tax = ISNULL(Tax,0), @Service = ISNULL(ServiceCharge,0)
    FROM Orders WHERE OrderID = @OrderID

    SET @Total = @Total * (1 - @Discount/100) + ISNULL(@Tax,0) + ISNULL(@Service,0)

    RETURN @Total
END
GO

/* ===========================================================================
   03_LogAction
   Logs actions into a general logging table
   =========================================================================== */
IF OBJECT_ID('dbo.ActionLogs','U') IS NULL
CREATE TABLE ActionLogs
(
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    LogDate DATETIME DEFAULT GETDATE(),
    UserName NVARCHAR(100),
    Action NVARCHAR(200),
    Details NVARCHAR(MAX)
);
GO

CREATE PROCEDURE sp_LogAction
    @UserName NVARCHAR(100),
    @Action NVARCHAR(200),
    @Details NVARCHAR(MAX) = NULL
AS
BEGIN
    INSERT INTO ActionLogs (UserName, Action, Details)
    VALUES (@UserName, @Action, @Details)
END
GO

/* ===========================================================================
   04_CheckStock
   Returns current stock for an ingredient or a menu item
   =========================================================================== */
CREATE PROCEDURE sp_CheckIngredientStock
    @IngredientID INT
AS
BEGIN
    SELECT IngredientID, IngredientName, CurrentStock
    FROM Ingredients
    WHERE IngredientID = @IngredientID
END
GO

CREATE PROCEDURE sp_CheckMenuItemStock
    @ItemID INT
AS
BEGIN
    SELECT i.IngredientID, i.IngredientName, i.CurrentStock, ii.QuantityPerItem,
           FLOOR(i.CurrentStock / ii.QuantityPerItem) AS AvailablePortions
    FROM ItemIngredients ii
    INNER JOIN Ingredients i ON ii.IngredientID = i.IngredientID
    WHERE ii.ItemID = @ItemID
END
GO

/* ===========================================================================
   05_AutoUpdateOrderTotals
   Updates total amounts for all orders automatically
   =========================================================================== */
CREATE PROCEDURE sp_UpdateAllOrderTotals
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            UPDATE o
            SET TotalAmount = dbo.fn_CalculateOrderTotal(o.OrderID)
            FROM Orders o
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    END CATCH
END
GO

/* ===========================================================================
   06_GenerateInvoiceNumber
   Utility function to generate a unique invoice number
   =========================================================================== */
CREATE FUNCTION fn_GenerateInvoiceNumber()
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @Invoice NVARCHAR(20)
    SET @Invoice = 'INV-' + REPLACE(CONVERT(VARCHAR(20), GETDATE(), 112), '-', '') 
                   + '-' + RIGHT('0000' + CAST((SELECT ISNULL(MAX(PurchaseID),0)+1 FROM Purchases) AS VARCHAR(4)),4)
    RETURN @Invoice
END
GO

/* ===========================================================================
   07_CalculateLoyaltyPoints
   Calculates loyalty points based on order total
   =========================================================================== */
CREATE FUNCTION fn_CalculateLoyaltyPoints(@OrderID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Total DECIMAL(10,2)
    SELECT @Total = TotalAmount FROM Orders WHERE OrderID = @OrderID

    -- Example: 1 point for each 10 currency units spent
    RETURN FLOOR(ISNULL(@Total,0)/10)
END
GO
