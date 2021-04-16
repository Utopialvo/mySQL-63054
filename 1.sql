/*1.1.1*/
CREATE TABLE book(
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(50),
    author VARCHAR(30),
    price DECIMAL(8,2),
    amount INT
);

/*1.1.2*/
INSERT INTO book (book_id, title, author, price, amount) 
VALUES (1, 'Мастер и Маргарита', 'Булгаков М.А.', 670.99, 3);
SELECT * FROM book;

/*1.1.3*/
INSERT INTO book (book_id, title, author, price, amount)
    VALUES (2, 'Белая гвардия', 'Булгаков М.А.', 540.50, 5);
INSERT INTO book (book_id, title, author, price, amount)
    VALUES (3, 'Идиот', 'Достоевский Ф.М.', 460.00, 10);
INSERT INTO book (book_id, title, author, price, amount)
    VALUES (4, 'Братья Карамазовы', 'Достоевский Ф.М.', 799.01, 2);
SELECT * FROM book;

/*1.2.1*/
SELECT * FROM book;

/*1.2.2*/
SELECT author, title, price FROM book;

/*1.2.3*/
SELECT title as Название, author as Автор FROM book;

/*1.2.4*/
SELECT title, amount, 
    1.65 * amount AS pack 
FROM book;

/*1.2.5*/
SELECT title, author, amount, 
    ROUND(((price/100)*70),2) AS new_price
FROM book;

/*1.2.6*/
SELECT author, title,
   ROUND(if (author = 'Булгаков М.А.', ((price /100)*110), if (author = 'Есенин С.А.', ((price /100)*105), price)), 2) AS new_price
    FROM book;

/*1.2.7*/
SELECT author, title, price FROM book WHERE amount < 10;

/*1.2.8*/
SELECT title, author, price, amount 
FROM book 
WHERE (price < 500 or price > 600) and (price * amount) >= 5000;

/*1.2.9*/
SELECT title, author FROM book
WHERE price BETWEEN 540.50 and 800 and amount in (2,3,5,7);

/*1.2.10*/
SELECT title , author FROM book
WHERE author LIKE "%С.%" and title LIKE "%_ %"

/*1.2.11*/
SELECT author, title FROM book
WHERE amount >=2 and amount <= 14
ORDER BY author DESC, title ASC;

/*1.3.1*/
SELECT DISTINCT amount
FROM book;

/*1.3.2*/
SELECT author as Автор, COUNT(author) as Различных_книг ,SUM(amount) as Количество_экземпляров
FROM book
GROUP BY author;

/*1.3.3*/
SELECT author, MIN(price) as Минимальная_цена, MAX(price) as Максимальная_цена, AVG(price) as Средняя_цена FROM book
GROUP BY author;  

/*1.3.4*/
SELECT author, 
SUM(price * amount) as Стоимость, 
round(((SUM(price * amount)*(18/100))/(1+(18/100))),2) as НДС,
round((SUM(price * amount)/(1 + (18/100))),2) as Стоимость_без_НДС
FROM book

GROUP BY author;

/*1.3.5*/
SELECT MIN(price) as Минимальная_цена, MAX(price) as Максимальная_цена, ROUND(AVG(price),2) as Средняя_цена FROM book;

/*1.3.6*/
SELECT 
ROUND(AVG(price),2) as Средняя_цена,
ROUND(SUM(price * amount),2) as Стоимость
FROM book
WHERE amount BETWEEN 5 and 14;

/*1.3.7*/
SELECT author, 
SUM(price * amount) as Стоимость 
FROM book
WHERE title != "Идиот" or "Белая гвардия"
GROUP BY author
HAVING SUM(price * amount) > 5000
ORDER BY SUM(price * amount) DESC;

/*1.4.1*/
SELECT author, title, price FROM book
WHERE price <= (
    SELECT AVG(price) FROM book
) ORDER BY price DESC;

/*1.4.2*/
SELECT author, title, price FROM book
WHERE price <= 150 + (SELECT MIN(price) FROM book)
ORDER BY price;

/*1.4.3*/
SELECT author, title, amount FROM book
WHERE amount IN (SELECT amount FROM book
                GROUP BY amount
                HAVING COUNT(amount)=1
               );

/*1.4.4*/
SELECT author, title, price FROM book
WHERE price < ANY ( SELECT MIN(price)
               FROM book
               GROUP BY author
);

/*1.4.5*/
SELECT title, author, amount,(
SELECT MAX(amount) FROM book
) - amount as Заказ
FROM book
WHERE amount not in(SELECT MAX(amount) FROM book
)

/*1.5.1*/
CREATE TABLE supply(
    supply_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(50),
    author VARCHAR(30),
    price DECIMAL(8, 2),
    amount INT
);

/*1.5.2*/
INSERT INTO supply(supply_id, title, author, price, amount) 
VALUES (1, "Лирика", 'Пастернак Б.Л.', 518.99, 2),
(2, "Черный человек", 'Есенин С.А.', 570.20, 6),
(3,"Белая гвардия","Булгаков М.А.",540.50,7),
(4,"Идиот","Достоевский Ф.М.",360.80,3);

/*1.5.3*/
INSERT INTO book (title, author, price, amount) 
SELECT title, author, price, amount 
FROM supply
WHERE author NOT IN ("Булгаков М.А.", "Достоевский Ф.М.");

SELECT * FROM book;

/*1.5.4*/
INSERT INTO book (title, author, price, amount) 
SELECT title, author, price, amount 
FROM supply
WHERE author NOT IN (
        SELECT author 
        FROM book
      );

