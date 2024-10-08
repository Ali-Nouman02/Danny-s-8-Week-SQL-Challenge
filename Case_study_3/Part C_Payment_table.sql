USE foodie_fie;

SELECT * FROM plans;



--  MAIN QUERY

WITH RECURSIVE date_series AS(

	SELECT 
		S.start_date AS 'payment_date',
        S.customer_id,
        P.plan_id,
        P.plan_name,
        P.price AS 'amount'
    FROM subscriptions AS S
    JOIN plans AS P on P.plan_id = S.plan_id
    WHERE S.plan_id != 0
    
    UNION ALL
    
    SELECT 
		DATE_ADD(CAST(payment_date AS DATE), INTERVAL 1 MONTH),
        customer_id,
        plan_id,
        plan_name,
        amount
    FROM date_series
    WHERE CAST(payment_date AS DATE) < '2021-01-01'
    
)
SELECT 
    customer_id,
    plan_id,
    plan_name,
    payment_date,
    amount,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date ASC) AS 'payment_order'
FROM date_series
WHERE YEAR(payment_date) < 2021
AND customer_id = 16
ORDER BY customer_id ASC, plan_id ASC, payment_date ASC;

SELECT * FROM plans;



-- test query- new main

WITH RECURSIVE date_series AS(

	SELECT 
		S.start_date AS 'payment_date',
        S.customer_id,
        P.plan_id,
        P.plan_name,
        P.price AS 'amount'
    FROM subscriptions AS S
    JOIN plans AS P on P.plan_id = S.plan_id
    WHERE S.plan_id != 0
    
    UNION ALL
    
    SELECT 
		DATE_ADD(CAST(payment_date AS DATE), INTERVAL 1 MONTH),
        customer_id,
        plan_id,
        plan_name,
        amount
    FROM date_series
    WHERE DATE_ADD(CAST(payment_date AS DATE), INTERVAL 1 MONTH) < '2021-01-01'
    AND
    plan_id != 3
)
SELECT 
    customer_id,
    plan_id,
    LAG(plan_id,1) OVER (PARTITION BY customer_id ORDER BY payment_date) AS 'lag_plan_id',
    plan_name,
    payment_date,
    amount,
    LAG(amount,1) OVER (PARTITION BY customer_id ORDER BY payment_date) AS 'lag_amount',
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date ASC) AS 'payment_order',
    
    IF(plan_id > LAG(plan_id, 1) OVER (PARTITION BY customer_id ORDER BY payment_date), 
       amount - LAG(amount, 1) OVER (PARTITION BY customer_id ORDER BY payment_date), 
       amount) AS amount_2
       
FROM date_series
WHERE customer_id = 19
ORDER BY customer_id ASC, payment_date ASC;


WITH RECURSIVE date_series AS (
    -- Base case
    SELECT 
        S.start_date AS payment_date,
        S.customer_id,
        P.plan_id,
        P.plan_name,
        P.price AS amount,
        NULL AS lag_plan_id,
        NULL AS lag_amount
    FROM subscriptions AS S
    JOIN plans AS P ON P.plan_id = S.plan_id
    WHERE S.plan_id != 0

    UNION ALL
    
    -- Recursive part with plan_id check
    SELECT 
        DATE_ADD(CAST(payment_date AS DATE), INTERVAL 1 MONTH),
        customer_id,
        plan_id,
        plan_name,
        amount,
        -- Carry over previous values
        plan_id AS lag_plan_id,
        amount AS lag_amount
    FROM date_series
    WHERE DATE_ADD(CAST(payment_date AS DATE), INTERVAL 1 MONTH) < '2021-01-01'
      AND (plan_id != 3 OR lag_plan_id IS NULL)  -- Add this condition
)
SELECT 
 * FROM date_series;

CREATE VIEW sales_employees AS
SELECT employee_id, first_name, last_name, department
FROM employees
WHERE department = 'Sales';



CREATE VIEW MIDDLE_MAN AS 
SELECT 
	S.customer_id,
    S.plan_id,
	LAG(S.plan_id,1)  OVER()AS lag_plan_id,
	P.plan_name,
    S.start_date AS 'payment_date',
    P.price AS 'amount',
    LAG(P.price,1) OVER() AS lag_amount
FROM 
subscriptions AS S
JOIN plans AS P ON P.plan_id = S.plan_id
WHERE S.plan_id != 0
ORDER BY customer_id ASC, S.start_date ASC;

SELECT * FROM MIDDLE_MAN;


DROP VIEW MIDDLE_MAN;



