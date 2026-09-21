/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'BRONZE' schema for Snowflake, dropping 
    existing tables if they already exist.
    Run this script to re-define the DDL structure of 'BRONZE' Tables.
===============================================================================
*/

USE ROLE ACCOUNTADMIN;
USE DATABASE DATAWAREHOUSE;
USE SCHEMA BRONZE;

-- ===============================================================================
-- 1. CRM Tables
-- ===============================================================================

-- Customer Info Table
CREATE OR REPLACE TABLE BRONZE.CRM_CUST_INFO (
    cst_id              INT,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_material_status VARCHAR(50),
    cst_gndr            VARCHAR(50),
    cst_create_date     DATE
);

-- Product Info Table
CREATE OR REPLACE TABLE BRONZE.CRM_PRD_INFO (
    prd_id       INT,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     NUMBER(10, 2),
    prd_line     VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE
);

-- Sales Details Table
CREATE OR REPLACE TABLE BRONZE.CRM_SALES_DETAILS (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    NUMBER(10, 2),
    sls_quantity INT,
    sls_price    NUMBER(10, 2)
);

-- ===============================================================================
-- 2. ERP Tables
-- ===============================================================================

-- ERP Customer Demographics Table
CREATE OR REPLACE TABLE BRONZE.ERP_CUST_AZ12 (
    cid   VARCHAR(50),
    bdate DATE,
    gen   VARCHAR(50)
);

-- ERP Customer Location Table
CREATE OR REPLACE TABLE BRONZE.ERP_LOC_A101 (
    cid   VARCHAR(50),
    cntry VARCHAR(50)
);

-- ERP Product Category Table
CREATE OR REPLACE TABLE BRONZE.ERP_PX_CAT_G1V2 (
    id          VARCHAR(50),
    cat         VARCHAR(50),
    subcat      VARCHAR(50),
    maintenance VARCHAR(50)
);

-- ===============================================================================
-- Verification
-- ===============================================================================
SHOW TABLES IN SCHEMA BRONZE;
