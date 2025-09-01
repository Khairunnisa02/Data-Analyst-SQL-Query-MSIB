#UNDERSTANDING DATABASES
##THERE ARE 15 TABLES IN THIS DATABASE
###USE THIS QUERY TO SEE EACH TABLE
####ACTOR TABLE

SELECT * FROM public.actor
ORDER BY actor_id ASC LIMIT 100

####ADDRESS TABLE

SELECT * FROM public.address
ORDER BY address_id ASC LIMIT 100

####CATEGORY TABLE

SELECT * FROM public.category
ORDER BY category_id ASC LIMIT 100

####CITY TABLE

SELECT * FROM public.city
ORDER BY city_id ASC LIMIT 100

####COUNTRY TABLE

SELECT * FROM public.country
ORDER BY country_id ASC LIMIT 100

####CUSTOMER TABLE

SELECT * FROM public.customer
ORDER BY customer_id ASC LIMIT 100

####FILM TABLE

SELECT * FROM public.film
ORDER BY film_id ASC LIMIT 100

####FILM_ACTOR TABLE

SELECT * FROM public.film_actor
ORDER BY actor_id ASC, film_id ASC LIMIT 100

####FILM_CATEGORY TABLE

SELECT * FROM public.film_category
ORDER BY film_id ASC, category_id ASC LIMIT 100

####INVENTORY TABLE

SELECT * FROM public.inventory
ORDER BY inventory_id ASC LIMIT 100

####LANGUAGE TABLE

SELECT * FROM public.language
ORDER BY language_id ASC LIMIT 100

####PAYMENT TABLE

SELECT * FROM public.payment
ORDER BY payment_id ASC LIMIT 100

####RENTAL TABLE

SELECT * FROM public.rental
ORDER BY rental_id ASC LIMIT 100

####STAFF TABLE

SELECT * FROM public.staff
ORDER BY staff_id ASC LIMIT 100

####STORE TABLE

SELECT * FROM public.store
ORDER BY store_id ASC LIMIT 100


#BASIC QUERY: SELECT, WHERE, ORDER BY, LIMIT
##Show the 5 most recent films (released in 2006 or later) with a rental rate above 2.50, ordered by the newest release year and the highest rental rate.

SELECT film_id, title, release_year, rental_rate
FROM film
WHERE release_year >= 2006 AND rental_rate > 2.50
ORDER BY release_year DESC, rental_rate DESC
LIMIT 5


#AGGREGATION QUERY: COUNT (), SUM (), AVG (), MAX (), MIN ()
##Show the top 5 customers by total payment amount, including their count, average, max, and min payments.

SELECT customer_id,
COUNT (amount) AS count_amount_paid,
sum (amount) AS total_amount_paid, 
AVG (amount) AS average_amount_paid, 
MAX (amount) AS maximum_amount_paid, 
MIN (amount) AS minimum_amount_paid
FROM payment
GROUP BY customer_id
ORDER BY total_amount_paid DESC
LIMIT 5


#JOIN QUERY: INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL JOIN
##Show 5 customers who have paid the least in total, including their full name, email, and total payment amount.

SELECT concat (first_name, ' ', last_name) AS full_name, email, 
SUM (amount) AS total_amount_paid
FROM customer
INNER JOIN payment ON payment.customer_id = customer.customer_id
GROUP BY full_name, email
ORDER BY total_amount_paid
LIMIT 5


#SUBQUERY AND CTE
##SUBQUERY
###Which 5 customers spent the most money on rentals, and how much did they spend in total

SELECT full_name, total_paid
FROM (
    SELECT customer.customer_id, 
           CONCAT(customer.first_name, ' ', customer.last_name) AS full_name,
           SUM(payment.amount) AS total_paid
    FROM customer
    JOIN payment ON customer.customer_id = payment.customer_id
    GROUP BY customer.customer_id, full_name
) AS customer_totals
ORDER BY total_paid DESC
LIMIT 5

##CTE
###Which 5 customers spent the most money on rentals, and how much did they spend in total

