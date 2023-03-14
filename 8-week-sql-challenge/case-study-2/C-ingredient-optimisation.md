# Case Study #2: Pizza Runner 🍕

## Solution - C. Ingredient Optimisation

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/cASe-study-2/sql-syntax/C-ingredient-optimisation.sql).

---

### 1. What are the standard ingredients for each pizza?

```sql
WITH recipes_toppings_cte AS (
	SELECT
		pizza_id,
		unnest(string_to_array(toppings, ','))::INTEGER AS topping_id
	FROM pizza_runner.pizza_recipes
)
SELECT n.pizza_name, t.topping_name
FROM recipes_toppings_cte r
JOIN pizza_runner.pizza_names n 
	ON r.pizza_id = n.pizza_id
JOIN pizza_runner.pizza_toppings t 
	ON r.topping_id = t.topping_id
GROUP BY n.pizza_name, t.topping_name
ORDER BY n.pizza_name;
```

#### Steps:
- Use **UNNEST** to expand an array to a set of rows, and use **STRING_TO_ARRAY** to have the text separated by a comma into an array to be used with **UNNEST** function.

#### Answer:
| pizza_name | topping_name |
| :- | :- |
| Meatlovers|	Mushrooms|
| Meatlovers|	Pepperoni|
| Meatlovers|	Bacon|
| Meatlovers|	Cheese|
| Meatlovers|	BBQ Sauce|
| Meatlovers|	Salami|
| Meatlovers|	Beef|
| Meatlovers|	Chicken|
| Vegetarian|	Peppers|
| Vegetarian|	Cheese|
| Vegetarian|	Mushrooms|
| Vegetarian|	Tomato Sauce|
| Vegetarian|	Onions|
| Vegetarian|	Tomatoes|

- Meatlovers pizza has the following ingredients: Mushrooms, Pepperoni, Bacon, Cheese, BBQ Sauce, Salami, Beef and Chicke.
- Vegetarian pizza has the following ingredients: Peppers, Cheese, Mushrooms, Tomato Sauce, Onions and Tomatoes.

---

### 2. What was the most commonly added extra?

```sql
WITH pizza_extras_cte AS (
	SELECT
		order_id,
		unnest(string_to_array(extras, ','))::INTEGER AS topping_id
	FROM pizza_runner.customer_orders
)
SELECT t.topping_name AS extra, count(r.topping_id) AS extra_count
FROM pizza_extras_cte r
JOIN pizza_runner.pizza_toppings t 
	ON r.topping_id = t.topping_id
GROUP BY t.topping_name
ORDER BY extra_count DESC;
```

#### Answer:
| extra | extra_count |
| :- | :- |
| Bacon|	4|
| Chicken|	1|
| Cheese|	1|

- Most commonly added extra is Bacon which was requested 4 times.

---

### 3. What was the most common exclusion?

```sql
WITH pizza_exclusions_cte AS (
	SELECT
		order_id,
		unnest(string_to_array(exclusions, ','))::INTEGER AS topping_id
	FROM pizza_runner.customer_orders
)
SELECT t.topping_name AS exclusion, count(r.topping_id) AS exclusion_count
FROM pizza_exclusions_cte r
JOIN pizza_runner.pizza_toppings t 
	ON r.topping_id = t.topping_id
GROUP BY t.topping_name
ORDER BY exclusion_count DESC;
```

#### Answer:
| exclusion | exclusion_count |
| :- | :- |
| Cheese|	4|
| Mushrooms|	1|
| BBQ Sauce|	1|

- Most common exclusion is Cheese, that was requested 4 times to be removed.

---

### 4. Generate an order item for each record in the customers_orders table

In the format of one of the following:
- Meay Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Esclude Cheese, Bacon - Extra Mushroom, Peppers

```sql
WITH extras_cte AS
(
	SELECT 
		request_id,
		concat('Extra ', STRING_AGG(t.topping_name, ', ')) AS request_options
	FROM temp_extras e,
		pizza_runner.pizza_toppings t
	WHERE e.topping_id = t.topping_id
	GROUP BY request_id
),
exclusions_cte AS
(
	SELECT 
		request_id,
		concat('Exclude ', STRING_AGG(t.topping_name, ', ')) AS request_options
	FROM temp_exclusions e,
		pizza_toppings t
	WHERE e.topping_id = t.topping_id
	GROUP BY request_id
),
union_cte AS
(
	SELECT * FROM extras_cte
	UNION
	SELECT * FROM exclusions_cte
)

SELECT 
	c.request_id,
	CONCAT_WS(' - ', p.pizza_name, STRING_AGG(cte.request_options, ' - '))
FROM pizza_runner.customer_orders c
JOIN pizza_runner.pizza_names p
	ON c.pizza_id = p.pizza_id
LEFT JOIN union_cte cte
	ON c.request_id = cte.request_id
GROUP BY c.request_id, p.pizza_name
ORDER BY 1;
```

#### Steps

