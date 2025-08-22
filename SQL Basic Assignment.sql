# Assignment Questions (Theory + SQL)

#1) Create `employees` with constraints:
create database Assignment;

use Assignment;
CREATE TABLE employees (
  emp_id     INT            NOT NULL,
  emp_name   VARCHAR(100)   NOT NULL,
  age        INT,
  email      VARCHAR(255)   UNIQUE,
  salary     DECIMAL(10,2)  DEFAULT 30000.00,
  CONSTRAINT pk_employees PRIMARY KEY (emp_id),
  CONSTRAINT chk_employees_age CHECK (age >= 18)
);


# 2) Purpose of constraints (with examples)
-- PRIMARY KEY: entity identity (e.g., `actor.actor_id`).
-- FOREIGN KEY: referential integrity (e.g., `rental.inventory_id → inventory.inventory_id`).
-- UNIQUE: no duplicates (e.g., `customer.email`).
-- NOT NULL: required data (e.g., names).
-- CHECK: business rules (e.g., `age >= 18`).
-- DEFAULT: stable defaults (e.g., `salary DEFAULT 30000`).

# 3) Why NOT NULL? Can PK be NULL?
-- Use **NOT NULL** to ensure a column always has a value (e.g., required names). A **PRIMARY KEY cannot be NULL**—by definition it must uniquely identify each row, and NULL isn’t a value you can identify/compare.&#x20;

# 4) Add / remove constraints on existing table
-- ADD
ALTER TABLE employees
  ADD CONSTRAINT uq_employees_email UNIQUE (email);

ALTER TABLE employees
  ADD CONSTRAINT chk_employees_age CHECK (age >= 18);

-- DROP (MySQL)
ALTER TABLE employees DROP INDEX uq_employees_email;       -- for UNIQUE
ALTER TABLE employees DROP CHECK chk_employees_age;        -- 8.0.16+

-- Add a FK example
ALTER TABLE orders
  ADD CONSTRAINT fk_orders_customer
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

-- Drop a FK
ALTER TABLE orders DROP FOREIGN KEY fk_orders_customer;


# 5) What happens if you violate constraints?
 -- Writes fail and the statement is rejected (rolled back if transactional). Typical MySQL errors:

-- Duplicate unique: `ERROR 1062 (23000): Duplicate entry 'x' for key 'uq_employees_email'`
-- FK violation: `ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails`
-- Check failure: `ERROR 3819 (HY000): Check constraint 'chk_employees_age' is violated`&#x20;

# 6) Fix `products` (add PK, set default price)

ALTER TABLE products
  ADD CONSTRAINT pk_products PRIMARY KEY (product_id);

ALTER TABLE products
  MODIFY price DECIMAL(10,2) DEFAULT 50.00;

#7) INNER JOIN students ↔ classes
SELECT s.student_name, c.class_name
FROM students s
JOIN classes  c ON c.class_id = s.class_id;

# 8) List all products (even without orders) with order/customer
SELECT
  o.order_id,
  c.customer_name,
  p.product_name
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
LEFT JOIN orders      o  ON o.order_id    = oi.order_id
LEFT JOIN customers   c  ON c.customer_id = o.customer_id
ORDER BY p.product_name, o.order_id;

# 9) Total sales per product (INNER JOIN + SUM)
SELECT
  p.product_id,
  p.product_name,
  SUM(oi.quantity * oi.unit_price) AS total_sales
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sales DESC;

# 10) order\_id, customer\_name, total quantity (3-way INNER JOIN)
SELECT
  o.order_id,
  c.customer_name,
  SUM(oi.quantity) AS total_quantity
FROM orders o
JOIN customers c  ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, c.customer_name
ORDER BY o.order_id;


### SQL Commands — Sakila / Maven Movies
#  Assume standard Sakila names: `actor, film, film_actor, inventory, rental, customer, store, address, city, country, payment, language, category, film_category`. Replace if your dump uses different casing.

-- Identify PKs & FKs + differences

