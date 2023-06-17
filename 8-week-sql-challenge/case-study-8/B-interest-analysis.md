# Case Study #8: Fresh Segments 🍊

## Solution - B. Interest Analysis Questions

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-8/sql-syntax/B-interest-analysis.sql).

### 1. Which interests have been present in all `month_year` dates in our dataset?

```sql
SELECT COUNT(DISTINCT month_year)
FROM fresh_segments.interest_metrics
WHERE month_year IS NOT NULL; --14 year_month

WITH cte_count_interest AS (
    SELECT ma.id,
        ma.interest_name,
        COUNT(*) AS times
    FROM fresh_segments.interest_metrics AS im 
    LEFT JOIN fresh_segments.interest_map AS ma
        ON im.interest_id::integer = ma.id
    WHERE ma.interest_name IS NOT NULL
    GROUP BY 1, 2
    ORDER BY 3 DESC
)
SELECT *
FROM cte_count_interest
WHERE times >= 14
ORDER BY interest_name; --480 interests
```

__Steps:__

- The first query results how many `month_year` are present in the data, which are 14.
- The second query calculates using `COUNT` function how many times an interest ID appeared.

__Answer:__

- There are 480 interests that appeared in all 14 months.
- Here are the top 5 results ordered alphabetically:

    | id | interest_name | times |
    | -: | :- | -: |
    | 6183| Accounting & CPA Continuing Education Researchers| 14|
    | 18347| Affordable Hotel Bookers| 14|
    | 129| Aftermarket Accessories Shoppers| 14|
    | 7541| Alabama Trip Planners| 14|
    | 10284| Alaskan Cruise Planners| 14|

---

### 2. Using this same `total_months` measure - calculate the cumulative percentage of all records starting at 14 months - which `total_months` value passes the 90% cumulative percentage value?

```sql
WITH cte_count_interest AS (
    SELECT ma.id,
        ma.interest_name,
        COUNT(*) AS total_months,
    FROM fresh_segments.interest_metrics AS im 
    LEFT JOIN fresh_segments.interest_map AS ma
        ON im.interest_id::integer = ma.id
    WHERE ma.interest_name IS NOT NULL
    GROUP BY 1, 2
    ORDER BY 3 DESC
),
cte_final_counts AS (
    SELECT ri.total_months,
        COUNT(DISTINCT ri.id) AS total_ids,
        COUNT(*) AS total_data_points
    FROM fresh_segments.interest_metrics AS im
    INNER JOIN cte_count_interest AS ri
        ON im.interest_id::integer = ri.id
    GROUP BY ri.total_months
)
SELECT *,
    SUM(total_ids) OVER (ORDER BY total_months DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) /
    SUM(total_ids) OVER () * 100.0 AS cum_pcent
FROM cte_final_counts
```

__Steps:__

- On the previous questions, `times` column it's actual our `total_months` at the level of each interest. On question number 2, we want the information at the level of `total_months` with the total amount of interests that have the same amount of `total_months`, plus we need to calculate the cumulative percentage value.
- To calculate the cumulative percentage, we will be using the `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`, which means that the window to the calculation consists of the first row of the partition and all the rows up to the current row. Each calculation is done over a different set of rows. For example, when performing the calculation for row 3, the rows 1 to 3 are used. Then we divide that value for the total value of `total_ids` given by `SUM(total_ids) OVER ()`.

__Answer:__

- The values of `total_months` that passes the 90% cumulative percentage value is 1 to 6.
- Here are the results:

    | total_months | total_ids | total_data_points | cumulative_pcent |
    | -: | -: | -: | -: |
    | 14| 480| 6720| 39.9|
    | 13| 82| 1066| 46.8|
    | 12| 65| 780| 52.2|
    | 11| 95| 1045| 60.1|
    | 10| 85| 850| 67.1|
    | 9| 95| 855| 75.0|
    | 8| 67| 536| 80.6|
    | 7| 90| 630| 88.1|
    | 6| 33| 198| 90.8|
    | 5| 38| 190| 94.0|
    | 4|  32| 128| 96.7|
    | 3| 15| 45| 97.9|
    | 2| 12| 24| 98.9|
    | 1| 13| 13| 100.0|

