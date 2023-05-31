--------------------------------
--CASE STUDY #7: BALANCED TREE--
--------------------------------

--Author: Anabela Nogueira
--Date: 2023/05/31
--Tool used: Posgresql

-----------------------------
-- CASE E STUDY QUESTIONS ---
-----------------------------

--Use a single SQL query to transform the `product_hierarchy` and `product_prices` datasets to the `product_details` table.
SELECT product_id,
    pp.price,
    CONCAT(ph.level_text, ' ',ph1.level_text, ' - ', ph2.level_text) AS product_name,
    ph2.id AS category_id,
    ph1.id AS segment_id,
    ph.id AS style_id,
    ph2.level_text AS category_name,
    ph1.level_text AS segment_name,
    ph.level_text AS style_name
FROM balanced_tree.product_hierarchy ph
JOIN balanced_tree.product_hierarchy AS ph1
    ON ph.parent_id = ph1.id
JOIN balanced_tree.product_hierarchy AS ph2
    ON ph1.parent_id = ph2.id
JOIN balanced_tree.product_prices AS pp
    ON ph.id = pp.id;