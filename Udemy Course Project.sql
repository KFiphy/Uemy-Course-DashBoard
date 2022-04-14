USE Projects;

--Confirming imported tables

SELECT* FROM ['Bussiness Coure$']

SELECT * FROM MusicCourses

SELECT * FROM	GraphicCourses

SELECT * FROM	WebCourses


--Appending all data from different courses into a single table.

WITH allcourse AS (
                  SELECT * FROM ['Bussiness Coure$'] WHERE course_id IS NOT NULL
                      UNION
                  SELECT * FROM MusicCourses WHERE course_id IS NOT NULL
                                  UNION
                  SELECT * FROM GraphicCourses WHERE course_id IS NOT NULL
                                                     UNION
                 SELECT * FROM WebCourses WHERE course_id IS NOT NULL)

SELECT * INTO Udemy_Courses FROM allcourse

---ProofChecking
SELECT * FROM Udemy_Courses


--Seperating date from timestamp in the published_timestamp column.

SELECT published_timestamp, 
SUBSTRING(published_timestamp,1, CHARINDEX('T',published_timestamp)-1) 
FROM Udemy_Courses

---Converting it to date format.

SELECT published_timestamp, 
CONVERT(DATE, SUBSTRING(published_timestamp,1, CHARINDEX('T',published_timestamp)-1))
FROM Udemy_Courses

--Updating the affected column in the existing table.

UPDATE Udemy_Courses
SET published_timestamp = CONVERT(DATE, SUBSTRING(published_timestamp,1, CHARINDEX('T',published_timestamp)-1))

UPDATE Udemy_Courses
     SET date = CONVERT(DATE, date)


--- I want to rename Subject: Web Development to only the subject name like others

SELECT subject ,CASE WHEN subject = 'Graphic Design' THEN 'Graphic Design' 
WHEN subject = 'Subject: Web Development' THEN 'Web Development' 
WHEN subject = 'Musical Instruments' THEN 'Musical Instruments' ELSE 'Business Finance'
END AS realCase FROM Udemy_Courses

UPDATE Udemy_Courses
SET subject = CASE WHEN subject = 'Graphic Design' THEN 'Graphic Design' WHEN subject = 'Subject: Web Development' 
THEN 'Web Development' WHEN subject = 'Musical Instruments' 
THEN 'Musical Instruments' ELSE 'Business Finance' END


---Adding a column to identify paid and free courses using Case
SELECT PRICE, CASE WHEN price = 0 THEN 'Free' ELSE 
'Paid' END AS payment_status FROM Udemy_Courses

ALTER TABLE Udemy_Courses
ADD payment_status NVARCHAR(20)

UPDATE Udemy_Courses
SET payment_status = CASE WHEN price = 0 THEN 'Free' ELSE 'Paid' END



-------------------ANALYSIS---------------
--Calculating the revenue and adding new column for it.

SELECT price, num_subscribers, (PRICE * num_subscribers) AS REVENUE FROM Udemy_Courses

ALTER TABLE Udemy_Courses
ADD Revenue float

UPDATE Udemy_Courses
SET Revenue = (PRICE * num_subscribers)


--View total revenue

SELECT SUM(Revenue) AS Revenue_Sum FROM Udemy_Courses

--View total number of subscribers

SELECT SUM(num_subscribers) FROM Udemy_Courses

--View the average review rating

SELECT ROUND(AVG(Rating), 2) AS average_rating FROM Udemy_Courses

--View number of courses

SELECT COUNT(DISTINCT course_title) AS Num_of_Courses FROM Udemy_Courses

--View number of subjects

SELECT COUNT(DISTINCT subject) AS Total_Subject FROM Udemy_Courses



--View Revenue generated by each Subject

SELECT subject, SUM(Revenue) AS Total_Revenue
FROM Udemy_Courses GROUP BY subject

--View top 10 course by revenue

SELECT DISTINCT TOP 10 course_title, Revenue 
FROM Udemy_Courses ORDER BY 2 DESC;


--View  bottom 5 course title by review rating

SELECT DISTINCT TOP 5 course_title, SUM(Rating) FROM Udemy_Courses 
GROUP BY course_title ORDER BY 2 ASC

--View the occurrence of each level of learners in the dataset

SELECT level, COUNT(*) FROM Udemy_Courses GROUP BY level

--Comparing how number of subscribers of each level affects revenue by payment or free

SELECT level ,subject, SUM(num_subscribers) subscriber_per_level, 
SUM(Revenue) revenue_by_level, payment_status FROM Udemy_Courses 
GROUP BY level, payment_status, subject

--Viewing count of free and paid course

SELECT  DISTINCT Payment_status,  COUNT(*) AS countofpaymentstatus 
FROM Udemy_Courses GROUP BY payment_status

---Viewing number of paid and free subject

SELECT subject, payment_status, COUNT(payment_status) 
FROM Udemy_Courses GROUP BY subject,payment_status



                            -------Time Analysis--------------
--Viewing revenue generated for months of all years in total

SELECT MONTH(date) AS date, SUM(Revenue) 
FROM Udemy_Courses GROUP BY MONTH(date) ORDER BY date ASC;

--Viewing Revenue generated across all years

SELECT YEAR(date) AS date, SUM(Revenue) 
FROM Udemy_Courses GROUP BY YEAR(date) ORDER BY date ASC;


--Viewing Month on Month Variance from the first day of course study.

WITH VARIANCE AS (SELECT date, MONTH(date) AS CourseDate, Revenue,
LAG(Revenue) OVER (ORDER BY date) AS previous_revenue, 
(Revenue - LAG(Revenue) OVER (ORDER BY date)) AS MOM_variance FROM Udemy_Courses)


SELECT *, ROUND((MOM_variance /(previous_revenue)),0) * 100 AS percentageMOMvar FROM VARIANCE
WHERE previous_revenue <> 0 ORDER BY MONTH(date)



