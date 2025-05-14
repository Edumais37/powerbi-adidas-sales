# Adidas Sales Analytics Project (2020-2021 Data)
-- Import CSV
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 9.2\\Uploads\\Adidas US Sales Datasets.csv'
INTO TABLE adidas_sales
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW VARIABLES LIKE "secure_file_priv";

# Clean data
-- Rename Table and check values
RENAME TABLE `adidas us sales datasets` TO adidas_sales;
DESCRIBE adidas_sales;
SELECT * FROM adidas_sales;

-- Copy table
CREATE TABLE your_table_backup AS
SELECT * FROM adidas_sales;
RENAME TABLE your_table_backup TO backup_adidas_sales;

-- Remove unecessary characters
SET SQL_SAFE_UPDATES = 0;

UPDATE adidas_sales
SET 
    `Price per Unit` = REPLACE(REPLACE(`Price per Unit`, '$', ''), ',', ''),
	`Total Sales` = REPLACE(REPLACE(`Total Sales`, '$', ''), ',', ''),
	`Operating Profit` = REPLACE(REPLACE(`Operating Profit`, '$', ''), ',', ''),
    `Operating Margin` = REPLACE(`Operating Margin`, '%', ''),
    `Invoice Date` = REPLACE(`Invoice Date`, '/', '-');

-- Format Date
UPDATE adidas_sales
SET `Invoice Date` = STR_TO_DATE(`Invoice Date`, '%m-%d-%Y');

SET SQL_SAFE_UPDATES = 1;

-- Rename columns and change data types
ALTER TABLE adidas_sales
	CHANGE `Retailer ID` Retailer_ID INT,
	CHANGE `Invoice Date` Invoice_Date DATE,
	CHANGE `Price per Unit` Price_per_Unit Decimal(10,2),
	CHANGE `Units Sold` Units_Sold INT,
	CHANGE `Total Sales` Total_sales Decimal(10,2),
	CHANGE `Operating Profit` Operating_Profit Decimal(10,2),
	CHANGE `Operating Margin` Operating_Margin Decimal(5,2),
    CHANGE `Sales Method` Sales_Method TEXT;
    
    
-- Correct errors in total_sales values (adjust by factor of 10)
SELECT count(*) FROM fact_sales where (Price_per_Unit * units_sold <> total_sales);

UPDATE fact_sales
SET total_sales = ROUND(Price_per_Unit * units_sold, 2)
WHERE ROUND(total_sales / NULLIF(Price_per_Unit * units_sold, 0), 1) = 10.0;

SELECT COUNT(*) AS remaining_errors
FROM fact_sales
WHERE ROUND(Price_per_Unit * units_sold, 2) <> ROUND(total_sales, 2);


-- Adjust operating_margin to decimals
UPDATE fact_sales
SET operating_margin = operating_margin / 100.0;

-- Correct errors in operating_profit values (adjust by factor of 10)
UPDATE fact_sales
SET operating_profit = ROUND(operating_margin * total_sales, 2)
WHERE ROUND(operating_profit / NULLIF(operating_margin * total_sales, 0), 1) = 10.0;


-- Create city_state column
ALTER TABLE adidas_sales
ADD City_State VARCHAR(100);

UPDATE adidas_sales
SET City_State = CONCAT(City, ', ', State);


#Create dimension tables, and core fact table
-- Dim_Product Table
CREATE TABLE Dim_Product AS
SELECT DISTINCT
	Product,
    CASE
		WHEN Product LIKE '%Footwear%' THEN 'Footwear'
        WHEN Product LIKE '%Apparel%'  THEN 'Apparel'
        ELSE 'Other'
	END AS Catergory,
    CASE
		WHEN Product LIKE 'Men%' THEN 'Male'
        WHEN Product LIKE 'Women%' THEN 'Female'
        ELSE 'Unisex'
	END AS Gender
FROM adidas_sales;

-- Add Product_ID column
ALTER TABLE Dim_Product 
ADD Product_ID INT PRIMARY KEY AUTO_INCREMENT;

-- Link Product_ID to Sales Table
ALTER TABLE adidas_sales 
ADD Product_ID INT;

UPDATE adidas_sales AS a
JOIN Dim_Product AS d
ON a.Product = d.Product
SET a.Product_ID = d.Product_ID;


-- Create Fact_Sales Core Table;
CREATE TABLE Fact_Sales AS
SELECT
    Retailer_ID,
    Retailer AS Retailer_Name,
    Invoice_Date AS Date_ID,
    City_State,
    Product_ID,
    Units_Sold,
    Price_per_Unit,
    Total_sales,
    Operating_Profit,
    Operating_Margin
FROM
    adidas_sales;


