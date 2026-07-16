# **Data Warehouse: Gold Layer Documentation** 

## **Project Brief** 

The Gold Layer is the final, business-ready stage of the Data Warehouse. It consolidates transformed and cleansed data from the CRM and ERP source systems into optimized star-schema structures, enabling reliable business intelligence and reporting. 

## **Purpose** 

This documentation defines the structure and business logic for the dimension and fact tables, providing a clear reference for stakeholders and developers to understand the entities and transactional metrics available for analysis. 

## **1. View: gold.dim_customers** 

**Description:** A consolidated customer dimension view that integrates CRM demographics with ERP location and birthdate records. 

|Column Name|Data Type|Meaning|
|---|---|---|
|customer_key|BIGINT|Surrogate key for the customer<br>record.|
|Customer_Id|INT|Unique identifier from the<br>source CRM.|
|Customer_Number|NVARCHAR|Business-level unique key for<br>the customer.|
|First_Name|NVARCHAR|Customer’s first name.|
|Last_Name|NVARCHAR|Customer’s last name.|
|Country|NVARCHAR|Country of residence (sourced<br>from ERP).|
|Marital_Status|NVARCHAR|Marital status (e.g., Single,<br>Married).|
|Gender|NVARCHAR|Standardized gender<br>information.|
|Birth_Date|DATE|Date of birth (sourced from<br>ERP).|
|Created_Date|DATE|Record creation date in the<br>system.|



## **2. View: gold.dim_products** 

**Description:** A comprehensive product catalog view, enriching basic CRM product info with ERP-sourced category and subcategory hierarchies. 

|Column Name|Data Type|Meaning|
|---|---|---|
|product_key|BIGINT|Surrogate key for the product<br>record.|
|product_id|INT|Unique ID from the source<br>CRM.|
|product_number|NVARCHAR|Business-level product<br>SKU/Key.|
|product_name|NVARCHAR|The name of theproduct.|
|category_id|NVARCHAR|Identifier linking the product to<br>its category.|
|category|NVARCHAR|High-levelproduct category.|
|subcategory|NVARCHAR|Specific sub-classification of<br>theproduct.|
|product_maintainance|NVARCHAR|Maintenance status/level of the<br>product.|
|productcost|INT|<br>Unit cost of theproduct.|
|_<br>product_line|NVARCHAR|The product line (e.g.,<br>Mountain, Road).|
|product_startdate|DATETIME|<br>The date the product became<br>available.|



## **3. View: gold.fact_sales** 

**Description:** The central transactional fact table linking product and customer dimensions to actual sales events. 

|Column Name|Data Type|Meaning|
|---|---|---|
|order_number|NVARCHAR|Unique identifier for the sales<br>order.|
|product_key|BIGINT|Foreign key linking to<br>gold.dim_products.|
|customer_key|BIGINT|Foreign key linking to<br>gold.dim_customers.|
|order_date|DATE|Date the order wasplaced.|
|ship_date|DATE|Date the items were shipped.|
|due_date|DATE|Due date forpayment.|
|sales|INT|Total sales revenue for the line<br>item.|
|quantity|INT|Number of itemspurchased.|
|price|INT|Priceper unit of the item.|



## **Conclusion** 

These views provide a scalable and performant foundation for organizational reporting. By standardizing fields and establishing clear relationships between facts and dimensions, this architecture ensures stakeholders can perform accurate, data-driven analysis. 

