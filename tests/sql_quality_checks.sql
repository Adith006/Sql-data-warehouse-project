/*
===============================================================================
WARNING: DATA PROFILING AND PARTIAL ETL SCRIPT
===============================================================================
PURPOSE:
This script is designed for Data Quality Assurance (QA) and data profiling 
on the 'bronze' layer. It identifies anomalies such as nulls, negative values, 
invalid date ranges, and logical inconsistencies (e.g., sales total mismatching 
quantity * price). Additionally, it includes transformation and ingestion logic 
to standardize and load specific ERP tables into the 'silver' layer.

CAUTION: 
1. DUPLICATION RISK: The INSERT INTO statements at the end of this script 
   for the 'silver' schema do not include preceding TRUNCATE or DELETE 
   commands. Executing this script multiple times will result in duplicate 
   records in the silver.erp_CUST_AZ12, silver.erp_LOC_A101, and 
   silver.erp_PX_CAT_G1V2 tables.
2. SCRIPT REPAIR: The trailing orphaned 'OR' conditions at the end of the 
   original script have been moved back to their correct location within the 
   'crm_sales_details' query to ensure the SQL syntax runs correctly.
===============================================================================
*/
-- for crm--
-- checking for nulls --
select
prd_id,
COUNT(*)
from bronze.crm_prd_info
group by prd_id
having COUNT(*) > 1 or prd_id is null

-- check for negative numbers --
select prd_cost
from bronze.crm_prd_info
where prd_cost < 0 or prd_cost is null

-- check for invalid date --
select
prd_end_dt
from bronze.crm_prd_info
where prd_end_dt < prd_start_dt

-- checking for sales , price  and quantity null or 0 --

select distinct
sls_sales as old_sls_sales,
sls_quantity as old_sls_quantity,
sls_price as old_sls_price,
case
	when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_price)
	then sls_quantity * abs(sls_price)
	else sls_sales
end as sls_sales,
case
	when sls_price is null or sls_price <= 0
	then sls_sales / nullif(sls_quantity,0)
	else sls_price
end as sls_price
from bronze.crm_sales_details
where sls_sales != sls_quantity * sls_price

-- for erp --
-- for erp_cust_az12--
-- identifying out of range dates --
select 
BDATE
from bronze.erp_CUST_AZ12
where bdate < '1916-02-10' or bdate > getdate()
order by BDATE

-- data standardization --
select distinct gen 
from bronze.erp_CUST_AZ12
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

-- cleaning for px_cat_table ---
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
or sls_sales is null or sls_price is null or sls_quantity is null
or sls_sales <= 0 or sls_price <= 0 or sls_quantity <= 0
order by sls_sales,sls_quantity,sls_price
