# Olist E-Commerce SQL Analysis

## Project Overview

This project analyzes the Olist e-commerce dataset using SQL Server.

The main goal of this project is to understand the business performance of Olist by analyzing revenue, delivery performance, customer retention, and customer satisfaction.

This project is focused on the SQL analysis phase. Python analysis and Power BI dashboard will be added later.

---

## Business Problem

Olist has many orders, customers, sellers, products, and reviews.  
The business needs to understand where the performance is strong and where there are problems.

The main business questions are:

- Is the business generating strong revenue?
- Are customers buying again or only one time?
- Are orders delivered on time?
- How does late delivery affect customer satisfaction?
- Which states or business areas need more attention?

---

## Dataset

The dataset contains Brazilian e-commerce data from Olist.

The main tables used in this project are:

- customers
- orders
- order_items
- order_payments
- order_reviews
- products
- sellers
- geolocation
- product_category_translation

The data includes information about customers, orders, products, sellers, payments, delivery dates, and review scores.

---

## Tools Used

- SQL Server
- GitHub

Future tools to be added:

- Python
- Power BI

---

## Analysis Questions

This SQL analysis answers the following questions:

- What is the total revenue?
- What is the average order value?
- How many orders were delivered?
- What is the customer retention rate?
- How many customers bought only one time?
- How many customers returned and bought again?
- What is the late delivery rate?
- Which states have more delivery problems?
- What is the average review score?
- How many bad reviews and good reviews exist?
- How does late delivery affect review scores?
- Which states should be prioritized based on delivery and customer satisfaction?

---

## Key Insights

- Olist had **96,470 delivered orders** during the analysis period.

- The business generated total revenue of about **15.42M**.

- The average order value was **159.83**, which means each delivered order generated around 159.83 in revenue on average.

- Customer retention was very low at only **3.00%**. This means most customers bought only one time and did not return for another order.

- The late delivery rate was **8.11%**, with **7,826 late orders**. This shows that delivery performance is generally good, but late delivery is still an important issue.

- Customer satisfaction was generally positive, with an average review score of **4.16**.

- However, the bad review rate was **12.85%**, which means there is still a meaningful number of unhappy customers.

- Late delivery appears to have a negative effect on review scores, especially in some states.

---

## Business Recommendations

- The marketing team should improve customer retention because the business should not depend only on acquiring new customers.

- Olist can use loyalty offers, post-purchase discounts, and email campaigns to encourage customers to buy again.

- The logistics team should reduce delivery delays by monitoring late orders by state, seller, and product category.

- Olist should focus on important states like SP because it has the largest customer base. Even a small delivery issue in SP can affect many customers.

- Sellers with high late delivery rates or low review scores should be monitored and improved.

- The customer service team should analyze bad reviews to understand why customers are unhappy and reduce repeated problems.

---

## Project Structure

```text
SQL/
├── 01_data_quality_checks.sql
├── 02_revenue_analysis.sql
├── 03_customer_retention_analysis.sql
├── 04_delivery_performance_analysis.sql
├── 05_customer_satisfaction_analysis.sql
├── 06_seller_performance_analysis.sql
├── 07_category_performance_analysis.sql
├── 08_state_priority_and_problem_prioritization.sql
└── 09_final_executive_kpi_summary.sql
