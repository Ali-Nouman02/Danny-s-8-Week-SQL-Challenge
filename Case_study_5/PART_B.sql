USE data_mart;


SHOW TABLES;

-- Part 2

-- 1. What day of the week is used for each week_date value?

SELECT 
    DISTINCT(DAYNAME(week_date)) AS 'day_of_week'
FROM clean_weekly_sales;

-- 2. What range of week numbers are missing from the dataset?

SELECT 
	DISTINCT(week_number)
FROM clean_weekly_sales
ORDER BY week_number
;
-- missing weeks are (1-11) and (37-52)


-- 3. How many total transactions were there for each year in the dataset?

SELECT DISTINCT YEAR(week_date) FROM clean_weekly_sales;

SELECT 
	YEAR(week_date) AS 'YEAR',
	SUM(transactions) AS 'count'
FROM clean_weekly_sales
GROUP BY YEAR(week_date);


-- 4. What is the total sales for each region for each month?

SELECT 
	region,
	CONCAT(SUM(sales),'$') AS 'total_sales'
FROM clean_weekly_sales
GROUP BY region;


SELECT * FROM clean_weekly_sales;

-- 5. What is the total count of transactions for each platform

SELECT
	platform,
	SUM(transactions) AS 'transaction_count'
FROM clean_weekly_sales
GROUP BY platform;


-- 6. What is the percentage of sales for Retail vs Shopify for each month?

SELECT 
    month_number,
    CONCAT(ROUND(SUM(IF(platform = 'Retail', sales, 0)) / NULLIF(SUM(sales), 0) * 100, 2), '%') AS Retail_Percentage,
    CONCAT(ROUND(SUM(IF(platform = 'Shopify', sales, 0)) / NULLIF(SUM(sales), 0) * 100, 2), '%') AS Shopify_Percentage
FROM 
    clean_weekly_sales
GROUP BY 
    month_number
ORDER BY 
    month_number;


-- 7. What is the percentage of sales by demographic for each year in the dataset?


WITH CTE AS (
	SELECT 
		YEAR(week_date) AS 'Year',
		demographic,
		SUM(sales) AS 'sales_per_group',
		SUM(SUM(sales)) OVER () AS 'total_sales'
	FROM clean_weekly_sales
	GROUP BY YEAR(week_date), demographic
)
 SELECT 
	Year,
    demographic,
	CONCAT(ROUND((sales_per_group / total_sales) * 100,2), '%') AS 'percentage'
 FROM CTE;


-- 8. Which age_band and demographic values contribute the most to Retail sales?

WITH CTE AS (
	SELECT 
		age_band,
		demographic,
		SUM(sales) AS 'sales_per_group',
		SUM(SUM(sales)) OVER () AS 'total_sales'
	FROM clean_weekly_sales
	WHERE platform = 'Retail'
	GROUP BY age_band, demographic
	ORDER BY SUM(sales) DESC
) 
SELECT 
	age_band,
    demographic,
    CONCAT(ROUND((sales_per_group / total_sales) * 100,2), '%' ) AS 'percentage_of_retail_sales'
FROM CTE
LIMIT 2
;


-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?





















