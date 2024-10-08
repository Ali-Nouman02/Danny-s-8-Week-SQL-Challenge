# :pizza: Case Study #2: Pizza runner - Runner and Customer Experience

## Case Study Questions

1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner?

***

###  1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

```sql
SELECT 
	WEEK(registration_date) AS 'week_nr',
    COUNT(runner_id)
FROM runners
GROUP BY week_nr; 
``` 
	
#### Result set:

![question_1](https://github.com/user-attachments/assets/bfcdd6ac-4dd6-4079-9853-a4ece10c0cc7)

***

###  2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

```sql
WITH CTE AS ( 
	SELECT 
		runner_id, 
		MINUTE(TIMEDIFF(order_time,pickup_time)) AS 'time_in_min'
	FROM runner_orders AS RO 
    JOIN customer_orders AS CO ON CO.order_id = RO.order_id
    WHERE pickup_time != 'null'
	)
SELECT
	runner_id,
	CONCAT(CEIL(AVG(time_in_min)),' mins') AS 'avg_pickup_time'
FROM CTE
GROUP BY runner_id; 
``` 
	
#### Result set:
![question_2](https://github.com/user-attachments/assets/a3a87056-3e97-427a-814b-b985af6adcea)

***

###  3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

```sql
WITH CTE AS(
	SELECT
		CO.order_id, 
		CO.customer_id,
		COUNT(*) AS 'amount_of_pizzas',
		CONCAT(MINUTE(TIMEDIFF(order_time,pickup_time)),' mins') AS 'prep_time'
	FROM customer_orders AS CO
	JOIN runner_orders AS RO ON RO.order_id = CO.order_id
	WHERE pickup_time != 'null'
	GROUP BY order_id,customer_id,prep_time
	ORDER BY amount_of_pizzas DESC
	)
SELECT
	amount_of_pizzas, 
    AVG(prep_time) AS 'avg_prep_time'
FROM CTE
GROUP BY  amount_of_pizzas
;
``` 
	
#### Result set:

![question_3](https://github.com/user-attachments/assets/577442cf-8a9c-4159-ad5a-62dca82ee8b0)

***

###  4. What was the average distance travelled for each customer?

```sql
SELECT 
	customer_id,
	AVG(CAST(REPLACE(distance,'km', '') AS DECIMAL(3,1))) AS 'distance'
FROM customer_orders AS CO
JOIN runner_orders AS RO ON RO.order_id = CO.order_id
WHERE distance != 'null'
GROUP BY customer_id
;
``` 
	
#### Result set:

![question_4](https://github.com/user-attachments/assets/c4e13fd8-ff63-4907-8601-4b2735d05f22)

***

###  5. What was the difference between the longest and shortest delivery times for all orders?

```sql
WITH CTE AS (
	SELECT
		order_id, 
		runner_id,
		CAST(LEFT(duration,2) AS DECIMAL(3,0)) AS 'time'
	FROM runner_orders
	WHERE pickup_time != 'null'
	) 
SELECT 
	(MAX(time) - MIN(time)) AS 'diff'
FROM CTE
;
``` 
	
#### Result set:

![question_5](https://github.com/user-attachments/assets/24a28d64-8eb5-45d2-a0fb-112879089e03)

***

###  6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

```sql
WITH CTE AS(
	SELECT
		order_id, 
		runner_id,
		CAST(REPLACE(distance,'km', '') AS DECIMAL(3,1)) AS 'distance',
		CAST(LEFT(duration,2) AS DECIMAL(3,0)) AS 'time'
	FROM runner_orders
	WHERE pickup_time != 'null'
	)
SELECT
	order_id,
    runner_id,
	ROUND(AVG(distance / CTE.time),2) AS 'avg_speed_per_min'
FROM CTE
GROUP BY runner_id, order_id
ORDER BY order_id
;
``` 
	
#### Result set:

![question_6](https://github.com/user-attachments/assets/341d66b0-2559-4df3-a9db-28288e1d8229)

***

###  7. What is the successful delivery percentage for each runner?

```sql
-- alter the cancellation column so that empty cells have 'null' as value
START TRANSACTION;
SET SQL_SAFE_UPDATES = 0;

UPDATE runner_orders
SET cancellation = 'null'
WHERE TRIM(cancellation) = '' OR cancellation IS NULL  ;

COMMIT;
SET SQL_SAFE_UPDATES = 1;

SELECT
	runner_id,
	COUNT(*) AS 'number_of_delivery',
    COUNT(CASE WHEN cancellation = 'null' THEN 1 END) AS 'nr_of_successful_delivery',
    ROUND((COUNT(CASE WHEN cancellation = 'null' THEN 1 END) / COUNT(*)) * 100,1) AS 'success_rate'
FROM runner_orders
GROUP BY runner_id;
``` 
	
#### Result set:

![question_7](https://github.com/user-attachments/assets/9619408c-44d8-4ab1-9969-aa5389aa8920)

***


