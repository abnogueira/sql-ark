-------------------------------
--CASE STUDY #2: PIZZA RUNNER--
-------------------------------

--Author: Anabela Nogueira
--Date: 2023/03/14
--Tool used: Posgres

-----------------
--DATA CLEANING--
-----------------


--Add request_id as a primary key to customer_orders table
ALTER TABLE pizza_runner.customer_orders
ADD column request_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY;


--Temp table for extras ingredients
CREATE temporary TABLE temp_extras AS (
	SELECT c.request_id,
		unnest(string_to_array(c.extras, ','))::INTEGER AS topping_id
	FROM pizza_runner.customer_orders AS c
	WHERE c.extras IS NOT NULL
);

--Temp table for exclusion ingredients
CREATE temporary TABLE temp_exclusions AS (
	SELECT		
		c.request_id,
		unnest(string_to_array(c.exclusions, ','))::INTEGER AS topping_id
	FROM pizza_runner.customer_orders as c
	WHERE c.exclusions IS NOT NULL
);

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. What are the standard ingredients for each pizza?
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

--2. What was the most commonly added extra?
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

--3. What was the most common exclusion?
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

--4. Generate an order item for each record in the customers_orders table
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

--5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
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

--6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
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