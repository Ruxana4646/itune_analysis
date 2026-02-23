# 🎵 Apple iTunes Sales &amp; Customer Analytics - SQL-Based Data Analysis Project

## 📌 Project Overview

This project analyzes the Apple iTunes music store database using SQL to generate business insights related to customer behavior, sales trends, product performance, artist & genre popularity, and regional revenue distribution.

The goal of this project is to demonstrate strong SQL querying skills, relational database understanding, and business-driven data analysis.

---

## 🗂️ Dataset Description

The database consists of 10 relational tables:

- **Customer**
- **Invoice**
- **Invoice_Line**
- **Track**
- **Album**
- **Artist**
- **Genre**
- **Media_Type**
- **Playlist**
- **Playlist_Track**
- **Employee**

The database follows a relational structure:

Customer → Invoice → Invoice_Line → Track → Album → Artist  
Track → Genre  
Track → Media_Type  
Customer → Employee  

---

## 🛠️ Tools & Technologies Used

- MySQL
- MySQL Workbench
- SQL (Joins, Aggregations, Window Functions, CTEs)
- Tableau (for Dashboard Visualization)

---

## 🧩 Database Design

- Primary Keys defined for all tables
- Foreign Key relationships established to maintain referential integrity
- ER Diagram generated using MySQL Workbench (Reverse Engineering)

---

## 📊 Business Analysis Performed

### 1️⃣ Customer Analytics
- Total spending per customer
- Repeat vs one-time customers
- Customer Lifetime Value (CLV)
- High-value customer identification
- Revenue contribution by country

### 2️⃣ Sales & Revenue Analysis
- Monthly revenue trend (2016–2020)
- Yearly revenue growth
- Average invoice value
- Invoice volume trend
- Revenue by country

### 3️⃣ Product & Content Analysis
- Top 10 tracks by revenue
- Most sold tracks
- Revenue by album
- Track performance ranking

### 4️⃣ Artist & Genre Performance
- Top 5 highest-grossing artists
- Genre popularity by revenue
- Units sold per genre
- Top genre per country (using window functions)

### 5️⃣ Employee & Operational Efficiency
- Revenue handled per support representative
- Customer count per employee
- Employee revenue contribution

### 6️⃣ Geographic Trend Analysis
- Revenue by country
- Customer distribution by region
- Regional genre preferences
- Market opportunity identification

### 7️⃣ Customer Retention & Purchase Pattern
- Purchase frequency distribution
- Repeat purchase analysis
- Multi-genre purchasing behavior
- Average time between purchases

### 8️⃣ Operational Optimization Insights
- Popular product combinations
- Revenue concentration analysis
- High-performing market segments
- Business growth recommendations

---

## 🧠 Advanced SQL Concepts Used

- INNER JOIN, LEFT JOIN
- GROUP BY & HAVING
- Aggregate Functions (SUM, COUNT, AVG)
- Subqueries
- Common Table Expressions (CTE)
- Window Functions:
  - RANK()
  - DENSE_RANK()
  - PARTITION BY

---

## 📌 Sample Query (Top Genre by Country)

```sql
WITH genre_sales AS (
    SELECT 
        c.country,
        g.name AS genre_name,
        SUM(il.quantity * il.unit_price) AS total_revenue
    FROM invoice_line il
    JOIN invoice i ON il.invoice_id = i.invoice_id
    JOIN customer c ON i.customer_id = c.customer_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY c.country, g.name
),
ranked_genre AS (
    SELECT *,
           RANK() OVER (PARTITION BY country ORDER BY total_revenue DESC) AS rank_in_country
    FROM genre_sales
)
SELECT *
FROM ranked_genre
WHERE rank_in_country = 1;
