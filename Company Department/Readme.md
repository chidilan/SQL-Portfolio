# **15 Key Questions with SQL Queries & Explanations**  

### **1. What is the average salary per department?** 
**Query:**  
```sql
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
```  
**Explanation:**  
- Removes `$` from salary strings and converts to numeric.  
- Calculates average salary per department.  

**Insight:** HR has the highest average salary ($5,547), while Sales has the lowest ($2,853).  

---

### **2. Which employees earn below their department’s average?**  
**Query:**  
```sql
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
```  
**Explanation:**  
- Compares each employee’s salary against their department’s average.  
- Identifies at-risk employees who may leave due to low pay.  

**Insight:** 60% of Sales employees earn below their department’s average.  

---

### **3. How many employees were onboarded in the last 6 months?**  
**Query:**  
```sql
SELECT
    'HR' AS department,
    COUNT(*) AS recent_hires
FROM hr_department
WHERE Onboard_Date >= CURRENT_DATE - INTERVAL 2 year
UNION ALL
SELECT
    'Marketing',
    COUNT(*)
FROM marketing_department
WHERE Onboard_Date >= CURRENT_DATE - INTERVAL 2 year
UNION ALL
SELECT
    'Sales',
    COUNT(*)
FROM sales_department
WHERE Onboard_Date >= CURRENT_DATE - INTERVAL 2 year ;
```  
**Explanation:**  
- Filters employees hired in the last 6 months.  
- Helps track recent hiring trends.  

**Insight:** HR has the most recent hires 94, suggesting rapid expansion over the years.  

---

### **4. Which client companies pay the highest salaries?**  
**Query:**  
```sql
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
```  
**Explanation:**  
- Aggregates salaries across all departments.  
- Ranks clients by average salary.  

**Insight:** **"Magna LLP"** (HR) pays the highest ($9,982).  

---

### **5. What is the salary distribution by tenure?**  
**Query:**  
```sql
SELECT
	department,
	CASE WHEN Onboard_Date >= CURRENT_DATE - INTERVAL 1 year THEN '≤ 1 Year'
		 WHEN Onboard_Date >= CURRENT_DATE - INTERVAL 3 year THEN'≤ 3 Years'
         ELSE '3 Years+' END AS Tenure_Group,
    AVG(CAST(REPLACE(REPLACE(salary, '$', ''), ',', '') AS DECIMAL (10,2))) AS Avg_Salary
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
```  
**Explanation:**  
- Groups employees by tenure.  
- Shows if longer-tenured employees earn more.  

**Insight:** Employees with seems to earn the same over the years as 

---

### **6. Who are the top 5 highest-paid employees?**  
**Query:**  
```sql
SELECT Name, Salary, 'Sales' AS dept FROM Sales_Department
UNION ALL
SELECT Name, Salary, 'Marketing' FROM Marketing_Department
UNION ALL
SELECT Name, Salary, 'HR' FROM HR_Department
ORDER BY REPLACE(Salary, '$', '')::NUMERIC DESC
LIMIT 5;
```  
**Insight:** **Jacqueline Yates (HR)** is the highest-paid ($9,645).  

---

### **7. Which department has the highest salary variance?**  
**Query:**  
```sql
SELECT 
    'Sales' AS dept,
    VARIANCE(REPLACE(Salary, '$', '')::NUMERIC) AS salary_variance
FROM Sales_Department
UNION ALL
SELECT 'Marketing', VARIANCE(REPLACE(Salary, '$', '')::NUMERIC)
FROM Marketing_Department
UNION ALL
SELECT 'HR', VARIANCE(REPLACE(Salary, '$', '')::NUMERIC)
FROM HR_Department;
```  
**Insight:** **HR has the highest variance**, indicating wide pay disparities.  

---

### **8. How many employees earn less than $3,000?**  
**Query:**  
```sql
SELECT 
    COUNT(*) FILTER (WHERE REPLACE(Salary, '$', '')::NUMERIC < 3000) AS low_paid_employees,
    'Sales' AS dept
FROM Sales_Department
UNION ALL
SELECT COUNT(*), 'Marketing'
FROM Marketing_Department
WHERE REPLACE(Salary, '$', '')::NUMERIC < 3000
UNION ALL
SELECT COUNT(*), 'HR'
FROM HR_Department
WHERE REPLACE(Salary, '$', '')::NUMERIC < 3000;
```  
**Insight:** **Sales has the most low-paid employees (9).**  

--- 

---

### **9. Which employees should be prioritized for raises?**  
**Query:**  
```sql
SELECT 
    Name,
    Salary,
    'Sales' AS dept
FROM Sales_Department
WHERE 
    REPLACE(Salary, '$', '')::NUMERIC < (SELECT AVG(REPLACE(Salary, '$', '')::NUMERIC) FROM Sales_Department)
    AND Onboard_Date <= CURRENT_DATE - INTERVAL '1 year'
ORDER BY Salary ASC;
```  
**Explanation:**  
- Identifies **long-tenured, underpaid employees**.  
- Helps prioritize retention efforts.  

**Insight:** **Reed Cline (Sales, $2,719)** is a top candidate for a raise.  

---

## **Final Recommendations**  
✅ **Adjust Sales salaries** to match HR benchmarks.  
✅ **Retention bonuses** for employees with 1-3 years tenure.  
✅ **Review client contracts** impacting compensation fairness.  
✅ **Monitor Marketing turnover** due to rapid hiring.  
