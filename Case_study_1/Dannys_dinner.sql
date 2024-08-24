CREATE DATABASE dannys_dinner;

USE dannys_dinner;

SELECT * FROM sales;
SELECT * FROM members;
SELECT * FROM menu;

-- 1.What is the total amount each customer spent at the restaurant?

SELECT customer_id, sum(price) as 'total_spent' FROM sales
JOIN menu ON menu.product_id = sales.product_id
GROUP BY customer_id;

-- 2.How many days has each customer visited the restaurant?

SELECT customer_id,COUNT(DISTINCT(order_date)) AS 'nr_of_visits' FROM sales
GROUP BY customer_id;


-- 3.What was the first item from the menu purchased by each customer?

-- OPTION 1 
WITH CTE AS (
	SELECT 
		S.customer_id,
		M.product_name,
		S.order_date,
		DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) as 'rnk'
	FROM sales AS S
	JOIN menu AS M ON M.product_id = S.product_id
    )
SELECT *
FROM CTE
WHERE rnk = '1';

-- OPTION 2

WITH CTE AS(
	SELECT 
		S.customer_id,
		M.product_name,
		S.order_date,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) as 'rn'
	FROM sales AS S
	JOIN menu AS M ON M.product_id = S.product_id
    )
SELECT *
FROM CTE
WHERE rn = '1'
;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
		M.product_name,
		COUNT(*) AS 'highest'
	FROM sales AS S
	JOIN menu AS M ON M.product_id = S.product_id
	GROUP BY M.product_name
    ORDER BY highest DESC
    LIMIT 1;
    
    
-- 5. Which item was the most popular for each customer?

WITH CTE AS (
	SELECT 
		S.customer_id, 
		M.product_name,
		COUNT(*) AS 'no_of_purchases',
		ROW_NUMBER() OVER(PARTITION BY S.customer_id ORDER BY COUNT(*) DESC) AS 'rn'
	FROM sales AS s 
	JOIN menu AS M on M.product_id = S.product_id
	GROUP BY S.customer_id, M.product_name
	)
SELECT * FROM CTE
WHERE rn = '1'; 


-- 6.Which item was purchased first by the customer after they became a member?

WITH CTE AS (
	SELECT 
		S.customer_id,
		S.order_date,
		M.product_name,
		T.join_date,
		ROW_NUMBER() OVER(PARTITION BY S.customer_id ORDER BY S.order_date) AS 'rn'
	FROM sales AS S
	JOIN menu AS M ON M.product_id = S.product_id
	LEFT JOIN members AS T ON T.customer_id = S.customer_id
	WHERE order_date >= join_date
	) 
SELECT customer_id, 
		product_name,
        order_date, 
        join_date
FROM CTE 
WHERE rn = '1'
; 


-- 7.Which item was purchased just before the customer became a member?

WITH CTE AS (
	SELECT 
		S.customer_id,
		S.order_date,
		M.product_name,
		T.join_date,
		ROW_NUMBER() OVER(PARTITION BY S.customer_id ORDER BY S.order_date DESC) AS 'rn'
	FROM sales AS S
	JOIN menu AS M ON M.product_id = S.product_id
	LEFT JOIN members AS T ON T.customer_id = S.customer_id
	WHERE order_date < join_date
	) 
SELECT customer_id, 
		product_name, 
        order_date, 
        join_date
FROM CTE 
WHERE rn = '1'
;

-- 8. What is the total items and amount spent for each member before they became a member?			

SELECT 
	S.customer_id,
	COUNT(M.product_name) AS 'total_item_purchased',
    SUM(M.price) AS 'total_amount_spent',
	T.join_date,
	ROW_NUMBER() OVER(PARTITION BY S.customer_id ORDER BY SUM(M.price) DESC) AS 'rn'
FROM sales AS S
JOIN menu AS M ON M.product_id = S.product_id
LEFT JOIN members AS T ON T.customer_id = S.customer_id
WHERE order_date < join_date
GROUP BY S.customer_id, T.join_date
;


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT 
	S.customer_id,
SUM(CASE
	WHEN M.product_name = 'sushi' THEN price * 20
	ELSE price * 10
END) AS points
FROM sales as S 
JOIN menu AS M ON M.product_id = S.product_id
GROUP BY S.customer_id;


-- 10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT 
	S.customer_id,
SUM(CASE
	WHEN order_date BETWEEN join_date AND ADDDATE(G.join_date, '6') THEN price * 10 * 2 
    WHEN M.product_name = 'sushi' THEN price * 10 * 2
	ELSE price * 10
END) AS 'total_points'
FROM sales as S 
JOIN menu AS M ON M.product_id = S.product_id
JOIN members AS G on G.customer_id = S.customer_id
WHERE order_date <= '2021-01-31'
GROUP BY S.customer_id
ORDER BY total_points DESC
; 


-- JOINING ALL TABLES 
-- Table shows whether the customer was a member at the time of the purchase

SELECT 
	S.customer_id, 
    S.order_date, 
    M.product_name,
    M.price,
CASE 
	WHEN  G.join_date IS NOT NULL AND order_date >= join_date THEN 'Y'
    ELSE 'N'
END AS member
FROM sales AS S
JOIN menu AS M ON M.product_id = S.product_id 
LEFT JOIN members AS G ON G.customer_id = S.customer_id 
;


-- RANKING ALL THINGS
WITH CTE AS(
	SELECT 
		S.customer_id, 
		S.order_date, 
		M.product_name,
		M.price,
	CASE 
		WHEN G.join_date IS NOT NULL AND order_date >= join_date THEN 'Y'
		ELSE 'N'
	END AS member
	FROM sales AS S
	JOIN menu AS M ON M.product_id = S.product_id 
	LEFT JOIN members AS G ON G.customer_id = S.customer_id
    ) 
SELECT 
	customer_id, 
	order_date, 
	product_name,
	price,
    member,
CASE 
	WHEN member = 'Y' THEN DENSE_RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date) 
	ELSE 'null'
END AS ranking
FROM CTE
;