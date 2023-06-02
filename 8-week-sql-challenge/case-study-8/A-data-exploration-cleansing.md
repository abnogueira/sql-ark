# Case Study #8: Fresh Segments 🍊

## Solution - A. Data Exploration and Cleansing Questions

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-8/sql-syntax/A-data-exploration-cleansing.sql).

### 1. Update the `fresh_segments.interest_metrics` table by modifying the `month_year` column to be a date data type with the start of the month

```sql
ALTER TABLE fresh_segments.interest_metrics ALTER COLUMN month_year TYPE DATE
using TO_DATE(month_year, 'MM-YYYY');
```

__Answer:__

Top 3 rows of `fresh_segments.interest_metrics`:

| _month | _year | month_year | interest_id | composition | index_value | ranking | percentile_ranking |
| :- | :- | :- | :- | -: | -: | -: | -: |
| 7| 2018| 2018-07-01| 32486| 11.89| 6.19| 1| 99.86|
| 7| 2018| 2018-07-01| 6106| 9.93| 5.31| 2| 99.73|
| 7| 2018| 2018-07-01| 18923| 10.85| 5.29| 3| 99.59|

---

### 2. What is count of records in the `fresh_segments.interest_metrics` for each `month_year` value sorted in chronological order (earliest to latest) with the null values appearing first?

```sql
SELECT month_year, count(*)
FROM fresh_segments.interest_metrics im
GROUP BY 1
ORDER BY 1 ASC NULLS FIRST;
```

__Answer:__

| month_year | count |
| :- | -: |
| [NULL] | 1194|
| 2018-07-01| 729|
| 2018-08-01| 767|
| 2018-09-01| 780|
| 2018-10-01| 857|
| 2018-11-01| 928|
| 2018-12-01| 995|
| 2019-01-01| 973|
| 2019-02-01| 1121|
| 2019-03-01| 1136|
| 2019-04-01| 1099|
| 2019-05-01| 857|
| 2019-06-01| 824|
| 2019-07-01| 864|
| 2019-08-01| 1149|

---

### 3. What do you think we should do with these null values in the `fresh_segments.interest_metrics`

__Answer:__

- Regarding the NULL values on `month_year`, we shouldn't use them, because we can't place those 1194 records in a certain time period to make sense of the data.
- So the best way, would be to remove the NULL values to prevent being used for any calculations on columns where there is data.

---

### 4. How many `interest_id` values exist in the `fresh_segments.interest_metrics` table but not in the `fresh_segments.interest_map` table? What about the other way around?

__Answer:__

- There are none `interest_id` values in the `fresh_segments.interest_metrics` table but not in the `fresh_segments.interest_map`.

    Run query:

    ```sql
    SELECT COUNT(DISTINCT interest_id)
    FROM fresh_segments.interest_metrics 
    WHERE interest_id::integer NOT IN (
        SELECT DISTINCT id
        FROM fresh_segments.interest_map
    )
    ```

- There are 7 `id` values in the `fresh_segments.interest_map` table but not in the `fresh_segments.interest_metrics`.

    Run query:

    ```sql
    SELECT COUNT(DISTINCT id)
    FROM fresh_segments.interest_map
    WHERE id NOT IN (
        SELECT DISTINCT interest_id::integer 
        FROM fresh_segments.interest_metrics
        WHERE interest_id IS NOT NULL
    )
    ````

---

### 5. Summarise the id values in the `fresh_segments.interest_map` by its total record count in this table

```sql
SELECT COUNT(DISTINCT id)
FROM fresh_segments.interest_map
```

__Answer:__

| count |
| -: |
| 1209 |

- There are 1209 `id` on `interest_map` which is the exact row count of the table. On this table each interest appears once associated with an `id`.

---

### 6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where `interest_id = 21246` in your joined output and include all columns from `fresh_segments.interest_metrics` and all columns from `fresh_segments.interest_map` except from the `id` column

```sql
SELECT im.month_year,
    im._month,
    im._year,
    im.composition, 
    im.index_value,
    im.ranking,
    im.percentile_ranking ,
    im.interest_id,
    ma.interest_name, 
    ma.interest_summary,
    ma.created_at,
    ma.last_modified 
FROM fresh_segments.interest_metrics AS im 
LEFT JOIN fresh_segments.interest_map AS ma
    ON im.interest_id::integer = ma.id
