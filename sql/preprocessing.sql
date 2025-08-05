-- Inspect table schemas and preview structure
DESCRIBE customers;
SELECT COUNT(*) FROM customers;
SELECT * FROM customers LIMIT 5;

-- Check duplicate rows based on customer_id and customer_unique_id
SELECT COUNT(*) AS count
FROM customers
GROUP BY customer_id, customer_unique_id
HAVING count > 1;

-- Geolocation Table
DESCRIBE geolocation;
SELECT COUNT(*) FROM geolocation;
SELECT * FROM geolocation LIMIT 5;

-- Check duplicate rows based on all columns
SELECT COUNT(*) AS count
FROM geolocation
GROUP BY geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state
HAVING count > 1;

-- Dropping duplicates from geolocation table
CREATE TEMPORARY TABLE geolocation_dedup AS
SELECT DISTINCT * FROM geolocation;

TRUNCATE TABLE geolocation;

INSERT INTO geolocation
SELECT * FROM geolocation_dedup;

-- Order Items Table
DESCRIBE order_items;
SELECT COUNT(*) FROM order_items;
SELECT * FROM order_items LIMIT 5;

-- Check duplicate rows based on composite keys
SELECT COUNT(*) AS count
FROM order_items
GROUP BY order_id, order_item_id, product_id, seller_id
HAVING count > 1;

-- Order Payments Table
DESCRIBE order_payments;
SELECT COUNT(*) FROM order_payments;
SELECT * FROM order_payments LIMIT 5;

-- Check duplicate rows based on order_id, payment_sequential, and payment_type
SELECT COUNT(*) AS count
FROM order_payments
GROUP BY order_id, payment_sequential, payment_type
HAVING count > 1;

-- Order Reviews Table
DESCRIBE order_reviews;
SELECT COUNT(*) FROM order_reviews;
SELECT * FROM order_reviews LIMIT 5;

-- Check duplicate rows based on review_id
-- If rows have the same review_id but different review_comment_message or review_score, they'll still be kept.
SELECT COUNT(*) AS count
FROM order_reviews
GROUP BY review_id
HAVING count > 1;

-- Dropping duplicates from order_reviews table
CREATE TEMPORARY TABLE order_reviews_dedup AS
SELECT DISTINCT * FROM order_reviews;

TRUNCATE TABLE order_reviews;

INSERT INTO order_reviews
SELECT * FROM order_reviews_dedup;

-- Product Category Name Translation Table
DESCRIBE product_category_name_translation;
SELECT COUNT(*) FROM product_category_name_translation;
SELECT * FROM product_category_name_translation LIMIT 5;

-- Check duplicate rows based on both name and translation
SELECT COUNT(*) AS count
FROM product_category_name_translation
GROUP BY product_category_name, product_category_name_english
HAVING count > 1;

-- Products Table
DESCRIBE products;
SELECT COUNT(*) FROM products;
SELECT * FROM products LIMIT 5;
-- Check duplicate rows based on product_id
SELECT COUNT(*) AS count
FROM products
GROUP BY product_id
HAVING count > 1;

-- Fix column typos for accurate reference later
ALTER TABLE products
CHANGE product_name_lenght product_name_length DOUBLE,
CHANGE product_description_lenght product_description_length DOUBLE;

-- Orders Table
DESCRIBE orders;
SELECT COUNT(*) FROM orders;
SELECT * FROM orders LIMIT 5;

-- Check duplicate rows based on order_id
SELECT COUNT(*) AS count
FROM orders
GROUP BY order_id
HAVING count > 1;

-- Sellers Table
DESCRIBE sellers;
SELECT COUNT(*) FROM sellers;
SELECT * FROM sellers LIMIT 5;

-- Check duplicate rows based on seller_id
SELECT COUNT(*) AS count
FROM sellers
GROUP BY seller_id
HAVING count > 1;

-- Null Checks Across Tables
-- Check for NULL values in customers
SELECT
	COUNT(*) AS total_rows,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(customer_unique_id IS NULL) AS null_customer_unique_id,
    SUM(customer_zip_code_prefix IS NULL) AS null_customer_zip,
    SUM(customer_city IS NULL) AS null_city,
    SUM(customer_state IS NULL) AS null_state
