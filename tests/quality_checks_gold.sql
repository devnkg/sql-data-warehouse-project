/*
===============================================================================
Quality Checks (Snowflake Gold Layer)
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

USE ROLE ACCOUNTADMIN;
USE DATABASE DATAWAREHOUSE;
USE SCHEMA GOLD;

-- ====================================================================
-- Checking 'GOLD.DIM_CUSTOMERS'
-- ====================================================================
-- Check for Uniqueness of Customer Key in GOLD.DIM_CUSTOMERS
-- Expectation: 0 rows (No duplicates)
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM GOLD.DIM_CUSTOMERS
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- ====================================================================
-- Checking 'GOLD.DIM_PRODUCTS'
-- ====================================================================
-- Check for Uniqueness of Product Key in GOLD.DIM_PRODUCTS
-- Expectation: 0 rows (No duplicates)
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM GOLD.DIM_PRODUCTS
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ====================================================================
-- Checking 'GOLD.FACT_SALES'
-- ====================================================================
-- Check the data model connectivity between fact and dimensions (Referential Integrity)
-- Expectation: 0 rows (No orphan records)
SELECT * 
FROM GOLD.FACT_SALES f
LEFT JOIN GOLD.DIM_CUSTOMERS c
    ON c.customer_key = f.customer_key
LEFT JOIN GOLD.DIM_PRODUCTS p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL 
   OR c.customer_key IS NULL;