WHERE im.interest_id = '21246'
ORDER BY im.month_year ASC NULLS FIRST;
```

__Answer:__

| month_year | _month | _year | composition | index_value | ranking | percentile_ranking | interest_id | interest_name | interest_summary | created_at | last_modified |
| :- | :- | :- | -: | -: | -: | -: | :- | :- | :- | :- | :- |
| | | | 1.61| 0.68| 1191| 0.25| 21246| Readers of El Salvadoran Content| People reading news from El Salvadoran media sources.| 2018-06-11 17:50:04.000| 2018-06-11 17:50:04.000|
| 2018-07-01| 7| 2018| 2.26| 0.65| 722| 0.96| 21246| Readers of El Salvadoran Content| People reading news from El Salvadoran media sources.| 2018-06-11 17:50:04.000| 2018-06-11 17:50:04.000|
| 2018-08-01| 8| 2018| 2.13| 0.59| 765| 0.26| 21246| Readers of El Salvadoran Content| People reading news from El Salvadoran media sources.| 2018-06-11 17:50:04.000 |2018-06-11 17:50:04.000|
| 2018-09-01| 9| 2018| 2.06| 0.61| 774| 0.77| 21246| Readers of El Salvadoran Content| People reading news from El Salvadoran media sources.| 2018-06-11 17:50:04.000 |2018-06-11 17:50:04.000|
| 2018-10-01| 10| 2018| 1.74| 0.58| 855| 0.23| 21246| Readers of El Salvadoran Content| People reading news from El Salvadoran media sources.| 2018-06-11 17:50:04.000 |2018-06-11 17:50:04.000|
| 2018-11-01| 11| 2018| 2.25| 0.78| 908| 2.16| 21246| Readers of El Salvadoran Content| People reading news from El Salvadoran media sources.| 2018-06-11 17:50:04.000 |2018-06-11 17:50:04.000|
| 2018-12-01| 12| 2018| 1.97| 0.7| 983| 1.21| 21246| Readers of El Salvadoran Content| People reading news from El Salvadoran media sources.| 2018-06-11 17:50:04.000 |2018-06-11 17:50:04.000|
| 2019-01-01| 1| 2019| 2.05| 0.76| 954| 1.95| 21246| Readers of El Salvadoran Content| People reading news from El Salvadoran media sources.| 2018-06-11 17:50:04.000 |2018-06-11 17:50:04.000|
| 2019-02-01| 2| 2019| 1.84| 0.68| 1109| 1.07| 21246| Readers of El Salvadoran Content| People reading news from El Salvadoran media sources.| 2018-06-11 17:50:04.000 |2018-06-11 17:50:04.000|
| 2019-03-01| 3| 2019| 1.75| 0.67| 1123| 1.14| 21246| Readers of El Salvadoran Content| People reading news from El Salvadoran media sources.| 2018-06-11 17:50:04.000 |2018-06-11 17:50:04.000|
| 2019-04-01| 4| 2019| 1.58| 0.63| 1092| 0.64| 21246| Readers of El Salvadoran Content| People reading news from El Salvadoran media sources.| 2018-06-11 17:50:04.000 |2018-06-11 17:50:04.000|

- Regarding the table join we should do a `LEFT JOIN` since `interest_map` has only one row per interest id, while `interest_metrics` references several interest id.
- The `interest_id` equal to 21246 shows that there is an interest with `month_year`, `_month` and `_year` with missing values. In order to remove this row, we can add a `WHERE` clause with `month_year` `NOT NULL` or, we can and another `ON` clause where `month_year` is bigger or equal to `created_at` column from `interest_map` table.

---

### 7. Are there any records in your joined table where the `month_year` value is before the `created_at` value from the `fresh_segments.interest_map` table? Do you think these values are valid and why?

```sql
SELECT COUNT(*)
FROM (
    SELECT im.month_year,
        ma.created_at
    FROM fresh_segments.interest_metrics AS im 
    LEFT JOIN fresh_segments.interest_map AS ma
        ON im.interest_id::integer = ma.id
        AND im.month_year < ma.created_at
    WHERE im.month_year IS NOT NULL 
        AND ma.created_at IS NOT NULL
    ORDER BY im.month_year ASC NULLS FIRST
) a;
```

__Answer:__

| count |
| :-: |
| 188 |

- There are 188 records where `month_year` is lower than the date of `created_at` associated with the interest map.
- These values are valid, because `month_year` only have accurate information of the month and year, the day was added later on (as a result of question 1) when this column was transformed into a date.

Example:

```sql
SELECT im.month_year,
    ma.created_at
FROM fresh_segments.interest_metrics AS im 
LEFT JOIN fresh_segments.interest_map AS ma
    ON im.interest_id::integer = ma.id
    AND im.month_year < ma.created_at
WHERE im.month_year IS NOT NULL 
    AND ma.created_at IS NOT NULL
ORDER BY im.month_year ASC NULLS FIRST
LIMIT 5;
```

| month_year | created_at |
| :- | :- |
| 2018-07-01| 2018-07-17 10:40:03.000|
| 2018-07-01| 2018-07-06 14:35:04.000|
| 2018-07-01| 2018-07-06 14:35:03.000|
| 2018-07-01| 2018-07-06 14:35:04.000|
| 2018-07-01| 2018-07-06 14:35:04.000|
