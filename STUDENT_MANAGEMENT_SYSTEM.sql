

create database STUDENT_MANAGEMENT_SYSTEM

USE  STUDENT_MANAGEMENT_SYSTEM;


-- STUDENT MANAGEMENT SYSTEM: FULL SQL SCRIPT FOR MS SQL

-- Drop tables if they exist (order matters due to FK constraints)
IF OBJECT_ID('Grades', 'U') IS NOT NULL DROP TABLE Grades;
IF OBJECT_ID('Enrollments', 'U') IS NOT NULL DROP TABLE Enrollments;
IF OBJECT_ID('Courses', 'U') IS NOT NULL DROP TABLE Courses;
IF OBJECT_ID('Instructors', 'U') IS NOT NULL DROP TABLE Instructors;
IF OBJECT_ID('Students', 'U') IS NOT NULL DROP TABLE Students;

-- 1. Students Table
CREATE TABLE Students (
    student_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    dob DATE,
    email NVARCHAR(100) UNIQUE,
    phone NVARCHAR(20),
    address NVARCHAR(255)
);

-- 2. Instructors Table
CREATE TABLE Instructors (
    instructor_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    email NVARCHAR(100) UNIQUE,
    department NVARCHAR(50)
);

-- 3. Courses Table
CREATE TABLE Courses (
    course_id INT IDENTITY(1,1) PRIMARY KEY,
    course_name NVARCHAR(100) NOT NULL,
    credits INT,
    instructor_id INT,
    FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)
);

-- 4. Enrollments Table
CREATE TABLE Enrollments (
    enrollment_id INT IDENTITY(1,1) PRIMARY KEY,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- 5. Grades Table
CREATE TABLE Grades (
    grade_id INT IDENTITY(1,1) PRIMARY KEY,
    enrollment_id INT,
    grade NVARCHAR(2),
    FOREIGN KEY (enrollment_id) REFERENCES Enrollments(enrollment_id)
);

-- ---------------------------------------------------------
-- INSERT SAMPLE DATA
-- ---------------------------------------------------------

-- Students
INSERT INTO Students (first_name, last_name, dob, email, phone, address) VALUES
(N'John', N'Doe', '2003-04-15', N'john.doe@email.com', N'1234567890', N'123 Maple St'),
(N'Jane', N'Smith', '2002-09-30', N'jane.smith@email.com', N'2345678901', N'456 Oak Ave'),
(N'Mike', N'Johnson', '2004-01-22', N'mike.johnson@email.com', N'3456789012', N'789 Pine Rd');

-- Instructors
INSERT INTO Instructors (first_name, last_name, email, department) VALUES
(N'Alice', N'Williams', N'alice.williams@email.com', N'Mathematics'),
(N'Bob', N'Brown', N'bob.brown@email.com', N'Computer Science');

-- Courses
INSERT INTO Courses (course_name, credits, instructor_id) VALUES
(N'Calculus I', 4, 1),
(N'Introduction to Programming', 3, 2),
(N'Data Structures', 3, 2);

-- Enrollments
INSERT INTO Enrollments (student_id, course_id, enrollment_date) VALUES
(1, 1, '2024-08-01'),
(1, 2, '2024-08-01'),
(2, 1, '2024-08-01'),
(2, 3, '2024-08-01'),
(3, 2, '2024-08-01');

-- Grades
INSERT INTO Grades (enrollment_id, grade) VALUES
(1, N'A'),
(2, N'B+'),
(3, N'B'),
(4, N'A-'),
(5, N'C+');

-- ---------------------------------------------------------
-- SAMPLE QUERIES (UNCOMMENT TO USE)
-- ---------------------------------------------------------
-- -- 1. List all students enrolled in "Calculus I"
 SELECT S.first_name, S.last_name
 FROM Students S
 JOIN Enrollments E ON S.student_id = E.student_id
 JOIN Courses C ON E.course_id = C.course_id
 WHERE C.course_name = 'Calculus I';

-- -- 2. List all courses for student "John Doe"
 SELECT C.course_name
 FROM Courses C
 JOIN Enrollments E ON C.course_id = E.course_id
 JOIN Students S ON E.student_id = S.student_id
 WHERE S.first_name = 'John' AND S.last_name = 'Doe';

-- -- 4. List all students with their grades in each course
 SELECT S.first_name, S.last_name, C.course_name, G.grade
 FROM Students S
 JOIN Enrollments E ON S.student_id = E.student_id
 JOIN Courses C ON E.course_id = C.course_id
 JOIN Grades G ON E.enrollment_id = G.enrollment_id;

-- -- 5. List all courses taught by "Bob Brown"
 SELECT C.course_name
 FROM Courses C
 JOIN Instructors I ON C.instructor_id = I.instructor_id
 WHERE I.first_name = 'Bob' AND I.last_name = 'Brown';


---- Show all students with their enrolled courses and grades
SELECT 
    S.student_id,
    S.first_name,
    S.last_name,
    C.course_name,
    G.grade
FROM Students S
JOIN Enrollments E ON S.student_id = E.student_id
JOIN Courses C ON E.course_id = C.course_id
LEFT JOIN Grades G ON E.enrollment_id = G.enrollment_id
ORDER BY S.student_id, C.course_name;


--Count the number of students in each course
SELECT 
    C.course_name,
    COUNT(E.student_id) AS num_students
FROM Courses C
LEFT JOIN Enrollments E ON C.course_id = E.course_id
GROUP BY C.course_name;


--- List students who are not enrolled in any course
SELECT 
    S.student_id,
    S.first_name,
    S.last_name
FROM Students S
LEFT JOIN Enrollments E ON S.student_id = E.student_id
WHERE E.enrollment_id IS NULL;



---Find the average grade (using numerical mapping for grades)
 SELECT 
    C.course_name,
	FORMAT(
    ROUND(
        AVG(
            CASE G.grade
                WHEN 'A' THEN 4.0
                WHEN 'A-' THEN 3.7
                WHEN 'B+' THEN 3.3
                WHEN 'B' THEN 3.0
                WHEN 'C+' THEN 2.3
                ELSE NULL
            END
        ), 1
		),'N1'
    ) AS avg_gpa
FROM Courses C
JOIN Enrollments E ON C.course_id = E.course_id
JOIN Grades G ON E.enrollment_id = G.enrollment_id
GROUP BY C.course_name;



--List all courses with their assigned instructor's name
SELECT 
    C.course_name,
    I.first_name + ' ' + I.last_name AS instructor
FROM Courses C
JOIN Instructors I ON C.instructor_id = I.instructor_id;


---- Find students who have received an 'A' grade in any course

SELECT DISTINCT 
    S.student_id,
    S.first_name,
    S.last_name
FROM Students S
JOIN Enrollments E ON S.student_id = E.student_id
JOIN Grades G ON E.enrollment_id = G.enrollment_id
WHERE G.grade = 'A';


---- List all instructors and the number of courses they teach

SELECT 
    I.instructor_id,
    I.first_name + ' ' + I.last_name AS instructor,
    COUNT(C.course_id) AS courses_taught
FROM Instructors I
LEFT JOIN Courses C ON I.instructor_id = C.instructor_id
GROUP BY I.instructor_id, I.first_name, I.last_name;


-- Get all students born after the year 2003

SELECT 
    student_id,
    first_name,
    last_name,
    dob
FROM Students
WHERE YEAR(dob) > 2003;