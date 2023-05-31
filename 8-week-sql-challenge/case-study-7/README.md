# 🥾  Case Study #7: Balanced Tree

<img src="https://8weeksqlchallenge.com/images/case-study-designs/7.png" alt="Image" width="500" height="520">

## Table of Contents

- [Problem Statement](#problem-statement)
- [Case Study Questions](#case-study-questions)
- My Solutions:
  - [A. High Level Sales Analysis Questions][solution-a]
  - [B. Transaction Analysis Questions][solution-b]
  - [C. Product Analysis Questions][solution-c]
  - [D. Reporting Challenge Questions][solution-d]
  - [E. Bonus Challenge Questions][solution-e]

---

## Problem Statement

Balanced Tree Clothing Company prides themselves on providing an optimised range of clothing and lifestyle wear for the modern adventurer!

Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams analyse their sales performance and generate a basic financial report to share with the wider business.

## Case Study Questions

The following questions can be considered key business questions and metrics that the Balanced Tree team requires for their monthly reports.

Each question can be answered using a single query - but as you are writing the SQL to solve each individual problem, keep in mind how you would generate all of these metrics in a single SQL script which the Balanced Tree team can run each month.

<details>
<summary>
Click here to expand!
</summary>

### A. High Level Sales Analysis Questions

View my solution [here][solution-a].

1. What was the total quantity sold for all products?
2. What is the total generated revenue for all products before discounts?
3. What was the total discount amount for all products?

### B. Transaction Analysis Questions

View my solution [here][solution-b].

1. How many unique transactions were there?
2. What is the average unique products purchased in each transaction?
3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
4. What is the average discount value per transaction?
5. What is the percentage split of all transactions for members vs non-members?
6. What is the average revenue for member transactions and non-member transactions?

### C. Product Analysis Questions

View my solution [here][solution-c].

1. What are the top 3 products by total revenue before discount?
2. What is the total quantity, revenue and discount for each segment?
3. What is the top selling product for each segment?
4. What is the total quantity, revenue and discount for each category?
5. What is the top selling product for each category?
6. What is the percentage split of revenue by product for each segment?
7. What is the percentage split of revenue by segment for each category?
8. What is the percentage split of total revenue by category?
9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

### D. Reporting Challenge Questions

View my solution [here][solution-d].

Write a single SQL script that combines all of the previous questions into a scheduled report that the Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.

Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.

He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the same analysis for February without many changes (if at all).

Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks.

### E. Bonus Challenge Questions

View my solution [here][solution-e].

Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.

Hint: you may want to consider using a recursive CTE to solve this problem!

</details>

[solution-a]: https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-7/A-high-lvl-sales-analysis.md
[solution-b]: https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-7/B-transaction-analysis.md
[solution-c]: https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-7/C-product-analysis.md
[solution-d]: https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-7/D-reporting-challenge.md
[solution-e]: https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-7/E-bonus-challenge.md
