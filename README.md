# Olist E-Commerce Analytics — dbt on Amazon Redshift Serverless

End-to-end analytics engineering learning project built with dbt-core 2.0 on Amazon Redshift Serverless using the Olist Brazilian E-Commerce dataset.
The pipeline ingests raw transactional data from S3, transforms it through a three-layer dbt architecture (staging → intermediate → marts), and produces a dimensional star schema ready for BI analytics.

---

## Project Structure

```
aws-dbt-project/
├── dbt_project.yml               — dbt project config (schemas, materializations, vars)
├── packages.yml                  — dbt package dependencies
├── .gitignore                    — excludes venv/, target/, profiles.yml, secrets
├── models/
│   ├── staging/                  — Source-conformed views; rename + cast only, no logic
│   │   ├── _sources.yml          — Source definitions for raw schema
│   │   ├── _staging.yml          — Column tests and descriptions for staging models
│   │   ├── stg_orders.sql
│   │   ├── stg_order_items.sql
│   │   ├── stg_order_payments.sql
│   │   ├── stg_order_reviews.sql
│   │   ├── stg_customers.sql
│   │   ├── stg_products.sql
│   │   └── stg_sellers.sql
│   ├── intermediate/             — Business logic and enrichment; still views
│   │   ├── _intermediate.yml
│   │   ├── int_orders_enriched.sql       — Joins orders, payments, reviews
│   │   ├── int_order_items_enriched.sql  — Joins items with product/seller context
│   │   ├── int_customer_orders.sql       — Customer-level order aggregations
│   │   └── int_product_category_translated.sql  — PT→EN category join
│   └── marts/
│       ├── core/                 — Dimensional model (tables); primary analytics layer
│       │   ├── _core.yml         — Tests, descriptions, and exposure definition
│       │   ├── dim_customers.sql
│       │   ├── dim_products.sql
│       │   ├── dim_sellers.sql
│       │   ├── dim_dates.sql             — Generated via dbt_utils.date_spine
│       │   ├── fct_orders.sql            — Incremental model (merge on order_id)
│       │   └── fct_order_items.sql
│       └── marketing/            — Denormalized marts for self-service BI
│           ├── _marketing.yml
│           └── mrt_customer_lifetime_value.sql
├── macros/
│   ├── generate_schema_name.sql  — Routes dev→dbt_dev_<layer>, prod→<layer>
│   ├── classify_delivery_status.sql  — on_time / slightly_late / late / very_late
│   └── brl_to_usd.sql            — Parameterized BRL→USD currency conversion
├── tests/
│   ├── assert_no_future_order_dates.sql
│   └── assert_order_items_revenue_matches_payments.sql  — severity: warn
├── seeds/
│   ├── product_category_name_translation.csv  — 71 PT→EN category labels
│   └── _seeds.yml
├── snapshots/
│   └── sellers_snapshot.sql      — SCD Type 2 on seller_city / seller_state
├── infra/
│   └── sql/raw_tables/           — DDL + COPY scripts for all 7 raw tables
├── docs/                         — Documentation beyond dbt docs
├── analysis/                     — Ad-hoc analysis queries
├── research/                     — Architecture notes and design decisions
└── venv/                         — Python virtual environment (gitignored)
```

---

## Final Architecture

```
Dataset      Amazon S3          Amazon Redshift Serverless      dbt
─────────    ─────────────      ──────────────────────────      ────────────────────────
Olist CSV → s3://olist-raw  →  COPY → raw schema          →   staging (views)
files         data bucket        7 tables                       intermediate (views)
(Kaggle)                                                        marts/core (tables)
                                                                marts/marketing (tables)
                                                                seeds / snapshots
```

**Technology stack:**

