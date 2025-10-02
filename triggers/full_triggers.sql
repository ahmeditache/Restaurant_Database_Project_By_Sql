-- ============================================================
-- TRIGGERS FOR RESTAURANT MANAGEMENT SYSTEM
-- ============================================================

-- 1) Advanced Order Calculations
IF OBJECT_ID('dbo.trg_AdvancedOrderCalculations','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_AdvancedOrderCalculations;
GO
CREATE TRIGGER trg_AdvancedOrderCalculations
ON Orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Compute FinalPrice for each OrderItem using the best applicable promotion
    UPDATE oi
    SET
        oi.FinalPrice =
            CASE
                WHEN p.MaxDiscountType = 'AMOUNT' THEN oi.Price - p.MaxDiscountValue
                WHEN p.MaxDiscountType = 'PERCENT' THEN oi.Price - (oi.Price * p.MaxDiscountValue / 100.0)
                ELSE oi.Price
            END,
        oi.PromotionID = p.MaxPromotionID
    FROM OrderItems oi
    INNER JOIN inserted i ON oi.OrderID = i.OrderID
    OUTER APPLY (
        SELECT TOP 1
            pr.PromotionID AS MaxPromotionID,
            pr.DiscountType AS MaxDiscountType,
            pr.DiscountValue AS MaxDiscountValue
        FROM PromotionItems pi
        INNER JOIN Promotions pr
            ON pi.PromotionID = pr.PromotionID
            AND GETDATE() BETWEEN pr.StartDate AND pr.EndDate
        WHERE pi.ItemID = oi.ItemID
        ORDER BY
            CASE WHEN pr.DiscountType='AMOUNT' THEN pr.DiscountValue
                 WHEN pr.DiscountType='PERCENT' THEN pr.DiscountValue
                 ELSE 0 END DESC
    ) p;

    -- Calculate TotalAmount per order
    UPDATE o
    SET o.TotalAmount = ISNULL(sub.Total,0)
    FROM Orders o
    INNER JOIN inserted i ON o.OrderID = i.OrderID
    CROSS APPLY (
        SELECT SUM(ISNULL(FinalPrice,Price) * Quantity) AS Total
        FROM OrderItems
        WHERE OrderID = i.OrderID
    ) sub;

    -- ServiceCharge and Tax
    UPDATE o
    SET
        o.ServiceCharge = ISNULL(t.NumberOfGuests,1) * 10,
        o.Tax = (ISNULL(o.TotalAmount,0) + ISNULL(t.NumberOfGuests,1) * 10) * 0.14
    FROM Orders o
    INNER JOIN inserted i ON o.OrderID = i.OrderID
    LEFT JOIN Tabels t ON o.TableId = t.TableID;

    -- Discount for frequent delivery customers
    UPDATE o
    SET o.DiscountPercent = 25
    FROM Orders o
    INNER JOIN inserted i ON o.OrderID = i.OrderID
    WHERE o.OrderType = 'Delivery'
      AND i.CustomerId IS NOT NULL
      AND (SELECT COUNT(*) FROM Orders WHERE CustomerId = i.CustomerId AND OrderType='Delivery') >= 10;

    -- Final Total after service, tax, and discount
    UPDATE o
    SET o.TotalAmount =
        (ISNULL(o.TotalAmount,0) + ISNULL(o.ServiceCharge,0) + ISNULL(o.Tax,0))
        * CASE WHEN o.DiscountPercent IS NOT NULL THEN (1 - o.DiscountPercent/100.0) ELSE 1 END
    FROM Orders o
    INNER JOIN inserted i ON o.OrderID = i.OrderID;

END;
GO

-- 2) Update Stock on OrderItems
IF OBJECT_ID('dbo.trg_OrderItems_Stock','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_OrderItems_Stock;
GO
CREATE TRIGGER trg_OrderItems_Stock
ON OrderItems
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Reduce stock for ingredients used in the ordered items
    UPDATE ing
    SET ing.CurrentStock = ing.CurrentStock - (ii.QuantityPerItem * oi.Quantity)
    FROM Ingredients ing
    INNER JOIN ItemIngredients ii ON ing.IngredientID = ii.IngredientID
    INNER JOIN inserted oi ON ii.ItemID = oi.ItemID;

    -- Log stock reduction
    INSERT INTO StockTransactions (IngredientID, Quantity, TransactionType)
    SELECT ii.IngredientID, ii.QuantityPerItem * oi.Quantity, 'OUT'
    FROM inserted oi
    INNER JOIN ItemIngredients ii ON oi.ItemID = ii.ItemID;

END;
GO

-- 3) Update Stock on Purchases
IF OBJECT_ID('dbo.trg_Purchases_Stock','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Purchases_Stock;
GO
CREATE TRIGGER trg_Purchases_Stock
ON Purchases
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Increase stock for purchased ingredients
    UPDATE ing
    SET ing.CurrentStock = ing.CurrentStock + p.Quantity
    FROM Ingredients ing
    INNER JOIN inserted p ON ing.IngredientID = p.IngredientID;

    -- Log stock addition
    INSERT INTO StockTransactions (IngredientID, Quantity, TransactionType)
    SELECT p.IngredientID, p.Quantity, 'IN'
    FROM inserted p;

END;
GO

-- 4) Update Table Status
IF OBJECT_ID('dbo.trg_Tables_Status','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Tables_Status;
GO
CREATE TRIGGER trg_Tables_Status
ON Orders
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Set table as occupied when order is open
    UPDATE t
    SET t.NumberOfGuests = ISNULL(o.ServiceCharge/10,1)
    FROM Tabels t
    INNER JOIN inserted o ON t.TableID = o.TableId
    WHERE o.Status = 'Open';

    -- Set table available when order is closed
    UPDATE t
    SET t.NumberOfGuests = 0
    FROM Tabels t
    INNER JOIN inserted o ON t.TableID = o.TableId
    WHERE o.Status = 'Closed';

END;
GO

-- 5) Loyalty Points for Customers
IF OBJECT_ID('dbo.trg_Customers_Loyalty','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Customers_Loyalty;
GO
CREATE TRIGGER trg_Customers_Loyalty
ON Orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Increment loyalty points (example) per 100 currency spent
    UPDATE c
    SET c.Note = ISNULL(c.Note,'') + ' | Loyalty+' + CAST(FLOOR(o.TotalAmount/100) AS NVARCHAR)
    FROM Customers c
    INNER JOIN inserted o ON c.CustomerID = o.CustomerId
    WHERE o.CustomerId IS NOT NULL;

END;
GO
