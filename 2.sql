/*2.1.1*/
CREATE TABLE author (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    name_author VARCHAR(50)
)

/*2.1.2*/
INSERT INTO author (author_id ,name_author) 
VALUES (1, "Булгаков М.А."), 
(2, "Достоевский Ф.М."), 
(3, "Есенин С.А."), 
(4, "Пастернак Б.Л.");

/*2.1.3*/
CREATE TABLE book(
    book_id INT PRIMARY KEY AUTO_INCREMENT, 
    title VARCHAR(50),
	author_id INT NOT NULL,
    
    genre_id int,
    
	price DECIMAL(8,2),
	amount INT,
	foreign key (genre_id) references genre (genre_id),
    foreign key (author_id) references author (author_id)
);
SHOW COLUMNS FROM book;

/*2.1.4*/
CREATE TABLE book(
    book_id INT PRIMARY KEY AUTO_INCREMENT, 
    title VARCHAR(50),
	author_id INT NOT NULL,
    
    genre_id int,
    
	price DECIMAL(8,2),
	amount INT,
	foreign key (genre_id) references genre (genre_id) ON DELETE SET NULL,
    foreign key (author_id) references author (author_id) ON DELETE CASCADE
);
SHOW COLUMNS FROM book;

/*2.1.5*/
INSERT INTO book (book_id,title, author_id, genre_id, price, amount) 
VALUES (6, "Стихотворения и поэмы", 3, 2, 650.00, 15), 
       (7, "Черный человек", 3, 2, 570.20, 6), 
       (8, "Лирика", 4, 2, 518.99, 2);
       
SELECT * FROM book;

/*2.2.1*/
SELECT title, name_genre, price 
FROM book INNER JOIN genre ON genre.genre_id = book.genre_id
WHERE amount > 8
ORDER BY price DESC;

/*2.2.2*/
SELECT name_genre FROM genre
    LEFT JOIN book ON genre.genre_id = book.genre_id
WHERE amount IS NULL;

/*2.2.3*/
SELECT name_city, name_author, 
DATE_ADD("2020-02-02", INTERVAL (FLOOR(RAND() * 365)) DAY) AS Дата 
FROM city 
	CROSS JOIN author 
ORDER BY name_city, Дата DESC;

/*2.2.4*/
SELECT name_genre, title, name_author 
FROM genre 
	INNER JOIN book ON genre.genre_id = book.genre_id 
    INNER JOIN author ON author.author_id = book.author_id 
WHERE name_genre LIKE ("%Роман%") 
ORDER BY title;

/*2.2.5*/
SELECT name_author, SUM(amount) AS Количество FROM author 
	LEFT JOIN book ON author.author_id = book.author_id 
GROUP BY name_author 
HAVING SUM(amount) is NULL or SUM(amount) < 10
ORDER BY Количество;

/*2.2.6*/
SELECT name_author FROM
    (SELECT name_author, name_genre FROM genre 
		INNER JOIN book ON genre.genre_id = book.genre_id 
        INNER JOIN author ON author.author_id = book.author_id
	) as a
GROUP BY name_author 
HAVING COUNT(DISTINCT name_genre) = 1; 

/*2.2.7*/
SELECT title, name_author, name_genre, price, amount FROM author as a
	INNER JOIN book as b ON a.author_id = b.author_id 
    INNER JOIN genre as g ON g.genre_id = b.genre_id 
WHERE b.genre_id IN (
    SELECT genre_id FROM book GROUP BY genre_id HAVING SUM(amount) = 
	(SELECT MAX(sums) AS max_sum FROM (
	SELECT SUM(amount) AS sums FROM book GROUP BY genre_id
	)as c))
ORDER BY title;

/*2.2.8*/
SELECT b.title AS Название, name_author AS Автор,
(b.amount + s.amount) AS Количество 
FROM author as a
	INNER JOIN book as b USING(author_id) 
    INNER JOIN supply as s ON s.title = b.title 
	AND s.author = a.name_author 
	AND s.price = b.price;

/*2.3.1*/
UPDATE book 
	INNER JOIN author ON book.author_id = author.author_id 
    INNER JOIN supply ON book.title = supply.title 
								AND author.name_author = supply.author 
SET book.amount = book.amount + supply.amount,
	supply.amount = 0,
    book.price = ((book.price * book.amount) + (supply.amount * supply.price)) / (book.amount + supply.amount) 
WHERE book.price <> supply.price;
SELECT * FROM book;
SELECT * FROM supply;

/*2.3.2*/
INSERT INTO author (name_author) 
(SELECT supply.author FROM author 
	RIGHT JOIN supply ON author.name_author =  supply.author
WHERE author.name_author IS NULL);
SELECT * FROM author;

/*2.3.3*/
INSERT INTO book (genre_id, title, author_id, price, amount) 
(SELECT NULL, title, author_id, price, amount 
FROM author 
	INNER JOIN supply ON author.name_author = supply.author 
WHERE amount <> 0);
SELECT * FROM book;