WITH customer_totals AS (
    SELECT customer.customer_id, 
           CONCAT(customer.first_name, ' ', customer.last_name) AS full_name,
           SUM(payment.amount) AS total_paid
    FROM customer
    JOIN payment ON customer.customer_id = payment.customer_id
    GROUP BY customer.customer_id, full_name
)
SELECT full_name, total_paid
FROM customer_totals
ORDER BY total_paid DESC
LIMIT 5


#CASE STUDY
#1. How many rental films were returned late, early, and on time? -> This query shows the transaction that may not have been done

SELECT CASE
	WHEN rental_duration > date_part('day', return_date-rental_date) THEN 'returned early'
	WHEN rental_duration = date_part('day', return_date-rental_date) THEN 'returned on time'
	ELSE 'returned_late'
	END AS status_of_return,
	COUNT(*) AS total_number_of_films
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY status_of_return
ORDER BY total_number_of_films DESC

#2. Show the 5 most profitable countries for this business and the output must be INCLUDE how many transactions customers have

SELECT country, COUNT(*) AS total_transaction_customers, SUM(amount) AS total_sales
FROM country
INNER JOIN city ON country.country_id = city.country_id
INNER JOIN address ON city.city_id = address.city_id
INNER JOIN customer ON address.address_id = customer.address_id
INNER JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY country
ORDER BY total_transaction_customers DESC
LIMIT 5

#3. Show the 5 most profitable countries for this business and the output with unique customers

SELECT country, COUNT(DISTINCT customer.customer_id) AS total_number_customers, SUM(amount) AS total_sales
FROM country
INNER JOIN city ON country.country_id = city.country_id
INNER JOIN address ON city.city_id = address.city_id
INNER JOIN customer ON address.address_id = customer.address_id
INNER JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY country
ORDER BY total_number_customers DESC
LIMIT 5

#4. Identify the top 10 customers and their email addresses so we can reward them.

SELECT concat (first_name, ' ',last_name) AS full_name, email,
SUM (amount) AS total_amount_paid
FROM customer
INNER JOIN payment ON payment.customer_id = customer.customer_id
GROUP BY full_name, email
ORDER BY total_amount_id DESC
LIMIT 10

#5. The most profitable film genres (ratings)

SELECT category.name AS genre, COUNT(customer.customer_id) AS total_demanded,
SUM(payment.amount) AS total_sales
FROM category
INNER JOIN film_category ON category.category_id = film_category.category_id
INNER JOIN film ON film_category.film_id = film.film_id
INNER JOIN inventory ON film.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
INNER JOIN customer ON rental.customer_id = customer.customer_id
INNER JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY genre
ORDER BY total_demanded DESC

#6. What are the average rental rates per film genre (rating)?

SELECT name AS movie_genre, AVG(rental_rate) AS average_rental_rate
FROM category
JOIN film_category
USING(category_id)
JOIN film
USING(film_id)
GROUP BY movie_genre
ORDER BY average_rental_rate DESC


#For Visualization
#1. Which country has the most customers

SELECT country, COUNT(DISTINCT customer.customer_id) AS total_number_customers, SUM(amount) AS total_sales
FROM country
INNER JOIN city ON country.country_id = city.country_id
INNER JOIN address ON city.city_id = address.city_id
INNER JOIN customer ON address.address_id = customer.address_id
INNER JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY country
ORDER BY total_number_customers DESC

#2. Which cities are the most profitable for the top 3 countries example in India country

SELECT 
    city.city,
    COUNT(DISTINCT customer.customer_id) AS total_number_customers,
	COUNT(payment.payment_id) AS total_transactions,
    SUM(payment.amount) AS total_sales
FROM country
INNER JOIN city ON country.country_id = city.country_id
INNER JOIN address ON city.city_id = address.city_id
INNER JOIN customer ON address.address_id = customer.address_id
INNER JOIN payment ON customer.customer_id = payment.customer_id
WHERE country.country = 'India'
GROUP BY city
ORDER BY total_sales DESC

#3. How many rental films were returned late, early, and on time with case when 'NOT INCLUDED transaction that has not yet been done'?

