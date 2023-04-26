# Case Study #4: Data Bank 🏦

## Solution - D. Extra Challenge Question

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-4/sql-syntax/D-data-allocation.sql).

---

### 1. Data Bank wants to try another option which is a bit more difficult to implement - they want to calculate data growth using an interest calculation, just like in a traditional savings account you might have with a bank.

    If the annual interest rate is set at 6% and the Data Bank team wants to reward its customers by increasing their data allocation based off the interest calculated on a daily basis at the end of each day, how much data would be required for this option on a monthly basis?

    Special notes:

    - Data Bank wants an initial calculation which does not allow for compounding interest, however they may also be interested in a daily compounding interest calculation so you can try to perform this calculation if you have the stamina!

#### Steps

In order to proceed with the resolution, I had to make assumptions regarding the calculation of the interest, that would be calculated on a daily basis. Here are the assumptions:

- The principal amount (meaning the initial amount) for the interest calculation will be the first deposit money, starting on that day.
- Since it requires a period of 24h in order to calculate the interest on a daily basis, if there is movement in the account, there is a penalty. I won't be calculating the interest of that day, since the money wasn't the same for 24 hours.

This challenge will be separated into two parts: data growth calculation using a daily simple interest rate  and data growth using a daily compouding interest rate.

How to calculate the daily data growth using a:
- daily simple interest rate: `prev_month_amount + principal_amount * AIR/365`;
- daily compounding interest rate: `prev_month_amount + prev_month_amount * AIR/365`;

where

- `prev_month_amount` is the balance amount of the previous month,
- `principal_amount` is the amount to be used for the calculation with the simple interest rate,
- `AIR` is the annual interest rate,
- `AIR/365` gives the daily interest rate.

```sql
-- DAILY SIMPLE INTEREST RATE
WITH transactions_cte as (
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

-- DAILY COMPOUND INTEREST RATE
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
```

#### Answer

Using a simple interest rate:

| txn_month | data_required_per_month |
| :- | -: |
| 1 | 556.83 |
| 2 | 1,008.58 |
| 3 | 1,083.96 |
| 4 | 1,121.34 |

Note: this is the sum of a simple interest rate. Technically, the real amount (adding the principal amount and subtracting withdraws) would be calculated after one year since this is a yearly interest rate.

Using a compound interest rate:

| txn_month | data_required_per_month |
| :- | -: |
| 1 | 294,326.86 |
| 2 | 9,678,947.24 |
| 3 | 13,498,385.04 |
| 4 | 16,758,187.85 |

Note: there aren't negative values, because when the balance is negative, the total is zero.