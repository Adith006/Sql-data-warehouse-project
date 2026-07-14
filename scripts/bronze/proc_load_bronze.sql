/*
===============================================================================
WARNING: DATA TRUNCATION AND BULK LOAD SCRIPT
===============================================================================
This script creates or alters a stored procedure designed to load the 
bronze (staging) layer of the Data Warehouse.

CAUTION: 
Executing the resulting stored procedure ('bronze.load_bronze') will 
PERMANENTLY TRUNCATE (completely empty) the existing data in the following 
tables before reloading them:
- bronze.crm_cust_info
- bronze.crm_prd_info
- bronze.crm_sales_details
- bronze.erp_CUST_AZ12
- bronze.erp_LOC_A101
- bronze.erp_PX_CAT_G1V2

PREREQUISITES:
Ensure that all source CSV files exist at the exact hardcoded directory paths 
(e.g., 'C:\Users\Adith\Desktop\rvu-adITH\...') and that the SQL Server service 
account has read access to these files. If the files are missing or locked, 
the bulk insert operations will fail.

Project: Data Warehouse Implementation
Purpose: ETL - Full Load of Bronze Layer from Source CSV Files
===============================================================================
*/

-- bulk insert data into tables --
-- cust_info_csv --
--stored procedures as we use in daily life --
create or alter procedure bronze.load_bronze as
begin
-- to check ETL duration 
	declare @start_time datetime, @end_time datetime;
-- to check errors using try and catch --
	begin try
		print '=========================================================================================';
		print('loading the bronze layer');
		print '=========================================================================================';

		print '----------------------------------------------------------------------------------------';
		print('loading the crm tables');
		print '----------------------------------------------------------------------------------------';

		--inserting into customer info ---

		set @start_time = GETDATE();
		truncate table bronze.crm_cust_info;
		bulk insert bronze.crm_cust_info
		from 'C:\Users\Adith\Desktop\rvu-adITH\MBA - AIDS\My Learning\SQL\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print 'load duration ' + cast(datediff(second, @start_time,@end_time)as nvarchar) + ' seconds';
		--select * from bronze.crm_cust_info

		-- prd_info_csv --
		set @start_time = GETDATE();
		truncate table bronze.crm_prd_info;
		bulk insert bronze.crm_prd_info
		from 'C:\Users\Adith\Desktop\rvu-adITH\MBA - AIDS\My Learning\SQL\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print 'load duration ' + cast(datediff(second, @start_time,@end_time)as nvarchar) + ' seconds';

		-- sales details info --
		set @start_time = GETDATE();
		truncate table bronze.crm_sales_details;
		bulk insert bronze.crm_sales_details
		from 'C:\Users\Adith\Desktop\rvu-adITH\MBA - AIDS\My Learning\SQL\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print 'load duration ' + cast(datediff(second, @start_time,@end_time)as nvarchar) + ' seconds';

		print '----------------------------------------------------------------------------------------';
		print('loading the ERP Tables');
		print '----------------------------------------------------------------------------------------';

		-- erp_cust_az12--
		set @start_time = GETDATE();
		truncate table bronze.erp_CUST_AZ12;
		bulk insert bronze.erp_CUST_AZ12
		from 'C:\Users\Adith\Desktop\rvu-adITH\MBA - AIDS\My Learning\SQL\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		with(firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print 'load duration ' + cast(datediff(second, @start_time,@end_time)as nvarchar) + ' seconds';

		-- erp_loc_a101--
		set @start_time = GETDATE();
		truncate table bronze.erp_LOC_A101;
		bulk insert bronze.erp_LOC_A101
		from 'C:\Users\Adith\Desktop\rvu-adITH\MBA - AIDS\My Learning\SQL\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		with(firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print 'load duration ' + cast(datediff(second, @start_time,@end_time)as nvarchar) + ' seconds';

		-- erp_loc_a101--
		set @start_time = GETDATE();
		truncate table bronze.erp_PX_CAT_G1V2;
		bulk insert bronze.erp_PX_CAT_G1V2
		from 'C:\Users\Adith\Desktop\rvu-adITH\MBA - AIDS\My Learning\SQL\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		with(firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print 'load duration ' + cast(datediff(second, @start_time,@end_time)as nvarchar) + ' seconds';
	end try
	begin catch
	print'================================================================================='
	print 'error occured during loading the bronze layer';
	print 'Error Message'+ error_message();
	print 'Error Message'+ cast(error_number() as nvarchar);

	print'================================================================================='
	end catch
end