| Layer | Technology |
|---|---|
| dbt | dbt-core 2.0.0-alpha.1 · dbt-redshift 1.10.1 |
| Warehouse | Amazon Redshift Serverless (8 RPU base, eu-central-1) |
| Raw storage | Amazon S3 |
| Data loading | Redshift COPY from S3 via IAM role |
| dbt packages | dbt_utils · dbt_expectations (metaplane) · audit_helper |
| Docs | `dbt compile --write-catalog` + Python `http.server` |

---

## Final Data Flow

```
Olist CSV files (Kaggle)
→ Amazon S3 (raw data bucket)
→ Redshift COPY command (IAM role auth)
→ raw schema (7 source tables: orders, order_items, order_payments, order_reviews, customers, products, sellers)
→ dbt staging layer (7 views: stg_*)
→ dbt intermediate layer (4 views: int_*)
→ dbt seed (product_category_name_translation — 71 rows)
→ dbt marts/core (6 tables: dim_customers, dim_products, dim_sellers, dim_dates, fct_orders, fct_order_items)
→ dbt marts/marketing (1 table: mrt_customer_lifetime_value)
→ dbt snapshot (sellers_snapshot — SCD Type 2)
→ BI / Dashboard (olist_orders_dashboard exposure)
```

---

## Dimensional Model (Star Schema)

```
dim_dates ──────────────────────────┐
                                    ▼
dim_customers ──────────────► fct_orders ◄──────────── dim_dates
                                    │
                             fct_order_items ◄───────── dim_products
                                    │
                                    └────────────────── dim_sellers
```

| Model | Grain | Materialization |
|---|---|---|
| `fct_orders` | One row per order | Incremental (merge on order_id) |
| `fct_order_items` | One row per order line item | Table |
| `dim_customers` | One row per unique customer (person) | Table |
| `dim_products` | One row per product SKU | Table |
| `dim_sellers` | One row per seller | Table |
| `dim_dates` | One row per calendar day (2016–2018) | Table |
| `mrt_customer_lifetime_value` | One row per unique customer | Table |

---

## Service Setup

### Amazon Redshift Serverless

- Namespace: `olist-analytics-ns`
- Workgroup: `olist-workgroup`
- Base capacity: 8 RPU
- Database: `dev`
- Admin user: `olist_admin`
- Endpoint: `olist-workgroup.759302162548.eu-central-1.redshift-serverless.amazonaws.com:5439`
- **Publicly accessible** must be enabled (Workgroup → Edit → Network and security)

### Amazon S3

- Bucket: `olist-raw-data-759302162548-eu-central-1-an`
- Region: `eu-central-1`
- Structure: one prefix per source table (`raw/orders/`, `raw/customers/`, etc.)
- Upload CSVs via AWS CLI: `aws s3 cp <file> s3://<bucket>/raw/<table>/`

### IAM Role

- Name: `redshift-s3-copy-role`
- Trust: `redshift.amazonaws.com`
- Policy: S3 read access on the raw data bucket
- Attached to the Redshift namespace
- ARN: `arn:aws:iam::759302162548:role/redshift-s3-copy-role`

### Security Group

- Inbound rule: Custom TCP, port 5439, source = your local IP `/32`
- Must be added as a **new rule** — editing the default group-reference rule fails in the console

---

## Environment Setup

### Prerequisites

- Python 3.11+
- AWS CLI configured with credentials for account `759302162548`
- Olist CSV files downloaded from Kaggle

### Install dependencies

```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install dbt-redshift==1.10.1
```

### Configure dbt profile

Create `~/.dbt/profiles.yml` (never commit this file):

```yaml
olist_redshift:
  target: dev
  outputs:
    dev:
      type: redshift
      host: olist-workgroup.759302162548.eu-central-1.redshift-serverless.amazonaws.com
      port: 5439
      dbname: dev
      schema: dbt_dev
      user: olist_admin
      password: "{{ env_var('DBT_REDSHIFT_PASSWORD') }}"
      threads: 4
      connect_timeout: 30
      ra3_node: true
```

### Set the password environment variable

```powershell
$env:DBT_REDSHIFT_PASSWORD = "your-password-here"
```

