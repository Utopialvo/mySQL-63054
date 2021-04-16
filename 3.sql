/*3.1.1*/
SELECT name_student, date_attempt, result 
FROM student 
INNER JOIN attempt ON student.student_id = attempt.student_id 
INNER JOIN subject  ON attempt.subject_id = subject.subject_id
WHERE name_subject = "Основы баз данных" 
ORDER BY result DESC;

/*3.1.2*/
SELECT name_subject, COUNT(result) AS Количество,
ROUND(AVG(result), 2) AS Среднее
FROM subject
LEFT JOIN attempt ON subject.subject_id = attempt.subject_id
GROUP BY name_subject;

/*3.1.3*/
SELECT name_student, result 
FROM student 
INNER JOIN attempt ON student.student_id = attempt.student_id
WHERE result = (
SELECT MAX(result) 
FROM attempt
) 
ORDER BY name_student;

/*3.1.4*/
SELECT name_student, 
ANY_VALUE(name_subject) AS name_subject,
ANY_VALUE(DATEDIFF(MAX(date_attempt),MIN(date_attempt))) AS Интервал
FROM student 
INNER JOIN attempt ON student.student_id = attempt.student_id 
INNER JOIN subject ON attempt.subject_id = subject.subject_id
WHERE name_student IN
(
SELECT ANY_VALUE(name_student)
FROM student 
INNER JOIN attempt ON student.student_id = attempt.student_id 
INNER JOIN subject ON attempt.subject_id = subject.subject_id 
GROUP BY name_student 
HAVING COUNT(DISTINCT name_subject) = 1
)
GROUP BY name_student
ORDER BY Интервал;

/*3.1.5*/
SELECT name_subject, COUNT(DISTINCT student_id) AS Количество 
FROM subject 
LEFT JOIN attempt ON subject.subject_id = attempt.subject_id
GROUP BY name_subject 
ORDER BY Количество DESC, name_subject;

/*3.1.6*/
SELECT question_id, name_question 
FROM question 
WHERE subject_id =
(
SELECT subject_id 
FROM subject 
WHERE name_subject = "Основы баз данных"
) 
ORDER BY RAND() LIMIT 3;

/*3.1.7*/
SELECT name_question, name_answer, 
IF(is_correct = 1, "Верно", "Неверно") AS Результат
FROM answer 
INNER JOIN testing ON answer.answer_id = testing.answer_id
INNER JOIN question ON testing.question_id = question.question_id
WHERE attempt_id = 7;

/*3.1.8*/
SELECT name_student, name_subject, date_attempt,
ROUND((SUM(is_correct)/3*100), 2) AS Результат 
FROM answer 
INNER JOIN testing ON answer.answer_id = testing.answer_id 
INNER JOIN attempt ON testing.attempt_id = attempt.attempt_id
INNER JOIN student ON attempt.student_id = student.student_id
INNER JOIN subject ON attempt.subject_id = subject.subject_id
GROUP BY date_attempt, name_student, name_subject 
ORDER BY name_student, date_attempt DESC;

/*3.1.9*/
SELECT ANY_VALUE(name_subject) AS name_subject, 
ANY_VALUE(CONCAT(LEFT(name_question, 30), "...")) AS Вопрос, 
ANY_VALUE(COUNT(testing.question_id)) AS Всего_ответов, 
ANY_VALUE(ROUND(SUM(is_correct)/COUNT(testing.question_id) * 100, 2)) AS Успешность 
FROM question 
INNER JOIN subject USING (subject_id) 
INNER JOIN attempt USING (subject_id) 
RIGHT JOIN testing USING (attempt_id) 
INNER JOIN answer USING (answer_id) 
WHERE testing.question_id = question.question_id 
GROUP BY answer.question_id
ORDER BY name_subject, Успешность DESC, Вопрос;

/*3.2.1*/
INSERT INTO attempt (student_id, subject_id, date_attempt, result) 
VALUES(
(SELECT student_id 
FROM student 
WHERE name_student = "Баранов Павел"), 
(SELECT subject_id 
FROM subject 
WHERE name_subject = "Основы баз данных"), 
NOW(), NULL
);

SELECT * FROM attempt;

/*3.2.2*/
INSERT INTO testing (attempt_id, question_id, answer_id)
(
SELECT(SELECT MAX(attempt_id) + 1 FROM testing), question_id, NULL
FROM question 
WHERE subject_id = (
SELECT DISTINCT subject_id 
FROM attempt 
WHERE student_id = (
SELECT MAX(student_id) 
FROM attempt))
ORDER BY RAND()LIMIT 3
);

SELECT * FROM testing;

/*3.2.3*/
UPDATE attempt SET result = (
SELECT CEILING(SUM(is_correct) / 3 * 100)
FROM testing
INNER JOIN answer ON testing.answer_id = answer.answer_id
WHERE attempt_id = 8
)
WHERE attempt_id = 8;
SELECT * FROM attempt;

/*3.2.4*/
DELETE FROM attempt
WHERE date_attempt < "2020-05-01";

