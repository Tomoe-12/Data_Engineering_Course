-- =====================================================
-- eCommerce View Assignment
-- =====================================================
CREATE DATABASE ecommerce_view_demo;  
USE ecommerce_view_demo;

-- =====================================================
-- Create Table
-- =====================================================

CREATE TABLE customers (
 customer_id INT PRIMARY KEY AUTO_INCREMENT,
 customer_name VARCHAR(100),
 email VARCHAR(100),
 city VARCHAR(100)
);

CREATE TABLE products (
 product_id INT PRIMARY KEY AUTO_INCREMENT,
 product_name VARCHAR(100),
 category VARCHAR(50),
 price DECIMAL(10,2)
);

CREATE TABLE orders (
 order_id INT PRIMARY KEY AUTO_INCREMENT,
 customer_id INT,
 order_date DATE,
 status VARCHAR(50),
 FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
 order_item_id INT PRIMARY KEY AUTO_INCREMENT,
 order_id INT,
 product_id INT,
 quantity INT,
 FOREIGN KEY (order_id) REFERENCES orders(order_id),
 FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- =====================================================
-- Sample Data 
-- =====================================================

INSERT INTO customers (customer_name, email, city) VALUES
('Aung Aung', 'aung@gmail.com', 'Yangon'),
('Su Su', 'susu@gmail.com', 'Mandalay'),
('Kyaw Kyaw', 'kyaw@gmail.com', 'Yangon');

INSERT INTO products (product_name, category, price) VALUES
('Laptop', 'Electronics', 1500000),
('Phone', 'Electronics', 800000),
('Shoes', 'Fashion', 120000);

INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2024-01-10', 'Completed'),
(2, '2024-01-11', 'Pending'),
(1, '2024-01-12', 'Completed');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1),
(1, 2, 2),
(2, 3, 1),
(3, 2, 1);

-- =====================================================
-- Assignment Questions
-- =====================================================

-- Q1 : Create a VIEW to Show Customer Basic Information (Hide Email)
CREATE VIEW vw_customer_info AS
SELECT customer_id,
       customer_name,
       city
FROM   customers;
Select * from vw_customer_info;

-- Q2 :  Create a VIEW to Show All Completed Orders
CREATE VIEW vw_completed_orders AS
SELECT o.order_id,
       c.customer_name,
       o.order_date,
       o.status
FROM   orders    o
JOIN   customers c ON o.customer_id = c.customer_id
WHERE  o.status = 'Completed';
SELECT * FROM vw_completed_orders;

-- Q3: Create a JOIN VIEW for Order Details (Customer + Product) 
CREATE VIEW vw_order_details AS
SELECT c.customer_name,
       o.order_id,
       o.order_date,
       p.product_name,
       p.price,
       oi.quantity,
       (p.price * oi.quantity) AS line_total
FROM   customers   c
JOIN   orders      o  ON c.customer_id = o.customer_id
JOIN   order_items oi ON o.order_id    = oi.order_id
JOIN   products    p  ON oi.product_id = p.product_id;
SELECT * FROM vw_order_details;

-- Q4: Create a VIEW to Calculate Total Sales per Order 
CREATE VIEW vw_order_totals AS
SELECT o.order_id,
       c.customer_name,
       o.order_date,
       SUM(p.price * oi.quantity) AS total_sales
FROM   orders      o
JOIN   customers   c  ON o.customer_id = c.customer_id
JOIN   order_items oi ON o.order_id    = oi.order_id
JOIN   products    p  ON oi.product_id = p.product_id
GROUP BY o.order_id, c.customer_name, o.order_date;
SELECT * FROM vw_order_totals;

-- Q5: Create a VIEW for High-Value Orders (Above 1,000,000) 
CREATE VIEW vw_high_value_orders AS
SELECT order_id,
       customer_name,
       order_date,
       total_sales
FROM   vw_order_totals
WHERE  total_sales > 1000000;
SELECT * FROM vw_high_value_orders;

-- Q6: Create a VIEW with WITH CHECK OPTION 
CREATE VIEW vw_completed_only AS
SELECT order_id, customer_id, order_date, status
FROM   orders
WHERE  status = 'Completed'
WITH CHECK OPTION;
-- VALID: status = 'Completed' -- succeeds
INSERT INTO vw_completed_only (customer_id, order_date, status)
VALUES (2, '2024-02-01', 'Completed');
-- INVALID: status = 'Pending' -- FAILS
INSERT INTO vw_completed_only (customer_id, order_date, status)
VALUES (3, '2024-02-02', 'Pending');
-- ERROR 1369 (HY000): CHECK OPTION failed 'ecommerce_view_demo.vw_completed_only'

-- Q7: Try to Update Data Using VIEW (Updatable View) 
-- vw_customer_info is updatable (single table, no GROUP BY, no aggregation)
UPDATE vw_customer_info
SET    city = 'Naypyidaw'
WHERE  customer_id = 1;
-- Verify change in base table
SELECT customer_id, customer_name, city FROM customers WHERE customer_id = 1;
-- Result: 1 | Aung Aung | Naypyidaw
-- Also visible in the view
SELECT * FROM vw_customer_info WHERE customer_id = 1;
-- Result: 1 | Aung Aung | Naypyidaw

