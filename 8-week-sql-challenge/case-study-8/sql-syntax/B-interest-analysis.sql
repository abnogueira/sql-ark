---------------------------------
--CASE STUDY #8: FRESH SEGMENTS--
---------------------------------

--Author: Anabela Nogueira
--Date: 2023/06/17
--Tool used: Posgresql

--------------------------
-- CASE STUDY QUESTIONS --
--------------------------

--1. Which interests have been present in all `month_year` dates in our dataset?
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

--2. Using this same `total_months` measure - calculate the cumulative percentage of all records starting at 14 months - which `total_months` value passes the 90% cumulative percentage value?
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
FROM cte_final_counts;

--3. If we were to remove all `interest_id` values which are lower than the `total_months` value we found in the previous question - how many total data points would we be removing?
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
WHERE total_months <= 6;

--5. After removing these interests - how many unique interests are there for each month?
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
SELECT COUNT(DISTINCT ri.id) AS total_ids
FROM fresh_segments.interest_metrics AS im
INNER JOIN cte_count_interest AS ri
    ON im.interest_id::integer = ri.id
WHERE total_months > 6;