---

### 3. If we were to remove all `interest_id` values which are lower than the `total_months` value we found in the previous question - how many total data points would we be removing?

```sql
WITH cte_count_interest AS (
    SELECT ma.id,
        ma.interest_name,
        COUNT(*) AS total_months
    FROM fresh_segments.interest_metrics AS im 
    LEFT JOIN fresh_segments.interest_map AS ma
        ON im.interest_id::integer = ma.id
    WHERE ma.interest_name IS NOT NULL
    GROUP BY 1, 2
    ORDER BY 3 DESC
)
SELECT COUNT(DISTINCT ri.id) AS total_ids,
    COUNT(*) AS total_data_points,
    ROUND(100.0 * COUNT(*) / 
        (SELECT COUNT(*) FROM fresh_segments.interest_metrics), 1) AS data_points_pcent
FROM fresh_segments.interest_metrics AS im
INNER JOIN cte_count_interest AS ri
    ON im.interest_id::integer = ri.id
WHERE total_months <= 6
```

__Answer:__

| total_ids | total_data_points | data_points_pcent |
| -: | -: | -: |
| 143 | 598 | 4.2|

- It would be removed 598 data points (4,2% of data), which are related to 143 different interest IDs.

---

### 4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective

__Answer:__

- It makes sense to remove these data points from a business perspective because there is at least one missing month (see Example 1). What have happened to the months of may, june and july regardin the "Texas Activity Researchers", it completed ceased or it's missing? When we see all 14 months of data (see Example 2), we can analyse characteristics like seasons where the interest increases, for example.
- Customer segmentation itself it's not time-bound since it is the process of diving customers based into different groups based on shared characteristics or behavior. But to calculate Customer Lifetime Value or making a Cohort Analysis we need to work with customer data from a specific time period. That's why having all data within a certain timeframe important and relevant to be analysed. And since there are so many interests, we can discards those with missing data.
- Example 1 - random removed interest:
  - Query:

    ```sql
    SELECT month_year, composition, index_value, ranking, percentile_ranking,
        interest_id, interest_name, interest_summary, created_at, last_modified
    FROM fresh_segments.interest_metrics AS im 
    LEFT JOIN fresh_segments.interest_map AS ma
        ON im.interest_id::integer = ma.id
    WHERE ma.id = '44484'
    ```

  - Result:

    | month_year | composition| index_value | ranking | percentile_ranking | interest_id| interest_name| interest_summary| created_at| last_modified|
    | :- | -: | -: | -: | -: | -: | :- | :- | :- | :- |
    | 2019-02-01| 2.74| 1.48| 304| 72.88| 44484| Texas Activity Researchers| People researching Texas activities| 2019-01-28 09:00:07.000| 2019-01-28 09:00:07.000|
    | 2019-03-01| 2.31| 1.31| 517| 54.49| 44484| Texas Activity Researchers| People researching Texas activities| 2019-01-28 09:00:07.000| 2019-01-28 09:00:07.000|
    | 2019-04-01| 1.72| 1.19| 661| 39.85| 44484| Texas Activity Researchers| People researching Texas activities| 2019-01-28 09:00:07.000| 2019-01-28 09:00:07.000|
    | 2019-08-01| 2.45| 1.9| 368| 67.97| 44484| Texas Activity Researchers| People researching Texas activities| 2019-01-28 09:00:07.000| 2019-01-28 09:00:07.000|

