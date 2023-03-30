# Case Study #4: Data Bank 🏦

## Solution - B. Customer Transactions Questions

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-4/sql-syntax/B-customer-transactions.sql).

---

### 1. What is the unique count and total amount for each transaction type?

```sql
SELECT txn_type, COUNT(txn_type) AS unique_count, SUM(txn_amount) AS total_amount
FROM data_bank.customer_transactions
GROUP BY txn_type;
```

#### Answer:

| txn_type | unique_count | total_amount |
| :- | :- | :- |
| purchase |	1617|	806537|
| withdrawal |	1580|	793003|
| deposit |	2671|	1359168|

- 1617 purchases with a total sum of US$806,537
- 1580 withdrawals with a total sum of US$793,003.
- 2671 deposits with a total amount of US$1,359,168.

---

### 2. What is the average total historical deposit counts and amounts for all customers?

```sql
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
```

#### Steps

- Filter transactions that are only deposits.
- Count transactions and average transaction amount for each customer using **CTE**.
- Calculate the average of both columns.

#### Answer:

| avg_deposit | avg_amount |
| :-: | :- |
| 5 |	508.61|

- Average deposits quantity per customer is 5, with an average amount of $508.61.

---

### 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

```sql
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
```

#### Answer:

| monthly | customer_count |
| :-: | :-: |
| 1 |	88|
| 2 |	115|
| 3 |	137|
| 4 |	40|

- Total of customers that made more than 1 deposit and either 1 purchase or 1 withdrawal in a single month: on january, 88 customers; on february there were 115; on march there were 137 and april with 40.

---

### 4. What is the closing balance for each customer at the end of the month?

```sql
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
```

#### Steps
- Create a **CTE** named `monthly_transactions_cte` with the total of monthly transactions using **SUM** function per customer on a monthly basis. **CASE WHEN** statement was used to convert purchases and withdrawals to negatives leaving only deposits as positives. Transaction dates were converted to end of month dates.
- Create a **CTE** named `closing_dates_cte` with the last day of the month for each customer. It's only generating from January to April, since the last transaction registed it's in April.
- Left join `monthly_transactions_cte` to `closing_dates_cte` on `customer_id` and `month`. In order to calculate the `closing_balance`, the window function `OVER(PARTITION BY ... ORDER BY ...)` was used, which uses unbounded preceding data, to use with the **SUM** function. This way it's possible to use the last monthly amount to populate a month when there wasn't any transaction.

#### Answer:

Top 5 customers results:

| customer_id | month | closing_balance |
| -: | :- | -: |
| 1 |	january|  	312|
| 1 |	february| 	312|
| 1 |	march |   	-640|
| 1 |	april|    	-640|
| 2 |	january|  	549|
| 2 |	february| 	549|
| 2 |	march|    	610|
| 2 |	april|    	610|
| 3 |	january|  	144|
| 3 |	february| 	-821|
| 3 |	march    |	-1222|
| 3 |	april    |	-729|
| 4 |	january  |	848|
| 4 |	february |	848|
| 4 |	march    |	655|
| 4 |	april    |	655|
| 5 |	january  |	954|
| 5 |	february |	954|
| 5 |	march    |	-1923|
| 5 | 	april    |	-2413|

---

### 5. What is the percentage of customers who increase their closing balance by more than 5%?

```sql
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
```

#### Steps

Without the possibility to question the intentions regarding this question, it's possible to calculate de percentage of customers that increased their closing balance every single month as customers, or customers that increased their balance at least once while customers. My interpretation is: calculating the percentage of customers that increased at least by 5% their monthly balance, every single month (with expection of january since there is no previous data).

- Reusing **CTE** from the previous question: `monthly_transactions_cte` and `closing_dates_cte`;
- Transform the query from previous question into **CTE** named `closing_balance_cte`;
- Create a **CTE** named `two_months_balance_cte` that adds the closing balance from the previous month to the data available on `closing_balance_cte` using **LAG** function;
- Create a **CTE** named `count_increased_balance_cte` that counts how many months customers have increased their monthly balance;
- Calculate the percentage of customers that have 3 months of increased closing balance.

#### Answer:

| percentage |
| :- |
| 3.8 |

- 3.8% of the costumers have increased their closing balance higher than 5% every month.