This must be set in every new terminal session before running dbt commands.

### Run the project

```powershell
# Verify connection
.\venv\Scripts\dbt debug --profiles-dir C:\Users\<user>\.dbt

# Install packages
.\venv\Scripts\dbt deps

# Load reference data
.\venv\Scripts\dbt seed --profiles-dir C:\Users\<user>\.dbt

# Build all models
.\venv\Scripts\dbt run --profiles-dir C:\Users\<user>\.dbt

# Run all tests
.\venv\Scripts\dbt test --profiles-dir C:\Users\<user>\.dbt

# Run SCD Type 2 snapshot
.\venv\Scripts\dbt snapshot --profiles-dir C:\Users\<user>\.dbt

# Generate and serve docs
.\venv\Scripts\dbt compile --write-catalog --profiles-dir C:\Users\<user>\.dbt
cd target; python -m http.server 8080
```

### Useful node selection patterns

```powershell
# Only staging layer
dbt run --select staging

# Model + all upstream dependencies
dbt run --select +fct_orders

# Model + all downstream dependents
dbt run --select int_product_category_translated+

# Run and test together
dbt build --select +fct_order_items

# Test only one layer
dbt test --select staging.*

# Models with a specific tag
dbt run --select tag:incremental
```

---

## Data Source

- **Name:** Olist Brazilian E-Commerce Public Dataset
- **Source:** Kaggle — `olist/brazilian-ecommerce`
- **License:** CC BY-NC-SA 4.0
- **Coverage:** Brazil, September 2016 – October 2018
- **Tables:** 8 CSV files
- **Scale:** ~100K orders, ~73K unique customers, ~32K unique sellers, ~33K unique products

| Table | Rows (approx.) | Description |
|---|---|---|
| orders | 99,441 | Order header records |
| order_items | 112,650 | Line items per order |
| order_payments | 103,886 | Payment records (multiple per order possible) |
| order_reviews | 99,224 | Customer reviews (1–5 star rating) |
| customers | 99,441 | Customer records (per-order key) |
| products | 32,951 | Product catalog with dimensions |
| sellers | 3,095 | Seller / merchant records |
| product_category_name_translation | 71 | PT → EN category labels (dbt seed) |

---

## AWS Budget

A monthly budget alert is recommended. At 8 RPU Redshift Serverless costs approximately $0.36/hour when active — for short learning sessions the monthly cost is minimal. Set a $10/month alert in AWS Billing to avoid surprises.

---

## Challenges & Fixes

### DNS resolution failed on dbt debug

**Symptom:** `hostname resolving error: lookup olist-workgroup... no such host`

**Root cause:** The Redshift Serverless workgroup had "Publicly accessible" disabled, so the DNS entry did not resolve from outside the VPC.

**Fix:**
AWS Console → Redshift Serverless → Workgroups → `olist-workgroup` → Edit → Network and security → Enable "Publicly accessible" → Save.

---

### TCP connection timeout on port 5439

**Symptom:** `dial tcp 63.184.254.21:5439: connectex: A connection attempt failed`

**Root cause:** The VPC security group had no inbound rule allowing TCP 5439 from the local IP. The existing default rule was a group-reference rule and could not be modified to change the source type.

**Fix:**
Add a **new** inbound rule: Custom TCP · Port 5439 · Source: `<your-ip>/32`. Do not try to edit the existing group-reference rule — the console blocks changing the source type on existing rules.

---

### `raw` is a reserved word in Redshift

**Symptom:** `CREATE SCHEMA raw;` returned a syntax error.

**Root cause:** `raw` is a reserved keyword in Redshift SQL.

**Fix:**
- Quote in all SQL: `CREATE SCHEMA "raw";` and `"raw".orders`
- Add `quoting: { schema: true }` to the source definition in `_sources.yml` so dbt quotes it in generated SQL

---

### dbt 2.0: all generic test arguments require `arguments:` key

