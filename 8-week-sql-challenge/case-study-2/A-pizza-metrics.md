# Case Study #2: Pizza Runner 🍕

## Solution - A. Pizza Metrics

View the complete syntax - TBD.

---

### 1. How many pizzas were ordered?

```sql
SELECT COUNT(*) AS total_pizzas
FROM pizza_runner.customer_orders; 
```

#### Steps:
- Use **COUNT** to find out the number of ordered pizzas (`total_pizzas`).

#### Answer:
| total_pizzas |
| :- |
| 14 |

- A total of 14 pizzas were ordered.

---

### 2. How many unique customer orders were made?

```sql
SELECT COUNT(distinct(order_id)) AS unique_customer_orders
FROM pizza_runner.customer_orders;
```

#### Answer:
| unique_customer_orders |
| :- |
| 10 |

- There are 10 unique customer orders.

---

### 3. How many successful orders were delivered by each runner?

```sql
SELECT runner_id, count(order_id) AS total_successful_orders
FROM pizza_runner.runner_orders
WHERE distance != 0
GROUP BY runner_id;
```

#### Answer:
| runner_id | total_successful_orders |
| :- | :- |
| 1 | 4 |
| 2 | 3 |
| 3 | 1 |

---

### 4. How many of each type of pizza was delivered?

```sql
SELECT n.pizza_name, count(c.pizza_id) AS total_delivered
FROM pizza_runner.runner_orders r
JOIN pizza_runner.customer_orders c
	ON r.order_id = c.order_id
JOIN pizza_runner.pizza_names n 
	ON c.pizza_id = n.pizza_id
WHERE r.distance NOT LIKE 'null'
GROUP BY n.pizza_name;
```

#### Answer:
| pizza_name | total_delivered | 
| :- | :- |
| Meatlovers |	9 |
| Vegetarian | 3 |

- Meatlovers pizza was delivered 9 times.
- Vegetarian pizza was delivered 3 times.

---

### 5. Which item was the most popular for each customer?

```sql
SELECT c.customer_id, n.pizza_name, count(c.pizza_id) AS total_ordered
FROM pizza_runner.runner_orders r
JOIN pizza_runner.customer_orders c
	ON r.order_id = c.order_id
JOIN pizza_runner.pizza_names n 
	ON c.pizza_id = n.pizza_id
GROUP BY c.customer_id, n.pizza_name
ORDER BY c.customer_id;
```

#### Answer:
| customer_id | pizza_name | total_ordered |
| ----------- | ---------- |------------  |
| 101	| Meatlovers	| 2
| 101	| Vegetarian	| 1
| 102	| Meatlovers	| 2
| 102	| Vegetarian	| 1
| 103	| Meatlovers	| 3
| 103	| Vegetarian	| 1
| 104	| Meatlovers	| 3
| 105	| Vegetarian	| 1

- Customer 101 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza.
- Customer 102 ordered 2 Meatlovers pizzas and 2 Vegetarian pizzas.
- Customer 103 ordered 3 Meatlovers pizzas and 1 Vegetarian pizza.
- Customer 104 ordered 1 Meatlovers pizza.
- Customer 105 ordered 1 Vegetarian pizza.

---

### 6. What was the maximum number of pizzas delivered in a single order?

```sql
SELECT MAX(pizza_delivered) FROM (
	SELECT r.order_id, count(c.order_id) AS pizza_delivered
	FROM pizza_runner.runner_orders r
	JOIN pizza_runner.customer_orders c
		ON r.order_id = c.order_id
	WHERE r.distance NOT LIKE 'null'
	GROUP BY r.order_id
) AS orders;
```

#### Answer:
| max |
| :- |
| 3 |

- Maximum number of pizza delivered in a single order is 3 pizzas.

---

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
```sql
SELECT c.customer_id
	, sum(CASE
		WHEN c.exclusions = 'null' AND c.extras = 'null' THEN 0
		WHEN c.exclusions <> '' OR c.extras <> '' THEN 1
		ELSE 0
	END) AS at_least_one_change
	, sum(CASE
		WHEN c.exclusions = 'null' AND c.extras = 'null' THEN 1
		WHEN (c.exclusions = '' OR c.exclusions IS NULL) AND (c.extras = '' OR c.extras IS NULL) THEN 1
		ELSE 0
	END) AS no_change
FROM pizza_runner.runner_orders r
JOIN pizza_runner.customer_orders c
	ON r.order_id = c.order_id
WHERE r.distance NOT LIKE 'null'
GROUP BY c.customer_id
ORDER BY c.customer_id;
```

#### Steps
After looking into the data of the column `exclusions` and `extras` on the table `customer_order`, which are column of type `VARCHAR`. It's possible to see when there are changes to the pizzas, there are one or several numbers separated by commas that indicate which changes to the pizzas were requested by the customer; on the other hand when no changes are requested the cells can be: empty, null as a string or NULL do type `NULL`.
- The expression `stringexpression = ''` yields:
   - `TRUE` for `''` (or for any string consisting of only spaces with the data type `char(n)`)
   - `NULL` for `NULL`
   - `FALSE` for anything else

#### Answer:
| customer_id | at_least_one_change | no_change |
| :- | :- | :- |
| 101 | 0 | 2 |
| 102 | 0 | 3 |
| 103 | 3 | 0 |
| 104 | 2 | 1 |
| 105 | 1 | 0 |

- Customers 101 and 102 order pizzas with their original recipes.
- Customer 103, 104 and 105 have requested at least once, a change on their pizza.

---

### 8. How many pizzas were delivered that had both exclusions and extras?

```sql
SELECT sum(CASE
		WHEN c.exclusions = 'null' OR c.extras = 'null' THEN 0
		WHEN c.exclusions <> '' AND c.extras <> '' THEN 1
		ELSE 0
	END) AS nb_pizza_w_exclusions_and_extras
FROM pizza_runner.runner_orders r
JOIN pizza_runner.customer_orders c
	ON r.order_id = c.order_id
WHERE r.distance NOT LIKE 'null';
```

#### Answer:
| nb_pizza_w_exclusions_and_extras |
| :- |
| 1 |

- Only one pizza was delivered with esclusions and extras.

---

### 9. What was the total volume of pizzas ordered for each hour of the day?

```sql
SELECT DATE_PART('hour', c.order_time) AS hour_of_day,
	COUNT(c.order_id) AS total_pizzas
FROM pizza_runner.customer_orders c
GROUP BY hour_of_day
ORDER BY hour_of_day;
```

#### Answer:
| hour_of_day | total_pizzas |
| :- | :- |
| 11 | 1 |
| 13 |	3 |
| 18 |	3 |
| 19 |	1 |
| 21 |	3 |
| 23 |	3 |

- Peak hours of the day are at 13h, 18h, 21h and 23h with 3 pizzas orders.
- Lower volume of pizzas seen at 11h and 19h.

---

### 10. What was the volume of orders for each day of the week?

```sql
SELECT TO_CHAR(c.order_time, 'Day') AS day_of_week,
	COUNT(c.order_id) AS total_pizzas
FROM pizza_runner.customer_orders c
GROUP BY day_of_week
ORDER BY day_of_week;
```

### Answer:
| day_of_week | total_pizzas |
| :- | :- |
| Friday | 1 |
| Saturday | 5 |
| Thursday | 3 |
| Wednesday	| 5 |

- Saturdays and Wednesday have the higher volume of orders, with 5 pizzas.
- Friday and Thursday have a lower volume of orders, with 1 and 3, respectively.