FROM customers;

-- Check uniqueness of customers
SELECT COUNT(DISTINCT customer_unique_id) AS unique_customers FROM customers;

-- Check for NULLs in geolocation
SELECT
	COUNT(*) AS total_rows,
    SUM(geolocation_zip_code_prefix IS NULL) AS null_zip,
    SUM(geolocation_lat IS NULL) AS null_lat,
    SUM(geolocation_lng IS NULL) AS null_lng,
    SUM(geolocation_city IS NULL) AS null_city
FROM geolocation;

-- Check for NULLs in order_items
SELECT
	COUNT(*) AS total_rows,
    SUM(order_id IS NULL) AS null_order_id,
    SUM(product_id IS NULL) AS null_product_id,
    SUM(seller_id IS NULL) AS null_seller_id,
    SUM(price IS NULL) AS null_price
FROM order_items;

-- Check for NULLs in order_payments
SELECT
	COUNT(*) AS total_rows,
    SUM(order_id IS NULL) AS null_order_id,
    SUM(payment_sequential IS NULL) AS null_payment_sequential,
    SUM(payment_type IS NULL) AS null_payment_type,
    SUM(payment_installments IS NULL) AS null_payment_installments,
    SUM(payment_value IS NULL) AS null_payment_value
FROM order_payments;

-- Check for NULLs in order_reviews
SELECT
	COUNT(*) AS total_rows,
    SUM(review_id IS NULL) AS null_review_id,
    SUM(order_id IS NULL) AS null_order_id,
    SUM(review_score IS NULL) AS null_review_score,
    SUM(review_comment_title IS NULL) AS null_review_title,
    SUM(review_comment_message IS NULL) AS null_review_comment,
    SUM(review_creation_date IS NULL) AS null_review_date,
    SUM(review_answer_timestamp IS NULL) AS null_review_timestamp
FROM order_reviews;

-- Fill missing text fields in reviews
UPDATE order_reviews SET review_comment_title = 'No title comment' WHERE review_comment_title IS NULL;
UPDATE order_reviews SET review_comment_message = 'No comment' WHERE review_comment_message IS NULL;

-- Check for NULLs in orders (dates left untouched)
SELECT
	COUNT(*) AS total_rows,
    SUM(order_id IS NULL) AS null_order_id,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(order_status IS NULL) AS null_order_status,
    SUM(order_purchase_timestamp IS NULL) AS null_timestamp,
    SUM(order_approved_at IS NULL) AS null_approved_date,
    SUM(order_delivered_carrier_date IS NULL) AS null_carrier_delivery_date,
    SUM(order_delivered_customer_date IS NULL) AS null_customer_delivery_date,
    SUM(order_estimated_delivery_date IS NULL) AS null_estimated_delivery_date
FROM orders;

-- Check NULLs in product category translation
SELECT
	COUNT(*) AS total_rows,
    SUM(product_category_name IS NULL) AS null_category_name,
    SUM(product_category_name_english IS NULL) AS null_name_translation
FROM product_category_name_translation;

-- Check NULLs in products
SELECT
	COUNT(*) AS total_rows,
	SUM(product_id IS NULL) AS null_product_id,
	SUM(product_category_name IS NULL) AS null_category_name,
    SUM(product_name_length IS NULL) AS null_product_name_length,
    SUM(product_description_length IS NULL) AS null_description_length,
    SUM(product_photos_qty IS NULL) AS null_photos_qty,
    SUM(product_weight_g IS NULL) AS null_product_weight,
    SUM(product_length_cm IS NULL) AS null_product_length,
    SUM(product_height_cm IS NULL) AS null_product_height,
    SUM(product_width_cm IS NULL) AS null_product_width
FROM products;

-- Count matchable rows by comparing physical dimensions
SELECT COUNT(DISTINCT p1.product_id) AS matchable_rows
FROM products p1
JOIN products p2
	ON p1.product_weight_g = p2.product_weight_g
 AND p1.product_length_cm = p2.product_length_cm
 AND p1.product_height_cm = p2.product_height_cm
 AND p1.product_width_cm = p2.product_width_cm
