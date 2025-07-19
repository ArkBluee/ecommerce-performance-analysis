-- Count all orders in the dataset
SELECT COUNT(*) AS total_orders 
FROM orders;

-- Count how many unique customers made purchases
SELECT COUNT(DISTINCT customer_unique_id) AS unique_customers 
FROM customers;

-- Total sales per product category (English names)
-- Helps identify high-performing and low-performing categories
SELECT 
  t.product_category_name_english AS category,
  ROUND(SUM(oi.price), 2) AS total_sales
FROM order_items oi
JOIN products p 
	ON oi.product_id = p.product_id
JOIN product_category_name_translation t 
	ON p.product_category_name = t.product_category_name
GROUP BY t.product_category_name_english
ORDER BY total_sales DESC;

-- Number of orders made each month
-- Shows seasonality or monthly demand
SELECT 
  DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
  COUNT(*) AS total_orders
FROM orders
GROUP BY order_month
ORDER BY order_month;

-- Distribution of review scores
SELECT 
  review_score, 
  COUNT(*) AS num_reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score DESC;

-- Top 10 sellers based on total revenue
SELECT 
  seller_id, 
  ROUND(SUM(price), 2) AS revenue
FROM order_items 
GROUP BY seller_id
ORDER BY revenue DESC
LIMIT 10;

-- Find categories with total sales under 2000
-- These are the underperforming product categories
WITH underperforming_products AS (
  SELECT
    t.product_category_name_english AS category,
    ROUND(SUM(oi.price), 2) AS total_sales
  FROM order_items oi
  JOIN products p 
	ON oi.product_id = p.product_id
  LEFT JOIN product_category_name_translation t 
    ON p.product_category_name = t.product_category_name
  GROUP BY category
)
SELECT * 
FROM underperforming_products 
WHERE total_sales < 2000;

-- Save underperforming categories in a temporary table
CREATE TEMPORARY TABLE underperforming_products AS 
SELECT
  t.product_category_name AS orig_name,
  t.product_category_name_english AS english_category_name,
  ROUND(SUM(oi.price), 2) AS total_sales
FROM order_items oi
JOIN products p 
	ON oi.product_id = p.product_id
JOIN product_category_name_translation t 
	ON p.product_category_name = t.product_category_name
GROUP BY 
  t.product_category_name, 
  t.product_category_name_english
HAVING total_sales < 2000
ORDER BY total_sales;

-- Check contents of underperforming categories
SELECT * 
FROM underperforming_products 
ORDER BY total_sales DESC;

-- Save top-performing categories (sales > 2000) in a temp table
CREATE TEMPORARY TABLE top_performing_products AS
SELECT
  t.product_category_name_english AS english_category_name,
  p.product_category_name AS orig_name,
  ROUND(SUM(oi.price), 2) AS total_sales
FROM order_items oi
JOIN products p 
	ON oi.product_id = p.product_id
JOIN product_category_name_translation t 
	ON p.product_category_name = t.product_category_name
GROUP BY 
  t.product_category_name_english, 
  p.product_category_name
HAVING total_sales > 2000;

-- View contents of top-performing categories
SELECT * 
FROM top_performing_products 
ORDER BY total_sales DESC;

-- Underperforming: average review score and count
-- Insight: Low review scores are not the main reason for poor performance.
SELECT 
  up.english_category_name,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  COUNT(r.review_id) AS total_reviews
FROM underperforming_products up
JOIN products p 
	ON p.product_category_name = up.orig_name
JOIN order_items oi 
	ON oi.product_id = p.product_id
JOIN order_reviews r 
	ON r.order_id = oi.order_id
GROUP BY up.english_category_name
ORDER BY avg_review_score DESC;

-- Top-performing: average review score and count
-- Some top categories have low average reviews too.
SELECT 
  tp.english_category_name,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  COUNT(r.review_id) AS total_reviews
FROM top_performing_products tp
JOIN products p 
	ON p.product_category_name = tp.orig_name
JOIN order_items oi 
	ON oi.product_id = p.product_id
JOIN order_reviews r 
	ON r.order_id = oi.order_id
GROUP BY tp.english_category_name
ORDER BY avg_review_score DESC;

-- Underperforming: average delivery days
-- Delivery speed doesn't fully explain underperformance
SELECT
  up.english_category_name,
  ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS avg_delivery_days
FROM underperforming_products up
JOIN products p 
	ON p.product_category_name = up.orig_name
JOIN order_items oi 
	ON oi.product_id = p.product_id
JOIN orders o 
	ON o.order_id = oi.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY up.english_category_name
ORDER BY avg_delivery_days DESC;

-- Top-performing: average delivery days
SELECT
  tp.english_category_name,
  ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS avg_delivery_days
FROM top_performing_products tp
JOIN products p 
	ON p.product_category_name = tp.orig_name
JOIN order_items oi 
	ON oi.product_id = p.product_id