- `request_id` was added to `customer_orders` to have a primary key, since `order_id` gets repeated -- on data cleaning process. 
- Create 3 CTEs `extras_cte`, `exclusions_cte` and `union_cte`, to transform the information into the intended text format. Then `union_cte` will be combined with `customers_orders` with a **LEFT JOIN**.

#### Answer:
| request_id | concat_ws | 
| :- | :- |
| 1|	Meatlovers|
| 2|	Meatlovers|
| 3|	Meatlovers|
| 4|	Meatlovers - Exclude Cheese|
| 5|	Meatlovers - Exclude Cheese|
| 6|	Vegetarian - Exclude Cheese|
| 7| 	Meatlovers - Extra Bacon, Chicken - Exclude Cheese|
| 8|	Meatlovers - Extra Bacon, Cheese - Exclude BBQ Sauce, Mushrooms|
| 9|	Meatlovers - Extra Bacon|
| 10|	Vegetarian - Extra Bacon|
| 11|	Vegetarian|
| 12|	Vegetarian|
| 13|	Meatlovers|
| 14|	Meatlovers|

---

### 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients

```sql
WITH toppings_cte AS (
	SELECT		
   		pr.pizza_id,
   		pr.topping_id,
   		pt.topping_name
	FROM (
		SELECT p.pizza_id,
   			unnest(string_to_array(p.toppings, ','))::INTEGER AS topping_id
		FROM pizza_runner.pizza_recipes AS p) AS pr
    	JOIN pizza_runner.pizza_toppings AS pt
    		ON pr.topping_id = pt.topping_id 
), 
ingredients_cte AS
(
	SELECT
		c.request_id, 
		p.pizza_name,
	CASE
		WHEN t.topping_id 
		IN (SELECT topping_id FROM temp_extras e WHERE c.request_id = e.request_id)
		THEN concat('2x', t.topping_name)
		ELSE t.topping_name
	END AS topping
	FROM pizza_runner.customer_orders c
	JOIN pizza_runner.pizza_names p
		ON c.pizza_id = p.pizza_id
	JOIN toppings_cte t 
		ON c.pizza_id = t.pizza_id
	WHERE t.topping_id NOT IN (SELECT topping_id FROM temp_exclusions e WHERE c.request_id = e.request_id)
	ORDER BY request_id, topping ASC
)

SELECT 
	request_id,
	CONCAT(pizza_name, ': ', STRING_AGG(topping, ', ')) AS ingredients_list
FROM ingredients_cte
GROUP BY 
	request_id,
	pizza_name;
```

#### Answer:

| request_id | ingredients_list |
| :- | :- |
| 1 |	Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami
| 2 |	Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami
| 3 |	Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami
| 4 |	Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami
| 5 |	Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami
| 6 |	Vegetarian: Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes
| 7 |	Meatlovers: 2xBacon, 2xChicken, BBQ Sauce, Beef, Mushrooms, Pepperoni, Salami
| 8 |	Meatlovers: 2xBacon, 2xCheese, Beef, Chicken, Pepperoni, Salami
| 9 |	Meatlovers: 2xBacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami
| 10 |	Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes
| 11 |	Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes
| 12 |	Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes
| 13 |	Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami
| 14 |	Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami

---

### 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

```sql
WITH toppings_cte AS (
	SELECT		
   		pr.pizza_id,
   		pr.topping_id,
   		pt.topping_name
	FROM (
		SELECT p.pizza_id,
   			unnest(string_to_array(p.toppings, ','))::INTEGER AS topping_id
		FROM pizza_runner.pizza_recipes AS p) AS pr
    	JOIN pizza_runner.pizza_toppings AS pt
    		ON pr.topping_id = pt.topping_id 
), 
ingredients_cte AS
(
	SELECT
		c.request_id,
		TRIM(t.topping_name) AS topping_name,
	CASE
		-- if extra ingredient add 2
		WHEN t.topping_id 
		IN (SELECT topping_id FROM temp_extras e WHERE c.request_id = e.request_id)
		THEN 2
		-- if excluded ingredient add 0
		WHEN t.topping_id
		IN (SELECT topping_id FROM temp_exclusions e WHERE c.request_id = e.request_id)
		THEN 0
		-- if normal ingredient add 1
		ELSE 1
	END AS quantity
	FROM pizza_runner.customer_orders c
	JOIN toppings_cte t 
		ON c.pizza_id = t.pizza_id
)

SELECT topping_name AS ingredient, sum(quantity) AS times_used
FROM ingredients_cte
GROUP BY topping_name
ORDER BY times_used DESC, ingredient ASC;
```

#### Answer:

| ingredient | times_used |
| :- | :- |
| Bacon | 	13|
| Mushrooms |	13|
| Cheese |	11|
| Chicken |	11|
| Beef |	10|
| Pepperoni |	10|
| Salami |	10|
| BBQ Sauce |	9|
| Onions |	4|
| Peppers |	4|
| Tomato Sauce |	4|
| Tomatoes |	4|