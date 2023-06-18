---------------------------------
--CASE STUDY #8: FRESH SEGMENTS--
---------------------------------

--Author: Anabela Nogueira
--Date: 2023/06/18
--Tool used: Posgresql

--------------------------
-- CASE STUDY QUESTIONS --
--------------------------

--1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any `month_year`? Only use the maximum composition value for each interest but you must keep the corresponding `month_year`
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

--2. Which 5 interests had the lowest average `ranking` value?
SELECT interest_name,
    ROUND(AVG(ranking), 1) AS avg_ranking
FROM temp_filtered_interest fi
JOIN fresh_segments.interest_map im
    ON im.id = fi.interest_id::integer
GROUP BY 1
ORDER BY AVG(ranking)
LIMIT 5;

--3. Which 5 interests had the largest standard deviation in their `percentile_ranking` value?
SELECT interest_id,
    interest_name,
    ROUND(STDDEV(percentile_ranking)::decimal, 1) AS larg_sd
FROM temp_filtered_interest fi
JOIN fresh_segments.interest_map im
    ON im.id = fi.interest_id::integer
GROUP BY 1, 2
ORDER BY STDDEV(percentile_ranking) DESC
LIMIT 5;

--4. For the 5 interests found in the previous question - what was minimum and maximum `percentile_ranking` values for each interest and its corresponding `month_year` value? Can you describe what is happening for these 5 interests?
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
