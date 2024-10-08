# :avocado: Case Study #3: Foodie-Fi - Data Analysis Questions

## Case Study Questions
1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

***

###  1. How many customers has Foodie-Fi ever had?

```sql
SELECT COUNT(DISTINCT customer_id) AS 'number_of_customers'
FROM subscriptions;
``` 
	
#### Result set:

![PartB_QUESTION_1](https://github.com/user-attachments/assets/990591a4-acd7-42cb-b6a3-6aa3f3fc0208)

***

###  2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

```sql
SELECT 
	MONTH(start_date) AS 'MONTH',
	COUNT(plan_id) AS 'COUNT'
FROM subscriptions
WHERE plan_id = 0
GROUP BY MONTH
ORDER BY MONTH
;
``` 
	
#### Result set:

![PartB_Question_2](https://github.com/user-attachments/assets/089181b0-0bfb-4dcb-9031-8eb09e2ad2db)

***

###  3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

```sql
SELECT 
	plan_name, 
    COUNT(plan_name) AS 'COUNT'
FROM subscriptions AS S
JOIN plans AS P ON P.plan_id = S.plan_id
WHERE YEAR(start_date)> 2020
GROUP BY plan_name
ORDER BY COUNT(plan_name); 
``` 
	
#### Result set:

![PartB_Question_3](https://github.com/user-attachments/assets/609a0cfd-6260-483f-8943-bc1de5c7d1c9)

***

###  4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

```sql
SELECT 
    COUNT(customer_id) AS 'count_churn', 
    ROUND(COUNT(customer_id)/( SELECT COUNT(DISTINCT customer_id) AS 'number_of_customers'
FROM subscriptions)* 100,2) AS 'churn_percentage'
FROM subscriptions AS S
JOIN plans AS P ON P.plan_id = S.plan_id
WHERE plan_name = 'churn'
;
``` 
	
#### Result set:

![PartB_Question_4](https://github.com/user-attachments/assets/eeb0e12d-55f1-4552-911e-45e40b8aed4f)

***

###  5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

```sql
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
``` 
	
#### Result set:

![PartB_Question_5](https://github.com/user-attachments/assets/57af2bd8-1610-458b-a8d8-f16b4aa096f9)

***

###  6. What is the number and percentage of customer plans after their initial free trial?

```sql
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
``` 
	
#### Result set:

![PartB_Question 6](https://github.com/user-attachments/assets/6582e8a9-3110-42e9-8e21-8e3f52bdc6aa)

***

###  7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

```sql
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
``` 
	
#### Result set:

![PartB_Question_7](https://github.com/user-attachments/assets/fcd1d079-0e22-4547-990b-cb247097f88b)

***

###  8. How many customers have upgraded to an annual plan in 2020?

```sql
SELECT 
	plan_id,
	COUNT(*) AS 'count_of_customer'
FROM subscriptions
WHERE YEAR(start_date) = 2020
AND plan_id = 3
GROUP BY plan_id;
``` 
	
#### Result set:

![PartB_Question_8](https://github.com/user-attachments/assets/5ec3ea45-9da6-4e16-a752-c1c91f2e6d41)
  
***

###  9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

```sql
SELECT 
    ROUND(AVG(DATEDIFF( S1.start_date,S2.start_date)),0) AS 'AVG_NO_OF_DAYS'
FROM subscriptions AS S1
JOIN subscriptions AS S2 
    ON S1.customer_id = S2.customer_id  
WHERE S1.plan_id = 3                   
  AND S2.plan_id = 0;
``` 

#### Result set:

![PartB_Question 9](https://github.com/user-attachments/assets/7c6f9b04-1ffb-4bd2-9e1d-a044bffa28a2)

***

###  10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
skip
```sql

``` 
	
#### Result set:


***

###  11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

```sql
SELECT COUNT(*) AS 'NO_OF_CUSTOMER' FROM 
(SELECT *,
	LEAD(plan_id,1) OVER(ORDER BY customer_id) AS 'next_row'
	FROM subscriptions) AS S
WHERE YEAR(start_date) = 2020
AND 
plan_id = 2
AND 
next_row = 1;
``` 
	
#### Result set:

![PartB_Question_11](https://github.com/user-attachments/assets/70b2c543-b8f3-46ce-8114-bbcb8446aa54)

***

Click [here](https://github.com/Ali-Nouman02/Danny-s-8-Week-SQL-Challenge) to move back to the 8-Week-SQL-Challenge repository!

