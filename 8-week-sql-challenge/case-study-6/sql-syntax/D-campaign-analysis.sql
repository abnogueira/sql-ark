------------------------------
--CASE STUDY #6: CLIQUE BAIT--
------------------------------

--Author: Anabela Nogueira
--Date: 2023/05/18
--Tool used: Posgresql

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. Generate a table that has 1 single row for every unique visit_id record and designed columns:
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

--2. Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a single A4 infographic that the team can use for their management reporting sessions, be sure to emphasise the most important points from your findings.
--Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
SELECT 
	CASE impression WHEN 1 THEN 'Yes' ELSE 'No' END AS received_impressions,
	COUNT(*) AS visits_total,
	ROUND(AVG(page_views)) AS avg_page_views,
	ROUND(AVG(cart_adds)) AS avg_cart_adds,
	ROUND(100.0 * SUM(purchase)/ count(*), 1) AS purchase_rate_pcent
FROM clique_bait.campaign_visit_stats
GROUP BY 1
ORDER BY 5 DESC

-- What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
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

-- What metrics can you use to quantify the success or failure of each campaign compared to eachother
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

-- Calculate the bounce rate, which give us the amount of people that leave at the first page they view.
SELECT 
	CASE WHEN page_views = 1 THEN 'Yes' ELSE 'No' END AS bounced,
	ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM clique_bait.campaign_visit_stats)
	,1) AS bounce_rate
FROM clique_bait.campaign_visit_stats
WHERE page_views = 1
GROUP BY page_views