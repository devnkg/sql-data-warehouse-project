/*
===============================================================================
DDL Script: Create Gold Views (Snowflake Compatible)
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema).

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready analytical model.

Usage:
    - These views can be queried directly for analytics and BI dashboards.
===============================================================================
*/

USE ROLE ACCOUNTADMIN;
USE DATABASE DATAWAREHOUSE;
USE SCHEMA GOLD;

-- =============================================================================
-- 1. Create Dimension: GOLD.DIM_CUSTOMERS
-- =============================================================================
CREATE OR REPLACE VIEW GOLD.DIM_CUSTOMERS AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key, -- Surrogate key
    ci.cst_id                              AS customer_id,  -- Source ID (Used to join with Sales)
    ci.cst_key                             AS customer_number,
    ci.cst_firstname                       AS first_name,
    ci.cst_lastname                        AS last_name,
    la.cntry                               AS country,
    ci.cst_marital_status                  AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is primary source for gender
        ELSE COALESCE(ca.gen, 'n/a')               -- Fallback to ERP data
    END                                    AS gender,
    ca.bdate                               AS birthdate,
    ci.cst_create_date                     AS create_date
FROM SILVER.CRM_CUST_INFO ci
LEFT JOIN SILVER.ERP_CUST_AZ12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN SILVER.ERP_LOC_A101 la
    ON ci.cst_key = la.cid;


-- =============================================================================
-- 2. Create Dimension: GOLD.DIM_PRODUCTS
-- =============================================================================
CREATE OR REPLACE VIEW GOLD.DIM_PRODUCTS AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- Surrogate key
    pn.prd_id                                                AS product_id,
    pn.prd_key                                               AS product_number, -- Natural key (Used to join with Sales)
    pn.prd_nm                                                AS product_name,
    pn.cat_id                                                AS category_id,
    pc.cat                                                   AS category,
    pc.subcat                                                AS subcategory,
    pc.maintenance                                           AS maintenance,
    pn.prd_cost                                              AS cost,
    pn.prd_line                                              AS product_line,
    pn.prd_start_dt                                          AS start_date
FROM SILVER.CRM_PRD_INFO pn
LEFT JOIN SILVER.ERP_PX_CAT_G1V2 pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL; -- Filter out historical/inactive records


-- =============================================================================
-- 3. Create Fact Table View: GOLD.FACT_SALES
-- =============================================================================
CREATE OR REPLACE VIEW GOLD.FACT_SALES AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key  AS product_key,  
    cu.customer_key AS customer_key, 
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM SILVER.CRM_SALES_DETAILS sd
LEFT JOIN GOLD.DIM_PRODUCTS pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN GOLD.DIM_CUSTOMERS cu
    ON sd.sls_cust_id = cu.customer_id;


-- =============================================================================
-- 4. Quality & Foreign Key Integrity Checks
-- =============================================================================

-- Both customer and product joins must return 0 rows (No Orphan Records)
SELECT *
FROM GOLD.FACT_SALES f
LEFT JOIN GOLD.DIM_CUSTOMERS c
    ON c.customer_key = f.customer_key
LEFT JOIN GOLD.DIM_PRODUCTS p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL;

