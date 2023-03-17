# Case Study #3: Foodie-Fi 🥑

## Solution - B. Data Analysis Questions

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-3/sql-syntax/B-data-analysis.sql).

---

### 1. How many customers has Foodie-Fi ever had?

```sql
SELECT COUNT(DISTINCT(customer_id)) AS total_customers
FROM foodie_fi.subscriptions;
```

#### Answer:
| total_customers |
| :- |
| 1000|

- Foodie-Fi had 1000 customers from the beginning.

---

### 2. What is the monthly distribution of `trial` plan `start_date` values for our dataset - use the start of the month as the group by value

```sql
SELECT EXTRACT(MONTH FROM s.start_date) AS monthly, 
	COUNT(distinct(customer_id)) AS total_plans
FROM foodie_fi.subscriptions s
WHERE plan_id = 0
GROUP BY monthly;
```

#### Steps

- Validate if trial subscription plans have happening during one or more years, to decide how the calculation of the month would be done. The minimum date was 2020-01-01, and the latest was 2020-12-30.
- **GROUP BY** by the calculated month of `start_date`, and **COUNT** `customer_id` using **DISTINCT**, adding the condition **WHERE** to filter subscription with `plan_id` equal to zero.

#### Answer:

| monthly | total_plans |
| :- | :- |
|1|	88|
|2|	68|
|3|	94|
|4|	81|
|5|	88|
|6|	79|
|7|	89|
|8|	88|
|9|	87|
|10|	79|
|11|	75|
|12|	84|

- The minimum number of trial subscriptions happened on February of 2020 with a total of 68, while March was the month with the highest number of trial subscriptions with a total of 94.
- A consistent number of trial subscriptions were made in the whole year (2020).

---

### 3. What plan `start_date` values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

```sql
SELECT p.plan_name, COUNT(DISTINCT(s.customer_id)) AS total_customers
FROM foodie_fi.subscriptions s
JOIN foodie_fi.plans p
	ON p.plan_id = s.plan_id
WHERE extract(YEAR FROM s.start_date) > 2020
GROUP BY p.plan_name;
```

#### Answer:

| plan_name | total_customers |
| :- | :- |
| basic monthly|	8|
| churn|	71|
| pro annual|	63|
| pro monthly|	60|

- A total of 8 customers subscribed to the *basic monthly* plan.
- 63 customers subscribed to the *pro annual* plan.
- 60 customers subscribed to the *pro monthly* plan.
- 71 customers cancelled their subscriptions.

---

### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

```sql
WITH total_customers_cte AS (
	SELECT COUNT(DISTINCT customer_id) AS total_customers FROM foodie_fi.subscriptions
)

SELECT COUNT(customer_id) AS count_churned, 
	ROUND(CAST(COUNT(customer_id) AS DECIMAL) / total_customers * 100, 3) AS churn_pcent
FROM foodie_fi.subscriptions, total_customers_cte
WHERE plan_id = 4
GROUP BY total_customers;
```

#### Answer:

| count_churned | churn_pcent |
| :- | :- |
| 307 |	30.7 |

- There was 307 of customer churn, which represents a 30.7% of their customers.

---

### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

```sql
WITH churned_after_trial_cte AS (
	SELECT customer_id, 
		(CASE
			WHEN plan_id = 4 AND 
				LAG(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) = 0 THEN 1
			ELSE 0
		END) AS is_churned
	FROM foodie_fi.subscriptions
)

SELECT SUM(is_churned) AS churned_customers,
	FLOOR(SUM(is_churned) / CAST(COUNT(DISTINCT customer_id) AS DECIMAL) * 100 ) AS churn_pcent
FROM churned_after_trial_cte;
```

#### Answer:

| churned_customers | churn_pcent |
| :- | :- |
| 92 |	9 |

- There was 92 of churned customers straight after their initial free trial, which represents 9% of their customers.

---

### 6. What is the number and percentage of customer plans after their initial free trial?

```sql
WITH plans_after_trial_cte AS (
	SELECT customer_id, 
		(CASE
			WHEN plan_id IN (1, 2, 3) AND --plans 
				LAG(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) = 0 THEN 1 --free trial
			ELSE 0
		END) AS has_plan
	FROM foodie_fi.subscriptions
)
SELECT SUM(has_plan) AS plans_customers,
	SUM(has_plan) / CAST(COUNT(DISTINCT customer_id) AS DECIMAL) * 100 AS plans_pcent
FROM plans_after_trial_cte;
```

#### Answer:

| churned_customers | churn_pcent |
| :- | :- |
| 908 |	90.8 |

- There was 908 of customers that have a paid plan straight after their initial free trial, which represents almost 91% of their customers.

---

