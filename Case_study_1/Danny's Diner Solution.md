# :ramen: :curry: :sushi: Case Study #1: Danny's Diner

## Case Study Questions

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
10. What is the total items and amount spent for each member before they became a member?
11. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
12. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
***

###  1. What is the total amount each customer spent at the restaurant?

```sql
SELECT customer_id, sum(price) as 'total_spent' FROM sales
JOIN menu ON menu.product_id = sales.product_id
GROUP BY customer_id;
``` 
	
#### Result set:

![ss_question_1](https://github.com/user-attachments/assets/47d4d754-6e5b-4874-9b0a-07ced062873f)

***

###  2. How many days has each customer visited the restaurant?

```sql
SELECT customer_id,COUNT(DISTINCT(order_date)) AS 'nr_of_visits' FROM sales
GROUP BY customer_id;
``` 
	
#### Result set:

![ss_question_2](https://github.com/user-attachments/assets/cb6c9afe-5372-4393-8fe3-5cdc0c14e401)

***

###  3. What was the first item from the menu purchased by each customer?

```sql
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
``` 
#### Result set:

![ss_question_3_option_1](https://github.com/user-attachments/assets/e03ddee6-c472-4fa2-8887-919d8359881f)


```sql
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
``` 
	
#### Result set:

![ss_question_3_option_2](https://github.com/user-attachments/assets/1dfb177b-e25d-424d-a0a6-1030f7718f97)

***

###  4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql
SELECT 
	M.product_name,
	COUNT(*) AS 'highest'
FROM sales AS S
JOIN menu AS M ON M.product_id = S.product_id
GROUP BY M.product_name
ORDER BY highest DESC
LIMIT 1;
``` 
	
#### Result set:

![ss_question_4](https://github.com/user-attachments/assets/9f730e1f-f4da-4f57-b274-37feefb5d14a)

***

###  5. Which item was the most popular for each customer?

```sql
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
``` 
	
#### Result set:

![ss_question_5](https://github.com/user-attachments/assets/98287083-b3c0-47c9-aef2-5a2cb36793b4)

***

###  6. Which item was purchased first by the customer after they became a member?

```sql
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
``` 
	
#### Result set:

![ss_question_6](https://github.com/user-attachments/assets/82109659-39ba-41fc-8e56-47d44501dd4a)

***

###  7. Which item was purchased just before the customer became a member?

```sql
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
``` 
	
#### Result set:

![ss_question_7](https://github.com/user-attachments/assets/7d7f1134-3431-4ede-9acc-3b2a5daa5c82)

***

###  8. What is the total items and amount spent for each member before they became a member?

```sql
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

``` 
	
#### Result set:

![ss_question_8](https://github.com/user-attachments/assets/540847c0-ab46-4814-8bd4-23d4212bddfb)

***

###  9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


```sql
SELECT 
	S.customer_id,
SUM(CASE
	WHEN M.product_name = 'sushi' THEN price * 20
	ELSE price * 10
END) AS points
FROM sales as S 
JOIN menu AS M ON M.product_id = S.product_id
GROUP BY S.customer_id;
``` 
	
#### Result set:

![ss_question_9](https://github.com/user-attachments/assets/e348a3db-f49f-4bd6-930b-10c49c49f586)

***

###  10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January


```sql
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
``` 


#### Result set:

![ss_question_10](https://github.com/user-attachments/assets/14f91192-da0e-42f9-8fa8-99f5a42b9fd1)

***

###  Bonus Questions

#### Join All The Things
Create basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL. Fill Member column as 'N' if the purchase was made before becoming a member and 'Y' if the after is amde after joining the membership.

```sql
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
``` 
	
#### Result set:

![joining_all_things](https://github.com/user-attachments/assets/99e48b65-a95e-4fb4-828b-95f4fd891a93)

***

#### Rank All The Things
Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

```sql
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
```

#### Result set:

![ranking_all_things](https://github.com/user-attachments/assets/6c3feae1-8e81-42e3-8312-60d9ccc9586c)


***


Click [here]([https://github.com/manaswikamila05/8-Week-SQL-Challenge](https://github.com/Ali-Nouman02/Danny-s-8-Week-SQL-Challenge)) to move back to the 8-Week-SQL-Challenge repository!


