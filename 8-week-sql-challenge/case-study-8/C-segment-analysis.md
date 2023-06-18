# Case Study #8: Fresh Segments 🍊

## Solution - C. Segment Analysis Questions

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-8/sql-syntax/C-segment-analysis.sql).

### 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any `month_year`? Only use the maximum composition value for each interest but you must keep the corresponding `month_year`

```sql
CREATE TEMPORARY TABLE IF NOT EXISTS temp_filtered_interest AS
WITH interest_id_list AS (
    SELECT interest_id,
        COUNT(*) AS month_year_num
    FROM fresh_segments.interest_metrics
    WHERE month_year IS NOT NULL
    GROUP BY 1
    HAVING COUNT(*) >= 6
)
SELECT *
FROM fresh_segments.interest_metrics
WHERE month_year IS NOT NULL
    AND interest_id IN (
        SELECT interest_id
        FROM interest_id_list);

WITH cte_ranked_interests AS (
    SELECT interest_id,
        interest_name,
        month_year,
        composition,
        ROW_NUMBER() OVER(PARTITION BY interest_id ORDER BY composition DESC) AS rn
    FROM temp_filtered_interest fi
    JOIN fresh_segments.interest_map im
        ON im.id = fi.interest_id::integer
    ORDER BY composition DESC
)
SELECT month_year,
    interest_name,
    composition
FROM (
    (SELECT month_year,
        interest_id,
        interest_name,
        composition
    FROM cte_ranked_interests
    WHERE rn = 1
    ORDER BY composition DESC
    LIMIT 10)
    
    UNION 
    
    (SELECT month_year,
        interest_id,
        interest_name,
        composition
    FROM cte_ranked_interests
    WHERE rn = 1
    ORDER BY composition
    LIMIT 10)
) interests
ORDER BY composition DESC;
```

__Steps:__

- Create a temporary table to be used during the Segment Analysis named `temp_filtered_interest` which has data mentioned in this question.
- Create a CTE named `cte_ranked_interests` with interests from the temporary table with added information from `interest_map`, having rows ranking by using the function `ROW_NUMBER` partioned by `interest_id` and ordered by `composition` to have rows ordered by the largest composition values for each interest.
- Select top 10 interests which have the largest composition values by extracting 10 rows with `rn = 1` ordered by composition in descending. And make a `UNION` to add information from the bottom 10 interests which have the largest composition values by extracting 10 rows with `rn = 1` ordered by composition in ascending order.

__Answer:__

| month_year | interest_name | composition |
| -: | :- | -: |
| 2018-12-01| Work Comes First Travelers| 21.2|
| 2018-07-01| Gym Equipment Owners| 18.82|
| 2018-07-01| Furniture Shoppers| 17.44|
| 2018-07-01| Luxury Retail Shoppers| 17.19|
| 2018-10-01| Luxury Boutique Hotel Researchers| 15.15|
| 2018-12-01| Luxury Bedding Shoppers| 15.05|
| 2018-07-01| Shoe Shoppers| 14.91|
| 2018-07-01| Cosmetics and Beauty Shoppers| 14.23|
| 2018-07-01| Luxury Hotel Guests| 14.1|
| 2018-07-01| Luxury Retail Researchers| 13.97|
| 2019-02-01| Haunted House Researchers| 2.18|
| 2019-08-01| Oakland Raiders Fans| 2.14|
| 2018-07-01| Super Mario Bros Fans| 2.12|
| 2019-08-01| Budget Mobile Phone Researchers| 2.09|
| 2019-01-01| League of Legends Video Game Fans| 2.09|
| 2018-10-01| Camaro Enthusiasts| 2.08|
| 2018-07-01| Xbox Enthusiasts| 2.05|
| 2019-03-01| Dodge Vehicle Shoppers| 1.97|
| 2018-10-01| Medieval History Enthusiasts| 1.94|
| 2018-08-01| Astrology Enthusiasts| 1.88|

---

### 2. Which 5 interests had the lowest average `ranking` value?

```sql
SELECT interest_name,
    ROUND(AVG(ranking), 1) AS avg_ranking
FROM temp_filtered_interest fi
JOIN fresh_segments.interest_map im
    ON im.id = fi.interest_id::integer
GROUP BY 1
ORDER BY AVG(ranking)
LIMIT 5;
```

__Answer:__

| interest_name | avg_ranking |
| :- | -: |
| Winter Apparel Shoppers| 1.0|
| Fitness Activity Tracker Users| 4.1|
| Mens Shoe Shoppers| 5.9|
| Shoe Shoppers| 9.4|
| Luxury Retail Researchers| 11.9|

---

### 3. Which 5 interests had the largest standard deviation in their `percentile_ranking` value?

