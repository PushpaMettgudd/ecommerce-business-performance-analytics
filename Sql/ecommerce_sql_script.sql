-- CREATE DATABASE ecommerce_analytics;
USE ecommerce_analytics;
-- CREATE TABLE users (
-- user_id	VARCHAR(20) PRIMARY KEY,
-- name VARCHAR(100) NOT NULL,	
-- email VARCHAR(50) NOT NULL UNIQUE,
-- gender VARCHAR(10),
-- city VARCHAR(100) NOT NULL,	
-- signup_date DATE
-- );

-- CREATE TABLE  products(
-- product_id VARCHAR(25) PRIMARY KEY,	
-- product_name VARCHAR(50) NOT NULL,
-- category VARCHAR(50) NOT NULL,
-- brand VARCHAR(100) NOT NULL,	
-- price DECIMAL(10,2) NOT NULL,	
-- rating DECIMAL(3,2) 
-- );

-- CREATE TABLE orders(
-- order_id VARCHAR(30) PRIMARY KEY,
-- user_id VARCHAR(20) NOT NULL,
-- CONSTRAINT fk_orders_user FOREIGN key (user_id) REFERENCES users(user_id),	
-- order_date DATETIME NOT NULL,	
-- order_status VARCHAR(30) NOT NULL,	
-- total_amount DECIMAL(10,2) NOT NULL
-- );



-- CREATE TABLE events(
-- event_id VARCHAR(25) PRIMARY KEY,
-- product_id VARCHAR(25) NOT NULL,
-- user_id VARCHAR(20) NOT NULL,
-- CONSTRAINT fk_events_product FOREIGN key (product_id) REFERENCES products(product_id),
-- CONSTRAINT fk_events_user FOREIGN key (user_id) REFERENCES users(user_id),	
-- event_type VARCHAR(20) NOT NULL	,
-- event_timestamp DATETIME NOT NULL
-- );

-- CREATE TABLE order_items (
-- order_item_id VARCHAR(30) PRIMARY KEY ,	
-- order_id VARCHAR(30) NOT NULL,
-- product_id VARCHAR(25) NOT NULL,
-- user_id VARCHAR(20) NOT NULL,
-- CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
-- CONSTRAINT fk_order_items_product FOREIGN key (product_id) REFERENCES products(product_id),
-- CONSTRAINT fk_order_items_user FOREIGN key (user_id) REFERENCES users(user_id),	
-- quantity INT NOT NULL,	
-- item_price	DECIMAL(10,2) NOT NULL,
-- item_total DECIMAL(10,2) NOT NULL
-- );

-- CREATE TABLE reviews(
-- review_id VARCHAR(30) PRIMARY KEY,
-- order_id VARCHAR(30) NOT NULL,
-- product_id VARCHAR(25) NOT NULL,
-- user_id VARCHAR(20) NOT NULL,
-- CONSTRAINT fk_reviews_order FOREIGN KEY (order_id) REFERENCES orders(order_id),	
-- CONSTRAINT fk_reviews_product FOREIGN key (product_id) REFERENCES products(product_id),
-- CONSTRAINT fk_reviews_user FOREIGN key (user_id) REFERENCES users(user_id),	
-- rating INT,
-- review_text	VARCHAR(255),
-- review_date DATETIME  NOT NULL
-- );

-- DATA VERIFICATION -- 
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM events;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*)FROM reviews;
SELECT COUNT(*) FROM users;

-- TOTAL REVENUE GENERATED--  
SELECT SUM(total_amount) AS revenue FROM orders;

-- TOTAL ORDERS PLACED--
SELECT COUNT(*) AS total_orders FROM orders;

-- CUSTOMERS WITH ORDERS PLACED -- 
SELECT COUNT(DISTINCT user_id) AS order_placed_customers FROM orders;

-- AVARAGE VALUE PER ORDER-- 
SELECT SUM(total_amount)/COUNT(*) AS average_value_per_order FROM orders;

-- TOTAL PRODUCTS SOLD -- 
SELECT SUM(quantity) AS total_products_sold FROM order_items;

-- AVERAGE RATINGS OF THE CUSTOMERS -- 
SELECT AVG(rating) AS avg_review_rating FROM reviews;

-- MONTH WISE REVENUE -- 
SELECT year(order_date) AS year, monthname(order_date)  AS month,sum(total_amount) as monthly_revenue FROM orders 
GROUP BY 
	YEAR(order_date), month(order_date), monthname(order_date)
ORDER BY 
	year(order_date) ,month(order_date);

-- MONTH HAIVNG HIGHEST REVENUE-- 
SELECT YEAR(order_date) AS year,monthname(order_date)AS month,sum(total_amount) AS high_revenue_month
FROM orders GROUP BY YEAR(order_date),monthname(order_date) ORDER BY max(total_amount) DESC LIMIT 1;

-- WHICHH MONTH HAS HIGH ORDERS PLACED -- 
SELECT year(orders.order_date) AS year,monthname(orders.order_date) as highest_orders, SUM(order_items.quantity) AS products_sold
FROM orders join order_items on orders.order_id=order_items.order_id
GROUP BY year(orders.order_date),month(orders.order_date), monthname(orders.order_date) 
ORDER BY SUM(order_items.quantity) DESC limit 1;

-- WHICH CATEGORY GENERATED HIGHEST REVENUE  -- 
SELECT products.category AS product_category, ROUND(SUM(order_items.item_total),2) AS category_revenue
FROM products INNER JOIN order_items ON products.product_id = order_items.product_id GROUP BY products.category
ORDER BY SUM(order_items.item_total)  DESC LIMIT 1;

-- WHICH PRODUCT HAD HIGHEST REVENUE --  
SELECT products.category AS product_category,products.product_name,products.product_id AS product_id,
 ROUND(SUM(order_items.item_total),2) AS product_revenue
FROM products INNER JOIN order_items ON products.product_id = order_items.product_id GROUP BY products.category,products.product_id,
products.product_name
ORDER BY SUM(order_items.item_total)  DESC LIMIT 1;

-- TOP 10 CUSTOMER BY TOTA; SPENDING
SELECT users.name,users.user_id, ROUND(SUM(order_items.item_total),2) AS spending_by_customer FROM users
INNER JOIN order_items ON users.user_id = order_items.user_id GROUP BY users.user_id,users.name
ORDER BY  ROUND(SUM(order_items.item_total),2) DESC LIMIT 10;

-- CUSTOMERS WHO NEVER PLACED ORDERS -- 
SELECT users.name AS name,users.user_id AS user_id FROM users LEFT JOIN orders
ON users.user_id=orders.user_id WHERE orders.order_id is NULL;

-- DISTRIBUTION OF ORDER STATUSES -- 
SELECT order_status,COUNT(*) AS status_total_count FROM orders
GROUP BY order_status ORDER BY status_total_count DESC;

-- Which order status generated the highest revenue -- 

SELECT order_status,SUM(total_amount) AS order_statuswise_revenue
FROM orders GROUP BY order_status ORDER BY order_statuswise_revenue DESC;

USE ecommerce_analytics;
SELECT products.category,COUNT(*) AS return_count FROM 
orders JOIN order_items ON orders.order_id= order_items.order_id JOIN products on order_items.product_id= products.product_id
WHERE orders.order_status = 'returned'
 GROUP BY products.category Order by return_count DESC ;
