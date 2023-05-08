# Case Study #5: Data Mart 🛒

## Solution - C. Before And After Analysis Questions

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-5/sql-syntax/B-data-exploration.sql).

---

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the `week_date` value of `2020-06-15` as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all `week_date` values for `2020-06-15` as the start of the period **after** the change and the previous `week_date` values would be **before**

Using this analysis approach - answer the following questions:

### 1. What is the total sales for the 4 weeks before and after `2020-06-15`? What is the growth or reduction rate in actual values and percentage of sales?

```sql
WITH total_weeks_sales_cte AS (
	SELECT 
		SUM(CASE WHEN(week_number >= 25 - 4 AND week_number < 25) THEN sales ELSE 0 END) AS total_4weeks_sales_before,
		SUM(CASE WHEN(week_number >= 25 AND week_number < 25 + 4) THEN sales ELSE 0 END) AS total_4weeks_sales_after
	FROM clean_weekly_sales
	WHERE calendar_year = 2020
)
SELECT total_4weeks_sales_before, total_4weeks_sales_after,
	(total_4weeks_sales_before - total_4weeks_sales_after) AS diff_4weeks_sales,
	ROUND((total_4weeks_sales_after - total_4weeks_sales_before)::decimal / 
		ABS(total_4weeks_sales_before) * 100.0, 2) AS sales_4weeks_pcent
FROM total_weeks_sales_cte;
```

#### Steps

- My first approach was to select the data for the query by adding/ substracting an `interval '4weeks'`, but on question 3 we need to compare the same week interval for multiple years. So, it was easier to calculate using the week number, then I remade questions 1 and 2, accordingly with the query on question 3.
- To know which week number has the date `2020-06-15`, I ran the following query:

	```sql
	SELECT DISTINCT week_number
	FROM clean_weekly_sales
	WHERE week_date = '2020-06-15'; -- week_number = 25
	```

- The date `2020-06-15` is considered the first day, where the change was implemented, so it is excluded from the 'before' period and included in the 'after' period.

#### Answer:

| total_sales_before | total_sales_after | difference | sales_pcent |
| :-:| :-:| :-:| :-:|
| 2,345,878,357 | 2,318,994,169| -26,884,188| -1.15|

- There was a decrease of 1.15% on the amount of sales since the new sustainable packaging came into effect.

---

### 2. What about the entire 12 weeks before and after?

```sql
WITH total_week_sales_cte AS (
	SELECT 
		SUM(CASE WHEN (week_number >= 25 - 12 AND week_number < 25) THEN sales ELSE 0 END) AS total_12weeks_sales_before,
		SUM(CASE WHEN (week_number >= 25 AND week_number < 25 + 12) THEN sales ELSE 0 END) AS total_12weeks_sales_after
	FROM clean_weekly_sales
	WHERE calendar_year = 2020
)
SELECT 
	total_sales_before, total_sales_after,
	(total_sales_after - total_sales_before) AS difference,
	ROUND((total_sales_after - total_sales_before)::decimal / 
		ABS(total_sales_before) * 100.0, 2) AS sales_pcent
FROM total_week_sales_cte;
```

#### Answer:

| total_sales_before | total_sales_after | difference | sales_pcent |
| :-:| :-:| :-:| :-:|
| 7,126,273,147| 6,973,947,753| -152,325,394| -2.14|

- There was a decrease of 2.14% on the amount of sales since the new sustainable packaging came into effect, when we are comparing 3 month before and after. The new packaging could be the reason why.

---

### 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

```sql
WITH total_weeks_sales_cte AS (
	SELECT calendar_year,
		SUM(CASE WHEN (week_number >= 25 - 4 AND week_number < 25) THEN sales ELSE 0 END) AS total_4weeks_sales_before,
		SUM(CASE WHEN (week_number >= 25 AND week_number < 25 + 4) THEN sales ELSE 0 END) AS total_4weeks_sales_after,
		SUM(CASE WHEN (week_number >= 25 - 12 AND week_number < 25) THEN sales ELSE 0 END) AS total_12weeks_sales_before,
		SUM(CASE WHEN (week_number >= 25 AND week_number < 25 + 12) THEN sales ELSE 0 END) AS total_12weeks_sales_after
	FROM clean_weekly_sales
	GROUP BY 1
	ORDER BY 1
)
SELECT calendar_year, total_4weeks_sales_before, total_4weeks_sales_after,
	(total_4weeks_sales_after - total_4weeks_sales_before) AS diff_4weeks_sales,
	ROUND((total_4weeks_sales_after - total_4weeks_sales_before)::decimal / 
		ABS(total_4weeks_sales_before) * 100.0, 2) AS sales_4weeks_pcent,
	total_12weeks_sales_before, total_12weeks_sales_after,
	(total_12weeks_sales_after total_12weeks_sales_before) as diff_12weeks_sales,
	ROUND((total_12weeks_sales_after - total_12weeks_sales_before)::decimal / 
		ABS(total_12weeks_sales_before) * 100.0, 2) AS sales_12weeks_pcent
FROM total_weeks_sales_cte;
```

#### Answer:

| calendar_year | total_4weeks_sales_before | total_4weeks_sales_after | diff_4weeks_sales | sales_4weeks_pcent | total_12weeks_sales_before | total_12weeks_sales_after | diff_12weeks_sales | sales_12weeks_pcent
|:-:| :-:| :-:| :-:| :-:| :-:| :-:| :-:| :-:|
| 2018|	2,125,140,809|	2,129,242,914|	4,102,105|	0.19|	6,396,562,317|	6,500,818,510|	104,256,193| 1.63|
| 2019|	2,249,989,796| 2,252,326,390| 2,336,594| 0.10| 6,883,386,397|	6,862,646,103| -20,740,294| -0.30|
| 2020|	2,345,878,357|	2,318,994,169|	-26,884,188|	-1.15|	7,126,273,147|	6,973,947,753|	-152,325,394|	-2.14|

- In the previous years of 2018 and 2019, when comparing 4 weeks before and after week 25, there was a small increase in sales, at an average of 0.15%. However, after the new packaging was implemented in 2020, there was a decrease in sales, which is higher than the positive increase in those previous years, for the same time period.
- When comparing 12 weeks before and after week 25, which is 3 times longer than the previous comparison. In the years of 2019 and 2020 there was a decrease in sales for the same time period. While in 2018 there was an increase of 1.63% in sales. However, since the decrease is higher in 2020, translates that the new packaging could have a negative effect on sales.
