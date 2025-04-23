# This one is a continuation of a project from pandas dataframe. We use a cleaned csv file here.

CREATE DATABASE walmart_db;
USE walmart_db;

SELECT * FROM walmart_cleaned_me;

ALTER TABLE walmart_cleaned_me
RENAME TO walmart;

SELECT *
FROM walmart;


-- EDA

SELECT COUNT(*) FROM walmart;

SELECT DISTINCT payment_method
FROM walmart;

SELECT payment_method, COUNT(payment_method)
FROM walmart
GROUP BY payment_method;

SELECT COUNT(DISTINCT Branch)
FROM walmart;

SELECT MAX(quantity)
FROM walmart;

SELECT * FROM walmart;

-- Business Problems
-- 1. Analyze Payment Methods and Sales
-- ● Question: What are the different payment methods, and how many transactions and
-- items were sold with each method?
-- ● Purpose: This helps understand customer preferences for payment methods, aiding in
-- payment optimization strategies.

SELECT  payment_method, 
		COUNT(*) AS num_transactions,
        SUM(quantity) AS qty_sold
FROM walmart
GROUP BY payment_method;



# 2. Identify the Highest-Rated Category in Each Branch
-- ● Question: Which category received the highest average rating in each branch?
-- ● Purpose: This allows Walmart to recognize and promote popular categories in specific
-- branches, enhancing customer satisfaction and branch-specific marketing.

SELECT * FROM walmart;

SELECT *
FROM
(
	SELECT  Branch, category, AVG(rating) AS avg_rating,
			RANK() OVER(PARTITION BY Branch ORDER BY AVG(rating) DESC) AS `rank`
	FROM walmart
	GROUP BY Branch, category
) AS ranked_table
WHERE `rank` = 1;



# 3. Determine the Busiest Day for Each Branch
-- ● Question: What is the busiest day of the week for each branch based on transaction
-- volume?
-- ● Purpose: This insight helps in optimizing staffing and inventory management to
-- accommodate peak days

SELECT * FROM walmart;

SELECT `date`,
		STR_TO_DATE(`date`, '%d/%m/%Y') AS formated_date
FROM walmart;

SELECT *
FROM
(
SELECT 	Branch,
		DAYNAME(STR_TO_DATE(`date`, '%d/%m/%Y')) AS day_of_week,
        COUNT(*) AS transactions,
        RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) AS day_rank
FROM walmart
GROUP BY Branch, day_of_week
) AS Busiest_day
WHERE day_rank = 1;



# 4. Calculate Total Quantity Sold by Payment Method
-- ● Question: How many items were sold through each payment method?
-- ● Purpose: This helps Walmart track sales volume by payment type, providing insights
-- into customer purchasing habits.

SELECT * FROM walmart;

SELECT payment_method, SUM(quantity) AS total_quantity
FROM walmart
GROUP BY payment_method;



# 5. Analyze Category Ratings by City
-- ● Question: What are the average, minimum, and maximum ratings for each category in
-- each city?
-- ● Purpose: This data can guide city-level promotions, allowing Walmart to address
-- regional preferences and improve customer experiences.

SELECT * FROM walmart;

SELECT  City, category,
		AVG(rating) AS avg_rating, MIN(rating) AS min_rating, MAX(rating) 
FROM walmart
GROUP BY City, category
ORDER BY 1, 2;



# 6. Calculate Total Profit by Category
-- ● Question: What is the total profit for each category, ranked from highest to lowest?
-- ● Purpose: Identifying high-profit categories helps focus efforts on expanding these
-- products or managing pricing strategies effectively.

SELECT * FROM walmart;

SELECT  category, SUM(total_price) AS revenue,
		SUM(total_price * profit_margin) AS profit_per_category
FROM walmart
GROUP BY category
ORDER BY 2 DESC;



# 7. Determine the Most Common Payment Method per Branch
-- ● Question: What is the most frequently used payment method in each branch?
-- ● Purpose: This information aids in understanding branch-specific payment preferences,
-- potentially allowing branches to streamline their payment processing systems.

SELECT * FROM walmart;

WITH rank_payment 
AS
(
SELECT Branch, payment_method, COUNT(payment_method),
		RANK() OVER(PARTITION BY Branch ORDER BY COUNT(payment_method) DESC) AS `rank`
FROM walmart
GROUP BY Branch, payment_method
)
SELECT *
FROM rank_payment
WHERE `rank` = 1;



# 8. Analyze Sales Shifts Throughout the Day
-- ● Question: How many transactions occur in each shift (Morning, Afternoon, Evening)
-- across branches?
-- ● Purpose: This insight helps in managing staff shifts and stock replenishment schedules,
-- especially during high-sales periods.

SELECT * FROM walmart;

SELECT  Branch,
		CASE
			WHEN TIME(STR_TO_DATE(`time`, '%H:%i:%s')) BETWEEN '06:00;00' AND '11:59:59' THEN 'morning'
            WHEN TIME(STR_TO_DATE(`time`, '%H:%i:%s')) BETWEEN '12:00:00' AND '17:59:59' THEN 'afternoon'
            ELSE 'evening'
		END AS shift,
        COUNT(*) AS transactions
FROM walmart	
GROUP BY Branch, shift
ORDER BY 1, 3 DESC;



# 9. Identify 5 Branches with Highest Revenue Decline Year-Over-Year
-- ● Question: Which branches experienced the largest decrease in revenue compared to
-- the previous year?
-- ● Purpose: Detecting branches with declining revenue is crucial for understanding
-- possible local issues and creating strategies to boost sales or mitigate losses
-- Here current year is 2023 and past year is 2022
-- Revenue decrease ratio formula -> rdr = ((last_rev - cur_rev) / lst_rev) * 100

SELECT * FROM walmart;

SELECT *
FROM
(
SELECT  Branch, SUM(total_price) AS revenue, 
		YEAR(STR_TO_DATE(`date`, '%d/%m/%y')) AS ext_year
FROM walmart
GROUP BY Branch, ext_year
HAVING ext_year = 2022 OR ext_year = 2023
ORDER BY 1,3
) AS rdr;

WITH revenue_2022
AS
(
	SELECT Branch, SUM(total_price) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(`date`, '%d/%m/%y')) = 2022
    GROUP BY 1
    ORDER BY 1
),
revenue_2023
AS
(
	SELECT Branch, SUM(total_price) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(`date`, '%d/%m/%y')) = 2023
    GROUP BY 1
    ORDER BY 1
)
SELECT 	ls.Branch,
		ls.revenue AS lst_yr_revenue,
        cs.revenue AS cur_yr_revenue,
		ROUND((ls.revenue - cs.revenue) / ls.revenue * 100, 2) AS rev_dec_ratio
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs
ON ls.Branch = cs.Branch		
WHERE ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5;


























