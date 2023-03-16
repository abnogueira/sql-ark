-------------------------------
--CASE STUDY #2: PIZZA RUNNER--
-------------------------------

--Author: Anabela Nogueira
--Date: 2023/03/16
--Tool used: Posgres

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
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

--2. What if there was an additional $1 charge for any pizza extras?
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

--3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
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

--4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
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

--5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
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