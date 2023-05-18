# Case Study #6: Clique Bait 🍤

## Solution - D. Campaign Analysis Questions

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-6/sql-syntax/D-campaign-analysis.sql).

---

### 1. Generate a table that has 1 single row for every unique visit_id record and has the following columns:

    - `user_id`
    - `visit_id`
    - `visit_start_time`: the earliest `event_time` for each visit
    - `page_views`: count of page views for each visit
    - `cart_adds`: count of product cart add events for each visit
    - `purchase`: 1/0 flag if a purchase event exists for each visit
    - `campaign_name`: map the visit to a campaign if the `visit_start_time` falls between the `start_date` and `end_date`
    - `impression`: count of ad impressions for each visit
    - `click`: count of ad clicks for each visit
    - (Optional column) `cart_products`: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the `sequence_number`)

```sql
SELECT u.user_id,
	e.visit_id,
	MIN(e.event_time) AS visit_start_time,
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_views,
    SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_adds,
    SUM(CASE WHEN e.event_type = 3 THEN 1 ELSE 0 END) AS purchase,
    c.campaign_name,
    SUM(CASE WHEN e.event_type = 4 THEN 1 ELSE 0 END) AS impression,
    SUM(CASE WHEN e.event_type = 5 THEN 1 ELSE 0 END) AS click,
    STRING_AGG(CASE WHEN p.product_id IS NOY NULL AND e.event_type = 2 THEN p.page_name ELSE NULL END, 
    	', ' ORDER BY e.sequence_number) AS cart_products
INTO clique_bait.campaign_visit_stats
FROM clique_bait.users AS u
JOIN clique_bait.events AS e 
	ON u.cookie_id = e.cookie_id
LEFT JOIN clique_bait.campaign_identifier AS c
	ON e.event_time BETWEEN c.start_date AND c.end_date
LEFT JOIN clique_bait.page_hierarchy AS p
	ON e.page_id = p.page_id
GROUP BY user_id, visit_id, c.campaign_name
ORDER BY 1, 2;
```

#### Answer:

Top 10 rows of generated table:

| user_id | visit_id | visit_start_time | page_views |  cart_adds | purchase | campaign_name | impression | click | cart_products |
| -:| :-| :-| -:| -:| -:| -:| -:| -:| :-|
| 1|	02a5d5|	2020-02-26 16:57:26.260|	4|	0|	0|	Half Off - Treat Your Shellf(ish)|	0|	0|	|
| 1|	0826dc|	2020-02-26 05:58:37.918|	1|	0|	0|	Half Off - Treat Your Shellf(ish)|	0|	0|	|
| 1|	0fc437|	2020-02-04 17:49:49.602|	10|	6|	1|	Half Off - Treat Your Shellf(ish)|	1|	1|	Tuna, Russian Caviar, Black Truffle, Abalone, Crab, Oyster|
| 1|	30b94d|	2020-03-15 13:12:54.023|	9|	7|	1|	Half Off - Treat Your Shellf(ish)|	1|	1|	Salmon, Kingfish, Tuna, Russian Caviar, Abalone, Lobster, Crab|
| 1|	41355d|	2020-03-25 00:11:17.860|	6|	1|	0|	Half Off - Treat Your Shellf(ish)|	0|	0|	Lobster|
| 1|	ccf365|	2020-02-04 19:16:09.182|	7|	3|	1|	Half Off - Treat Your Shellf(ish)|	0|	0|	Lobster, Crab, Oyster|
| 1|	eaffde|	2020-03-25 20:06:32.342|	10|	8|	1|	Half Off - Treat Your Shellf(ish)|	1|	1|	Salmon, Tuna, Russian Caviar, Black Truffle, Abalone, Lobster, Crab, Oyster|
| 1|	f7c798|	2020-03-15 02:23:26.312|	9|	3|	1|	Half Off - Treat Your Shellf(ish)|	0|	0|	Russian Caviar, Crab, Oyster|
| 2|	0635fb|	2020-02-16 06:42:42.735|	9|	4|	1|	Half Off - Treat Your Shellf(ish)|	0|	0|	Salmon, Kingfish, Abalone, Crab|
| 2|	1f1198|	2020-02-01 21:51:55.078|	1|	0|	0|	Half Off - Treat Your Shellf(ish)|	0|	0|	|

