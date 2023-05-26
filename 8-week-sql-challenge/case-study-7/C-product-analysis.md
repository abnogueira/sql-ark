# Case Study #7: Balanced Tree 🥾

## Solution - C. Product Analysis Questions

The following questions can be considered key business questions and metrics that the Balanced Tree team requires for their monthly reports.

Each question can be answered using a single query - but as you are writing the SQL to solve each individual problem, keep in mind how you would generate all of these metrics in a single SQL script which the Balanced Tree team can run each month.

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-7/sql-syntax/ABC-balanced-tree-metrics.sql).

---

### 1. What are the top 3 products by total revenue before discount?

```sql
SELECT TOP 3 p.product_name,
    TO_CHAR(SUM(s.qty * s.price), '999,999') AS gross_revenue_total
FROM balanced_tree.sales AS s
JOIN balanced_tree.product_details AS p 
    ON s.prod_id = p.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;
```

__Answer:__

| product_name | total_gross_revenue |
| :- | :- |
| Blue Polo Shirt - Mens| 217,683|
| Grey Fashion Jacket - Womens| 209,304|
| White Tee Shirt - Mens| 152,000|

---

### 2. What is the total quantity, revenue and discount for each segment?

```sql
WITH cte_segment_subset AS (
    SELECT p.segment_name,
        s.qty,
        (s.qty * s.price) AS gross_revenue,
        ROUND(((s.qty * s.price) * (s.discount::NUMERIC / 100)), 1) AS discount
    FROM balanced_tree.sales AS s
    JOIN balanced_tree.product_details AS p 
        ON s.prod_id = p.product_id
)
SELECT segment_name,
    SUM(qty) AS quantity,
    SUM(gross_revenue - discount) AS total_net_revenue,
    SUM(discount) AS total_discount
FROM segment_subset
GROUP BY 1
ORDER BY 2 DESC;
```

__Answer:__

Here is a list of total quantity, revenue and discount for each segment:

| segment_name | quantity | total_net_revenue | total_discount |
| :- | -: | -: | -: |
| Jacket| 11385| 322686.3| 44296.7|
| Jeans| 11349| 182996.5| 25353.5|
| Shirt| 11265| 356540.8| 49602.2|
| Socks|  11217| 270947.8| 37029.2|

---

### 3. What is the top selling product for each segment?

```sql
WITH cte_prd_segment AS (
    SELECT p.segment_name,
        p.product_name,
        SUM(s.qty) AS total_qty,
        SUM(s.qty * s.price) AS gross_revenue,
        ROW_NUMBER() OVER(PARTITION BY segment_name ORDER BY SUM(s.qty * s.price) DESC) AS revenue_rank_nb
        ROW_NUMBER() OVER(PARTITION BY segment_name ORDER BY SUM(s.qty) DESC) AS qty_rank_nb
    FROM balanced_tree.sales AS s
    JOIN balanced_tree.product_details AS p 
        ON s.prod_id = p.product_id
    GROUP BY p.segment_name, p.product_name
)
SELECT DISTINCT segment_name,
    product_name AS top_product,
    total_qty,
    gross_revenue
FROM cte_prd_segment
WHERE qty_rank_nb = 1
GROUP BY segment_name, product_name, total_qty, gross_revenue
ORDER BY total_qty DESC, gross_revenue DESC
```

__Answer:__

Top selling products for each segment by quantity are:

| segment_name | product_name | total_qty | gross_revenue |
| :- | :- | -: | -: |
| Jacket| Grey Fashion Jacket - Womens| 3876| 209304|
| Jeans | Navy Oversized Jeans - Womens| 3856| 50128|
| Shirt | Blue Polo Shirt - Mens| 3819| 217683|
| Socks | Navy Solid Socks - Mens| 3792| 136512|

Top selling products for each segment by gross revenue, can be obtained by changing `WHERE` clause into `revenue_rank_nb = 1`. The results are:

| segment_name | product_name | total_qty | gross_revenue |
| :- | :- | -: | -: |
| Jacket| Grey Fashion Jacket - Womens| 3876| 209304|
| Shirt| Blue Polo Shirt - Mens| 3819| 217683|
| Socks| Navy Solid Socks - Mens| 3792| 136512|
| Jeans| Black Straight Jeans - Womens| 3786| 121152|

