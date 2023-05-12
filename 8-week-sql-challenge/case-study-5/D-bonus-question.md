# Case Study #5: Data Mart 🛒

## Solution - C. Before And After Analysis Questions

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-5/sql-syntax/D-bonus-question.sql).

---

### 1. Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

- `region`
- `platform`
- `age_band`
- `demographic`
- `customer_type`

---

Let's start this analysis over each area.

#### Region

```sql
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
```

Total sales for 12 weeks before and after 2020-06-15 by region:

| region | total_12weeks_sales_before | total_12weeks_sales_after | diff_12weeks_sales | sales_12weeks_pcent |
| :- | -: | -: | -: | -: | 
| ASIA|	1637244466|	1583807621|	-53436845|	-3.26|
| OCEANIA|	2354116790|	2282795690|	-71321100|	-3.03|
| SOUTH AMERICA|	213036207|	208452033|	-4584174|	-2.15|
| CANADA|	426438454|	418264441|	-8174013|	-1.92|
| USA|	677013558|	666198715|	-10814843|	-1.60|
| AFRICA|	1709537105|	1700390294|	-9146811|	-0.54|
| EUROPE|	108886567|	114038959|	5152392|	4.73|

- Asia and Oceania had the highest negative impact with percentage higher than 3%, for the 12 weeks after the change.

#### Platform

```sql
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
```

Total sales for 12 weeks before and after 2020-06-15 by region:

| platform | total_12weeks_sales_before | total_12weeks_sales_after | diff_12weeks_sales | sales_12weeks_pcent |
| :- | -: | -: | -: | -: |
| Retail|	6906861113|	6738777279|	-168083834|	-2.43|
| Shopify|	219412034|	235170474|	15758440|	7.18|

- Retail had a decrease in sales of 2.43% when comparing the 12 week time period after the implemented change.
- Shopify has seen an increase in sales of 7.18%, however the difference in sales doesn't compensate the loss from Retail.

#### Age Band

```sql
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
```

Total sales for 12 weeks before and after 2020-06-15 by region:

| age_band | total_12weeks_sales_before | total_12weeks_sales_after | diff_12weeks_sales | sales_12weeks_pcent |
| :- | -: | -: | -: | -: |
| "unknown"|	2764354464|	2671961443|	-92393021|	-3.34|
| Middle Aged|	3560112155|	3507568342|	-52543813|	-1.48|
| Young Adults|	801806528|	794417968|	-7388560|	-0.92|

- Middle Aged is the identified `age_band` that had a decrease in sales of 1.48%.
- The "unknown" category had the overall decrease in sales in 3.34% when comparing the 12 week time period after the implemented change.

#### Demographic

```sql
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
```

Total sales for 12 weeks before and after 2020-06-15 by region:

| demographic | total_12weeks_sales_before | total_12weeks_sales_after | diff_12weeks_sales | sales_12weeks_pcent |
| :- | -: | -: | -: | -: |
| "unknown"|	2764354464|	2671961443|	-92393021|	-3.34|
| Families|	2328329040|	2286009025|	-42320015|	-1.82|
| Couples|	2033589643|	2015977285|	-17612358|	-0.87|

- Families is the identified `demographic` category that had a decrease in sales by 1.82%.
- The "unknown" category had the overall decrease in sales in 3.34% when comparing the 12 week time period after the implemented change.

#### Customer Type

```sql
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
```

Total sales for 12 weeks before and after 2020-06-15 by region:

| customer_type | total_12weeks_sales_before | total_12weeks_sales_after | diff_12weeks_sales | sales_12weeks_pcent |
| :- | -: | -: | -: | -: |
| Guest|	2573436301|	2496233635|	-77202666|	-3.00|
| Existing|	3690116427|	3606243454|	-83872973|	-2.27|
| New|	862720419|	871470664|	8750245|	1.01|

- The customer type that showed the highest decrease is the Guest, with 3%, for the time period of 12 weeks after the implemented change.

##### Answer

- We can conclude that these areas of business had the highest negative impact in sales metrics performance in 2020: sales in Asia and Oceania, retail platform, unknown age, unknown demographic group, and guest customers.

---

### 2. Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

- When the new packaging was changed, did the overall color/brand change as well, to the point the customer couldn't easily recognize the brand? If that happens, it may be needed to do a marketing campaign for customers to get costumed with the rebranding.
- It seems the European market didn't suffer too much because of the change of packaging. Could it be that the market had a good response to the new packaging? Keep using the new packaging in this market, and try to get loyal customers.
- It's hard to use information regarding age and demographics since there are too many unknowns. If possible, gather more information about customers, in order to make use of this information in the future.