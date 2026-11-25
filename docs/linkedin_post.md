# LinkedIn post (draft)

I finished an SQL project on the public Olist e-commerce dataset, about 100,000 Brazilian orders from 2016 to 2018.

The result I found most useful: orders that arrived after their estimated date averaged 2.57 stars. Orders on time or early averaged 4.29. Among reviews of late orders, 46% were one-star, against 6.6% for the rest.

The delay length matters too. One to three days late still averaged 3.77. At four to seven days it fell to 2.32.

Other things I found:
- Only 3.1% of customers ordered more than once
- Interstate orders were late 9.2% of the time, against 6.0% within a state
- Credit cards made up 74% of payment records

A few things I learned along the way. One order can have several payment records, so the average order value needed distinct orders (R$160.99) instead of a record count (R$154.10). Customer IDs change per order, so repeat buyers only show up through the unique ID. And the results are associations, not proof that delays cause low ratings.

I wrote the analysis in PostgreSQL and put the findings into a dashboard. The queries, documentation and dashboard are on GitHub: [link]

I would welcome feedback, especially on how you would approach the delivery data.

#SQL #PostgreSQL #DataAnalytics #DataAnalysis
