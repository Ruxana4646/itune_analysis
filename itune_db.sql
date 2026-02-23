create database itune_db;
use itune_db;
create table artists(artist_id int primary key, name varchar(200));

create table genres (genre_id int primary key , name varchar(200));

create table media_types(media_type_id int primary key, name varchar(200));

create table employe(
employee_id int primary key,
first_name varchar(50),
last_name varchar(50),
title varchar(100),
report_to int,
levels varchar(20),
birthdate date,
hire_date date,
address varchar(100),
city varchar(50),
state varchar(50),
country varchar(50),
postal_code varchar(20),
phone varchar(20),
fax varchar(30),
email varchar(100),
foreign key (report_to) references employe(employee_id));


describe employe;

create table albums(
album_id int primary key,
title varchar(200),
artist_id int,
foreign key (artist_id) references artists(artist_id));

create table tracks(
track_id int primary key,
name varchar(200),
album_id int ,
media_type_id int ,
genre_id int,
composer varchar(200),
milliseconds int,
bytes int,
unit_price decimal(10,2),
foreign key(album_id) references albums(album_id),
foreign key(media_type_id) references media_types(media_type_id),
foreign key(genre_id) references genres(genre_id));

create table customers(
customer_id int primary key,
first_name varchar(50),
last_name varchar(50),
company varchar(100),
address varchar(100),
city varchar(50),
state varchar(100),
country varchar(100),
postal_code varchar(20),
phone varchar(30),
fax varchar(30),
email varchar(100),
support_rep_id int ,
foreign key (support_rep_id) references employe (employee_id));

create table invoices (
invoice_id int primary key,
customer_id int,
invoice_date datetime,
billing_address varchar(200),
billing_city varchar(50),
billing_state varchar(50),
billing_country varchar(50),
billing_postal_code varchar(20),
total decimal(10,2),
foreign key (customer_id) references customers(customer_id));

CREATE TABLE invoice_lines (
    invoice_line_id INT PRIMARY KEY,
    invoice_id INT,
    track_id INT,
    unit_price DECIMAL(10,2),
    quantity INT,
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id),
    FOREIGN KEY (track_id) REFERENCES tracks(track_id)
);

CREATE TABLE playlists (
    playlist_id INT PRIMARY KEY,
    name VARCHAR(200)
);

CREATE TABLE playlist_track (
    playlist_id INT,
    track_id INT,
    PRIMARY KEY (playlist_id, track_id),
    FOREIGN KEY (playlist_id) REFERENCES playlists(playlist_id),
    FOREIGN KEY (track_id) REFERENCES tracks(track_id)
);


SET FOREIGN_KEY_CHECKS = 0;

LOAD DATA LOCAL INFILE 'C:/Users/hp/OneDrive/Documents/album.csv'
INTO TABLE albums
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


SHOW VARIABLES LIKE 'local_infile';

SELECT @@local_infile;  

LOAD DATA LOCAL INFILE "C:/Users/hp/OneDrive/Documents/customer.csv"
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET FOREIGN_KEY_CHECKS = 0;

LOAD DATA LOCAL INFILE 'C:/Users/hp/OneDrive/Documents/employee.csv'
INTO TABLE employe
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET FOREIGN_KEY_CHECKS = 1;

LOAD DATA LOCAL INFILE 'C:/Users/hp/OneDrive/Documents/employee.csv'
INTO TABLE employe
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(employee_id, last_name, first_name, title, @report_to,
 levels, @birthdate, @hire_date,
 address, city, state, country, postal_code, phone, fax, email)
SET
report_to = NULLIF(@report_to, ''),
birthdate = STR_TO_DATE(@birthdate, '%d-%m-%Y %H:%i'),
hire_date = STR_TO_DATE(@hire_date, '%d-%m-%Y %H:%i');

SET FOREIGN_KEY_CHECKS = 1;

LOAD DATA LOCAL INFILE "C:/Users/hp/OneDrive/Documents/invoice_line.csv"
INTO TABLE invoice_lines
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/hp/OneDrive/Desktop/playlist_track.csv'
INTO TABLE playlist_track
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Exploratory analysis

