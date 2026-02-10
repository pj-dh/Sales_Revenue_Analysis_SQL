CREATE DATABASE sales_analysis;
USE sales_analysis;

CREATE TABLE sales (
InvoiceNo VARCHAR(20),
StockCode VARCHAR(20),
Description TEXT,
Quantity INT,
InvoiceDate DATETIME,
UnitPrice DECIMAL(10,2),
CustomerID INT,
Country VARCHAR(50));

SELECT * FROM sales
LIMIT 10;

-- Data Cleaning
CREATE TABLE sales_clean AS
SELECT *
FROM sales
WHERE
Quantity > 0
AND UnitPrice > 0
AND InvoiceDate IS NOT NULL;

SELECT COUNT(*) FROM sales_clean;

-- Monthly Revenue
SELECT
YEAR(InvoiceDate) as Year,
MONTH(InvoiceDate) as Month,
SUM(Quantity * UnitPrice) AS Monthly_Revenue
FROM sales
WHERE Quantity > 0 AND UnitPrice > 0
GROUP BY Year, month
ORDER BY Year, Month;

-- Quarterly Revenue
SELECT 
YEAR(InvoiceDate) AS YEAR,
QUARTER(InvoiceDate) AS QUARTER,
SUM(Quantity * UnitPrice) AS Quarterly_Revenue
FROM sales_clean
GROUP BY Year, Quarter
ORDER BY Year, Quarter;

-- Top Selling Products
SELECT
StockCode,
Description,
SUM(Quantity) AS Units_sold,
SUM(Quantity * UnitPrice) AS Revenue
FROM sales_clean
GROUP BY StockCode, Description
ORDER BY Revenue DESC
LIMIT 10;

-- Category Mapping
CREATE TABLE product_category_map (
StockCode VARCHAR(20),
Category VARCHAR(50));

SELECT COUNT(*) FROM product_category_map;
SELECT * FROM product_category_map;

SELECT
  s.StockCode,
  c.Category
FROM sales_clean s
LEFT JOIN product_category_map c
  ON TRIM(s.StockCode) = TRIM(c.StockCode)
LIMIT 10;

-- Joined Revenue table
SELECT
  s.StockCode,
  s.Description,
  IFNULL(c.Category, 'Others') AS Category,
  SUM(s.Quantity * s.UnitPrice) AS Revenue
FROM sales_clean s
LEFT JOIN product_category_map c
  ON TRIM(s.StockCode) = TRIM(c.StockCode)
GROUP BY
  s.StockCode,
  s.Description,
  c.Category
ORDER BY Revenue DESC;

-- Country-wise sale
SELECT
  Country,
  SUM(Quantity * UnitPrice) AS Revenue
FROM sales_clean
GROUP BY Country
ORDER BY Revenue DESC;

-- Year over year growth
SELECT
  Year,
  Revenue,
  Revenue - LAG(Revenue) OVER (ORDER BY Year) AS YoY_Growth
FROM (
  SELECT
    YEAR(InvoiceDate) AS Year,
    SUM(Quantity * UnitPrice) AS Revenue
  FROM sales_clean
  GROUP BY Year
) t;
