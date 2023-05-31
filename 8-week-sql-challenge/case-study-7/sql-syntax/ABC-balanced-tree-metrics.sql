--------------------------------
--CASE STUDY #7: BALANCED TREE--
--------------------------------

--Author: Anabela Nogueira
--Date: 2023/05/23
--Tool used: Posgresql

-----------------------------
-- CASE A STUDY QUESTIONS ---
--HIGH LEVEL SALES ANALYSIS--
-----------------------------

--1. What was the total quantity sold for all products?
--2. What is the total generated revenue for all products before discounts?
--3. What was the total discount amount for all products?
SELECT SUM(s.qty) AS total_products,
    SUM(s.qty * s.price) AS total_revenue_wo_discounts,
    SUM(ROUND(s.qty * s.price * (s.discount/ 100.0), 2)) AS total_discounts
FROM balanced_tree.sales s;

--------------------------
--CASE B STUDY QUESTIONS--
-- TRANSACTION ANALYSIS --
--------------------------

--1. How many unique transactions were there?
--2. What is the average unique products purchased in each transaction?
--3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
--4. What is the average discount value per transaction?
--5. What is the percentage split of all transactions for members vs non-members?
--6. What is the average revenue for member transactions and non-member transactions?
WITH cte_transactions AS (
    SELECT s.txn_id,
        s."member",
        s.discount AS discount_value,
        COUNT(DISTINCT s.prod_id) AS unique_prods,
        SUM(s.qty * s.price) - SUM((s.discount/100.0) * s.qty * s.price) AS total_revenue
    FROM balanced_tree.sales s
    GROUP BY s.txn_id, s."member", s.discount
)
SELECT COUNT(txn_id) AS unique_txn,
    ROUND(AVG(unique_prods), 2) AS avg_unique_prods_per_txn, 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_revenue ASC) AS percentile_25,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_revenue ASC) AS percentile_50,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_revenue ASC) AS percentile_75,
    AVG(discount_value) AS avg_discount,
    100.0 * SUM(CASE WHEN "member" IS TRUE THEN 1 ELSE 0 END)/ COUNT(*) AS pcent_txn_members,
    100.0 * SUM(CASE WHEN "member" IS FALSE THEN 1 ELSE 0 END)/ COUNT(*) AS pcent_txn_non_members,
    ROUND(AVG(CASE WHEN "member" IS TRUE THEN total_revenue ELSE NULL END), 2) AS avg_revenue_member,
    ROUND(AVG(CASE WHEN "member" IS FALSE THEN total_revenue ELSE NULL END), 2) AS avg_revenue_non_member
FROM cte_transactions;

--------------------------
--CASE C STUDY QUESTIONS--
--   PRODUCT ANALYSIS   --
--------------------------

--1. What are the top 3 products by total revenue before discount?
SELECT p.product_name,
    TO_CHAR(SUM(s.qty * s.price), '999,999') AS gross_revenue_total
FROM balanced_tree.sales AS s
JOIN balanced_tree.product_details AS p 
    ON s.prod_id = p.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

--2. What is the total quantity, revenue and discount for each segment?
--3. What is the top selling product for each segment?
--7. What is the percentage split of revenue by segment for each category?
WITH cte_prd_segment AS (
    SELECT p.category_name,
        p.segment_name,
        p.product_name,
        SUM(s.qty) AS total_qty,
        SUM(s.qty * s.price) AS gross_revenue,
        SUM(s.qty * s.price - discount) AS total_net_revenue,
        ROUND((s.qty * s.price) * (s.discount::NUMERIC / 100), 1) AS discount,
        ROW_NUMBER() OVER(PARTITION BY segment_name ORDER BY SUM(s.qty) DESC) AS qty_rank_nb,
        ROUND(100.0 * SUM(s.qty * s.price) / SUM(SUM(s.qty * s.price)) 
            OVER(PARTITION BY category_name), 2) AS revenue_split_pcent
    FROM balanced_tree.sales AS s
    JOIN balanced_tree.product_details AS p 
        ON s.prod_id = p.product_id
    GROUP BY p.category_name, p.segment_name, p.product_name, s.qty, s.price, s.discount
)
SELECT ps.category_name,
    ps.segment_name,
    tp.top_product,
    SUM(ps.total_qty) AS quantity_by_segment,
    SUM(ps.gross_revenue) - SUM(ps.discount) AS net_revenue_by_segment,
    SUM(ps.discount) AS total_discount_by_segment,
    SUM(ps.revenue_split_pcent) AS revenue_split_pcent
