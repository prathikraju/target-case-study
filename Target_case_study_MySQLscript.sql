CREATE DATABASE IF NOT EXISTS target;
USE target;

CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat DECIMAL(10,7),
    geolocation_lng DECIMAL(10,7),
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
);

CREATE TABLE customers (
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_unique_id VARCHAR(32),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

CREATE TABLE sellers (
    seller_id VARCHAR(32) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);

CREATE TABLE products (
    product_id VARCHAR(32) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE orders (
    order_id VARCHAR(32) PRIMARY KEY,
    customer_id VARCHAR(32),
    order_status VARCHAR(20),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_id VARCHAR(32),
    order_item_id INT,
    product_id VARCHAR(32),
    seller_id VARCHAR(32),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE payments (
    order_id VARCHAR(32),
    payment_sequential INT,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);


CREATE TABLE order_reviews (
    review_id VARCHAR(32),
    order_id VARCHAR(32),
    review_score INT,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '/Users/prathikraju/Documents/Scaler case study/Target_case_study/Target Case study data/geolocation.csv'
INTO TABLE geolocation 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/prathikraju/Documents/Scaler case study/Target_case_study/Target Case study data/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/prathikraju/Documents/Scaler case study/Target_case_study/Target Case study data/sellers.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/prathikraju/Documents/Scaler case study/Target_case_study/Target Case study data/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/prathikraju/Documents/Scaler case study/Target_case_study/Target Case study data/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/prathikraju/Documents/Scaler case study/Target_case_study/Target Case study data/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/prathikraju/Documents/Scaler case study/Target_case_study/Target Case study data/payments.csv'
INTO TABLE payments
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

TRUNCATE TABLE order_reviews;

LOAD DATA LOCAL INFILE '/Users/prathikraju/Documents/Scaler case study/Target_case_study/Target Case study data/order_reviews.csv'
INTO TABLE order_reviews
CHARACTER SET latin1
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM order_reviews;

SHOW WARNINGS LIMIT 20;

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation;



USE target;

-- ============================================================
-- Q1: Import the dataset and do usual exploratory analysis
-- ============================================================

-- Q1.1: Data type of all columns in the "customers" table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'target'
  AND table_name = 'customers';


-- Q1.2: Get the time range between which the orders were placed
SELECT
    MIN(order_purchase_timestamp) AS first_date,
    MAX(order_purchase_timestamp) AS last_date
FROM orders;


-- Q1.3: Count the Cities & States of customers who ordered during the given period
SELECT
    COUNT(DISTINCT Cust.customer_city) AS count_city,
    COUNT(DISTINCT Cust.customer_state) AS count_state
FROM customers AS Cust
LEFT JOIN orders AS Ord
    USING (customer_id)
WHERE Ord.order_id IS NOT NULL;


-- ============================================================
-- Q2: In-depth Exploration
-- ============================================================

-- Q2.1: Is there a growing trend in the no. of orders placed over the past years?
-- (Yes - total orders placed increased from 2016 to 2018)
SELECT
    EXTRACT(YEAR FROM order_purchase_timestamp) AS order_year,
    COUNT(order_id) AS Total_orders
FROM orders
GROUP BY order_year
ORDER BY order_year;


-- Q2.2: Can we see some kind of monthly seasonality in terms of the no. of orders being placed?
SELECT
    EXTRACT(MONTH FROM order_purchase_timestamp) AS order_month,
    EXTRACT(YEAR FROM order_purchase_timestamp) AS order_year,
    COUNT(order_id) AS Total_orders
FROM orders
GROUP BY order_year, order_month
ORDER BY order_year, order_month;


-- Q2.3: During what time of the day do Brazilian customers mostly place orders?
-- 0-6 hrs: Dawn | 7-12 hrs: Morning | 13-18 hrs: Afternoon | 19-23 hrs: Night
SELECT
    CASE
        WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 0 AND 6 THEN 'Dawn'
        WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 7 AND 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 13 AND 18 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 19 AND 23 THEN 'Night'
        ELSE 'N/A'
    END AS time_slot,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY time_slot
ORDER BY time_slot;


-- ============================================================
-- Q3: Evolution of E-commerce orders in the Brazil region
-- ============================================================

-- Q3.1: Get the month on month no. of orders placed in each state
SELECT
    Cust.customer_state,
    EXTRACT(MONTH FROM order_purchase_timestamp) AS order_month,
    COUNT(Ord.order_id) AS Total_orders
FROM customers AS Cust
LEFT JOIN orders AS Ord
    USING (customer_id)
WHERE Ord.order_id IS NOT NULL
GROUP BY Cust.customer_state, order_month
ORDER BY Cust.customer_state, order_month;


-- Q3.2: How are the customers distributed across all the states?
-- (State "SP" has the highest number of customers; SP, RJ, MG make up the majority)
SELECT
    Cust.customer_state,
    COUNT(Cust.customer_id) AS Total_customers
FROM customers AS Cust
LEFT JOIN orders AS Ord
    USING (customer_id)
GROUP BY Cust.customer_state
ORDER BY Total_customers DESC, Cust.customer_state;


-- ============================================================
-- Q4: Impact on Economy - money movement via order prices, freight, etc.
-- ============================================================

-- Q4.1: Get the % increase in the cost of orders from 2017 to 2018 (Jan-Aug only)
-- Uses "payment_value" column from the payments table
WITH cte_2017 AS (
    SELECT SUM(p.payment_value) AS total_cost_2017
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2017
      AND EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 8
),
cte_2018 AS (
    SELECT SUM(p.payment_value) AS total_cost_2018
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
      AND EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 8
)
SELECT
    ((total_cost_2018 - total_cost_2017) / total_cost_2017) * 100 AS Perc_Change
FROM cte_2018
JOIN cte_2017 ON 1 = 1;


-- Q4.2: Calculate the Total & Average value of order price for each state
SELECT
    C.customer_state,
    SUM(p.payment_value) AS Total_order_price,
    AVG(p.payment_value) AS Avg_order_price
FROM customers AS C
LEFT JOIN orders AS o
    USING (customer_id)
JOIN payments p ON o.order_id = p.order_id
GROUP BY C.customer_state
ORDER BY C.customer_state;


-- Q4.3: Calculate the Total & Average value of order freight for each state
SELECT
    C.customer_state,
    SUM(p.freight_value) AS Total_freight_price,
    AVG(p.freight_value) AS Avg_freight_price
FROM customers AS C
LEFT JOIN orders AS o
    USING (customer_id)
JOIN order_items p ON o.order_id = p.order_id
GROUP BY C.customer_state
ORDER BY C.customer_state;


-- ============================================================
-- Q5: Analysis based on sales, freight and delivery time
-- ============================================================

-- Q5.1: Find the no. of days taken to deliver each order (delivery time),
-- and the difference (in days) between estimated & actual delivery date
-- MySQL note: DATEDIFF(a, b) = a - b, in days (no unit parameter needed)
SELECT
    order_id,
    DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS delivery_time,
    DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) AS diff_estimated_delivery
FROM orders;


-- Q5.2a: Top 5 states with the HIGHEST average freight value
WITH avg_freight_per_state AS (
    SELECT
        C.customer_state,
        AVG(p.freight_value) AS Avg_freight_price
    FROM customers AS C
    LEFT JOIN orders AS o
        USING (customer_id)
    JOIN order_items p ON o.order_id = p.order_id
    GROUP BY C.customer_state
)
SELECT customer_state, Avg_freight_price
FROM avg_freight_per_state
ORDER BY Avg_freight_price DESC
LIMIT 5;


-- Q5.2b: Top 5 states with the LOWEST average freight value
WITH avg_freight_per_state AS (
    SELECT
        C.customer_state,
        AVG(p.freight_value) AS Avg_freight_price
    FROM customers AS C
    LEFT JOIN orders AS o
        USING (customer_id)
    JOIN order_items p ON o.order_id = p.order_id
    GROUP BY C.customer_state
)
SELECT customer_state, Avg_freight_price
FROM avg_freight_per_state
ORDER BY Avg_freight_price ASC
LIMIT 5;


-- Q5.3a: Top 5 states with the HIGHEST average delivery time
SELECT
    C.customer_state,
    AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)) AS avg_delivery_time
FROM customers AS C
LEFT JOIN orders AS o
    USING (customer_id)
GROUP BY C.customer_state
ORDER BY avg_delivery_time DESC
LIMIT 5;


-- Q5.3b: Top 5 states with the LOWEST average delivery time
SELECT
    C.customer_state,
    AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)) AS avg_delivery_time
