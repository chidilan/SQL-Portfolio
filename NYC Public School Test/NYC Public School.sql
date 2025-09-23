###################################
-- 1. Data Completeness & Coverage
###################################
-- How complete is the SAT data across NYC public high schools?
-- How many schools are missing data on the percentage of students tested?
SELECT
	COUNT(*) AS missing_data
FROM public_school
WHERE percent_tested IS NULL;
-- Are there schools that share the same building codes?
SELECT * FROM public_school;

###################################
-- 2. Top Performing Schools
###################################
-- Which schools have the highest SAT scores in math, reading, and writing?
-- How many schools achieve a math score of 640 or higher?
-- What is the lowest score recorded for reading, math, or writing?

###################################
-- 3. Overall SAT Performance
###################################
-- Which schools have the highest total SAT scores?
-- How do these elite schools compare to the rest of the city?

###################################
-- 4. Borough-Level Comparison
###################################
-- How does average SAT performance vary by borough?
-- Which borough has the highest average SAT score despite the number of schools?
-- How do smaller boroughs compare to larger boroughs in overall performance?

###################################
-- 5. Brooklyn-Specific Analysis
###################################
-- Among Brooklyn schools, which ones perform best in math?
-- How does Brooklyn compare to other boroughs in terms of the number of schools and top performers?

#####################################
-- 6. Observations on Equity & Access
#####################################
-- Are there disparities in academic performance across NYC schools?
-- Is there a concentration of high-performing schools in specific areas?
-- What factors (funding, demographics, participation) might explain these differences?