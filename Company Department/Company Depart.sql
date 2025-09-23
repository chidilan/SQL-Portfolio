USE `Company Department`;
SET SESSION group_concat_max_len = 1000000;

-- 1. What is the average salary per department?
SELECT
	'HR' AS department,
	AVG(CAST(REPLACE(REPLACE(salary, '$', ''), ',', '') AS DECIMAL(10, 2))) AS avg_salary
FROM hr_department
UNION ALL 
SELECT
	'marketing',
	AVG(CAST(REPLACE(REPLACE(salary, '$', ''), ',', '') AS DECIMAL(10,2)))
FROM marketing_department
UNION ALL
SELECT
	'sales',
	AVG(CAST(REPLACE(REPLACE(salary, '$', ''), ',', '') AS DECIMAL (10,2)))
FROM sales_department;



-- 2. Which employees earn below their department’s average?
WITH dept_avg AS (
    SELECT 
        'Sales' AS dept,
        AVG(CAST(REPLACE(REPLACE(Salary, '$', ''), ',', '') AS DECIMAL(10,2))) AS avg_sal
    FROM Sales_Department
    UNION ALL
    SELECT 
        'Marketing',
        AVG(CAST(REPLACE(REPLACE(Salary, '$', ''), ',', '') AS DECIMAL(10,2)))
    FROM Marketing_Department
    UNION ALL
    SELECT 
        'HR',
        AVG(CAST(REPLACE(REPLACE(Salary, '$', ''), ',', '') AS DECIMAL(10,2)))
    FROM HR_Department
)
SELECT 
    e.name,
    e.salary,
    d.dept,
    d.avg_sal,
    CASE 
        WHEN CAST(REPLACE(REPLACE(e.salary, '$', ''), ',', '') AS DECIMAL(10,2)) < d.avg_sal 
        THEN 'Below Avg' 
        ELSE 'Above Avg' 
    END AS salary_status
FROM (
    SELECT name, salary, 'Sales' AS dept FROM Sales_Department
    UNION ALL
    SELECT name, salary, 'Marketing' FROM Marketing_Department
    UNION ALL
    SELECT name, salary, 'HR' FROM HR_Department
) e
JOIN dept_avg d ON e.dept = d.dept;



-- 3. How many employees were onboarded in the last 6 months?
SELECT
    'HR' AS department,
    COUNT(*) AS recent_hires
FROM hr_department
WHERE Onboard_Date >= CURRENT_DATE - INTERVAL 6 MONTH
UNION ALL
SELECT
    'Marketing',
    COUNT(*)
FROM marketing_department
WHERE Onboard_Date >= CURRENT_DATE - INTERVAL 6 MONTH
UNION ALL
SELECT
    'Sales',
    COUNT(*)
FROM sales_department
WHERE Onboard_Date >= CURRENT_DATE - INTERVAL 6 MONTH;

-- 4. Which client companies pay the highest salaries?
SELECT
	`Client Company`,
    AVG(CAST(REPLACE(REPLACE(salary, '$', ''), ',', '') AS DECIMAL (10,2))) AS avg_salary
FROM (
	SELECT CAST(REPLACE(REPLACE(salary, '$', ''),',', '')AS DECIMAL (10,2)) AS salary, `Client Company` FROM hr_department
    UNION ALL
    SELECT CAST(REPLACE(REPLACE(salary, '$', ''), ',', '')AS DECIMAL (10,2)), `Client Company` FROM marketing_department
    UNION ALL
    SELECT CAST(REPLACE(REPLACE(salary, '$', ''), ',', '')AS DECIMAL (10,2)), `Client Company` FROM sales_department
) t
GROUP BY `Client Company`
ORDER BY avg_salary DESC
LIMIT 5;

-- 5. What is the salary distribution by tenure?
SELECT
	department,
	CASE WHEN Onboard_Date >= CURRENT_DATE - INTERVAL 1 year THEN '≤ 1 Year'
		 WHEN Onboard_Date >= CURRENT_DATE - INTERVAL 3 year THEN'≤ 3 Years'
         ELSE '3 Years+' END AS Tenure_Group,
    AVG(CAST(REPLACE(salary, '$', '') AS DECIMAL (10,2))) AS Avg_Salary
FROM (
	SELECT 
		'HR' AS Department,
		Onboard_Date, 
        Salary 
	FROM hr_department
    UNION ALL
    SELECT
		'Marketing',
        Onboard_Date,
        Salary
	FROM marketing_department
    UNION ALL
    SELECT
		'Sales',
        Onboard_Date,
        Salary
	FROM sales_department
) t
GROUP BY department, Tenure_Group;

