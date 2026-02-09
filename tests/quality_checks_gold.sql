-- First check: Data Integrity. Different data from different tables.

SELECT DISTINCT
	ci.cst_gndr,
	ca.gen
FROM Silver.crm_cust_info ci
LEFT JOIN Silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN Silver.erp_loc_a101 la
ON ci.cst_key = la.cid
ORDER BY 1, 2

-- After discussing with the source system experts, we concluded that the data from the cust_info table is correct.

