
/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
Actions Performed:
    - Truncates Silver tables.
    - Inserts transformed and cleansed data from Bronze into Silver tables.
    - Logs execution messages, step durations, total batch duration, and handles errors.
    
Parameters:
    None.
    
Usage Example:
    CALL silver.load_silver();
===============================================================================
*/

USE ROLE ACCOUNTADMIN;
USE DATABASE DATAWAREHOUSE;
USE SCHEMA SILVER;

CREATE OR REPLACE PROCEDURE silver.load_silver()
RETURNS TABLE (messages VARCHAR)
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    batch_start_time TIMESTAMP_NTZ;
    batch_end_time   TIMESTAMP_NTZ;
    step_start_time  TIMESTAMP_NTZ;
    step_end_time    TIMESTAMP_NTZ;
    res RESULTSET;
BEGIN
    batch_start_time := CURRENT_TIMESTAMP();

    -- Temporary table to hold execution messages
    CREATE OR REPLACE TEMPORARY TABLE silver_execution_logs (
        step_id INT AUTOINCREMENT,
        log_message VARCHAR
    );

    INSERT INTO silver_execution_logs (log_message) VALUES ('================================================');
    INSERT INTO silver_execution_logs (log_message) VALUES ('Loading Silver Layer');
    INSERT INTO silver_execution_logs (log_message) VALUES ('================================================');

    -- ===============================================================================
    -- SECTION 1: CRM TABLES
    -- ===============================================================================
    INSERT INTO silver_execution_logs (log_message) VALUES ('------------------------------------------------');
    INSERT INTO silver_execution_logs (log_message) VALUES ('Loading CRM Tables');
    INSERT INTO silver_execution_logs (log_message) VALUES ('------------------------------------------------');

    -- 1.1 Loading silver.crm_cust_info
    step_start_time := CURRENT_TIMESTAMP();
    INSERT INTO silver_execution_logs (log_message) VALUES ('>> Truncating Table: silver.crm_cust_info');
    TRUNCATE TABLE silver.crm_cust_info;

    INSERT INTO silver_execution_logs (log_message) VALUES ('>> Inserting Data Into: silver.crm_cust_info');
    INSERT INTO silver.crm_cust_info (
        cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date
    )
    SELECT
        cst_id, 
        cst_key, 
        TRIM(cst_firstname), 
        TRIM(cst_lastname),
        CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
             WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married' 
             ELSE 'n/a' 
        END,
        CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
             WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male' 
             ELSE 'n/a' 
        END,
        cst_create_date
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    ) t 
    WHERE flag_last = 1;

    step_end_time := CURRENT_TIMESTAMP();
    INSERT INTO silver_execution_logs (log_message)
    SELECT '>> Load Duration: ' || DATEDIFF('second', :step_start_time, :step_end_time) || ' seconds';
    INSERT INTO silver_execution_logs (log_message) VALUES ('>> -------------');


    -- 1.2 Loading silver.crm_prd_info
    step_start_time := CURRENT_TIMESTAMP();
    INSERT INTO silver_execution_logs (log_message) VALUES ('>> Truncating Table: silver.crm_prd_info');
    TRUNCATE TABLE silver.crm_prd_info;

    INSERT INTO silver_execution_logs (log_message) VALUES ('>> Inserting Data Into: silver.crm_prd_info');
    INSERT INTO silver.crm_prd_info (
        prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
    )
    SELECT 
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
        SUBSTRING(prd_key, 7, LEN(prd_key)),
        TRIM(prd_nm),
        COALESCE(prd_cost, 0),
        CASE UPPER(TRIM(prd_line)) 
            WHEN 'M' THEN 'Mountain' 
            WHEN 'R' THEN 'Road' 
            WHEN 'S' THEN 'Other Sales' 
            WHEN 'T' THEN 'Touring' 
            ELSE 'n/a' 
        END,
        CAST(prd_start_dt AS DATE),
        CAST(LEAD(prd_start_dt) OVER (PARTITION BY SUBSTRING(prd_key, 7, LEN(prd_key)) ORDER BY prd_start_dt) - 1 AS DATE)
    FROM bronze.crm_prd_info;

    step_end_time := CURRENT_TIMESTAMP();
    INSERT INTO silver_execution_logs (log_message)
    SELECT '>> Load Duration: ' || DATEDIFF('second', :step_start_time, :step_end_time) || ' seconds';
    INSERT INTO silver_execution_logs (log_message) VALUES ('>> -------------');


    -- 1.3 Loading silver.crm_sales_details
    step_start_time := CURRENT_TIMESTAMP();
    INSERT INTO silver_execution_logs (log_message) VALUES ('>> Truncating Table: silver.crm_sales_details');
    TRUNCATE TABLE silver.crm_sales_details;

    INSERT INTO silver_execution_logs (log_message) VALUES ('>> Inserting Data Into: silver.crm_sales_details');
    INSERT INTO silver.crm_sales_details (
        sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
    )
    SELECT
        sls_ord_num, 
        sls_prd_key, 
        sls_cust_id,
        CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt::VARCHAR) != 8 THEN NULL 
             ELSE TO_DATE(sls_order_dt::VARCHAR, 'YYYYMMDD') 
        END,
        CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt::VARCHAR) != 8 THEN NULL 
             ELSE TO_DATE(sls_ship_dt::VARCHAR, 'YYYYMMDD') 
        END,
        CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt::VARCHAR) != 8 THEN NULL 
             ELSE TO_DATE(sls_due_dt::VARCHAR, 'YYYYMMDD') 
        END,
        CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
             THEN sls_quantity * ABS(sls_price) 
             ELSE sls_sales 
        END,
        sls_quantity,
        CASE WHEN sls_price IS NULL OR sls_price <= 0 
             THEN ROUND(sls_sales / NULLIF(sls_quantity, 0), 2) 
             ELSE ABS(sls_price) 
        END
    FROM bronze.crm_sales_details;

    step_end_time := CURRENT_TIMESTAMP();
    INSERT INTO silver_execution_logs (log_message)
    SELECT '>> Load Duration: ' || DATEDIFF('second', :step_start_time, :step_end_time) || ' seconds';
    INSERT INTO silver_execution_logs (log_message) VALUES ('>> -------------');


    -- ===============================================================================
    -- SECTION 2: ERP TABLES
    -- ===============================================================================
    INSERT INTO silver_execution_logs (log_message) VALUES ('------------------------------------------------');
    INSERT INTO silver_execution_logs (log_message) VALUES ('Loading ERP Tables');
    INSERT INTO silver_execution_logs (log_message) VALUES ('------------------------------------------------');

    -- 2.1 Loading silver.erp_cust_az12
    step_start_time := CURRENT_TIMESTAMP();
    INSERT INTO silver_execution_logs (log_message) VALUES ('>> Truncating Table: silver.erp_cust_az12');
    TRUNCATE TABLE silver.erp_cust_az12;

    INSERT INTO silver_execution_logs (log_message) VALUES ('>> Inserting Data Into: silver.erp_cust_az12');
    INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
    SELECT DISTINCT
        CASE WHEN cid LIKE 'NAS%' THEN SUBSTR(cid, 4) ELSE cid END,
        CASE WHEN CAST(bdate AS DATE) > CURRENT_DATE() OR CAST(bdate AS DATE) < '1920-01-01' THEN NULL 
             ELSE CAST(bdate AS DATE) 
        END,
        CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female' 
             WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male' 
             ELSE 'n/a' 
        END
    FROM bronze.erp_cust_az12;

    step_end_time := CURRENT_TIMESTAMP();
    INSERT INTO silver_execution_logs (log_message)
    SELECT '>> Load Duration: ' || DATEDIFF('second', :step_start_time, :step_end_time) || ' seconds';
    INSERT INTO silver_execution_logs (log_message) VALUES ('>> -------------');


    -- 2.2 Loading silver.erp_loc_a101
    step_start_time := CURRENT_TIMESTAMP();
    INSERT INTO silver_execution_logs (log_message) VALUES ('>> Truncating Table: silver.erp_loc_a101');
    TRUNCATE TABLE silver.erp_loc_a101;

    INSERT INTO silver_execution_logs (log_message) VALUES ('>> Inserting Data Into: silver.erp_loc_a101');
    INSERT INTO silver.erp_loc_a101 (cid, cntry)
    SELECT DISTINCT
        REPLACE(cid, '-', ''),
        CASE WHEN TRIM(cntry) = 'DE' THEN 'Bharat'
             WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
             WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
             ELSE TRIM(cntry) 
        END
    FROM bronze.erp_loc_a101;

    step_end_time := CURRENT_TIMESTAMP();
    INSERT INTO silver_execution_logs (log_message)
    SELECT '>> Load Duration: ' || DATEDIFF('second', :step_start_time, :step_end_time) || ' seconds';
    INSERT INTO silver_execution_logs (log_message) VALUES ('>> -------------');


    -- 2.3 Loading silver.erp_px_cat_g1v2
    step_start_time := CURRENT_TIMESTAMP();
    INSERT INTO silver_execution_logs (log_message) VALUES ('>> Truncating Table: silver.erp_px_cat_g1v2');
    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    INSERT INTO silver_execution_logs (log_message) VALUES ('>> Inserting Data Into: silver.erp_px_cat_g1v2');
    INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
    SELECT DISTINCT
        TRIM(id), 
        TRIM(cat), 
        TRIM(subcat), 
        TRIM(maintenance)
    FROM bronze.erp_px_cat_g1v2;

    step_end_time := CURRENT_TIMESTAMP();
    INSERT INTO silver_execution_logs (log_message)
    SELECT '>> Load Duration: ' || DATEDIFF('second', :step_start_time, :step_end_time) || ' seconds';
    INSERT INTO silver_execution_logs (log_message) VALUES ('>> -------------');


    -- Final Batch Duration
    batch_end_time := CURRENT_TIMESTAMP();
    INSERT INTO silver_execution_logs (log_message) VALUES ('================================================');
    INSERT INTO silver_execution_logs (log_message) VALUES ('Loading Silver Layer Completed');
    INSERT INTO silver_execution_logs (log_message)
    SELECT ' - Total Load Duration: ' || DATEDIFF('second', :batch_start_time, :batch_end_time) || ' seconds';
    INSERT INTO silver_execution_logs (log_message) VALUES ('================================================');

    res := (SELECT log_message AS messages FROM silver_execution_logs ORDER BY step_id);
    RETURN TABLE(res);

-- Error Handling
EXCEPTION
    WHEN OTHER THEN
        INSERT INTO silver_execution_logs (log_message) VALUES ('================================================');
        INSERT INTO silver_execution_logs (log_message) VALUES ('ERROR OCCURRED DURING LOADING SILVER LAYER');
        INSERT INTO silver_execution_logs (log_message)
        SELECT 'Error Code: ' || :sqlcode::VARCHAR;
        INSERT INTO silver_execution_logs (log_message)
        SELECT 'Error State: ' || :sqlstate;
        INSERT INTO silver_execution_logs (log_message)
        SELECT 'Error Message: ' || :sqlerrm;
        INSERT INTO silver_execution_logs (log_message) VALUES ('================================================');
        res := (SELECT log_message AS messages FROM silver_execution_logs ORDER BY step_id);
        RETURN TABLE(res);
END;
$$;

CALL SILVER.LOAD_SILVER();

