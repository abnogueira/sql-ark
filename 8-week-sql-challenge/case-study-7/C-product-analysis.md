# Case Study #7: Balanced Tree 🥾

## Solution - C. Product Analysis Questions

The following questions can be considered key business questions and metrics that the Balanced Tree team requires for their monthly reports.

Each question can be answered using a single query - but as you are writing the SQL to solve each individual problem, keep in mind how you would generate all of these metrics in a single SQL script which the Balanced Tree team can run each month.

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-7/sql-syntax/ABC-balanced-tree-metrics.sql).

---

### 1. What are the top 3 products by total revenue before discount?

```sql
SELECT p.product_name,
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

### 2. What is the total quantity, revenue and discount for each segment? & 3. What is the top selling product for each segment? & 7. What is the percentage split of revenue by segment for each category?

```sql
WITH cte_prd_segment AS (
    SELECT p.category_name,
        p.segment_name,
        p.product_name,
        SUM(s.qty) AS total_qty,
        SUM(s.qty * s.price) AS gross_revenue,
        SUM(s.qty * s.price - discount) AS total_net_revenue,
        ROUND((s.qty * s.price) * (s.discount::NUMERIC / 100), 1) AS discount,
        ROW_NUMBER() OVER(PARTITION BY segment_name ORDER BY SUM(s.qty) DESC) AS qty_rank_nb,
        ROUND(100.0 * SUM(s.qty * s.price) / SUM(SUM(s.qty * s.price)) 
            OVER(PARTITION BY category_name), 2) AS revenue_split_pcent
    FROM balanced_tree.sales AS s
    JOIN balanced_tree.product_details AS p 
        ON s.prod_id = p.product_id
    GROUP BY p.category_name, p.segment_name, p.product_name, s.qty, s.price, s.discount
)
SELECT ps.category_name,
    ps.segment_name,
    tp.top_product,
    SUM(ps.total_qty) AS quantity_by_segment,
    SUM(ps.gross_revenue) - SUM(ps.discount) AS net_revenue_by_segment,
    SUM(ps.discount) AS total_discount_by_segment,
    SUM(ps.revenue_split_pcent) AS revenue_split_pcent
FROM cte_prd_segment ps
LEFT JOIN (
    SELECT segment_name, top_product 
    FROM (
        SELECT segment_name,
            product_name AS top_product,
            total_qty,
            gross_revenue
        FROM cte_prd_segment
        WHERE qty_rank_nb = 1
        GROUP BY segment_name, product_name, total_qty, gross_revenue
        ORDER BY total_qty DESC, gross_revenue DESC) AS a
    ) AS tp
    on ps.segment_name = tp.segment_name
GROUP BY ps.category_name, ps.segment_name, tp.top_product
ORDER BY 4 DESC;
```

__Answer:__

| category_name | segment_name | top_product | quantity_by_segment | net_revenue_by_segment | discount_by_segment | revenue_split_pcent |
| :- | :- | :- |  -: | -: | -: | -: |
| Womens | Jacket| Indigo Rain Jacket - Womens| 11385| 362661.2| 4321.8| 63.85|
| Womens| Jeans| Navy Oversized Jeans - Womens| 11349| 205874.1| 2475.9| 36.16|
| Mens| Shirt| White Tee Shirt - Mens| 11265| 401327.3| 4815.7| 57.02|
| Mens| Socks| Navy Solid Socks - Mens| 11217| 304285.4| 3691.6| 43.13|

- The segment with most sold products is the Jacket  segment, with a total of 11385 products sold. And the segment with a higher net revenue and total discount is the Shirt segment.
- Top selling products for each segment are: Grey Fashion Jacket - Womens for Jacket segment; Navy Oversized Jeans - Womens for Jeans segment; Blue Polo Shirt - Mens for Shirt segment; and Navy Solid Socks - Mens for Socks segment.
- Percentage split of revenue by segment for each category:
  - For Womens, Jacket and Jeans segments results in 63.85% and 36.16% of revenue, respectively.
  - For Mens, Shirt and Socks segments results in 57.02% and 43.13% of revenue, respectively.

---

### 4. What is the total quantity, revenue and discount for each category? & 5. What is the top selling product for each category? & 8. What is the percentage split of total revenue by category?

```sql
WITH cte_prd_category AS (
    SELECT p.category_name,
        p.product_name,
        SUM(s.qty) AS total_qty,
        SUM(s.qty * s.price) AS gross_revenue,
     ROUND(SUM(s.qty * s.price * s.discount::NUMERIC / 100), 1) AS discount,
        ROW_NUMBER() OVER(PARTITION BY category_name ORDER BY SUM(s.qty) DESC) AS qty_rank_nb
    FROM balanced_tree.sales AS s
    JOIN balanced_tree.product_details AS p 
        ON s.prod_id = p.product_id
    GROUP BY p.category_name, p.product_name
),
cte_top_selling_prd_cat AS (
    SELECT category_name,
        product_name AS top_product
    FROM cte_prd_category
    WHERE qty_rank_nb = 1
)
SELECT pc.category_name,
    SUM(total_qty) AS quantity,
    SUM(gross_revenue - discount) AS total_net_revenue,
    SUM(discount) AS total_discount,
    ROUND(100.0 * SUM(gross_revenue) / (SELECT SUM(gross_revenue) FROM cte_prd_category), 2) AS revenue_split_pcent,
    tc.top_product
