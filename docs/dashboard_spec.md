# Executive Dashboard Specification

## One-page story
**Headline:** Revenue is growing, but customer retention is the key opportunity.

### KPI row
- Total Revenue — currency, 0 decimals
- Orders — whole number
- Customers — whole number
- Average Order Value — currency, 2 decimals

### Main visuals
1. **Monthly Revenue Trend:** line chart. X-axis = Month; Y-axis = Revenue. Title: `Monthly Revenue Trend`.
2. **RFM Segment Mix:** horizontal bar chart. X-axis = Customers; Y-axis = RFM Segment. Title: `Customer Portfolio by RFM Segment`.
3. **Revenue by State:** filled map. Geography = Brazilian state; color/size = Revenue. Title: `Revenue by Customer State`.
4. **Cohort Retention:** heatmap. Rows = Cohort Month; columns = Months Since First Purchase; values = Retention %. Title: `Customer Retention by Cohort`.
5. **Top Categories:** horizontal bar chart, Top 10. X-axis = Revenue; Y-axis = Product Category. Title: `Top 10 Categories by Revenue`.

## 10-second narrative
**Revenue trend → customer quality → geographic concentration → retention.**
The dashboard should let an executive answer: How much are we selling? Who drives the value? Where is revenue concentrated? Are customers coming back?

## Layout
Top: 4 KPI cards.
Middle-left: Revenue Trend (largest visual).
Middle-right: RFM Segment Mix.
Bottom-left: Revenue by State map.
Bottom-center/right: Cohort Retention heatmap + Top Categories bar chart.

Avoid pie charts for RFM; bars make segment comparison easier. Keep colors consistent across the dashboard and reserve an accent color for risk segments.
