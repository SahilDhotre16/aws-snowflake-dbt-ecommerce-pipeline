# E-commerce Analytics Pipeline — Snowflake + dbt

An end-to-end data engineering project that transforms raw e-commerce CSV data into analytics-ready datasets using **Snowflake, dbt Core, SQL, and a Medallion Architecture**.

The project demonstrates data ingestion, data cleaning, deduplication, dimensional modeling, data quality testing, Slowly Changing Dimensions (SCD Type 2), and business-focused analytics.

## Architecture

MongoDB Atlas + MongoDB Compass
            |
            v
AWS (DMS, S3, IAM)
            |
            v
Snowflake
            |
            v
STAGING
Raw data loaded using COPY INTO
            |
            v
BRONZE (DBT)
Raw data replication
            |
            v
SILVER
Cleaning, standardization,
deduplication and validation
            |
            v
GOLD
Dimensions, facts, OBT and marts
            |
            v
Analytics-ready datasets

dbt Snapshots --> SCD Type 2 historical tracking
```

## Tech Stack

- **Data Warehouse:** Snowflake
- **Transformation:** dbt Core, dbt-snowflake
- **Languages:** SQL, Jinja
- **Data Format:** CSV
- **Architecture:** Medallion Architecture
- **Data Modeling:** Star Schema, Fact and Dimension Tables
- **Data Quality:** dbt data tests
- **Historical Tracking:** dbt Snapshots, SCD Type 2
- **Development:** Python virtual environment managed with uv, VS Code
- **Version Control:** Git and GitHub

## Dataset

The project uses synthetic e-commerce data based on a theLook-style dataset.

| Source table | Rows |
|---|---:|
| Users | 99,999 |
| Orders | 125,225 |
| Order Items | 181,758 |
| Products | 29,119 |
| Inventory Items | 490,704 |
| Distribution Centers | 9 |

**Total source records:** 926,814

## Medallion Architecture

### 1. Staging Layer

- Loads source CSV files into Snowflake using `COPY INTO`.
- Preserves the source data for downstream processing.
- Provides the entry point for dbt transformations.

### 2. Bronze Layer

- Creates raw representations of the six source tables.
- Preserves source-level values without applying business cleaning.
- Validates that Bronze row counts match the source data.

### 3. Silver Layer

- Standardizes and cleans source data.
- Deduplicates records using their actual primary identifiers.
- Preserves records when shared email addresses do not indicate duplicate users.
- Maintains referential information for downstream transformations.

### 4. Gold Layer

Builds analytics-ready dimensions, facts, a wide table, and business marts.

**Dimension tables**
- `dim_customers`
- `dim_products`
- `dim_distribution_centers`
- `dim_date`

**Fact tables**
- `fact_order_items`
- `fact_orders`

**Analytics models**
- `gold_obt`
- `gold_monthly_sales_growth`
- `gold_customer_rfm`
- `gold_brand_cat_performance`

## Business Analytics

### Monthly Sales Growth
Analyzes monthly orders, net revenue, profit, profit margin, cancellation rates, return rates, month-over-month changes, and cumulative revenue using SQL window functions such as `LAG`.

### Customer RFM Segmentation
Uses Recency, Frequency, and Monetary metrics with `NTILE(5)` to score and segment customers.

### Brand and Category Performance
Analyzes revenue, profit margin, cancellation rates, and return rates by product brand and category, including brand rankings.

### Gold OBT
Creates a wide analytical table containing 34 columns and 181,758 rows, including profit, return and cancellation indicators, shipping duration, and delivery duration.

Net revenue and profit exclude cancelled and returned items. Cancellation and return rates are calculated against all ordered items.

## dbt Snapshots and SCD Type 2

The project uses dbt snapshots to maintain historical versions of records when tracked attributes change.

Snapshots:
- `dim_customers_snapshot`
- `dim_products_snapshot`
- `fct_orders_snapshot`

The snapshots use the `check` strategy to detect changes in configured columns and preserve historical versions using SCD Type 2.

## Data Quality and Challenges

The project includes investigation and handling of real-world data quality issues:

1. **Non-unique emails:** Multiple users share email addresses. Deduplication uses user IDs rather than email addresses to avoid deleting valid users.
2. **Misaligned order columns:** Incorrect column mapping was detected through null-count checks. The staging table was recreated and reloaded using the correct file-column order.
3. **Missing order dates:** Some shipping, delivery, and return date fields were absent from the source extract. Missing dates were not fabricated.
4. **Missing users:** Two orders reference users absent from the user source data.
5. **Missing orders:** Two order items reference a missing order. Left joins preserve these records for investigation.
6. **Missing distribution center:** Distribution center ID 8 is absent, although 2,919 products reference it. A placeholder dimension record is used with null coordinates.
7. **Invalid shipping intervals:** Negative shipping durations are set to null rather than treated as valid values.

Relationship tests for certain source-data anomalies are configured as warnings so the pipeline can complete while surfacing the issues.

## Project Structure

```text
ecommerce_de_project/
├── analyses/
├── macros/
│   └── generate_schema.sql
├── models/
│   ├── sources/
│   │   └── sources.yml
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│   └── properties.yml
├── snapshots/
│   └── scd.yml
├── seeds/
├── tests/
├── dbt_project.yml
├── profiles.yml.example
├── .gitignore
└── README.md
```

*Note: `profiles.yml.example` is a template. Keep actual credentials in your local `profiles.yml` or environment variables, never in version control.*

## Setup and Execution

### Prerequisites

- A Snowflake account with the required warehouse, database, and permissions
- Python 3.10 or later
- uv
- Git
- dbt Core and the dbt-snowflake adapter

### 1. Clone the repository

```bash
git clone https://github.com/SahilDhotre16/aws-snowflake-dbt-ecommerce-pipeline.git
cd aws-snowflake-dbt-ecommerce-pipeline
```

### 2. Install dependencies

```bash
uv sync
```

Activate the virtual environment on Windows:

```cmd
.venv\Scripts\activate
```

### 3. Configure Snowflake credentials

Copy the example profile and configure your Snowflake connection using your own account details.

```cmd
copy profiles.yml.example profiles.yml
```

Set your Snowflake password as an environment variable if your profile references it:

```cmd
set SNOWFLAKE_PASSWORD=your_password
```

Replace `your_password` with your actual password locally. Never commit real credentials.

### 4. Load the source CSV files

Create the required Snowflake objects and staging tables using the SQL setup script, `creatingddl.sql`, if included in your local project.

Upload the six CSV files to the Snowflake internal stage named `SNOWSTAGE`, then load them into the staging tables using `COPY INTO`.

Confirm the staging row counts before running dbt.

### 5. Run dbt

From the directory containing `dbt_project.yml`, run:

```bash
dbt debug
dbt build
```

Generate and serve documentation:

```bash
dbt docs generate
dbt docs serve
```

## Build Results

The validated project build reported:

| Metric | Result |
|---|---:|
| dbt models | 22 |
| Snapshots | 3 |
| Data tests | 15 |
| Passed checks | 38 |
| Warnings | 2 |
| Errors | 0 |
| Skipped | 0 |

The results demonstrate a successful build with known data-quality anomalies surfaced as warnings.

## Key Skills Demonstrated

- Building layered data transformation pipelines
- Writing SQL transformations in dbt
- Creating reusable dbt macros
- Implementing dbt snapshots and SCD Type 2
- Designing fact and dimension tables
- Building analytical marts for business reporting
- Implementing data quality and relationship tests
- Investigating source-data anomalies
- Loading CSV data into Snowflake using `COPY INTO`
- Managing dependencies and source control with Git

## Future Improvements

- Add automated CI checks for dbt compilation and testing.
- Implement a scheduled orchestration workflow.
- Add incremental models where appropriate.
- Integrate a change data capture (CDC) ingestion source if implemented in the pipeline.
- Add monitoring, failure alerts, and data freshness checks.

## Author

**Sahil Dhotre**

Aspiring Data Engineer | SQL | Python | Snowflake | dbt | Data Modeling
