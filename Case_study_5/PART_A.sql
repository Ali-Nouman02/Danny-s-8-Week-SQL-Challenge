USE data_mart;


SHOW TABLES;


CREATE TABLE clean_weekly_sales AS
SELECT 
	STR_TO_DATE(week_date, '%d/%c/%y')  AS week_date,
    WEEK(week_date) AS week_number,
    MONTH(week_date) AS month_number,
	CONCAT(20, RIGHT(week_date,2)) AS calendar_year,
    CASE 
		WHEN segment = 'null' THEN 'unknown'
        ELSE segment
	END AS segment,
    CASE 
		WHEN RIGHT(segment,1) = '1' THEN 'Young Adults'
        WHEN RIGHT(segment,1) = '2' THEN 'Middle Aged'
        WHEN RIGHT(segment,1) IN ('3','4') THEN 'Retirees'
        WHEN segment = 'null' OR segment IS NULL THEN 'unknown'
        ELSE 'unknown'
	END AS age_band,
     CASE 
		WHEN LEFT(segment,1)= 'C' THEN 'Couples'
        WHEN LEFT(segment,1)= 'F' THEN 'Families'
        WHEN segment = 'null' THEN 'unknown'
	END AS demographic,
    CONCAT(ROUND(sales/transactions,2), '$') AS 'avg_transactions',
    transactions, 
    CONCAT(sales, '$') AS sales,
    region,
    platform
FROM weekly_sales;


SELECT * FROM clean_weekly_sales;
SELECT * FROM weekly_sales;
DROP TABLE clean_weekly_sales;

SELECT
	STR_TO_DATE(week_date, '%d/%c/%y') AS converted_date,
    WEEK(week_date),
    MONTH(week_date),
    CONCAT(20, RIGHT(week_date,2)) AS some,
    segment,
    CASE 
		WHEN segment = 'null' THEN 'unknown'
        ELSE segment
	END AS segment_1,
    CASE 
		WHEN RIGHT(segment,1) = 1 THEN 'Young Adults'
        WHEN RIGHT(segment,1) = 2 THEN 'Middle Aged'
        WHEN RIGHT(segment,1) = 3 OR RIGHT(segment,1) = 4 THEN 'Retirees'
        WHEN segment = 'null' THEN 'unknown'
	END AS age_band,
    CASE 
		WHEN LEFT(segment,1)= 'C' THEN 'Couples'
        WHEN LEFT(segment,1)= 'F' THEN 'Families'
        WHEN segment = 'null' THEN 'unknown'
	END AS demograhic,
    CONCAT(ROUND(sales/transactions,2), '$') AS 'avg_transactions'
FROM weekly_sales;