- If we analyse the top selling products by quantity or by gross revenue only one product differs which is Black Straight Jeans - Womens (return more gross revenue), while Navy Oversized Jeans - Womens gets purchased more times. The other products are presented in the tables below.

---

### 4. What is the total quantity, revenue and discount for each category?

```sql
WITH cte_category_subset AS (
    SELECT p.category_name,
        s.qty,
        (s.qty * s.price) AS gross_revenue,
        ROUND(((s.qty * s.price) * (s.discount::NUMERIC / 100)), 1) AS discount
    FROM balanced_tree.sales AS s
    JOIN balanced_tree.product_details AS p 
        ON s.prod_id = p.product_id
)
SELECT category_name,
    SUM(qty) AS quantity,
    SUM(gross_revenue - discount) AS total_net_revenue,
    SUM(discount) AS total_discount
FROM cte_category_subset
GROUP BY 1
ORDER BY 2 DESC;
```

__Answer:__

| category_name | quantity | total_net_revenue | total_discount |
| :- | -: | -: | -: |
| Womens| 22734| 505682.8| 69650.2|
| Mens| 22482| 627488.6| 86631.4|

- There are two categories: Mens and Womens.
- For Mens category, were sold 22,482 items, with a total revenue of $627,512.29, with a given discount of $86,607.71 in total.
- For Womens category, were sold slightly more items with a total of 22,734, with a slightly lower total revenue of $505,711.57, with a given discount of $69,621.43 in total.

---

### 5. What is the top selling product for each category?

```sql
WITH cte_prd_category AS (
    SELECT category_name,
        product_name,
        SUM(s.qty) AS quantity,
        SUM(s.qty * s.price) AS revenue,
        ROW_NUMBER() OVER(PARTITION BY category_name ORDER BY SUM(qty)) as revenue_rank,
        ROW_NUMBER() OVER(PARTITION BY category_name ORDER BY SUM(qty)) as qty_rank
    FROM balanced_tree.sales AS s
    JOIN balanced_tree.product_details AS p 
        ON s.prod_id = p.product_id
    GROUP BY category_name, product_name
)
SELECT category_name,
    product_name,
    quantity,
    revenue
FROM cte_prd_category
WHERE qty_rank = 1
```

__Answer:__

| category_name | product_name | quantity | revenue |
| :- | :- | -: | -: |
| Mens| Teal Button Up Shirt - Mens| 3646| 36460|
| Womens| Cream Relaxed Jeans - Womens| 3707| 37070|

- For Mens category the top selling product is a "Teal Button Up Shirt - Mens".
- For Womens category the top selling product is "Cream Relaxed Jeans - Womens".

---

### 6. What is the percentage split of revenue by product for each segment?

```sql
SELECT segment_name,
    product_name,
    ROUND(100.0 * SUM(total_revenue) / SUM(SUM(total_revenue)) OVER(PARTITION BY segment_name), 2) AS revenue_split_pcent
FROM cte_prd_transactions
GROUP BY segment_name, product_name
```

__Answer:__

| segment_name | product_name | revenue_split_pcent |
| :- | :- | -: |
| Jacket| Grey Fashion Jacket - Womens| 56.99|
| Jacket| Khaki Suit Jacket - Womens| 23.57|
| Jacket| Indigo Rain Jacket - Womens| 19.44|
| Jeans| Navy Oversized Jeans - Womens| 24.04|
| Jeans| Black Straight Jeans - Womens| 58.14|
| Jeans| Cream Relaxed Jeans - Womens| 17.82|
| Shirt| White Tee Shirt - Mens| 37.48|
| Shirt| Teal Button Up Shirt - Mens| 8.99|
| Shirt| Blue Polo Shirt - Mens| 53.53|
| Socks| Navy Solid Socks - Mens| 44.24|
| Socks| White Striped Socks - Mens| 20.20|
| Socks| Pink Fluro Polkadot Socks - Mens| 35.57|

---

### 7. What is the percentage split of revenue by segment for each category?

```sql
SELECT category_name,
    segment_name,
    ROUND(100.0 * SUM(total_revenue) / SUM(SUM(total_revenue)) OVER(PARTITION BY category_name), 2) AS revenue_split_pcent
FROM cte_prd_transactions
GROUP BY category_name, segment_name
```

__Answer:__

