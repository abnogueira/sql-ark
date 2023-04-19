# Case Study #4: Data Bank 🏦

## Solution - C. Data Allocation Challenge

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-4/sql-syntax/C-data-allocation.sql).

---

### 1. To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:

    - Option 1: data is allocated based off the amount of money at the end of the previous month
    - Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
    - Option 3: data is updated real-time

    For this multi-part challenge question - you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:

    - running customer balance column that includes the impact each transaction;
    - customer balance at the end of each month;
    - minimum, average and maximum values of the running balance for each customer;

    Using all of the data available - how much data would have been required for each option on a monthly basis?

#### Data Elements

- running customer balance column that includes the impact each transaction;
    ```sql
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
    ```

- customer balance at the end of each month;
    ```sql
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
    ```

- minimum, average and maximum values of the running balance for each customer;
    ```sql
    SELECT customer_id, MIN(txn_amount) AS min_amount,
    	ROUND(AVG(txn_amount), 2) AS avg_amount,
    	MAX(txn_amount) AS max_amount
    FROM transactions_with_balance_cte
    GROUP BY customer_id
    ORDER BY customer_id;
    ```

#### Option 1

```sql
SELECT txn_month,
	sum(month_end_balance) AS data_required_per_month
FROM month_end_balance_cte
GROUP BY txn_month
ORDER BY txn_month;
```

##### Answer:

| txn_month | data_required_per_month |
| :- | -: |
| 1 | 182,163 |
| 2 | 11,858 |
| 3 | -125,678 |
| 4 | -158,904 |

#### Option 2

```sql
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
```

##### Answer:

| txn_month | data_required_per_month |
| :- | -: |
| 1 | -269,385.64 |
| 2 | -177,523.46 |
| 3 | -384,490.04 |
| 4 | -126,828.86 |

#### Option 3

```sql
SELECT txn_month,
	SUM(running_customer_balance) AS data_required_per_month
FROM transactions_with_balance_cte
GROUP BY txn_month
ORDER BY txn_month;
```

##### Answer:

| txn_month | data_required_per_month |
| :- | -: |
| 1 | 394,097 |
| 2 | 39,613 |
| 3 | -895,302 |
| 4 | -501,205 |

Data required per month can be negative due to negative account balance of some customers, at the end of the month.

Option 1 seems what they are looking for, with a lower data required per month.