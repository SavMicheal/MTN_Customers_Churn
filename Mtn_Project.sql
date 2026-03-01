 SELECT * FROM Mtn_Customer_Churn


--DATA CLEANING

--CHANGING DATE_OF_PURCHASE DATETIME COLUMN TO DATE COLUMN
SELECT DATETIME(Date_of_purchase)  FROM Mtn_Customer_Churn

--ALTERING FIELDS TO SUIT THE DATA TYPE
ALTER TABLE Mtn_Customer_Churn
ALTER COLUMN Date_of_Purchase DATE

ALTER TABLE Mtn_Customer_Churn
ALTER COLUMN Satisfaction_Rate TINYINT

ALTER TABLE Mtn_Customer_Churn
ALTER COLUMN Customer_Tenure_in_Months INT

ALTER TABLE Mtn_Customer_Churn
ALTER COLUMN Unit_Price INT

ALTER TABLE Mtn_Customer_Churn
ALTER COLUMN Number_of_Times_purchased TINYINT


--CHANGING THE DATA_USAGE COLUMN TO A ONE DECIMAL COLUMN
UPDATE Mtn_Customer_Churn
SET Data_Usage = ROUND(Data_Usage, 1)

--ADDING A COLUMN REPRESENTING THE CUSTOMER_CHURN_STATUS FOR EASY CALCULATION
ALTER TABLE Mtn_Customer_Churn
ADD Customer_Churn TINYINT

UPDATE Mtn_Customer_Churn
SET Customer_Churn = 
CASE
	WHEN Customer_Churn_Status = 'Yes' THEN 1
	WHEN Customer_Churn_Status = 'No' THEN 0
	ELSE 2
END 
FROM Mtn_Customer_Churn



-- EXPLORATORY DATA ANALYSIS;

--HOW MANY TOTAL CUSTOMERS ARE IN THE DATASET?
SELECT COUNT(*) AS Total_Customers
FROM mtn_customer_churn;


--DISTRIBUTION OF CUSTOMERS BY GENDER
SELECT 
    Gender,
    COUNT(*) AS Customer_Count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),
        2
    ) AS Percentage
FROM mtn_customer_churn
GROUP BY Gender
ORDER BY Customer_Count DESC;


--DISTRIBUTION BY STATE
SELECT 
    State,
    COUNT(*) AS Customer_Count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),
        2
    ) AS Percentage
FROM Mtn_Customer_Churn
GROUP BY State
ORDER BY Customer_Count DESC;


--WHAT IS THE AVERAGE TENURE?
SELECT 
    MIN(Customer_Tenure_in_months) AS Min_Tenure,
    MAX(Customer_Tenure_in_months) AS Max_Tenure,
    ROUND(AVG(CAST(Customer_Tenure_in_months AS FLOAT)), 0) AS Avg_Tenure
FROM Mtn_Customer_Churn;


--WHAT IS THE AVERAGE MONTHLY REVENUE?
SELECT 
    MIN(Total_Revenue) AS Min_Revenue,
    MAX(Total_Revenue) AS Max_Revenue,
    ROUND(AVG(CAST(Total_Revenue AS FLOAT)), 0) AS Avg_Revenue
FROM Mtn_Customer_Churn;


-- CHURN PERCENTAGE RATE
SELECT 
	SUM(CASE WHEN Customer_Churn = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*) AS ChurnRatePercentage 
FROM Mtn_Customer_Churn

-- CHURN BY GENDER
SELECT Gender, SUM(Customer_Churn) AS Gender_Rate  FROM Mtn_Customer_Churn
GROUP BY Gender 



--USING FEATURE ENGINEERIGN TO ADDING A COLUMN CHURN RATE BY AGE_GROUP

ALTER TABLE Mtn_Customer_Churn
ADD Age_Group VARCHAR(10)

UPDATE Mtn_Customer_Churn
SET Age_Group =
	CASE WHEN Age < 20 THEN 'Teen'
	WHEN Age >= 20 and Age < 35 THEN 'Youth'
	WHEN Age >= 35 THEN 'Adult'
	ELSE 'Child'
	END
FROM Mtn_Customer_Churn


--WHAT IS THE TOTAL REVENUE LOST DUE TO CHURN?

SELECT
	COUNT (*) AS Total_Churn_Customers,
	SUM(Total_Revenue) As Total_Revenue,
	AVG(Total_Revenue) AS AvgRevenuePerChurnedCustomers
FROM Mtn_Customer_Churn
	WHERE Customer_Churn = 1


-- WHO ARE THE TOP HIGHEST REVENUE CUSTOMERS AND WHATS THEIR CHURN STATUS?

SELECT * FROM
	(SELECT Full_Name, SUM(Total_Revenue) AS Total_Revenue, 
		MAX(CAST(Customer_Churn AS INT)) AS Churn_Status, 
		RANK() OVER (ORDER BY SUM(Total_Revenue) DESC) AS Revenue_Rank
	FROM Mtn_Customer_Churn
	GROUP BY Full_Name )
AS Ranked_Customers
	WHERE Revenue_Rank <= 10




--USING CTE TO GET THE CHURN_RATE BY AGE_GROUP

WITH Age_Group_Rate
AS
	(SELECT Age_Group,
		CASE 
		WHEN Age_Group = 'Teen' THEN 0
		WHEN Age_Group = 'Youth' THEN 1
		WHEN Age_Group = 'Adult' THEN 2
		ELSE 3
	END As Groups
FROM Mtn_Customer_Churn)
SELECT Age_Group, Count(Groups) FROM Age_Group_Rate
	GROUP BY Age_Group


