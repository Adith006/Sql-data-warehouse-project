/*
===============================================================================
WARNING: DESTRUCTIVE ETL PROCESS (SILVER LAYER LOAD)
===============================================================================
PURPOSE:
This stored procedure ('silver.load_silver') executes the transformation 
pipeline from the 'bronze' schema to the 'silver' schema. It cleanses raw 
data, handles nulls, normalizes values (e.g., gender, marital status, country 
codes), removes duplicates, and performs necessary type casting to ensure 
data quality for analytical reporting.

CAUTION: 
Executing this stored procedure will PERMANENTLY TRUNCATE all existing data 
in the target tables within the 'silver' schema before reloading them with 
the transformed dataset. 

Affected tables:
- silver.crm_cust_info
- silver.crm_prd_info
- silver.crm_sales_details
- silver.erp_CUST_AZ12
- silver.erp_LOC_A101
- silver.erp_PX_CAT_G1V2

This process cannot be undone. Ensure the 'bronze' staging tables are 
populated and accurate before execution.
===============================================================================
*/
-- choosing only the latest data to remove duplicates --
--select * from silver.crm_cust_info--
-- creating a procedure -- 
create or alter procedure silver.load_silver as
begin
	-- to check ETL duration 
	declare @start_time datetime, @end_time datetime,@batch_start_time datetime,@batch_end_time datetime;
