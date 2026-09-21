/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'BRONZE' schema from internal stage CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data to ensure idempotency.
    - Uses the 'COPY INTO' command to bulk load data from stage files to bronze tables.
    - Computes and logs the ingestion duration for each table and total batch execution.
    - Implements exception handling to gracefully capture and report runtime failures.

Parameters:
    None.
    This stored procedure does not accept any input parameters.

Returns:
    VARCHAR: Formatted execution status summary with load durations.

Usage Example:
    CALL BRONZE.LOAD_BRONZE();
===============================================================================
*/

USE ROLE ACCOUNTADMIN;
USE DATABASE DATAWAREHOUSE;
USE SCHEMA BRONZE;

CREATE OR REPLACE PROCEDURE BRONZE.LOAD_BRONZE()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
DECLARE
    log_msg VARCHAR DEFAULT '';
    batch_start TIMESTAMP_NTZ;
    batch_end TIMESTAMP_NTZ;
    t_start TIMESTAMP_NTZ;
    t_end TIMESTAMP_NTZ;
    duration_ms INT;
BEGIN
    batch_start := CURRENT_TIMESTAMP();
    
    log_msg := log_msg || '==================================================\n';
    log_msg := log_msg || 'STARTING BRONZE LAYER INGESTION\n';
    log_msg := log_msg || 'Start Time: ' || TO_VARCHAR(batch_start, 'YYYY-MM-DD HH24:MI:SS') || '\n';
    log_msg := log_msg || '==================================================\n\n';

    -- =============================================================
    -- CRM TABLES
    -- =============================================================
    log_msg := log_msg || '--------------------------------------------------\n';
    log_msg := log_msg || 'Loading CRM Tables...\n';
    log_msg := log_msg || '--------------------------------------------------\n';

    -- 1. CRM Customer Info
    t_start := CURRENT_TIMESTAMP();
    TRUNCATE TABLE BRONZE.CRM_CUST_INFO;
    COPY INTO BRONZE.CRM_CUST_INFO
    FROM @bronze_stage/cust_info.csv
    FILE_FORMAT = (FORMAT_NAME = csv_load_format)
    ON_ERROR = 'CONTINUE';
    t_end := CURRENT_TIMESTAMP();
    duration_ms := DATEDIFF('millisecond', t_start, t_end);
    log_msg := log_msg || '>> CRM_CUST_INFO loaded in: ' || (duration_ms / 1000.0)::VARCHAR || ' seconds.\n';

    -- 2. CRM Product Info
    t_start := CURRENT_TIMESTAMP();
    TRUNCATE TABLE BRONZE.CRM_PRD_INFO;
    COPY INTO BRONZE.CRM_PRD_INFO
    FROM @bronze_stage/prd_info.csv
    FILE_FORMAT = (FORMAT_NAME = csv_load_format)
    ON_ERROR = 'CONTINUE';
    t_end := CURRENT_TIMESTAMP();
    duration_ms := DATEDIFF('millisecond', t_start, t_end);
    log_msg := log_msg || '>> CRM_PRD_INFO loaded in: ' || (duration_ms / 1000.0)::VARCHAR || ' seconds.\n';

    -- 3. CRM Sales Details
    t_start := CURRENT_TIMESTAMP();
    TRUNCATE TABLE BRONZE.CRM_SALES_DETAILS;
    COPY INTO BRONZE.CRM_SALES_DETAILS
    FROM @bronze_stage/sales_details.csv
    FILE_FORMAT = (FORMAT_NAME = csv_load_format)
    ON_ERROR = 'CONTINUE';
    t_end := CURRENT_TIMESTAMP();
    duration_ms := DATEDIFF('millisecond', t_start, t_end);
    log_msg := log_msg || '>> CRM_SALES_DETAILS loaded in: ' || (duration_ms / 1000.0)::VARCHAR || ' seconds.\n\n';

    -- =============================================================
    -- ERP TABLES
    -- =============================================================
    log_msg := log_msg || '--------------------------------------------------\n';
    log_msg := log_msg || 'Loading ERP Tables...\n';
    log_msg := log_msg || '--------------------------------------------------\n';

    -- 4. ERP Customer Demographics
    t_start := CURRENT_TIMESTAMP();
    TRUNCATE TABLE BRONZE.ERP_CUST_AZ12;
    COPY INTO BRONZE.ERP_CUST_AZ12
    FROM @bronze_stage/CUST_AZ12.csv
    FILE_FORMAT = (FORMAT_NAME = csv_load_format)
    ON_ERROR = 'CONTINUE';
    t_end := CURRENT_TIMESTAMP();
    duration_ms := DATEDIFF('millisecond', t_start, t_end);
    log_msg := log_msg || '>> ERP_CUST_AZ12 loaded in: ' || (duration_ms / 1000.0)::VARCHAR || ' seconds.\n';

    -- 5. ERP Location
    t_start := CURRENT_TIMESTAMP();
    TRUNCATE TABLE BRONZE.ERP_LOC_A101;
    COPY INTO BRONZE.ERP_LOC_A101
    FROM @bronze_stage/LOC_A101.csv
    FILE_FORMAT = (FORMAT_NAME = csv_load_format)
    ON_ERROR = 'CONTINUE';
    t_end := CURRENT_TIMESTAMP();
    duration_ms := DATEDIFF('millisecond', t_start, t_end);
    log_msg := log_msg || '>> ERP_LOC_A101 loaded in: ' || (duration_ms / 1000.0)::VARCHAR || ' seconds.\n';

    -- 6. ERP Product Category
    t_start := CURRENT_TIMESTAMP();
    TRUNCATE TABLE BRONZE.ERP_PX_CAT_G1V2;
    COPY INTO BRONZE.ERP_PX_CAT_G1V2
    FROM @bronze_stage/PX_CAT_G1V2.csv
    FILE_FORMAT = (FORMAT_NAME = csv_load_format)
    ON_ERROR = 'CONTINUE';
    t_end := CURRENT_TIMESTAMP();
    duration_ms := DATEDIFF('millisecond', t_start, t_end);
    log_msg := log_msg || '>> ERP_PX_CAT_G1V2 loaded in: ' || (duration_ms / 1000.0)::VARCHAR || ' seconds.\n\n';

    -- Total Batch Duration
    batch_end := CURRENT_TIMESTAMP();
    duration_ms := DATEDIFF('millisecond', batch_start, batch_end);
    log_msg := log_msg || '==================================================\n';
    log_msg := log_msg || 'SUCCESS: All Bronze Tables Ingested!\n';
    log_msg := log_msg || 'Total Duration: ' || (duration_ms / 1000.0)::VARCHAR || ' seconds.\n';
    log_msg := log_msg || '==================================================\n';

    RETURN log_msg;

EXCEPTION
    WHEN OTHER THEN
        batch_end := CURRENT_TIMESTAMP();
        duration_ms := DATEDIFF('millisecond', batch_start, batch_end);
        
        log_msg := log_msg || '\n==================================================\n';
        log_msg := log_msg || 'ERROR OCCURRED DURING INGESTION!\n';
        log_msg := log_msg || 'Failed After: ' || (duration_ms / 1000.0)::VARCHAR || ' seconds.\n';
        log_msg := log_msg || 'Error Code: ' || SQLCODE || '\n';
        log_msg := log_msg || 'Error State: ' || SQLSTATE || '\n';
        log_msg := log_msg || 'Error Message: ' || SQLERRM || '\n';
        log_msg := log_msg || '==================================================\n';
        
        RETURN log_msg;
END;
$$;

-- Execution Command:
-- CALL BRONZE.LOAD_BRONZE();
