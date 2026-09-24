# Olist E-Commerce Sales Analysis

*Portfolio project: this analysis uses Olist's public dataset and is written from the perspective of an in-house data analyst.*

<img width="800" alt="page1_overview" src="https://github.com/user-attachments/assets/0c0d99b9-f956-4588-9183-1cc42b40a0b5" /> 


## 1. Background & Overview

This analysis uses the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), covering about 100,000 orders from 2016 to 2018.

Olist is a Brazilian online marketplace that connects small businesses with customers across Brazil. As a data analyst on the team, I was asked by leadership to review our sales performance from 2016 to 2018, covering about 100,000 orders. All values are in Brazilian reais (R$).

The goal of this analysis was to answer three questions for the business:
- How has revenue changed over time, and when do sales peak?
- Which product categories drive the most revenue?
- Where are our customers, and how do shipping costs vary by region?

These insights are intended to support planning for the marketing, category management, and logistics teams.

**Tools:** PostgreSQL (data modeling) and Power BI (cleaning and visualization)

## 2. Data Structure Overview


I loaded the raw order data into PostgreSQL staging tables, then built a star schema with one fact table and four dimension tables:

| Table | Description |
|---|---|
| fact_order_items | One row per item in an order, with price, shipping cost, and order status (112,650 rows) |
| dim_customer | Customer IDs and locations (city, state) |
| dim_seller | Seller IDs and locations |
| dim_product | Product category (translated to English) and physical dimensions |
| dim_date | Calendar table covering 2016 to 2018 |


**Entity Relationship Diagram:**

<img width="700" alt="Entity relationship diagram" src="https://github.com/user-attachments/assets/e0d89321-6d61-474c-9fdb-eb1f1ebf91e4" />


**Data cleaning decisions:**
- Products with no category were labeled "uncategorized" so their revenue still counts.
- Canceled and unavailable orders were excluded from revenue.
- The monthly trend uses 2017 only, since it's the one complete year in our data.
- Unique customers are counted with `customer_unique_id`, because our system creates a new `customer_id` for every order.

## 3. Executive Summary

Olist generated R$13.5M in revenue across 98,199 orders from 94,983 unique customers. Revenue grew steadily throughout 2017, rising roughly six-times from January to December, with a peak in November driven by Black Friday. Sales are heavily concentrated in São Paulo, which also has our lowest average shipping cost. Customers in remote northern states pay nearly three times as much for shipping, which may be limiting our growth in those regions.

## 4. Insights Deep Dive

**Revenue trends**
- Monthly revenue grew from R$0.12M in January 2017 to R$0.74M in December.
- November 2017 was our strongest month at R$1.0M, lining up with Black Friday.

**Product categories**
- Health & Beauty was our top category at R$1.26M, followed by Watches & Gifts.
- Five categories earned above the top-10 average: Health & Beauty, Watches & Gifts, Bed Bath & Table, Sports & Leisure, and Computers & Accessories.

**Regional sales**
- São Paulo (SP) generated R$5.2M, more than the next two states (RJ and MG) combined.

**Shipping costs**
- Customers in SP paid R$15 on average for shipping.
- Customers in Roraima (RR) and Paraíba (PB) paid R$43, nearly three times as much.
- The states with the cheapest shipping are also where our sales are highest.

<img width="800" alt="page2_customers_shipping" src="https://github.com/user-attachments/assets/6acaf33b-a650-4211-b4d1-0251b6fbc847" />


## 5. Recommendations

- Build inventory plans and campaigns around Black Friday, our biggest sales month of the year.
- Prioritize promotions and seller recruitment in our five above-average categories.
- Test ways to lower shipping costs in the north and northeast, such as shipping discounts, regional warehouses, or recruiting local sellers, to grow sales in underserved states.
- Review delivery times, customer review scores, and repeat purchase rates to see whether slow or expensive shipping affects customer satisfaction.
