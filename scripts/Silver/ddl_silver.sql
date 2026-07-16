/*
===============================================================================
WARNING: DESTRUCTIVE TABLE SCHEMA RESET (SILVER LAYER)
===============================================================================
PURPOSE:
This script initializes the 'silver' schema by dropping and recreating all 
required tables. This layer serves as the transformed and cleansed data 
repository in the data warehouse, incorporating audit metadata (dwh_create_date) 
to track data ingestion timestamps.

CAUTION: 
Executing this script will PERMANENTLY DROP all existing tables within 
the 'silver' schema, including:
- silver.crm_cust_info
- silver.crm_prd_info
- silver.crm_sales_details
- silver.erp_CUST_AZ12
- silver.erp_LOC_A101
- silver.erp_PX_CAT_G1V2

All transformed data currently stored in these tables will be permanently 
deleted. Ensure you have backed up any necessary data before executing 
this script, as the 'DROP TABLE' operation cannot be undone.
===============================================================================
*/
-- data ingestion in silver layer --

--T-sql statement to replace tables--
if OBJECT_ID('silver.crm_cust_info','U') is not null
	drop table silver.crm_cust_info;
--CRM Layer--
--table for customers --
create table silver.crm_cust_info(
	cst_id int,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_marital_status nvarchar(50),
	cst_gender nvarchar(50),
	cst_create_date date,
	dwh_create_date datetime2 default getdate()
);
--T-sql statement to replace tables--
if OBJECT_ID('silver.crm_prd_info','U') is not null
	drop table silver.crm_prd_info;
-- table for products --
create table silver.crm_prd_info(
	prd_id int,
	cat_id nvarchar(50),
	prd_key nvarchar(50),
	prd_nm nvarchar(50),
	prd_cost int,
	prd_line nvarchar(10),
	prd_start_dt date,
	prd_end_dt date,
	dwh_create_date datetime2 default getdate()
);
--T-sql statement to replace tables--
if OBJECT_ID('silver.crm_sales_details','U') is not null
	drop table silver.crm_sales_details;
-- table for sales details --
create table silver.crm_sales_details(
	sls_ord_num nvarchar(50),
	sls_prd_key nvarchar(50),
	sls_cust_id int,
	sls_order_dt date,
	sls_ship_dt date,
	sls_due_dt date,
	sls_sales int,
	sls_quantity int,
	sls_price int,
	dwh_create_date datetime2 default getdate()
);
--T-sql statement to replace tables--
if OBJECT_ID('silver.erp_CUST_AZ12','U') is not null
	drop table silver.erp_CUST_AZ12;
-- table for ERP  layer --
--for CUST_AZ12
create table silver.erp_CUST_AZ12(
	CID nvarchar(50),
	BDATE date,
	GEN nvarchar(50),
	dwh_create_date datetime2 default getdate()
);
--T-sql statement to replace tables--
if OBJECT_ID('silver.erp_LOC_A101','U') is not null
	drop table silver.erp_LOC_A101;
-- for LOC_A101 --
create table silver.erp_LOC_A101(
	CID nvarchar(50),
	CNTRY nvarchar(50),
	dwh_create_date datetime2 default getdate()
);
--T-sql statement to replace tables--
if OBJECT_ID('silver.erp_PX_CAT_G1V2','U') is not null
	drop table silver.erp_PX_CAT_G1V2;
--for PX_CAT_G1V2 --
create table silver.erp_PX_CAT_G1V2(
	ID nvarchar(50),
	CAT nvarchar(50),
	SUBCAT nvarchar(50),
	MAINTENANCE nvarchar(50),
	dwh_create_date datetime2 default getdate()
);


