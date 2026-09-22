# SQL Data Warehouse Project

A modern cloud data warehouse and analytics project built around the Medallion Architecture on Snowflake. This repository demonstrates how raw operational data from ERP and CRM sources can be ingested, cleaned, modeled, validated, and transformed into analytics-ready datasets for business reporting and decision-making.

## Overview

This project is designed as a portfolio-ready data engineering solution that covers the full data lifecycle:

- Ingest raw source files into a warehouse
- Build Bronze, Silver, and Gold layers
- Apply data quality checks and transformation rules
- Create star schema models for analytics
- Support reporting with SQL-based analysis

The repository combines data architecture, ETL process design, SQL development, and data quality governance in a practical end-to-end workflow.

## Business Problem

Organizations often work with multiple fragmented data sources such as ERP and CRM systems. These datasets are usually inconsistent, contain duplicates, missing values, and formatting issues. This project addresses those challenges by building a clean, governed, and query-optimized warehouse that supports analytical use cases.

## Architecture

The solution follows the Medallion Architecture pattern:

1. Bronze Layer
   - Stores raw data as it arrives from external systems
   - Preserves source fidelity and enables auditability
   - Used for ingestion and staging

2. Silver Layer
   - Cleanses, standardizes, and enriches data
   - Resolves duplicates, invalid values, and inconsistent formatting
   - Prepares data for downstream modeling

3. Gold Layer
   - Contains curated, analytics-ready tables and views
   - Structured around fact and dimension tables for reporting
   - Optimized for dashboarding and business analysis

![Data Architecture](docs/data_architecture.png)

## Key Features

- Snowflake-based data warehouse implementation
- Medallion architecture with Bronze, Silver, and Gold layers
- ETL/ELT process for ERP and CRM datasets
- Data cleaning and quality validation using SQL
- Dimensional modeling for analytical reporting
- SQL-driven quality checks for integrity and consistency
- Repository structured for easy extension and learning

## Tech Stack

- Snowflake Data Cloud
- SQL and Snowflake SQL Scripting
- Git and GitHub
- Draw.io for architecture and workflow design
- CSV-based source datasets

## Repository Structure

```text
sql-data-warehouse-project/
├── datasets/                          # Raw ERP and CRM source datasets
├── docs/                              # Architecture and project documentation
│   ├── data_architecture.drawio       # High-level warehouse architecture
│   ├── data_catalog.md                # Dataset metadata and field descriptions
│   ├── data_flow.drawio               # Pipeline flow diagram
│   ├── data_models.drawio             # Dimensional model design
│   └── naming-conventions.md         # SQL naming conventions
├── scripts/                           # SQL scripts for pipeline layers
│   ├── bronze/                        # Raw ingestion and staging logic
│   │   ├── ddl_bronze.sql             # Bronze table definitions
│   │   └── proc_load_bronze.sql       # Bronze load procedure
│   ├── silver/                        # Data cleansing and transformation
│   │   ├── ddl_silver.sql             # Silver table definitions
│   │   └── proc_load_silver.sql       # Silver ETL procedure
│   └── gold/                          # Analytical data models
│       ├── ddl_gold.sql               # Gold schema and tables
│       └── views_gold.sql             # Reporting views
├── tests/                             # Data validation and quality checks
│   ├── quality_checks_silver.sql      # Silver layer validation scripts
│   └── quality_checks_gold.sql        # Gold layer validation scripts
├── README.md                          # Project overview and usage guide
├── LICENSE                            # License information
├── .gitignore                         # Git ignore rules
└── docs/requirements.md               # Business and technical requirements
```

## Data Flow

The project follows a typical warehouse flow:

1. Raw CSV files are loaded into the Bronze layer.
2. Standardization and cleansing are performed in the Silver layer.
3. Business-ready models are built in the Gold layer.
4. Quality checks validate the integrity of the transformed data.
5. SQL queries support reporting and analytical insight generation.

## Data Quality and Governance

The repository includes validation scripts designed to protect warehouse integrity by checking:

- Duplicate records
- Null or missing values
- Referential integrity
- Surrogate key uniqueness
- Invalid or inconsistent values
- Date and domain validation

These checks help ensure that data is reliable before it is used in downstream reporting.

## Example Use Cases

This project supports common business intelligence and analytics scenarios such as:

- Customer segmentation
- Product performance analysis
- Sales trend monitoring
- Retention and cohort analysis
- Operational KPI reporting

## Setup and Prerequisites

To use this project, you need:

- Snowflake account access
- SQL client or Snowflake worksheet access
- Source CSV files in the `datasets/` folder
- Basic knowledge of SQL and warehouse design

## Run the Pipeline

1. Create the required Snowflake database and schema structure.
2. Load raw datasets into the Bronze layer.
3. Run the Silver layer transformation procedures.
4. Execute Gold layer DDL and reporting views.
5. Run quality checks to validate the final data.

## Project Goals

This repository aims to provide a clear, practical example of how to:

- structure a cloud data warehouse
- build incremental ETL logic in SQL
- implement medallion architecture
- apply quality checks in production-like workflows
- create a portfolio-ready analytics data platform

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contributing

Contributions, improvements, and suggestions are welcome. If you want to extend the project, consider adding:

- additional source systems
- automation with tasks and procedures
- dashboarding examples
- documentation for the ETL process
- more advanced data quality tests

## Final Note

This project is a practical demonstration of building a robust, modern data warehouse using Snowflake and SQL. It is especially useful for learning data engineering concepts, portfolio projects, and warehouse design patterns in real-world scenarios.
