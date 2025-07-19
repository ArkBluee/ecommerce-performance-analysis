import pandas as pd
import mysql.connector

# Database connection config
db_config = {
    'host': '127.0.0.1',
    'user': 'root',
    'password': 'mypass',
    'database': 'ecommerce'
}

# Connect to database
conn = mysql.connector.connect(**db_config)

# SQL query to export cleaned data
query = """
SELECT 
    o.order_id,
    oi.product_id,
    oi.seller_id,  -- Include seller_id from order_items
    p.product_category_name,
    t.product_category_name_english,
    p.product_name_length,
    p.product_description_length,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    oi.price,
    oi.freight_value,
    op.payment_type,
    op.payment_value,
    op.payment_installments,
    r.review_score,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date
FROM orders o
JOIN order_items oi 
    ON o.order_id = oi.order_id
JOIN products p 
    ON oi.product_id = p.product_id
JOIN product_category_name_translation t 
    ON p.product_category_name = t.product_category_name
JOIN order_payments op 
    ON o.order_id = op.order_id
LEFT JOIN order_reviews r 
    ON o.order_id = r.order_id;
"""

# Load into DataFrame
df = pd.read_sql(query, conn)

# Data cleaning (Did this just now so joins before won't be affected)
df['product_category_name'] = (
    df['product_category_name'].astype(str)
    .str.replace('_', ' ', regex=False)
    .str.strip()
    .str.lower()
)

df['product_category_name_english'] = (
    df['product_category_name_english'].astype(str)
    .str.replace('_', ' ', regex=False)
    .str.strip()
    .str.lower()
)

df['payment_type'] = (
    df['payment_type'].astype(str)
    .str.replace('_', ' ', regex=False)
    .str.strip()
    .str.lower()
)

# Export to CSV
output_path = 'data/cleaned_data/cleaned_data.csv'
df.to_csv(output_path, index=False)

# Close connection
conn.close()

print(f"Cleaned data exported to: {output_path}")
