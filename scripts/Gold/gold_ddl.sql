/*
===============================================================================
WARNING: GOLD LAYER VIEW INITIALIZATION (STAR SCHEMA)
===============================================================================
PURPOSE:
This script initializes the 'gold' layer by creating Dimension and Fact views. 
These views represent the final, business-ready analytical layer of the 
Data Warehouse, transforming and joining the cleansed 'silver' data into a 
Star Schema format suitable for Business Intelligence (BI) reporting.

CAUTION:
1. VIEW DEPENDENCIES: These views depend on the existence of the underlying 
   tables in the 'silver' schema. If the silver tables are dropped or modified, 
   these views will become invalid.
2. DATA INTEGRITY: The views perform left joins to aggregate data from multiple 
   source systems (CRM and ERP). Ensure that the joining keys (e.g., customer IDs, 
   product keys) are consistent across layers; otherwise, you may observe 
   unexpected NULL values or partial records in your final reports.
3. RECREATION: If these views already exist, the 'CREATE OR ALTER' (or equivalent 
   drop/recreate logic) will overwrite existing view definitions. Ensure that 
   any dependent reports or BI dashboards are compatible with current logic.
===============================================================================
*/
-- building the gold layer dim --
-- for customer information --
Create view gold.dim_customers as
	select 
	ROW_NUMBER() over( order by cst_id) as customer_key,
	ci.cst_id as Customer_Id,
	ci.cst_key as Customer_Number,
	ci.cst_firstname as First_Name,
	ci.cst_lastname as Last_Name,
	la.CNTRY as Country,
	ci.cst_marital_status as Marital_Status,
		case 
		when ci.cst_gender != 'N/A' then ci.cst_gender -- crm is the master for gender info --
		else coalesce(ca.GEN,'N/A')
		end Gender,
	ca.BDATE as Birth_Date,
	ci.cst_create_date as Created_Date
	from silver.crm_cust_info ci
	left join silver.erp_CUST_AZ12 ca
	on ci.cst_key = ca.CID
	left join silver.erp_LOC_A101 la
	on ci.cst_key = la.CID

-- corrrecting the gender issue ---
-- building the gold layer dim --
	select distinct
	ci.cst_gender,
	ca.GEN,
	case 
		when ci.cst_gender != 'N/A' then ci.cst_gender -- crm is the master for gender info --
		else coalesce(ca.GEN,'N/A')
		end new_gen
	from silver.crm_cust_info ci
	left join silver.erp_CUST_AZ12 ca
	on ci.cst_key = ca.CID
	left join silver.erp_LOC_A101 la
	on ci.cst_key = la.CID
	order by 1,2

	select * from gold.dim_customers

--- for product information ---
create view gold.dim_products as
select
ROW_NUMBER() over(order by pn.prd_start_dt,pn.prd_key) as product_key,
pn.prd_id as product_id,
pn.prd_key as product_number,
pn.prd_nm as product_name,
pn.cat_id as category_id,
pc.CAT as category,
pc.SUBCAT as subcategory,
pc.MAINTENANCE as product_maintainance,
pn.prd_cost as product_cost,
pn.prd_line as product_line,
pn.prd_start_dt as product_startdate
from silver.crm_prd_info pn
left join silver.erp_PX_CAT_G1V2 pc
on pn.cat_id = pc.ID
where prd_end_dt is null -- filter out all historical products --

-- for sales information ---
create view gold.fact_sales as 
select
sa.sls_ord_num as order_number,
pr.product_key,
cu.customer_key,
sa.sls_order_dt as order_date,
sa.sls_ship_dt as ship_date,
sa.sls_due_dt as due_date,
sa.sls_sales as sales,
sa.sls_quantity as quantity,
sa.sls_price as price
from silver.crm_sales_details sa
left join gold.dim_products pr on
sa.sls_prd_key = pr.product_number
left join gold.dim_customers cu on
sa.sls_cust_id = cu.Customer_id