**Symptom:** `dbt seed` / `dbt run` failed with errors like `unexpected keyword argument 'values'`, `unexpected keyword argument 'to'`.

**Root cause:** dbt 2.0 breaking change — all parameters for generic tests (`values`, `to`, `field`, `min_value`, `max_value`) must now be nested under an `arguments:` key in schema YAML.

**Fix:**
```yaml
# Before (dbt 1.x)
- accepted_values:
    values: ['created', 'approved']

# After (dbt 2.0)
- accepted_values:
    arguments:
      values: ['created', 'approved']
```

Applied across `_staging.yml`, `_intermediate.yml`, `_core.yml`, and `_marketing.yml`.

---

### `DISTINCT ON` not supported in Redshift

**Symptom:** `ERROR: syntax error at or near "ON"` in `dim_customers` and `int_orders_enriched`.

**Root cause:** `DISTINCT ON (col)` is a PostgreSQL extension not available in Redshift.

**Fix:** Replace with `ROW_NUMBER() OVER (PARTITION BY ...)`:
```sql
SELECT customer_unique_id, customer_city, customer_state, zip_code_prefix
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY customer_id) AS rn
    FROM {{ ref('stg_customers') }}
) ranked
WHERE rn = 1
```

---

### `LISTAGG(DISTINCT)` and `COUNT(DISTINCT)` cannot coexist in same query

**Symptom:** `ERROR: Using LISTAGG/PERCENTILE_CONT/MEDIAN aggregate functions with other distinct aggregate function not supported`

**Root cause:** Redshift does not allow `LISTAGG(DISTINCT ...)` in the same query as `COUNT(DISTINCT ...)`.

**Fix:** Split into two CTEs — one for numeric aggregates (`SUM`, `MAX`, `COUNT(DISTINCT)`), one for the `LISTAGG` on a pre-deduplicated subquery — then join:
```sql
payments_metrics AS (
    SELECT order_id, SUM(...), COUNT(DISTINCT payment_type) ...
    FROM {{ ref('stg_order_payments') }} GROUP BY order_id
),
payments_types AS (
    SELECT order_id, LISTAGG(payment_type, ', ') WITHIN GROUP (ORDER BY payment_type)
    FROM (SELECT DISTINCT order_id, payment_type FROM {{ ref('stg_order_payments') }}) d
    GROUP BY order_id
)
```

---

### Changing a view's column type requires DROP first

**Symptom:** `ERROR: cannot change data type of view column "product_category_name_english"`

**Root cause:** Redshift's `CREATE OR REPLACE VIEW` does not allow changing a column's type. Adding `MAX()` around a column changed its type signature.

**Fix:**
```powershell
aws redshift-data execute-statement `
  --workgroup-name olist-workgroup --database dev --region eu-central-1 `
  --sql "DROP VIEW IF EXISTS dbt_dev_intermediate.int_product_category_translated CASCADE;"
```
Then re-run `dbt run --select int_product_category_translated+`.

---

### `dbt docs generate` removed in dbt 2.0

**Symptom:** `dbt docs generate` printed a warning and produced no output.

**Root cause:** `dbt docs generate` and `dbt docs serve` were removed in dbt 2.0.

**Fix:**
```powershell
# Step 1: generate the catalog
dbt compile --write-catalog --profiles-dir C:\Users\<user>\.dbt

# Step 2: download the docs UI (use v1.9 index.html — format is backward compatible)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/dbt-labs/dbt-core/v1.9.0/core/dbt/task/docs/index.html" -OutFile "target\index.html"

# Step 3: serve locally
cd target; python -m http.server 8080
```

---

## Lessons Learned

