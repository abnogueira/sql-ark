# Case Study #5: Data Mart 🛒

## Solution - A. Customer Nodes Exploration

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-5/sql-syntax/A-data-cleansing-steps.sql).

---

### 1. In a single query, perform the following operations and generate a new table in the `data_mart` schema named `clean_weekly_sales`.

- Convert the `week_date` to a `DATE` format;
- Add a `week_number` as the second column for each `week_date` value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc;
- Add a `month_number` with the calendar month for each `week_date` value as the 3rd column;
- Add a `calendar_year` column as the 4th column containing either 2018, 2019 or 2020 values;
- Add a new column called `age_band` after the original `segment` column using the following mapping on the number inside the `segment` value

	| segment | age_band |
	| :-: | :-: |
	| 1 | Young Adults |
	| 2 | Middle Aged |
	| 3 or 4 | Retirees |

- Add a new `demographic` column using the following mapping for the first letter in the `segment` values:

	| segment | demographic |
	| :-: | :-: |
	| C | Couples |
	| F | Families |

- Ensure all `null` string values with an `"unknown"` string value in the original `segment` column as well as the new `age_band` and `demographic` columns;
- Generate a new `avg_transaction` column as the `sales` value divided by `transactions` rounded to 2 decimal places for each record.

```sql
SELECT TO_DATE(week_date, 'DD/MM/YY') AS week_date,
	DATE_PART('week', TO_DATE(week_date, 'DD/MM/YY')) AS week_number,
	DATE_PART('month', TO_DATE(week_date, 'DD/MM/YY')) AS month_number,
	DATE_PART('year', TO_DATE(week_date, 'DD/MM/YY')) AS calendar_year,
	region,
	platform,
	CASE WHEN segment = 'null' THEN '"unknown"' ELSE segment END AS segment,
	CASE 
		WHEN RIGHT(segment, 1) = '1' THEN 'Young Adults'
		WHEN RIGHT(segment, 1) = '2' THEN 'Middle Aged'
		WHEN RIGHT(segment, 1) in ('3', '4') THEN 'Retirees'
		ELSE '"unknown"'
	END AS age_band,
	CASE 
		WHEN LEFT(segment, 1) = 'C' THEN 'Couples'
		WHEN LEFT(segment, 1) = 'F' THEN 'Families'
		ELSE '"unknown"'
	END AS demographic,
	customer_type,
	transactions,
	sales,
	ROUND(sales/transactions,2) AS avg_transaction
INTO clean_weekly_sales
FROM weekly_sales;
```

#### Answer:

Here are the first ten rows of the created table:

| week_date | week_number | month_number | calendar_year | region | platform | segment | age_band | demographic | customer_type | transactions | sales | avg_transaction |
| :-: | :-: |:-: |:-: |:-: |:-: |:-: |:-: |:-: |:-: |:-: |:-: |:-: |
| 2020-08-31|	36|	8| 2020| ASIA | Retail | C3 | Middle Aged | Couples | New | 120631| 3656163| 30|
| 2020-08-31|	36|	8|	2020|	ASIA|	Retail|	F1|	Young Adults|	Families|	New|	31574|	996575|	31|
| 2020-08-31|	36|	8|	2020|	USA|	Retail|	"unknown"|	"unknown"|	"unknown"|	Guest|	529151|	16509610|	31|
| 2020-08-31|	36|	8|	2020|	EUROPE|	Retail|	C1|	Young Adults|	Couples|	New|	4517|	141942|	31|
| 2020-08-31|	36|	8|	2020|	AFRICA|	Retail|	C2|	Middle Aged|	Couples|	New|	58046|	1758388|	30|
| 2020-08-31|	36|	8|	2020|	CANADA|	Shopify|	F2|	Middle Aged|	Families|	Existing|	1336|	243878|	182|
| 2020-08-31|	36|	8|	2020|	AFRICA|	Shopify|	F3|	Middle Aged|	Families|	Existing|	2514|	519502|	206|
| 2020-08-31|	36|	8|	2020|	ASIA|	Shopify|	F1|	Young Adults|	Families|	Existing|	2158|	371417|	172|
| 2020-08-31|	36|	8|	2020|	AFRICA|	Shopify|	F2|	Middle Aged|	Families|	New|	318|	49557|	155|
| 2020-08-31|	36|	8|	2020|	AFRICA|	Retail|	C3|	Middle Aged|	Couples|	New|	111032|	3888162|	35|

And here are the datatypes of each column:

| Column Name | # | Data type |
| :-: | :-: | :-: |
| week_date | 1 | date |
| week_number | 2 | float8 |
| month_number | 3 | float8 |
| calendar_year | 4 | float8 |
| region | 5 | varchar(13) |
| platform | 6 | varchar(7) |
| segment | 7 | text |
| age_band | 8 | text |
| demographic | 9 | varchar(8) |
| customer_type | 10 | varchar(8) |
| transactions | 11 | int4 |
| sales | 12 | int4 |
| avg_transaction | 13 | numeric |