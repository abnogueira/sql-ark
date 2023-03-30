----------------------------
--CASE STUDY #4: DATA BANK--
----------------------------

--Author: Anabela Nogueira
--Date: 2023/03/25
--Tool used: Posgres

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. What is the unique count and total amount for each transaction type?
SELECT txn_type, COUNT(txn_type) AS unique_count, SUM(txn_amount) AS total_amount
FROM data_bank.customer_transactions
GROUP BY txn_type;

--2. What is the average total historical deposit counts and amounts for all customers?
WITH deposits_cte AS (
	SELECT 
    	customer_id, 
    	COUNT(*) AS txn_count, 
    	AVG(txn_amount) AS avg_amount
	FROM data_bank.customer_transactions
	WHERE txn_type = 'deposit'
	GROUP BY customer_id, txn_type
)
SELECT ROUND(AVG(txn_count),0) AS avg_deposit, 
	ROUND(AVG(avg_amount),2) AS avg_amount
FROM deposits_cte;

--3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
WITH monthly_data_cte AS (
	SELECT 
    	customer_id,
    	EXTRACT('MONTH' from txn_date) as monthly,
    	SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_count,
		SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
		SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
	FROM data_bank.customer_transactions
	GROUP BY EXTRACT('MONTH' from txn_date), customer_id
)
select monthly,
	COUNT(DISTINCT customer_id) AS customer_count
FROM monthly_data_cte
WHERE deposit_count > 1 
  AND (purchase_count > 1 OR withdrawal_count > 1)
GROUP BY monthly
ORDER BY monthly;

--4. What is the closing balance for each customer at the end of the month?
WITH monthly_transactions_cte AS (
	SELECT 
		customer_id,
		(DATE_TRUNC('month', txn_date) + INTERVAL '1 MONTH - 1 DAY') AS closing_month,
		SUM(CASE 
			WHEN txn_type = 'deposit' THEN txn_amount
			ELSE -txn_amount END) AS amount
	FROM data_bank.customer_transactions
	GROUP BY customer_id, closing_month
	order by customer_id, closing_month
),
closing_dates_cte AS (
    SELECT DISTINCT customer_id,
    	to_date('2020-01-31','YYYY-MM-DD') + (generate_series(0,3,1) * interval '1 month') AS month
    FROM data_bank.customer_transactions
	ORDER BY customer_id, month
)
SELECT c.customer_id, 
	TO_CHAR(month, 'month') as month,
    SUM(amount) OVER (PARTITION BY c.customer_id ORDER BY month) AS closing_balance
FROM closing_dates_cte c
LEFT JOIN monthly_transactions_cte m
	ON c.customer_id = m.customer_id AND c.month = m.closing_month;

--5. What is the percentage of customers who increase their closing balance by more than 5%?
WITH monthly_transactions_cte AS (
	SELECT 
		customer_id,
		(DATE_TRUNC('month', txn_date) + INTERVAL '1 MONTH - 1 DAY') AS closing_month,
		SUM(CASE 
			WHEN txn_type = 'deposit' THEN txn_amount
			ELSE -txn_amount END) AS amount
	FROM data_bank.customer_transactions
	GROUP BY customer_id, closing_month
	order by customer_id, closing_month
),
closing_dates_cte AS (
    SELECT DISTINCT customer_id,
    	to_date('2020-01-31','YYYY-MM-DD') + (generate_series(0,3,1) * interval '1 month') AS month
    FROM data_bank.customer_transactions
	ORDER BY customer_id, month
),
closing_balance_cte AS (
	SELECT c.customer_id,
		month,
	    SUM(amount) OVER (PARTITION BY c.customer_id ORDER BY month) AS closing_balance
	FROM closing_dates_cte c
	LEFT JOIN monthly_transactions_cte m
		ON c.customer_id = m.customer_id AND c.month = m.closing_month
	ORDER BY c.customer_id, ROW_NUMBER() OVER(PARTITION BY c.customer_id ORDER BY c.month)
),
two_months_balance_cte AS (
	SELECT *,
       LAG(closing_balance) OVER(PARTITION BY customer_id ORDER BY month) AS prev_closing_bal
	FROM closing_balance_cte
),
count_increased_balance_cte AS (
	SELECT customer_id,
       COUNT(customer_id) AS month_count
	FROM two_months_balance_cte
	WHERE closing_balance > (105/100)*prev_closing_bal AND 
		closing_balance::text NOT LIKE '-%'
	GROUP BY customer_id
)
SELECT ROUND(COUNT(DISTINCT(customer_id))::numeric /
	--number of customers
	(SELECT count(DISTINCT customer_id)::numeric FROM data_bank.customer_transactions)*100,2) AS percentage
FROM count_increased_balance_cte
WHERE month_count = 3;