- dbt 2.0 is a breaking release — check the migration guide before upgrading any existing project
- Reserved SQL words (`raw`, `order`, `user`) cause silent failures in Redshift if not quoted; always verify schema and table names against the [Redshift reserved words list](https://docs.aws.amazon.com/redshift/latest/dg/r_pg_keywords.html)
- Redshift is PostgreSQL-derived but not PostgreSQL — `DISTINCT ON`, `LISTAGG(DISTINCT)` + `COUNT(DISTINCT)`, and `CREATE OR REPLACE VIEW` with type changes all fail silently or with cryptic errors
- SCD Type 2 snapshots only show their value after a second run with changed source data — document this clearly so future you doesn't wonder why `dbt_valid_to` is always NULL
- Setting `severity: warn` on a test is the right tool for known data quality issues in source data (like Olist voucher discrepancies) — the anomaly is surfaced without blocking the pipeline
- The `generate_schema_name` macro is mandatory before the first `dbt run` when using custom per-layer schemas — without it, dbt uses the profile default schema for everything
- `LISTAGG` and complex aggregate combinations should be split into separate CTEs for Redshift compatibility — this also improves readability
- dbt's `--full-refresh` flag rebuilds incremental models from scratch; use it when the underlying logic or schema changes, not on every run
- The dbt lineage DAG + exposures feature makes it easy to answer "what depends on this model?" — worth setting up even on small learning projects

---

## Future Improvements

### Analytics Enhancements
- Add `fct_reviews` fact table to enable review-level analysis independent of orders
- Build a `dim_geolocation` model using the Olist geolocation dataset (lat/lon → region mapping)
- Add month-over-month revenue and order volume trend models
- Seller performance mart (delivery rate, average rating, revenue per seller)

### Data Quality
- Add `dbt_expectations.expect_table_row_count_to_be_between` tests on all fact tables
- Add freshness checks once a streaming or scheduled ingestion pipeline is in place
- Investigate and document the root cause of the order items / payment discrepancies (voucher logic)

### Infrastructure
- Replace manual S3 upload + Redshift COPY with an AWS Glue or Step Functions ingestion pipeline
- Add Terraform for Redshift Serverless, S3 bucket, and IAM role provisioning
- CI/CD pipeline: GitHub Actions running `dbt build` on pull requests

### Orchestration
- Integrate with Apache Airflow (MWAA) to schedule daily `dbt run` + `dbt test`
- Add Slack alerts on test failures via Airflow callbacks

### BI Layer
- Connect Amazon QuickSight to the mart schemas for dashboard prototypes
- Build the `olist_orders_dashboard` exposure referenced in `_core.yml`

---

## Project Progress

### 20260703

Initial build — complete end-to-end project from scratch.

**Environment**
- Configured Redshift Serverless workgroup and S3 bucket
- Resolved security group and public accessibility issues for local dbt connection
- Created IAM role for Redshift → S3 COPY authentication

**Data loading**
- Uploaded 7 Olist CSV files to S3
- Created `"raw"` schema and 7 source tables via Redshift Data API
- Loaded all raw data via COPY commands

**dbt build**
- Installed packages: `dbt_utils`, `dbt_expectations`, `audit_helper`
- Seeded `product_category_name_translation` — 71 rows
- Built 18 models: 7 staging views, 4 intermediate views, 6 core tables, 1 marketing table
- 94 tests: 93 pass · 1 warn (`assert_order_items_revenue_matches_payments`)
- Built `sellers_snapshot` — SCD Type 2 initial load
- Generated docs: `dbt compile --write-catalog` + Python http.server

**Key fixes applied**
- dbt 2.0: wrapped all generic test arguments under `arguments:` key
- Redshift: replaced `DISTINCT ON` with `ROW_NUMBER()` in 2 models
- Redshift: split `LISTAGG(DISTINCT)` + `COUNT(DISTINCT)` into separate CTEs
- Redshift: quoted `"raw"` schema throughout; added `quoting: { schema: true }` in sources
- Removed `freshness` and `loaded_at_field` from `_sources.yml` (removed in dbt 2.0)
- Deduplicated translation lookup in `int_product_category_translated` to fix cascading uniqueness failures
- Added `COALESCE` for nullable metrics in `dim_customers` (customers with no order history)
