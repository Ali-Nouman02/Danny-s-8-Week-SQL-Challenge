CREATE DATABASE pizza_runner;

USE pizza_runner; 

SELECT * FROM customer_orders; 
SELECT * FROM pizza_names;
SELECT * FROM pizza_recipes;
SELECT * FROM pizza_toppings;
SELECT * FROM runner_orders;
SELECT * FROM runners;

-- 1. How many pizzas were ordered?
-- count the number of the rows in the customer_order table
SELECT 
	COUNT(order_id) AS 'amount_of_orders'
FROM customer_orders;

-- 2. How many unique customer orders were made?´
-- count the number of distinct customer ids in customer table

SELECT
	COUNT(DISTINCT(customer_id)) AS 'amount_of_unique_customers'
FROM customer_orders; 

-- 3.How many successful orders were delivered by each runner?
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

-- 4. How many of each type of pizza was delivered?

SELECT
	PN.pizza_name, 
    COUNT(*) AS 'amount_of_orders_delivered'
FROM customer_orders AS CO
JOIN runner_orders AS RO ON RO.order_id = CO.order_id
JOIN pizza_names AS PN ON PN.pizza_id = CO.pizza_id
WHERE pickup_time != 'null'
GROUP BY PN.pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT
	CO.customer_id, 
	PN.pizza_name,
    COUNT(*) AS 'amount_of_orders' 
FROM customer_orders AS CO
JOIN pizza_names AS PN ON PN.pizza_id = CO.pizza_id
GROUP BY CO.customer_id, PN.pizza_name
ORDER BY CO.customer_id; 

-- 6. What was the maximum number of pizzas delivered in a single order?

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


-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

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


-- 8.How many pizzas were delivered that had both exclusions and extras?

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

-- 9. What was the total volume of pizzas ordered for each hour of the day?

 SELECT 
	HOUR(order_time) AS 'hour_of_the_day',
    COUNT(order_id) AS 'amount_of_orders'
 FROM customer_orders
 GROUP BY hour_of_the_day;

-- 10. What was the volume of orders for each day of the week?

 SELECT 
	DAYNAME(order_time) AS 'hour_of_the_day',
    COUNT(order_id) AS 'amount_of_orders'
 FROM customer_orders
 GROUP BY hour_of_the_day;
 
 -- PART B: Runner and Customer Experience
 
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
 
SELECT 
	WEEK(registration_date) AS 'week_nr',
    COUNT(runner_id)
FROM runners
GROUP BY week_nr; 

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

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

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

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


-- 4. What was the average distance travelled for each customer?

SELECT 
	customer_id,
	AVG(CAST(REPLACE(distance,'km', '') AS DECIMAL(3,1))) AS 'distance'
FROM customer_orders AS CO
JOIN runner_orders AS RO ON RO.order_id = CO.order_id
WHERE distance != 'null'
GROUP BY customer_id
;

-- 5. What was the difference between the longest and shortest delivery times for all orders?

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

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

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

-- 7. What is the successful delivery percentage for each runner?


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


-- C. Ingredient Optimisation

-- 1. What are the standard ingredients for each pizza?


WITH CTE AS (
	SELECT 
		pizza_id,
		TRIM(topping) AS 'topping_id'
	FROM 
		pizza_recipes AS PR,
		JSON_TABLE(
			CONCAT('["', REPLACE(toppings, ',', '","'), '"]'),
			'$[*]' COLUMNS (topping VARCHAR(255) PATH '$')
		) 
	AS toppings_split
    )
SELECT 
	CTE.pizza_id,
    GROUP_CONCAT(PT.topping_name) AS 'standard_ingredients'
FROM CTE
JOIN pizza_toppings AS PT on PT.topping_id = CTE.topping_id
GROUP BY pizza_id
ORDER BY pizza_id;


-- 2. What was the most commonly added extra?

-- Create temp table with no null value from customer_orders table

DROP TABLE temp_extras; 

CREATE TEMPORARY TABLE temp_extras AS
	SELECT 
		order_id, 
		extras
	FROM customer_orders
    WHERE extras != 'null';

WITH CTE AS (    
	SELECT 
		TRIM(extra) AS 'extra_id',
		COUNT(*) AS 'nr_of_count'
	FROM temp_extras AS TE,
	JSON_TABLE(
				CONCAT('["', REPLACE(extras, ',', '","'), '"]'),
				'$[*]' COLUMNS (extra VARCHAR(255) PATH '$')
			) 
		AS extras_split
		GROUP BY extra_id
		ORDER BY nr_of_count DESC
		LIMIT 1 
		)
