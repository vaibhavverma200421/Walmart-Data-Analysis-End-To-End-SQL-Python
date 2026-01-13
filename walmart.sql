
-- The walmart table :
SELECT * FROM walmart;


-- Total transactions 
select count(*) from walmart;




-- There is a small Flaw  in two columns which is City and Branch 
-- because these columns contain capital letters 
-- so for this i have to first go back to jupyter notebook and then rename the columns there 
-- cause i cannot change them here due to obvious reasons.
--  let's drop this table 
--  drop table walmart;


-- Number of branches 
select count(distinct branch) from walmart ;


-- Creating a new column total_sales

-- ALTER TABLE walmart
-- ADD COLUMN total_sales numeric;

-- UPDATE walmart
-- SET total_sales = unit_price * quantity;



                                          -- BUISNESS PROBLEMS 
										  

-- Q1. Find different methods of payments with number of trasnactions and number of quantity sold.

select  payment_method ,count(*) as number_of_transactions, sum(quantity) as total_quantity_sold from walmart
group by payment_method;


-- Q2. Identify the highest reated category in each branch, displaying the branch, category and AVG rating.

-- The goal of the query (VERY important)
-- “Identify the highest-rated category in EACH branch”
-- RANK() is applied per branch and wrapped in a subquery to allow filtering on rank = 1

select * from
(
select  
   branch, 
   category , 
   avg(rating) as average_rating, rank() over(partition by branch order by AVG(rating) desc ) as rank  from walmart
group by 1,2
)
where rank  = 1;

-- Now this will show only only 1 highest  rank of a specific product from one branch.



-- Q3. Identfiy the buisest day for each branch based on the number of transactions.

/* our date column is not in proper data type so let's deal with it so like it was in text datatype 
 so i first converted it into date like in proper format and then i like extracted the day from it */

SELECT 
    branch,
	TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'day') as day_names, count(*) as number_of_tranactions
FROM  walmart
GROUP BY 1,2
ORDER BY 1,3 desc;


-- Q4. Calculate the total quantity of  items sold per paymeny method and list payment method and toatl_quantity.

SELECT * FROM walmart;

SELECT  payment_method, 
        COUNT(*) AS number_of_transactions,
        SUM(quantity) AS total_quantity
FROM walmart
GROUP BY payment_method;


-- Q5. Determine average, minimum and maximum rating of products for each city and list the city,
--     average rating, minimum rating and maximum rating.


SELECT city,
       category,
       AVG(rating) AS average_product_rating,
	   MIN(rating) AS minimum_product_rating,
	   MAX(rating) AS maximum_product_rating
FROM walmart
GROUP BY 1,2;


-- Q6. Calculate the total profit for each category by considering total profit as 
--     (unit_price * quantity * profit_margin) and list category and toatl_profit ordered from the highest profit to lowest.


SELECT category,
       ROUND(SUM(total_Sales)) AS  total_revenue,                -- Used  ROUND  for removing decimals from the output.
	   ROUND(SUM(total_sales * profit_margin)) AS profit 
FROM walmart
GROUP BY 1
ORDER BY 3;


-- Q7. Determine the most common type of payment method for each branch and display branch and the preferred payment method.


WITH cte 
AS
(SELECT 
       branch,
	   payment_method,
	   COUNT(*) AS total_transactions,
	   RANK() OVER(PARTITION BY branch ORDER BY COUNT(*)) AS rank
FROM walmart
GROUP BY 1,2)

SELECT * FROM cte
WHERE rank = 1;      -- this is going to just show only one branch with most comman payment_method


-- Q8. Categorize sales into 3 groups morning, evening and afternoon and also find out which of the shift and number of invoices.


SELECT 
  branch,
     CASE 
	      WHEN EXTRACT(HOUR  FROM(time::time)) < 12 THEN 'morning'
	      WHEN EXTRACT(HOUR  FROM(time::time)) BETWEEN   12 AND 16 THEN 'afternoon'
	      ELSE  'evening'
     END day_time,
	      COUNT(*) AS number_of_transactions
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC;



-- Q9. Identify 5 branch with highest decrease ratio revenue compare to last year ( current year 2023 and last year 2022).
	 
                                          -- FROMULA 
         --  revenue decrease ratio = last_year_revenue - current_year_revenue/last_year_revenue * 100




-- converting date column into date (earlier it was in text)
SELECT 
*,
      TO_DATE(date, 'DD/MM/YY') AS formatted_date
FROM walmart;	


-- now extracting years from the date column
SELECT 
*, 
   EXTRACT (YEAR FROM TO_DATE(date, 'DD/MM/YY')) AS years
FROM walmart;


-- 2022 sales 
WITH revenue_2022                      -- Use of CTEs and name of CTE = revenue_2022
AS
(
SELECT 
       branch,
	   SUM(total_sales) AS revenue_2022
FROM walmart
WHERE  EXTRACT (YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
GROUP BY branch
),

revenue_2023
AS
(
 SELECT 
       branch,
	   SUM(total_sales) AS revenue_2023
FROM walmart
WHERE  EXTRACT (YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
GROUP BY branch
)

SELECT 
       last_Sales.branch,
	   last_sales.revenue_2022 AS last_year_revenue,
	   current_sales.revenue_2023 AS current_year_revenue,
	   ROUND(
	        (last_sales.revenue_2022 - current_sales.revenue_2023)::numeric 
	        / last_sales.revenue_2022 * 100, 2) AS revenue_decreasing_ratio 
FROM revenue_2022 AS last_sales
JOIN
revenue_2023 AS current_Sales 
ON last_sales.branch  =  current_Sales.branch
WHERE revenue_2022 > revenue_2023
ORDER BY 4 DESC
LIMIT 5;     
	   
	  


	  















     