-- 6. Who are the top 5 highest-paid employees?
SELECT
	Name,
	'HR' AS department,
	Salary 
FROM hr_department
UNION ALL
SELECT 
	Name,
	'Marketing',
	Salary 
FROM marketing_department
UNION ALL
SELECT 
	Name,
	'Sales',
	salary 
FROM sales_department
ORDER BY Salary DESC
LIMIT 5;

-- 7. Which department has the highest salary variance?
SELECT
    department,
    VARIANCE(CAST(REPLACE(REPLACE(salary, '$', ''),',','') AS DECIMAL(10,2))) AS salary_variance
FROM (
    SELECT 
		'HR' AS department, 
        CAST(REPLACE(REPLACE(salary, '$', ''), ',', '') AS DECIMAL(10, 2)) AS salary
	FROM hr_department
    UNION ALL
    SELECT 
		'Marketing', 
        CAST(REPLACE(REPLACE(salary, '$', ''), ',', '') AS DECIMAL (10,2)) 
	FROM marketing_department
    UNION ALL
    SELECT 
		'Sales', 
        CAST(REPLACE(REPLACE(salary, '$', ''), ',', '') AS DECIMAL(10,2)) 
	FROM sales_department
) t
GROUP BY department
ORDER BY salary_variance DESC;

-- How many employees earn less than $3,000?
SELECT
	department,
	COUNT(*) AS num_employees
FROM (
	SELECT 
		'HR' AS department, 
        CAST(REPLACE(REPLACE(salary, '$', ''), ',', '') AS DECIMAL (10,2)) AS Salary 
	FROM hr_department
    UNION ALL
    SELECT 
		'Marketing', 
        CAST(REPLACE(REPLACE(salary, '$', ''), ',', '') AS DECIMAL (10,2))
	FROM marketing_department
    UNION ALL 
    SELECT 
		'Sales', 
        CAST(REPLACE(REPLACE(salary, '$', ''), ',', '') AS DECIMAL (10,2))
	FROM sales_department
)t
WHERE Salary < 3000
GROUP BY department;

-- What is the median salary per department?
SELECT
	department,
	CAST(
		SUBSTRING_INDEX(
			SUBSTRING_INDEX(
				GROUP_CONCAT(
					CAST(REPLACE(REPLACE(salary, '$', ''), ',', '')AS DECIMAL(10,2))
					ORDER BY CAST(REPLACE(REPLACE(salary, '$', ''),',','') AS DECIMAL (10,2))
				),
				',', CEIL(COUNT(*)/2)
			),
		',', -1) AS DECIMAL(10,2)
	) AS median_salary
FROM (
	SELECT
		'HR' AS department, 
        salary
	FROM hr_department
    UNION ALL
    SELECT
		'Marketing',
        salary
	FROM marketing_department
    UNION ALL
    SELECT
		'Sales',
        salary
	FROM sales_department
) t
GROUP BY department;


-- Which employees should be prioritized for raises?
SELECT
	t.department, 
    t.name,
    t.salary, 
    d.avg_salary, 
    CASE 
		WHEN OnBoard_Date > CURRENT_DATE - INTERVAL 1 YEAR THEN '< 1 year'
        WHEN OnBoard_Date > CURRENT_DATE - INTERVAL 3 YEAR THEN '1-3 years'
        ELSE '3 years+' 
    END AS tenure_group
FROM (
	SELECT 'HR' AS department, name, salary, OnBoard_Date FROM hr_department
    UNION ALL
    SELECT 'Marketing', name, salary, Onboard_Date FROM marketing_department
    UNION ALL
    SELECT 'Sales', name, salary, OnBoard_Date FROM sales_department
) t
JOIN (
	SELECT 
		department, 
        AVG(CAST(REPLACE(salary, '$', '') AS DECIMAL(10,2))) AS avg_salary
	FROM (
		SELECT 'HR' AS department, CAST(REPLACE(salary, '$', '') AS DECIMAL(10,2)) AS salary FROM hr_department
        UNION ALL
        SELECT 'Marketing', CAST(REPLACE(salary, '$', '') AS DECIMAL(10,2)) FROM marketing_department
        UNION ALL
        SELECT 'Sales', CAST(REPLACE(salary, '$', '') AS DECIMAL(10,2)) FROM sales_department
    ) dept
    GROUP BY department
) d
ON t.department = d.department
WHERE CAST(REPLACE(t.salary, '$', '') AS DECIMAL(10,2)) < d.avg_salary
ORDER BY tenure_group, salary ASC;

    
    
    
    
    
    
    
    
    
    