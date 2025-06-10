SELECT DISTINCT SALES_AMOUNT
FROM GOLD.fact_sales;

SELECT DISTINCT QUANTITY
FROM GOLD.fact_sales;

SELECT GETDATE();

SELECT DISTINCT
DATEDIFF(YEAR,BIRTHDATE,GETDATE()) AS DIFF
FROM GOLD.dim_customers;

--CHECKING WHAT TABLES ARE PRESENT IN DATABASE
SELECT*FROM INFORMATION_SCHEMA.TABLES;

--CHECKING WHAT COLUMNS ARE PRESENT IN DATABASE
SELECT*FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='fact_sales';

SELECT DISTINCT SHIPPING_DATE 
FROM GOLD.fact_sales;

SELECT DISTINCT COUNTRY FROM GOLD.dim_customers;

SELECT DISTINCT CATEGORY,SUBCATEGORY
FROM GOLD.dim_products
ORDER BY 1,2;

---FIND THE LAST AND FIRST ORDER DATE
SELECT MAX(ORDER_DATE) AS LAST_ORDER_DATE,MIN(ORDER_DATE) AS FIRST_ORDER_DATE,
DATEDIFF(YEAR,MIN(ORDER_DATE),MAX(ORDER_DATE)) AS YEAR_DIFF,
DATEDIFF(MONTH,MIN(ORDER_DATE),MAX(ORDER_DATE)) AS MONTH_DIFF
FROM GOLD.fact_sales;

--FIND THE YOUNGEST AND OLDER CUSTOMER
SELECT
MIN(BIRTHDATE) AS YOUNGEST_CUSTOMER,
MAX(BIRTHDATE) AS OLDEST_CUSTOMER,
DATEDIFF(YEAR,MIN(BIRTHDATE),MAX(BIRTHDATE)) AS DIFF_YEAR,
DATEDIFF(YEAR,MAX(BIRTHDATE),GETDATE()) AS YOUNGEST_AGE,
DATEDIFF(YEAR,MIN(BIRTHDATE),GETDATE()) AS OLDEST_AGE
FROM GOLD.dim_customers;

---MEASURE EXPLORATION

-- Find the Total Sales
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales

-- Find how many items are sold
SELECT SUM(quantity) AS total_quantity FROM gold.fact_sales

-- Find the average selling price
SELECT AVG(price) AS avg_price FROM gold.fact_sales

-- Find the Total number of Orders
SELECT COUNT(order_number) AS total_orders FROM gold.fact_sales
SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales

-- Find the total number of products
SELECT COUNT(product_name) AS total_products FROM gold.dim_products

-- Find the total number of customers
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers;

-- Find the total number of customers that has placed an order
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.fact_sales;

-- Generate a Report that shows all key metrics of the business
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Customers', COUNT(customer_key) FROM gold.dim_customers;

SELECT * FROM GOLD.dim_customers;
SELECT * FROM GOLD.dim_products;
SELECT * FROM GOLD.fact_sales;

---MAGNITUDE ANALYSIS
---TOTAL CUSTOMER BY COUNTRY
SELECT COUNTRY,COUNT(DISTINCT CUSTOMER_KEY) AS TOTAL_CUSTOMER
FROM GOLD.dim_customers
GROUP BY COUNTRY
ORDER BY TOTAL_CUSTOMER DESC;

---TOTAL CUSTOMER BY GENDER
SELECT GENDER,COUNT(DISTINCT CUSTOMER_KEY) AS TOTAL_CUSTOMER
FROM GOLD.dim_customers
GROUP BY GENDER
ORDER BY TOTAL_CUSTOMER DESC;

---TOTAL PRODUCTS BY CATEGORY
SELECT CATEGORY,COUNT(DISTINCT PRODUCT_NUMBER) AS TOTAL_PRODUCT
FROM GOLD.dim_products
GROUP BY CATEGORY
ORDER BY TOTAL_PRODUCT;

---AVERAGE COST IN EACH CATEGORY
SELECT CATEGORY,AVG(COST) AS AVG_COST
FROM GOLD.dim_products
GROUP BY CATEGORY
ORDER BY AVG_COST;

---TOTAL REVENUE GENERATED FOR EACH CATEGORY
SELECT P.CATEGORY,SUM(S.SALES_AMOUNT) AS TOTAL_REVENUE
FROM gold.fact_sales S
JOIN gold.dim_products P ON P.product_key=S.product_key
GROUP BY P.category
ORDER BY TOTAL_REVENUE DESC;

---TOTAL REVENUE BY CUSTOMER
SELECT C.first_name,C.last_name,SUM(S.SALES_AMOUNT) AS TOTAL_REVENUE
FROM gold.fact_sales S
JOIN gold.dim_customers C ON C.customer_key=S.customer_key
GROUP BY C.first_name,C.last_name
ORDER BY TOTAL_REVENUE DESC;

-- What is the distribution of sold items across countries?
SELECT
    c.country,
    SUM(f.quantity) AS total_sold_items
FROM gold.fact_sales f
JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;

---Ranking Analysis
-- Which 5 products Generating the Highest Revenue?
-- Complex but Flexibly Ranking Using Window Functions
SELECT *
FROM (
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.product_name
) AS ranked_products
WHERE rank_products <= 5;
 
 -- Simple Ranking
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;


-- What are the 5 worst-performing products in terms of sales?
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue;

-- Find the top 10 customers who have generated the highest revenue
SELECT TOP 10
 C.first_name,C.last_name,SUM(S.SALES_AMOUNT) AS TOTAL_REVENUE
FROM gold.fact_sales S
JOIN gold.dim_customers C ON C.customer_key=S.customer_key
GROUP BY C.first_name,C.last_name
ORDER BY TOTAL_REVENUE DESC;

-- the  3 customer with fewest order placed
select top 3 c.first_name,c.last_name,count(distinct order_number) as total_order
from gold.fact_sales f
join gold.dim_customers c on c.customer_key=f.customer_key
group by c.first_name,c.last_name
order by total_order asc;




