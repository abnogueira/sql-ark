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
GROUP BY s.customer_id, s.start_date, p.plan_name, p.price
HAVING customer_id IN (1, 2, 3, 4, 5, 6, 7, 8)
ORDER BY s.customer_id, s.start_date;
```

#### Steps:
- Use **COUNT** to find out the number of ordered pizzas (`total_pizzas`).

#### Answer:
| customer_id | start_date | plan_name | price |
| :- | :- | :- | :- |
|1|	2020-08-01|	trial|	0.00|
|1|	2020-08-08|	basic monthly|	9.90|
|2|	2020-09-20|	trial|	0.00|
|2|	2020-09-27|	pro annual|	199.00|
|3|	2020-01-13|	trial|	0.00|
|3|	2020-01-20|	basic monthly|	9.90|
|4|	2020-01-17|	trial|	0.00|
|4|	2020-01-24|	basic monthly|	9.90|
|4|	2020-04-21|	churn|	|
|5|	2020-08-03|	trial|	0.00|
|5|	2020-08-10|	basic monthly|	9.90|
|6|	2020-12-23|	trial|	0.00|
|6|	2020-12-30|	basic monthly|	9.90|
|6|	2021-02-26|	churn|	|
|7|	2020-02-05|	trial|	0.00|
|7|	2020-02-12|	basic monthly|	9.90|
|7|	2020-05-22|	pro monthly|	19.90|
|8|	2020-06-11|	trial|	0.00|
|8|	2020-06-18|	basic monthly|	9.90|
|8|	2020-08-03|	pro monthly|	19.90|

Brief description of 8 customer journeys:
- Customer 1, 3, 5: after a week on trial, subscribed to the basic monthly plan.
- Customer 2: after a week on trial, subscribed pro annual plan.
- Customer 4: after their week trial, subscribed to the basic monthly plan during 3 months, then unsubscribed.
- Customer 6: after their week trial, subscribed to the basic monthly plan during 2 months, then unsubscribed.
- Customer 7: after their week trial, subscribed to the basic monthly plan during 3 months, then upgraded to pro monthly plan.
- Customer 8: after their week trial, subscribed to the basic monthly plan during 2 months, then upgraded to pro monthly plan.