FROM customers AS C
LEFT JOIN orders AS o
    USING (customer_id)
GROUP BY C.customer_state
ORDER BY avg_delivery_time ASC
LIMIT 5;


-- Q5.4: Top 5 states where order delivery is really fast compared to the
-- estimated date of delivery (difference between actual & estimated delivery averages)
SELECT
    C.customer_state,
    AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)) AS avg_delivery_speed
FROM customers AS C
LEFT JOIN orders AS o
    USING (customer_id)
GROUP BY C.customer_state
HAVING avg_delivery_speed < 0
ORDER BY avg_delivery_speed ASC
LIMIT 5;


-- ============================================================
-- Q6: Analysis based on the payments
-- ============================================================

-- Q6.1: Find the month on month no. of orders placed using different payment types
SELECT
    p.payment_type,
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
    COUNT(*) AS num_orders
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY 
	EXTRACT(YEAR FROM o.order_purchase_timestamp),
    EXTRACT(MONTH FROM o.order_purchase_timestamp), 
    p.payment_type
ORDER BY year, month, p.payment_type;


-- Q6.2: Find the no. of orders placed on the basis of payment installments = 1
SELECT
    COUNT(order_id) AS total_orders
FROM payments
WHERE payment_installments = 1
  AND payment_value > 0;

