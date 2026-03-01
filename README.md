# MTN Nigeria Customer Churn Analysis

## Project Summary

This project presents a comprehensive analysis of **MTN Nigeria's** customer churn patterns using advanced SQL querying and customer segmentation techniques.

The insights are derived from customer, device, revenue, and satisfaction datasets to:

* Identify root causes of churn
* Quantify total revenue loss
* Segment high-risk customer groups
* Deliver a prioritised, evidence-based retention strategy

---

## Objectives

* Calculate overall churn rate and total revenue lost to churned customers
* Segment churn by:

  * Tenure
  * Revenue quartile
  * Age group
  * Gender
  * Device type
* Identify top drivers of customer exit
* Investigate why high-satisfaction customers are still churning
* Provide actionable retention recommendations

---

## Tools & Technologies

* **SQL Server (T-SQL)** – Core analysis and querying
* **CASE Logic + ALTER TABLE** – Feature engineering
* **CTEs (Common Table Expressions)** – Multi-step churn calculations
* **Window Functions**

  * `RANK()`
  * `NTILE()`
  * `SUM() OVER()`
* **Temporary Tables** – High-satisfaction churn paradox analysis

---

## Dataset Overview

| Dataset           | Description                                   |
| ----------------- | --------------------------------------------- |
| Customer Data     | Customer ID, Name, Gender, Age, State, Tenure |
| Revenue Data      | Total Revenue, Unit Price, Purchase Count     |
| Device Data       | Device Type (SIM, 4G Router, 5G Router, MiFi) |
| Satisfaction Data | Rating (1–5 scale)                            |
| Churn Data        | Churn Status (Yes/No), Exit Reason            |

---

# Methodology

## 1️⃣ Data Cleaning & Transformation

* Recast six columns to correct data types (`DATE`, `TINYINT`, `INT`)
* Rounded `Data_Usage` to one decimal place
* Standardised date formats for time-based filtering

---

## 2️⃣ Feature Engineering

### Binary Churn Indicator

Converted text-based churn status into numeric format:

```sql
CASE 
    WHEN Churn_Status = 'Yes' THEN 1
    ELSE 0
END AS Customer_Churn
```

### Age Group Segmentation

```sql
CASE 
    WHEN Age < 20 THEN 'Teen'
    WHEN Age BETWEEN 20 AND 34 THEN 'Youth'
    ELSE 'Adult'
END AS Age_Group
```

---

## 3️⃣ Exploratory Data Analysis

* Customer demographic profiling
* Overall churn rate calculation
* Revenue lost due to churn
* Gender-based churn comparison

---

## 4️⃣ Segmentation & Advanced Analysis

* Revenue quartile segmentation using `NTILE(4)`
* Top 10 highest-revenue customers using `RANK()`
* Churn by:

  * Tenure band
  * Device type
  * Subscription type
  * Satisfaction rating

---

## 5️⃣ High-Satisfaction Churn Paradox

A temporary table was created to isolate:

* **118 customers**
* Satisfaction rating **4–5**
* Yet still churned

Exit reasons were analysed separately.

---

# Key Insights

---

## Churn Overview

| Metric                           | Value           |
| -------------------------------- | --------------- |
| Total Customers                  | 974             |
| Churned Customers                | 284             |
| **Overall Churn Rate**           | **29%**         |
| **Total Revenue Lost**           | **₦58,000,200** |
| Avg Revenue per Churned Customer | ₦204,226        |
| Female Churners                  | 150             |
| Male Churners                    | 134             |

---

## Revenue Impact

**5 of the Top 10 Highest-Revenue Customers Have Churned**

| Rank | Customer        | Revenue    | Status |
| ---- | --------------- | ---------- | ------ |
| 1    | Chinedu Brown   | ₦3,640,000 | ❌      |
| 3    | Halima Martin   | ₦3,105,000 | ❌      |
| 5    | Amina Johns     | ₦2,606,500 | ❌      |
| 7    | Michael Schultz | ₦2,381,500 | ❌      |
| 10   | Zina Diaz       | ₦2,034,500 | ❌      |

