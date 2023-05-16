# Case Study #6: Clique Bait 🍤

## Solution - C. Product Funnel Analysis Questions

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-6/sql-syntax/C-prod-funnel-analysis.sql).

---

### 1. Using a single SQL query - create a new output table which has the following details:

    - How many times was each product viewed?
    - How many times was each product added to cart?
    - How many times was each product added to a cart but not purchased (abandoned)?
    - How many times was each product purchased?

```sql
CREATE TABLE clique_bait.product_stats AS (
	WITH cte_data_by_product AS (
		SELECT product_id, 
			page_name AS product_name,
			event_name,
			visit_id,
			CASE WHEN event_name = 'Add to Cart' AND visit_id IN (
		        SELECT DISTINCT visit_id
		        FROM clique_bait.events
		        WHERE event_type = 3
		    	) THEN 'Y' ELSE 'N' END AS made_purchase
		FROM clique_bait.events AS e
		JOIN clique_bait.event_identifier AS i
			ON e.event_type = i.event_type
		JOIN clique_bait.page_hierarchy AS p
			ON e.page_id = p.page_id
		WHERE product_id IS NOT NULL
			AND event_name IN ('Page View', 'Add to Cart')
	)
	SELECT product_id, 
		product_name,
		SUM(CASE WHEN event_name = 'Page View' THEN 1 ELSE 0 END) AS total_views,
		SUM(CASE WHEN event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS total_added_to_cart,
		SUM(CASE WHEN event_name = 'Add to Cart' AND made_purchase = 'N' THEN 1 ELSE 0 END) AS total_abandoned,
		SUM(CASE WHEN event_name = 'Add to Cart' AND made_purchase = 'Y' THEN 1 ELSE 0 END) AS total_purchases
	FROM cte_data_by_product
	GROUP BY product_id, product_name
	ORDER BY product_id
)
```

#### Steps

- Create table intitled `product_stats` based on a `SELECT` query.
- Create a CTE named `cte_data_by_product` that has information of each event, where `event_name` is 'Page View' or 'Add to Cart'. Also, add `made_purchase` attribute that indicates if an `Add to Cart` event is associated with a purchase by checking if `visit_id` is part of events that made a purchase (`event_type` = 3).
- Create a SELECT statement grouped by `product_id` and `product_name`, and add new attributes that count the total of events that follow a certain rule, with the usage of `SUM` and `CASE WHEN` functions.

#### Answer:

Generated table named `product_stats`:

| product_id | product_name | total_views | total_added_to_cart | total_abandoned | total_purchases |
| -: | :- | -: | -: | -: | -: |
| 1 | Abalone        | 1525 | 932 | 233 | 699 |
| 2 | Black Truffle  | 1469 | 924 | 217 | 707 |
| 3 | Crab           | 1564 | 949 | 230 | 719 |
| 4 | Kingfish       | 1559 | 920 | 213 | 707 |
| 5 | Lobster        | 1547 | 968 | 214 | 754 |
| 6 | Oyster         | 1568 | 943 | 217 | 726 |
| 7 | Russian Caviar | 1563 | 946 | 249 | 697 |
| 8 | Salmon         | 1559 | 938 | 227 | 711 |
| 9 | Tuna           | 1515 | 931 | 234 | 697 |        

---

### 2. Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

```sql
CREATE TABLE clique_bait.product_category_stats AS (
	SELECT product_category,
		SUM(total_views) AS total_views,
		SUM(total_added_to_cart) AS total_added_to_cart,
		SUM(total_abandoned) AS total_abandoned,
		SUM(total_purchases) AS total_purchases
	FROM clique_bait.product_stats ps
	JOIN clique_bait.page_hierarchy ph
		ON ps.product_name = ph.page_name
	GROUP BY product_category
	ORDER BY product_category
)
```

#### Steps

- Create table intitled `...` by joining `product_stats` with `page_hierarchy` table, and then count the number of records and group by product.

#### Answer:

Generated table named `product_category_stats`:

| product_category | total_views | total_added_to_cart | total_abandoned | total_purchases |
| :- | :- | -: | -: | -: |
| Fish             | 4633 | 2789 | 674 | 2115 |
| Luxury           | 3032 | 1870 | 466 | 1404 |
| Shellfish        | 6204 | 3792 | 894 | 2898 |      

---

### 3. Use your 2 new output tables - answer the following questions:

#### 3.1. Which product had the most views, cart adds and purchases?

```sql
WITH ordered_products AS (
	SELECT *,
		ROW_NUMBER() OVER (ORDER BY total_views DESC) AS views,
      	ROW_NUMBER() OVER (ORDER BY total_added_to_cart DESC) AS carts,
      	ROW_NUMBER() OVER (ORDER BY total_purchases DESC) AS purchases
    FROM product_stats
    GROUP by 1,2,3,4,5,6
)
SELECT product_name,
	total_views,
  	total_added_to_cart,
  	total_purchases
FROM ordered_products
WHERE views = 1 OR carts = 1 OR purchases = 1
```

##### Answer:

| product_name | total_views | total_added_to_cart | total_purchases |
| :- | -: | -: | -: |
| Oyster    | 1568 | 943 | 726 |
| Lobster   | 1547 | 968 | 754 |

- Oyster has the most views, with a total of 1568.
- Lobster has the highest number of purchases (754) and number of times it was added to cart (968).

#### 3.2. Which product was most likely to be abandoned?

```sql
SELECT product_name, total_abandoned
FROM clique_bait.product_stats
ORDER BY 2 DESC
LIMIT 1
```

##### Answer:

| product_name | total_abandoned |
| :- | -: |
| Russian Caviar | 249 |

- Russian Caviar is the most abandoned product, with a total of 249.

#### 3.3. Which product had the highest view to purchase percentage?

```sql
SELECT product_name, 
	ROUND(100.0 * total_purchases / total_views, 2) AS purchase_per_view_pcent
FROM clique_bait.product_stats
ORDER BY 2 DESC
LIMIT 1
```

##### Answer:

| product_name | purchase_per_view_pcent |
| :- | -: |
| Lobster | 48.74 |

- Lobster has the highest view to purchase percentage at 48.74%.

#### 3.4. What is the average conversion rate from view to cart add?

```sql
SELECT 
	ROUND(100.0 * SUM(total_added_to_cart) / SUM(total_views), 1) as avg_view_to_cart_rate
FROM clique_bait.product_category_stats
```

##### Answer:

| avg_view_to_cart_rate |
| :-: |
| 60.9 |

- The average conversion rate from view to cart add is 60.9%.

#### 3.5. What is the average conversion rate from cart add to purchase?

```sql
SELECT 
	ROUND(100.0 * SUM(total_added_to_cart) / SUM(total_views), 1) as avg_view_to_cart_rate
FROM clique_bait.product_category_stats
```

##### Answer:

| avg_cart_add_to_purchase_rate |
| :-: |
| 75.9 |

- The average conversion rate from cart add to purchase is 75.9%.