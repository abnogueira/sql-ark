# Case Study #8: Fresh Segments 🍊

## Solution - C. Index Analysis Questions

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-8/sql-syntax/D-index-analysis.sql).

The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.

Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.

---

### 1. What is the top 10 interests by the average composition for each month?

```sql
WITH cte_avg_composition AS (
    SELECT interest_id, 
        month_year,
        ROUND((composition / index_value)::NUMERIC, 2) AS avg_composition,
        ROW_NUMBER() OVER (PARTITION BY month_year 
            ORDER BY ROUND((composition / index_value)::NUMERIC, 2) DESC) AS int_rank
    FROM fresh_segments.interest_metrics
    WHERE month_year IS NOT NULL
)
SELECT av.month_year,
    interest_name,
    avg_composition
FROM cte_avg_composition AS av
JOIN fresh_segments.interest_map im 
    ON av.interest_id::integer = im.id
WHERE int_rank <= 10
ORDER BY av.month_year, av.int_rank;
```

__Answer:__

First day of the output (2018-07-01):

| month_year | interest_name | avg_composition |
| :- | :- | -: |
| 2018-07-01| Las Vegas Trip Planners| 7.36|
| 2018-07-01| Gym Equipment Owners| 6.94|
| 2018-07-01| Cosmetics and Beauty Shoppers| 6.78|
| 2018-07-01| Luxury Retail Shoppers| 6.61|
| 2018-07-01| Furniture Shoppers| 6.51|
| 2018-07-01| Asian Food Enthusiasts| 6.10|
| 2018-07-01| Recently Retired Individuals| 5.72|
| 2018-07-01| Family Adventures Travelers| 4.85|
| 2018-07-01| Work Comes First Travelers| 4.80|
| 2018-07-01| HDTV Researchers| 4.71|

---

### 2. For all of these top 10 interests - which interest appears the most often?

```sql
WITH cte_avg_composition AS (
    SELECT interest_id, 
        month_year,
        ROUND((composition / index_value)::NUMERIC, 2) AS avg_composition,
        ROW_NUMBER() OVER (PARTITION BY month_year 
            ORDER BY ROUND((composition / index_value)::NUMERIC, 2) DESC) AS int_rank
    FROM fresh_segments.interest_metrics
    WHERE month_year IS NOT NULL
),
cte_top_interest AS (
    SELECT av.month_year,
        interest_name,
        avg_composition
    FROM cte_avg_composition AS av
    JOIN fresh_segments.interest_map im 
        ON av.interest_id::integer = im.id
    WHERE int_rank <= 10
    ORDER BY av.month_year, av.int_rank
)
SELECT interest_name, count(interest_name)
FROM cte_top_interest
GROUP BY 1
ORDER BY count(interest_name) DESC
LIMIT 5;
```

__Answer:__

- Interests that appear the most often are: "Alabama Trip Planners", "Solar Energy Researchers" and "Luxury Bedding Shoppers" with a total of 10 times.
- Top 5 interest list:

    | interest_name | count |
    | :- | -: |
    | Alabama Trip Planners| 10|
    | Solar Energy Researchers| 10|
    | Luxury Bedding Shoppers| 10|
    | Readers of Honduran Content| 9|
    | New Years Eve Party Ticket Purchasers| 9|

---

### 3. What is the average of the average composition for the top 10 interests for each month?

```sql
WITH cte_avg_composition AS (
    SELECT interest_id, 
        month_year,
        ROUND((composition / index_value)::NUMERIC, 2) AS avg_composition,
        ROW_NUMBER() OVER (PARTITION BY month_year 
            ORDER BY ROUND((composition / index_value)::NUMERIC, 2) DESC) AS int_rank
    FROM fresh_segments.interest_metrics
    WHERE month_year IS NOT NULL
)
select month_year,
    ROUND(AVG(avg_composition), 2) AS average
FROM cte_avg_composition
WHERE int_rank <= 10
GROUP BY 1
ORDER BY 1;
```

__Answer:__

| month_year | average |
| :- | -: |
| 2018-07-01| 6.04|
| 2018-08-01| 5.95|
| 2018-09-01| 6.90|
| 2018-10-01| 7.07|
| 2018-11-01| 6.62|
| 2018-12-01| 6.65|
| 2019-01-01| 6.40|
| 2019-02-01| 6.58|
| 2019-03-01| 6.17|
| 2019-04-01| 5.75|
| 2019-05-01| 3.54|
| 2019-06-01| 2.43|
| 2019-07-01| 2.77|
| 2019-08-01| 2.63|

