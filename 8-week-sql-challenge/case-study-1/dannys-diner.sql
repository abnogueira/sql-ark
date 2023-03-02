--------------------------------
--CASE STUDY #1: DANNY'S DINER--
--------------------------------

--Author: Anabela Nogueira
--Date: 2/03/2023
--Tool used: Posgres

CREATE SCHEMA dannys_diner;

CREATE TABLE sales (
    "customer_id" VARCHAR(1),
    "order_date" DATE,
    "product_id" INTEGER
);

INSERT INTO sales
    ("customer_id", "order_date", "product_id")
VALUES
    ('A', '2021-01-01', '1'),
    ('A', '2021-01-01', '2'),
    ('A', '2021-01-07', '2'),
    ('A', '2021-01-10', '3'),
    ('A', '2021-01-11', '3'),
    ('A', '2021-01-11', '3'),
    ('B', '2021-01-01', '2'),
    ('B', '2021-01-02', '2'),
    ('B', '2021-01-04', '1'),
    ('B', '2021-01-11', '1'),
    ('B', '2021-01-16', '3'),
    ('B', '2021-02-01', '3'),
    ('C', '2021-01-01', '3'),
    ('C', '2021-01-01', '3'),
    ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
    "product_id" INTEGER,
    "product_name" VARCHAR(5),
    "price" INTEGER
);

INSERT INTO menu
    ("product_id", "product_name", "price")
VALUES
    ('1', 'sushi', '10'),
    ('2', 'curry', '15'),
    ('3', 'ramen', '12');
  

CREATE TABLE members (
    "customer_id" VARCHAR(1),
    "join_date" DATE
);

INSERT INTO members
    ("customer_id", "join_date")
VALUES
    ('A', '2021-01-07'),
    ('B', '2021-01-09');

SELECT *
FROM public.members;

SELECT *
FROM public.menu;

SELECT *
FROM public.sales;

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(price) AS total
FROM sales AS s
JOIN menu AS m
    ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY customer_id; 

--2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT(order_date)) AS visit_count
FROM sales
GROUP BY customer_id;

--3. What was the first item from the menu purchased by each customer?
WITH ordered_sales_cte AS
(
   SELECT s.customer_id, m.product_name, 
      ROW_NUMBER() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date) AS rank
   FROM sales AS s
   INNER JOIN menu AS m
      ON s.product_id = m.product_id
)

SELECT customer_id, product_name
FROM ordered_sales_cte
WHERE rank = 1;

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT COUNT(s.product_id) AS most_purchased, product_name
FROM sales AS s
INNER JOIN menu AS m
   ON s.product_id = m.product_id
GROUP BY s.product_id, product_name
ORDER BY most_purchased DESC
LIMIT 1;

--5. Which item was the most popular for each customer?
WITH popular_sales_cte AS
(
   SELECT s.customer_id, m.product_name, COUNT(m.product_id) AS order_count,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY COUNT(s.customer_id) DESC) AS rank
   FROM menu AS m
   INNER JOIN sales AS s
      ON m.product_id = s.product_id
   GROUP BY s.customer_id, m.product_name
)

SELECT customer_id, product_name, order_count
FROM popular_sales_cte 
WHERE rank = 1;

--6. Which item was purchased first by the customer after they became a member?
WITH member_sales_cte AS 
(
   SELECT s.customer_id, mb.join_date, s.order_date, s.product_id,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date) AS rank
   FROM sales AS s
   JOIN members AS mb
      ON s.customer_id = mb.customer_id
   WHERE s.order_date >= mb.join_date
)

SELECT s.customer_id, s.order_date, m.product_name 
FROM member_sales_cte AS s
JOIN menu AS m
   ON s.product_id = m.product_id
WHERE rank = 1;

--7. Which item was purchased just before the customer became a member?
WITH prior_member_sales_cte AS 
(
   SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
         DENSE_RANK() OVER(PARTITION BY s.customer_id
         ORDER BY s.order_date DESC) AS rank
   FROM sales AS s
   JOIN members AS m
      ON s.customer_id = m.customer_id
   WHERE s.order_date < m.join_date
)

SELECT s.customer_id, s.order_date, m.product_name 
FROM prior_member_sales_cte AS s
JOIN menu AS m
   ON s.product_id = m.product_id
WHERE rank = 1;

--8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, COUNT(DISTINCT s.product_id), 
   SUM(m.price) AS spent
FROM sales AS s
JOIN members AS mb
   ON s.customer_id = mb.customer_id
JOIN menu AS m
   ON s.product_id = m.product_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id;

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?
WITH price_points AS
(
   SELECT *, 
      CASE
         WHEN product_id = 1 THEN price * 20
         ELSE price * 10
      END AS points
   FROM menu
)

SELECT s.customer_id, SUM(p.points) AS total_points
FROM sales AS s
JOIN price_points AS p
   ON p.product_id = s.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?
WITH dates_cte AS (				
	SELECT *,
		(m.join_date + interval '6 days')::date AS valid_date	
	FROM members as m			
)

SELECT d.customer_id			
    , SUM(CASE
	    WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price		
		WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price		
		ELSE 10 * m.price		
		END) AS points		
FROM dates_cte AS d
JOIN sales AS s
	ON d.customer_id = s.customer_id
JOIN menu AS m
	ON s.product_id = m.product_id
WHERE s.order_date < '2021-01-31'::date
GROUP BY d.customer_id;

--11. Bonus Question - Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)
SELECT s.customer_id, s.order_date, m.product_name, m.price,
	(CASE
		WHEN mb.join_date <= s.order_date THEN 'Y'
		ELSE 'N'
	END) AS member
FROM sales AS s
JOIN menu AS m 
	ON m.product_id = s.product_id
LEFT JOIN members AS mb
	ON mb.customer_id = s.customer_id
ORDER BY s.customer_id, s.order_date;

--12. Bonus Question - Rank All The Things - Danny also requires further information about the `ranking` of customer products, but he purposely does not need the ranking for non-member purchases so he expects null `ranking` values for the records when customers are not yet part of the loyalty program.
WITH all_the_things_cte AS(
    SELECT s.customer_id, s.order_date, m.product_name, m.price,
        (CASE
		    WHEN mb.join_date <= s.order_date THEN 'Y'
		    ELSE 'N'
        END) AS member
    FROM sales AS s
    JOIN menu AS m 
        ON m.product_id = s.product_id
    LEFT JOIN members AS mb
        ON mb.customer_id = s.customer_id
    ORDER BY s.customer_id, s.order_date;
)

SELECT *,
	(CASE
		WHEN member = 'N' THEN NULL
        ELSE 
            RANK() OVER(PARTITION BY customer_id, member
            ORDER BY order_date)
	END) AS ranking
FROM all_the_things_cte;
