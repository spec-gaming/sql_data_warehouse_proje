/* this script is my etl process.
this script extracts from the bronze layer, transform the data and loads the transformed data into the silver layer.
Also added some error handling  for the stored procedre and loading the data
*/

CREATE or REPLACE PROCEDURE silver.load_silver() LANGUAGE plpgsql
AS $$
BEGIN
	BEGIN
		TRUNCATE TABLE silver.crm_cust_info;
		INSERT INTO silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
		)
		
		select cst_id,
				cst_key,
				trim(cst_firstname) as cst_firstname, 
			    trim(cst_lastname) as cst_lastname,
			
			    CASE 
			    	 when UPPER(trim(cst_marital_status)) = 'S' then 'Single'
			    	 when UPPER(trim(cst_marital_status)) = 'M' then 'Married'
			    	  else 'Unknown'
				end cst_marital_status,
			    CASE
			    	WHEN TRIM(cst_gndr) = 'M' then 'Male'
			    	WHEN TRIM(cst_gndr) = 'F' then 'Female'
			    	else 'Unknown'
			    end cst_gndr,
			    cst_create_date
		
		from (
		
		select * , 
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER by cst_create_date DESC  )as flag_last
		from bronze.crm_cust_info
		
		)
		where flag_last = 1;
		
		
		RAISE NOTICE 'silver.crm_cust_info loaded';
		
		EXCEPTION
		    WHEN OTHERS THEN
		        RAISE NOTICE 'Error: %', SQLERRM;
		        RAISE;
		
		
		END;
		
		
		
		
		
		
		
		-- prd table
		
	BEGIN	
		TRUNCATE TABLE silver.crm_prd_info;
		INSERT INTO silver.crm_prd_info(
		    prd_id,
		    cat_id, 
		    prd_key,
		    prd_nm,
		    prd_cost,
		    prd_line,
		    prd_start_dt,
		    prd_end_dt
		)
		SELECT 
		    prd_id, 
		    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- extract new column 
		    SUBSTRING(prd_key, 7) AS prd_key, -- extract new coumn
		    prd_nm,
		    COALESCE(prd_cost, 0) AS prd_cost,
		    CASE UPPER(TRIM(prd_line))
		        WHEN 'M' THEN 'Mountain'
		        WHEN 'R' THEN 'Road'
		        WHEN 'S' THEN 'Other Sales'
		        WHEN 'T' THEN 'Other Sales'
		        ELSE 'Unknown'
		    END AS prd_line, -- mapped to meaningful values
		    CAST(prd_start_dt AS DATE) AS prd_start_dt, -- data type casting
		    CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL '1 day' AS 	DATE) AS prd_end_dt
		FROM bronze.crm_prd_info;
			
		RAISE NOTICE 'silver.crm_prd_info';
		
		EXCEPTION
		    WHEN OTHERS THEN
		        RAISE NOTICE 'Error: %', SQLERRM;
		        RAISE;
		END;
		
		BEGIN
		-- sales details
		TRUNCATE TABLE silver.crm_sales_details;
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price 
		)
		
		select 
			sls_ord_num,
			sls_prd_key, 
			sls_cust_id,
				CASE WHEN sls_order_dt = 0 or  LENGTH(cast(sls_order_dt AS VARCHAR)) !=8 THEN NULL
					ELSE CAST(cast(sls_order_dt AS VARCHAR) as DATE) 
				end as sls_order_dt,
			CASE WHEN sls_ship_dt =0 OR LENGTH(CAST(sls_ship_dt as VARCHAR)) !=8 then NULL
				 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) as DATE)
			end sls_ship_dt,
			CASE when sls_due_dt = 0 or LENGTH(CAST(sls_due_dt as VARCHAR)) !=8 then NULL
				 else CAST(CAST( sls_due_dt as VARCHAR) as DATE)
			end sls_due_dt,
			CASE
					WHEN sls_sales is null or sls_price <= 0 or sls_sales != sls_quantity * ABS(sls_price)
						THEN sls_quantity * ABS(sls_price)
						ELSE sls_sales
				end sls_sales,
			sls_quantity,
			CASE
					WHEN sls_price is null or sls_price <=0
						THEN ABS(sls_sales)  / NULLIF(sls_quantity, 0)
						else sls_price
				end sls_price
				
				
		from bronze.crm_sales_details;
		
		
		
		
		-- sales = quantity * price
		-- price = sales / quantity
		
		RAISE NOTICE 'silver.crm_sales_details';
		
		EXCEPTION
		    WHEN OTHERS THEN
		        RAISE NOTICE 'Error: %', SQLERRM;
		        RAISE;
		
		END;
		
		
		-- erp cust
		
		BEGIN
		TRUNCATE TABLE silver.erp_cust_az12;
		INSERT INTO silver.erp_cust_az12 (
		cid,
		bdate,
		gen
		)
		
		SELECT
			CASE 
				WHEN cid LIKE 'NAS%' then SUBSTRING(cid, 4, LENGTH(cid))
				ELSE cid
				end cid,
				
			CASE
				WHEN bdate >  now()
				THEN NULL
				ELSE bdate
			end bdate,
			
			CASE
				WHEN upper(gen) in ('M', 'MALE')
				THEN 'Male'
				
				WHEN upper(gen) in ('F', 'FEMALE') 
				THEN 'Female'
				
				else 'Unknown'
			end gen
		
		from bronze.erp_cust_az12 ;
		
		
		
		RAISE NOTICE 'silver.erp_cust_az12';
		
		EXCEPTION
		    WHEN OTHERS THEN
		        RAISE NOTICE 'Error: %', SQLERRM;
		        RAISE;
		END;
		
		BEGIN
		-- erp loc
		TRUNCATE TABLE silver.erp_loc_al01;
		INSERT INTO silver.erp_loc_al01 ( cid, cntry)
		
		select REPLACE(cid, '-', '') as cid,
				
				CASE
					WHEN upper(trim(cntry)) in ('DE', 'GERMANY')
					THEN 'Germany'
					
					WHEN upper(trim(cntry)) in ('UNITED STATES', 'US', 'USA')
					THEN 'United States'
					
					WHEN trim(cntry) is NULL or upper(trim(cntry)) = ''
					THEN 'Unknown'
					
					ELSE cntry
				end cntry
		from bronze.erp_loc_al01 ;
		
		
		RAISE NOTICE 'silver.erp_loc_al01';
		
		EXCEPTION
		    WHEN OTHERS THEN
		        RAISE NOTICE 'Error: %', SQLERRM;
		        RAISE;
		
		END;
		
		BEGIN
		-- erp px
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		INSERT INTO silver.erp_px_cat_g1v2( id, cat, subcat, maintenance)
		SELECT id, cat, subcat, maintenance from bronze.erp_px_cat_g1v2;
		
		
		
		RAISE NOTICE 'silver.erp_px_cat_g1v2';
		
		EXCEPTION
		    WHEN OTHERS THEN
		        RAISE NOTICE 'Error: %', SQLERRM;
		        RAISE;
		
		END;

END;
$$;




call silver.load_silver();