# Data Quality check 
# 1. check Total rows in each table

SELECT COUNT(*) FROM playlist_track;
SELECT * FROM playlists LIMIT 5;
SELECT COUNT(*) FROM invoice_lines;
SELECT * FROM invoice_lines LIMIT 5;
SELECT COUNT(*) FROM tracks;
SELECT * FROM tracks LIMIT 5;
SELECT COUNT(*) FROM albums;
SELECT * FROM albums LIMIT 5;
SELECT COUNT(*) FROM artists;
SELECT * FROM  artists LIMIT 5;
SELECT COUNT(*) FROM customers;
SELECT * FROM customers LIMIT 5;
SELECT COUNT(*) FROM employe;
SELECT * FROM employe LIMIT 10;
SELECT COUNT(*) FROM playlist_track;
SELECT * FROM playlist_track LIMIT 5;
SELECT COUNT(*) FROM tracks;
SELECT * FROM tracks LIMIT 5;
SELECT COUNT(*) FROM invoices;
SELECT * FROM invoices LIMIT 5;

#2. check foreign key integrity
SELECT *
FROM invoice_lines il
LEFT JOIN invoices i ON il.invoice_id = i.invoice_id
WHERE i.invoice_id IS NULL;

SELECT DISTINCT il.invoice_id
FROM invoice_lines il
LEFT JOIN invoices i 
ON il.invoice_id = i.invoice_id
WHERE i.invoice_id IS NULL;

SELECT DISTINCT c.support_rep_id
FROM customers c
LEFT JOIN employe e
ON c.support_rep_id = e.employee_id
WHERE e.employee_id IS NULL
AND c.support_rep_id IS NOT NULL;

# 3.Basic EDA

# Total Revenue
select sum(total) as Total_Revenue  
from invoices;

# monthlty revenue trend
select 
date_format(invoice_date, '%y-%m') as month,
sum(total) as Revenue
from invoices
group by month
order by month;

# Top 5 Customers
select 
c.customer_id,
concat(c.first_name,' ',c.last_name) as name,
sum(i.total) as total_spent
from customers c 
join invoices i on c.customer_id = i.customer_id
group by c.customer_id
order by total_spent desc
limit 5;

# most  popular Genre
select
g.name,
count(il.track_id) as total_sales
from invoice_lines il
join tracks t on il.track_id = t.track_id
join genres g on t.genre_id = g.genre_id
group by g.name
order by total_sales desc;

-- Customer Analytics

#1. top 10 customer
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customers c
JOIN invoices i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 10;

#2. Average customer lifetime value(clv): Average total revenue per customer
SELECT AVG(total_spent) AS avg_customer_value
FROM (
    SELECT customer_id, SUM(total) AS total_spent
    FROM invoices
    GROUP BY customer_id
) t;

#3.repeat vs one-time purchasers
select 
sum(case when invoice_count > 1 then 1 else 0 end) as Repeat_customers,
sum(case when invoice_count = 1 then 1 else 0 end) as one_time_customer
from (
select customer_id, count(invoice_id) as invoice_count
from invoices
group by customer_id)t;

#4.Revenue per country
SELECT 
  c.country,
  SUM(i.total) / COUNT(DISTINCT c.customer_id) AS revenue_per_customer
FROM customers c
JOIN invoices i ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY revenue_per_customer DESC;

#5.Inactive customers
SELECT 
    c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,  -- Concatenate first and last name
    MAX(i.invoice_date) AS last_purchase
FROM customers c
LEFT JOIN invoices i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, full_name
HAVING MAX(i.invoice_date) < DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
   OR MAX(i.invoice_date) IS NULL;

# 6.High Value inactive customers
SELECT 
    c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    MAX(i.invoice_date) AS last_purchase,
    IFNULL(SUM(i.total), 0) AS total_spent
FROM customers c
LEFT JOIN invoices i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, full_name
HAVING MAX(i.invoice_date) < DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
   OR MAX(i.invoice_date) IS NULL
ORDER BY total_spent DESC;

-- SALES AND REVENUE ANALYSIS

