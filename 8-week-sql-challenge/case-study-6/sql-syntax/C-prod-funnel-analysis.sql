------------------------------
--CASE STUDY #6: CLIQUE BAIT--
------------------------------

--Author: Anabela Nogueira
--Date: 2023/05/17
--Tool used: Posgresql

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. Using a single SQL query - create a new output table which has given details:
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

--2. Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.
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

--3.1. Which product had the most views, cart adds and purchases?
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

--3.2. Which product was most likely to be abandoned?
SELECT product_name, total_abandoned
FROM clique_bait.product_stats
ORDER BY 2 DESC
LIMIT 1

--3.3. Which product had the highest view to purchase percentage?
SELECT product_name, 
	ROUND(100.0 * total_purchases / total_views, 2) AS purchase_per_view_pcent
FROM clique_bait.product_stats
ORDER BY 2 DESC
LIMIT 1

--3.4. What is the average conversion rate from view to cart add?
SELECT 
	ROUND(100.0 * SUM(total_added_to_cart) / SUM(total_views), 1) as avg_view_to_cart_rate
FROM clique_bait.product_category_stats

--3.5. What is the average conversion rate from cart add to purchase?
SELECT 
	ROUND(100.0 * SUM(total_added_to_cart) / SUM(total_views), 1) as avg_view_to_cart_rate
FROM clique_bait.product_category_stats