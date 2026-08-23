# Olist Brazilian E-Commerce Analytics

## Problem Statement
Analyze Olist Brazilian E-Commerce transaction data to understand revenue performance, customer value, geographic concentration, customer retention, and RFM segments. The project is designed to demonstrate practical PostgreSQL, SQL analytics, customer segmentation, and BI dashboarding skills.

## Dataset
Olist Brazilian E-Commerce Public Dataset (Kaggle). Expected source files are listed in `data/raw/` documentation. The raw dataset is not included in this repository.

## Tools
- PostgreSQL
- SQL
- Tableau or Power BI
- Git/GitHub

## Pipeline
`Kaggle CSV → PostgreSQL Raw → Staging → Analytics Views → SQL Analysis → BI Dashboard`

See `docs/architecture.md` and `docs/dashboard_spec.md` for the detailed design.

## Analysis
- Monthly revenue trend
- Top product categories by revenue
- Average order value by state
- RFM customer segmentation
- Cohort retention analysis
- Data-quality checks

## Dashboard
Add the final dashboard screenshot here:

`![Olist Executive Dashboard](images/dashboard_preview.png)`

## Key Insights
Populate this section after running the SQL outputs. Use actual numbers for RFM segment share, segment revenue, cohort retention, geographic concentration, and category contribution.

## Recommendations
Tie recommendations directly to measured RFM and cohort results. Examples of valid directions include Champions loyalty, At Risk reactivation, Lost-customer win-back, and targeted geographic/category actions.

## Repository Structure
```text
olist-ecommerce-analytics/
├── data/raw/
├── sql/
│   ├── 01_create_schemas.sql
│   ├── 02_create_raw_tables.sql
│   ├── 03_load_data.sql
│   ├── 04_staging.sql
│   ├── 05_analytics_views.sql
│   └── analysis/
├── docs/
├── dashboard/
└── images/
```