SELECT 
	PT.topping_name AS 'most_common_topping'
FROM CTE AS CT
JOIN pizza_toppings AS PT ON PT.topping_id = CT.extra_id
;

-- 3. What was the most common exclusion?
-- Create temp table with no null value from customer_orders table

DROP TABLE temp_exclusion; 
CREATE TEMPORARY TABLE temp_exclusion AS
	SELECT 
		order_id, 
		exclusions
	FROM customer_orders
    WHERE exclusions != 'null';


WITH CTE AS (    
	SELECT 
		TRIM(exclusion) AS 'exclusion_id',
		COUNT(*) AS 'nr_of_count'
	FROM temp_exclusion AS TE,
	JSON_TABLE(
				CONCAT('["', REPLACE(exclusions, ',', '","'), '"]'),
				'$[*]' COLUMNS (exclusion VARCHAR(255) PATH '$')
			) 
		AS exclusion_split
		GROUP BY exclusion_id
		ORDER BY nr_of_count DESC
		LIMIT 1 
		)
SELECT 
	PT.topping_name AS 'most_excluded_topping'
FROM CTE AS CT
JOIN pizza_toppings AS PT ON PT.topping_id = CT.exclusion_id
;

-- 4. Generate an order item for each record in the customers_orders table 

DROP TABLE temp_exclude_and_extra;
-- changing data from comma seperated values into multiple rows
CREATE TEMPORARY TABLE temp_exclude_and_extra AS
SELECT 
	order_id,
    pizza_id,
	TRIM(exclusion) AS 'Temp_exclude',
    TRIM(extra) AS 'Temp_extra'
FROM customer_orders AS CO,
JSON_TABLE(
			CONCAT('["', REPLACE(exclusions, ',', '","'), '"]'),
			'$[*]' COLUMNS (exclusion VARCHAR(255) PATH '$')
		) AS exclusion_split,
JSON_TABLE(
			CONCAT('["', REPLACE(extras, ',', '","'), '"]'),
			'$[*]' COLUMNS (extra VARCHAR(255) PATH '$')
		) AS extra_split;



CREATE TEMPORARY TABLE temp_four AS
SELECT 
	order_id, 
    EE.pizza_id, 
    PN.pizza_name,
    PT_1.topping_name AS 'EXCLUDE', 
    PT_2.topping_name AS 'EXTRA'
FROM temp_exclude_and_extra AS EE
LEFT JOIN pizza_toppings AS PT_1 ON PT_1.topping_id = EE.Temp_exclude
LEFT JOIN pizza_toppings AS PT_2 ON PT_2.topping_id = EE.Temp_extra
LEFT JOIN pizza_names AS PN on PN.pizza_id = EE.pizza_id ;

-- final results 
WITH CTE AS(
	SELECT 
		order_id,
		pizza_id,
		pizza_name,
		CONCAT(
			IFNULL(
				CONCAT(
					'Include ', 
					GROUP_CONCAT(DISTINCT extra ORDER BY extra SEPARATOR ', ')
				), 
				''
			),
			IF(
				CONCAT(
					GROUP_CONCAT(DISTINCT extra ORDER BY extra SEPARATOR ', ')
				) != '' AND CONCAT(
					GROUP_CONCAT(DISTINCT exclude ORDER BY exclude SEPARATOR ', ')
				) != '', 
				' - ', 
				''
			),
			IFNULL(
				CONCAT(
					'Exclude ', 
					GROUP_CONCAT(DISTINCT exclude ORDER BY exclude SEPARATOR ', ')
				), 
				''
			)
		) AS 'include_exclude'
	FROM temp_four
	GROUP BY 
		order_id, 
		pizza_id, 
		pizza_name
		)
SELECT 
	order_id, 
	CONCAT(IF (include_exclude != '',CONCAT(pizza_name,' - ',include_exclude), ''),
    IF (include_exclude = '', pizza_name,''))  AS 'order_item'
FROM CTE;

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients


-- 5 skip 

-- 6 skip 
-- for another day 


-- PART D: Pricing and Ratings

-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?


WITH CTE AS ( 
	SELECT 
		PN.pizza_name,
		COUNT(*) AS 'cnt', 
		CASE 
			WHEN pizza_name = 'Meatlovers' THEN (COUNT(*) * 12)
			WHEN pizza_name = 'Vegetarian' THEN (COUNT(*) * 10)
		END AS 'total'
	FROM customer_orders AS CO 
	JOIN pizza_names AS PN on PN.pizza_id = CO.pizza_id
	GROUP BY PN.pizza_name
	) 