-- to check errors using try and catch --
	begin try
		print '=========================================================================================';
		print('loading the silver layer');
		print '=========================================================================================';

		print '----------------------------------------------------------------------------------------';
		print('loading the crm tables');
		print '----------------------------------------------------------------------------------------';

		set @start_time = GETDATE();
		print '>> truncating the table'
		truncate table silver.crm_cust_info
		print '>> Inserting data into silver.crm'
		insert into silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gender,
		cst_create_date)
		select 
		cst_id,
		cst_key,
		trim(cst_firstname) as cst_firstname,
		trim(cst_lastname) as cst_lastname,
		case when upper(trim(cst_gender)) = 'F' then 'Female'
			when upper(trim(cst_gender)) = 'M' then 'Male'
			else 'n/a'
		end cst_gender,
		case when upper(trim(cst_marital_status)) = 'S' then 'Single'
			when upper(trim(cst_marital_status)) = 'M' then 'Married'
			else 'n/a'
		end cst_marital_status,
		cst_create_date
		from (
			select * ,
			row_number() over (partition by cst_id order by cst_create_date desc) as flag_last
			from bronze.crm_cust_info
			where cst_id is not null
		)t where flag_last = 1
		set @end_time = GETDATE();
		print 'load duration ' + cast(datediff(second, @start_time,@end_time)as nvarchar) + ' seconds';

		select * from silver.crm_cust_info


		--- cleaning the product table crm ---
		set @start_time = GETDATE();
		print '>> truncating the table'
		truncate table silver.crm_prd_info
		print '>> Inserting data into silver.crm'
		insert into silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
		)
		select 
		prd_id,
		replace(SUBSTRING(prd_key, 1,5),'-','_') as cat_id,
		SUBSTRING(prd_key,7, LEN(prd_key)) as prd_key,
		prd_nm,
		isnull(prd_cost,0) as prd_cost,
		case UPPER(TRIM(prd_line))
			when  'M' then 'Mountain'
			when  'R' then 'Road'
			when  'S' then 'OtherSales'
			when  'T' then 'Touring'
			else 'N/A'
		end as prd_line,
		cast(prd_start_dt as date) as prd_start_dt,
		cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)- 1 as date) as prd_end_dt
		from bronze.crm_prd_info
		set @end_time = GETDATE();
		print 'load duration ' + cast(datediff(second, @start_time,@end_time)as nvarchar) + ' seconds';

		select * from silver.crm_prd_info

		--data cleaning for sales table --
		set @start_time = GETDATE();
		print '>> truncating the table'
		truncate table silver.crm_sales_details
		print '>> Inserting data into silver.crm'
		insert into silver.crm_sales_details(
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
		case
			when sls_order_dt = 0 or LEN(sls_order_dt) != 8 then null
			else cast(cast(sls_order_dt as varchar) as date)
		end as sls_order_dt,
		case
			when sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 then null
			else cast(cast(sls_ship_dt as varchar) as date)
		end as sls_ship_dt,
		case
			when sls_due_dt = 0 or LEN(sls_due_dt) != 8 then null
			else cast(cast(sls_due_dt as varchar) as date)
		end as sls_due_dt,
		case
			when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_price)
			then sls_quantity * abs(sls_price)
			else sls_sales
		end as sls_sales,
		sls_quantity,
		case
			when sls_price is null or sls_price <= 0
			then sls_sales / nullif(sls_quantity,0)
			else sls_price
		end as sls_price
		from bronze.crm_sales_details
		set @end_time = GETDATE();
		print 'load duration ' + cast(datediff(second, @start_time,@end_time)as nvarchar) + ' seconds';


		print '----------------------------------------------------------------------------------------';
		print('loading the erp tables');
		print '----------------------------------------------------------------------------------------';
		--- ERP---
		set @start_time = GETDATE();
		print '>> truncating the table'
		truncate table silver.erp_CUST_AZ12
		print '>> Inserting data into silver.crm'
		-- cleaning for erp_cust_az12 ---
		insert into silver.erp_CUST_AZ12(
		CID,
		BDATE,
		GEN

		)
		select
		case
			when CID like 'NAS%' then substring (cid,4,LEN(cid))
			else CID
		end CID,
		case
			when BDATE > GETDATE() then null
			else BDATE
		end as Bdate,
		case
			when upper(trim(gen)) in ('F','FEMALE') then 'Female'
			when upper(trim(gen)) in ('M','MALE') then 'Male'
			else 'N/A'
		end as gen
		from bronze.erp_CUST_AZ12

		-- cleaning for the location table --
		set @start_time = GETDATE();
		print '>> truncating the table'
		truncate table silver.erp_LOC_A101
		print '>> Inserting data into silver.crm'
		insert into silver.erp_LOC_A101
		(
		CID,
		CNTRY
		)
		select
		replace(CID,'-','') Cid,
		case
			when trim(CNTRY) = 'DE' then 'Germany'
			when trim(CNTRY) in ('US','USA') then 'United States'
			when trim(CNTRY) = '' or CNTRY is null then 'N/A'
			else trim(CNTRY)

		end as Cntry
		from bronze.erp_LOC_A101
		set @end_time = GETDATE();
		print 'load duration ' + cast(datediff(second, @start_time,@end_time)as nvarchar) + ' seconds';

		-- cleaning for px_cat_table ---
		set @start_time = GETDATE();
		print '>> truncating the table'
		truncate table silver.erp_PX_CAT_G1V2
		print '>> Inserting data into silver.crm'
		insert into silver.erp_PX_CAT_G1V2(
		ID,
		CAT,
		SUBCAT,
		MAINTENANCE
		)
		select 
		ID,
		CAT,
		SUBCAT,
		MAINTENANCE
		from bronze.erp_PX_CAT_G1V2
		set @end_time = GETDATE();
		print 'load duration ' + cast(datediff(second, @start_time,@end_time)as nvarchar) + ' seconds';

		set @batch_end_time = GETDATE();
		print'================================================================================='
		print'Loading silver layer is completed'
		print 'load duration ' + cast(datediff(second, @batch_start_time,@batch_end_time)as nvarchar) + ' seconds';
		print'=================================================================================='

		end try
		begin catch
		print'================================================================================='
		print 'error occured during loading the bronze layer';
		print 'Error Message'+ error_message();
		print 'Error Message'+ cast(error_number() as nvarchar);
	
		print'================================================================================='
		end catch
	end
