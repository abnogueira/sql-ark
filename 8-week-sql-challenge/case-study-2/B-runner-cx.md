# Case Study #2: Pizza Runner 🍕

## Solution - B. Runnner and Customer Experience

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-2/sql-syntax/B-runner-cx.sql).

---

### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

```sql
SELECT date_part('week', registration_date + 3) AS signed_week,
	COUNT(runner_id) AS total_runners
FROM pizza_runner.runners
GROUP BY signed_week
ORDER BY signed_week;
```

#### Steps:
- Use **DATE_PART** to find out the week number, the function provides the number of the week of the year that the day is in. By definition (ISO 8601), the first week of a year contains January 4 of that year. So, we need to add 3 days, in order for the first week on 2021 start in 2021-01-01.

#### Answer:
| signed_week | total_runners |
| :- | :- |
| 1 | 2 |
| 2 | 1 |
| 3 | 1 |

- On the first week, there were 2 runners.
- On the week number two and three, there was only one runner.

---

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

```sql
WITH time_taken_cte AS (
	SELECT 
    	c.order_id, 
    	c.order_time, 
    	r.pickup_time,
    	EXTRACT(MINUTE FROM r.pickup_time - c.order_time) AS pickup_minutes
  	FROM pizza_runner.customer_orders AS c
  	JOIN pizza_runner.runner_orders AS r
    	ON c.order_id = r.order_id
  	WHERE r.distance IS NOT NULL
  	GROUP BY c.order_id, c.order_time, r.pickup_time
)

SELECT avg(pickup_minutes) AS avg_time
FROM time_taken_cte;
```

#### Answer:
| avg_time |
| :- |
| 15.625 |

- The average time taken in minutes by runners to arrive at Pizza Runner HQ to pick up the order is around 15 minutes.

---

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

```sql
WITH prep_time_cte AS (
	SELECT
		c.order_id, 
		count(c.order_id) AS pizza_order,
		EXTRACT(MINUTE FROM o.pickup_time - c.order_time) AS prep_time_minutes
	FROM pizza_runner.customer_orders c
	JOIN pizza_runner.runner_orders o
		ON c.order_id = o.order_id
	WHERE o.pickup_time IS NOT NULL
	GROUP BY c.order_id, o.pickup_time, c.order_time
)
SELECT pizza_order, AVG(prep_time_minutes) AS avg_prep_time_mins
FROM prep_time_cte
GROUP BY pizza_order;
```

#### Answer:
| pizza_order | avg_prep_time_mins |
| :- | :- |
| 3 | 29 |
| 2 | 18 |
| 1 | 12 |

- On average, a single pizza order takes 12 minutes to prepare.
- For an order with 2 pizzas, it takes on average 18 minutes, which makes 9 minutes per pizza.
- There is a relationship between time to prepare and the number of pizzas to prepare, since an order with 3 pizzas takes 29 minute, at an average of 10 minutes per pizza.

---

### 4. What was the average distance travelled for each customer?

```sql
SELECT c.customer_id, AVG(o.distance) AS avg_distance_km
FROM pizza_runner.customer_orders c
JOIN pizza_runner.runner_orders o
	ON c.order_id = o.order_id
WHERE o.pickup_time IS NOT NULL
GROUP BY c.customer_id
ORDER BY c.customer_id;
```

#### Answer:
| customer_id | avg_distance_km | 
| :- | :- |
| 101 |	20 |
| 102 |	16.7333333333333333 |
| 103	| 23.4 |
| 104 | 10 |
| 105 | 25 |

- Customer 104 is nearest to Pizza Runner HQ, with an average distance of 10 km, whereas customer 105 stays furhter away from headquarters, with an average distance of 25 km.

---

### 5. What was the difference between the longest and shortest delivery times for all orders?

```sql
SELECT MAX(duration) - MIN(duration) AS delivery_time_difference
FROM pizza_runner.runner_orders
WHERE duration IS NOT NULL;
```

#### Answer:
| delivery_time_difference |
| :- |
| 30 |

- The difference between the longest (which is 40 min) and shortest (which is 10 min) of delivery time for all orders is 30 minutes.

---

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

```sql
SELECT o.runner_id, c.customer_id, c.order_id, 
	COUNT(c.order_id) AS pizza_count, 
	o.distance,
	(o.duration::NUMERIC / 60)::NUMERIC(4,2) AS duration_hours,
	round(o.distance::NUMERIC / o.duration::NUMERIC * 60, 2) AS avg_speed
FROM pizza_runner.customer_orders c
JOIN pizza_runner.runner_orders o
	ON c.order_id = o.order_id
WHERE o.duration IS NOT NULL
GROUP BY o.runner_id, c.customer_id, c.order_id, o.distance, o.duration
ORDER BY c.customer_id;
```

#### Answer:
| runner_id | customer_id | order_id | pizza_count | distance | duration_hours | avg_speed |
| :- | :- | :- | :- | :- | :- | :- |
| 1|	101|	1|	1|	20.0|	0.53|	37.50|
| 1|	101|	2|	1|	20.0|	0.45|	44.44|
| 1|	102|	3|	2|	13.4|	0.33|	40.20|
| 2|	102|	8|	1|	23.4|	0.25|	93.60|
| 2|	103|	4|	3|	23.4|	0.67|	35.10|
| 1|	104|	10|	2|	10.0|	0.17|	60.00|
| 3|	104|	5|	1|	10.0|	0.25|	40.00|
| 2| 	105|	7|	1|	25.0|	0.42|	60.00|

- Runner 1's average speed is between 37.5km/h to 60km/h.
- Runner 2's average speed is between 35.1km/h to 93.60km/h. The table is orderd by `customer_id` so that we can compare the same location (assuming the customer has the same address). This runner made an order to customer 102, for a farther away address (23.4 km) but took less time because the average speed was 93.6km/h, comparing with another run of 23.4 that took way longer since the average speed was 35.1km/h. Does any of these routes make usage of highway that help to explain the higher speed? 
- Runner 3's average speed is 40km/h, with only one delivery being done.

---

### 7. What is the successful delivery percentage for each runner?

```sql
SELECT
	runner_id,
	round(100 * SUM(
		CASE WHEN duration IS NULL THEN 0
		ELSE 1 END) / COUNT(*), 0) AS success_perc
FROM pizza_runner.runner_orders
GROUP BY runner_id
ORDER BY runner_id;
```

#### Answer:
| runner_id | success_perc |
| :- | :- |
| 1 | 100 |
| 2 | 75 |
| 3 | 50 |

Although calculating successful delivery percentage by deducting cancelled deliveries is not fair for runners, here are the percentages:
- Runner 1 has 100% successful delivery.
- Runner 2 has 75% successful delivery (1 cancelled and 3 completed).
- Runner 3 has 50% successful delivery (1 cancelled and 1 completed).