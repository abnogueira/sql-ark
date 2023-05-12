----------------------------
--CASE STUDY #5: DATA MART--
----------------------------

--Author: Anabela Nogueira
--Date: 2023/05/08
--Tool used: Posgresql

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?
--Region
WITH total_weeks_sales_cte AS (
	SELECT region,
		SUM(CASE WHEN(week_number >= 25 - 12 AND week_number < 25) THEN sales ELSE 0 END) AS total_12weeks_sales_before,
		SUM(CASE WHEN(week_number >= 25 AND week_number < 25 + 12) THEN sales ELSE 0 END) AS total_12weeks_sales_after
	FROM clean_weekly_sales
	WHERE calendar_year = 2020
	GROUP BY 1
)
SELECT region,
	total_12weeks_sales_before, 
	total_12weeks_sales_after,
	(total_12weeks_sales_before - total_12weeks_sales_after) AS diff_12weeks_sales,
	ROUND((total_12weeks_sales_after - total_12weeks_sales_before)::decimal / 
		ABS(total_12weeks_sales_before) * 100.0, 2) AS sales_12weeks_pcent
FROM total_weeks_sales_cte
ORDER BY 5;

--Platform
WITH total_weeks_sales_cte AS (
	SELECT platform,
		SUM(CASE WHEN(week_number >= 25 - 12 AND week_number < 25) THEN sales ELSE 0 END) AS total_12weeks_sales_before,
		SUM(CASE WHEN(week_number >= 25 AND week_number < 25 + 12) THEN sales ELSE 0 END) AS total_12weeks_sales_after
	FROM clean_weekly_sales
	WHERE calendar_year = 2020
	GROUP BY 1
)
SELECT platform,
	total_12weeks_sales_before, 
	total_12weeks_sales_after,
	(total_12weeks_sales_before - total_12weeks_sales_after) AS diff_12weeks_sales,
	ROUND((total_12weeks_sales_after - total_12weeks_sales_before)::decimal / 
		ABS(total_12weeks_sales_before) * 100.0, 2) AS sales_12weeks_pcent
FROM total_weeks_sales_cte
ORDER BY 5;

--Age Band
WITH total_weeks_sales_cte AS (
	SELECT age_band,
		SUM(CASE WHEN(week_number >= 25 - 12 AND week_number < 25) THEN sales ELSE 0 END) AS total_12weeks_sales_before,
		SUM(CASE WHEN(week_number >= 25 AND week_number < 25 + 12) THEN sales ELSE 0 END) AS total_12weeks_sales_after
	FROM clean_weekly_sales
	WHERE calendar_year = 2020
	GROUP BY 1
)
SELECT age_band,
	total_12weeks_sales_before, 
	total_12weeks_sales_after,
	(total_12weeks_sales_before - total_12weeks_sales_after) AS diff_12weeks_sales,
	ROUND((total_12weeks_sales_after - total_12weeks_sales_before)::decimal / 
		ABS(total_12weeks_sales_before) * 100.0, 2) AS sales_12weeks_pcent
FROM total_weeks_sales_cte
ORDER BY 5;

--Demographic
WITH total_weeks_sales_cte AS (
	SELECT demographic,
		SUM(CASE WHEN(week_number >= 25 - 12 AND week_number < 25) THEN sales ELSE 0 END) AS total_12weeks_sales_before,
		SUM(CASE WHEN(week_number >= 25 AND week_number < 25 + 12) THEN sales ELSE 0 END) AS total_12weeks_sales_after
	FROM clean_weekly_sales
	WHERE calendar_year = 2020
	GROUP BY 1
)
SELECT demographic,
	total_12weeks_sales_before, 
	total_12weeks_sales_after,
	(total_12weeks_sales_before - total_12weeks_sales_after) AS diff_12weeks_sales,
	ROUND((total_12weeks_sales_after - total_12weeks_sales_before)::decimal / 
		ABS(total_12weeks_sales_before) * 100.0, 2) AS sales_12weeks_pcent
FROM total_weeks_sales_cte
ORDER BY 5;

--Customer Type
WITH total_weeks_sales_cte AS (
	SELECT customer_type,
		SUM(CASE WHEN(week_number >= 25 - 12 AND week_number < 25) THEN sales ELSE 0 END) AS total_12weeks_sales_before,
		SUM(CASE WHEN(week_number >= 25 AND week_number < 25 + 12) THEN sales ELSE 0 END) AS total_12weeks_sales_after
	FROM clean_weekly_sales
	WHERE calendar_year = 2020
	GROUP BY 1
)
SELECT customer_type,
	total_12weeks_sales_before, 
	total_12weeks_sales_after,
	(total_12weeks_sales_before - total_12weeks_sales_after) AS diff_12weeks_sales,
	ROUND((total_12weeks_sales_after - total_12weeks_sales_before)::decimal / 
		ABS(total_12weeks_sales_before) * 100.0, 2) AS sales_12weeks_pcent
FROM total_weeks_sales_cte
ORDER BY 5;