---------------------------------
--CASE STUDY #8: FRESH SEGMENTS--
---------------------------------

--Author: Anabela Nogueira
--Date: 2023/06/3
--Tool used: Posgresql

--------------------------
-- CASE STUDY QUESTIONS --
--------------------------

--1. Update the `fresh_segments.interest_metrics` table by modifying the `month_year` column to be a date data type with the start of the month
ALTER TABLE fresh_segments.interest_metrics ALTER COLUMN month_year TYPE DATE
using TO_DATE(month_year, 'MM-YYYY');

--2. What is count of records in the `fresh_segments.interest_metrics` for each `month_year` value sorted in chronological order (earliest to latest) with the null values appearing first?
SELECT month_year, count(*)
FROM fresh_segments.interest_metrics im
GROUP BY 1
ORDER BY 1 ASC NULLS FIRST;

--4. How many `interest_id` values exist in the `fresh_segments.interest_metrics` table but not in the `fresh_segments.interest_map` table? What about the other way around?
--There are none `interest_id` values in the `fresh_segments.interest_metrics` table but not in the `fresh_segments.interest_map`.
SELECT COUNT(DISTINCT interest_id)
FROM fresh_segments.interest_metrics 
WHERE interest_id::integer NOT IN (
    SELECT DISTINCT id
    FROM fresh_segments.interest_map
);
--There are 7 `id` values in the `fresh_segments.interest_map` table but not in the `fresh_segments.interest_metrics`.
SELECT COUNT(DISTINCT id)
FROM fresh_segments.interest_map
WHERE id NOT IN (
    SELECT DISTINCT interest_id::integer 
    FROM fresh_segments.interest_metrics
    WHERE interest_id IS NOT NULL
);

--5. Summarise the id values in the `fresh_segments.interest_map` by its total record count in this table
SELECT COUNT(DISTINCT id)
FROM fresh_segments.interest_map;

--6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where `interest_id = 21246` in your joined output and include all columns from `fresh_segments.interest_metrics` and all columns from `fresh_segments.interest_map` except from the `id` column
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

--7. Are there any records in your joined table where the `month_year` value is before the `created_at` value from the `fresh_segments.interest_map` table? Do you think these values are valid and why?
--Count month_year < created_at
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
--Examples of month_year < created_at
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