#.1 Monthly revenue trends
SELECT DATE_FORMAT(invoice_date, '%Y-%m') AS month, SUM(total) AS revenue
FROM invoices
WHERE invoice_date >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
GROUP BY month
ORDER BY month;
SELECT MIN(invoice_date), MAX(invoice_date) FROM invoices;

# 2.Average invoice values
SELECT AVG(total) AS avg_invoice_value FROM invoices;

#3.Revenue per sales rep
select e.employee_id, concat(e.first_name,' ',e.last_name) as name, sum(i.total) as revenue
from employe e
join customers c on e.employee_id = c.support_rep_id
join invoices i on c.customer_id = i.customer_id
group by e.employee_id,name 
order by revenue desc ;

#4.peak months/quarters
select month(invoice_date) as month , sum(total) as Revenue
from invoices 
group by month
order by Revenue desc;

-- PRODUCT AND CONTENT ANALYSIS

#1. track generating most revenue
select t.track_id , t.name , sum(il.unit_price * il.quantity) as Revenue
from tracks t
join invoice_lines il on t.track_id = il.track_id
group by t.track_id , t.name
order by Revenue
desc limit 10;

#2.mostbfrequently purchased albums/playlist
SELECT a.album_id, a.title, SUM(il.quantity) AS units_sold
FROM albums a
JOIN tracks t ON a.album_id = t.album_id
JOIN invoice_lines il ON t.track_id = il.track_id
GROUP BY a.album_id, a.title
ORDER BY units_sold DESC;

#playlists(if sold as part of bundle);
SELECT p.playlist_id, p.name, COUNT(pt.track_id) AS track_count_sold
FROM playlists p
JOIN playlist_track pt ON p.playlist_id = pt.playlist_id
GROUP BY p.playlist_id, p.name
ORDER BY track_count_sold DESC;

#3.track/album never purchased
SELECT t.track_id, t.name
FROM tracks t
LEFT JOIN invoice_lines il ON t.track_id = il.track_id
WHERE il.track_id IS NULL;

#4. Average track price per genre
SELECT g.name AS genre, AVG(t.unit_price) AS avg_price
FROM tracks t
JOIN genres g ON t.genre_id = g.genre_id
GROUP BY g.name;

#5.Track per genre & correlation with sale
SELECT g.name AS genre, COUNT(t.track_id) AS total_tracks,
       SUM(il.quantity) AS tracks_sold
FROM genres g
JOIN tracks t ON g.genre_id = t.genre_id
LEFT JOIN invoice_lines il ON t.track_id = il.track_id
GROUP BY g.name;

-- Artist and Genre performance

#1.Top 5 highest-grossing artists
SELECT ar.artist_id, ar.name, SUM(il.unit_price * il.quantity) AS revenue
FROM artists ar
JOIN albums a ON ar.artist_id = a.artist_id
JOIN tracks t ON a.album_id = t.album_id
JOIN invoice_lines il ON t.track_id = il.track_id
GROUP BY ar.artist_id, ar.name
ORDER BY revenue DESC
LIMIT 5;

#2.popular genre
-- by number off track sold
SELECT g.name, SUM(il.quantity) AS units_sold
FROM genres g
JOIN tracks t ON g.genre_id = t.genre_id
JOIN invoice_lines il ON t.track_id = il.track_id
GROUP BY g.name
ORDER BY units_sold DESC;

-- by revenue
SELECT g.name, SUM(il.unit_price * il.quantity) AS revenue
FROM genres g
JOIN tracks t ON g.genre_id = t.genre_id
JOIN invoice_lines il ON t.track_id = il.track_id
GROUP BY g.name
ORDER BY revenue DESC;

#3.Genre by country
SELECT c.country, g.name, SUM(il.quantity) AS units_sold
FROM customers c
JOIN invoices i ON c.customer_id = i.customer_id
JOIN invoice_lines il ON i.invoice_id = il.invoice_id
JOIN tracks t ON il.track_id = t.track_id
JOIN genres g ON t.genre_id = g.genre_id
GROUP BY c.country, g.name
ORDER BY c.country, units_sold DESC;

