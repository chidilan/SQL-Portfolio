USE Ecommerce;
SELECT * FROM ecommerce_data;

## First lets check for duplicates
SELECT row_id, COUNT(*) AS duplicates
FROM ecommerce_data
GROUP BY row_id
HAVING COUNT(*) > 1;

# Total Sales of the Store
SELECT SUM(sales) AS revenue FROM ecommerce_data;

# Total Profit of Shop
SELECT ROUND(SUM(profit), 2) AS Total_Profit FROM ecommerce_data;

# Total Quantity Sold
SELECT SUM(quantity) AS Quantity_Sold FROM ecommerce_data;


-- Was having trouble so i had to temporarily disable ONLY_FULL_GROUP_BY
SET SESSION sql_mode = (SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));

# Total Profit And Sales Per Month
SELECT MONTHNAME(order_date) AS Order_Month, SUM(Profit) AS Total_Profit, SUM(Sales) AS Total_Sales
FROM ecommerce_data
GROUP BY Order_Month
ORDER BY MONTH(order_date);

# Profit By Category
SELECT Category, ROUND(SUM(profit), 2) AS Total_Profit
FROM ecommerce_data
GROUP BY category
ORDER BY category;

#Sales Percentage
SELECT Category, SUM(Sales) AS total_sales, (SUM(Sales)/ (SELECT SUM(Sales) FROM ecommerce_data)) * 100 AS Sales_Per
FROM ecommerce_data
GROUP BY category
ORDER BY category;

# Sales From Each State
SELECT State, SUM(Sales) AS Total_Sales FROM ecommerce_data
GROUP BY State
ORDER BY State;

#Top 5 Category by Sales
SELECT 
	sub_category, 
	SUM(sales) AS total_sales
FROM ecommerce_data
GROUP BY sub_category
ORDER BY total_sales DESC
LIMIT 5;

# YOY GROWTH
#Sales
WITH salesbyyear AS (
	SELECT
		Year(order_date) AS Sales_Year,
		SUM(sales) AS Total_Sales
	FROM ecommerce_data
    GROUP BY Year(order_date)
)
SELECT 
	s1.Sales_Year AS Current_Year,
    s1.Total_sales AS Current_Year_Sales,
    s2.Total_Sales AS Previous_Year_Sales,
    ROUND(((s1.total_sales - s2.total_sales) /s2.total_sales) * 100 , 2) AS Profit_Growth
FROM salesbyyear s1
JOIN salesbyyear s2 ON
	s1.sales_year = s2.sales_year + 1
GROUP BY s1.Sales_year, s1.Total_sales
order by s1.sales_year;

#Profit
WITH profitbyyear AS (
	SELECT
		Year(order_date) AS Profit_Year,
        SUM(profit) AS Total_Profit
	FROM ecommerce_data
    GROUP BY Year(order_date)
)
SELECT
	p1.profit_year AS Current_Year,
    p1.total_profit AS Current_Year_Profit,
    p2.total_profit AS Previous_Year_Profit,
    ROUND(((p1.total_profit - p2.total_profit)/p2.total_profit) *100 , 2) AS Profit_Growth
FROM profitbyyear p1
LEFT JOIN profitbyyear p2 ON
	p1.profit_year = p2.profit_year + 1
GROUP BY p1.profit_year, p1.total_profit
ORDER BY p1.total_profit;

#ORDER
WITH orderbyyear AS (
	SELECT
		YEAR(order_date) AS Order_Year,
        COUNT(Order_ID) AS Total_Orders
	FROM ecommerce_data
    GROUP BY YEAR(order_date)
)
SELECT
	o1.Order_Year AS Current_Year,
    o1.Total_orders AS Current_Orders,
    o2.Total_orders AS Previous_Orders,
    ROUND(((o1.total_orders - o2.total_orders) / o2.total_orders) *100 ,2) AS Order_Growth
FROM orderbyyear o1
LEFT JOIN orderbyyear o2
	ON o1.order_year = o2.order_year + 1
GROUP BY o1.order_year, o1.total_orders
ORDER BY o1.order_year;

#Profit Margin
WITH MarginByYear AS (
	SELECT
		Year(Order_date) AS Margin_Year,
        ROUND((SUM(Profit)/SUM(Sales))*100, 2) AS Profit_Margin
	FROM ecommerce_data
    GROUP BY YEAR(order_date)
)
SELECT
	m1.margin_year AS Current_Year,
    m1.Profit_Margin AS Current_Profit_Margin,
    m2.Profit_Margin AS Previous_Profit_Margin,
    ROUND(((m1.Profit_Margin - M2.Profit_Margin) / m2.Profit_MArgin) * 100, 2) AS Margin_Growth
FROM marginbyyear m1
LEFT JOIN marginbyyear m2 ON 
 m1.margin_year = m2.margin_year + 1
GROUP BY m1.margin_year, m1.profit_margin
ORDER BY m1.margin_year;
