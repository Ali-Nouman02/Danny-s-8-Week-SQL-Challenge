## :technologist::woman_technologist: Case Study #4: Data Bank - Customer Transactions - WIP

## Case Study Questions

1. What is the unique count and total amount for each transaction type?
2. What is the average total historical deposit counts and amounts for all customers?
3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
4. What is the closing balance for each customer at the end of the month?
5. What is the percentage of customers who increase their closing balance by more than 5%?

***

###  1. What is the unique count and total amount for each transaction type?

```sql
SELECT 
	txn_type,
    count(*) AS 'unique_count',
    SUM(txn_amount) AS 'total_amount'
FROM customer_transactions
GROUP BY txn_type;
``` 
	
#### Result set:

![ss_question_1](https://github.com/user-attachments/assets/545f6bd5-21d3-4d05-abd9-727ee382363d)

***

###  2. What is the average total historical deposit counts and amounts for all customers?

```sql
WITH CTE AS(
	SELECT 
		customer_id,
		COUNT(txn_type) AS 'txn_count',
		SUM(txn_amount) AS 'txn_amount'
	FROM customer_transactions
	WHERE txn_type = 'deposit'
	GROUP BY customer_id
	ORDER BY customer_id
) 
SELECT 
	ROUND(AVG(txn_count),2) AS 'average_count',
    CONCAT(ROUND(AVG(txn_amount),2), '$') AS 'average_amount'
FROM CTE
;
``` 
	
#### Result set:

![ss_question_2](https://github.com/user-attachments/assets/d32dda8d-5cb6-434b-803b-a87e33b0751c)

***

###  3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

```sql
WITH CTE AS (
	SELECT
		customer_id,
		MONTH(txn_date) AS 'trx_month',
		SUM(IF(txn_type = 'deposit', 1, 0)) AS 'count_deposit',
		SUM(IF(txn_type = 'purchase',1 , 0)) AS 'count_purchase',
		SUM(IF(txn_type = 'withdrawal',1,0)) AS 'count_withdrawal'
	FROM customer_transactions
	GROUP BY customer_id, MONTH(txn_date)
	ORDER BY customer_id
)
SELECT
	trx_month,
    COUNT(DISTINCT(customer_id)) AS 'customer_count'
FROM CTE
WHERE count_deposit > 1 
AND (count_purchase = 1 OR count_withdrawal = 1)
GROUP BY trx_month;
``` 
	
#### Result set:

![ss_question_3](https://github.com/user-attachments/assets/694c13c4-3fa7-4ebc-923e-f899cb054787)


***

###  4. What is the closing balance for each customer at the end of the month?

```sql
WITH CTE AS (
SELECT 
	customer_id,
    MONTH(txn_date) AS 'txn_month',
    SUM(IF(txn_type = 'deposit', txn_amount, 0)) AS 'total_deposit',
    SUM(IF(txn_type = 'withdrawal', txn_amount, 0)) AS 'total_withdrawal',
    SUM(IF(txn_type = 'purchase', txn_amount, 0)) AS 'total_purchase'
FROM customer_transactions
GROUP BY customer_id, MONTH(txn_date)
ORDER BY customer_id
)
SELECT 
	customer_id,
    txn_month,
    CONCAT((total_deposit - (total_withdrawal + total_purchase)),'$') AS 'closing_balance'
FROM CTE;
``` 
	
#### Result set:

![ss_question_4](https://github.com/user-attachments/assets/2a522329-bd01-47db-950c-6e8af985e760)


***

###  5. What is the percentage of customers who increase their closing balance by more than 5%?
skip
```sql

``` 
	
#### Result set:

***

