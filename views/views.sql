/* ===========================================================================
   Restaurant Management System - Views
   =========================================================================== */

/* ===========================================================================
   01_Employees View
   Shows employee details with job title and department
   =========================================================================== */
CREATE VIEW vw_Employees AS
SELECT 
    e.EmployeeID,
    e.FullName,
    j.JobTitle,
    d.DepartmentName,
    e.HireDate,
    e.BirthDate,
    e.Salary,
    e.PhoneNumber,
    e.Email,
    e.Address,
    e.EmergencyContact,
    e.Status
FROM Employees e
INNER JOIN JobTitles j ON e.JobID = j.JobID
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID;
GO

/* ===========================================================================
   02_Customers View
   Shows customer details with total orders and loyalty points
   =========================================================================== */
CREATE VIEW vw_Customers AS
SELECT 
    c.CustomerID,
    c.CustomerName,
    c.Phone1,
    c.Phone2,
    c.Address1,
    c.Address2,
    c.Email,
    c.DateOfBirth,
    c.LoyaltyPoints,
    c.PreferredPaymentMethod,
    COUNT(o.OrderID) AS TotalOrders,
    ISNULL(SUM(o.TotalAmount),0) AS TotalSpent
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerId
GROUP BY 
    c.CustomerID, c.CustomerName, c.Phone1, c.Phone2, c.Address1, c.Address2, 
    c.Email, c.DateOfBirth, c.LoyaltyPoints, c.PreferredPaymentMethod;
GO

/* ===========================================================================
   03_MenuItems View
   Shows menu items with category, availability, and promotions
   =========================================================================== */
CREATE VIEW vw_MenuItems AS
SELECT 
    m.ItemID,
    m.ItemName,
    c.CategoryName,
    m.[Size],
    m.Price,
    m.IsAvailable,
    m.Calories,
    m.PreparationTime,
    STRING_AGG(p.PromotionName, ', ') AS Promotions
FROM MenuItems m
INNER JOIN Categories c ON m.CategoryID = c.CategoryID
LEFT JOIN PromotionItems pi ON m.ItemID = pi.ItemID
LEFT JOIN Promotions p ON pi.PromotionID = p.PromotionID
GROUP BY 
    m.ItemID, m.ItemName, c.CategoryName, m.[Size], m.Price, m.IsAvailable, m.Calories, m.PreparationTime;
GO

/* ===========================================================================
   04_Orders View
   Shows orders with customer, table, captain, total amount, and status
   =========================================================================== */
CREATE VIEW vw_Orders AS
SELECT 
    o.OrderID,
    o.OrderDate,
    o.OrderType,
    c.CustomerName AS Customer,
    t.TableNumber AS TableNo,
    capt.FullName AS Captain,
    del.FullName AS DeliveryPerson,
    cash.FullName AS Cashier,
    o.TotalAmount,
    o.Status,
    o.PaymentMethod,
    o.DiscountPercent,
    o.ServiceCharge,
    o.Tax,
    o.OrderNotes
FROM Orders o
LEFT JOIN Customers c ON o.CustomerId = c.CustomerID
LEFT JOIN Tabels t ON o.TableId = t.TableID
LEFT JOIN Employees capt ON o.CaptinId = capt.EmployeeID
LEFT JOIN Employees del ON o.DeliveryId = del.EmployeeID
LEFT JOIN Employees cash ON o.CashierId = cash.EmployeeID;
GO

/* ===========================================================================
   05_OrderItems View
   Shows order items with item name, quantity, price, promotion, and final price
   =========================================================================== */
CREATE VIEW vw_OrderItems AS
SELECT 
    oi.OrderItemID,
    oi.OrderID,
    m.ItemName,
    oi.Quantity,
    oi.Price,
    p.PromotionName,
    oi.FinalPrice
FROM OrderItems oi
INNER JOIN MenuItems m ON oi.ItemID = m.ItemID
LEFT JOIN Promotions p ON oi.PromotionID = p.PromotionID;
GO

/* ===========================================================================
   06_Stock View
   Shows ingredients with current stock and total purchases
   =========================================================================== */
CREATE VIEW vw_Stock AS
SELECT 
    i.IngredientID,
    i.IngredientName,
    i.Unit,
    i.CurrentStock,
    ISNULL(SUM(p.Quantity),0) AS TotalPurchased,
    ISNULL(SUM(st.Quantity),0) AS TotalTransactions
FROM Ingredients i
LEFT JOIN Purchases p ON i.IngredientID = p.IngredientID
LEFT JOIN StockTransactions st ON i.IngredientID = st.IngredientID
GROUP BY i.IngredientID, i.IngredientName, i.Unit, i.CurrentStock;
GO

/* ===========================================================================
   07_Promotions View
   Shows promotions and linked menu items
   =========================================================================== */
CREATE VIEW vw_Promotions AS
SELECT 
    p.PromotionID,
    p.PromotionName,
    p.DiscountType,
    p.DiscountValue,
    p.StartDate,
    p.EndDate,
    STRING_AGG(m.ItemName, ', ') AS Items
FROM Promotions p
LEFT JOIN PromotionItems pi ON p.PromotionID = pi.PromotionID
LEFT JOIN MenuItems m ON pi.ItemID = m.ItemID
GROUP BY p.PromotionID, p.PromotionName, p.DiscountType, p.DiscountValue, p.StartDate, p.EndDate;
GO
