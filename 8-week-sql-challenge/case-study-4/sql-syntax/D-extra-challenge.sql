----------------------------
--CASE STUDY #4: DATA BANK--
----------------------------

--Author: Anabela Nogueira
--Date: 2023/04/26
--Tool used: Posgres

-----------------------
--CASE STUDY QUESTION--
-----------------------

--1. Data Bank wants to try another option which is a bit more difficult to implement - they want to calculate data growth using an interest calculation, just like in a traditional savings account you might have with a bank.

--1.1 Using single interest rate
WITH transactions_cte as (
	SELECT *,
		DATE_PART('MONTH', txn_date) AS txn_month,
		SUM(CASE
		    WHEN txn_type = 'deposit' THEN txn_amount
	        ELSE -txn_amount
	    END) AS net_transaction
	FROM data_bank.customer_transactions
	GROUP BY customer_id, txn_date, txn_type, txn_amount
	ORDER BY customer_id, txn_date
),
principal_amounts_cte AS (
	SELECT customer_id, txn_date, net_transaction FROM (
		SELECT *,
			ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY txn_date ASC) AS row_number
		FROM transactions_cte
	) pa
	WHERE pa.row_number = 1
),
accrue_calculation_cte AS (
	SELECT x.customer_id, x.txn_date, 
		t.net_transaction AS daily_balance,
		(CASE WHEN t.net_transaction IS NOT NULL THEN 0
		ELSE accrue_SIT END) AS accrue_SIT
	FROM (
		SELECT customer_id, GENERATE_SERIES(MIN(txn_date), '2020-04-30', '1d')::date AS txn_date,
			net_transaction * (0.06 / 365) AS accrue_SIT
        FROM principal_amounts_cte
        GROUP BY customer_id, net_transaction
        ORDER BY 1,2
    ) x
    LEFT JOIN transactions_cte t USING (customer_id, txn_date)
    GROUP BY x.customer_id, x.txn_date, t.net_transaction, accrue_SIT
    ORDER BY x.customer_id, x.txn_date
),
group_daily_balance_cte AS (
	SELECT *,
		COUNT(daily_balance) OVER(ORDER BY customer_id, txn_date) AS _grp
	FROM accrue_calculation_cte
),
daily_filled_balance_cte AS (
	SELECT customer_id, txn_date,
		DATE_PART('MONTH', txn_date) AS txn_month,
		FIRST_VALUE(daily_balance) OVER(PARTITION BY _grp ORDER BY customer_id, txn_date) AS balance,
		accrue_sit 
	FROM group_daily_balance_cte
)
SELECT txn_month,
	ROUND(SUM(accrue_sit),2) AS data_required_per_month
FROM daily_filled_balance_cte
GROUP BY txn_month
ORDER BY txn_month;

--1.2 Using compound interest rate
WITH transactions_cte AS (
	SELECT *,
		DATE_PART('MONTH', txn_date) AS txn_month,
		SUM(CASE
		    WHEN txn_type = 'deposit' THEN txn_amount
	        ELSE -txn_amount
	    END) AS net_transaction
	FROM data_bank.customer_transactions
	GROUP BY customer_id, txn_date, txn_type, txn_amount
	ORDER BY customer_id, txn_date
),
transactions_with_balance_cte AS (
	SELECT customer_id, txn_date, txn_month, net_transaction,
	    SUM(net_transaction) OVER(PARTITION BY customer_id
	    	ORDER BY txn_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS balance
	FROM transactions_cte
),
group_daily_balance_cte AS (
	SELECT x.customer_id, x.txn_date, t.net_transaction,
		t.balance as daily_balance,
		COUNT(t.balance) OVER(ORDER BY customer_id, txn_date) AS _grp
	FROM (
		SELECT customer_id, GENERATE_SERIES(MIN(txn_date), '2020-04-30', '1d')::date AS txn_date
        FROM transactions_with_balance_cte
        GROUP BY customer_id, txn_date, balance
        ORDER BY 1,2
    ) x
    LEFT JOIN transactions_with_balance_cte t USING (customer_id, txn_date)
    GROUP BY x.customer_id, x.txn_date, t.balance, t.net_transaction
    ORDER BY x.customer_id, x.txn_date
),
daily_filled_balance_cte AS (
	SELECT customer_id, txn_date, 
		DATE_PART('MONTH', txn_date) AS txn_month, 
		COALESCE(net_transaction, 0) AS net_transaction,
		FIRST_VALUE(daily_balance) OVER(PARTITION BY _grp ORDER BY customer_id, txn_date) AS balance,
		CASE WHEN daily_balance < 0 THEN -1 
			WHEN net_transaction <> 0 THEN 0
			ELSE 0.05/365 END AS int_rate
	FROM group_daily_balance_cte
	ORDER BY customer_id, txn_date
)

WITH RECURSIVE cte AS (
  SELECT a.customer_id, a.txn_date, a.txn_month, a.net_transaction, a.balance, a.int_rate, 
  	a.balance * (1 + a.int_rate) AS total
  FROM (
	SELECT customer_id, txn_date, txn_month, net_transaction, balance, int_rate FROM (
		SELECT *,
			ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY txn_date ASC) AS row_number
		FROM temp_daily_balance
	) pa
	WHERE pa.row_number = 1
  ) a
  UNION ALL
  SELECT t.customer_id, t.txn_date, t.txn_month, t.net_transaction, t.balance, t.int_rate, 
  	CASE WHEN t.net_transaction <> 0 AND t.balance > 0 THEN total * (1 + t.int_rate) + t.net_transaction
  		ELSE total * (1 + t.int_rate) END AS total
  FROM temp_daily_balance t
  JOIN cte c
    ON t.customer_id = c.customer_id
    AND t.txn_date = c.txn_date + interval '1 day'
)
SELECT txn_month,
	ROUND(SUM(accrue_sit),2) AS data_required_per_month
FROM cte
GROUP BY txn_month
ORDER BY txn_month;