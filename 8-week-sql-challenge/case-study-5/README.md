# 🛒 Case Study #5: Data Mart

<img src="https://8weeksqlchallenge.com/images/case-study-designs/5.png" alt="Image" width="500" height="520">

## Table of Contents
- [Problem Statement](#problem-statement)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Case Study Questions](#case-study-questions)
- My Solutions:
    - [A. Data Cleansing Steps][solution-a]
    - [B. Data Exploration Questions][solution-b]
    - [C. Before & After Analysis Questions][solution-c]
    - [D. Bonus Question][solution-d]

---

## Problem Statement
Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce - Danny is asking for your support to analyse his sales performance. Danny needs your help to quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas.

## Entity Relationship Diagram

![image](https://8weeksqlchallenge.com/images/case-study-5-erd.png "ER diagram")

## Case Study Questions

<details>
<summary>
Click here to expand!
</summary>

### A. Data Cleansing Steps

View my solution [here][solution-a].

In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:

- Convert the week_date to a DATE format;
- Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc;
- Add a month_number with the calendar month for each week_date value as the 3rd column;
- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values;
- Add a new column called age_band after the original segment column using the a suggested mapping on the number inside the segment value;
- Add a new demographic column using the suggested mapping for the first letter in the segment values;
- Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns;
- Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record.

### B. Data Exploration Questions

View my solution [here][solution-b].

1. What day of the week is used for each `week_date` value?
2. What range of week numbers are missing from the dataset?
3. How many total transactions were there for each year in the dataset?
4. What is the total sales for each region for each month?
5. What is the total count of transactions for each platform
6. What is the percentage of sales for Retail vs Shopify for each month?
7. What is the percentage of sales by demographic for each year in the dataset?
8. Which `age_band` and `demographic` values contribute the most to Retail sales?
9. Can we use the `avg_transaction` column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

### C. Before & After Analysis Questions

View my solution [here][solution-c].

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the `week_date` value of `2020-06-15` as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all `week_date` values for `2020-06-15` as the start of the period **after** the change and the previous `week_date` values would be **before**

Using this analysis approach - answer the following questions:

1. What is the total sales for the 4 weeks before and after `2020-06-15`? What is the growth or reduction rate in actual values and percentage of sales?
2. What about the entire 12 weeks before and after?
3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

### D. Bonus Question

View my solution [here][solution-d].

1. Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

- `region`
- `platform`
- `age_band`
- `demographic`
- `customer_type`

Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

</details>

[solution-a]: https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-5/A-data-cleansing-steps.md
[solution-b]: https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-5/B-data-exploration.md
[solution-c]: https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-5/C-before-and-after-analysis.md
[solution-d]: https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-5/D-bonus-question.md