# 🛒 Instacart Market Basket Analysis 

**Author:** Asim Jamal  
**Dataset:** [Instacart Market Basket Analysis (Kaggle)](https://www.kaggle.com/datasets/psparks/instacart-market-basket-analysis)  

This project explores customer purchasing patterns, reordering behavior, churn risk, customer segmentation, and product-level insights using the **Instacart Market Basket dataset**.  
The goal was to perform **comprehensive exploratory data analysis (EDA)**, apply **statistical and machine learning techniques**, and generate **business-ready insights** for retention, cross-sell, and demand planning strategies.

---

## 📂 Project Overview
The analysis was carried out in **R** using packages such as `tidyverse`, `ggplot2`, `dplyr`, `lubridate`, `arules`, `arulesViz`, and `prophet`.  

This project covers:
- Customer behavior analysis (frequency, recency, loyalty, churn risk)
- Product-level stickiness and drop-off detection
- Market basket analysis for cross-selling
- Segmentation of customers and products
- Demand forecasting for top products
- Funnel and journey analysis to understand retention

---

## 📊 Full List of Analyses Performed

### 1. **Basic EDA & User Behavior**
- Distribution of **days since prior order**
- Orders by **day of the week** and **hour of the day**
- **Average number of items per order**
- **Average items per order per user**
- Reorder ratio by **order sequence number**
- Comparison of **Reorders vs First-time orders**

---

### 2. **Product & Department Trends**
- Top **10 most reordered products**
- **Reorder rate by department**
- **Customer reorder distribution** across users
- **Basket size distribution** (per order & per customer)
- **Product diversity** per customer (unique products purchased)

---

### 3. **Reorder Probability & Stickiness**
- Calculated **Reorder Probability per product** ("stickiness score")
- Identified top products customers repeatedly come back for

---

### 4. **Customer Retention & Churn Analysis**
- **Time gap analysis** between consecutive orders
- Segmentation into **weekday vs weekend shoppers**
- Comparison of **loyal vs infrequent customers**
- **Churn Risk Prediction** using:
  - Ratio of last order gap vs. average order gap
  - Logistic regression model (features: gap ratio, avg basket size, reorder ratio)
  - Visualization of churn distribution

---

### 5. **Product-Level Churn Signals**
- Identified products that customers **used to buy frequently but stopped buying**
- Measured **churn ratio per product**
- Highlighted top dropped products (signals of disengagement)

---

### 6. **Customer Segmentation (RFM Analysis)**
- RFM metrics:
  - **Recency** (time since last purchase)
  - **Frequency** (total orders per user)
  - **Monetary** (average basket size)
- **K-means clustering** applied to RFM features
- Segmented customers into **4 behavioral clusters**:
  - Loyal & big basket shoppers
  - Infrequent & small basket shoppers
  - High-frequency but low-value buyers
  - Recently reactivated users

---

### 7. **Market Basket Analysis (Association Rules)**
- Used **Apriori algorithm** (`arules` package)  
- Extracted rules like:  
  *“Customers who bought **organic strawberries** also tend to buy **almond milk***”
- Visualized association rules with **network graphs**

---

### 8. **Customer Lifetime Value (CLV Proxy)**
- Calculated **CLV proxy** = (number of orders × avg basket size)  
- Segmented customers into:
  - **High Value**
  - **Medium Value**
  - **Low Value**
- Visualized distribution of CLV segments

---

### 9. **Clustering Products Based on Co-Purchase**
- Built **basket matrix (orders × products)**
- Constructed **co-occurrence matrix** for products
- Applied **K-means clustering** to group products bought together
- Reduced dimensions with **PCA**
- Visualized **product clusters**

---

### 10. **Demand Forecasting**
- Prepared **daily demand time-series** for a top product (Organic Bananas, product_id: 24852)
- Applied **Facebook Prophet model** for forecasting
- Generated **30-day demand forecast**

---

### 11. **Outlier Detection**
- Analyzed **order frequency per user**
- Measured **average basket size per user**
- Applied **IQR method** to detect abnormal customers (e.g., suspiciously high frequency or basket size)
- Flagged **potential fraud cases or power users**

---

### 12. **User Journey Funnel Analysis**
- Built funnel stages:
  - **First order users**
  - **Repeat buyers (≥2 orders)**
  - **Loyal users (≥5 orders)**
  - **Power users (≥10 orders)**
- Visualized **conversion funnel** from first purchase to loyalty

---

## 🚀 Key Techniques Used
- **Exploratory Data Analysis (EDA)** with `tidyverse` & `ggplot2`
- **Customer Segmentation** using RFM + K-means clustering
- **Predictive Modeling** (logistic regression for churn, Prophet for forecasting)
- **Market Basket Analysis** with Association Rules (Apriori algorithm)
- **Dimensionality Reduction** with PCA
- **Anomaly Detection** with IQR method
- **Journey Funnel Analytics** for retention insights

---

## 📌 Business Applications of Insights
- **Churn prevention**: Identify at-risk customers and send targeted reactivation campaigns
- **Cross-selling**: Use market basket rules to recommend complementary products
- **Product placement**: Highlight sticky products in promotions & store layouts
- **Demand planning**: Use forecasts to optimize inventory for top-selling products
- **Customer segmentation**: Run different strategies for high-value vs low-value users
- **Fraud detection**: Investigate users with abnormal order behavior

---

## 🛠️ Tech Stack
- **Language**: R  
- **Packages**: `tidyverse`, `dplyr`, `ggplot2`, `lubridate`, `arules`, `arulesViz`, `prophet`, `scales`, `data.table`  

---

## 📈 Sample Visuals
- Order frequency histograms  
- Reorder ratio trends  
- CLV segmentation distributions  
- Market basket association graphs  
- Churn risk histograms  
- Product cluster scatterplots  
- Demand forecasting plots  

---

## ✅ Next Steps
- Build a **recommendation system** using association rules + product churn risk  
- Deploy a **predictive churn model** with additional features (time decay, diversity)  
- Explore **deep learning sequence models (RNN/LSTM)** for demand forecasting  
- Package results into a **dashboard (Shiny/Power BI)** for business users  

---
