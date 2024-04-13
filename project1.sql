1
SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1
2
SELECT COUNT(*) as c,billing_country FROM invoice
GROUP BY billing_country
ORDER BY c DESC
3
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3
4
SELECT billing_city,SUM(total) as invoice_total  FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1
5
SELECT customer.customer_id,customer.first_name,customer.last_name,SUM(invoice.total) as total
FROM customer
JOIN invoice 
ON customer.customer_id=invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
LIMIT 1
6
-- Q-1) write query to return the email,first name,last name and Genre of all Rock Music listeners.
-- return your listed orderd alphabetically by email starting with a.
SELECT DISTINCT email,first_name,last_name
FROM customer
JOIN invoice 
ON customer.customer_id = invoice.customer_id
JOIN invoice_line
ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre 
	ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;
7
-- Q-2)Let's invite the artists who have written the most rock music in out dataset write a query that
-- returns the Artist name and total track count of the 10 rock bands
SELECT artist.artist_id,artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM artist
JOIN album ON artist.artist_id = album.artist_id
JOIN track ON album.album_id = track.album_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id 
ORDER BY number_of_songs DESC
LIMIT 10
8
-- Q-3)Return all the track names that have a song length longer than the average song length.Return the Name and
-- Milliseconds for each track. Order by the song length ith the longest songs lited first.

SELECT name,milliseconds FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;
9
-- Q-4) Find how much amount spent by each customers on artists? Write a query to return customer name,
-- artist name and total spent
WITH best_selling_artist AS(
	SELECT artist.artist_id,artist.name,SUM(invoice_line.unit_price*invoice_line.quantity) as Total_sales
	FROM artist
	JOIN album ON artist.artist_id = album.artist_id
	JOIN track ON album.album_id = track.album_id
	JOIN invoice_line ON invoice_line.track_id = track.track_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id,c.first_name,c.last_name,bsa.name,SUM(il.unit_price*il.quantity) as amount_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album al ON al.album_id = t.album_id 
JOIN best_selling_artist bsa ON bsa.artist_id = al.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;
10
-- Q-5)
-- We want to find out the most popular music Genre for each country.
-- (we determine the most popular genre as the genre with the heighest amount)
WITH popular_music AS(
SELECT COUNT(il.quantity) as purcase,c.country,g.name,g.genre_id,
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS RowNo
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY 2,3,4
ORDER BY 2 ASC,1 DESC
)
SELECT * FROM popular_music WHERE RowNo <= 1
11
-- Q-6)write a query that determines the custoomer that has spent the most on music for each cuntry.
-- write a query that returns the country along with the top customer and how much they spent.
-- for countries where the top amount spent is shared, provide all customers who spent this amount.
WITH customer_with_country AS(
	SELECT c.customer_id,c.first_name,c.last_name,i.billing_country,SUM(total) AS total_spending,
	ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY SUM(total) DESC) AS Rowno
	FROM customer c
	JOIN invoice i ON c.customer_id = i.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 4 DESC
)
SELECT * FROM customer_with_country WHERE Rowno <= 1