-- Discussion: PK uniquely identifies a row; FK enforces parent-child links.
-- Examples(not exhaustive):

  -- `actor(actor_id PK)`; `film(film_id PK)`
  -- `inventory(inventory_id PK, film_id FK→film)`
  -- `rental(rental_id PK, inventory_id FK→inventory, customer_id FK→customer, staff_id FK→staff)`
  -- `payment(payment_id PK, customer_id FK→customer, rental_id FK→rental, staff_id FK→staff)`
-- System query (MySQL):


-- Primary keys
SELECT tc.table_name, kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type = 'PRIMARY KEY' AND tc.table_schema = DATABASE();

-- Foreign keys
SELECT tc.table_name, kcu.column_name, kcu.referenced_table_name, kcu.referenced_column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = DATABASE();

#2 All actor details
SELECT * FROM actor;

#3 All customers
SELECT * FROM customer;

#4 Different countries
SELECT DISTINCT country FROM country ORDER BY country;

#6 Active customers
SELECT * FROM customer WHERE active = 1;

#7 Rental IDs for customer 1
SELECT rental_id FROM rental WHERE customer_id = 1 ORDER BY rental_id;

#8 Films with rental duration > 5
SELECT film_id, title, rental_duration
FROM film
WHERE rental_duration > 5
ORDER BY rental_duration DESC;

#9 Count films with replacement\_cost between 15 and 20 (exclusive per wording)
SELECT COUNT(*) AS film_count
FROM film
WHERE replacement_cost > 15 AND replacement_cost < 20;

#10 Count of unique actor first names
SELECT COUNT(DISTINCT first_name) AS unique_first_names FROM actor;

#11 First 10 customers
SELECT * FROM customer ORDER BY customer_id LIMIT 10;

#12 First 3 customers whose first\_name starts with 'b'
SELECT *
FROM customer
WHERE first_name LIKE 'b%'
ORDER BY customer_id
LIMIT 3;

#13 First 5 movie titles rated 'G'
SELECT title FROM film WHERE rating = 'G' ORDER BY title LIMIT 5;

#14 Customers with first name starting with 'a'
SELECT * FROM customer WHERE first_name LIKE 'a%';

#15 Customers with first name ending with 'a'
SELECT * FROM customer WHERE first_name LIKE '%a';

#16 First 4 cities that start and end with 'a'
SELECT city
FROM city
WHERE city LIKE 'a%a'
ORDER BY city
LIMIT 4;

#17 Customers with first name containing 'NI' (any position)
SELECT * FROM customer WHERE first_name LIKE '%NI%';

#18 Customers with first name having 'r' in second position
SELECT * FROM customer WHERE first_name LIKE '_r%';

#19 First name starts with 'a' and length ≥ 5
SELECT *
FROM customer
WHERE first_name LIKE 'a%' AND CHAR_LENGTH(first_name) >= 5;

#20 First name starts with 'a' and ends with 'o'
SELECT *
FROM customer
WHERE first_name LIKE 'a%o';

#21 Films with rating PG or PG-13 (IN)
SELECT film_id, title FROM film WHERE rating IN ('PG', 'PG-13');

#22 Films with length between 50 and 100 (BETWEEN is inclusive)
SELECT film_id, title, length FROM film WHERE length BETWEEN 50 AND 100;

#23. Top 50 actors (by actor\_id order; change ORDER BY for other criteria)
SELECT * FROM actor ORDER BY actor_id LIMIT 50;

#24. Distinct film\_ids from inventory
SELECT DISTINCT film_id FROM inventory ORDER BY film_id;



### Functions & Groups (Sakila)&#x20;

# Q1) Total number of rentals
SELECT COUNT(*) AS total_rentals FROM rental;

# Q2) Average rental duration (days)
SELECT AVG(DATEDIFF(return_date, rental_date)) AS avg_rental_days
FROM rental
WHERE return_date IS NOT NULL;

# Q3) Customer names in UPPER
SELECT UPPER(first_name) AS first_name_up, UPPER(last_name) AS last_name_up
FROM customer;

