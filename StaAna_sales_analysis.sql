SELECT * FROM inventory_categories;
SELECT * FROM inventory_subcategories;
SELECT * FROM management;
SELECT * FROM online_sales;
SELECT * FROM products;
SELECT * FROM shipper_list;
SELECT * FROM store_locations;
SELECT * FROM store_sales;

-- The region I am analyzing is Colorado

-- What is total revenue overall for sales in the assigned territory, plus the start date and end date
-- that tell you what period the data covers

-- THE OVERALL TOTAL REVENUE WAS 8971157.20 and the START DATE was 2022-01-01 and END DATE
-- was 2025-12-31

WITH colorado_sales AS (
    SELECT 
        s.Sale_Amount AS revenue,
        s.Transaction_Date AS sale_date
    FROM store_sales s
    JOIN store_locations l ON s.Store_ID = l.StoreId
    WHERE l.State IN ('Colorado')
-- Used AI for support here
    UNION ALL
    -- Used AI for support here 

    SELECT 
        o.SalesTotal AS revenue,
        o.Date AS sale_date
    FROM online_sales o
    WHERE o.ShiptoState IN ('Colorado')
)
SELECT 
    ROUND(SUM(revenue), 2) AS total_revenue,
    MIN(sale_date) AS start_date,
    MAX(sale_date) AS end_date
FROM colorado_sales;
-- Used AI for support here

-- What is the revenue breakdown by year and month for the sales territory?
WITH colorado_sales AS (
    SELECT 
        s.Sale_Amount AS revenue,
        s.Transaction_Date AS sale_date
    FROM store_sales s
    JOIN store_locations l ON s.Store_ID = l.StoreId
    WHERE l.State IN ('Colorado')

    UNION ALL

    SELECT 
        o.SalesTotal AS revenue,
        o.Date AS sale_date
    FROM online_sales o
    WHERE o.ShiptoState IN ('Colorado')
)
SELECT 
    YEAR(sale_date) AS sales_year,
    MONTH(sale_date) AS sales_month,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM colorado_sales
GROUP BY YEAR(sale_date), MONTH(sale_date)
ORDER BY sales_year DESC, sales_month DESC;
-- Used AI for support here

-- Provide a comparison of total revenue for the specific sales territory and the region it belongs to.
