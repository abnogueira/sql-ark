----------------------------
--CASE STUDY #5: DATA MART--
----------------------------

--Author: Anabela Nogueira
--Date: 2023/05/01
--Tool used: Posgresql

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. What day of the week is used for each `week_date` value?
SELECT DISTINCT TO_CHAR(week_date, 'day') AS day_of_week
FROM clean_weekly_sales;

--2. What range of week numbers are missing from the dataset?
SELECT generate_series(1, 52) AS missing_week_numbers
EXCEPT SELECT week_number FROM clean_weekly_sales
ORDER BY missing_week_numbers ASC;

--3. How many total transactions were there for each year in the dataset?
SELECT calendar_year, SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY 1;

--4. What is the total sales for each region for each month?
SELECT region, month_number, SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY 1;

--5. What is the total count of transactions for each platform?
SELECT platform, SUM(transactions) AS transactions_count
FROM clean_weekly_sales
GROUP BY platform;

--6. What is the percentage of sales for Retail vs Shopify for each month?
WITH total_monthly_sales_cte AS (
	SELECT calendar_year, month_number, SUM(sales) AS total_sales
	FROM clean_weekly_sales
	GROUP BY 1, 2
	ORDER BY 1, 2
)
SELECT c.calendar_year, c.month_number, c.platform, 
	ROUND(100.0 * SUM(c.sales) / t.total_sales, 1) AS pcent_sales
FROM clean_weekly_sales c
JOIN total_monthly_sales_cte t
	ON c.calendar_year = t.calendar_year AND 
	c.month_number = t.month_number
GROUP BY c.calendar_year, c.month_number, c.platform, t.total_sales
ORDER BY c.calendar_year, c.month_number, c.platform;

--7. What is the percentage of sales by demographic for each year in the dataset?
WITH total_yearly_sales_cte AS (
	SELECT calendar_year, SUM(sales) AS total_sales
	FROM clean_weekly_sales
	GROUP BY 1
	ORDER BY 1
)
SELECT c.calendar_year, c.demographic, 
	ROUND((SUM(c.sales)::decimal / t.total_sales) * 100, 1) AS pcent_sales
FROM clean_weekly_sales c
JOIN total_yearly_sales_cte t
	ON c.calendar_year = t.calendar_year
GROUP BY c.calendar_year, c.demographic, t.total_sales
ORDER BY c.calendar_year, c.demographic;

--8. Which `age_band` and `demographic` values contribute the most to Retail sales?
SELECT c.age_band, c.demographic, 
	ROUND((SUM(c.sales)::decimal / 
		(SELECT SUM(sales)
		FROM clean_weekly_sales 
		WHERE platform = 'Retail')
	) * 100, 1) AS retail_sales_pcent
FROM clean_weekly_sales c
WHERE platform = 'Retail'
GROUP BY 1, 2
ORDER BY 3 DESC;

--9. Can we use the `avg_transaction` column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT calendar_year,
	platform,
	ROUND(SUM(sales)::decimal/SUM(transactions), 2) AS correct_avg_transact,
    ROUND(AVG(avg_transaction)::decimal, 2) AS incorrect_avg_transact
FROM clean_weekly_sales
GROUP BY 1, 2
ORDER BY 1, 2;