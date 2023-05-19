# Case Study #7: Balanced Tree 🥾

## Solution - A. High Level Sales Analysis Questions

The following questions can be considered key business questions and metrics that the Balanced Tree team requires for their monthly reports.

Each question can be answered using a single query - but as you are writing the SQL to solve each individual problem, keep in mind how you would generate all of these metrics in a single SQL script which the Balanced Tree team can run each month.

```sql
SELECT SUM(s.qty) AS total_products,
    SUM(s.qty * s.price) AS total_revenue_wo_discounts,
    SUM(ROUND(s.qty * s.price * (s.discount/ 100.0), 2)) AS total_discounts
FROM balanced_tree.sales s
```

__Steps:__

- Since the `discount` attribute in `sales` table is a percentage, it's necessary to apply it over the full price of the item in order to get the discount amount. And then use `SUM` to get the total discount amount.

__Result:__

| total_products | total_revenue_wo_discounts | total_discounts |
| :-: | :-: | :-: |
| 45216| 1289453| 156229.14|

### 1. What was the total quantity sold for all products?

__Answer:__

- Total quantity sold for all products is 45 216 items.

---

### 2. What is the total generated revenue for all products before discounts?

__Answer:__

- Total generated revenue for all products before discounts is $1 289 453.

---

### 3. What was the total discount amount for all products?

__Answer:__

- The total discount amount for all products is $156 229.14.
