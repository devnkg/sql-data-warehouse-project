
/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
    Run this script to re-define the DDL structure of 'silver' Tables.
===============================================================================
*/

USE ROLE ACCOUNTADMIN;
USE DATABASE DATAWAREHOUSE;
USE SCHEMA SILVER;

-- ===============================================================================
-- 1. CRM Tables
-- ===============================================================================

-- Customer Info Table
CREATE OR REPLACE TABLE SILVER.CRM_CUST_INFO (
    cst_id             INT,
    cst_key            VARCHAR(50),
    cst_firstname      VARCHAR(50),
    cst_lastname       VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr           VARCHAR(50),
    cst_create_date    DATE,
    dwh_create_date    TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Product Info Table
CREATE OR REPLACE TABLE SILVER.CRM_PRD_INFO (
    prd_id          INT,
    cat_id          VARCHAR(50),
    prd_key         VARCHAR(50),
    prd_nm          VARCHAR(50),
    prd_cost        INT,
    prd_line        VARCHAR(50),
    prd_start_dt    DATE,
    prd_end_dt      DATE,
    dwh_create_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Sales Details Table
CREATE OR REPLACE TABLE SILVER.CRM_SALES_DETAILS (
    sls_ord_num     VARCHAR(50),
    sls_prd_key     VARCHAR(50),
    sls_cust_id     INT,
    sls_order_dt    DATE,
    sls_ship_dt     DATE,
    sls_due_dt      DATE,
    sls_sales       NUMBER(10, 2),
    sls_quantity    INT,
    sls_price       NUMBER(10, 2),
    dwh_create_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ===============================================================================
-- 2. ERP Tables
-- ===============================================================================

-- ERP Customer Demographics Table
CREATE OR REPLACE TABLE SILVER.ERP_CUST_AZ12 (
    cid             VARCHAR(50),
    bdate           DATE,
    gen             VARCHAR(50),
    dwh_create_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ERP Customer Location Table
CREATE OR REPLACE TABLE SILVER.ERP_LOC_A101 (
    cid             VARCHAR(50),
    cntry           VARCHAR(50),
    dwh_create_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ERP Product Category Table
CREATE OR REPLACE TABLE SILVER.ERP_PX_CAT_G1V2 (
    id              VARCHAR(50),
    cat             VARCHAR(50),
    subcat          VARCHAR(50),
    maintenance     VARCHAR(50),
    dwh_create_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ===============================================================================
-- Verification
-- ===============================================================================
SHOW TABLES IN SCHEMA SILVER;
