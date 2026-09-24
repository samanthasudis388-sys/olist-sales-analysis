/* ======================================================================
	Olist E-Commerce Star Schema
	Author: Samantha Sudis
	Database: PostgreSQL
 
	Builds a star schema from the Brazilian E-Commerce Public Dataset 
	by Olist, for analysis in Power BI.

	Layers: 
	1. Staging tables - raw CSV data loaded as-is.
	2. Dimension tables - customers, sellers, products, dates.
	3. Fact table - one row per order item
	4. Validation checks
==================================================================== */

/* -------------------------------------------------------------------- 
	1. Staging tables
	Raw data from the Olist CSV files. After creating these, load
	each CSV using pgAdmin's Import/Export Data tool. 
-------------------------------------------------------------------- */

CREATE TABLE stg_orders (
	order_id TEXT
	, customer_id TEXT
	, order_status TEXT
	, order_purchase_timestamp TIMESTAMP
	, order_approved_at TIMESTAMP
	, order_delivered_carrier_date TIMESTAMP
	, order_delivered_customer_date TIMESTAMP
	, order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE stg_customers (
	customer_id TEXT
	, customer_unique_id TEXT
	, customer_zip_code_prefix TEXT
	, customer_city TEXT
	, customer_state TEXT
);

CREATE TABLE stg_order_items (
	order_id TEXT
	, order_item_id INTEGER
	, product_id TEXT
	, seller_id TEXT
	, shipping_limit_data TIMESTAMP
	, price NUMERIC(10,2)
	, freight_value NUMERIC(10,2)
);

CREATE TABLE stg_products (
	product_id TEXT
	, product_category_name TEXT
	, product_name_lenght INTEGER
	, product_description_lenght INTEGER
	, product_photos_qty INTEGER
	, product_weight_g INTEGER
	, product_length_cm INTEGER
	, product_height_cm INTEGER
	, product_width_cm INTEGER
);

CREATE TABLE stg_sellers (
	seller_id TEXT
	, seller_zip_code_prefix TEXT
	, seller_city TEXT
	, seller_state TEXT
);

/* -------------------------------------------------------------------
	2. Dimension tables
	-------------------------------------------------------------- */
-- Date dimension: one row per day covering the dataset's range

CREATE TABLE dim_date AS 
SELECT
	d :: date AS date_id
	, EXTRACT(YEAR FROM d):: INT AS year
	, EXTRACT( QUARTER FROM d):: INT AS quarter
	, EXTRACT (MONTH FROM d):: INT AS month
	, TO_CHAR(d, 'Month') AS month_name
	, EXTRACT(DAY FROM d) :: INT AS day
	, TO_CHAR(d, 'Day') AS day_name
	, CASE WHEN EXTRACT(ISODOW FROM d) IN (6,7) THEN TRUE ELSE FALSE END AS is_weekend
FROM generate_series('2016-01-01':: date, '2018-12-31':: date, '1 day' ) AS d;

-- Customer dimension
-- Note: Olist creates a new customer_id for every order. 
-- customer_unique_id identifies the actual person.

CREATE TABLE dim_customer AS 
SELECT DISTINCT 
	customer_id
	, customer_unique_id
	, customer_zip_code_prefix
	, customer_city
	, customer_state
FROM stg_customers;

SELECT * FROM dim_customer
LIMIT 10;

-- Seller dimension
CREATE TABLE dim_seller AS 
SELECT DISTINCT
	seller_id
	, seller_zip_code_prefix
	, seller_city
	, seller_state
FROM stg_sellers;

SELECT * FROM dim_seller
LIMIT 10;

CREATE TABLE stg_category_translation (
	product_category_name TEXT
	, product_category_name_english TEXT
);

-- Product dimension
CREATE TABLE dim_product AS
SELECT DISTINCT 
	p.product_id
	, COALESCE(t.product_category_name_english, p.product_category_name) AS product_category
	, p.product_weight_g
	, p.product_length_cm
	, p.product_height_cm
	, p.product_width_cm
FROM stg_products p
LEFT JOIN stg_category_translation t
	ON p.product_category_name = t.product_category_name;

SELECT * 
FROM dim_product
LIMIT 10;

SELECT COUNT(*)
FROM stg_products
WHERE product_category_name IS NULL;

DROP TABLE dim_product;

CREATE TABLE dim_product AS
SELECT DISTINCT
    p.product_id,
    COALESCE(t.product_category_name_english, p.product_category_name, 'uncategorized') AS product_category,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM stg_products p
LEFT JOIN stg_category_translation t
    ON p.product_category_name = t.product_category_name;

	SELECT COUNT(*)
FROM dim_product
WHERE product_category = 'uncategorized';

/* ---------------------------------------------------------------------
	3. Fact table
	Grain: one row per item within an order.
	-------------------------------------------------------------------- */
CREATE TABLE fact_order_items AS
SELECT
	oi.order_id
	, oi.order_item_id
	, o.customer_id
	, oi.product_id
	, oi.seller_id
	, o.order_purchase_timestamp::date AS order_date_id
	, o.order_status
	, oi.price
	, oi.freight_value
FROM stg_order_items oi
JOIN stg_orders o
	ON oi.order_id = o.order_id;

/* -----------------------------------------------------------------
	4. Validation checks
	---------------------------------------------------------------- */

-- Products with no category in the source data
Select COUNT(*) AS products_missing_category
FROM stg_products
WHERE product_category_name IS NULL ;

-- confirm those products were labled 'uncategorized'
SELECT COUNT(*) AS uncategorized_products
FROM dim_product
WHERE product_category = 'uncategorized';