### 7. What is the customer count and percentage breakdown of all 5 `plan_name` values at 2020-12-31?

```sql
WITH last_entry_customers_cte AS (
	SELECT customer_id, MAX(start_date) AS last_date
	FROM foodie_fi.subscriptions
	WHERE start_date <= '2020-12-31'
	GROUP BY customer_id
),
total_customers_cte as (
	SELECT COUNT(DISTINCT customer_id) AS total_customers
	FROM foodie_fi.subscriptions
	WHERE start_date <= '2020-12-31'
)
SELECT p.plan_name, 
	COUNT(DISTINCT s.customer_id) AS customer_count, 
	COUNT(DISTINCT s.customer_id) / CAST(total_customers_cte.total_customers AS DECIMAL) * 100 AS customer_pcent
FROM total_customers_cte, last_entry_customers_cte le
JOIN foodie_fi.subscriptions s
	ON le.customer_id = s.customer_id AND le.last_date = s.start_date
JOIN foodie_fi.plans p
	ON p.plan_id = s.plan_id
GROUP BY p.plan_name, total_customers_cte.total_customers;
```

#### Answer:

| plan_name | customer_count | customer_pcent |
| :- | :- | :- |
| basic monthly|	224|	22.4|
| churn|	236|	23.6|
| pro annual|	195|	19.5|
| pro monthly|	326|	32.6|
| trial|	19|	1.9|

-- The distribution of customers at 2020-12-31: 19 (1.9%) of customers are on free trial; 224 (22.4%) are on basic monthly plan; 195 (19.5%) are on pro annual plan; 326 (32.6%) are on pro monthly plan; and 236 (23.6%) have no plan.

---

### 8. How many customers have upgraded to an annual plan in 2020?

```sql
SELECT COUNT(DISTINCT(customer_id)) AS customer_count
FROM foodie_fi.subscriptions s
WHERE plan_id = 3 AND start_date <= '2020-12-31';
```

#### Answer:

| customer_count |
| :- |
| 195 |

- 195 customers have subscribed the annual plan in 2020.

---

### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

```sql
WITH first_time_customers_cte AS (
	SELECT customer_id, MIN(start_date) AS trial_date
	FROM foodie_fi.subscriptions s
	GROUP BY customer_id
)
SELECT ROUND(AVG(s.start_date - ft.trial_date), 2) AS avg_days_until_annual
FROM first_time_customers_cte ft
JOIN foodie_fi.subscriptions s
	ON ft.customer_id = s.customer_id
WHERE s.plan_id = 3;
```

#### Answer:

| avg_days_until_annual |
| :- |
| 104.62 |

- On average, customers take 104 days to subscribe to the annual plan from the day they join Foodie-Fi.

---

### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

```sql
WITH first_time_customers_cte AS (
	SELECT customer_id, MIN(start_date) AS trial_date
	FROM foodie_fi.subscriptions s
	GROUP BY customer_id
),
buckets_until_annual_cte AS (
	SELECT ft.customer_id,
		(s.start_date - ft.trial_date)/30 AS bucket
	FROM first_time_customers_cte ft
	JOIN foodie_fi.subscriptions s
		ON ft.customer_id = s.customer_id
	WHERE s.plan_id = 3
)
SELECT 
	CASE 
		WHEN bucket = 0 THEN CONCAT(bucket, ' - 30 days')
		ELSE CONCAT((bucket * 30) + 1, ' - ', (bucket + 1)* 30, ' days')
	END AS day_period, 
	COUNT(customer_id) AS total_customers
FROM buckets_until_annual_cte
GROUP BY bucket
ORDER BY bucket;
```

#### Answer:

| day_period | total_customers |
| :-: | :- |
| 0 - 30 days|	48|
| 31 - 60 days|	25|
| 61 - 90 days|	33|
| 91 - 120 days|	35|
| 121 - 150 days|	43|
| 151 - 180 days|	35|
| 181 - 210 days|	27|
| 211 - 240 days|	4|
| 241 - 270 days|	5|
| 271 - 300 days|	1|
| 301 - 330 days|	1|
| 331 - 360 days|	1|

---

### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

```sql
WITH monthly_downgraded_cte AS (
	SELECT customer_id, 
		(CASE
			WHEN plan_id =2 AND --pro monthly plan
				LEAD(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) = 1 THEN 1 --free trial
			ELSE 0
		END) AS is_downgraded
	FROM foodie_fi.subscriptions
	WHERE start_date <= '2020-12-31'
)
SELECT SUM(is_downgraded) AS total_downgrads
FROM monthly_downgraded_cte;
```

#### Answer: 
| total_downgrads |
| :- |
| 0 |

- No customer downgraded directly from `pro monthly` plan to the `basic monthly` plan.