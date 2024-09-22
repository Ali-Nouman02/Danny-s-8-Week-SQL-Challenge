USE foodie_fie;



-- Part B: 
-- 1. How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT customer_id) AS 'number_of_customers'
FROM subscriptions;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT 
		MONTH(start_date) AS 'MONTH',
		COUNT(plan_id) AS 'COUNT'
FROM subscriptions
WHERE plan_id = 0
GROUP BY MONTH
ORDER BY MONTH
;

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT 
	plan_name, 
    COUNT(plan_name) AS 'COUNT'
FROM subscriptions AS S
JOIN plans AS P ON P.plan_id = S.plan_id
WHERE YEAR(start_date)> 2020
GROUP BY plan_name
ORDER BY COUNT(plan_name); 

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT 
    COUNT(customer_id) AS 'count_churn', 
    ROUND(COUNT(customer_id)/( SELECT COUNT(DISTINCT customer_id) AS 'number_of_customers'
FROM subscriptions)* 100,2) AS 'churn_percentage'
FROM subscriptions AS S
JOIN plans AS P ON P.plan_id = S.plan_id
WHERE plan_name = 'churn'
;

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

WITH CTE AS (
	SELECT * FROM
	(SELECT *,
	LEAD(plan_id) OVER(ORDER BY customer_id) AS 'next_row'
	FROM subscriptions) AS S
	WHERE plan_id = 0
	AND
	next_row = 4
)
SELECT 
	COUNT(customer_id) AS 'churn_after_trial',
    CONCAT(ROUND(COUNT(customer_id)/(SELECT COUNT(DISTINCT(customer_id))
FROM subscriptions)* 100,2),'%') AS 'percentage'
FROM CTE
;

-- 6. What is the number and percentage of customer plans after their initial free trial?

WITH TotalCustomers AS (
    SELECT COUNT(DISTINCT S.customer_id) AS total_customers
    FROM subscriptions AS S
)
SELECT 
    P.plan_name,
    COUNT(DISTINCT S.customer_id) AS customer_count,
    CONCAT(ROUND((COUNT(DISTINCT S.customer_id) /
    T.total_customers)*100,2),'%') AS 'customer_percentage'
FROM subscriptions AS S
JOIN plans AS P ON P.plan_id = S.plan_id
CROSS JOIN TotalCustomers AS T
WHERE P.plan_name != 'trial'
GROUP BY P.plan_name, T.total_customers
ORDER BY customer_count;


-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

SELECT 
	P.plan_name,
    COUNT(S.customer_id) AS 'count_of_customer',
    CONCAT(ROUND((COUNT(S.customer_id)/
    (SELECT COUNT(DISTINCT(customer_id)) FROM subscriptions))*100,2), '%') 
    AS 'customer_percentage'
FROM subscriptions AS S
JOIN plans AS P ON P.plan_id = S.plan_id
WHERE S.start_date <= '2020-12-31'
GROUP BY P.plan_name
ORDER BY COUNT(S.customer_id);
    
-- 8. How many customers have upgraded to an annual plan in 2020?

SELECT 
	plan_id,
	COUNT(*) AS 'count_of_customer'
FROM subscriptions
WHERE YEAR(start_date) = 2020
AND plan_id = 3
GROUP BY plan_id;

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

SELECT 
    ROUND(AVG(DATEDIFF( S1.start_date,S2.start_date)),0) AS 'AVG_NO_OF_DAYS'
FROM subscriptions AS S1
JOIN subscriptions AS S2 
    ON S1.customer_id = S2.customer_id  
WHERE S1.plan_id = 3                   
  AND S2.plan_id = 0;

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

-- skip
SELECT
	S1.customer_id,
	DATEDIFF( S1.start_date,S2.start_date) AS 'NO_OF_DAYS'
FROM subscriptions AS S1
JOIN subscriptions AS S2 
    ON S1.customer_id = S2.customer_id  
WHERE S1.plan_id = 3                   
  AND S2.plan_id = 0;

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

SELECT COUNT(*) AS 'NO_OF_CUSTOMER' FROM 
(SELECT *,
	LEAD(plan_id,1) OVER(ORDER BY customer_id) AS 'next_row'
	FROM subscriptions) AS S
WHERE YEAR(start_date) = 2020
AND 
plan_id = 2
AND 
next_row = 1;