- Average of average composition starts to decrease on March of 2019.

---

### 4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the shown output

```sql
WITH cte_avg_composition AS (
    SELECT interest_id,
        im.interest_name,
        month_year,
        ROUND((composition / index_value)::NUMERIC, 2) AS avg_composition,
        ROW_NUMBER() OVER (PARTITION BY month_year 
            ORDER BY ROUND((composition / index_value)::NUMERIC, 2) DESC) AS int_rank
    FROM fresh_segments.interest_metrics
    JOIN fresh_segments.interest_map im 
        ON imt.interest_id::integer = im.id
    WHERE month_year IS NOT NULL
),
cte_max_index_composition AS (
    SELECT 
        month_year,
        interest_name,
        avg_composition AS max_index_composition,
        AVG(avg_composition) OVER(
            ORDER BY month_year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        )::numeric(10, 2) AS _3_month_moving_avg,
        CONCAT(
            LAG(interest_name) OVER(ORDER BY month_year), 
            ': ', 
            LAG(avg_composition) OVER(ORDER BY month_year)) AS _1_month_ago,
        CONCAT(
            LAG(interest_name, 2) OVER(ORDER BY month_year), 
            ': ', 
            LAG(avg_composition, 2) OVER(ORDER BY month_year)) AS _2_month_ago
    FROM cte_avg_composition
    WHERE int_rank = 1
    ORDER BY 1
)
SELECT *
FROM cte_max_index_composition
WHERE month_year >= '2018-09-01';
```

__Steps:__

- To calculate the three months moving average we can use `AVG(Value) Over(Order by month_year rows between 2 preceding and current row)`.
- In order to have the maximum interest per `month_year`, we need to add a `WHERE` clause for `int_rank = 1`.
- The reason behind `WHERE month_year >= '2018-09-01'` was to apply the `WHERE` clause after building all necessary columns to prevent missing data on the first row (regarding the first `month_year`).

__Answer:__

| month_year | interest_name | max_index_composition | _3_month_moving_avg | _1_month_ago | _2_month_ago |
| :- | :- | -: | -: | :- | :- |
| 2018-09-01| Work Comes First Travelers| 8.26| 7.61| Las Vegas Trip Planners: 7.21| Las Vegas Trip Planners: 7.36|
| 2018-10-01| Work Comes First Travelers| 9.14| 8.20| Work Comes First Travelers: 8.26| Las Vegas Trip Planners: 7.21|
| 2018-11-01| Work Comes First Travelers| 8.28| 8.56| Work Comes First Travelers: 9.14| Work Comes First Travelers: 8.26|
| 2018-12-01| Work Comes First Travelers| 8.31| 8.58| Work Comes First Travelers: 8.28| Work Comes First Travelers: 9.14|
| 2019-01-01| Work Comes First Travelers| 7.66| 8.08| Work Comes First Travelers: 8.31| Work Comes First Travelers: 8.28|
| 2019-02-01| Work Comes First Travelers| 7.66| 7.88| Work Comes First Travelers: 7.66| Work Comes First Travelers: 8.31|
| 2019-03-01| Alabama Trip Planners| 6.54| 7.29| Work Comes First Travelers: 7.66| Work Comes First Travelers: 7.66|
| 2019-04-01| Solar Energy Researchers| 6.28| 6.83| Alabama Trip Planners: 6.54| Work Comes First Travelers: 7.66|
| 2019-05-01| Readers of Honduran Content| 4.41| 5.74| Solar Energy Researchers: 6.28| Alabama Trip Planners: 6.54|
| 2019-06-01| Las Vegas Trip Planners| 2.77| 4.49| Readers of Honduran Content: 4.41| Solar Energy Researchers: 6.28|
| 2019-07-01| Las Vegas Trip Planners| 2.82| 3.33| Las Vegas Trip Planners: 2.77| Readers of Honduran Content: 4.41|
| 2019-08-01| Cosmetics and Beauty Shoppers| 2.73| 2.77| Las Vegas Trip Planners: 2.82| Las Vegas Trip Planners: 2.77|

---

### 5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?

__Answer:__

- A possible reason why the max average composition might change from month to month is due to the preferences of people changing over time, either seasonal or having to move on to another interest.
- It may not be a problem with Fresh Segments. The data could be the result of having an interest in travelling in certain seasons, for example. Some interests could be segmented in a different way. For example, aggregating some interests since it could lead to different insights. It may be worth double checking the data gathering process to verify if there is a reason for a decrease in `max_index_composition`, also collect more data to properly compare the seasonality over time.