-- Employee & Operational Efficiency
#1.Employee managing Highest-spending customers;
SELECT e.employee_id, CONCAT(e.first_name, ' ', e.last_name) AS full_name,
SUM(i.total) AS revenue
FROM employe e
JOIN customers c ON e.employee_id = c.support_rep_id
JOIN invoices i ON c.customer_id = i.customer_id
GROUP BY e.employee_id
ORDER BY revenue DESC;

#2.Average customer by employee
SELECT AVG(customer_count) AS avg_customers
FROM (
    SELECT support_rep_id, COUNT(customer_id) AS customer_count
    FROM customers
    GROUP BY support_rep_id
) t;

#3. Revenue by employee region
SELECT e.city, e.state, SUM(i.total) AS revenue
FROM employe e
JOIN customers c ON e.employee_id = c.support_rep_id
JOIN invoices i ON c.customer_id = i.customer_id
GROUP BY e.city, e.state
ORDER BY revenue DESC;

-- Customer Retention & purchase Patterns
#1.purchase frequency distribution
SELECT customer_id, COUNT(invoice_id) AS purchase_count
FROM invoices
GROUP BY customer_id;

#2. Average time between purchase
SELECT 
    customer_id, 
    AVG(DATEDIFF(next_invoice, invoice_date)) AS avg_days_between
FROM (
    SELECT 
        customer_id, 
        invoice_date,
        LEAD(invoice_date) OVER(
            PARTITION BY customer_id 
            ORDER BY invoice_date
        ) AS next_invoice
    FROM invoices
) t
WHERE next_invoice IS NOT NULL
GROUP BY customer_id
ORDER BY avg_days_between;

#3.Customer Buying Multiple Genres
SELECT customer_id, COUNT(DISTINCT t.genre_id) AS genres_bought
FROM invoices i
JOIN invoice_lines il ON i.invoice_id = il.invoice_id
JOIN tracks t ON il.track_id = t.track_id
GROUP BY customer_id
HAVING genres_bought > 1;

-- Geographic Trend
#1. countries with most customers
SELECT country, COUNT(customer_id) AS customer_count
FROM customers
GROUP BY country
ORDER BY customer_count DESC;

#2.Revenue by region
SELECT country, SUM(i.total) AS revenue
FROM customers c
JOIN invoices i ON c.customer_id = i.customer_id
GROUP BY country
ORDER BY revenue DESC;

-- OPERATIONAL OPTIMIZATION
#1.Track purschased together:use invoicelines with same invoice_id:
SELECT il1.track_id AS track1, il2.track_id AS track2, COUNT(*) AS times_bought_together
FROM invoice_lines il1
JOIN invoice_lines il2 ON il1.invoice_id = il2.invoice_id AND il1.track_id < il2.track_id
GROUP BY track1, track2
ORDER BY times_bought_together DESC
LIMIT 20;

#2.pricing pattern affecting sales:correlate unit_price with quantity sold
SELECT t.track_id, t.name, t.unit_price, SUM(il.quantity) AS total_sold
FROM tracks t
JOIN invoice_lines il ON t.track_id = il.track_id
GROUP BY t.track_id, t.name, t.unit_price
ORDER BY total_sold DESC;

#3.media type trends
SELECT mt.name, SUM(il.quantity) AS total_sold
FROM media_types mt
JOIN tracks t ON mt.media_type_id = t.media_type_id
JOIN invoice_lines il ON t.track_id = il.track_id
GROUP BY mt.name
ORDER BY total_sold DESC;


-- Calculate customer spending and segment them Using window functions, subqueries, and CTEs to generate deeper insights.Segment users and rank products by popularity and sales performance.
-- Customer segmentation and Track Ranking
WITH customer_segment AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS full_name,
        SUM(i.total) AS total_spent,
        CASE 
            WHEN SUM(i.total) >= 100 THEN 'High Spender'
            WHEN SUM(i.total) >= 50 THEN 'Medium Spender'
            ELSE 'Low Spender'
        END AS spending_segment
    FROM customers c
    LEFT JOIN invoices i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, full_name
),

