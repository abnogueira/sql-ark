# Case Study #7: Balanced Tree 🥾

## Solution - E. Bonus Challenge

Use a single SQL query to transform the `product_hierarchy` and `product_prices` datasets to the `product_details` table.

Hint: you may want to consider using a recursive CTE to solve this problem!

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-7/sql-syntax/E-bonus-challenge.sql).

```sql
SELECT product_id,
    pp.price,
    CONCAT(ph.level_text, ' ',ph1.level_text, ' - ', ph2.level_text) AS product_name,
    ph2.id AS category_id,
    ph1.id AS segment_id,
    ph.id AS style_id,
    ph2.level_text AS category_name,
    ph1.level_text AS segment_name,
    ph.level_text AS style_name
FROM balanced_tree.product_hierarchy ph
JOIN balanced_tree.product_hierarchy AS ph1
    ON ph.parent_id = ph1.id
JOIN balanced_tree.product_hierarchy AS ph2
    ON ph1.parent_id = ph2.id
JOIN balanced_tree.product_prices AS pp
    ON ph.id = pp.id;
```

__Steps:__

- Due to the way `product_hierarchy` is structured for different levels, and since the `id` from that table is sequential is makes it easy to use multiple joins to add information from other levels.
- `ph` is intended to have the style level of information; `ph1` will add the segment level; `ph2` will add the category level. And `pp` to add product information (`product_id` and `price`) from `product_prices`.

__Result:__

| product_id | price | product_name | category_id | segment_id | style_id | category_name | segment_name | style_name |
| :- | -: | :- | -: | -: | -: | :- | :- | :- |
| c4a632| 13| Navy Oversized Jeans - Womens| 1| 3| 7| Womens| Jeans| Navy Oversized|
| e83aa3| 32| Black Straight Jeans - Womens| 1| 3| 8| Womens| Jeans| Black Straight|
| e31d39| 10| Cream Relaxed Jeans - Womens| 1| 3| 9| Womens| Jeans| Cream Relaxed|
| d5e9a6| 23| Khaki Suit Jacket - Womens| 1| 4| 10| Womens| Jacket| Khaki Suit|
| 72f5d4| 19| Indigo Rain Jacket - Womens| 1| 4| 11| Womens| Jacket| Indigo Rain|
| 9ec847| 54| Grey Fashion Jacket - Womens| 1| 4| 12| Womens| Jacket| Grey Fashion|
| 5d267b| 40| White Tee Shirt - Mens| 2| 5| 13| Mens| Shirt| White Tee|
| c8d436| 10| Teal Button Up Shirt - Mens| 2| 5| 14| Mens| Shirt| Teal Button Up|
| 2a2353| 57| Blue Polo Shirt - Mens| 2| 5| 15| Mens| Shirt| Blue Polo|
| f084eb| 36| Navy Solid Socks - Mens| 2| 6| 16| Mens| Socks| Navy Solid|
| b9a74d| 17| White Striped Socks - Mens| 2| 6| 17| Mens| Socks| White Striped|
| 2feb6b| 29| Pink Fluro Polkadot Socks - Mens| 2| 6| 18| Mens| Socks| Pink Fluro Polkadot|