-- Q8: Try Invalid Update (Should Fail) 
-- FAIL: vw_order_totals has GROUP BY + SUM
UPDATE vw_order_totals
SET    total_sales = 9999999
WHERE  order_id = 1;
-- ERROR 1288 (HY000): The target table vw_order_totals of the UPDATE is not updatable
-- FAIL: vw_order_details joins 4 tables
UPDATE vw_order_details
SET    product_name = 'MacBook'
WHERE  order_id = 1;
-- ERROR 1288 (HY000): The target table vw_order_details of the UPDATE is not updatable

-- Q9: Create a VIEW for Customer Purchase Summary 
CREATE VIEW vw_customer_summary AS
SELECT c.customer_id,
       c.customer_name,
       c.city,
       COUNT(DISTINCT o.order_id)   AS total_orders,
       SUM(oi.quantity)             AS total_items,
       SUM(p.price * oi.quantity)   AS total_spent
FROM   customers   c
JOIN   orders      o  ON c.customer_id = o.customer_id
JOIN   order_items oi ON o.order_id    = oi.order_id
JOIN   products    p  ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name, c.city;
SELECT * FROM vw_customer_summary;
 

-- Q10: Create a VIEW Using ALGORITHM = TEMPTABLE 
CREATE ALGORITHM = TEMPTABLE VIEW vw_sales_summary AS
SELECT p.category,
       COUNT(oi.order_item_id)     AS total_items_sold,
       SUM(p.price * oi.quantity)  AS category_revenue
FROM   products    p
JOIN   order_items oi ON p.product_id = oi.product_id
GROUP BY p.category;
SELECT * FROM vw_sales_summary;

-- Q11: Create a VIEW for Security (Hide Price) 
CREATE VIEW vw_product_catalog AS
SELECT product_id,
       product_name,
       category
       -- price intentionally excluded
FROM   products;
SELECT * FROM vw_product_catalog;

-- Q12: Show All Views in Database
-- Method 1: Quick list
SHOW FULL TABLES IN ecommerce_view_demo WHERE TABLE_TYPE = 'VIEW';
-- Method 2: Detailed with updatability
SELECT TABLE_NAME    AS view_name,
       IS_UPDATABLE
FROM   INFORMATION_SCHEMA.VIEWS
WHERE  TABLE_SCHEMA = 'ecommerce_view_demo';

-- Q13: Show View Definition
SHOW CREATE VIEW vw_order_details;

-- Q14: Drop a View
-- Drop a single view
DROP VIEW IF EXISTS vw_high_value_orders;
-- Drop multiple views at once
DROP VIEW IF EXISTS vw_completed_orders, vw_completed_only;
-- Verify
SHOW FULL TABLES IN ecommerce_view_demo WHERE TABLE_TYPE = 'VIEW';

-- =====================================================
-- Additional Question
-- =====================================================

-- Additional Q1: Create a View for Pending Orders Only
CREATE VIEW vw_pending_orders AS
SELECT o.order_id,
       c.customer_name,
       c.city,
       o.order_date,
       o.status
FROM   orders    o
JOIN   customers c ON o.customer_id = c.customer_id
WHERE  o.status = 'Pending';
SELECT * FROM vw_pending_orders;

-- Additional Q2: Create a View Showing Top 3 Expensive Products
CREATE VIEW vw_top3_expensive AS
SELECT product_id,
       product_name,
       category,
       price
FROM   products
ORDER BY price DESC
LIMIT 3;
SELECT * FROM vw_top3_expensive;

-- Additional Q3: Create a View Showing Customer Orders by City
CREATE VIEW vw_orders_by_city AS
SELECT c.city,
       COUNT(DISTINCT o.order_id)    AS total_orders,
       COUNT(DISTINCT c.customer_id) AS total_customers,
       SUM(p.price * oi.quantity)    AS city_revenue
FROM   customers   c
JOIN   orders      o  ON c.customer_id = o.customer_id
JOIN   order_items oi ON o.order_id    = oi.order_id
JOIN   products    p  ON oi.product_id = p.product_id
GROUP BY c.city
ORDER BY city_revenue DESC;
SELECT * FROM vw_orders_by_city;

-- Additional Q4: Create a View for Monthly Sales Report
CREATE VIEW vw_monthly_sales AS
SELECT YEAR(o.order_date)                AS sale_year,
       MONTH(o.order_date)               AS sale_month,
       DATE_FORMAT(o.order_date,'%Y-%m') AS month_label,
       COUNT(DISTINCT o.order_id)        AS total_orders,
       SUM(p.price * oi.quantity)        AS monthly_revenue
FROM   orders      o
JOIN   order_items oi ON o.order_id    = oi.order_id
JOIN   products    p  ON oi.product_id = p.product_id
GROUP BY sale_year, sale_month, month_label
ORDER BY sale_year, sale_month;
SELECT * FROM vw_monthly_sales;

-- Additional Q5: Create a View Showing Products Not Ordered
CREATE VIEW vw_unordered_products AS
SELECT p.product_id,
       p.product_name,
       p.category,
       p.price
FROM   products    p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE  oi.order_item_id IS NULL;
-- Currently all products have been ordered, so result is empty
SELECT * FROM vw_unordered_products;
-- Result: Empty set (0 rows)
-- Test by adding an unordered product
INSERT INTO products (product_name, category, price) VALUES ('Tablet', 'Electronics', 600000);
-- Now the view returns the new product
SELECT * FROM vw_unordered_products;





















