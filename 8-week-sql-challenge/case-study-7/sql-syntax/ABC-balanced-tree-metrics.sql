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
FROM balanced_tree.sales s

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
FROM cte_transactions

--------------------------
--CASE C STUDY QUESTIONS--
--   PRODUCT ANALYSIS   --
--------------------------