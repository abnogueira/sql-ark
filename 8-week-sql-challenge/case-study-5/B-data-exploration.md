# Case Study #5: Data Mart 🛒

## Solution - B. Data Exploration Questions

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-5/sql-syntax/B-data-exploration.sql).

---

### 1. What day of the week is used for each `week_date` value?

```sql
SELECT DISTINCT TO_CHAR(week_date, 'day') AS day_of_week
FROM clean_weekly_sales;
```

#### Answer:

| day_of_week |
|:-:|
| monday |

---

### 2. What range of week numbers are missing from the dataset?

```sql
SELECT generate_series(1, 52) AS missing_week_numbers
EXCEPT SELECT week_number FROM clean_weekly_sales
ORDER BY missing_week_numbers ASC;
```

#### Answer:

| missing_week_numbers |
|:-:|
| 1 |
| 2|
| 3|
| 4|
| 5|
| 6|
| 7|
| 8|
| 9|
| 10|
| 11|
| 12|
| 37|
| 38|
| 39|
| 40|
| 41|
| 42|
| 43|
| 44|
| 45|
| 46|
| 47|
| 48|
| 49|
| 50|
| 51|
| 52|

- The missing week numbers are the weeks from 1 to 12, and from 37 until 52.

---

### 3. How many total transactions were there for each year in the dataset?

```sql
SELECT calendar_year, SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY 1;
```

#### Answer:

| calendar_year | total_transactions |
| -: | -:|
| 2018|	346406460|
| 2019|	365639285|
| 2020|	375813651|

---

### 4. What is the total sales for each region for each month?

```sql
SELECT region, month_number, SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY 1;
```

#### Answer:

| region | month_number | total_sales |
| :- | :-: | -:|
| AFRICA|	3|	567767480
| AFRICA|	4|	1911783504
| AFRICA|	5|	1647244738
| AFRICA|	6|	1767559760
| AFRICA|	7|	1960219710
| AFRICA|	8|	1809596890
| AFRICA|	9|	276320987
| ASIA|	3|	529770793
| ASIA|	4|	1804628707
| ASIA|	5|	1526285399
| ASIA|	6|	1619482889
| ASIA|	7|	1768844756
| ASIA|	8|	1663320609
| ASIA|	9|	252836807
| CANADA|	3|	144634329
| CANADA|	4|	484552594
| CANADA|	5|	412378365
| CANADA|	6|	443846698
| CANADA|	7|	477134947
| CANADA|	8|	447073019
| CANADA|	9|	69067959
| EUROPE|	3|	35337093
| EUROPE|	4|	127334255
| EUROPE|	5|	109338389
| EUROPE|	6|	122813826
| EUROPE|	7|	136757466
| EUROPE|	8|	122102995
| EUROPE|	9|	18877433
| OCEANIA|	3|	783282888
| OCEANIA|	4|	2599767620
| OCEANIA|	5|	2215657304
| OCEANIA|	6|	2371884744
| OCEANIA|	7|	2563459400
| OCEANIA|	8|	2432313652
| OCEANIA|	9|	372465518
| SOUTH AMERICA|	3|	71023109
| SOUTH AMERICA|	4|	238451531
| SOUTH AMERICA|	5|	201391809
| SOUTH AMERICA|	6|	218247455
| SOUTH AMERICA|	7|	235582776
| SOUTH AMERICA|	8|	221166052
| SOUTH AMERICA|	9|	34175583
| USA|	3|	225353043
| USA|	4|	759786323
| USA|	5|	655967121
| USA|	6|	703878990
| USA|	7|	760331754
| USA|	8|	712002790
| USA|	9|	110532368

---

### 5. What is the total count of transactions for each platform?

```sql
SELECT platform, SUM(transactions) AS transactions_count
FROM clean_weekly_sales
GROUP BY platform;
```

#### Answer:

| platform | transactions_count |
| :-: | :-:|
| Shopify|	5925169|
| Retail |	1081934227|

- Shopify had much more transactions than Retail.

---

### 6. What is the percentage of sales for Retail vs Shopify for each month?

```sql
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
```

#### Answer:

| calendar_year | month_number | platform | pcent_sales |
| :-: | :-:| :-:| :-:|
| 2018|	3|	Retail|	97.9
| 2018|	3|	Shopify|	2.1
| 2018|	4|	Retail|	97.9
| 2018|	4|	Shopify|	2.1
| 2018|	5|	Retail|	97.7
| 2018|	5|	Shopify|	2.3
| 2018|	6|	Retail|	97.8
| 2018|	6|	Shopify|	2.2
| 2018|	7|	Retail|	97.8
| 2018|	7|	Shopify|	2.2
| 2018|	8|	Retail|	97.7
| 2018|	8|	Shopify|	2.3
| 2018|	9|	Retail|	97.7
| 2018|	9|	Shopify|	2.3
| 2019|	3|	Retail|	97.7
| 2019|	3|	Shopify|	2.3
| 2019|	4|	Retail|	97.8
| 2019|	4|	Shopify|	2.2
| 2019|	5|	Retail|	97.5
| 2019|	5|	Shopify|	2.5
| 2019|	6|	Retail|	97.4
| 2019|	6|	Shopify|	2.6
| 2019|	7|	Retail|	97.4
| 2019|	7|	Shopify|	2.6
| 2019|	8|	Retail|	97.2
| 2019|	8|	Shopify|	2.8
| 2019|	9|	Retail|	97.1
| 2019|	9|	Shopify|	2.9
| 2020|	3|	Retail|	97.3
| 2020|	3|	Shopify|	2.7
| 2020|	4|	Retail|	97.0
| 2020|	4|	Shopify|	3.0
| 2020|	5|	Retail|	96.7
| 2020|	5|	Shopify|	3.3
| 2020|	6|	Retail|	96.8
| 2020|	6|	Shopify|	3.2
| 2020|	7|	Retail|	96.7
| 2020|	7|	Shopify|	3.3
| 2020|	8|	Retail|	96.5
| 2020|	8|	Shopify|	3.5

- Overall, Retail has a monthly sales percentage higher than 96%, while Shopify has between 2.1% and 3.5%.

---

### 7. What is the percentage of sales by demographic for each year in the dataset?

```sql
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
```

#### Answer:

| calendar_year | demographic | pcent_sales |
| :-: | :-:| :-:|
| 2018|	"unknown"|	41.6|
| 2018|	Couples|	26.4|
| 2018|	Families|	32.0|
| 2019|	"unknown"|	40.3|
| 2019|	Couples|	27.3|
| 2019|	Families|	32.5|
| 2020|	"unknown"|	38.6|
| 2020|	Couples|	28.7|
| 2020|	Families|	32.7|

---

### 8. Which `age_band` and `demographic` values contribute the most to Retail sales?

```sql
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
```

#### Answer:

| age_band| demographic | pcent_sales |
| :-:| :-:| :-:|
| "unknown"| "unknown"|	40.5|
| Middle Aged|	Families|	27.7|
| Middle Aged|	Couples|	20.7|
| Young Adults|	Couples|	6.6|
| Young Adults|	Families|	4.5|

- The `"unknown"` category on both `age_band` and `demographic` contributes the most to Retail sales on an yearly basis.
- The known categories that contributed the most to Retail sales is the `Middle Aged` on `age_band` and `Families` from the `demographic`.

---

### 9. Can we use the `avg_transaction` column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

```sql
SELECT calendar_year,
	platform,
	ROUND(SUM(sales)::decimal/SUM(transactions), 2) AS correct_avg_transact,
    ROUND(AVG(avg_transaction)::decimal, 2) AS incorrect_avg_transact
FROM clean_weekly_sales
GROUP BY 1, 2
ORDER BY 1, 2;
```

#### Answer:

- No, we can not use the `avg_transaction` column since it gives the average amount of sales per transaction for a specific record on a day. And an average of average will not give us the yearly average, but an average of averages. Example:

	| calendar_year | sales | transactions | avg_transaction |
	| :-: | :-:| :-:| :-:|
	| 2018-01-01 | 2+3+4+4+4+4+4+4 = 17 | 8 | 2.125 |
	| 2018-01-02 |	1+5+1+1+1 = 9| 5 | 1.8 |

	Average of averages: (2.125 + 1.8)/ 2 = 1.9

	Yearly average: (17 + 9)/ (8 + 5) = 2.9

- Here it is the final result, using the query above:

	| calendar_year | platform | correct_avg_transact | incorrect_avg_transact |
	| :-: | :-:| :-:| :-:|
	| 2018|	Retail|	36.56| 42.41|
	| 2018|	Shopify| 192.48| 187.80|
	| 2019|	Retail|	36.83| 41.47|
	| 2019|	Shopify| 183.36| 177.07|
	| 2020|	Retail|	36.56| 40.14|
	| 2020|	Shopify| 179.03| 174.40|