# Q4) Extract month alongside rental\_id
SELECT rental_id, MONTH(rental_date) AS rental_month
FROM rental;

# Q5) Rentals per customer
SELECT customer_id, COUNT(*) AS rental_count
FROM rental
GROUP BY customer_id
ORDER BY rental_count DESC;

# Q6) Total revenue by store
SELECT s.store_id, SUM(p.amount) AS total_revenue
FROM payment p
JOIN staff   st ON st.staff_id = p.staff_id
JOIN store   s  ON s.store_id  = st.store_id
GROUP BY s.store_id
ORDER BY total_revenue DESC;

# Q7) Rentals per category
SELECT c.name AS category, COUNT(*) AS rental_count
FROM rental r
JOIN inventory     i ON i.inventory_id = r.inventory_id
JOIN film          f ON f.film_id      = i.film_id
JOIN film_category fc ON fc.film_id    = f.film_id
JOIN category      c ON c.category_id  = fc.category_id
GROUP BY c.name
ORDER BY rental_count DESC;

#Q8) Avg rental rate by language
SELECT l.name AS language, AVG(f.rental_rate) AS avg_rental_rate
FROM film f
JOIN language l ON l.language_id = f.language_id
GROUP BY l.name
ORDER BY avg_rental_rate DESC;



### Joins (Sakila)

# Q9) Movie title + customer name who rented it
SELECT f.title, c.first_name, c.last_name
FROM rental r
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film     f ON f.film_id       = i.film_id
JOIN customer c ON c.customer_id   = r.customer_id;


# Q10) Actors in “Gone with the Wind”
SELECT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON fa.actor_id = a.actor_id
JOIN film f        ON f.film_id   = fa.film_id
WHERE f.title = 'Gone with the Wind';

# Q11) Customer names + total amount spent
SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_spent
FROM customer c
JOIN payment  p ON p.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

# Q12) Titles rented by each customer in 'London'
SELECT c.customer_id, c.first_name, c.last_name, GROUP_CONCAT(DISTINCT f.title ORDER BY f.title) AS titles
FROM customer c
JOIN address a   ON a.address_id = c.address_id
JOIN city    ci  ON ci.city_id   = a.city_id
JOIN rental  r   ON r.customer_id= c.customer_id
JOIN inventory i ON i.inventory_id= r.inventory_id
JOIN film     f  ON f.film_id     = i.film_id
WHERE ci.city = 'London'
GROUP BY c.customer_id, c.first_name, c.last_name;


### Advanced Joins & GROUP BY

# Q13) Top 5 rented movies
SELECT f.film_id, f.title, COUNT(*) AS times_rented
FROM rental r
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film     f ON f.film_id       = i.film_id
GROUP BY f.film_id, f.title
ORDER BY times_rented DESC
LIMIT 5;

# Q14) Customers who rented from both stores (1 and 2)
SELECT c.customer_id, c.first_name, c.last_name
FROM rental r
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN store    s ON s.store_id      = i.store_id
JOIN customer c ON c.customer_id   = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT s.store_id) = 2;


### Window Functions:

# 1.Rank customers by total spend
WITH spend AS (
  SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_spent
  FROM customer c JOIN payment p ON p.customer_id = c.customer_id
  GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT *, RANK() OVER (ORDER BY total_spent DESC) AS spend_rank
FROM spend;

# 2. Cumulative revenue per film over time
-- Assume payment is tied to rental -> inventory -> film
WITH film_pay AS (
  SELECT f.film_id, f.title, DATE(p.payment_date) AS dt, SUM(p.amount) AS daily_amt
  FROM payment p
  JOIN rental r   ON r.rental_id    = p.rental_id
  JOIN inventory i ON i.inventory_id= r.inventory_id
  JOIN film f      ON f.film_id     = i.film_id
  GROUP BY f.film_id, f.title, DATE(p.payment_date)
)
SELECT *,
  SUM(daily_amt) OVER (PARTITION BY film_id ORDER BY dt
                       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_revenue
FROM film_pay;

# 3. Avg rental duration per film, consider films with similar lengths
SELECT f.film_id, f.title, f.length,
       AVG(DATEDIFF(r.return_date, r.rental_date)) OVER (PARTITION BY f.length) AS avg_duration_by_length
FROM film f
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r    ON r.inventory_id = i.inventory_id
WHERE r.return_date IS NOT NULL;


# 4. Top 3 films in each category by rental counts
WITH counts AS (
  SELECT c.category_id, c.name AS category, f.film_id, f.title, COUNT(*) AS rentals
  FROM category c
  JOIN film_category fc ON fc.category_id = c.category_id
  JOIN film f          ON f.film_id       = fc.film_id
  JOIN inventory i     ON i.film_id       = f.film_id
  JOIN rental r        ON r.inventory_id  = i.inventory_id
  GROUP BY c.category_id, c.name, f.film_id, f.title
)
SELECT *
FROM (
  SELECT counts.*,
         DENSE_RANK() OVER (PARTITION BY category_id ORDER BY rentals DESC) AS rnk
  FROM counts
) x
WHERE rnk <= 3;

# 5. Diff between each customer’s rentals and average rentals
WITH rc AS (
  SELECT customer_id, COUNT(*) AS rentals
  FROM rental GROUP BY customer_id
)
SELECT customer_id, rentals,
       rentals - AVG(rentals) OVER () AS diff_from_avg
FROM rc;

# 6. Monthly revenue trend
SELECT DATE_FORMAT(payment_date, '%Y-%m') AS yyyymm,
       SUM(amount) AS revenue
FROM payment
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY yyyymm;

# 7. Customers in top 20% by spend (P80 cutoff)
WITH spend AS (
  SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_spent
  FROM customer c JOIN payment p ON p.customer_id = c.customer_id
  GROUP BY c.customer_id, c.first_name, c.last_name
),
ranked AS (
  SELECT *, CUME_DIST() OVER (ORDER BY total_spent DESC) AS cum_frac
  FROM spend
)
SELECT * FROM ranked WHERE cum_frac <= 0.20;

# 8. Running total of rentals per category ordered by rental count
WITH cat_rent AS (
  SELECT c.category_id, c.name AS category, COUNT(*) AS rentals
  FROM rental r
  JOIN inventory i ON i.inventory_id = r.inventory_id
  JOIN film f      ON f.film_id = i.film_id
  JOIN film_category fc ON fc.film_id = f.film_id
  JOIN category c       ON c.category_id = fc.category_id
  GROUP BY c.category_id, c.name
)
SELECT category_id, category, rentals,
       SUM(rentals) OVER (ORDER BY rentals DESC
                          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM cat_rent
ORDER BY rentals DESC;

# 9. Films rented less than their category average
WITH film_counts AS (
  SELECT c.category_id, f.film_id, COUNT(*) AS rentals
  FROM category c
  JOIN film_category fc ON fc.category_id = c.category_id
  JOIN film f          ON f.film_id = fc.film_id
  JOIN inventory i     ON i.film_id = f.film_id
  JOIN rental r        ON r.inventory_id = i.inventory_id
  GROUP BY c.category_id, f.film_id
),
cat_avg AS (
  SELECT category_id, AVG(rentals) AS avg_rentals
  FROM film_counts GROUP BY category_id
)
SELECT fc.film_id
FROM film_counts fc
JOIN cat_avg ca ON ca.category_id = fc.category_id
WHERE fc.rentals < ca.avg_rentals;

# 10. Top 5 months with highest revenue
WITH m AS (
  SELECT DATE_FORMAT(payment_date, '%Y-%m') AS yyyymm, SUM(amount) AS revenue
  FROM payment GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
)
SELECT * FROM m ORDER BY revenue DESC LIMIT 5;


### Normalisation & CTE Tasks:

# 1) 1NF violation & fix (example thought experiment)
-- If a table stored multiple phone numbers in one column like customer(…, phones TEXT '123|456'), that violates 1NF (repeating groups). Fix: create customer_phone(customer_id, phone) one phone per row; make (customer_id, phone) unique.

#2) 2NF check
-- On a composite PK, ensure every non-key attribute depends on the full key. Example: in a join table `film_actor(film_id, actor_id, role_name)`, `role_name` depends on both keys—OK. If you had `film_title` there, it depends only on `film_id` → move to `film`.&#x20;

# 3) 3NF
-- Remove transitive dependencies (A→B→C). Example: if `address` table stored `city_name` plus `city_postal_code` while `city_postal_code` depends on `city` not on `address_id`, move postal code to `city`.&#x20;

# 4) Walkthrough to 2NF
-- Start with unnormalised order table having repeated items; split into `order(order_id, customer_id, order_date)` and `order_item(order_id, product_id, qty, price)`. Make PKs and FKs. Ensure `customer_name` isn’t in `order_item`.&#x20;

# 5) CTE: distinct actors + film count
WITH actor_counts AS (
  SELECT a.actor_id, a.first_name, a.last_name, COUNT(fa.film_id) AS films
  FROM actor a
  LEFT JOIN film_actor fa ON fa.actor_id = a.actor_id
  GROUP BY a.actor_id, a.first_name, a.last_name
)
SELECT DISTINCT first_name, last_name, films FROM actor_counts;

# 6) CTE combining film & language
WITH fl AS (
  SELECT f.title, l.name AS language_name, f.rental_rate
  FROM film f JOIN language l ON l.language_id = f.language_id
)
SELECT * FROM fl;


# CTE for aggregation: revenue per customer

WITH spend AS (
  SELECT customer_id, SUM(amount) AS total_spent
  FROM payment GROUP BY customer_id
)
SELECT c.customer_id, c.first_name, c.last_name, s.total_spent
FROM customer c JOIN spend s USING (customer_id)
ORDER BY s.total_spent DESC;

# CTE + window: rank films by rental\_duration
WITH d AS (
  SELECT film_id, title, rental_duration FROM film
)
SELECT d.*, RANK() OVER (ORDER BY rental_duration DESC) AS duration_rank
FROM d;


# CTE & filtering: customers with >2 rentals + details

WITH freq AS (
  SELECT customer_id, COUNT(*) AS rentals
  FROM rental GROUP BY customer_id HAVING COUNT(*) > 2
)
SELECT c.*, f.rentals
FROM customer c JOIN freq f USING (customer_id);


# CTE for monthly rental counts
WITH m AS (
  SELECT DATE_FORMAT(rental_date, '%Y-%m') AS yyyymm, COUNT(*) AS rentals
  FROM rental GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)
SELECT * FROM m ORDER BY yyyymm;

# CTE & self-join: pairs of actors in same film
WITH fa AS (
  SELECT film_id, actor_id FROM film_actor
)
SELECT a1.actor_id AS actor1, a2.actor_id AS actor2, fa1.film_id
FROM fa fa1
JOIN fa fa2 ON fa2.film_id = fa1.film_id AND fa2.actor_id > fa1.actor_id
JOIN actor a1 ON a1.actor_id = fa1.actor_id
JOIN actor a2 ON a2.actor_id = fa2.actor_id
ORDER BY fa1.film_id, actor1, actor2;

# Recursive CTE: staff reporting tree (manager → reports)
#(MySQL 8.0+) Suppose `staff(staff_id, first_name, last_name, reports_to)`:

WITH RECURSIVE org AS (
  SELECT s.staff_id, s.first_name, s.last_name, s.reports_to, 0 AS lvl
  FROM staff s
  WHERE s.staff_id = @manager_id  -- set this variable to the manager you want

  UNION ALL

  SELECT s.staff_id, s.first_name, s.last_name, s.reports_to, o.lvl + 1
  FROM staff s
  JOIN org  o ON s.reports_to = o.staff_id
)
SELECT * FROM org ORDER BY lvl, staff_id;