-- Dim_Location Table
CREATE TABLE Dim_Location AS
SELECT
	ROW_NUMBER() OVER (ORDER BY City_State) AS Location_ID,
    City,
    State,
    City_State
FROM (
	SELECT DISTINCT City, State, City_State
    FROM adidas_sales
) AS unique_locations;

-- Add Location_ID to Fact_Sales
ALTER TABLE Fact_Sales 
ADD Location_ID INT;

Update Fact_Sales AS f
JOIN Dim_Location AS d
ON f.City_State = d.City_State
SET f.Location_ID = d.Location_ID;


-- Dim_Date Table
CREATE TABLE Dim_Date AS
SELECT DISTINCT
	Date_ID,
    YEAR(Date_ID) AS Year,
    MONTH(Date_ID) AS MONTH,
    DAY(Date_ID) AS DAY,
    QUARTER(Date_ID) AS QUARTER,
    DATE_FORMAT(Date_ID, '%M') AS Month_Name,
    DATE_FORMAT(Date_ID, '%W') AS Day_Name
FROM
	Fact_Sales;


-- Dim_Retailer Table
-- Identify mapping of Retailer_ID to Retailer
SELECT Retailer, Retailer_ID, COUNT(*) AS Count
FROM adidas_sales
GROUP BY Retailer, Retailer_ID
ORDER BY Count DESC;

-- Update Retailer_ID = Retailer
UPDATE adidas_sales SET Retailer_ID = 1185732 WHERE Retailer = 'Amazon';
UPDATE adidas_sales SET Retailer_ID = 1189833 WHERE Retailer = 'Kohl''s';
UPDATE adidas_sales SET Retailer_ID = 1128299 WHERE Retailer = 'West Gear';
UPDATE adidas_sales SET Retailer_ID = 1197831 WHERE Retailer = 'Sports Direct';
UPDATE adidas_sales SET Retailer_ID = 1187456 WHERE Retailer = 'Walmart';
UPDATE adidas_sales SET Retailer_ID = 1158388 WHERE Retailer = 'Foot Locker';

Create Table Dim_Retailer AS
SELECT DISTINCT
	Retailer_ID,
	Retailer as Retailer_Name
FROM 
	adidas_sales;
    
    
-- Dim_Operating Margin
WITH MarginRanks AS (
  SELECT 
    Operating_Margin,
    NTILE(4) OVER (ORDER BY Operating_Margin) AS Quartile
  FROM 
    fact_sales
)
SELECT 
  Quartile,
  MIN(Operating_Margin) AS Min_Margin,
  MAX(Operating_Margin) AS Max_Margin
FROM 
  MarginRanks
GROUP BY 
  Quartile
ORDER BY 
  Quartile;

  
CREATE TABLE Dim_OperatingMargin AS
SELECT
	ROW_NUMBER() OVER (ORDER BY Operating_Margin) AS Margin_ID,
    Operating_Margin,
    ROUND(AVG(Operating_Profit), 2) AS Avg_Operating_Profit,
    CASE 
        WHEN Operating_Margin <= .35 THEN 'Low'
        WHEN Operating_Margin  > .35 AND Operating_Margin <= .49 THEN 'Medium'
        ELSE 'High'
    END AS Margin_Category
FROM 
	fact_sales
GROUP BY
	Operating_Margin
ORDER BY
	Operating_Margin;

-- Add Margin_ID to fact_sales
ALTER TABLE fact_sales ADD Margin_ID INT;

UPDATE fact_sales AS f
JOIN Dim_OperatingMargin AS d
ON f.Operating_Margin = d.Operating_Margin
SET f.Margin_ID = d.Margin_ID;


-- Dim_Region table
CREATE TABLE Dim_Region AS
SELECT 
    r.Region_ID,
    a.Region,
    a.City_State
FROM (
    SELECT 
        Region,
        ROW_NUMBER() OVER (ORDER BY Region) AS Region_ID
    FROM (
        SELECT DISTINCT Region
        FROM adidas_sales
    ) AS unique_regions
) AS r
JOIN adidas_sales AS a
ON r.Region = a.Region
GROUP BY r.Region_ID, a.Region, a.City_State;

-- Join Dim_Region to Dim_Location through Region_ID
ALTER TABLE dim_location 
ADD Region_ID INT;

Update dim_location AS l
JOIN dim_region AS r
ON l.City_State = r.City_State
SET l.Region_ID = r.Region_ID;



-- Create retailer_city_counts table
CREATE TABLE retailer_city_counts AS
SELECT 
    Retailer_ID,
    City,
    COUNT(*) AS City_Count
FROM 
    adidas_sales
GROUP BY 
    Retailer_ID, City
ORDER BY 
    Retailer_ID, City;




