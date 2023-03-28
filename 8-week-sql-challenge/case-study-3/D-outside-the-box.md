# Case Study #3: Foodie-Fi 🥑

## Solution - D. Outside The Box Questions

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-3/sql-syntax/D-outside-the-box.sql).

---

### 1. How would you calculate the rate of growth for Foodie-Fi?

```sql
--change payments table to add trials, and monthly income from annual plan
DROP TABLE IF EXISTS payments;
SELECT
  customer_id,
  plan_id,
  plan_name,
  payment_date ::date :: varchar,
  CASE
    WHEN LAG(plan_id) OVER (
      PARTITION BY customer_id
      ORDER BY
        plan_id
    ) != plan_id
    AND DATE_PART(
      'day',
      payment_date - LAG(payment_date) OVER (
        PARTITION BY customer_id
        ORDER BY
          plan_id
      )
    ) < 30 THEN amount - LAG(amount) OVER (
      PARTITION BY customer_id
      ORDER BY
        plan_id
    )
    ELSE amount
  END AS amount,
  RANK() OVER(
    PARTITION BY customer_id
    ORDER BY
      payment_date
  ) AS payment_order 
  
INTO TEMP TABLE payments
FROM
  (
    SELECT
      customer_id,
      s.plan_id,
      plan_name,
      generate_series(
        start_date,
        CASE
          WHEN s.plan_id = 4 THEN NULL
          WHEN LEAD(start_date) OVER (
            PARTITION BY customer_id
            ORDER BY
              start_date
          ) IS NOT NULL THEN LEAD(start_date) OVER (
            PARTITION BY customer_id
            ORDER BY
              start_date
          )
          ELSE '2020-12-31' :: date
        END,
        '1 month' + '1 second' :: interval
      ) AS payment_date,
      CASE
	      WHEN s.plan_id = 3 THEN price / 12.0
      	ELSE price
      END AS amount
    FROM
      foodie_fi.subscriptions AS s
      JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
    WHERE
      start_date < '2021-01-01' :: date
    GROUP BY
      customer_id,
      s.plan_id,
      plan_name,
      start_date,
      price
  ) AS t
ORDER BY
  customer_id

SELECT * FROM payments;

--ARPU, MRR
SELECT
	EXTRACT('MONTH' FROM payment_date::date) AS revenue_month
	, count(DISTINCT customer_id) AS customers_count
	, sum(amount)/count(DISTINCT customer_id) AS arpu
	, count(DISTINCT customer_id) * (sum(amount)/count(DISTINCT customer_id)) AS mrr
INTO TEMPORARY TABLE monthly_mrr
FROM payments
GROUP BY EXTRACT('MONTH' FROM payment_date::date);
SELECT * FROM monthly_mrr;

--customer acquisition
SELECT EXTRACT('MONTH' FROM payment_date::date) AS revenue_month
	, count(DISTINCT customer_id) AS active_users
	, SUM(CASE WHEN plan_id = 0 THEN 1 ELSE 0 END) AS trial_users
	, SUM(CASE WHEN plan_id != 0 THEN 1 ELSE 0 END) AS paying_users
FROM payments
GROUP BY EXTRACT('MONTH' FROM payment_date::date);

--churn rate
WITH total_customers_cte AS (
	SELECT EXTRACT('MONTH' FROM start_date::date) AS monthly
		, COUNT(DISTINCT customer_id) AS total_customers 
	FROM foodie_fi.subscriptions
	GROUP BY EXTRACT('MONTH' FROM start_date::date)
)
SELECT t.monthly
	, COUNT(s.customer_id) AS count_churned
	, ROUND(CAST(COUNT(s.customer_id) AS DECIMAL) / t.total_customers * 100, 3) AS churn_pcent
FROM foodie_fi.subscriptions s
	JOIN total_customers_cte t
		ON EXTRACT('MONTH' FROM s.start_date::date) = t.monthly
WHERE s.plan_id = 4
GROUP BY t.monthly, t.total_customers
ORDER BY t.monthly;
```

#### Steps

What could be monitor to determine the rate of growth for Foodie-Fi:

- **Customer acquisition**: This should include a current count of all customer entities as well as run rate information based on the creation date of customers within the last calendar year.
- **Churn rate**: This should include a current churn count of all customer as well as run rate information based on the leave date of customers within the last calendar year.
- **Average revenue per user (ARPU)**: Monthly ARPU is calculated as the earned revenues divided by the number of active customers. ARPU is most influenced by the mix of subscriptions your customers have and adding subscriptions to higher value price plans will increase ARPU while adding customers who don’t have subscriptions, or who are subscribed to free plans will with no subscriptions, will decrease ARPU.
- **Monthly recurring revenue (MRR)**: When measuring MRR, your report should show only the recurring charges that are earned in the month (one-time charges like setup fees are not included) in order to be a true indicator of future revenues from your existing customer base. Additional customers, higher value plans, and recurring add-on components will all make MRR increase.

  MRR Calculation Details: MRR is the effective monthly revenue from all active recurring subscriptions under the account.

  Example: A $10/monthly plan = $10 MRR. A $120/year plan = $10 MRR.

