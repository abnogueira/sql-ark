-------------------------------
--CASE STUDY #2: PIZZA RUNNER--
-------------------------------

--Author: Anabela Nogueira
--Date: 2023/03/09
--Tool used: Posgres

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT date_part('week', registration_date + 3) as signed_week,
	COUNT(runner_id) as total_runners
from pizza_runner.runners
group by signed_week
order by signed_week;

--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
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

--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH prep_time_cte as (
	select
		c.order_id, 
		count(c.order_id) as pizza_order,
		EXTRACT(minute from o.pickup_time - c.order_time) as prep_time_minutes
	from pizza_runner.customer_orders c
	join pizza_runner.runner_orders o
		on c.order_id = o.order_id
	where o.pickup_time is not NULL
	group by c.order_id, o.pickup_time, c.order_time
)
select pizza_order, AVG(prep_time_minutes) as avg_prep_time_mins
from prep_time_cte
group by pizza_order;

--4. What was the average distance travelled for each customer?
SELECT c.customer_id, AVG(o.distance) AS avg_distance_km
FROM pizza_runner.customer_orders c
JOIN pizza_runner.runner_orders o
	ON c.order_id = o.order_id
WHERE o.pickup_time IS NOT NULL
GROUP BY c.customer_id
ORDER BY c.customer_id;

--5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration) - MIN(duration) AS delivery_time_difference
FROM pizza_runner.runner_orders
WHERE duration IS NOT NULL;

--6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT MAX(pizza_delivered) FROM (
	SELECT r.order_id, count(c.order_id) AS pizza_delivered
	FROM pizza_runner.runner_orders r
	JOIN pizza_runner.customer_orders c
		ON r.order_id = c.order_id
	WHERE r.distance NOT LIKE 'null'
	GROUP BY r.order_id
) AS orders;

--7. What is the successful delivery percentage for each runner?
SELECT
	runner_id,
	round(100 * SUM(
		CASE WHEN duration IS NULL THEN 0
		ELSE 1 END) / COUNT(*), 0) AS success_perc
FROM pizza_runner.runner_orders
GROUP BY runner_id
ORDER BY runner_id;