# Case Study #6: Clique Bait 🍤

## Solution - B. Digital Analysis Questions

View the complete syntax in [here](https://github.com/abnogueira/sql-ark/blob/main/8-week-sql-challenge/case-study-6/sql-syntax/B-digital-analysis.sql).

---

### 1. How many users are there?

```sql
SELECT COUNT(DISTINCT user_id) as total_users
FROM clique_bait.users;
```

#### Steps:

- Use `DISTINCT` and `COUNT` to get the total number of users using `user_id` from table `users`.

#### Answer:

| total_users |
| :-: |
| 500|

- There are 500 unique users.

---

### 2. How many cookies does each user have on average?

```sql
WITH cte_cookies_per_user AS (
	SELECT COUNT(cookie_id) AS count_cookies
	FROM clique_bait.users
	GROUP BY user_id
)
SELECT ROUND(AVG(count_cookies), 0) AS avg_cookies_per_user
FROM cte_cookies_per_user;
```

#### Steps:

- Create a CTE named `cte_cookies_per_user` which gives us the total number of cookies per user, by using `COUNT` of `cookie_id` and by `GROUP BY` the `user_id` from table `users`.
- Use `AVG` function over the `count_cookies` given by the `cte_cookies_per_user`, and use `ROUND` to round the final number to 0 decimal points.

#### Answer:

| avg_cookies_per_user |
| :-: |
| 4|

- On average, each user has 4 cookies.

---

### 3. What is the unique number of visits by all users per month?

```sql
SELECT date_part('month', event_time) AS monthly, 
	COUNT(DISTINCT visit_id) AS total_visits 
FROM clique_bait.events
GROUP BY date_part('month', event_time);
```

#### Steps

- Extract month from `event_time`, in order to be able to `GROUP BY` the data by month.
- Use `DISTINCT` and `COUNT` to calculate the unique number of visits using `visit_id` from table `events`.

#### Answer:

| monthly | total_users |
| -: | -: |
| 1|	876|
| 2|	1488|
| 3|	916|
| 4|	248|
| 5|	36|

---

### 4. What is the number of events for each event type?

```sql
SELECT event_type, COUNT(visit_id) AS total_events 
FROM clique_bait.events
GROUP BY 1
ORDER BY 1;
```

#### Answer:

| event_type | total_events |
| -: | -: |
| 1| 20928|
| 2| 8451|
| 3| 1777|
| 4| 876|
| 5| 702|

---

### 5. What is the percentage of visits which have a purchase event?

```sql
SELECT ROUND(COUNT(DISTINCT visit_id)::decimal / (
	SELECT COUNT(DISTINCT visit_id) FROM clique_bait.events
	) * 100, 1) AS pe_pcent
FROM clique_bait.events e
JOIN clique_bait.event_identifier i 
	ON e.event_type = i.event_type
WHERE event_name = 'Purchase';
```

#### Steps

- To identify a `Purchase` event, join the tables `events` and `events_identifier`. Then filter data by `Purchase` event only.
- Use `COUNT` on `visit_id` to know the number of visits with a purchase event, since data is filtered by purchase event.
- Use a sub-query to `COUNT` the total of distinct

#### Answer:

| pe_pcent |
| :-: |
| 49.9|

- Around of 49.9% of visits have a purchase event.

---

### 6. What is the percentage of visits which view the checkout page but do not have a purchase event?

```sql
WITH cte_visitor_checkout AS (
	SELECT DISTINCT e.visit_id
	FROM clique_bait.events e
	JOIN clique_bait.event_identifier i 
		ON e.event_type = i.event_type
	JOIN clique_bait.page_hierarchy p
		ON p.page_id = e.page_id
	WHERE p.page_name = 'Checkout'
)
SELECT ROUND(COUNT(DISTINCT visit_id)::decimal / (
	SELECT COUNT(*) FROM cte_visitor_checkout
	) * 100, 1) AS pcent
FROM cte_visitor_checkout
WHERE visit_id NOT IN (
		SELECT DISTINCT visit_id
		FROM clique_bait.events e
		JOIN clique_bait.event_identifier i 
			ON e.event_type = i.event_type
		WHERE i.event_name = 'Purchase'
	);
```

#### Steps

- First we need to count all the visitors who visited the Checkout page. Create a CTE named `cte_visitor_checkout`, which lists all `visit_id`s that visited `Checkout` page.
- Next we need to exclude the visits that had a purchase event - we can exclude these IDs using the WHERE statement with a sub-query that list all `visit_id`s that visited `Purchase` page.
- Now, `DISTINCT visit_id` list all visit_ids that viewed `Checkout` page with a purchase event. To calculate the percentage of these visits, use this number divided by `COUNT` of rows from CTE, multiplied by 100.

#### Answer:

| pcent |
| :-: |
| 15.5|

- 15.5% of visits view the checkout page but do not have a purchase event.

---

### 7. What are the top 3 pages by number of views?

```sql
SELECT p.page_name, 
	count(page_name) AS total_views
FROM clique_bait.events e
JOIN clique_bait.event_identifier i 
	ON e.event_type = i.event_type
JOIN clique_bait.page_hierarchy p
	ON p.page_id = e.page_id
WHERE i.event_name = 'Page View'
GROUP BY p.page_name
ORDER BY total_views DESC
LIMIT 3;
```

#### Steps

- `Events` tables list events, and since we want to count top pages, we need to count page views. So join events with event_identifier, to add `WHERE` clause to filter only `Page View`s.
- Next, join `page_hierarchy` table, to get `page_name`.
- Use `COUNT` to calculate the total of `page_name`.
- Order by descending order, and limit to 3, to get only the top 3 pages.

#### Answer:

| page_name | total_views |
| :-: | -: |
| All Products|	3174|
| Checkout|	2103|
| Home Page|	1782|

- Top 3 most viewed pages are: All Products, Checkout and Home Page.

---

### 8. What is the number of views and cart adds for each product category?

```sql
SELECT 
	p.product_category, 
	SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_views,
	SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_adds
FROM clique_bait.events AS e
JOIN clique_bait.page_hierarchy AS p
	ON e.page_id = p.page_id
WHERE p.product_category IS NOT NULL
GROUP BY p.product_category
ORDER BY page_views DESC;
```

#### Steps

- Problem: count the number of `Page View`s and `Add to Cart` events by category.
- Use `CASE WHEN` statement: if an event name is equal to 'Page View', then we count it as 1, otherwise we count it as 0. After that we can `SUM` the results. We repeat this query to count 'Add to Cart' events too.
- And we need to exclude from the count products with the null ID - to do that we add a special condition to the `WHERE` statement.

#### Answer:

| product_category | page_views | cart_adds |
| :-: | -: | -: |
| Shellfish|	6204|	3792|
| Fish|	4633|	2789|
| Luxury|	3032|	1870|

---

### 9. What are the top 3 products by purchases?

```sql
SELECT p.page_name,
	COUNT(p.page_name) AS total_purchases
FROM clique_bait.events AS e
JOIN clique_bait.event_identifier AS i
	ON e.event_type = i.event_type
JOIN clique_bait.page_hierarchy AS p
	ON e.page_id = p.page_id
WHERE product_id IS NOT NULL 
	AND event_name = 'Add to Cart'
	AND visit_id in (
        SELECT DISTINCT visit_id
        FROM clique_bait.events
        WHERE event_type = 3)
GROUP BY p.page_name
ORDER BY total_purchases DESC
LIMIT 3;
```

#### Steps

- In order to identify `product_id` we need information from `page_hierarchy` table. It's not possible to use the information from events with `event_type` as 3 which is a `Purchase`, since the `page_id` is always 13.
- If a product is added to cart, it has an 'Add to Cart' event recorded. And to count purchases, let's use `visit_id` records that associated with events had a `Purchase` event.

#### Answer:

| page_name | total_purchases |
| :-: | -: |
| Lobster|	754|
| Oyster|	726|
| Crab|	719|