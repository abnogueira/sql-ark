----------------------------
--CASE STUDY #4: DATA BANK--
----------------------------

--Author: Anabela Nogueira
--Date: 2023/04/19
--Tool used: Posgres

-----------------------
--CASE STUDY QUESTION--
-----------------------

--1. To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options.

--1.1 Running customer balance column that includes the impact each transaction
WITH transactions_cte AS (
	SELECT *,
		date_part('MONTH', txn_date) AS txn_month,
		SUM(CASE
			WHEN txn_type = 'deposit' THEN txn_amount
			ELSE -txn_amount
		END) AS net_transaction
	FROM data_bank.customer_transactions
	GROUP BY customer_id, txn_date, txn_type, txn_amount
	ORDER BY customer_id, txn_date
),
transactions_with_balance_cte AS (
	SELECT customer_id, txn_date, txn_month,
		txn_type, txn_amount,
		SUM(net_transaction) OVER(PARTITION BY customer_id
			ORDER BY txn_month ROWS BETWEEN UNBOUNDED preceding AND CURRENT ROW) AS running_customer_balance
	FROM transactions_cte
)

--1.2 Customer balance at the end of each month
, calc_month_end_balance_cte AS (
	SELECT customer_id, txn_month,
		LAST_VALUE(running_customer_balance) OVER(PARTITION BY customer_id, txn_month
			ORDER BY txn_month) AS month_end_balance,
		ROW_NUMBER() OVER(PARTITION BY customer_id, txn_month 
			ORDER BY customer_id, txn_month) AS row_num
	FROM transactions_with_balance_cte
	GROUP BY customer_id, txn_month, running_customer_balance
),
month_end_balance_cte as (
	SELECT customer_id, txn_month, month_end_balance
	FROM calc_month_end_balance_cte
	WHERE row_num = 1
)

--1.3 Minimum, average and maximum values of the running balance for each customer
SELECT customer_id, MIN(txn_amount) AS min_amount,
	ROUND(AVG(txn_amount), 2) AS avg_amount,
	MAX(txn_amount) AS max_amount
FROM transactions_with_balance_cte
GROUP BY customer_id
ORDER BY customer_id;

-- Option 1
SELECT txn_month,
	sum(month_end_balance) AS data_required_per_month
FROM month_end_balance_cte
GROUP BY txn_month
ORDER BY txn_month;

-- Option 2
--use other cte available above
, avg_monthly_transactions_balance_cte AS (
	SELECT customer_id, txn_month,
	    avg(running_customer_balance) OVER(PARTITION BY customer_id) AS avg_running_customer_balance
	FROM transactions_with_balance_cte
	GROUP BY customer_id, txn_month, running_customer_balance
	ORDER BY customer_id
)
SELECT txn_month,
	ROUND(SUM(avg_running_customer_balance),2) AS data_required_per_month
FROM avg_monthly_transactions_balance_cte
GROUP BY txn_month
ORDER BY txn_month;

-- Option 3
SELECT txn_month,
	SUM(running_customer_balance) AS data_required_per_month
FROM transactions_with_balance_cte
GROUP BY txn_month
ORDER BY txn_month;