--  Calculate track revenue and rank tracks
track_ranking AS (
    SELECT 
        t.track_id,
        t.name AS track_name,
        SUM(il.quantity) AS units_sold,
        SUM(il.quantity * il.unit_price) AS revenue,
        RANK() OVER(ORDER BY SUM(il.quantity * il.unit_price) DESC) AS revenue_rank 
    FROM tracks t
    JOIN invoice_lines il ON t.track_id = il.track_id
    GROUP BY t.track_id, t.name
)

--  Combine customers and tracks to see segment purchases
SELECT 
    cs.full_name,
    cs.spending_segment,
    tr.track_name,
    tr.units_sold,
    tr.revenue,
    tr.revenue_rank
FROM customer_segment cs
JOIN invoices i ON cs.customer_id = i.customer_id
JOIN invoice_lines il ON i.invoice_id = il.invoice_id
JOIN track_ranking tr ON il.track_id = tr.track_id
ORDER BY cs.spending_segment DESC, tr.revenue_rank;

 # Top performing product
 SELECT 
    track_id,
    SUM(unit_price * quantity) AS revenue,
    RANK() OVER(ORDER BY SUM(unit_price * quantity) DESC) AS revenue_rank
FROM invoice_lines
GROUP BY track_id;

-- Region Wise Top selling product
WITH region_track_sales AS (
    SELECT 
        c.country,
        t.track_id,
        t.name AS track_name,
        SUM(il.quantity * il.unit_price) AS revenue
    FROM customers c
    JOIN invoices i ON c.customer_id = i.customer_id
    JOIN invoice_lines il ON i.invoice_id = il.invoice_id
    JOIN tracks t ON il.track_id = t.track_id
    GROUP BY c.country, t.track_id, t.name
)

SELECT 
    country,
    track_name,
    revenue,
    RANK() OVER(PARTITION BY country ORDER BY revenue DESC) AS rank_in_country
FROM region_track_sales
ORDER BY country, rank_in_country;

-- Top track per region
WITH region_genre_sales AS (
    SELECT 
        c.country,
        g.genre_id,
        g.name AS genre_name,
        SUM(il.quantity * il.unit_price) AS revenue
    FROM customers c
    JOIN invoices i 
        ON c.customer_id = i.customer_id
    JOIN invoice_lines il 
        ON i.invoice_id = il.invoice_id
    JOIN tracks t 
        ON il.track_id = t.track_id
    JOIN genres g 
        ON t.genre_id = g.genre_id
    GROUP BY c.country, g.genre_id, g.name
)
SELECT 
    country,
    genre_name,
    revenue,
    RANK() OVER (
        PARTITION BY country 
        ORDER BY revenue DESC
    ) AS rank_in_country
FROM region_genre_sales
ORDER BY country, rank_in_country;

-- Most popular Genre by quantity
WITH country_genre_sales AS (
    SELECT 
        c.country,
        g.name AS genre_name,
        SUM(il.quantity) AS total_units_sold
    FROM customers c
    JOIN invoices i 
        ON c.customer_id = i.customer_id
    JOIN invoice_lines il 
        ON i.invoice_id = il.invoice_id
    JOIN tracks t 
        ON il.track_id = t.track_id
    JOIN genres g 
        ON t.genre_id = g.genre_id
    GROUP BY c.country, g.name
)

SELECT *
FROM (
    SELECT 
        country,
        genre_name,
        total_units_sold,
        RANK() OVER (
            PARTITION BY country 
            ORDER BY total_units_sold DESC
        ) AS rank_in_country
    FROM country_genre_sales
) ranked
WHERE rank_in_country = 1
ORDER BY country;


-- overall rank
WITH country_genre_sales AS (
    SELECT 
        c.country,
        g.genre_id,
        g.name AS genre_name,
        SUM(il.quantity * il.unit_price) AS revenue
    FROM customers c
    JOIN invoices i 
        ON c.customer_id = i.customer_id
    JOIN invoice_lines il 
        ON i.invoice_id = il.invoice_id
    JOIN tracks t 
        ON il.track_id = t.track_id
    JOIN genres g 
        ON t.genre_id = g.genre_id
    GROUP BY c.country, g.genre_id, g.name
),

