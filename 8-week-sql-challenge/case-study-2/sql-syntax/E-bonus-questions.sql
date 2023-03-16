-------------------------------
--CASE STUDY #2: PIZZA RUNNER--
-------------------------------

--Author: Anabela Nogueira
--Date: 2023/03/16
--Tool used: Posgres

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
WITH ins_pizza_name_cte AS (
    INSERT INTO pizza_runner.pizza_names(pizza_id, pizza_name)
    VALUES (3, 'Supreme')
    RETURNING pizza_id
)
INSERT INTO pizza_runner.pizza_recipes(pizza_id, toppings)
SELECT pizza_id, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12' FROM ins_pizza_name_cte;