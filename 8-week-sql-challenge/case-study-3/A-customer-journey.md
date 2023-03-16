# Case Study #3: Foodie-Fi 🥑

## Solution - A. Customer Journey

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-3/sql-syntax/A-customer-journey.sql).

---

### 1. Based off the 8 sample customers provided in the sample from the `subscriptions` table, write a brief description about each customer’s onboarding journey. Try to keep it as short as possible - you may also want to run some sort of `join` to make your explanations a bit easier!

```sql
SELECT s.customer_id, s.start_date, p.plan_name, p.price
FROM 
	foodie_fi.subscriptions s
	JOIN foodie_fi.plans p
		ON p.plan_id = s.plan_id
WHERE customer_id IN (1, 2, 11, 13, 15, 16, 18, 19)
GROUP BY s.customer_id, s.start_date, p.plan_name, p.price
ORDER BY s.customer_id, s.start_date;
```

#### Answer:
| customer_id | start_date | plan_name | price |
| :- | :- | :- | :- |
| 1|	2020-08-01|	trial|	0.00|
| 1|	2020-08-08|	basic monthly|	9.90|
| 2|	2020-09-20|	trial|	0.00|
| 2|	2020-09-27|	pro annual|	199.00|
|11|	2020-11-19|	trial|	0.00|
|11|	2020-11-26|	churn|	|
|13|	2020-12-15|	trial|	0.00|
|13|	2020-12-22|	basic monthly|	9.90|
|13|	2021-03-29|	pro monthly|	19.90|
|15|	2020-03-17|	trial|	0.00|
|15|	2020-03-24|	pro monthly|	19.90|
|15|	2020-04-29|	churn|	|
|16|	2020-05-31|	trial|	0.00|
|16|	2020-06-07|	basic monthly|	9.90|
|16|	2020-10-21|	pro annual|	199.00|
|18|	2020-07-06|	trial|	0.00|
|18|	2020-07-13|	pro monthly|	19.90|
|19|	2020-06-22|	trial|	0.00|
|19|	2020-06-29|	pro monthly|	19.90|
|19|	2020-08-29|	pro annual|	199.00|

Brief description of 8 customer journeys:
- Customer 1: after a week on trial, subscribed to the *basic monthly* plan.
- Customer 2: after a week on trial, subscribed to the *pro annual* plan.
- Customer 11: after a 7 days trial, they unscribed.
- Customer 13: after a week trial, subscribed to the *basic monthly* plan during 3 months, then upgraded to pro monthly plan.
- Customer 15: after a week trial, subscribed to the *pro monthly* plan during 1 month, then they cancelled their subscription.
- Customer 16: after a 7 days trial, subscribed to the *basic monthly* plan during 4 months, then upgraded to *pro annual* plan.
- Customer 18: after a week on trial, subscribed to the *pro monthly* plan.
- Customer 19: after a 7 days trial, subscribed to the pro monthly plan during 2 months, then upgraded to *pro annual* plan.
