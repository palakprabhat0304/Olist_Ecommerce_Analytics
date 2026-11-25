# Olist E-commerce Analysis

SQL analysis of the public Olist Brazilian e-commerce dataset (about 100,000 orders, 2016–2018), built in PostgreSQL. The project looks at delivery performance, customer satisfaction, repeat purchasing and payment behaviour, and ends with a dashboard and written recommendations.

## Main finding

Late delivery is the clearest problem in the data. Orders delivered after the estimated date averaged a 2.57 review score, against 4.29 for orders on time or early. Of the late orders' reviews, 46.2% were one-star, compared with 6.6% for the rest. The one-star share rises with the length of the delay, from 13.8% at 1–3 days late to 69.5% beyond 14 days.

## Key numbers

| Metric | Value |
|---|---|
| Orders | 99,441 |
| Unique customers | 96,096 |
| Customers with more than one order | 2,997 (3.12%) |
| Total payment value | R$16,008,872.12 |
| Average order value | R$160.99 |
| Average review score | 4.09 |
| Delivered orders arriving late | 7,826 of 96,470 (8.11%) |
| Average delay of late orders | 9.55 days |
| Late rate, interstate vs same state | 9.16% vs 5.99% |
| Credit card share of payment records | 73.92% |

## Repository layout

```
.
├── README.md
├── sql/
│   ├── 00_full_working_queries.sql        original working file, kept as backup
│   ├── 01_data_exploration.sql
│   ├── 02_customer_review_analysis.sql
│   ├── 03_delivery_performance_analysis.sql
│   └── 04_payment_analysis.sql
├── dashboard/
│   └── olist_dashboard.html
└── docs/
    ├── architecture.md
    ├── business_story.md
    ├── business_insights.md
    ├── dashboard_spec.md
    ├── linkedin_post.md
    └── portfolio_notes.md
```

## How to reproduce

1. Download the nine CSV files from the Olist dataset on Kaggle.
2. Create a PostgreSQL database and a schema named `raw`.
3. Create the tables and load each CSV (the table definitions are at the top of `00_full_working_queries.sql`; run that part once only, as the tables will already exist afterwards).
4. Run the scripts in `sql/` in numerical order. Each query is separate, so run them one at a time rather than executing a whole file.

## Tools

PostgreSQL and pgAdmin 4 for the analysis. The dashboard is a static HTML page with no external libraries.

## Limitations

- Findings describe associations in the data. They do not show that late delivery causes low ratings.
- Complaint categories come from keyword matching on Portuguese review text and were not checked by hand.
- The state and route tables join through sellers and cover 97,811 orders, while the headline delivery figures cover 96,470. The difference has not yet been traced to its source.
- The data ends in 2018 and may not reflect the current business.
- Payment values are in Brazilian reais (BRL).
