---------------------------------
--CASE STUDY #8: FRESH SEGMENTS--
---------------------------------

--Author: Anabela Nogueira
--Date: 2023/06/22
--Tool used: Posgresql

--------------------------
-- CASE STUDY QUESTIONS --
--------------------------

--1. What is the top 10 interests by the average composition for each month?
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

--2. For all of these top 10 interests - which interest appears the most often?
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

--3. What is the average of the average composition for the top 10 interests for each month?
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

--4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the shown output
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
