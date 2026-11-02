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
        s.Sale_Amount AS revenue, -- used s, as store sales, took sales amount 
        -- from the table, used revenue as alias
        s.Transaction_Date AS sale_date -- s from store sales, took transaction 
        -- date from table and used sale date as alias
    FROM store_sales s -- from aliases revenue and sale date, i took the sales 
    -- from both
    JOIN store_locations l ON s.Store_ID = l.StoreId -- to join sales form 
    -- Colorado stores only, I used store_location table and added 1 
    -- to then join store ID from store sales
    WHERE l.State IN ('Colorado') -- with the l as store ID and location,
    -- i wrote location as an IN colorado from the State in store_location

-- Used AI for support here
    UNION ALL -- combained all sales from store and also online
    -- Used AI for support here 

    SELECT 
        o.SalesTotal AS revenue, -- took the sales total from online 
        -- Salestotal and used revenue as alias 
        o.Date AS sale_date -- used online orders from Date and used 
        -- sale_date as alias
    FROM online_sales o -- taking the date from sales total and date as from 
    -- this table
    WHERE o.ShiptoState IN ('Colorado') -- took shiptostate from online sales 
    -- table and used IN for only colorado 
)
SELECT 
    ROUND(SUM(revenue), 2) AS total_revenue, -- alias as total revenue for both 
    -- s saleamount and o sales total, i get the revenue from both aka sum and 
    -- round to 2 decimals 
    MIN(sale_date) AS start_date, -- using s.transaction and o.date as the alias
    -- sale_date, i used another alias start_date
    MAX(sale_date) AS end_date -- again as previously stated, i did the same 
    -- thing and used the alias end_date
FROM colorado_sales; -- gatherered all the data from colorado sales
-- Used AI for support here

-- What is the revenue breakdown by year and month for the sales territory?
WITH colorado_sales AS (
    SELECT 
        s.Sale_Amount AS revenue,
        s.Transaction_Date AS sale_date
    FROM store_sales s
    JOIN store_locations l ON s.Store_ID = l.StoreId
    WHERE l.State IN ('Colorado') -- as the previous question, i took sales 
    -- from colorado sales 

    UNION ALL

    SELECT 
        o.SalesTotal AS revenue,
        o.Date AS sale_date
    FROM online_sales o
    WHERE o.ShiptoState IN ('Colorado')
    -- Used Ai for support
    -- again, i used online sales total as revenue and the date as sale date
    -- online sales as o and then online sales o, used shiptostate and only
    -- wanted colorado revenue 
)
SELECT 
    YEAR(sale_date) AS sales_year, -- selected the year from alias sale date and
    -- use alias sales_year
    MONTH(sale_date) AS sales_month, -- selected month from alias sale date and
    -- used sale_month as alias
    ROUND(SUM(revenue), 2) AS total_revenue -- rounded the revenue from each 
    -- year and month to alias total_revenue and used 2 decimals
FROM colorado_sales -- colorado_sales is where we are getting the dates and rev 
-- from
GROUP BY YEAR(sale_date), MONTH(sale_date)
ORDER BY sales_year DESC, sales_month DESC;
-- used alias sales_year and sales_month and descended from year and month
-- with the revenue 
-- Used AI for support here

-- Provide a comparison of total revenue for the specific sales territory and the region it belongs to.
