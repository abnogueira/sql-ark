# Case Study #2: Pizza Runner 🍕

## Solution - D. Pricing and Ratings

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/CASE-study-2/sql-syntax/D-pricing-ratings.sql).

---

### 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

```sql
SELECT SUM(
	CASE 
		WHEN c.pizza_id = 1 THEN 12
		WHEN c.pizza_id = 2 THEN 10
	END
) AS total_revenue
FROM pizza_runner.runner_orders r
JOIN pizza_runner.customer_orders c
	ON r.order_id = c.order_id
WHERE r.distance IS NOT NULL;
```

#### Answer:

| total_revenue |
| :-: |
| 138 |

- Pizza Runner made $138, if there are no delivery fees (assuming cancellation orders translates in $0).

---

### 2. What if there was an additional $1 charge for any pizza extras?

```sql
SELECT SUM(
	(CASE 
		WHEN c.pizza_id = 1 THEN 12
		WHEN c.pizza_id = 2 THEN 10
	END) +
	(CASE WHEN c.extras <> '' THEN cardinality(string_to_array(c.extras, ', ')) ELSE 0 END)
) AS total_revenue
FROM pizza_runner.runner_orders r
JOIN pizza_runner.customer_orders c
	ON r.order_id = c.order_id
WHERE r.distance IS NOT null;
```

#### Answer:

| total_revenue |
| :-: |
| 142 |

- If any pizza extras were charged $1, Pizza Runner would be making $142 in revenue.

---

### 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

```sql
DROP TABLE IF EXISTS runners_ratings;
CREATE TABLE runners_ratings (
   "order_id" INTEGER,
   "runner_id" INTEGER,
   "rating" INTEGER CHECK (rating <=5)
);
INSERT INTO runners_ratings
   ("order_id", "runner_id", "rating")
VALUES
   (1, 1, 5),
   (2, 1, 4),
   (3, 1, 5),
   (4, 2, 4),
   (5, 3, 5),
   (7, 2, 3),
   (8, 2, 4),
   (10, 1, 5);
```

---

### 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?

- `customer_id`
- `order_id`
- `runner_id`
- `rating`
- `order_time`
- `pickup_time`
- Time between order and pickup
- Delivery duration
- Average speed
- Total number of pizzas

```sql
WITH avg_speed_cte AS (
	SELECT o.runner_id, c.customer_id, c.order_id, 
		COUNT(c.order_id) AS pizza_count, 
		(o.duration::NUMERIC / 60)::NUMERIC(4,2) AS duration_hours,
		round(o.distance::NUMERIC / o.duration::NUMERIC * 60, 2) AS avg_speed
	FROM pizza_runner.customer_orders c
	JOIN pizza_runner.runner_orders o
		ON c.order_id = o.order_id
	WHERE o.duration IS NOT NULL
	GROUP BY o.runner_id, c.customer_id, c.order_id, o.distance, o.duration
	ORDER BY c.customer_id
)

SELECT co.customer_id, rr.order_id, ro.runner_id, rr.rating, co.order_time, ro.pickup_time
	, (ro.pickup_time - co.order_time) AS time_between_order_pickup
	, sp.duration_hours AS delivery_duration
	, sp.avg_speed AS average_speed
	, sp.pizza_count AS total_number_pizzas
FROM runners_ratings rr
JOIN pizza_runner.customer_orders co
	ON rr.order_id = co.order_id
JOIN pizza_runner.runner_orders ro
	ON co.order_id = ro.order_id
JOIN avg_speed_cte sp
	ON sp.order_id = co.order_id
GROUP BY co.customer_id, rr.order_id, ro.runner_id, rr.rating, co.order_time, ro.pickup_time
	, sp.duration_hours, sp.avg_speed, sp.pizza_count
ORDER BY co.customer_id, rr.order_id, ro.runner_id;
```

#### Answer:

| customer_id | order_id | runner_id | rating | order_time | pickup_time | time_between_order_pickup | delivery_duration | avg_speed | total_number_pizzas |
| :- | :- | :- | :- | :- | :- | :- | :- | :- | :- |
| 101|	1|	1|	5|	2020-01-01 18:05:02.000|	2020-01-01 18:15:34.000|	00:10:32|	0.53|	37.50|	1|
|101|	2|	1|	4|	2020-01-01 19:00:52.000|	2020-01-01 19:10:54.000|	00:10:02|	0.45|	44.44|	1|
|102|	3|	1|	5|	2020-01-02 23:51:23.000|	2020-01-03 00:12:37.000|	00:21:14|	0.33|	40.20|	2|
|102|	8|	2|	4|	2020-01-09 23:54:33.000|	2020-01-10 00:15:02.000|	00:20:29|	0.25|	93.60|	1|
|103|	4|	2|	4|	2020-01-04 13:23:46.000|	2020-01-04 13:53:03.000|	00:29:17|	0.67|	35.10|	3|
|104|	5|	3|	5|	2020-01-08 21:00:29.000|	2020-01-08 21:10:57.000|	00:10:28|	0.25|	40.00|	1|
|104|	10|	1|	5|	2020-01-11 18:34:49.000|	2020-01-11 18:50:20.000|	00:15:31|	0.17|	60.00|	2|
|105|	7|	2|	3|	2020-01-08 21:20:29.000|	2020-01-08 21:30:45.000|	00:10:16|	0.42|	60.00|	1|

---

### 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

```sql 
SELECT SUM(
	(CASE 
		WHEN c.pizza_id = 1 THEN 12
		WHEN c.pizza_id = 2 THEN 10
	END) -
	(r.distance * 0.30)
) AS total_revenue
FROM pizza_runner.runner_orders r
JOIN pizza_runner.customer_orders c
	ON r.order_id = c.order_id
WHERE r.distance IS NOT null;
```

#### Answer:

| total_revenue |
| :-: |
| 73.38 |

- Pizza Runner would be making $73.38 in revenue after paying $0.30 per kilometre traveled.