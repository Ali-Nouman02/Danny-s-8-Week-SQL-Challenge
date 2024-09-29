-- PART A 
USE data_bank;
-- 1. How many unique nodes are there on the Data Bank system?

SELECT 
COUNT(DISTINCT(node_id)) AS 'nr_unique_nodes'
FROM customer_nodes;

-- 2. What is the number of nodes per region?

SELECT
	cn.region_id,
    r.region_name,
	COUNT(node_id) AS 'nr_nodes' 
FROM customer_nodes AS cn
JOIN regions AS r ON r.region_id = cn.region_id
GROUP BY cn.region_id,r.region_name;


-- 3. How many customers are allocated to each region?

SELECT 
	cn.region_id,
    r.region_name,
    COUNT(customer_id) AS 'nr_of_customers'
FROM customer_nodes AS cn
JOIN regions AS r ON r.region_id = cn.region_id
GROUP BY cn.region_id, r.region_name;
 
-- 4. How many days on average are customers reallocated to a different node?

SELECT 
    ROUND(AVG(DATEDIFF(end_date,start_date)),2) AS 'nr_of_days'
FROM customer_nodes
WHERE end_date != '9999-12-31';

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

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
    
-- could not figure this one out
SET @rowindex := -1;
WITH CTE AS (
	SELECT
		region_id,
		DATEDIFF(end_date,start_date) AS 'nr_of_days'
	FROM customer_nodes
	WHERE end_date != '9999-12-31'
),
CTE_2 AS(
SELECT 
	@rowindex := CASE 
	WHEN @prev_region_id IS NULL THEN 1 
	WHEN @prev_region_id = region_id THEN @rowindex + 1 
	ELSE 1 
	END AS rowindex,
	region_id,
	nr_of_days,

	@prev_region_id := region_id 

FROM CTE
ORDER BY region_id
),
MedianCTE AS (
	SELECT
		region_id,
        AVG(nr_of_days) AS 'median'
	FROM CTE_2
    WHERE rowindex IN(
		FLOOR((SELECT COUNT(*) FROM CTE_2 WHERE region_id = CTE_2.region_id) / 2),
		CEIL((SELECT COUNT(*) FROM CTE_2 WHERE region_id = CTE_2.region_id) / 2)
	)
    GROUP BY region_id
)

SELECT
	region_id,
	median
FROM MedianCTE
;

-- percentile rank
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



