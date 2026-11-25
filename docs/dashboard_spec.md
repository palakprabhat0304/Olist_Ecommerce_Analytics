# Dashboard specification

## Purpose

Give a reader who has not seen the SQL a quick view of delivery, satisfaction and payment results, and show the link between late delivery and ratings.

## Audience

Hiring managers and interviewers reviewing the portfolio; a business reader who wants conclusions, not queries.

## Pages

### 1. Overview
- KPI strip: orders, total payment value, average order value, average review score, late delivery rate, repeat customer rate.
- Chart: one-star share by delay bucket (main chart of the project).
- Late vs on-time average score and one-star share.
- Review score distribution.
- One-star comment categories.

### 2. Delivery
- Late rate by customer state (top eight and lowest three).
- Interstate vs same-state late rate.
- Table of the ten routes with the highest late rate.
- Table of rating by delay bucket.

### 3. Customers and payments
- Payment method by share of records and by share of value.
- Orders by instalment count.
- Average payment by instalment count.
- Unique customers vs repeat customers.

## Metric definitions

| Metric | Definition | Source script |
|---|---|---|
| Orders | Distinct `order_id` | 01 |
| Total payment value | Sum of `payment_value` | 04 |
| Average order value | Total payment value / distinct orders | 04 |
| Average review score | Mean of `review_score` | 02 |
| Late delivery rate | Late delivered orders / delivered orders with both dates | 03 |
| Repeat customer rate | Customers with 2+ orders / unique customers | 02 |

## Design

| Item | Choice |
|---|---|
| Background | Navy `#0e1a2b` |
| Accent | Teal `#3cb8a9` for positive or neutral emphasis |
| Warning | Orange `#e0875a` for late or negative measures |
| Type | IBM Plex Serif for numbers and title, IBM Plex Sans for text |
| Layout | Flat panels separated by thin rules; no shadows or gradients |
| Themes | Dark by default, light available |

## Power BI version

If rebuilt in Power BI, load the nine CSVs, relate tables on the keys in `architecture.md`, and create these measures:

```
Orders = DISTINCTCOUNT(orders[order_id])
Total Payment Value = SUM(order_payments[payment_value])
AOV = DIVIDE([Total Payment Value], DISTINCTCOUNT(order_payments[order_id]))
Avg Review Score = AVERAGE(order_reviews[review_score])
Late Orders =
CALCULATE(
    DISTINCTCOUNT(orders[order_id]),
    orders[order_status] = "delivered",
    FILTER(orders, orders[order_delivered_customer_date] > orders[order_estimated_delivery_date])
)
Delivered Orders =
CALCULATE(
    DISTINCTCOUNT(orders[order_id]),
    orders[order_status] = "delivered",
    NOT ISBLANK(orders[order_delivered_customer_date])
)
Late Rate = DIVIDE([Late Orders], [Delivered Orders])
```

## Known limits

Values are static, taken from query output. The page does not connect to the database.
