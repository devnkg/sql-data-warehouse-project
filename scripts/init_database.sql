/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

-- 1. Set role and compute warehouse context
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

-- 2. Drop and recreate the 'DataWarehouse' database
-- Snowflake's CREATE OR REPLACE syntax handles dropping and recreating cleanly without locks
CREATE OR REPLACE DATABASE DataWarehouse;

-- 3. Set the active database
USE DATABASE DataWarehouse;

-- 4. Create the medallion architecture schemas
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