global_genre_rank AS (
    SELECT 
        genre_id,
        genre_name,
        SUM(revenue) AS total_global_revenue,
        RANK() OVER (ORDER BY SUM(revenue) DESC) AS overall_rank
    FROM country_genre_sales
    GROUP BY genre_id, genre_name
),

country_ranked AS (
    SELECT 
        country,
        genre_id,
        genre_name,
        revenue,
        RANK() OVER (
            PARTITION BY country 
            ORDER BY revenue DESC
        ) AS rank_in_country
    FROM country_genre_sales
)

SELECT 
    cr.country,
    cr.genre_name,
    cr.revenue,
    cr.rank_in_country,
    gr.overall_rank
FROM country_ranked cr
JOIN global_genre_rank gr
    ON cr.genre_id = gr.genre_id
WHERE cr.rank_in_country = 1
ORDER BY cr.country;

-- Customer Analysis view
CREATE OR REPLACE VIEW customer_analysis_view AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    c.country,
    COUNT(i.invoice_id) AS total_orders,
    SUM(i.total) AS total_spent,
    AVG(i.total) AS avg_order_value,
    MIN(i.invoice_date) AS first_purchase,
    MAX(i.invoice_date) AS last_purchase,
    CASE 
        WHEN SUM(i.total) >= 100 THEN 'High Spender'
        WHEN SUM(i.total) >= 50 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS spending_segment
FROM customers c
LEFT JOIN invoices i 
    ON c.customer_id = i.customer_id
GROUP BY c.customer_id, full_name, c.country;
select * from customer_analysis_view;

-- Sales Trend View
CREATE OR REPLACE VIEW sales_trend_view AS
SELECT 
    YEAR(invoice_date) AS year,
    MONTH(invoice_date) AS month,
    DATE_FORMAT(invoice_date, '%Y-%m') AS years_month,
    SUM(total) AS monthly_revenue,
    COUNT(invoice_id) AS total_invoices,
    AVG(total) AS avg_invoice_value
FROM invoices
GROUP BY 
    YEAR(invoice_date),
    MONTH(invoice_date),
    DATE_FORMAT(invoice_date, '%Y-%m');
    select * from  sales_trend_view;
    
-- Product Performance view
CREATE OR REPLACE VIEW product_performance_view AS
SELECT 
    t.track_id,
    t.name AS track_name,
    g.name AS genre_name,
    SUM(il.quantity) AS units_sold,
    SUM(il.quantity * il.unit_price) AS revenue,
    RANK() OVER (ORDER BY SUM(il.quantity * il.unit_price) DESC) AS revenue_rank
FROM tracks t
JOIN invoice_lines il 
    ON t.track_id = il.track_id
JOIN genres g 
    ON t.genre_id = g.genre_id
GROUP BY t.track_id, t.name, g.name;
select * from product_performance_view;

-- Regional Genre View
CREATE OR REPLACE VIEW regional_genre_view AS
WITH country_genre_sales AS (
    SELECT 
        c.country,
        g.genre_id,
        g.name AS genre_name,
        SUM(il.quantity * il.unit_price) AS revenue
    FROM customers c
    JOIN invoices i 
        ON c.customer_id = i.customer_id
    JOIN invoice_lines il 
        ON i.invoice_id = il.invoice_id
    JOIN tracks t 
        ON il.track_id = t.track_id
    JOIN genres g 
        ON t.genre_id = g.genre_id
    GROUP BY c.country, g.genre_id, g.name
),

global_genre_rank AS (
    SELECT 
        genre_id,
        SUM(revenue) AS total_global_revenue,
        RANK() OVER (ORDER BY SUM(revenue) DESC) AS overall_rank
    FROM country_genre_sales
    GROUP BY genre_id
)

SELECT 
    cgs.country,
    cgs.genre_id,
    cgs.genre_name,
    cgs.revenue,
    RANK() OVER (PARTITION BY cgs.country ORDER BY cgs.revenue DESC) AS rank_in_country,
    ggr.overall_rank
FROM country_genre_sales cgs
JOIN global_genre_rank ggr
    ON cgs.genre_id = ggr.genre_id;
select * from regional_genre_view;