- Example 2 - example where there are all 14 months present:
  - Query:

    ```sql
    SELECT month_year, composition, index_value, ranking, percentile_ranking,
        interest_id, interest_name, interest_summary, created_at, last_modified
    FROM fresh_segments.interest_metrics AS im 
    LEFT JOIN fresh_segments.interest_map AS ma
        ON im.interest_id::integer = ma.id
    WHERE ma.id = '15'
    ```

  - Result:

    | month_year | composition| index_value | ranking | percentile_ranking | interest_id| interest_name| interest_summary| created_at| last_modified|
    | :- | -: | -: | -: | -: | -: | :- | :- | :- | :- |
    | 2018-07-01| 6.9| 3.56| 38| 94.79| 15| NBA Fans| People reading articles and websites about basketball and the NBA.| 2016-05-26 14:57:59.000| 2018-05-23 11:30:13.000|
    | 2018-08-01| 2.83| 1.49| 205| 73.27| 15| NBA Fans| People reading articles and websites about basketball and the NBA.| 2016-05-26 14:57:59.000| 2018-05-23 11:30:13.000|
    | 2018-09-01|  2.49| 1.57| 143| 81.67| 15| NBA Fans| People reading articles and websites about basketball and the NBA.| 2016-05-26 14:57:59.000| 2018-05-23 11:30:13.000|
    | 2018-10-01| 3.34| 1.76| 143| 83.31| 15| NBA Fans| People reading articles and websites about basketball and the NBA.| 2016-05-26 14:57:59.000| 2018-05-23 11:30:13.000|
    | 2018-11-01| 2.04| 1.39| 468| 49.57| 15| NBA Fans| People reading articles and websites about basketball and the NBA.| 2016-05-26 14:57:59.000| 2018-05-23 11:30:13.000|
    | 2018-12-01| 2.36| 1.48| 410| 58.79| 15| NBA Fans| People reading articles and websites about basketball and the NBA.| 2016-05-26 14:57:59.000| 2018-05-23 11:30:13.000|
    | 2019-01-01| 2.05| 1.34| 405| 58.38| 15| NBA Fans| People reading articles and websites about basketball and the NBA.| 2016-05-26 14:57:59.000| 2018-05-23 11:30:13.000|
    | 2019-02-01| 2.37| 1.25| 605| 46.03| 15| NBA Fans| People reading articles and websites about basketball and the NBA.| 2016-05-26 14:57:59.000| 2018-05-23 11:30:13.000|
    | 2019-03-01| 2.47| 1.34| 478| 57.92| 15| NBA Fans| People reading articles and websites about basketball and the NBA.| 2016-05-26 14:57:59.000| 2018-05-23 11:30:13.000|
    | 2019-04-01| 2.29| 1.51| 261| 76.25| 15| NBA Fans| People reading articles and websites about basketball and the NBA.| 2016-05-26 14:57:59.000| 2018-05-23 11:30:13.000|
    | 2019-05-01| 1.86| 1.76| 273| 68.14| 15| NBA Fans| People reading articles and websites about basketball and the NBA.| 2016-05-26 14:57:59.000| 2018-05-23 11:30:13.000|
    | 2019-06-01| 2.08| 2.26| 127| 84.59| 15| NBA Fans| People reading articles and websites about basketball and the NBA.| 2016-05-26 14:57:59.000| 2018-05-23 11:30:13.000|
    | 2019-07-01| 2.58| 2.26| 113| 86.92| 15| NBA Fans| People reading articles and websites about basketball and the NBA.| 2016-05-26 14:57:59.000| 2018-05-23 11:30:13.000|
    | 2019-08-01| 3.57| 2.32| 122| 89.38| 15| NBA Fans| People reading articles and websites about basketball and the NBA.| 2016-05-26 14:57:59.000| 2018-05-23 11:30:13.000|

---

### 5. After removing these interests - how many unique interests are there for each month?

```sql
WITH cte_count_interest AS (
    SELECT ma.id,
        ma.interest_name,
        COUNT(*) AS total_months
    FROM fresh_segments.interest_metrics AS im 
    LEFT JOIN fresh_segments.interest_map AS ma
        ON im.interest_id::integer = ma.id
    WHERE ma.interest_name IS NOT NULL
    GROUP BY 1, 2
    ORDER BY 3 DESC
)
SELECT COUNT(DISTINCT ri.id) AS total_ids,
    COUNT(*) AS total_data_points,
    ROUND(100.0 * COUNT(*) / 
        (SELECT COUNT(*) FROM fresh_segments.interest_metrics), 1) AS data_points_pcent
FROM fresh_segments.interest_metrics AS im
INNER JOIN cte_count_interest AS ri
    ON im.interest_id::integer = ri.id
WHERE total_months > 6
```

__Answer:__

| total_ids | total_data_points | data_points_pcent |
| -: | -: | -: |
| 1059 | 12482 | 87.5|

- There are 1059 unique interests after the removal of some interests.
