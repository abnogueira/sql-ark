# Case Study #4: Data Bank 🏦

## Solution - A. Customer Nodes Exploration

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-4/A-customer-nodes.sql).

---

### 1. How many unique nodes are there on the Data Bank system?

```sql
SELECT COUNT(DISTINCT node_id)
FROM data_bank.customer_nodes;
```

#### Answer:

| count |
| :-: |
| 5 |

- There are 5 unique nodes on Data Bank system.

---

### 2. What is the number of nodes per region?

```sql
SELECT r.region_id, r.region_name, COUNT(DISTINCT node_id)
FROM data_bank.customer_nodes c
JOIN data_bank.regions r 
	ON c.region_id = r.region_id
GROUP BY r.region_id, r.region_name;
```

#### Answer:

| region_id | region_name | count |
| :-: | :- | :-: |
| 1 |	Australia|	5|
| 2 |	America|	5|
| 3 |	Africa|	5|
| 4 |	Asia|	5|
| 5 |	Europe|	5|

- There are 5 nodes per each region.

---

### 3. How many customers are allocated to each region?

```sql
SELECT r.region_id, r.region_name, COUNT(DISTINCT customer_id) AS total_customers
FROM data_bank.customer_nodes c
JOIN data_bank.regions r 
	ON c.region_id = r.region_id
GROUP BY r.region_id, r.region_name;
```

#### Answer:

| region_id | region_name | total_customers |
| :-: | :- | :-: |
| 1 |	Australia|	110|
| 2 |	America|	105|
| 3 |	Africa|	102|
| 4 |	Asia|	95|
| 5 |	Europe|	88|

- Here is the distribution of customers per each region: Australia has 110 customers, America has 105 customers; Africa has 102 customers; Asia has 95 customers; and Europe has 88 customers.

---

### 4. How many days on average are customers reallocated to a different node?

```sql
WITH reallocation_cte AS (
	SELECT customer_id, node_id, start_date,
		CASE
			WHEN LAG(node_id) OVER(PARTITION BY customer_id ORDER BY start_date) != node_id
            THEN start_date - LAG(start_date) OVER(PARTITION BY customer_id ORDER BY start_date) 
            ELSE NULL
            END AS reallocation_days
	FROM data_bank.customer_nodes
)
SELECT ROUND(AVG(reallocation_days), 2) AS avg_days
FROM reallocation_cte;
```

#### Answer:

| avg_days |
| :-: |
| 15,63 | 

- On average, every 15 days customers are reallocated to a different node.

---

### 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

```sql
WITH reallocation_cte AS (
	SELECT customer_id, r.region_name, node_id, start_date,
		case
			WHEN LAG(node_id) OVER(PARTITION BY customer_id ORDER BY start_date) != node_id
            THEN start_date - LAG(start_date) OVER(PARTITION BY customer_id ORDER BY start_date) 
            ELSE null
            END AS reallocation_days
	FROM data_bank.customer_nodes c
	JOIN data_bank.regions r
	   ON c.region_id = r.region_id
)
SELECT region_name,
	percentile_disc(0.50) WITHIN GROUP (ORDER BY reallocation_days) AS median,
	percentile_disc(0.80) WITHIN GROUP (ORDER BY reallocation_days) AS perc80,
	percentile_disc(0.95) WITHIN GROUP (ORDER BY reallocation_days) AS perc95
FROM reallocation_cte
GROUP BY region_name
ORDER BY region_name;
```

#### Answer:

| region_name | median | perc80 | perc95 |
| :- | :- | :- | :- |
| Africa |	16|	25|	29|
| America |	16|	24|	29|
| Asia |	15|	24|	29|
| Australia | 15| 24| 29|
| Europe |	16|	26|	29|