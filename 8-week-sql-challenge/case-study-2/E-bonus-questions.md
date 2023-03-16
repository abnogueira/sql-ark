# Case Study #2: Pizza Runner 🍕

## Solution - E. Bonus Questions

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/CASE-study-2/sql-syntax/E-bonus-questions.sql).

---

### 1. If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

```sql
WITH ins_pizza_name_cte AS (
    INSERT INTO pizza_runner.pizza_names(pizza_id, pizza_name)
    VALUES (3, 'Supreme')
    RETURNING pizza_id
)
INSERT INTO pizza_runner.pizza_recipes(pizza_id, toppings)
SELECT pizza_id, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12' FROM ins_pizza_name_cte;
```

#### Steps

- In order to insert a new recipe into table `pizza_recipes`, it's also important to add an entry to the table `pizza_names` with the new `pizza_id`. To prevent problems with IDs, let's make an insert that inserts data into both tables at the same time with the help of a *CTE*.

#### Answer:

- Table `pizza_names` is now:

| pizza_id | pizza_name |
| :-: | :- |
| 1 |	Meatlovers|
| 2 |	Vegetarian|
| 3 |	Supreme|

- Table `pizza_recipes` is now:

| pizza_id | toppings |
| :-: | :- |
| 1 |	1, 2, 3, 4, 5, 6, 8, 10|
| 2 |	4, 6, 7, 9, 11, 12|
| 3	| 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12|