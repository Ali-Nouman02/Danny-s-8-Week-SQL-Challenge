## :technologist::woman_technologist: Case Study #4: Data Bank - Customer Nodes Exploration

## Case Study Questions

1. How many unique nodes are there on the Data Bank system?
2. What is the number of nodes per region?
3. How many customers are allocated to each region?
4. How many days on average are customers reallocated to a different node?
5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

***

###  1. How many unique nodes are there on the Data Bank system?

```sql
SELECT 
COUNT(DISTINCT(node_id)) AS 'nr_unique_nodes'
FROM customer_nodes;
``` 
	
#### Result set:

![Part A_Question 1](https://github.com/user-attachments/assets/86cfbb66-3eea-4f9c-adb1-ceb3476e739f)


***

###  2. What is the number of nodes per region?

```sql
SELECT
	cn.region_id,
    r.region_name,
	COUNT(node_id) AS 'nr_nodes' 
FROM customer_nodes AS cn
JOIN regions AS r ON r.region_id = cn.region_id
GROUP BY cn.region_id,r.region_name;

``` 
	
#### Result set:

![PartA_Question 2](https://github.com/user-attachments/assets/80f01145-657c-455b-a4d1-472a1e67f90f)

***

###  3. How many customers are allocated to each region?

```sql
SELECT 
	cn.region_id,
    r.region_name,
    COUNT(customer_id) AS 'nr_of_customers'
FROM customer_nodes AS cn
JOIN regions AS r ON r.region_id = cn.region_id
GROUP BY cn.region_id, r.region_name;
``` 
	
#### Result set:

![question 3](https://github.com/user-attachments/assets/d35afd3e-2598-4f71-92cd-98bb3023b65e)

***

###  4. How many days on average are customers reallocated to a different node?

```sql
SELECT 
    ROUND(AVG(DATEDIFF(end_date,start_date)),2) AS 'nr_of_days'
FROM customer_nodes
WHERE end_date != '9999-12-31';
``` 
	
#### Result set:

![question 4](https://github.com/user-attachments/assets/df61739e-3609-4b64-8159-815be8dd5eb4)

***

###  5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?


**Median**
```sql
-- correct query Median for all data(not grouped by region)

SET @rowindex := -1;
WITH CTE AS (
	SELECT
		region_id,
		DATEDIFF(end_date,start_date) AS 'nr_of_days'
	FROM customer_nodes
	WHERE end_date != '9999-12-31'
),
CTE_2 AS (
SELECT 
	@rowindex:=@rowindex + 1 AS 'rowindex',
	nr_of_days
FROM CTE
ORDER BY nr_of_days ASC
)
SELECT 
	AVG(nr_of_days) AS 'median'
FROM CTE_2
WHERE 
	rowindex IN (FLOOR(@rowindex /2), CEIL(@rowindex /2));
``` 
	
#### Result set:

![question 5](https://github.com/user-attachments/assets/d291eea2-47ce-4ae3-abe3-b2d25845703c)


**80th percentile**

```sql
-- 80 percentile 

WITH CTE AS (
	SELECT
		cn.region_id,
		r.region_name,
        DATEDIFF(end_date,start_date) AS 'days_diff',
		ROUND(PERCENT_RANK() OVER(ORDER BY DATEDIFF(end_date,start_date)),2) AS 'per_rank' 
	FROM customer_nodes AS cn
	JOIN regions AS r ON r.region_id = cn.region_id
	WHERE end_date != '9999-12-31'
)
SELECT
	region_name,
	days_diff
FROM CTE
WHERE per_rank >= 0.80
GROUP BY region_name, days_diff
;
``` 
	
#### Result set:

![question 5 80 percentile](https://github.com/user-attachments/assets/3666586b-6f65-4b7b-b7bd-2dcd721863a0)


**95th percentile**
```sql
-- 95 percentile

WITH CTE AS (
	SELECT
		cn.region_id,
		r.region_name,
        DATEDIFF(end_date,start_date) AS 'days_diff',
		ROUND(PERCENT_RANK() OVER(ORDER BY DATEDIFF(end_date,start_date)),2) AS 'per_rank' 
	FROM customer_nodes AS cn
	JOIN regions AS r ON r.region_id = cn.region_id
	WHERE end_date != '9999-12-31'
)
SELECT
	region_name,
	days_diff
FROM CTE
WHERE per_rank >= 0.95
GROUP BY region_name, days_diff
;
``` 
	
#### Result set:

![question 5_95_percentile](https://github.com/user-attachments/assets/9eb6a54c-41c8-431c-a888-4814d9c283c0)

***

Click [here](https://github.com/Ali-Nouman02/Danny-s-8-Week-SQL-Challenge) to move back to the 8-Week-SQL-Challenge repository!
