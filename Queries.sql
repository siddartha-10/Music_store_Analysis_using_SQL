/* QUESTION -1 EASY SET

1) who is the senior most employee based on the title
ans) in the employee table we can see that there is level column the max the level he is 
senior most employee.
*/

SELECT * FROM employee
order by levels DESC
LIMIT 1;


/*  2) which countries have the most invoices
 ans) I can see that there is an invoice table in the dataset
 since question says most invoices we have to use count function along with 
 group by according to the country */
 
SELECT COUNT(*) AS most_invoices,billing_country
FROM invoice
GROUP BY billing_country
ORDER BY most_invoices DESC;


/*
3) what are	top 3 values of total invoices
ans) so we have total column that has invoice bills or totals
Since we need the top 3 values we can use the order by total DESC and limit to 3 
*/
SELECT total 
FROM invoice
ORDER BY total DESC
limit 3;

/*
4) Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals

ans) ONE WAY OF SOLVING:-We have customer table and for the total sum of invoices we can use the invoice table
we have customer_id in both the tables so we can inner join on the customer_id column overthinked this

SECOND SOL(BEST):- SELECT billing_city, SUM(total) as bill from invoice group by billing_city
ORDER BY bill DESC
LIMIT 1;
*/

-- first solution
SELECT c.city, SUM(i.total) as total_bill
FROM customer AS c
INNER JOIN invoice AS i
ON c.customer_id = i.customer_id
GROUP BY c.city
ORDER BY total_bill DESC
LIMIT 1;

-- second solution
SELECT billing_city, SUM(total) as bill from invoice group by billing_city
ORDER BY bill DESC
LIMIT 1;


/*
5) Who is the best customer? 
The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money

ans)
*/

/* This will only return the customer id who made the maximum bill
SELECT customer_id, SUM(total) as total_bill
FROM invoice
GROUP BY customer_id
ORDER BY total_bill DESC;*/

/*This will return name of the customer who spend the most money*/
SELECT first_name || ' ' || last_name AS full_name, SUM(i.total) as total_bill, c.customer_id
FROM customer AS c
INNER JOIN invoice AS i
on c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_bill DESC;

/*
6) Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A

ans) so we have to use the customer table to get email, first name, last name
to find the rcok music we have the genre table from there name contains the which genre the music is

so to join customer and genere we have to join
customer-> invoice-> invoiceLine-> Track-> Genre
*/

SELECT DISTINCT(c.email), c.first_name, c.last_name
FROM customer AS c
INNER JOIN invoice AS i ON c.customer_id = i.customer_id
INNER JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
INNER JOIN track ON track.track_id = il.track_id
INNER JOIN genre AS g ON track.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email;


/*
7) Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands

ans) artist->album->track->genre
*/

select a.name, COUNT(a.artist_id) as total_tracks
from artist AS a
INNER JOIN album AS ab ON a.artist_id = ab.artist_id
INNER JOIN track AS t ON ab.album_id = t.album_id
INNER JOIN genre AS g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY a.name
order by total_tracks DESC
LIMIT 10;


/*
8) Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
ans) Tracks-> we have song length as milliseconds name is also in milliseconds
*/

SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;


/*
9) Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent

ans) Here we need to use cutomer table and aritist table
customer table join with invoice-> invoiceline-> track-> album-> artist
*/
SELECT c.first_name || ' ' || c.last_name AS full_name, at.name, SUM(il.quantity*il.unit_price) AS total_price
FROM customer AS c
INNER JOIN invoice AS i ON c.customer_id = i.customer_id
INNER JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
INNER JOIN track AS t ON il.track_id =t.track_id
INNER JOIN album AS al on t.album_id = al.album_id
INNER JOIN artist AS at ON al.artist_id = at.artist_id
GROUP BY full_name,at.name
ORDER BY total_price DESC;


/*
10) We want to find out the most popular music Genre for each country.
We determine the most popular genre as the genre with the highest amount of purchases. 
Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres

ans) 
*/

WITH popular_genre AS(
	SELECT i.billing_country AS country, g.name AS genre_name,COUNT(g.name) AS top_genre,
	DENSE_RANK() OVER(PARTITION BY i.billing_country ORDER BY COUNT(g.name) DESC) AS rank_number
	FROM invoice As i
	INNER JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
	INNER JOIN track AS t ON il.track_id = t.track_id
	INNER JOIN genre AS g ON t.genre_id = g.genre_id
	GROUP BY country,genre_name
	ORDER BY country
)

SELECT pg.country, pg.genre_name, pg.top_genre 
FROM popular_genre AS pg
WHERE pg.rank_number <=1;


/*
11) Write a query that determines the customer that has spent the most on music foreach country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount

ans) we have the countries in invoice table customer data in customer table
group by customer id, country
order by 
*/


WITH most_spent AS (
	SELECT c.customer_id, c.first_name || ' ' || c.last_name AS full_name, i.billing_country AS country,
	SUM(i.total) AS total_spent
	FROM customer AS c
	INNER JOIN invoice AS i
	ON c.customer_id = i.customer_id
	GROUP BY c.customer_id, i.billing_country
	ORDER BY full_name
)

SELECT * FROM most_spent;




