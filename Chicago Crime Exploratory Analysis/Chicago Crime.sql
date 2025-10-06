
SELECT count(crime_id) AS "total reported crimes"
FROM crimes;

SELECT 
    crime_type,
    count(*) AS n_crimes
FROM crimes
WHERE crime_type IN ('homicide', 'battery', 'assault')
GROUP BY crime_type
ORDER BY n_crimes DESC;

SELECT 
    community_name AS community,
    population,
    density,
    count(*) AS reported_crimes
FROM chicago_crimes
GROUP BY community_name, population, density
ORDER BY reported_crimes DESC
LIMIT 10;


SELECT
    to_char(CRIME_DATE::timestamp, 'Month') AS month,
    COUNT(*) AS n_crimes
FROM chicago_crimes
GROUP BY month
ORDER BY n_crimes DESC;


SELECT
    to_char(CRIME_DATE, 'Month') AS month,
    COUNT(*) AS n_homicides,
    ROUND(AVG(temp_high), 1) AS avg_high_temp
FROM chicago_crimes
WHERE crime_type = 'homicide'
GROUP BY month
ORDER BY n_homicides DESC;

SELECT
    street_name,
    count(*) AS n_crimes
FROM chicago_crimes
GROUP BY street_name
ORDER BY count(*) DESC
LIMIT 5;

SELECT
    ROUND(100 * COUNT(*) FILTER (WHERE domestic = true) / COUNT(*)::numeric, 2) 
    AS domestic_percentage
FROM chicago_crimes;

-- Hottest day (95°F)
SELECT COUNT(*) FROM chicago_crimes WHERE temp_high = 95; 
-- Coldest day (4°F)
SELECT COUNT(*) FROM chicago_crimes WHERE temp_high = 4;