SELECT * FROM attempt;
SELECT * FROM testing;

/*3.3.1*/
SELECT name_enrollee
FROM program 
INNER JOIN program_enrollee ON program.program_id = program_enrollee.program_id
INNER JOIN enrollee ON program_enrollee.enrollee_id = enrollee.enrollee_id
WHERE name_program LIKE "мехатроника и робототехника"
ORDER BY name_enrollee;

/*3.3.2*/
SELECT name_program 
FROM program 
INNER JOIN program_subject ON program.program_id = program_subject.program_id
INNER JOIN subject ON program_subject.subject_id = subject.subject_id
WHERE name_subject LIKE 'Информатика';

/*3.3.3*/
SELECT ANY_VALUE(name_subject) AS name_subject,
COUNT(name_subject) AS Количество,
MAX(result) AS Максимум,
MIN(result) AS Минимум,
ROUND(AVG(result), 1) AS Среднее
FROM subject
INNER JOIN enrollee_subject ON subject.subject_id = enrollee_subject.subject_id
GROUP BY subject.subject_id
ORDER BY name_subject;

/*3.3.4*/
SELECT DISTINCT ANY_VALUE(name_program) AS name_program
FROM program 
INNER JOIN program_subject ON program.program_id = program_subject.program_id
GROUP BY name_program
HAVING MIN(min_result) >= 40
ORDER BY name_program

/*3.3.5*/
SELECT name_program, plan 
FROM program 
WHERE plan = 
(
SELECT MAX(plan)
 FROM program
)

/*3.3.6*/
SELECT name_enrollee, IF(SUM(bonus) IS NULL, 0, SUM(bonus)) AS Бонус 
FROM achievement
INNER JOIN enrollee_achievement ON achievement.achievement_id = enrollee_achievement.achievement_id
RIGHT JOIN enrollee ON enrollee_achievement.enrollee_id = enrollee.enrollee_id
GROUP BY enrollee.enrollee_id
ORDER BY name_enrollee;

/*3.3.7*/
SELECT name_department, name_program, plan,
COUNT(enrollee_id) AS Количество,
ROUND(COUNT(enrollee_id) / plan, 2) AS Конкурс
FROM department
INNER JOIN program ON department.department_id = program.department_id
INNER JOIN program_enrollee ON program.program_id = program_enrollee.program_id
GROUP BY name_department, name_program, plan
ORDER BY Конкурс DESC;

/*3.3.8*/
SELECT ANY_VALUE(name_program) AS name_program
FROM program 
INNER JOIN program_subject ON program.program_id = program_subject.program_id
INNER JOIN subject ON program_subject.subject_id = subject.subject_id
WHERE name_subject = "Информатика" OR "Математика"
GROUP BY name_program
ORDER BY name_program;

/*3.3.9*/
SELECT name_program, name_enrollee, SUM(result) AS itog
FROM enrollee
INNER JOIN program_enrollee ON enrollee.enrollee_id = program_enrollee.enrollee_id
INNER JOIN program ON program_enrollee.program_id = program.program_id
INNER JOIN program_subject ON program.program_id = program_subject.program_id
INNER JOIN subject ON program_subject.subject_id = subject.subject_id
INNER JOIN enrollee_subject ON subject.subject_id = enrollee_subject.subject_id 
AND enrollee_subject.enrollee_id = enrollee.enrollee_id
GROUP BY name_program, name_enrollee
ORDER BY name_program, itog DESC;

/*3.3.10*/
SELECT DISTINCT name_program, name_enrollee FROM enrollee
INNER JOIN program_enrollee ON enrollee.enrollee_id = program_enrollee.enrollee_id
INNER JOIN program ON program_enrollee.program_id = program.program_id
INNER JOIN program_subject ON program.program_id = program_subject.program_id
INNER JOIN subject ON program_subject.subject_id = subject.subject_id
INNER JOIN enrollee_subject ON subject.subject_id = enrollee_subject.subject_id 
AND enrollee_subject.enrollee_id = enrollee.enrollee_id
WHERE result < min_result
ORDER BY name_program, name_enrollee;

/*3.4.1*/
CREATE TABLE applicant AS
(
SELECT program_enrollee.program_id, enrollee.enrollee_id, SUM(result) AS itog
FROM enrollee
INNER JOIN program_enrollee ON enrollee.enrollee_id = program_enrollee.enrollee_id
INNER JOIN program ON program_enrollee.program_id = program.program_id
INNER JOIN program_subject ON program.program_id = program_subject.program_id
INNER JOIN subject ON program_subject.subject_id = subject.subject_id
INNER JOIN enrollee_subject ON subject.subject_id = enrollee_subject.subject_id 
AND enrollee_subject.enrollee_id = enrollee.enrollee_id
GROUP BY program_enrollee.program_id, enrollee.enrollee_id
ORDER BY program_enrollee.program_id, itog DESC
);

SELECT * FROM applicant;

