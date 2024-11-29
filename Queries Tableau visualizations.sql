/*

Queries Tableau visualizations

*/

-- 1. Average Sleep Duration by Job Satisfaction
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
SELECT *,
    CASE
        WHEN avg_sleep_duration < 5.5 THEN "Low"
        WHEN avg_sleep_duration BETWEEN 5.5 and 7.5 THEN "Normal"
        ELSE "High"
    END AS Sleep_Category
FROM AvgSleepDurationCTE;


-- 2. Work Pressure vs. Mental Health (Depression Counts)
SELECT `Work Pressure`,
    SUM(CASE WHEN Depression = 'YES' THEN 1 ELSE 0 END) AS Depression_Yes_Count,
    SUM(CASE WHEN Depression = 'NO' THEN 1 ELSE 0 END) AS Depression_No_Count
FROM wellness
GROUP BY `Work Pressure`
ORDER BY `Work Pressure` ASC;


-- 3. Risk Levels Based on Work Pressure and Depression
SELECT *,
    CASE
        WHEN `Work Pressure` > 3 AND Depression = "Yes" THEN "High Risk"
        WHEN `Work Pressure` > 3 AND Depression = "No" THEN "Mid Risk"
        WHEN `Work Pressure` <= 3 AND Depression = "No" THEN "Low Risk"
        WHEN `Work Pressure` <= 3 AND Depression = "Yes" THEN "Mid Risk"
    END AS Risk_Level
FROM wellness;


-- 4. Financial Stress and Work Hours by Age Group
SELECT Age,
	AVG(`Financial Stress`) AS AVG_Financial_Stress,
	AVG(`Work Hours`) AS AVG_Work_Hours
FROM wellness
GROUP BY Age
ORDER BY Age ASC;

-- 5. Depression by Dietary Habits
SELECT `Dietary Habits` AS diet,
    SUM(CASE WHEN Depression = 'YES' THEN 1 ELSE 0 END) AS Depression_Yes_Count,
    SUM(CASE WHEN Depression = 'NO' THEN 1 ELSE 0 END) AS Depression_No_Count,
    COUNT(*) AS Total_Count,
    ROUND(SUM(CASE WHEN Depression = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Depression_Yes_Percent,
    ROUND((COUNT(*) - SUM(CASE WHEN Depression = 'Yes' THEN 1 ELSE 0 END)) * 100.0 / COUNT(*), 2) AS Depression_No_Percent
FROM wellness
GROUP BY diet;