#### Answer:

Looking into all the metrics, Foodie-Fi seems to be growing, with a churn that is less than 22% (on a monthly view). Churning customers seem a little high, but the revenue is still increasing which seems that the business is doing all right so far. It needs a little more than a year of data in order to see if there are some monthly trends.

- Customer Acquisition:

| month |	total_users |	trial_users	| paying_users |
| :- | :- | :- | :- |
| 1 |	88 |	88 |	62|
| 2 |	144 |	68 |	130|
| 3 |	226 |	94 |	210|
| 4 |	294 |	81 |	275|
| 5	| 362 |	88 |	344|
| 6 | 421 |	79 |	412|
| 7 |	490 |	89 |	472|
| 8 |	553 |	88 |	553|
| 9	| 626 |	87 |	611|
| 10 |	677 |	79 |	671|
| 11 |	720 |	75 |	710|
| 12 |	775 |	84 |	763|

![image](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/images/solution3d_ca_chart.png "Monthly Customer Acquisition Chart")

- Churn Rate:

| monthly |	total_churn |	churn_pcent |
| :- |:- |:- |
| 1	| 28 |	17.073|
| 2 |	27 |	19.708|
| 3 |	34 |	20.988|
| 4 |	31 |	20.805|
| 5 |	21 |	15.108|
| 6 |	19 |	13.971|
| 7 |	28 |	19.048|
| 8 |	13 |	8.075|
| 9 |	23 |	14.557|
| 10 | 26 |	15.854|
| 11 | 32 |	21.918|
| 12 | 25 |	16.556|

![image](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/images/solution3d_churn_chart.png "Monthly Churn Rate Chart")

- Average Revenue Per User (ARPU) on a monthly basis:

| monthly |	customer_count | arpu | mrr |
| :- | :- | :- | :- |
| 1	 | 88 |	10.31 |	907.26|
| 2 |	144 |	13.08 |	1883.88|
| 3 |	226	| 13.02 |	2943.57|
| 4 |	294	| 13.30 |	3910.78|
| 5	| 362 |	13.21 |	4781.97|
| 6	| 421	| 13.99 |	5891.80|
| 7 |	490	| 13.86 |	6790.47|
| 8	| 553	| 14.64	| 8093.37|
| 9	| 626	| 14.83	| 9283.65|
| 10 | 677 |	14.94	| 10113.22|
| 11 | 720 |	15.27	| 10990.98|
| 12 | 775 |	15.15	| 11740.35|

![image](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/images/solution3d_arpu_chart.png "Monthly ARPU Chart")

- Monthly Recurring Revenue (MRR):

![image](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/images/solution3d_mrr_chart.png "MRR Chart")

---

### 2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?

Start by assessing the metrics on the previous question and few more:

- Customer acquisition and the total number of users at the same date;
  - Number of active customers (#total - #churn);
  - Number of paying customers (#total - #churn - #trial);
  - Number of new customers on a certain date;
- Churn Rate;
- Ratio new to churn customers - to understand if the company grows or losing their customers;
- Ratio new customers to paying customers;
- Revenue: total revenue, recurring revenue, average revenue per user (ARPU), average revenue per paying user (ARPPU), monthly recurring revenue (MRR);
- Number of active customers by plans - to understand what plan do customers prefer, and to see growth points;
- Number of active customers on date after their sign-up (cohort analysis: day 7, day 30, etc).

---

### 3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?

- **Trial customers** - it's important to understand what makes someone to subscribe a plan after their 7 days free trial. Furthermore, the experience they had: they actually used it during the free trial on a daily basis, what type of videos they watched (for instance, maybe there are few videos of the same type of those they add to favorities).
- **Upgrading customers** - how long did someone take until upgrading for a PRO plan? What features did they use the most? what type of videos/ experience are they having?
- **Downgrading customers** - what could be the main reason for a downgrade, is it the price vs what PRO features were they using? What was their experience before and after a PRO plan?
- **Churn customers** - why are they cancelling our subscription? Were they using Foodie-Fi or not? If they were, what type of content they watched?

---

### 4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?

1. What is the main reason to make you cancel? - Please select one reason:
    - Too complicated to use.
    - Lack of content that I like.
    - Lack of features.
    - Too expensive.
    - Found another product that I prefer.
2. From 1 to 10, how was your experience (1-extremely bad & 10-excellent)
3. What features did you loved the most?
4. What features did you disliked the most?
4. What could we improve?

---

### 5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?

- We can monitor the Loss Value per Churn on a monthly basis for example, instead of Churn Rate for a simple reason: the loss after a trial period is lesser than a paying customer.
  - For customers on a 7 days free trial, it's important to understand how it is their experience, and why they didn't subscribed to a paying plan. And the users during their trial period aren't using the application after two days, we should send them a reminder by email and also a reminder that that customer can experience a PRO feature twice until the end period to see if they want to make a subscription.
  - For paying customers, after we classify them into different type of users. We can target those who most likelly will churn by giving them opportunity to be alfa testers for some new feature, and gathering their opinion on the inovation.
- In order to validate the implementation, we can set A/B tests.