/*3.4.2*/
DELETE FROM applicant WHERE (program_id, enrollee_id) IN 
(
SELECT DISTINCT program_enrollee.program_id, enrollee.enrollee_id
FROM enrollee
INNER JOIN program_enrollee ON enrollee.enrollee_id = program_enrollee.enrollee_id
INNER JOIN program ON program_enrollee.program_id = program.program_id
INNER JOIN program_subject ON program.program_id = program_subject.program_id
INNER JOIN subject ON program_subject.subject_id = subject.subject_id
INNER JOIN enrollee_subject ON subject.subject_id = enrollee_subject.subject_id 
AND enrollee_subject.enrollee_id = enrollee.enrollee_id
WHERE result < min_result
ORDER BY program_enrollee.program_id, enrollee.enrollee_id
);
SELECT * FROM applicant;

/*3.4.3*/
UPDATE applicant 
INNER JOIN (
SELECT enrollee_id, 
IF(SUM(bonus) IS NULL, 0, SUM(bonus)) AS Бонус 
FROM achievement
INNER JOIN enrollee_achievement USING (achievement_id)
RIGHT JOIN enrollee USING (enrollee_id)
GROUP BY enrollee_id
ORDER BY enrollee_id
) AS abc
ON abc.enrollee_id = applicant.enrollee_id 
SET itog = itog+abc.Бонус;

SELECT * FROM applicant;

/*3.4.4*/
CREATE TABLE applicant_order AS
(
SELECT program_id, enrollee_id, itog 
FROM applicant 
ORDER BY program_id, itog DESC
);
DROP TABLE applicant;

SELECT * FROM applicant_order;

/*3.4.5*/
ALTER TABLE applicant_order ADD str_id INT FIRST;

SELECT * FROM applicant_order;

/*3.4.6*/
SET @num_pr = 0;
SET @row_num = 1;
UPDATE applicant_order 
INNER JOIN 
(
SELECT *, if(program_id = @num_pr, @row_num := @row_num + 1, @row_num := 1) AS str_num,
@num_pr := program_id AS add_var 
from applicant_order
) AS abc
ON applicant_order.program_id = abc.program_id 
AND applicant_order.enrollee_id = abc.enrollee_id
SET applicant_order.str_id = abc.str_num;

SELECT * FROM applicant_order;

/*3.4.7*/
CREATE TABLE student AS
SELECT name_program, name_enrollee, itog
FROM program
INNER JOIN applicant_order ON program.program_id = applicant_order.program_id
INNER JOIN enrollee ON applicant_order.enrollee_id = enrollee.enrollee_id
WHERE str_id <= plan
ORDER BY name_program, itog DESC;

SELECT * FROM student;

/*3.5.1*/
SELECT 
CONCAT(LEFT(CONCAT(CONCAT(module_id, " "), module_name), 16), "...") AS Модуль,
CONCAT(LEFT(CONCAT(CONCAT(CONCAT(module_id, "."), CONCAT(lesson_position, " ")), lesson_name), 16), "...") AS Урок,
CONCAT(CONCAT(CONCAT(CONCAT(module_id, "."), CONCAT(lesson_position, ".")), CONCAT(step_position, " ")), step_name) AS Шаг
FROM module
INNER JOIN lesson USING (module_id)
INNER JOIN step USING (lesson_id)
WHERE step_name LIKE "%вложен%запрос%"
ORDER BY module_id, lesson_id, step_id;

/*3.5.2*/
INSERT INTO step_keyword (step_id, keyword_id)
SELECT step_id, keyword_id 
FROM step 
CROSS JOIN keyword
WHERE step.step_name REGEXP (CONCAT('\\b', keyword.keyword_name, '\\b'));
SELECT * FROM step_keyword;

/*3.5.7*/
SELECT student_name AS Студент,
CONCAT(LEFT(step_name, 20), "...") AS Шаг,
result AS Результат,
FROM_UNIXTIME(submission_time) AS Дата_отправки,
SEC_TO_TIME(IFNULL(submission_time - LEAD(submission_time) OVER (ORDER BY submission_time DESC), 0)) AS Разница
FROM student 
INNER JOIN step_student ON student.student_id = step_student.student_id
INNER JOIN step ON step_student.step_id = step.step_id
WHERE student_name LIKE "student_61"
ORDER BY Дата_отправки;

/*3.5.9*/
WITH get_rate_student(mod_id, stud, rate) 
AS
(
   SELECT module_id, student_name,COUNT(DISTINCT step_id)
   FROM student
   INNER JOIN step_student USING (student_id)
   INNER JOIN step USING (step_id)
   INNER JOIN lesson USING (lesson_id)
   WHERE result LIKE "correct"
   GROUP BY module_id, 2
)
SELECT mod_id AS Модуль, stud AS Студент, rate AS Пройдено_шагов, 
ROUND(rate / (MAX(rate) OVER (PARTITION BY mod_id)) * 100, 1) AS Относительный_рейтинг
FROM get_rate_student
ORDER BY Модуль, Относительный_рейтинг DESC, Студент;