🚨 High-value customers are not immune to churn.

---

## Tenure Analysis

| Tenure Band    | Churn Rate           |
| -------------- | -------------------- |
| 0–5 Months     | 22.41%               |
| 6–12 Months    | 28.33%               |
| 12–24 Months   | 23.00%               |
| **24+ Months** | **32.05% (Highest)** |

📌 Long-tenure customers churn the most — loyalty does not build passively.

---

## Revenue Quartile Analysis

| Quartile     | Revenue Range         | Churn Rate |
| ------------ | --------------------- | ---------- |
| Q1 (Lowest)  | ₦350 – ₦33,000        | 33.20%     |
| Q2           | ₦33,000 – ₦108,000    | 27.46%     |
| Q3           | ₦108,000 – ₦261,000   | 30.86%     |
| Q4 (Highest) | ₦261,000 – ₦3,000,000 | 25.10%     |

📌 Mid-range customers (Q3) carry nearly the same churn risk as the lowest segment.

---

## Top 3 Churn Drivers

| Rank | Reason                         | Instances |
| ---- | ------------------------------ | --------- |
| 1️⃣  | High Call Tariffs              | 5,400     |
| 2️⃣  | Better Offers from Competitors | 5,200     |
| 3️⃣  | Poor Network Quality           | 4,500     |

---

## High-Satisfaction Churn Paradox

* **118 satisfied customers (Rating 4–5) still churned**

### Top Exit Reasons Among Satisfied Customers

| Reason                         | Customers | %   |
| ------------------------------ | --------- | --- |
| High Call Tariffs              | 30        | 25% |
| Better Offers from Competitors | 18        | 15% |
| Poor Network Quality           | 18        | 15% |
| Relocation                     | 17        | 14% |
| Poor Customer Service          | 14        | 11% |

 Satisfaction does not equal retention when pricing and competition pressures exist.

---

## Device Type Analysis

| Device Type         | Churn Rate        | Revenue      |
| ------------------- | ----------------- | ------------ |
| Mobile SIM Card     | **31% (Highest)** | ₦13,434,700  |
| 4G Router           | 30%               | ₦37,028,000  |
| 5G Broadband Router | 27%               | ₦100,818,000 |
| Broadband MiFi      | 26%               | ₦48,067,500  |

* Single-plan customers churn at **31.36%**
* Multi-plan customers churn at **28.44%**

 Product bundling reduces churn risk.

---

# Strategic Recommendations

---

## 1️⃣ Pricing Strategy

* Restructure call tariffs and data pricing
* Introduce flexible pricing tiers for Q1 and Q3 customers
* Deploy targeted discount offers for price-sensitive segments

---

## 2️⃣ High-Value Customer Retention

* Launch VIP retention programme for top 10% revenue customers
* Provide personalised offers and priority support
* Proactively re-engage churned high-revenue profiles

---

## 3️⃣ Long-Tenure Loyalty Programme

* Launch rewards for customers with 24+ months tenure:

  * Tariff discounts
  * Data bonuses
  * Exclusive perks

---

## 4️⃣ Network Infrastructure Investment

* Improve network performance in high-churn regions
* Prioritise areas with high complaints
* Strengthen service reliability

---

## 5️⃣ Competitive Intelligence System

* Monitor competitor offers in real time
* Deploy rapid counter-offers for at-risk customers
* Create churn prediction alerts

---

## 6️⃣ Multi-Product Bundling Strategy

* Introduce bundled subscription plans
* Incentivise multiple-device ownership
* Promote cross-product discounts

---

# Business Impact

If implemented effectively, these recommendations could:

* Reduce churn by 5–10%
* Protect high-value revenue segments
* Improve long-term customer lifetime value (CLV)
* Increase subscription bundling penetration
