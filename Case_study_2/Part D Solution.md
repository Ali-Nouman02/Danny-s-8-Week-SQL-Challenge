# :pizza: Case Study #2: Pizza runner - Pricing and Ratings

## Case Study Questions

1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra
3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
- customer_id
- order_id
- runner_id
- rating
- order_time
- pickup_time
- Time between order and pickup
- Delivery duration
- Average speed
- Total number of pizzas
5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

***

###  1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

```sql
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
``` 
	
#### Result set:
![question 1](https://github.com/user-attachments/assets/8b339afe-84b1-461b-ba33-9e45325ddedb)


***

###  2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra

```sql
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
``` 
	
#### Result set:

![question 2](https://github.com/user-attachments/assets/b43b407e-1dda-4e60-b077-a8cf662e144d)


***

###  3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

```sql
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
``` 
	
#### Result set:

![question 3](https://github.com/user-attachments/assets/00d9d246-db95-4349-a76f-79520355982f)


***

###  4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?

```sql
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
``` 
	
#### Result set:
![question 4](https://github.com/user-attachments/assets/807ebdcb-b1f8-4b15-be05-f100aa51c5af)


***

###  5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

```sql
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
``` 
	
#### Result set:

![question 5](https://github.com/user-attachments/assets/b00a6620-8f09-4f96-8b65-562b7bf70c42)

***


Click [here](https://github.com/Ali-Nouman02/Danny-s-8-Week-SQL-Challenge) to move back to the 8-Week-SQL-Challenge repository!

