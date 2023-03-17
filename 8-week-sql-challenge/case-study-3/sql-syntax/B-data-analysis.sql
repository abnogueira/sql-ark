----------------------------
--CASE STUDY #3: FOODIE-FI--
----------------------------

--Author: Anabela Nogueira
--Date: 2023/03/17
--Tool used: Posgres

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT(customer_id)) AS total_customers
FROM foodie_fi.subscriptions;

--2. What is the monthly distribution of `trial` plan `start_date` values for our dataset - use the start of the month as the group by value
SELECT EXTRACT(MONTH FROM s.start_date) AS monthly, 
	COUNT(distinct(customer_id)) AS total_plans
FROM foodie_fi.subscriptions s
WHERE plan_id = 0
GROUP BY monthly;

--3. What plan `start_date` values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT p.plan_name, COUNT(DISTINCT(s.customer_id)) AS total_customers
FROM foodie_fi.subscriptions s
JOIN foodie_fi.plans p
	ON p.plan_id = s.plan_id
WHERE extract(YEAR FROM s.start_date) > 2020
GROUP BY p.plan_name;

--4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
WITH total_customers_cte AS (
	SELECT COUNT(DISTINCT customer_id) AS total_customers FROM foodie_fi.subscriptions
)
SELECT COUNT(customer_id) AS count_churned, 
	ROUND(CAST(COUNT(customer_id) AS DECIMAL) / total_customers * 100, 3) AS churn_pcent
FROM foodie_fi.subscriptions, total_customers_cte
WHERE plan_id = 4
GROUP BY total_customers;

--5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
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

--6. What is the number and percentage of customer plans after their initial free trial?
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

--7. What is the customer count and percentage breakdown of all 5 `plan_name` values at 2020-12-31?
WITH last_entry_customers_cte AS (
	SELECT customer_id, MAX(start_date) AS last_date
	FROM foodie_fi.subscriptions
	WHERE start_date <= '2020-12-31'
	GROUP BY customer_id
),
total_customers_cte AS (
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

--8. How many customers have upgraded to an annual plan in 2020?
SELECT COUNT(DISTINCT(customer_id)) AS customer_count
FROM foodie_fi.subscriptions s
WHERE plan_id = 3 AND start_date <= '2020-12-31';

--9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
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

--10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
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

--11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
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