-- DO CUSTOMERS WITH SHORT_TERM_TENURE CHURN MORE?

SELECT 
	CASE
		WHEN Customer_Tenure_in_months < 6 THEN '0-5 Months'
		WHEN Customer_Tenure_in_months Between 6 and 12 THEN '6-12 Months'
	    WHEN Customer_Tenure_in_months Between 12 and 24 THEN '12-24 Months'
		ELSE '24+ Months'
		END As Tenure_Group,
    COUNT(*) As Total_Customers,
	AVG(CAST(Customer_Churn As FLOAT)) * 100 As Churn_Rate_Percentage
FROM Mtn_Customer_Churn
GROUP BY
	CASE
		WHEN Customer_Tenure_in_months < 6 THEN '0-5 Months'
		WHEN Customer_Tenure_in_months Between 6 and 12 THEN '6-12 Months'
	    WHEN Customer_Tenure_in_months Between 12 and 24 THEN '12-24 Months'
		ELSE '24+ Months'
	END
	ORDER BY Churn_Rate_Percentage DESC


--IS CHURN HIGHER AMOUNG CUSTOMERS WITH LOW MONTHLY CHARGES?

With Low_Monthly_Charges
As
(
SELECT Total_Revenue, Customer_Churn, NTILE(4) OVER (ORDER BY Total_Revenue) AS Monthly_Charges
FROM Mtn_Customer_Churn
)

SELECT Monthly_Charges, COUNT(*) AS Total_Customers, AVG(CAST(Customer_Churn AS FLOAT)) * 100 AS Churn_Rate_Precentage,
	MIN(Total_Revenue) As Min_Revenue,
	Max(Total_Revenue) As Max_Revenue
FROM Low_Monthly_Charges
GROUP BY Monthly_Charges
ORDER BY Monthly_Charges


--IDENTITY TOP 3 INDICATORS OF CHURN

SELECT * FROM
(
SELECT Reasons_for_Churn, COunt(Customer_Churn) * 100 AS Churn_Rate
	FROM Mtn_Customer_Churn
	WHERE Reasons_for_Churn IS NOT NULL
	GROUP BY Reasons_for_Churn
)
AS Churn_Analysis
	ORDER BY Churn_Rate DESC
	OFFSET 0 ROWS Fetch next 3 ROWS only


-- DEVICE & SUBSCRIPTION PLAN
-- DO CUSTOMERS WHO USE MULTIPLE DEVICES CHURN MORE?

SELECT MTN_Device, COUNT(*) AS Total_Customer, 
	ROUND(AVG(CAST(Customer_Churn AS FLOAT)) * 100, 2)  AS Churn_Rate_Percentage
FROM
(
SELECT Customer_ID, COUNT(*) AS Subscription_Count, MAX(CAST(Customer_Churn AS INT)) AS Customer_Churn,
	CASE
		WHEN COUNT(*) = 1 THEN 'Single Subscription'
		ELSE 'Multiple Subscription'
	END AS MTN_Device
FROM Mtn_Customer_Churn
GROUP BY Customer_ID
)
AS Customer_Level_Data
GROUP BY MTN_Device


-- WHICH MTN DEVICE TYPE HAS THE HIGHEST CHURN RATE AD WHICH GENERATE THE MOST REVENUE
 
 SELECT MTN_Device, COUNT(*) AS Total_Customers, 
	SUM(CASE WHEN Customer_Churn_Status = 'YES' THEN 1 ELSE 0 END) AS Churned_Customer,
	(SUM(CASE WHEN Customer_Churn_Status = 'YES' THEN 1 ELSE 0 END) * 100 / COUNT (*)) AS Churn_Rate_Percent,
	SUM(Total_Revenue) AS Total_Revenue
 FROM Mtn_Customer_Churn
GROUP BY MTN_Device
ORDER BY Churn_Rate_Percent DESC


 -- SATISFACTION & SERVICE QUALITY ANALYSIS
 -- WHAT IS THE AVERAGE SATISFACTION RATING FOR CHURNED VS NON CHURNED CUSTOMERS AND HOW DOES SATISFACTION RATING DISTRIBUTION DIFFER BETWEEN BOTH GROUPS?
WITH Rating_Stats AS
(
SELECT Customer_Churn, Satisfaction_Rate, COUNT(*) AS Frequency FROM Mtn_Customer_Churn
	GROUP BY Customer_Churn, Satisfaction_Rate
),
 TotalPerGroup AS 
 (
 SELECT Customer_Churn, COUNT(*) AS Total_Count
  FROM Mtn_Customer_Churn
  GROUP BY Customer_Churn 
  )

SELECT r.Customer_Churn, r.Satisfaction_Rate, r.Frequency,
	(r.Frequency * 100 / t.Total_Count) AS PercentageWithinGroup
FROM Rating_Stats r JOIN TotalPerGroup t
ON r.Customer_Churn = t.Customer_Churn
ORDER BY r.Customer_Churn, r.Satisfaction_Rate


--AMONG CUSTOMERS WHO GAVE A SATISFACTION RATING OF 4 0R 5 BUT STILL CHURNED?

SELECT * INTO #HighSatChurn
	FROM Mtn_Customer_Churn
	WHERE Satisfaction_Rate IN (4,5)
	AND Customer_Churn_Status = 'YES'
	AND Reasons_for_Churn IS NOT NULL;

SELECT Reasons_for_Churn, COUNT(*) AS Customer_Count, 
	ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 2) AS Percentage_of_Total
	FROM #HighSatChurn
	GROUP BY Reasons_for_Churn
	ORDER BY Customer_Count DESC