SELECT	country.country,
	CASE
	WHEN rental_duration > date_part('day', return_date-rental_date) THEN 'returned early'
	WHEN rental_duration = date_part('day', return_date-rental_date) THEN 'returned on time'
	ELSE 'returned_late'
	END AS status_of_return,
	COUNT(*) AS total_number_of_films
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
INNER JOIN customer ON rental.customer_id = customer.customer_id
INNER JOIN address ON customer.address_id = address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id
WHERE rental.return_date IS NOT NULL   -- supaya hanya transaksi yang sudah dikembalikan
GROUP BY country.country, status_of_return
ORDER BY country.country, total_number_of_films DESC


#4. How many rental films were returned late, early, and on time without showing the countries?

SELECT
	CASE
	WHEN rental_duration > date_part('day', return_date-rental_date) THEN 'returned early'
	WHEN rental_duration = date_part('day', return_date-rental_date) THEN 'returned on time'
	ELSE 'returned_late'
	END AS status_of_return,
	COUNT(*) AS total_number_of_films
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
INNER JOIN customer ON rental.customer_id = customer.customer_id
INNER JOIN address ON customer.address_id = address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id
WHERE rental.return_date IS NOT NULL   -- supaya hanya transaksi yang sudah dikembalikan
GROUP BY status_of_return
ORDER BY total_number_of_films DESC

#5. How many rental films were returned late, early, and on time in each country (example in India country)?

SELECT CASE
	WHEN rental_duration > date_part('day', return_date-rental_date) THEN 'returned early'
	WHEN rental_duration = date_part('day', return_date-rental_date) THEN 'returned on time'
	ELSE 'returned_late'
	END AS status_of_return,
	COUNT(*) AS total_number_of_films
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
INNER JOIN customer ON rental.customer_id = customer.customer_id
INNER JOIN address ON customer.address_id = address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id
WHERE country.country = 'India' AND rental.return_date IS NOT NULL   -- supaya hanya transaksi yang sudah dikembalikan
GROUP BY status_of_return
ORDER BY total_number_of_films DESC

#6. Show customer names with the highest profit for all countries?

WITH customer_totals AS (
    SELECT customer.customer_id, 
           CONCAT(customer.first_name, ' ', customer.last_name) AS full_name,
		   country.country,
           SUM(payment.amount) AS total_paid
    FROM customer
    JOIN payment ON customer.customer_id = payment.customer_id
	JOIN address ON customer.address_id = address.address_id
	JOIN city ON address.city_id = city.city_id
	JOIN country ON city.country_id = country.country_id
    GROUP BY customer.customer_id, full_name, country.country
)
SELECT full_name, total_paid, country
FROM customer_totals
ORDER BY total_paid DESC

#7. Show customer names with the highest profit for India country?

WITH customer_totals AS (
    SELECT customer.customer_id, 
           CONCAT(customer.first_name, ' ', customer.last_name) AS full_name,
		   country.country,
           SUM(payment.amount) AS total_paid
    FROM customer
    JOIN payment ON customer.customer_id = payment.customer_id
	JOIN address ON customer.address_id = address.address_id
	JOIN city ON address.city_id = city.city_id
	JOIN country ON city.country_id = country.country_id
    GROUP BY customer.customer_id, full_name, country.country
)
SELECT full_name, total_paid, country
FROM customer_totals
WHERE country = 'India'
ORDER BY total_paid DESC

#8. SHOW THE FAVORITE CATEGORY (group by category)

SELECT 
    category.name AS category_name,
    COUNT(rental.rental_id) AS total_rentals
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN film ON film_category.film_id = film.film_id
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY category.name
ORDER BY total_rentals DESC

#9. SHOW THE FAVORITE CATEGORY (group by category and countries)

SELECT 
	country.country,
	category.name AS category_name,
    COUNT(rental.rental_id) AS total_rentals
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN film ON film_category.film_id = film.film_id
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN customer ON rental.customer_id = customer.customer_id
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
GROUP BY category.name, country.country
ORDER BY total_rentals DESC


#10. SHOW THE FAVORITE CATEGORY in India country?

SELECT 
	country,
	category.name AS category_name,
    COUNT(rental.rental_id) AS total_rentals
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN film ON film_category.film_id = film.film_id
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN customer ON rental.customer_id = customer.customer_id
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
WHERE country = 'India'
GROUP BY category.name, country.country
ORDER BY total_rentals DESC