```sql
SELECT interest_id,
    interest_name,
    ROUND(STDDEV(percentile_ranking)::decimal, 1) AS larg_sd
FROM temp_filtered_interest fi
JOIN fresh_segments.interest_map im
    ON im.id = fi.interest_id::integer
GROUP BY 1, 2
ORDER BY STDDEV(percentile_ranking) DESC
LIMIT 5;
```

__Steps:__

- Calculate the standard deviation by using the function `STDDEV` over `percentile_ranking`.
- In order to find the 5 interests with the largest standard deviation, we aggregate data by interest, then calculate standard deviation with the function mentioned above, and order data in descending order by the standard deviation calculation. And to extract the top 5, limit the query to 5.

__Answer:__

| interest_id | interest_name | larg_sd |
| :- | :- | -: |
| 23| Techies| 30.2|
| 20764| Entertainment Industry Decision Makers| 29.0|
| 38992| Oregon Trip Planners| 28.3|
| 43546| Personalized Gift Shoppers| 26.2|
| 10839| Tampa and St Petersburg Trip Planners| 25.6|

---

### 4. For the 5 interests found in the previous question - what was minimum and maximum `percentile_ranking` values for each interest and its corresponding `month_year` value? Can you describe what is happening for these 5 interests?

```sql
WITH cte_list_percentile AS (
    SELECT interest_name,
        month_year,
        percentile_ranking,
        ROW_NUMBER() OVER(PARTITION BY interest_name ORDER BY percentile_ranking DESC) AS top_rank,
        ROW_NUMBER() OVER(PARTITION BY interest_name ORDER BY percentile_ranking) AS bottom_rank
    FROM temp_filtered_interest fi
    JOIN fresh_segments.interest_map im
        ON im.id = fi.interest_id::integer
    WHERE interest_id IN ('23', '20764', '38992', '43546', '10839')
    ORDER BY interest_name
)
SELECT *
FROM (
    (SELECT interest_name,
        month_year,
        percentile_ranking
    FROM cte_list_percentile
    WHERE top_rank = 1)
    
    UNION
    
    (SELECT interest_name,
        month_year,
        percentile_ranking
    FROM cte_list_percentile
    WHERE bottom_rank = 1)
) ab
```

__Steps:__

- Create a CTE named `cte_list_percentile` to have all interests found in the previous question, which are found using `interest_id` using the `WHERE` clause. Also, use the `ROW_NUMBER` function twice in order to rank rows by `interest_name` ordered by `percentile_ranking`, one ordered by descending order and other by ascending order in order find and rows with the highest and lowest `percentile_ranking`, respectively.
- Select everything from a `UNION` of two queries: one selects the highest `percentile_ranking` (it's associated `month_year`) per `interest_name`; and the other the lowest `percentile_ranking` (it's associated `month_year`) per `interest_name`.

__Answer:__

- For these 5 interests it seems to be decreasing the `percentile_ranking` over time, since the higher value happened mmonth prior to the month where the `percentile_ranking` was lower.

| interest_name | month_year | percentile_ranking |
| :- | :- | -: |
| Entertainment Industry Decision Makers| 2018-07-01| 86.15|
| Entertainment Industry Decision Makers| 2019-08-01| 11.23|
| Oregon Trip Planners| 2018-11-01| 82.44|
| Oregon Trip Planners| 2019-07-01| 2.2|
| Personalized Gift Shoppers| 2019-03-01| 73.15|
| Personalized Gift Shoppers| 2019-06-01| 5.7|
| Tampa and St Petersburg Trip Planners| 2018-07-01| 75.03|
| Tampa and St Petersburg Trip Planners| 2019-03-01| 4.84|
| Techies| 2018-07-01| 86.69|
| Techies| 2019-08-01| 7.92|

---

### 5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?

- Based on the top interest with the highest `composition`, the majority of the customers have an __interest per luxuary items or experiences__ like traveling. A couple examples: "Luxuary Retail Shoppers", and "Luxuary Boutique Hotel Researchers".
- Based on the top interest with the lowest `composition`,  the majority of the customers have a low interest in video games, and specific vehicles, also medieval history, astrology, and haunted house researchers. Also, based on the lowest `ranking` of interests, there's not much interest with fitness activity trackers, and shoes and winter clothing.
- Contents related to travelling, either products or services should be shown to these customers to fit their interests. Also, luxury products such as cosmetics and beauty products or treatments, or even luxury items for home such as bedding would be a nice fit to these customers.
- Contents to be avoided are those related with video games, sports items (unless they are for a gym at home) and [pony cars][1] (e.g. Dodge and Camaro).

[1]: https://en.wikipedia.org/wiki/Pony_car
