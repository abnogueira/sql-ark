----------------------------
--CASE STUDY #3: FOODIE-FI--
----------------------------

--Author: Anabela Nogueira
--Date: 2023/03/24
--Tool used: Posgres

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. How would you calculate the rate of growth for Foodie-Fi?
--change payments table to add trials, and monthly income from annual plan
DROP TABLE IF EXISTS payments;
SELECT
  customer_id,
  plan_id,
  plan_name,
  payment_date ::date :: varchar,
  CASE
    WHEN LAG(plan_id) OVER (
      PARTITION BY customer_id
      ORDER BY
        plan_id
    ) != plan_id
    AND DATE_PART(
      'day',
      payment_date - LAG(payment_date) OVER (
        PARTITION BY customer_id
        ORDER BY
          plan_id
      )
    ) < 30 THEN amount - LAG(amount) OVER (
      PARTITION BY customer_id
      ORDER BY
        plan_id
    )
    ELSE amount
  END AS amount,
  RANK() OVER(
    PARTITION BY customer_id
    ORDER BY
      payment_date
  ) AS payment_order 
  
INTO TEMP TABLE payments
FROM
  (
    SELECT
      customer_id,
      s.plan_id,
      plan_name,
      generate_series(
        start_date,
        CASE
          WHEN s.plan_id = 4 THEN NULL
          WHEN LEAD(start_date) OVER (
            PARTITION BY customer_id
            ORDER BY
              start_date
          ) IS NOT NULL THEN LEAD(start_date) OVER (
            PARTITION BY customer_id
            ORDER BY
              start_date
          )
          ELSE '2020-12-31' :: date
        END,
        '1 month' + '1 second' :: interval
      ) AS payment_date,
      CASE
	      WHEN s.plan_id = 3 THEN price / 12.0
      	ELSE price
      END AS amount
    FROM
      foodie_fi.subscriptions AS s
      JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
    WHERE
      start_date < '2021-01-01' :: date
    GROUP BY
      customer_id,
      s.plan_id,
      plan_name,
      start_date,
      price
  ) AS t
ORDER BY
  customer_id

SELECT * FROM payments;

--ARPU, MRR
SELECT
	EXTRACT('MONTH' FROM payment_date::date) AS revenue_month
	, count(DISTINCT customer_id) AS customers_count
	, sum(amount)/count(DISTINCT customer_id) AS arpu
	, count(DISTINCT customer_id) * (sum(amount)/count(DISTINCT customer_id)) AS mrr
INTO TEMPORARY TABLE monthly_mrr
FROM payments
GROUP BY EXTRACT('MONTH' FROM payment_date::date);
SELECT * FROM monthly_mrr;

--customer acquisition
SELECT EXTRACT('MONTH' FROM payment_date::date) AS revenue_month
	, count(DISTINCT customer_id) AS active_users
	, SUM(CASE WHEN plan_id = 0 THEN 1 ELSE 0 END) AS trial_users
	, SUM(CASE WHEN plan_id != 0 THEN 1 ELSE 0 END) AS paying_users
FROM payments
GROUP BY EXTRACT('MONTH' FROM payment_date::date);

--churn rate
WITH total_customers_cte AS (
	SELECT EXTRACT('MONTH' FROM start_date::date) AS monthly
		, COUNT(DISTINCT customer_id) AS total_customers 
	FROM foodie_fi.subscriptions
	GROUP BY EXTRACT('MONTH' FROM start_date::date)
)
SELECT t.monthly
	, COUNT(s.customer_id) AS count_churned
	, ROUND(CAST(COUNT(s.customer_id) AS DECIMAL) / t.total_customers * 100, 3) AS churn_pcent
FROM foodie_fi.subscriptions s
	JOIN total_customers_cte t
		ON EXTRACT('MONTH' FROM s.start_date::date) = t.monthly
WHERE s.plan_id = 4
GROUP BY t.monthly, t.total_customers
ORDER BY t.monthly;