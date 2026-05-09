DROP TABLE IF EXISTS bronze.crm_cust_info;
create table bronze.crm_cust_info (

cst_id INT,
cst_key VARCHAR(50),
cst_firstname VARCHAR(50),
cst_lastname VARCHAR(50),
cst_marital_status VARCHAR(50),
cst_gndr VARCHAR(50),
cst_create_date DATE
);


DROP TABLE IF EXISTS bronze.crm_prd_info;
create table bronze.crm_prd_info (
prd_id INT,
prd_key varchar(50),
prd_nm varchar(50),
prd_cost INT,
prd_line varchar(50),
prd_start_dt TIMESTAMP,
prd_end_dt TIMESTAMP
);

DROP TABLE IF EXISTS bronze.crm_sales_details;
create table bronze.crm_sales_details(

sls_ord_num varchar(50),
sls_prd_key varchar(50),
sls_cust_id INT,
sls_order_dt int,
sls_ship_dt int,
sls_due_dt int,
sls_sales int,
sls_quantity int,
sls_price int
);

DROP TABLE IF EXISTS bronze.erp_loc_al01;
create table bronze.erp_loc_al01 (
cid VARCHAR(50),
cntry VARCHAR(50)
);

DROP TABLE IF EXISTS bronze.erp_cust_az12;
create table bronze.erp_cust_az12 (

cid VARCHAR(50),
bdate DATE,
gen VARCHAR(50)
);

DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
create table bronze.erp_px_cat_g1v2 (
id VARCHAR(50),
cat VARCHAR(50),
subcat varchar(50),
maintenance varchar(50)
);


-- data inserted via csv file using table plus import option
select count(*) from bronze.crm_cust_info;

select count(*) from bronze.crm_prd_info;

select count(*) from bronze.crm_sales_details;

select count(*) from bronze.erp_cust_az12;