WHERE p1.product_category_name IS NULL
  AND p1.product_name_length IS NULL
  AND p2.product_category_name IS NOT NULL
  AND p2.product_name_length IS NOT NULL
  AND p1.product_id <> p2.product_id;

-- Update missing category and name length using matched dimensions
UPDATE products p1
JOIN (
  SELECT
    p1.product_id AS null_product_id,
    ANY_VALUE(p2.product_category_name) AS product_category_name,
    ANY_VALUE(p2.product_name_length) AS product_name_length
  FROM products p1
  JOIN products p2
		ON p1.product_weight_g = p2.product_weight_g
   AND p1.product_length_cm = p2.product_length_cm
   AND p1.product_height_cm = p2.product_height_cm
   AND p1.product_width_cm = p2.product_width_cm
  WHERE p1.product_category_name IS NULL
    AND p1.product_name_length IS NULL
    AND p2.product_category_name IS NOT NULL
    AND p2.product_name_length IS NOT NULL
    AND p1.product_id <> p2.product_id
  GROUP BY p1.product_id
) AS updates
ON p1.product_id = updates.null_product_id
SET
  p1.product_category_name = updates.product_category_name,
  p1.product_name_length = updates.product_name_length;

-- Update missing dimensions using products with same category and name length
UPDATE products p1
JOIN (
  SELECT
    p1.product_id AS null_product_id,
    ANY_VALUE(p2.product_weight_g) AS product_weight_g,
    ANY_VALUE(p2.product_length_cm) AS product_length_cm,
    ANY_VALUE(p2.product_height_cm) AS product_height_cm,
    ANY_VALUE(p2.product_width_cm) AS product_width_cm,
    ANY_VALUE(p2.product_photos_qty) AS product_photos_qty
  FROM products p1
  JOIN products p2
	ON p1.product_category_name = p2.product_category_name
   AND p1.product_name_length = p2.product_name_length
  WHERE (
        p1.product_weight_g IS NULL OR
        p1.product_length_cm IS NULL OR
        p1.product_height_cm IS NULL OR
        p1.product_width_cm IS NULL OR
        p1.product_photos_qty IS NULL
    )
    AND p2.product_weight_g IS NOT NULL
    AND p2.product_length_cm IS NOT NULL
    AND p2.product_height_cm IS NOT NULL
    AND p2.product_width_cm IS NOT NULL
    AND p2.product_photos_qty IS NOT NULL
    AND p1.product_id <> p2.product_id
  GROUP BY p1.product_id
) AS updates
ON p1.product_id = updates.null_product_id
SET
  p1.product_weight_g = updates.product_weight_g,
  p1.product_length_cm = updates.product_length_cm,
  p1.product_height_cm = updates.product_height_cm,
  p1.product_width_cm = updates.product_width_cm,
  p1.product_photos_qty = updates.product_photos_qty;

-- Delete records with still-missing essential product info
SELECT COUNT(*) AS rows_to_delete
FROM products
WHERE product_category_name IS NULL
   OR product_name_length IS NULL
   OR product_weight_g IS NULL
   OR product_length_cm IS NULL
   OR product_height_cm IS NULL
   OR product_width_cm IS NULL
   OR product_photos_qty IS NULL;

DELETE FROM products
WHERE product_category_name IS NULL
   OR product_name_length IS NULL
   OR product_weight_g IS NULL
   OR product_length_cm IS NULL
   OR product_height_cm IS NULL
   OR product_width_cm IS NULL
   OR product_photos_qty IS NULL;

-- Final NULL check on sellers
SELECT
	COUNT(*) AS total_rows,
    SUM(seller_id IS NULL) AS null_seller_id,
    SUM(seller_zip_code_prefix IS NULL) AS null_seller_zip,
    SUM(seller_city IS NULL) AS null_seller_city,
    SUM(seller_state IS NULL) AS null_seller_state
FROM sellers;
