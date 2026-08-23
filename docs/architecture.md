# Architecture

Kaggle Olist CSV files
        |
        v
PostgreSQL raw schema
        |
        v
Staging views
        |
        v
Analytics views
        |
        +--> Revenue analysis
        +--> Category analysis
        +--> Geographic analysis
        +--> RFM segmentation
        +--> Cohort retention
        |
        v
Tableau / Power BI executive dashboard

## Recommended dashboard
- KPI cards: Revenue, Orders, Customers, AOV
- Monthly revenue line chart
- RFM segment distribution
- Revenue by Brazilian state map
- Top product categories bar chart
- Cohort retention heatmap
