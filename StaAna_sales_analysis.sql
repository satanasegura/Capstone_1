SELECT * FROM inventory_categories;
SELECT * FROM inventory_subcategories;
SELECT * FROM management;
SELECT * FROM online_sales;
SELECT * FROM products;
SELECT * FROM shipper_list;
SELECT * FROM store_locations;
SELECT * FROM store_sales;

-- The region I am analyzing is Colorado

/* What is total revenue overall for sales in the assigned territory, plus the start date and end date
-- that tell you what period the data covers */

-- THE OVERALL TOTAL REVENUE WAS 8971157.20 and the START DATE was 2022-01-01 and END DATE
-- was 2025-12-31

WITH colorado_sales AS (
    SELECT 
        s.Sale_Amount AS revenue, -- used s, as table store_sales, took sale_amount 
        -- from the table, used revenue as alias
        s.Transaction_Date AS sale_date -- s from store_sales, took transaction_date
        -- from table s and used sale date as alias 
    FROM store_sales s -- from store_sales table, i took the sales_amount and transaction_date
    
    JOIN store_locations l ON s.Store_ID = l.StoreId -- to join sales from 
    -- Colorado store IDs only, I used store_location table, added 1 as alias
    -- to then join store sales from the store_ID to l.StoreId location
    WHERE l.State IN ('Colorado') -- with the l as store ID and location,
    -- i wrote location as an IN colorado from the State in store_locations

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

/* What is the revenue breakdown by year and month for the sales territory? */
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
        o.SalesTotal AS revenue, -- selected o as online_sales for SalesTotal and alias as revenue
        o.Date AS sale_date -- selected o as online_sales for Date and alias is sale_date
    FROM online_sales o -- chose all the revenue and sale dates from online_sales
    WHERE o.ShiptoState IN ('Colorado')
    -- Used Ai for support
    -- again, i used online sales total as revenue and the date as sale date
    -- online sales as o and then online sales o, used shiptostate and only
    -- wanted colorado revenue 
)
SELECT 
    YEAR(sale_date) AS sales_year, -- selected the year from alias sale date and
    -- use alias sales_year from both store and online
    MONTH(sale_date) AS sales_month, -- selected month from alias sale date and
    -- used sale_month as alias from both store and online
    ROUND(SUM(revenue), 2) AS total_revenue -- rounded the revenue from each 
    -- year and month to alias total_revenue and used 2 decimals
FROM colorado_sales -- colorado_sales is where we are getting the dates and revenue
-- from
GROUP BY YEAR(sale_date), MONTH(sale_date) -- used the dates from year and month sale_date in 80 and 82
ORDER BY sales_year DESC, sales_month DESC;
-- used alias sales_year and sales_month and descended from year and month
-- with the revenue summmed up for 2 decimals
-- Used AI for support here

/* Provide a comparison of total revenue for the specific sales territory and the region it belongs to. */
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
        o.SalesTotal AS revenue, -- selected o as online_sales for SalesTotal and alias as revenue
        o.Date AS sale_date -- selected o as online_sales for Date and alias is sale_date
    FROM online_sales o -- chose all the revenue and sale dates from online_sales
    WHERE o.ShiptoState IN ('Colorado')
    
    ),
regional_sales AS (
    SELECT 
        s.Sale_Amount AS revenue -- sale amount from store sales as revenue alias
    FROM store_sales s -- selecting from store sales
    JOIN store_locations l ON s.Store_ID = l.StoreId -- only location from colorado
    JOIN management m ON l.State = m.State -- joined management as 'm' alias to 1 state, colorado and colorado management info
    WHERE m.Region = 'West' -- under management, m, i chose the region from the table, only west region

    UNION ALL


    SELECT 
        o.SalesTotal AS revenue -- online_sales, salestotal as alias of revenue
    FROM online_sales o -- data gathered frmo online_sales table 
    JOIN (SELECT DISTINCT State, Region FROM management) m ON o.ShiptoState = m.State -- only selected one record of state, region from 
    -- management table and 'm' to only shipping to colorado 
    WHERE m.Region = 'West' -- only filtering to west region, including colorado
)
SELECT 
    'West' AS region_name, -- alias for the table
    ROUND(SUM(c.revenue), 2) AS colorado_territory_revenue, -- sum og the revenue for colorado region with decimal as 2 places
    (SELECT ROUND(SUM(revenue), 2) FROM regional_sales) AS total_west_region_revenue,
    -- total_west_region_revenue is alias for sum of revenue from regional sales , with 2 decimal places
    ROUND((SUM(c.revenue) / (SELECT SUM(revenue) FROM regional_sales)) * 100, 2) AS colorado_contribution_pct,
    -- percentage of colorado_contribution_pct as alias. from coloradao revnue and then divide by regional sales revenue
    MIN(c.sale_date) AS territory_start_date, -- earliest date sale alias as territory_start_date
    MAX(c.sale_date) AS territory_end_date -- latest date sale alias as territory_end_date
FROM colorado_sales c; -- got all data from this table
-- supported by AI

