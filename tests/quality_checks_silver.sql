 /*
====================================================================================
Quality Checks
====================================================================================

Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' schema. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
====================================================================================
*/

-- First check: Nulls and Primary Key, expectation: No result

SELECT
	cst_id,
	COUNT(*)
FROM Silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- Second check: Unwanted spaces, expectation: No result

SELECT
	cst_firstname,
	cst_lastname,
	cst_gndr
FROM Silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname) OR cst_lastname != TRIM(cst_lastname) OR cst_gndr != TRIM(cst_gndr)

-- Third check: Data Standardization and Consistency

SELECT
	DISTINCT cst_gndr, cst_marital_status
FROM Silver.crm_cust_info

-- First check: Nulls or duplicates in Primary Key, expectation: no result

SELECT
	prd_id,
	COUNT(*)
FROM Silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Second check: Unwanted spaces, expectation: no result

SELECT
	prd_nm
FROM Silver.crm_prd_info
WHERE TRIM(prd_nm) != prd_nm

-- Third check: Check for Nulls or Negative numbers, expectation: no result

SELECT
	prd_cost
FROM Silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Fourth check: Data Standardization and Consistency

SELECT
	DISTINCT prd_line
FROM Silver.crm_prd_info

-- Fifth check: Data Validation
SELECT
	*
FROM Silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

SELECT
	*
FROM Silver.crm_prd_info

SELECT
	*
FROM Silver.crm_sales_details

-- First check: Check for negative values or 0 values because they can't be case to a date, expectation: No result
SELECT
	NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM Silver.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8 
OR sls_order_dt > 20500101 
OR sls_order_dt < 19900101

SELECT
	NULLIF(sls_ship_dt, 0) AS sls_ship_dt
FROM Silver.crm_sales_details
WHERE sls_ship_dt <= 0 
OR LEN(sls_ship_dt) != 8 
OR sls_ship_dt > 20500101 
OR sls_ship_dt < 19900101

SELECT
	NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM Silver.crm_sales_details
WHERE sls_due_dt <= 0 
OR LEN(sls_due_dt) != 8 
OR sls_due_dt > 20500101 
OR sls_due_dt < 19900101

-- Second check: For invalid Date orders, expectation: No result

SELECT
	*
FROM Silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
OR sls_order_dt > sls_due_dt

-- Third check: Data Consistency between sales, quantity and price
	-- Sales = quantity * price
	-- Values must not be null, zero or negative

SELECT DISTINCT
	sls_sales AS old_sls_sales,
	sls_quantity,
	sls_price AS old_sls_price,
	CASE
		WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,
	CASE
		WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
	END AS sls_price
FROM Silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales <= 0
OR sls_quantity <= 0
OR sls_sales <= 0
ORDER BY sls_sales, sls_quantity, sls_price


-- First check: Data validation, expectation: No result
SELECT
	*
FROM Silver.erp_cust_az12
WHERE cid LIKE '%AW00011000%'

-- Second check: Identify out of range Dates 
SELECT
	bdate
FROM Silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Third check: Data Standardization and Consistency, check for all possible values of gender column

SELECT
	DISTINCT gen
FROM Silver.erp_cust_az12


SELECT
	*
FROM Silver.erp_loc_a101

-- First check: Data Validation -> column values should match, expectation: no result

SELECT
	cid
FROM Silver.erp_loc_a101

SELECT
	cst_key
FROM Silver.crm_cust_info

-- Second check: Standardization and Consistency -> Null values exists

SELECT DISTINCT
	cid,
	cntry
FROM Silver.erp_loc_a101
ORDER BY cntry

SELECT
	id,
	cat,
	subcat,
	maintenance
FROM Silver.erp_px_cat_g1v2

-- First check: unwanted spaces

SELECT
	*
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR TRIM(maintenance) != maintenance

-- Second check: Data Standardization and Consistency

SELECT DISTINCT
	maintenance
FROM bronze.erp_px_cat_g1v2
