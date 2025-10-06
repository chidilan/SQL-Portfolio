# Intuition
To make the query more efficient, we can use a single pass through the table to count the occurrences of each number and then select the maximum number with a count of 1.

# Approach
Our approach will be to use a SQL query with a subquery to count the occurrences of each number. We will then select the maximum number from the subquery where the count is 1. If no such number exists, the query will return null.

# Complexity
- Time complexity: $$O(n)$$
- Space complexity: $$O(n)$$ 

# Code
```sql
SELECT MAX(num) AS num
FROM (
    SELECT num
    FROM (
        SELECT num, COUNT(*) as cnt
        FROM MyNumbers
        GROUP BY num
    ) t
    WHERE cnt = 1
) AS subquery;
```
However, the most efficient way to write this query would be:
```sql
SELECT MAX(num) AS num
FROM MyNumbers
WHERE num IN (
    SELECT num
    FROM MyNumbers
    GROUP BY num
    HAVING COUNT(num) = 1
);
```
Or using window function (if supported by the database):
```sql
SELECT MAX(num) AS num
FROM (
    SELECT num, COUNT(*) OVER (PARTITION BY num) as cnt
    FROM MyNumbers
) t
WHERE cnt = 1;
```
But the most optimized query will be:
```sql
SELECT MAX(num) AS num
FROM MyNumbers
GROUP BY num
HAVING COUNT(num) = 1;
```
This query works because it only groups the numbers and counts their occurrences in one pass, then directly selects the maximum number with a count of 1. If no such number exists, the query will return null. 
