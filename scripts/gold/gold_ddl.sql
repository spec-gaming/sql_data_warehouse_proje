/*
This script creates views for the gold layer in the data warehouse.
the gold layer is the final dimension and fact tables using the star schema
*/





-- gold layer

-- crm customer info joined with erp cust az12 and erp loc
DROP VIEW gold.dim_customers;
CREATE VIEW gold.dim_customers AS

select 
	
	ROW_NUMBER() OVER(ORDER BY cc.cst_id) as customer_key,
	
	cc.cst_id as customer_id,
	cc.cst_key as customer_number,
	cc.cst_firstname as first_name,
	cc.cst_lastname as last_name,
	 CASE 
	 	WHEN cc.cst_gndr != 'Unknown' THEN cc.cst_gndr 
	 	ELSE COALESCE(ec.gen, 'Unknown')
	 END gender,
	cc.cst_marital_status as marital_status,
	el.cntry as country,
	ec.bdate as birthdate,
	cc.cst_create_date as create_date


from silver.crm_cust_info cc
left JOIN silver.erp_cust_az12 ec
ON cc.cst_key = ec.cid
LEFT JOIN silver.erp_loc_al01 el
ON cc.cst_key = el.cid ;






select 

	distinct cc.cst_gndr,
	 ec.gen,
	 
	 CASE 
	 	WHEN cc.cst_gndr != 'Unknown' THEN cc.cst_gndr 
	 	ELSE COALESCE(ec.gen, 'Unknown')
	 END valid_gender
	

from silver.crm_cust_info cc
left JOIN silver.erp_cust_az12 ec
ON cc.cst_key = ec.cid
LEFT JOIN silver.erp_loc_al01 el
ON cc.cst_key = el.cid;


select * from gold.dim_customers;


-- product gold view

DROP VIEW gold.dim_products;
CREATE VIEW gold.dim_products AS

SELECT
	ROW_NUMBER() OVER(ORDER BY prd_start_dt, cp.prd_id) as product_key,
	cp.prd_id as product_id,
	cp.cat_id category_id,
	cp.prd_key as product_number,
	cp.prd_nm AS product_name,
	ep.cat as category,
	ep.subcat AS subcategory,
	ep.maintenance,
	cp.prd_line AS product_line,
	cp.prd_cost AS product_cost,
	cp.prd_start_dt AS product_start_date
from silver.crm_prd_info cp
LEFT JOIN silver.erp_px_cat_g1v2 ep
ON cp.cat_id = ep.id
WHERE prd_end_dt is NULL ;-- remove historical data




-- gold fact sales
DROP VIEW gold.fact_sales;
CREATE VIEW gold.fact_sales AS

SELECT
	sd.sls_ord_num as order_number,
	pr.product_key,
	cu.customer_key,
	sd.sls_order_dt as order_date,
	sd.sls_ship_dt as shipping_date,
	sd.sls_due_dt as due_date,
	sd.sls_sales as sales_amount,
	sd.sls_quantity as quantity,
	sd.sls_price as price
from silver.crm_sales_details sd
left JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
left JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id;