/*2.3.4*/
UPDATE book 
SET genre_id = 
(
SELECT genre_id
FROM genre 
WHERE name_genre = "Поэзия"
) 
WHERE title = "Стихотворения и поэмы" AND author_id = 5;


UPDATE book 
SET genre_id =
(
SELECT genre_id 
FROM genre 
WHERE name_genre = "Приключения"
) 
WHERE title = "Остров сокровищ" AND author_id = 6;

SELECT * FROM book;

/*2.3.5*/
DELETE FROM author 
WHERE author_id IN 
(SELECT author_id 
FROM book 
GROUP BY author_id 
HAVING SUM(amount) < 20);

SELECT * FROM author;
SELECT * FROM book;

/*2.3.6*/
DELETE FROM genre 
WHERE genre_id IN 
	(SELECT genre_id 
    FROM book 
    GROUP BY book.genre_id 
    HAVING COUNT(amount) < 4);
SELECT * FROM genre;
SELECT * FROM book;

/*2.3.7*/
DELETE FROM author 
USING author 
	INNER JOIN book ON author.author_id = book.author_id 
    INNER JOIN genre ON genre.genre_id = book.genre_id 
WHERE name_genre = "Поэзия";
SELECT * FROM author;
SELECT * FROM book;

/*2.4.1*/
SELECT buy.buy_id, book.title, book.price, buy_book.amount 
FROM client 
	INNER JOIN buy ON client.client_id = buy.client_id 
    INNER JOIN buy_book ON  buy_book.buy_id = buy.buy_id
    INNER JOIN book ON buy_book.book_id = book.book_id 
WHERE client.name_client = "Баранов Павел" 
ORDER BY buy.buy_id, book.title;

/*2.4.2*/
SELECT name_author, title, COUNT(buy_book.book_id) AS Количество 
FROM author 
	INNER JOIN book ON author.author_id = book.author_id 
	LEFT JOIN buy_book ON book.book_id = buy_book.book_id 
GROUP BY name_author, title 
ORDER BY author.name_author, book.title;

/*2.4.3*/
SELECT name_city, COUNT(buy_id) AS Количество FROM city 
INNER JOIN client ON city.city_id = client.city_id 
INNER JOIN buy ON client.client_id = buy.client_id 
GROUP BY name_city 
ORDER BY COUNT(buy_id) DESC, name_city;

/*2.4.4*/
SELECT buy_id, date_step_end FROM step 
INNER JOIN buy_step ON step.step_id = buy_step.step_id 
WHERE buy_step.step_id = 1 AND date_step_end IS NOT NULL;

/*2.4.5*/
SELECT buy_book.buy_id, name_client, SUM(buy_book.amount * book.price) AS Стоимость 
FROM client 
INNER JOIN buy ON client.client_id = buy.client_id
INNER JOIN buy_book ON buy.buy_id = buy_book.buy_id
INNER JOIN book ON buy_book.book_id = book.book_id
GROUP BY buy_book.buy_id 
ORDER BY buy_book.buy_id;

/*2.4.6*/
SELECT buy_id, name_step FROM step 
INNER JOIN buy_step ON step.step_id = buy_step.step_id
WHERE date_step_end IS NULL 
AND date_step_beg IS NOT NULL 
ORDER BY buy_id;

/*2.4.7*/
SELECT buy.buy_id, DATEDIFF(date_step_end, date_step_beg) AS Количество_дней, 
IF(
DATEDIFF(date_step_end, date_step_beg) > city.days_delivery, 
DATEDIFF(date_step_end, date_step_beg) - city.days_delivery, 0
)AS Опоздание 
FROM city 
INNER JOIN client ON city.city_id = client.city_id 
INNER JOIN buy ON client.client_id = buy.client_id
INNER JOIN buy_step ON buy.buy_id = buy_step.buy_id
INNER JOIN step ON buy_step.step_id = step.step_id
WHERE buy_step.step_id = 3 
AND DATEDIFF(date_step_end, date_step_beg) IS NOT NULL;

/*2.4.8*/
SELECT name_client FROM author 
JOIN book ON author.author_id = book.author_id
INNER JOIN buy_book ON book.book_id = buy_book.book_id
INNER JOIN buy ON buy_book.buy_id = buy.buy_id
INNER JOIN client ON buy.client_id = client.client_id
WHERE name_author LIKE '%Достоевский%'
ORDER BY name_client;

/*2.4.9*/
SELECT ANY_VALUE(name_genre) AS name_genre, MAX(Количество) AS Количество 
FROM(SELECT name_genre, SUM(buy_book.amount) AS Количество FROM genre 
INNER JOIN book ON genre.genre_id = book.genre_id
INNER JOIN buy_book ON book.book_id = buy_book.book_id
GROUP BY name_genre) as a;

