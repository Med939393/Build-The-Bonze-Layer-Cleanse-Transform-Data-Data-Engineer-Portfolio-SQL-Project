

CREATE TABLE crm_cust_info (
    cst_id              INT,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status  VARCHAR(50),
    cst_gndr            VARCHAR(50),
    cst_create_date     DATE
);

CREATE TABLE crm_prd_info (
    prd_id       INT,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     INT,
    prd_line     VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE
);

CREATE TABLE crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);

CREATE TABLE erp_loc_a101 (
    cid    VARCHAR(50),
    cntry  VARCHAR(50)
);

CREATE TABLE erp_cust_az12 (
    cid    VARCHAR(50),
    bdate  DATE,
    gen    VARCHAR(50)
);

CREATE TABLE erp_px_cat_g1v2 (
    id           VARCHAR(50),
    cat          VARCHAR(50),
    subcat       VARCHAR(50),
    maintenance  VARCHAR(50)
);

--check for nulls or duplicates in primery key 
-- expectation no result 

select cst_id ,count(*) from crm_cust_info group by 1 having count(*) > 1 or cst_id is NULL
select * from crm_cust_info where cst_id = 29466

with cte as ( select * ,row_number () over  (partition by  cst_id order by cst_create_date DESC  ) as rn from crm_cust_info )

select * from cte where rn != 1 

--check for unwanted spaces 
--expectation no result 

select trim(cst_firstname) ,trim(cst_lastname) from crm_cust_info

select cst_firstname from crm_cust_info where cst_firstname != trim(cst_firstname) 

select cst_lastname from crm_cust_info where cst_lastname != trim(cst_lastname) 

select cst_gndr from crm_cust_info where cst_gndr != trim(cst_gndr)

--data standarization & consistency
select cst_id, cst_key

, trim(cst_firstname) as cst_firstname , trim(cst_lastname) as cst_lastname,

case when upper(trim(cst_marital_status)) ='M' then 'Married'
     when upper (trim(cst_marital_status)) ='S' then 'Single'
     else 'n\a' 
end as cst_marital_status ,

case when upper(trim(cst_gndr)) ='M' then 'Male'
     when upper(trim(cst_gndr)) ='F' then 'Female'
     else 'n\a' 
end as cst_gndr , cst_create_date
from (with cte as ( select * ,row_number () over  (partition by  cst_id order by cst_create_date DESC  ) as rn from crm_cust_info )

select * from cte where rn = 1 )

--

select * from crm_prd_info
select prd_id , count(*) from crm_prd_info group by 1 having  count(*) > 1 or prd_id is null

select * from crm_prd_info
--
select prd_id ,replace (substring(prd_key,1,5),'-','_' ) as cat_id ,
replace (substring(prd_key,7,length(prd_key)),'-','_' ) as prd_key,prd_nm,COALESCE(prd_cost, 0) AS prd_cost,

case  UPPER(TRIM(prd_line))
     when   'M' then 'Mountain'
     when   'R' then 'Road' 
	 when   'S' then 'Other Sales'
	 when  'T' then 'Touring'
	 ELSE 'n/a'
end as prd_line	,prd_start_dt,lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as prd_end_dt

from crm_prd_info

--
SELECT sls_ord_num, sls_prd_key, sls_cust_id,
       CASE 
           WHEN sls_order_dt = 0 OR LENGTH(CAST(sls_order_dt AS TEXT)) != 8 THEN NULL
           ELSE TO_DATE(CAST(sls_order_dt AS TEXT), 'YYYYMMDD')
       END AS sls_order_dt,
       sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
FROM crm_sales_details;
--

select distinct  sls_quantity ,
case when sls_sales is null or sls_sales  <= 0 or sls_sales != sls_quantity * ABS(sls_price)
     then sls_quantity * ABS(sls_price)
	 else sls_sales
END as sls_sales,

case when sls_price is NUll or sls_price <= 0
     then sls_sales  / NULLIF(sls_quantity ,0)
end as sls_price
from crm_sales_details where sls_sales != sls_quantity * sls_price

OR sls_sales  is NULL or sls_quantity is NULL  or sls_price is NULL
OR sls_sales  <= 0  or sls_quantity <= 0   or sls_price <=0
order by 1,2,3
--
select  
case when cid like 'NAS%' then substring (cid,4,length(cid))
     else cid
end as cid,

case when bdate > CURRENT_DATE then NULL
     else bdate 
end as bdate ,
case when upper(trim(gen)) in  ('M' , 'MALE' ) then 'Male'
     when upper(trim(gen)) in  ('F' , 'FEMALE' ) then 'Female'
     else 'n\a' 
end as gen
from erp_cust_az12 
--
select*, replace (cid,'-' , '') as cid from erp_loc_a101

select distinct cntry from erp_loc_a101 order by 1

select case when trim(cntry) = 'DE' then 'Germany'
     when trim(cntry) = 'US' or cntry = 'USA' then 'United States'
	 when trim(cntry) = '' or cntry is NULL then 'n/a'
     else trim(cntry)
end as cntry from erp_loc_a101 

--check for unwanted spaces 
--expectation no result 
select * from erp_px_cat_g1v2






