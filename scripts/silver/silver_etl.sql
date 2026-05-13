/*
This script creates silver tables.
first this script drops the silver schema if it exists and also silver tablesif they exists.

*/

DROP SCHEMA IF EXISTS silver CASCADE;
create schema silver;


DROP TABLE IF EXISTS silver.crm_cust_info;
create table silver.crm_cust_info (

cst_id INT,
cst_key VARCHAR(50),
cst_firstname VARCHAR(50),
cst_lastname VARCHAR(50),
cst_marital_status VARCHAR(50),
cst_gndr VARCHAR(50),
cst_create_date DATE,
dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


DROP TABLE IF EXISTS silver.crm_prd_info;
create table silver.crm_prd_info (
prd_id INT,
cat_id varchar(50),
prd_key varchar(50),
prd_nm varchar(50),
prd_cost INT,
prd_line varchar(50),
prd_start_dt DATE,
prd_end_dt DATE,
dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.crm_sales_details;
create table silver.crm_sales_details(

sls_ord_num varchar(50),
sls_prd_key varchar(50),
sls_cust_id INT,
sls_order_dt DATE,
sls_ship_dt DATE,
sls_due_dt DATE,
sls_sales int,
sls_quantity int,
sls_price int,
dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_loc_al01;
create table silver.erp_loc_al01 (
cid VARCHAR(50),
cntry VARCHAR(50),
dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_cust_az12;
create table silver.erp_cust_az12 (

cid VARCHAR(50),
bdate DATE,
gen VARCHAR(50),
dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
create table silver.erp_px_cat_g1v2 (
id VARCHAR(50),
cat VARCHAR(50),
subcat varchar(50),
maintenance varchar(50),
dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