### 2. Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a single A4 infographic that the team can use for their management reporting sessions, be sure to emphasise the most important points from your findings.

Some ideas you might want to investigate further include:

- Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
	
	```sql
	SELECT 
		CASE impression WHEN 1 THEN 'Yes' ELSE 'No' END AS received_impressions,
		COUNT(*) AS visits_total,
		ROUND(AVG(page_views)) AS avg_page_views,
		ROUND(AVG(cart_adds)) AS avg_cart_adds,
		ROUND(100.0 * SUM(purchase)/ count(*), 1) AS purchase_rate_pcent
	FROM clique_bait.campaign_visit_stats
	GROUP BY 1
	ORDER BY 5 DESC
	```
	
	Answer:

	| received_impressions | visits_total | avg_page_views | avg_cart_adds | purchase_rate_pcent |
	| :-: | :-: | :-: | :-: | :-: |
	| Yes|	876|	9|	5|	84.1|
	| No|	2688|	5|	2|	38.7|

	- The average number of page views, cart adds, and purchase rate is higher on users that received an impression ad.

- Does clicking on an impression lead to higher purchase rates?
	Answer:

	- Using the query on the question above, those users that clicked an impression ad, had a higher purchase rate, when compared with users that didn't.

- What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?

	```sql
	SELECT 
		CASE impression WHEN 1 THEN 'Yes' ELSE 'No' END AS received_impressions,
		CASE click WHEN 1 THEN 'Yes' ELSE 'No' END AS clicked_impression,
		COUNT(*) AS visits_total,
		ROUND(100.0 * SUM(purchase)/ 
			COUNT(*), 
			1) AS purchase_rate_pcent
	FROM clique_bait.campaign_visit_stats
	GROUP BY 1, 2
	ORDER BY 1, 2
	```

	Answer:

	| received_impressions | clicked_impression | visits_total | purchase_rate_pcent |
	| :-: | :-: | -: | -: |
	| No|	No|	2688|	38.7|
	| Yes|	No|	174|	64.9|
	| Yes|	Yes|	702|	88.9|

	- Users that clicked on a campaign impression had a 50.2% higher purchase rate than users that did not receive an impression.
	- Users that clicked on a campaign impression had a 24% higher purchase rate than users that did only seen the impression but did not clicked on it.

- What metrics can you use to quantify the success or failure of each campaign compared to eachother

	```sql
	SELECT 
		CASE WHEN campaign_name IS NULL THEN 'No campaign' ELSE campaign_name END AS campaign,
		COUNT(*) AS visits_total,
		ROUND(AVG(page_views)) AS avg_page_views,
		ROUND(AVG(cart_adds)) AS avg_cart_adds,
		SUM(purchase) AS total_purchases,
		ROUND(100.0 * SUM(purchase)/ 
			COUNT(*), 
			1) AS purchase_rate_pcent
	FROM clique_bait.campaign_visit_stats
	GROUP BY 1
	```
	Answer:

	| campaign | visits_total | avg_page_views | avg_cart_adds | total_purchases | purchase_rate_pcent |
	| :- | -: | -: | -: | -: | -: |
	| No campaign|	512|	6|	2|	268|	52.3|
	| Half Off - Treat Your Shellf(ish)|	2388|	6|	2|	1180|	49.4|
	| BOGOF - Fishing For Compliments|	260|	6|	2|	127|	48.8|
	| 25% Off - Living The Lux Life|	404|	6|	2|	202|	50.0|

	- Number of visits seems a good indicator how good a campaign is. In this case, Half Off resulted into more than 2000 visits.

Extra:
- Calculate the bounce rate, which give us the amount of people that leave at the first page they view.

	```sql
	SELECT 
		CASE WHEN page_views = 1 THEN 'Yes' ELSE 'No' END AS bounced,
		ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM clique_bait.campaign_visit_stats)
		,1) AS bounce_rate
	FROM clique_bait.campaign_visit_stats
	WHERE page_views = 1
	GROUP BY page_views
	```

	Answer:

	| bounced | bounced_rate |
	|:-: | :-: |
	| Yes | 25.5 |

	- The bounce rate is 25.5%, which seems normal for any website.

Bonus: for the infographics check this [pdf file](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-6/6D-infographic.pdf).