/* What is the number of transactions per month and average transaction amount by product
category for the sales territory? */
   WITH co_sales_by_product AS (
    SELECT 
        s.Sale_Amount AS revenue, -- selected sale_amount from from store_sales and alias as revenue
        s.Transaction_Date AS sale_date, -- select transaction_date from store_sales, sale_date as alias
        p.Categoryid AS category_id -- selected categoryid from products, alias as category_id
    FROM store_sales s -- gathered data from store sales
    JOIN store_locations l ON s.Store_ID = l.StoreId -- joined store_locations to store_sales using Store_ID to identify where
    -- each sale occured 
    JOIN products p ON s.Prod_Num = p.ProdNum -- joined products to store_sales using product numbers to retrieve category information
    WHERE l.State IN ('Colorado') -- state as only colorado

    UNION ALL -- combined sales from store and online sales


    SELECT 
        o.SalesTotal AS revenue, -- salestotal from online_sales and then alias as revenue
        o.Date AS sale_date, -- date from online_orders, alias as sale_date
        p.Categoryid AS category_id -- selected categoryid from products, alias as category_id
    FROM online_sales o -- sales from this table 
    JOIN products p ON o.ProdNum = p.ProdNum -- joined products from online_sales using product number to retrieve info from p
    WHERE o.ShiptoState IN ('Colorado') -- only shipments to colorado
)
SELECT 
    YEAR(c.sale_date) AS sales_year, -- year from colorado sale date and alias as sales_year
    MONTH(c.sale_date) AS sales_month, -- month from colorado sale date and alias as sales_month
    cat.Category AS product_category, -- from inventory_categories, category has alias as product_category
    COUNT(*) AS total_transactions, -- count all the total transactions  from year and month use total_transactions for alias
    ROUND(AVG(c.revenue), 2) AS avg_transaction_amount -- round the average of product_category, alias is avg_transaction_amount
FROM co_sales_by_product c -- all data collected from co_sales_by_proudct table
JOIN inventory_categories cat ON c.category_id = cat.Categoryid -- joined inventory_categories with co_sales_by_product
-- using category_id for product category info
GROUP BY YEAR(c.sale_date), MONTH(c.sale_date), cat.Category -- grouped results by sales year, sales month, and product category
ORDER BY sales_year DESC, sales_month DESC, total_transactions DESC; -- sorted results by year, month, and total transactions in descending order
-- AI Supported

/* Can you provide a ranking of in-store sales performance by each store in the sales territory, or a
ranking of online sales performance by state within an online sales territory? */
SELECT 
    l.StoreLocation AS store_name,-- using the colorado location, i used store_name as alias
    l.StoreId AS store_id, -- used the location storeid as alias store_id
    COUNT(*) AS total_transactions, -- as an alias, i used total_transactions and counted all form othe store name
    ROUND(SUM(s.Sale_Amount), 2) AS total_revenue, -- total_reveune as alias, i rounded the sum of the sale amount by 2 decimals
    ROUND(AVG(s.Sale_Amount), 2) AS average_transaction_value -- for alias, average_transaction_value, i used avg for sale amount
    -- and rounded by 2 decimals
FROM store_sales s -- this is the table i am getting my data from
JOIN store_locations l ON s.Store_ID = l.StoreId -- joined store_locations to store_sales using Store_ID to identify where
    -- each sale occured 
WHERE l.State IN ('Colorado') -- with location and state, only grab info from colorado 
GROUP BY l.StoreLocation, l.StoreId -- grouped by StoreLocation and StoreId to show results for each individual store
ORDER BY total_revenue DESC; -- order by total_reveune and descennd from highest to lowest
-- AI support
 
 /* What is your recommendation for where to focus sales attention in the next quarter? */
 -- My recommendation for where to focus the sales efforts in the next quarter is on books (general). From the number of total 
 -- transactions per month and year, it was historically low compareed to other product categories. I would try to market books to 
 -- the customers. Based on my code below and the data it retrieved, I would focus on marketing to Castle Rock, Grand Junction,
 -- and Littelton because there was only 1 book sold at each location for the 12th month. Grand Junction also performed the worst
 -- for quarter 4, selling only 15 books and 321.15 in revenue. 

SELECT
    YEAR(s.Transaction_Date) AS sales_year,
    MONTH(s.Transaction_Date) AS sales_month,
    l.StoreLocation AS store_name,
    l.StoreId AS store_id,
    COUNT(*) AS total_books_sold,
    ROUND(SUM(s.Sale_Amount), 2) AS total_book_revenue
FROM store_sales s
JOIN store_locations l ON s.Store_ID = l.StoreId
JOIN products p ON s.Prod_Num = p.ProdNum
JOIN inventory_categories cat ON p.Categoryid = cat.Categoryid
WHERE l.State IN ('Colorado')
    AND cat.Category = 'Books (General)'
GROUP BY 
    YEAR(s.Transaction_Date), 
    MONTH(s.Transaction_Date), 
    l.StoreLocation, 
    l.StoreId
ORDER BY 
    sales_year DESC, 
    sales_month DESC, 
    total_book_revenue DESC;

SELECT
    YEAR(s.Transaction_Date) AS sales_year,
    QUARTER(s.Transaction_Date) AS sales_quarter,
    l.StoreLocation AS store_name,
    l.StoreId AS store_id,
    COUNT(*) AS total_books_sold,
    ROUND(SUM(s.Sale_Amount), 2) AS total_book_revenue
FROM store_sales s
JOIN store_locations l ON s.Store_ID = l.StoreId
JOIN products p ON s.Prod_Num = p.ProdNum
JOIN inventory_categories cat ON p.Categoryid = cat.Categoryid
WHERE l.State IN ('CO', 'Colorado')
    AND cat.Category = 'Books (General)'
GROUP BY 
    YEAR(s.Transaction_Date), 
    QUARTER(s.Transaction_Date), 
    l.StoreLocation, 
    l.StoreId
ORDER BY 
    sales_year DESC, 
    sales_quarter DESC, 
    total_book_revenue DESC;
