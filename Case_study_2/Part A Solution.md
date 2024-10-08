# :pizza: Case Study #2: Pizza runner - Pizza Metrics

## Case Study Questions

1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?

***

###  1. How many pizzas were ordered?

```sql
-- count the number of the rows in the customer_order table
SELECT 
	COUNT(order_id) AS 'amount_of_orders'
FROM customer_orders;
``` 
	
#### Result set:

![Part_A_question_1](https://github.com/user-attachments/assets/29b5adf0-d7e5-41be-b2f8-ab6fb9848660)


***

###  2. How many unique customer orders were made?

```sql
-- count the number of distinct customer ids in customer table

SELECT
	COUNT(DISTINCT(customer_id)) AS 'amount_of_unique_customers'
FROM customer_orders;
``` 
	
#### Result set:
![Part_A_question_2](https://github.com/user-attachments/assets/ffcc2e52-9d9b-48a4-a8cc-41dbeb3b39b4)

***

###  3. How many successful orders were delivered by each runner?

```sql
WITH CTE AS(
	SELECT 
		runner_id, 
		RANK() OVER(PARTITION BY runner_id ORDER BY order_id) AS 'rnk'
	FROM runner_orders
	WHERE pickup_time != 'null'
	)
SELECT 
	runner_id,
    COUNT(rnk) AS 'successful orders'
FROM CTE
GROUP BY runner_id;
``` 
	
#### Result set:

![Part_A_question_3](https://github.com/user-attachments/assets/ef842468-659e-4b13-8c88-34563d2cc4da)

***

###  4. How many of each type of pizza was delivered?

```sql
SELECT
	PN.pizza_name, 
    COUNT(*) AS 'amount_of_orders_delivered'
FROM customer_orders AS CO
JOIN runner_orders AS RO ON RO.order_id = CO.order_id
JOIN pizza_names AS PN ON PN.pizza_id = CO.pizza_id
WHERE pickup_time != 'null'
GROUP BY PN.pizza_name;
``` 
	
#### Result set:

![Part_A_question_4](https://github.com/user-attachments/assets/264706d0-1ac3-49ad-a67f-1a3510af8e34)

***

###  5. How many Vegetarian and Meatlovers were ordered by each customer?

```sql
SELECT
	CO.customer_id, 
	PN.pizza_name,
    COUNT(*) AS 'amount_of_orders' 
FROM customer_orders AS CO
JOIN pizza_names AS PN ON PN.pizza_id = CO.pizza_id
GROUP BY CO.customer_id, PN.pizza_name
ORDER BY CO.customer_id; 
``` 
	
#### Result set:

![Part_A_question_5](https://github.com/user-attachments/assets/4f441ee1-ae9c-4ffa-a205-8803538e1198)

***

###  6. What was the maximum number of pizzas delivered in a single order?

```sql
SELECT
	CO.order_id, 
	CO.customer_id,
	COUNT(*) AS 'amount_of_pizzas'
FROM customer_orders AS CO
JOIN runner_orders AS RO ON RO.order_id = CO.order_id
WHERE pickup_time != 'null'
GROUP BY order_id,customer_id
ORDER BY amount_of_pizzas DESC
LIMIT 1;
``` 
	
#### Result set:

![Part_A_question_6](https://github.com/user-attachments/assets/82e6a3de-d257-4e93-b11f-64f47555134e)

***

###  7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

```sql
-- cleaning the tables so its easier to write the queries 
-- alter the exclustions column so that empty cells have 'null' as value
START TRANSACTION;
SET SQL_SAFE_UPDATES = 0;

UPDATE customer_orders
SET exclusions = 'null'
WHERE TRIM(exclusions) = '';

-- alter the extras column so that empty cells have 'null' as value
UPDATE customer_orders
SET extras = 'null'
WHERE TRIM(extras) = '' OR extras IS NULL  ;

COMMIT;
SET SQL_SAFE_UPDATES = 1;


WITH CTE AS(
	SELECT
		CO.order_id,
        CO.customer_id,
		CO.exclusions, 
		CO.extras,
		CO.extras = 'null' AND CO.exclusions = 'null' AS 'no_order',
		CO.extras != 'null' AND CO.exclusions = 'null' 
		OR 
		CO.extras = 'null' AND CO.exclusions != 'null'
		OR
		CO.extras != 'null' AND CO.exclusions != 'null' AS 'test',
		RANK() OVER(PARTITION BY customer_id) AS 'rnk'
	FROM customer_orders AS CO
	JOIN runner_orders AS RO ON RO.order_id = CO.order_id
	WHERE pickup_time != 'null'
    ) 
SELECT 
	customer_id, 
    SUM(no_order) AS 'no_changes',
    SUM(test) AS 'atleast_one_change'
FROM CTE
GROUP BY customer_id
;
``` 

#### Result set:

![Part_A_question_7](https://github.com/user-attachments/assets/d5668741-83a0-41b1-9cf0-3f9eb97dc171)

***

###  8. How many pizzas were delivered that had both exclusions and extras?

```sql
WITH CTE AS (
	SELECT
		CO.order_id,
		CO.customer_id,
		CO.exclusions, 
		CO.extras,
		CO.extras != 'null' AND CO.exclusions != 'null' AS 'chk'
	FROM customer_orders AS CO
	JOIN runner_orders AS RO ON RO.order_id = CO.order_id
	WHERE pickup_time != 'null'
	) 
SELECT 
	SUM(chk) AS 'both_exclusions_and_extras'
FROM CTE
;
``` 
	
#### Result set:

![Part_A_question_8](https://github.com/user-attachments/assets/6ee3471f-95a2-4932-b78e-26e3973e893a)

***

###  9. What was the total volume of pizzas ordered for each hour of the day?

```sql
 SELECT 
	HOUR(order_time) AS 'hour_of_the_day',
    COUNT(order_id) AS 'amount_of_orders'
 FROM customer_orders
 GROUP BY hour_of_the_day;
``` 
	
#### Result set:

![Part_A_question_9](https://github.com/user-attachments/assets/da49f19d-78a0-4852-9795-ee1f2800d9fd)

***

###  10. What was the volume of orders for each day of the week?

```sql
 SELECT 
	DAYNAME(order_time) AS 'hour_of_the_day',
    COUNT(order_id) AS 'amount_of_orders'
 FROM customer_orders
 GROUP BY hour_of_the_day;
``` 
	
#### Result set:

![Part_A_question_10](https://github.com/user-attachments/assets/ae8f9082-930b-4133-abd8-3f0cd4858cdb)

***