JOIN orders o 
	ON o.order_id = oi.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY tp.english_category_name
ORDER BY avg_delivery_days DESC;

-- Underperforming: number of unique sellers
-- Insight: Underperformers have fewer sellers, meaning less market presence
SELECT 
  up.english_category_name,
  COUNT(DISTINCT oi.seller_id) AS unique_sellers
FROM underperforming_products up
JOIN products p 
	ON p.product_category_name = up.orig_name
JOIN order_items oi 
	ON oi.product_id = p.product_id
GROUP BY up.english_category_name
ORDER BY unique_sellers DESC;

-- Top-performing: number of unique sellers
SELECT 
  tp.english_category_name,
  COUNT(DISTINCT oi.seller_id) AS unique_sellers
FROM top_performing_products tp
JOIN products p 
	ON p.product_category_name = tp.orig_name
JOIN order_items oi 
	ON oi.product_id = p.product_id
GROUP BY tp.english_category_name
ORDER BY unique_sellers DESC;

-- Underperforming: average product price
-- Insight: Prices are lower, but that doesn't help performance
SELECT
  up.english_category_name,
  ROUND(AVG(oi.price), 2) AS avg_price
FROM underperforming_products up
JOIN products p 
	ON p.product_category_name = up.orig_name
JOIN order_items oi 
	ON oi.product_id = p.product_id
GROUP BY up.english_category_name
ORDER BY avg_price DESC;

-- Top-performing: average product price
SELECT 
  tp.english_category_name,
  ROUND(AVG(oi.price), 2) AS avg_price
FROM top_performing_products tp
JOIN products p 
	ON p.product_category_name = tp.orig_name
JOIN order_items oi 
	ON oi.product_id = p.product_id
GROUP BY tp.english_category_name
ORDER BY avg_price DESC;

-- Underperforming: number of orders
-- Insight: Naturally, fewer orders are placed for underperforming categories
SELECT
  up.english_category_name, 
  COUNT(DISTINCT oi.order_id) AS total_orders
FROM underperforming_products up
JOIN products p 
	ON p.product_category_name = up.orig_name
JOIN order_items oi 
	ON oi.product_id = p.product_id
GROUP BY up.english_category_name
ORDER BY total_orders DESC;

-- Top-performing: number of orders
SELECT
  tp.english_category_name, 
  COUNT(DISTINCT oi.order_id) AS total_orders
FROM top_performing_products tp
JOIN products p 
	ON p.product_category_name = tp.orig_name
JOIN order_items oi 
	ON oi.product_id = p.product_id
GROUP BY tp.english_category_name
ORDER BY total_orders DESC;

-- Underperforming: average payment installments
-- Insight: Similar installment ranges (1–5) across both segments
SELECT 
  up.english_category_name,
  ROUND(AVG(op.payment_installments), 2) AS avg_installments
FROM underperforming_products up
JOIN products p 
	ON p.product_category_name = up.orig_name
JOIN order_items oi 
	ON oi.product_id = p.product_id
JOIN order_payments op 
	ON op.order_id = oi.order_id
GROUP BY up.english_category_name
ORDER BY avg_installments DESC;

-- Top-performing: average payment installments
-- Some top performers show outliers with 7–8 installments
SELECT 
  tp.english_category_name,
  ROUND(AVG(op.payment_installments), 2) AS avg_installments
FROM top_performing_products tp
JOIN products p 
	ON p.product_category_name = tp.orig_name
JOIN order_items oi 
	ON oi.product_id = p.product_id
JOIN order_payments op 
	ON op.order_id = oi.order_id
GROUP BY tp.english_category_name
ORDER BY avg_installments DESC;

-- Underperforming: number of unique products
-- Insight: Low variety contributes to underperformance
SELECT
  up.english_category_name,
  COUNT(DISTINCT p.product_id) AS product_count
FROM underperforming_products up
JOIN products p 
	ON p.product_category_name = up.orig_name
GROUP BY up.english_category_name
ORDER BY product_count DESC;

-- Top-performing: number of unique products
SELECT
  tp.english_category_name,
  COUNT(DISTINCT p.product_id) AS product_count
FROM top_performing_products tp
JOIN products p 
	ON p.product_category_name = tp.orig_name
GROUP BY tp.english_category_name
ORDER BY product_count DESC;

-- Monthly sales trends of underperforming categories
-- Useful for visualizing performance decline or spikes
SELECT
  up.english_category_name,
  DATE_FORMAT(o.order_purchase_timestamp, ' %Y-%m') AS month,
  ROUND(SUM(oi.price), 2) AS total_sales
FROM underperforming_products up
JOIN products p 
	ON p.product_category_name = up.orig_name
JOIN order_items oi 
	ON oi.product_id = p.product_id
JOIN orders o 
	ON o.order_id = oi.order_id
GROUP BY 
  up.english_category_name, 
  month
ORDER BY 
  up.english_category_name, 
  month;
