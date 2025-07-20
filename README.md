# E-Commerce Performance Analysis

This project analyzes sales data from a Brazilian marketplace to identify why certain product categories underperform. It simulates a real-world analytics workflow, from SQL data cleaning to Python visualization and Power BI dashboard reporting.

---

## Project Objectives

- Investigate why some product categories are underperforming  
- Clean, preprocess, and perform exploratory data analysis using SQL  
- Perform visual analysis using Python  
- Deliver insights through an interactive Power BI dashboard  

---

## Analytics Process

- **SQL**: Preprocessing and exploratory data analysis through JOINs and aggregations  
- **Python**: Visual analysis using Seaborn and Matplotlib to uncover category performance  
- **Power BI**: Dashboard summarizing findings for business presentation  

---

## Tools Used

- **SQL** (MySQL for data cleaning and joining tables)  
- **Python** (Pandas, Seaborn, Matplotlib for EDA and charting)  
- **Power BI** (for building dashboards and sharing business insights)  

---

## Folder Structure

<details>
<summary>📁 cleaned_data</summary>

- cleaned_data.csv  

</details>

<details>
<summary>📁 raw_data</summary>

- customers.csv  
- geolocation.csv  
- order_items.csv  
- order_payments.csv  
- order_reviews.csv  
- orders.csv  
- product_category_name_translation.csv  
- products.csv  
- sellers.csv  

</details>

<details>
<summary>📁 notebook</summary>

- analysis.ipynb  

</details>

<details>
<summary>📁 sql</summary>

- preprocessing.sql  
- exploratory_data_analysis.sql  

</details>

<details>
<summary>📁 scripts</summary>

- import_csvs_to_mysql.py  
- export_cleaned_data.py  

</details>

<details>
<summary>📁 visuals</summary>

- order_count-top_performers.png  
- order_count-underperformers.png  
- seller_count-top_performers.png  
- seller_count-underperformers.png  
- stock_count-top_performers.png  
- stock_count-underperformers.png  
- top_5_product_categories_by_sales.png  
- top_5_underperforming_product_categories_by_sales.png  

</details>

<details>
<summary>📁 dashboard</summary>

- ecommerce-dashboards.pbix  
- ecommerce-dashboard.pdf  

</details>

---

## Data Source

The dataset used for this project is from Kaggle:  
**[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)**

This dataset includes:
- Order-level transactions  
- Product categories (with English translations)  
- Order items and sellers  
- Customer reviews and shipping info  

---

## Key Findings

- **Underperforming categories** have:
  - Fewer unique sellers  
  - Lower product variety (stock count)  
  - Fewer orders  
- These factors contribute directly to **reduced visibility, availability, and sales performance**.

---

## Dashboard Overview (Power BI)

The interactive dashboard includes:

- **KPIs**: Total Sales, Total Sellers, Top Orders  
- **Tables**:
  - Top 5 Categories by Sales  
  - Top 5 Underperforming Categories by Sales  
- **Bar Charts**:
  - Seller Count – Top Categories  
  - Stock Count – Top Categories  
  - Seller Count – Underperforming Categories  
  - Stock Count – Underperforming Categories  
- **Business Insight** section summarizing findings  

---

## Status

Completed: SQL preprocessing, Python analysis, and Power BI dashboard  
All assets (data, code, and visuals) are organized in this repository  