SELECT 
SUM(total) AS 'TOTAL_EARNED'
FROM CTE;


-- 2. What if there was an additional $1 charge for any pizza extras?

SELECT * FROM customer_orders; 
SELECT * FROM pizza_names;

DROP TEMPORARY TABLE delivery; 
CREATE TEMPORARY TABLE delivery AS
SELECT 
	CO.order_id,
    CO.pizza_id,
	TRIM(extra) AS 'extra_id'
FROM customer_orders AS CO,
JSON_TABLE(
		CONCAT('["', REPLACE(extras, ',', '","'), '"]'),
		'$[*]' COLUMNS (extra VARCHAR(255) PATH '$')
	) 
AS extras_split;


WITH CTE AS (
	SELECT 
		D.order_id, 
		D.pizza_id,
		extra_id ,
		PN.pizza_name,
		CASE
		WHEN pizza_name = 'Meatlovers' AND extra_id = 'null' THEN 12 
		WHEN pizza_name = 'Vegetarian' AND extra_id = 'null' THEN 10
		WHEN pizza_name = 'Meatlovers' AND extra_id != 'null' THEN 12 + 1
		WHEN pizza_name = 'Vegetarian' AND extra_id != 'null' THEN 10 + 1
		END AS price 
	FROM delivery AS D
	JOIN pizza_names AS PN ON PN.pizza_id = D.pizza_id
	)
SELECT 
	SUM(price) AS 'total_earned'
FROM CTE; 


-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

DROP TABLE IF EXISTS runner_rating;
CREATE TABLE runner_rating (order_id INTEGER, rating INTEGER) ;

-- Order 6 and 9 were cancelled
INSERT INTO runner_rating
VALUES ('1', '1'),
       ('2', '1'),
       ('3', '4'),
       ('4', '1'),
       ('5', '2'),
       ('7', '5'),
       ('8', '2'),
       ('10', '5');
       
SELECT * FROM runner_rating;

-- 4. JOINING ALL TABLES 

SELECT
	CO.customer_id, 
    CO.order_id, 
    RO.runner_id, 
    RR.rating,
    CO.order_time, 
    RO.pickup_time,
    CONCAT(MINUTE(TIMEDIFF(order_time, pickup_time)), ' mins') AS 'time_between_order_&_pickup',
    CONCAT(CAST(LEFT(RO.duration,2) AS DECIMAL),' mins') AS 'delivery_duration',
    ROUND((CAST(REPLACE(RO.distance,'km', '') AS DECIMAL(3,1)) / 
    CAST(LEFT(RO.duration,2) AS DECIMAL))*60,2) AS 'average_speed_per_km',
    COUNT(pizza_id) AS 'total_nr_of_pizzas'
FROM customer_orders AS CO
JOIN runner_orders RO ON RO.order_id = CO.order_id
JOIN runner_rating RR ON RR.order_id = CO.order_id
GROUP BY CO.order_id, CO.customer_id, RO.runner_id, RR.rating, CO.order_time,
		RO.pickup_time,
        CONCAT(MINUTE(TIMEDIFF(order_time, pickup_time)), ' mins'),
        CONCAT(CAST(LEFT(RO.duration,2) AS DECIMAL),' mins'),
        ROUND((CAST(REPLACE(RO.distance,'km', '') AS DECIMAL(3,1)) / 
		CAST(LEFT(RO.duration,2) AS DECIMAL))*60,2)
        ;
-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
 

 WITH TOTAL_REVENUE AS ( 
	SELECT 
		PN.pizza_name,
		COUNT(*) AS 'cnt', 
		CASE 
			WHEN pizza_name = 'Meatlovers' THEN (COUNT(*) * 12)
			WHEN pizza_name = 'Vegetarian' THEN (COUNT(*) * 10)
		END AS 'total'
	FROM customer_orders AS CO 
	JOIN pizza_names AS PN on PN.pizza_id = CO.pizza_id
	GROUP BY PN.pizza_name
	) 
SELECT 
SUM(total) - (SELECT 	
		SUM(ROUND(CAST(REPLACE(distance, 'km', '') AS DECIMAL(5,2)), 1) 
		*
		0.30 )'total_runner_pay'
	FROM runner_orders
	WHERE pickup_time != 'null')
 AS 'TOTAL_PROFIT'
FROM TOTAL_REVENUE; 