FROM cte_prd_segment ps
LEFT JOIN (
    SELECT segment_name, top_product 
    FROM (
        SELECT segment_name,
            product_name AS top_product,
            total_qty,
            gross_revenue
        FROM cte_prd_segment
        WHERE qty_rank_nb = 1
        GROUP BY segment_name, product_name, total_qty, gross_revenue
        ORDER BY total_qty DESC, gross_revenue DESC) AS a
    ) AS tp
    on ps.segment_name = tp.segment_name
GROUP BY ps.category_name, ps.segment_name, tp.top_product
ORDER BY 4 DESC;

--4. What is the total quantity, revenue and discount for each category?
--5. What is the top selling product for each category?
--8. What is the percentage split of total revenue by category?
WITH cte_prd_category AS (
    SELECT p.category_name,
        p.product_name,
        SUM(s.qty) AS total_qty,
        SUM(s.qty * s.price) AS gross_revenue,
     ROUND(SUM(s.qty * s.price * s.discount::NUMERIC / 100), 1) AS discount,
        ROW_NUMBER() OVER(PARTITION BY category_name ORDER BY SUM(s.qty) DESC) AS qty_rank_nb
    FROM balanced_tree.sales AS s
    JOIN balanced_tree.product_details AS p 
        ON s.prod_id = p.product_id
    GROUP BY p.category_name, p.product_name
),
cte_top_selling_prd_cat AS (
    SELECT category_name,
        product_name AS top_product
    FROM cte_prd_category
    WHERE qty_rank_nb = 1
)
SELECT pc.category_name,
    SUM(total_qty) AS quantity,
    SUM(gross_revenue - discount) AS total_net_revenue,
    SUM(discount) AS total_discount,
    ROUND(100.0 * SUM(gross_revenue) / (SELECT SUM(gross_revenue) FROM cte_prd_category), 2) AS revenue_split_pcent,
    tc.top_product
FROM cte_prd_category pc
JOIN cte_top_selling_prd_cat tc
    ON pc.category_name = tc.category_name
GROUP BY 1, 6
ORDER BY 2 DESC;

--6. What is the percentage split of revenue by product for each segment?
--9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
SELECT segment_name,
    p.product_name,
    ROUND(100.0 * COUNT(*)::decimal/
        (SELECT COUNT(DISTINCT txn_id) FROM balanced_tree.sales), 2) AS penetration_pcent,
    ROUND(100.0 * SUM(s.qty * s.price) / SUM(SUM(s.qty * s.price)) 
        OVER(PARTITION BY segment_name), 2) AS revenue_split_pcent
FROM balanced_tree.sales s
JOIN balanced_tree.product_details p
    ON s.prod_id = p.product_id
GROUP BY 1, 2;

--10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
WITH cte_products AS(
    SELECT txn_id, product_name
    FROM balanced_tree.sales AS s
    JOIN balanced_tree.product_details AS pd ON s.prod_id = pd.product_id
),
cte_prod_combinations AS (
    SELECT p.product_name AS product_1,
        p1.product_name AS product_2,
        p2.product_name AS product_3,
        COUNT(*) AS times_bought_together,
        ROW_NUMBER() OVER(ORDER BY COUNT(*) DESC) AS combination_rank
    FROM cte_products AS p
    JOIN cte_products AS p1 ON p.txn_id = p1.txn_id
        AND p.product_name != p1.product_name
        AND p.product_name < p1.product_name
    JOIN cte_products AS p2 ON p.txn_id = p2.txn_id
        AND p.product_name != p2.product_name
        AND p1.product_name != p2.product_name
        AND p.product_name < p2.product_name
        AND p1.product_name < p2.product_name
    GROUP BY
        p.product_name,
        p1.product_name,
        p2.product_name
)
SELECT product_1, product_2, product_3,
    times_bought_together
FROM cte_prod_combinations
WHERE combination_rank = 1;