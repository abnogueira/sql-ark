# Case Study #6: Clique Bait 🍤

## Solution - A. Enterprise Relationship Diagram

### 1. Using a given DDL schema details to create an ERD for all the Clique Bait datasets.

Access the DB Diagram tool to create the ERD.

#### Answer:

Here is the Entity Relationship Diagram:

![image](https://8weeksqlchallenge.com/images/case-study-6-ERdiagram.png "ER diagram")

Note:

- There is no connection between `campaign_identifier` and `page_hierarchy` because `products` from `campaign_identifier` table shows a range of `product_id`s. So there is no direct link, because it's necessary to apply some transformation.