/*2.4.10*/
SELECT ANY_VALUE(YEAR(date_payment)) AS Год,
ANY_VALUE(MONTHNAME(date_payment)) AS Месяц,
ANY_VALUE(SUM(price * amount)) AS Сумма
FROM buy_archive 
GROUP BY MONTH(date_payment)
UNION ALL
SELECT ANY_VALUE(YEAR(date_step_end)) AS Год,
ANY_VALUE(MONTHNAME(date_step_end)) AS Месяц,
ANY_VALUE(SUM(book.price * buy_book.amount))
FROM book 
INNER JOIN buy_book ON book.book_id = buy_book.book_id
INNER JOIN buy ON buy_book.buy_id = buy.buy_id
INNER JOIN buy_step ON buy.buy_id = buy_step.buy_id
WHERE date_step_end IS NOT NULL 
AND step_id = 1
GROUP BY MONTH(date_step_end)
ORDER BY Месяц, Год;

/*2.4.11*/
SELECT ANY_VALUE(title) AS title,
ANY_VALUE(SUM(Количество)) AS Количество,
ANY_VALUE(SUM(Сумма)) AS Сумма
FROM (
SELECT title, buy_archive.amount AS Количество,
(buy_archive.amount * buy_archive.price) AS Сумма,
YEAR(date_payment)
FROM buy_archive 
INNER JOIN book ON buy_archive.book_id = book.book_id
UNION ALL
SELECT book.title, buy_book.amount, (buy_book.amount * book.price), YEAR(date_step_end)
FROM book 
INNER JOIN buy_book ON book.book_id = buy_book.book_id
INNER JOIN buy ON buy_book.buy_id = buy.buy_id
INNER JOIN buy_step ON buy.buy_id = buy_step.buy_id
WHERE date_step_end IS NOT NULL 
AND step_id = 1
) AS a
GROUP BY title
ORDER BY Сумма DESC;

/*2.5.1*/
INSERT INTO client (name_client, city_id, email)
SELECT "Попов Илья", city_id, "popov@test"
FROM city 
WHERE city_id = 1;
SELECT * FROM client;

/*2.5.2*/
INSERT INTO buy (buy_description, client_id)
SELECT "Связаться со мной по вопросу доставки", client_id
FROM client 
WHERE name_client = "Попов Илья";
SELECT * FROM buy;

/*2.5.3*/
INSERT INTO buy_book (buy_id, book_id, amount)
SELECT 5, book_id, 2 FROM author 
INNER JOIN book ON author.author_id = book.author_id
WHERE name_author = "Пастернак Б.Л." 
and book.title = "Лирика";

INSERT INTO buy_book (buy_id, book_id, amount)
SELECT 5, book_id, 1 FROM author 
INNER JOIN book ON author.author_id = book.author_id
WHERE name_author = "Булгаков М.А." 
and book.title = "Белая гвардия";

SELECT * FROM buy_book;

/*2.5.4*/
UPDATE book 
INNER JOIN buy_book ON book.book_id = buy_book.book_id
SET book.amount = book.amount - buy_book.amount
WHERE book.book_id = buy_book.book_id 
AND buy_book.buy_id = 5;

SELECT * FROM book;

/*2.5.5*/
CREATE TABLE buy_pay 
AS SELECT title, name_author, price, buy_book.amount,
(price * buy_book.amount) AS Стоимость
FROM author 
INNER JOIN book ON author.author_id = book.author_id
INNER JOIN buy_book ON book.book_id = buy_book.book_id
WHERE buy_id = 5;

SELECT * FROM buy_pay
order by title;

/*2.5.6*/
CREATE TABLE buy_pay 
AS SELECT buy_id,
SUM(buy_book.amount) AS Количество,
SUM(price * buy_book.amount) AS Итого
FROM book
INNER JOIN buy_book ON book.book_id = buy_book.book_id
WHERE buy_id = 5
GROUP BY buy_id;

SELECT * FROM buy_pay;

/*2.5.7*/
INSERT INTO buy_step (buy_id, step_id, date_step_beg, date_step_end)
SELECT buy.buy_id, step_id, null, null
FROM buy 
CROSS JOIN step
WHERE buy.buy_id = 5;

SELECT * FROM buy_step;

/*2.5.8*/
UPDATE buy_step 
SET date_step_beg = "2020-04-12"
WHERE buy_id = 5 
AND step_id = (
SELECT step_id FROM step 
WHERE name_step = "Оплата"
);

SELECT * FROM buy_step;

/*2.5.9*/
UPDATE buy_step 
SET date_step_end = "2020-04-13" 
WHERE buy_id = 5 
AND step_id = (
SELECT step_id 
FROM step 
WHERE name_step = "Оплата"
);

UPDATE buy_step
SET date_step_beg = "2020-04-13" 
WHERE buy_id = 5 
AND step_id = (
SELECT step_id + 1 
FROM step 
WHERE name_step = "Оплата"
);

SELECT * FROM buy_step;
