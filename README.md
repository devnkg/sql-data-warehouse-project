
```markdown
# Modern Cloud Data Warehouse & Analytics Project (Snowflake)

Welcome to the **Modern Cloud Data Warehouse and Analytics Project** repository! 🚀  
This project demonstrates an enterprise-grade cloud data warehousing and analytics solution, implemented on **Snowflake Data Cloud** using the **Medallion Architecture**. It covers the complete lifecycle from raw data ingestion to automated ETL transformation pipelines, data quality verification, and analytical star schema modeling.

---
## 🏗️ Data Architecture

The architecture implements the modern **Medallion (Multi-Hop) Architecture** divided into **Bronze**, **Silver**, and **Gold** layers:

![Data Architecture](docs/data_architecture.png)

1. **Bronze Layer (Raw Ingestion)**: Ingests raw batch datasets as-is from source systems (ERP & CRM CSVs) into Snowflake staging tables without schema alteration.
2. **Silver Layer (Cleansing & Conformance)**: Cleanses, deduplicates (window functions), enriches, standardizes, and normalizes operational data using automated Snowflake Stored Procedures.
3. **Gold Layer (Analytical Modeling)**: Houses business-ready star schema models (dimension and fact tables/views) optimized for analytical reporting and BI dashboards.

---
## 📖 Project Overview

Key engineering deliverables implemented in this repository:

1. **Cloud Data Architecture**: Built on Snowflake using compute separation, virtual warehouses, and role-based access management (`ACCOUNTADMIN`).
2. **Automated ETL Pipelines**: Developed native Snowflake Scripting Stored Procedures (`SP_LOAD_BRONZE`, `SP_LOAD_SILVER`) with step-by-step console logging, runtime duration tracking, and robust exception handling.
3. **Data Quality & Governance**: Created automated SQL test suites covering primary key uniqueness, foreign key integrity, domain validations, string trimming, and date alignment.
4. **Dimensional Modeling**: Transformed normalized ERP and CRM transactional sources into star schema models (Facts and Dimensions) for high-performance querying.
5. **Business Intelligence & Analytics**: SQL analytics for customer segmentation, cohort behavior, product performance, and sales trend analysis.

---

## 🛠️ Tech Stack & Tools

- **Data Warehouse Engine**: [Snowflake Data Cloud](https://www.snowflake.com/) (Worksheets, SnowSQL, Virtual Warehouses)
- **Transformation & Procedures**: Snowflake SQL Scripting (`PROCEDURE`, `RESULTSET`, Window Functions)
- **Version Control**: Git & GitHub for database code management and CI/CD-readiness
- **Architecture & Modeling**: [Draw.io](https://www.drawio.com/) for data lineage, ER diagrams, and flowcharts
- **Documentation & Tracking**: [Notion](https://www.notion.com/) for sprint tasks and metadata cataloging
- **Datasets**: ERP and CRM operational data (CSV sources)

---

## 🚀 Engineering Highlights & Snowflake Modernization

- **Native SQL Scripting**: Re-architected legacy on-premise procedural SQL (T-SQL) into modular Snowflake Stored Procedures with execution metrics logging.
- **Data Cleansing Engine**:
  - Deduplicated customer master data utilizing `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ... DESC)`.
  - Standardized invalid dates, derived missing sales metrics, and handled schema edge cases (e.g., column standardizations like `cst_marital_status`).
  - Corrected legacy prefixes and unified regional identifiers across systems.
- **Automated Validation Suite**: Built dedicated SQL quality checks ensuring zero duplicates and referential integrity across Silver layers prior to Gold consumption.

---

## 📂 Repository Structure


```

sql-data-warehouse-project/
│
├── datasets/                           # Raw source datasets (ERP & CRM CSV files)
│
├── docs/                               # Project design documentation and diagrams
│   ├── data_architecture.drawio        # Visual diagrams of Medallion Architecture
│   ├── data_catalog.md                 # Table definitions, schemas, and metadata dictionary
│   ├── data_flow.drawio                # End-to-end data pipeline flow
│   ├── data_models.drawio              # Dimensional model & Star Schema design
│   └── naming-conventions.md           # Engineering guidelines for schemas, tables, and scripts
│
├── scripts/                            # Production SQL pipelines and DDLs
│   ├── bronze/                         # Raw ingestion scripts
│   │   ├── ddl_bronze.sql              # Raw staging table definitions
│   │   └── proc_load_bronze.sql        # Bronze ingestion procedure
│   ├── silver/                         # Transformation and cleansing layer
│   │   ├── ddl_silver.sql              # Cleansed Silver layer DDLs
│   │   └── proc_load_silver.sql        # Automated Silver ETL Stored Procedure
│   └── gold/                           # Dimensional layer
│       ├── ddl_gold.sql                # Star schema dimension and fact tables/views
│       └── views_gold.sql              # Analytical reporting views
│
├── tests/                              # Data governance & testing suites
│   ├── quality_checks_silver.sql       # Automated constraints, nulls, and duplicate checks
│   └── quality_checks_gold.sql         # Fact-dimension referential integrity tests
│
├── README.md                           # Project technical overview
├── LICENSE                             # MIT License
└── .gitignore                          # Git tracking exclusions

```

---

## 🛡️ License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and distribute this codebase for educational and portfolio purposes.

```
