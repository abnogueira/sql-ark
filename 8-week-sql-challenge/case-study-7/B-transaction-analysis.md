# Case Study #7: Balanced Tree 🥾

## Solution - B. Transaction Analysis Questions

The following questions can be considered key business questions and metrics that the Balanced Tree team requires for their monthly reports.

Each question can be answered using a single query - but as you are writing the SQL to solve each individual problem, keep in mind how you would generate all of these metrics in a single SQL script which the Balanced Tree team can run each month.

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-7/sql-syntax/ABC-balanced-tree-metrics.sql).

```sql
WITH cte_transactions AS (
    SELECT s.txn_id,
        s."member",
        s.discount AS discount_value,
        COUNT(DISTINCT s.prod_id) AS unique_prods,
        SUM(s.qty * s.price) - SUM((s.discount/100.0) * s.qty * s.price) AS total_revenue
    FROM balanced_tree.sales s
    GROUP BY s.txn_id, s."member", s.discount
)
SELECT COUNT(txn_id) AS unique_txn,
    ROUND(AVG(unique_prods), 2) AS avg_unique_prods_per_txn, 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_revenue ASC) AS percentile_25,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_revenue ASC) AS percentile_50,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_revenue ASC) AS percentile_75,
    AVG(discount_value) AS avg_discount,
    100.0 * SUM(CASE WHEN "member" IS TRUE THEN 1 ELSE 0 END)/ COUNT(*) AS pcent_txn_members,
    100.0 * SUM(CASE WHEN "member" IS FALSE THEN 1 ELSE 0 END)/ COUNT(*) AS pcent_txn_non_members,
    ROUND(AVG(CASE WHEN "member" IS TRUE THEN total_revenue ELSE NULL END), 2) AS avg_revenue_member,
    ROUND(AVG(CASE WHEN "member" IS FALSE THEN total_revenue ELSE NULL END), 2) AS avg_revenue_non_member
FROM cte_transactions
```

__Steps:__

- To simplify having one query that answers all questions, a CTE named `cte_transactions` was created that aggregates the sales information to a transaction level.
- Regarding the revenue calculation, I assumed that the discount should be applied.

__Result:__

| unique_txn | avg_unique_prods_per_txn | percentile_25 | percentile_50 | percentile_75 | avg_discount | pcent_txn_members | pcent_txn_non_members | avg_revenue_member | avg_revenue_non_member |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| 2500| 6.04| 326.40| 441.225| 572.7625| 12.09| 60.20| 39.80| 454.14| 452.01|

---

### 1. How many unique transactions were there?

__Answer:__

- There are 2500 unique transactions.

### 2. What is the average unique products purchased in each transaction?

__Answer:__

- On average there are 6 products purchased in each transaction.

### 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?

__Answer:__

- The percentile 25 of revenue per transaction is $326.40.
- The percentile 50 of revenue per transaction is $441.225.
- The percentile 75 of revenue per transaction is $572.7625.

### 4. What is the average discount value per transaction?

__Answer:__

- On average the discount value per transaction is $12.09.

### 5. What is the percentage split of all transactions for members vs non-members?

__Answer:__

- The percentage split in transactions is 60.20% - 39.80% for members vs non-members. So the majority of transactions are from members.

### 6. What is the average revenue for member transactions and non-member transactions?

__Answer:__

- On average the revenue from members is $454.14, and for non-members is $452.01.