| category_name | segment_name | revenue_split_pcent |
| :- | :- | -: |
| Mens| Shirt| 56.82|
| Mens| Socks| 43.18|
| Womens| Jeans| 36.19|
| Womens| Jacket| 63.81|

---

### 8. What is the percentage split of total revenue by category?

```sql
SELECT category_name,
    ROUND(100.0 * SUM(revenue) / (SELECT SUM(revenue) FROM cte_by_category), 2) AS revenue_split_pcent
FROM cte_by_category
GROUP BY category_name
```

__Answer:__

- Mens category is 55.37% of revenue;
- Womens category is 44.63% of revenue.

---

### 9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

```sql
SELECT p.product_name,
    ROUND(100.0 * COUNT(*)::decimal/
        (SELECT COUNT(DISTINCT txn_id) FROM balanced_tree.sales), 2) as penetration_pcent
FROM balanced_tree.sales s
JOIN balanced_tree.product_details p
    ON s.prod_id = p.product_id
GROUP BY product_name
```

__Answer:__

| product_name | count | penetration_pcent |
| :- | -: | -: |
| White Tee Shirt - Mens| 1268| 50.72|
| Navy Solid Socks - Mens| 1281| 51.24|
| Grey Fashion Jacket - Womens| 1275| 51.00|
| Navy Oversized Jeans - Womens| 1274| 50.96|
| Pink Fluro Polkadot Socks - Mens| 1258| 50.32|
| Khaki Suit Jacket - Womens| 1247| 49.88|
| Black Straight Jeans - Womens| 1246| 49.84|
| White Striped Socks - Mens| 1243| 49.72|
| Blue Polo Shirt - Mens| 1268| 50.72|
| Indigo Rain Jacket - Womens| 1250| 50.00|
| Cream Relaxed Jeans - Womens| 1243| 49.72|
| Teal Button Up Shirt - Mens| 1242| 49.68|

---

### 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

The solution to this question is based on the solution provided by muryulia in [here](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%237%20-%20Balanced%20Tree%20Clothing%20Co./Solution.md#high-level-sales-analysis).

```sql
WITH cte_products AS(
    SELECT txn_id, product_name
    FROM balanced_tree.sales AS s
    JOIN balanced_tree.product_details AS pd ON s.prod_id = pd.product_id
),
cte_prod_combinations AS (
    SELECT p.product_name AS product_1,
        p1.product_name AS product_2,
        p2.product_name AS product_3,
        COUNT(*) AS times_bought_together,
        ROW_NUMBER() OVER(ORDER BY COUNT(*) DESC) AS combination_rank
    FROM cte_products AS p
    JOIN cte_products AS p1 ON p.txn_id = p1.txn_id
        AND p.product_name != p1.product_name
        AND p.product_name < p1.product_name
    JOIN cte_products AS p2 ON p.txn_id = p2.txn_id
        AND p.product_name != p2.product_name
        AND p1.product_name != p2.product_name
        AND p.product_name < p2.product_name
        AND p1.product_name < p2.product_name
    GROUP BY
        p.product_name,
        p1.product_name,
        p2.product_name
)
SELECT product_1, product_2, product_3,
    times_bought_together
FROM cte_prod_combinations
WHERE combination_rank = 1
```

__Steps:__

- The question requires the most common combination of at least 1 quantity of any 3 products in a 1 single transaction, which can be seen as finding the combination of 3 products bought together as many times as possible.
- Combination of 3 products within 12 possible products is actually C(12,3) = 220 possibilities. Since C(_n_, _r_) represents the combinations of _n_ (objects) choose _r_ (samples). First we need to create those combinations and count them.
- Create CTE named `cte_products`, which list a single product `product_name` that was bought with their associated transaction ID `txn_id`. This CTE will be used to feed another CTE.
- Create CTE named `cte_prod_combinations` which creates 220 combinations of 3 products using the information from `cte_products`. The `COUNT` function is used to count how many times the products were bought together, and then `ROW_NUMBER` is used to rank the combinations, in order to get the most bought one.

__Answer:__

| product_1 | product_2 | product_3 | times_bought_together |
| :- | :- | :- | :-: |
| Grey Fashion Jacket - Womens| Teal Button Up Shirt - Mens| White Tee Shirt - Mens| 352|

- The most bought combination is Grey Fashion Jacket - Womens, Teal Button Up Shirt - Mens and White Tee Shirt - Mens.
