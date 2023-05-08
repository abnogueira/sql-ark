----------------------------
--CASE STUDY #5: DATA MART--
----------------------------

--Author: Anabela Nogueira
--Date: 2023/05/08
--Tool used: Posgresql

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. What is the total sales for the 4 weeks before and after `2020-06-15`? What is the growth or reduction rate in actual values and percentage of sales?
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

--2. What about the entire 12 weeks before and after?
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

--3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
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