SELECT * FROM book;

/*1.5.5*/
UPDATE book 
SET price = 0.9 * price
WHERE amount BETWEEN 5 and 10;

SELECT * FROM book;

/*1.5.6*/
UPDATE book 
SET buy=amount
WHERE buy > amount;
UPDATE book
SET price=price*0.9
WHERE buy=0;

SELECT * FROM book;

/*1.5.7*/
UPDATE book, supply 
SET book.amount = book.amount + supply.amount, book.price = (book.price + supply.price) / 2
WHERE book.title = supply.title AND book.author = supply.author;

SELECT * FROM book;

/*1.5.8*/
DELETE FROM
    supply
WHERE author IN 
    (SELECT author
     FROM book
     GROUP BY author
     HAVING sum(amount) > 10);

SELECT * FROM supply;

/*1.5.9*/
CREATE TABLE ordering AS
SELECT author, title, 
   (
    SELECT ROUND(AVG(amount)) 
    FROM book
   ) AS amount
FROM book
WHERE amount < 7;

SELECT * FROM ordering;

/*1.6.1*/
SELECT name, city, per_diem, date_first, date_last FROM trip
WHERE name LIKE "%а %.%"
ORDER BY date_last DESC;

/*1.6.2*/
SELECT distinct name FROM trip
WHERE city LIKE "Москва"
ORDER BY name;

/*1.6.3*/
SELECT city, COUNT(city) as Количество FROM trip
GROUP BY city
ORDER BY city;

/*1.6.4*/
SELECT city, COUNT(city) as Количество
FROM trip
GROUP BY city
ORDER BY COUNT(city) DESC 
LIMIT 2;

/*1.6.5*/
SELECT name, city, (DATEDIFF(date_last, date_first)+1) as Длительность 
FROM trip
WHERE city != "Москва" and city !=  "Санкт-Петербург" 
ORDER BY (DATEDIFF(date_first, date_last)+1) ASC, city DESC;

/*1.6.6*/
SELECT name, city, date_first, date_last FROM trip
WHERE (DATEDIFF(date_last, date_first)+1) = (SELECT MIN(DATEDIFF(date_last, date_first)+1) FROM trip
      );
	  
/*1.6.7*/
SELECT name, city, date_first, date_last FROM trip
WHERE MONTH(date_first) = MONTH(date_last)
ORDER BY city, name;

/*1.6.8*/
SELECT MONTHNAME(date_first) as Месяц,
COUNT(MONTHNAME(date_first)) as Количество
FROM trip
GROUP BY MONTHNAME(date_first)
ORDER BY Количество DESC, Месяц ASC;

/*1.6.9*/
SELECT name, city , date_first, (DATEDIFF(date_last, date_first)+1)*per_diem as Сумма FROM trip
WHERE YEAR(date_first) = 2020 and MONTH(date_first) IN (2,3)
order by name asc, Сумма desc;

/*1.6.10*/
select name, sum((datediff(date_last, date_first)+1)*per_diem) as Сумма
from trip
group by name
having count(*) > 3
order by Сумма DESC;


/*1.7.1*/
CREATE TABLE fine(
    fine_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(30),
    number_plate VARCHAR(6),
    violation VARCHAR(50),
    sum_fine DECIMAL(8, 2),
    date_violation   DATE,
    date_payment DATE
);

/*1.7.2*/
INSERT INTO fine(name, number_plate, violation, sum_fine, date_violation,date_payment) 
VALUES ('Баранов П.Е.', 'Р523ВТ', 'Превышение скорости(от 40 до 60)', null, '2020-02-14 ', null),
('Абрамова К.А.', 'О111АВ', 'Проезд на запрещающий сигнал', null, '2020-02-23', null),
('Яковлев Г.Р.', 'Т330ТТ', 'Проезд на запрещающий сигнал', null, '2020-03-03', null);

/*1.7.3*/
UPDATE fine AS f, traffic_violation AS tv
    SET f.sum_fine=IF(f.sum_fine is Null,
                  (SELECT sum_fine FROM traffic_violation tv WHERE f.violation=tv.violation),
                  f.sum_fine);
SELECT * FROM fine;

/*1.7.4*/
SELECT name,  number_plate,  violation FROM fine
group by 1,2,3 
HAVING COUNT(number_plate) >= 2
order by 1,2,3

/*1.7.5*/
UPDATE fine AS f, fine as a
SET f.sum_fine=f.sum_fine*2 
WHERE f.name = a.name
   AND a.date_violation != f.date_violation 
   AND f.violation = a.violation
   AND f.number_plate = a.number_plate 
   AND f.date_payment IS Null;

SELECT * FROM fine;

/*1.7.6*/
UPDATE 
    fine f, payment p 
SET 
    f.date_payment = p.date_payment, 
    f.sum_fine = IF(
                    DATEDIFF(p.date_payment, f.date_violation) <= 20, f.sum_fine/2, f.sum_fine
                   ) 
WHERE f.name = p.name 
    AND f.number_plate = p.number_plate 
    AND f.violation = p.violation 
    AND f.date_violation = p.date_violation
    AND f.date_payment is null;
    
SELECT * FROM fine;

/*1.7.7*/
CREATE TABLE back_payment AS 
(SELECT name, number_plate, violation, sum_fine, date_violation 
FROM fine 
WHERE date_payment IS NULL);


SELECT * FROM back_payment;

/*1.7.8*/
DELETE FROM fine
WHERE date_violation < "2020-02-01";
SELECT * FROM fine;
