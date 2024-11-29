-- Data Cleaning

SELECT *
FROM wellness;

-- 1. Initial Data Import
-- A new table `wellness_cleaning` was created based on the structure of the original `wellness` table.
-- Data was copied into `wellness_cleaning` for cleaning and analysis.

CREATE TABLE wellness_cleaning
LIKE wellness;

SELECT *
FROM wellness_cleaning;

INSERT wellness_cleaning
SELECT *
FROM wellness;

-- 2. Check and Remove Duplicates
-- The dataset was checked for duplicates by using the ROW_NUMBER() function over all columns.
-- Duplicate rows would have a row_num > 1. The query below checks for duplicates.

WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY 
               Gender, 
               Age, 
               `Work Pressure`, 
               `Job Satisfaction`, 
               `Sleep Duration`, 
               `Dietary Habits`, 
               `Have you ever had suicidal thoughts ?`, 
               `Work Hours`, 
               `Financial Stress`, 
               `Family History of Mental Illness`, 
               Depression
           ) AS row_num
    FROM wellness_cleaning
)
SELECT *
FROM duplicate_cte
WHERE row_num >= 1;

-- Result: No duplicate rows were found in the dataset.

-- Step 3: Check for NULL or Empty String Values in All Columns
SELECT *
FROM wellness_cleaning
WHERE COALESCE(Gender, '') = '' OR
      COALESCE(Age, '') = '' OR
      COALESCE(`Work Pressure`, '') = '' OR
      COALESCE(`Job Satisfaction`, '') = '' OR
      COALESCE(`Sleep Duration`, '') = '' OR
      COALESCE(`Dietary Habits`, '') = '' OR
      COALESCE(`Have you ever had suicidal thoughts ?`, '') = '' OR
      COALESCE(`Work Hours`, '') = '' OR
      COALESCE(`Financial Stress`, '') = '' OR
      COALESCE(`Family History of Mental Illness`, '') = '' OR
      COALESCE(Depression, '') = '';

-- Result: No Null or empty rows were found in the dataset.

/*
After performing data cleaning steps on the wellness_cleaning table, the following observations were made:
1. No duplicate rows were identified in the dataset.
2. No NULL or empty string ('') values were found in any column.

As a result, the wellness_cleaning table remains identical to the original wellness table.
Therefore, for the analysis, the original wellness table will be used directly, ensuring data integrity without unnecessary duplication.
*/

-- Data Analysis 
SELECT * FROM wellness;

-- Calculate Average Sleep Duration by Job Satisfaction
-- Converts 'Sleep Duration' ranges to numeric values:
WITH AvgSleepDurationCTE AS(
	SELECT `Job Satisfaction`,
	AVG(CASE
		WHEN `Sleep Duration` = 'Less than 5 hours' THEN 4
		WHEN `Sleep Duration` = '5-6 hours' THEN 5.5
		WHEN `Sleep Duration` = '7-8 hours' THEN 7.5
		WHEN `Sleep Duration` = 'More than 8 hours' THEN 9
	END) AS avg_sleep_duration
	FROM wellness
	GROUP BY `Job Satisfaction`
	ORDER BY `Job Satisfaction` ASC
)
-- Categorize sleep duration
SELECT *,
CASE
	WHEN avg_sleep_duration < 5.5 THEN "Low"
    WHEN avg_sleep_duration BETWEEN 5.5 and 7.5 THEN "Normal"
    ElSE "High" 
END AS Sleep_Category
FROM AvgSleepDurationCTE;


-- Relationship between Work Pressure and Mental Health
-- Counts the number of 'Yes' and 'No' responses for Depression based on Work Pressure levels (1-5).
SELECT `Work Pressure`,
SUM(CASE WHEN Depression = 'YES' THEN 1 ELSE 0 END) Depression_Yes_Count,
SUM(CASE WHEN Depression = 'NO' THEN 1 ELSE 0 END) Depression_No_Count
FROM wellness
GROUP BY `Work Pressure` ORDER BY `Work Pressure` ASC;

-- Calculate average work hours and financial stress by age group
SELECT Age,
	AVG(`Financial Stress`) AS AVG_Financial_Stress,
	AVG(`Work Hours`) AS AVG_Work_Hours
FROM wellness
GROUP BY Age
ORDER BY Age ASC;

-- Identify high-risk individuals based on multiple factors
SELECT *,
	CASE
    WHEN `Work Pressure` > 3 AND Depression = "Yes" THEN "High Risk"
    WHEN `Work Pressure` > 3 AND Depression = "No" THEN "Mid Risk"
    WHEN `Work Pressure` <= 3 AND Depression = "No" THEN "Low Risk"
	WHEN `Work Pressure` <= 3 AND Depression = "Yes" THEN "Mid Risk"
    END AS Risk_Level
FROM wellness;

-- Group by gender/age and calculated averages for key variables
SELECT Gender, Age,
    AVG(`Work Pressure`) AS avg_work_pressure,
    AVG(`Job Satisfaction`) AS avg_job_satisfaction,
    AVG(`Work Hours`) AS avg_work_hours,
    AVG(`Financial Stress`) AS avg_financial_stress,
    AVG(CASE
		WHEN `Sleep Duration` = 'Less than 5 hours' THEN 4
		WHEN `Sleep Duration` = '5-6 hours' THEN 5.5
		WHEN `Sleep Duration` = '7-8 hours' THEN 7.5
		WHEN `Sleep Duration` = 'More than 8 hours' THEN 9
	END) AS avg_sleep_duration
FROM wellness
GROUP BY Gender, Age
ORDER BY Age; 

-- Count of individuals with depression by dietary habits
SELECT `Dietary Habits` AS diet,
	SUM(CASE WHEN Depression = 'YES' THEN 1 ELSE 0 END) Depression_Yes_Count,
	SUM(CASE WHEN Depression = 'NO' THEN 1 ELSE 0 END) Depression_No_Count,
    COUNT(*) AS Total_Count,
    ROUND(SUM(CASE WHEN Depression = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Depression_Yes_Percent%,
    ROUND((COUNT(*) - SUM(CASE WHEN Depression = 'Yes' THEN 1 ELSE 0 END)) * 100.0 / COUNT(*), 2) AS Depression_No_Percent
FROM wellness
GROUP BY diet;

-- Distribution of sleep duration
SELECT `Sleep Duration`, COUNT(*) AS Count
FROM wellness
GROUP BY `Sleep Duration`;

-- Distribution of financial stress by gender
SELECT `Financial Stress`, COUNT(*) AS Count
FROM wellness
GROUP By `Financial Stress`
ORDER BY `Financial Stress` ASC;



 