FROM cte_prd_category pc
JOIN cte_top_selling_prd_cat tc
    ON pc.category_name = tc.category_name
GROUP BY 1, 6
ORDER BY 2 DESC;
```

__Answer:__

| category_name | quantity | net_revenue | total_discount | top_product |
| :- | :- | -: | -: | -: |
| Womens| 22734| 505711.5| 69621.5| 44.62| Grey Fashion Jacket - Womens|
| Mens| 22482| 627512.2| 86607.8| 55.38| Blue Polo Shirt - Mens|

- Total quantity, revenue and discount for each category:
  - There are two categories: Mens and Womens.
  - For Mens category, were sold 22,482 items, with a total revenue of $627,512.29, with a given discount of $86,607.71 in total.
  - For Womens category, were sold slightly more items with a total of 22,734, with a slightly lower total revenue of $505,711.57, with a given discount of $69,621.43 in total.
- What is the top selling product for each category:
  - For Mens category the top selling product is a "Blue Polo Shirt - Mens".
  - For Womens category the top selling product is "Grey Fashion Jacket - Womens".
- Percentage split of total revenue by category:
  - Mens category is 55.37% of revenue;
  - Womens category is 44.63% of revenue.

---

### 6. What is the percentage split of revenue by product for each segment? & 9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

```sql
SELECT segment_name,
    p.product_name,
    ROUND(100.0 * COUNT(*)::decimal/
        (SELECT COUNT(DISTINCT txn_id) FROM balanced_tree.sales), 2) AS penetration_pcent,
    ROUND(100.0 * SUM(s.qty * s.price) / SUM(SUM(s.qty * s.price)) 
        OVER(PARTITION BY segment_name), 2) AS revenue_split_pcent
FROM balanced_tree.sales s
JOIN balanced_tree.product_details p
    ON s.prod_id = p.product_id
GROUP BY 1, 2;
```

__Answer:__

| segment_name | product_name | penetration_pcent |revenue_split_pcent |
| :- | :- | -: | -:|
| Jacket| Indigo Rain Jacket - Womens| 50.00| 19.45|
| Jacket| Khaki Suit Jacket - Womens| 49.88| 23.51|
| Jacket| Grey Fashion Jacket - Womens| 51.00| 57.03|
| Jeans| Navy Oversized Jeans - Womens| 50.96| 24.06|
| Jeans| Black Straight Jeans - Womens| 49.84| 58.15|
| Jeans| Cream Relaxed Jeans - Womens| 49.72| 17.79|
| Shirt| White Tee Shirt - Mens| 50.72| 37.43|
| Shirt| Blue Polo Shirt - Mens| 50.72| 53.60|
| Shirt| Teal Button Up Shirt - Mens| 49.68| 8.98|
| Socks| Navy Solid Socks - Mens| 51.24| 44.33|
| Socks| White Striped Socks - Mens| 49.72| 20.18|
| Socks| Pink Fluro Polkadot Socks - Mens| 50.32| 35.50|

- Percentage split of revenue by product for each segment can be seen in the table above on column named `revenue_split_pcent`.
  - For Jacket segment, the product that contributes the most to the revenue is `Grey Fashion Jacket - Womens` with 57.03%.
  - For Jeans segment, the product that contributes the most to the revenue is `Black Straight Jeans - Womens` with 58.14%.
  - For Shirt segment, the product that contributes the most to the revenue is `Blue polo Shirt - Mens` with 53.53%.
  - Socks segment, the product that contributes the most to the revenue is `Navy Solid Socks - Mens` with 44.24%.
- Total transaction “penetration” for each product can be seen in the table above on the column named `penetration_pcent`.
  - All products have a penetration percentage higher than 49%. The top two products are `Navy Solid Socks - Mens` and `Grey Fashion Jacket - Womens` with 51.24% and 51.00%, respectively.

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
