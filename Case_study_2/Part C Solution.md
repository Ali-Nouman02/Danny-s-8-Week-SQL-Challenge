# :pizza: Case Study #2: Pizza runner - Ingredient Optimisation WIP

## Case Study Questions

1. What are the standard ingredients for each pizza?
2. What was the most commonly added extra?
3. What was the most common exclusion?
4. Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

***



###  1. What are the standard ingredients for each pizza?

```sql
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
``` 
	
#### Result set:

![question_1](https://github.com/user-attachments/assets/19ba5655-d5a1-4ab2-b811-73a97d21be37)

***

###  2. What was the most commonly added extra?

```sql
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
``` 
	
#### Result set:

![question_2](https://github.com/user-attachments/assets/4719f2bd-18f3-4f95-894c-b2394c8567ef)

***

###  3. What was the most common exclusion?

```sql
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
``` 
	
#### Result set:

![question_3](https://github.com/user-attachments/assets/1ec858af-1a84-40ba-a857-58903fadf409)

***

###  4. Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

```sql
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

``` 
	
#### Result set:

![question_4](https://github.com/user-attachments/assets/058f4f4e-9a5c-43fe-81e8-74db7c7d34d5)

***

###  5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
- skip


	
#### Result set:

***

###  6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

```sql

``` 
	
#### Result set:

***

Click [here](https://github.com/manaswikamila05/8-Week-SQL-Challenge/blob/main/Case%20Study%20%23%202%20-%20Pizza%20Runner/D.%20Pricing%20and%20Ratings.md) to view the  solution of D. Pricing and Ratings!
