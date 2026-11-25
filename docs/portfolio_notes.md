# Portfolio notes

For resume, report and interview preparation.

## Resume bullets

- Analysed about 100,000 orders from the Olist e-commerce dataset in PostgreSQL across nine tables, covering delivery, reviews, customers and payments.
- Found that late-delivered orders averaged a 2.57 review score vs 4.29 for on-time orders, and that one-star share rose from 13.8% to 69.5% as delay grew.
- Corrected double counting from multi-payment and multi-seller orders by aggregating at order level before averaging.
- Built a three-page dashboard presenting findings, with written recommendations for delivery estimation and customer retention.

## Project summary (two sentences)

An end-to-end SQL analysis of the Olist marketplace, focused on how delivery performance relates to customer satisfaction. It includes documented queries, business recommendations and a dashboard.

## Skills shown

Joins across several tables, aggregation with `FILTER`, window functions (`SUM(COUNT(*)) OVER ()`), CTEs, `PERCENTILE_CONT`, date arithmetic with `EXTRACT(EPOCH ...)`, `CASE` bucketing, and keyword text classification.

## Questions to expect, with answers

**Why `COUNT(DISTINCT order_id)` for average order value?**
An order can have several payment records (103,886 records for 99,440 orders). Dividing by records gives R$154.10, which is the average payment, not the average order.

**Why two customer ID columns?**
`customer_id` is generated for each order. `customer_unique_id` identifies the person. Counting repeat customers with the first would find none.

**How did you define a late order?**
Delivered after the estimated delivery date, using delivered orders with both dates present. That left 96,470 orders, of which 7,826 were late.

**Does late delivery cause low ratings?**
The data shows a strong association. I cannot rule out other factors, such as product quality or seller behaviour. A way to test it further would be to compare ratings of late and on-time orders within the same product category and seller; the category comparison already shows the same gap in almost every category.

**What would you do next?**
Trace the 97,811 vs 96,470 difference, hand-check a sample of comments to measure the keyword classification's accuracy, and look at delivery trend by month.

**What went wrong or needed fixing?**
The first route-level delay average counted multi-seller orders more than once. I rebuilt it at order level, and results changed slightly (for example, São Paulo to Piauí moved from 13.09 to 13.71 days).

## Known weaknesses to be upfront about

- Complaint categories are keyword-based and unvalidated.
- Order totals differ between the headline delivery analysis and the state and route tables.
- The dashboard is static.
- The monthly late-delivery trend query exists but is not shown in the dashboard.
- The business insights file says delivery complaints are 47.49% of one-star comments, while the query output gives 56.28%. Update that file to match the query before publishing.
