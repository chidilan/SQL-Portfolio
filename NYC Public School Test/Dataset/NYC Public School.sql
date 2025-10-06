ALTER TABLE public_school
ADD total_sat INT GENERATED ALWAYS AS (average_math + average_writing + average_reading) STORED;

###################################
-- 1. Data Completeness & Coverage
###################################
-- How many schools are missing data on the percentage of students tested?
SELECT
	COUNT(*) AS missing_data
FROM public_school
WHERE percent_tested = '';

-- Are there schools that share the same building codes?
SELECT COUNT(DISTINCT building_code) AS unique_buildings
FROM public_school;

###################################
-- 2. Top Performing Schools
###################################
-- Which schools have the highest SAT scores in math, reading, and writing?
SELECT school_name, average_math, average_writing
FROM public_school
ORDER BY average_math DESC, average_writing DESC
LIMIT 10;

-- How many schools achieve a math score of 640 or higher?
SELECT COUNT(*) AS top_math_schools
FROM public_school
WHERE average_math >= 640;

-- What is the lowest score recorded for reading, math, or writing?
SELECT 
	MIN(average_reading) AS lowest_reading,
    MIN(average_math) AS lowest_math,
    MIN(average_writing) AS lowest_writing
FROM public_school;

###################################
-- 3. Overall SAT Performance
###################################

-- Which schools have the highest total SAT scores?
SELECT school_name, total_sat
FROM public_school
ORDER BY total_sat DESC
LIMIT 10;

###################################
-- 4. Borough-Level Comparison
###################################
-- How does average SAT performance vary by borough?
SELECT borough, ROUND(AVG(total_sat), 0) AS avg_total_sat
FROM public_school
GROUP BY borough
ORDER BY avg_total_sat DESC;

###################################
-- 5. Brooklyn-Specific Analysis
###################################

-- Among Brooklyn schools, which ones perform best in math?
SELECT borough, COUNT(*) AS num_schools
FROM public_school
GROUP BY borough
ORDER BY num_schools DESC;

-- How does Brooklyn compare to other boroughs in terms of the number of schools and top performers?
SELECT school_name, average_math, borough
FROM public_school
WHERE TRIM(LOWER(borough)) = 'Brooklyn'
ORDER BY average_math DESC
LIMIT 5;

#####################################
-- 6. Observations on Equity & Access
#####################################
-- Are there disparities in academic performance across NYC schools?
SELECT
	borough, 
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM public_school), 2) AS percent_high_scores, 
    total_sat
FROM public_school
WHERE total_sat > 2000
GROUP BY borough, average_math, average_reading, average_writing;

-- Is there a concentration of high-performing schools in specific areas?
SELECT school_name, borough, total_sat
FROM public_school
WHERE TRIM(LOWER(borough)) IN ('Manhattan', 'Staten Island')
ORDER BY total_sat DESC
LIMIT 10;