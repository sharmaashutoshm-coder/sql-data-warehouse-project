/*
================================================================================
DDL Script: Create Gold Views
================================================================================

Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
================================================================================
*/


CREATE VIEW Gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE
		WHEN ci.cst_gndr != 'Unknown' THEN ci.cst_gndr
		ELSE COALESCE(ca.gen, 'Unknown')
	END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM Silver.crm_cust_info ci
LEFT JOIN Silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN Silver.erp_loc_a101 la
ON ci.cst_key = la.cid

-- Filter out historical data and keep only current data or products with current price
CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY p.prd_start_dt, p.prd_key) AS product_key,
	p.prd_id AS product_id,
	p.prd_key AS product_number,
	p.prd_nm AS product_name,
	p.cat_id AS category_id,
	c.cat AS category,
	c.subcat AS sub_category,
	c.maintenance,
	p.prd_cost AS product_cost,
	p.prd_line AS product_line,
	p.prd_start_dt AS start_date
FROM Silver.crm_prd_info p
LEFT JOIN Silver.erp_px_cat_g1v2 c
ON p.cat_id = c.id
WHERE p.prd_end_dt IS NULL

CREATE VIEW Gold.fact_sales AS
SELECT
	s.sls_ord_num AS order_number,
	p.product_key,
	c.customer_key,
	s.sls_order_dt AS order_date,
	s.sls_ship_dt AS shipping_date,
	s.sls_due_dt AS due_date,
	s.sls_sales AS sales_amount,
	s.sls_quantity AS quantity,
	s.sls_price AS price
FROM Silver.crm_sales_details s
LEFT JOIN Gold.dim_products p
ON s.sls_prd_key = p.product_number
LEFT JOIN Gold.dim_customers c
ON s.sls_cust_id = c.customer_id
