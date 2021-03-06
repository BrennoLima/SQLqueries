REATE TABLE department (
    id      int PRIMARY KEY,
    name    varchar(30) NOT NULL
);

CREATE TABLE faculty (
    id          int PRIMARY KEY,
    firstname   varchar(30) NOT NULL,
    lastname    varchar(50)NOT NULL,
    deptId      int REFERENCES department(id) NOT NULL
);

CREATE TABLE student (
    id              int PRIMARY KEY,
    firstname       varchar(30) NOT NULL,
    lastname        varchar(50) NOT NULL,
    street          varchar(50) NOT NULL,
    streetDetail    varchar(30),
    city            varchar(30) NOT NULL,
    state           varchar(30) NOT NULL,
    postalCode      char(5) NOT NULL,
    majorId         int REFERENCES department(id) NOT NULL
);

CREATE TABLE course (
    id      int PRIMARY KEY,
    name    varchar(50) NOT NULL,
    deptId  int REFERENCES department(id) NOT NULL
);

CREATE TABLE studentCourse (
    studentId   int REFERENCES student(id),
    courseId    int REFERENCES course(id), 
    progress    int NOT NULL,
    startDate   date NOT NULL,
    CONSTRAINT st_course_pk PRIMARY KEY (studentId, courseId)
);

CREATE TABLE facultyCourse (
    facultyId      int REFERENCES faculty(id),
    courseId       int REFERENCES course(id),
    CONSTRAINT fac_course_pk PRIMARY KEY (facultyId, courseId)
);



/*  2A
Add a column named EndDate of type Date and a column named Credits of type INT.
*/

ALTER TABLE studentCourse
    ADD endDate date;

ALTER TABLE studentCourse    
    ADD credits int;

/*  2B 
Add NOT NULL constraint to the column EndDate.
*/

ALTER TABLE studentCourse
    MODIFY endDate date NOT NULL;

/*  2C
Modify the name of the field EndDate to FinishDate.
*/

ALTER TABLE studentCourse
    RENAME COLUMN endDate TO finishDate;

/*  2D
Write a query to remove the columns EndDate and FinishDate from the table StudentCourse.
*/

ALTER TABLE studentCourse
    DROP COLUMN finishDate;
    
ALTER TABLE studentCourse
    DROP COLUMN credits;

/*        4A      
The Curriculum Planning Committee is attempting to fill in gaps in the current course offerings.  
You need to provide them with a query which lists each department and the number of courses offered by that department.  
The two columns should have headers “Department Name? and “# Courses?, and the output should be sorted by the "# Courses" 
in each department (ascending).
*/

SELECT d.name AS "Department Name", COUNT(c.id) AS "# Courses"
    FROM department d INNER JOIN course c ON (d.id = c.deptId)
    GROUP BY d.name
    ORDER BY "# Courses";

/*      4B
The recruiting department needs to know which courses are most popular with the students.  
Please provide them with a query which lists each course and the number of students in that course.  
The two columns should have headers “Course Name? and “# Students?, and the output should be sorted 
by # Students descending and then by course name ascending.
*/

SELECT c.name AS "Course Name", COUNT(sc.studentId) AS "# Students"
    FROM course c INNER JOIN studentCourse sc ON (c.id = sc.courseId)
    GROUP BY c.name
    ORDER BY "# Students" DESC, c.name ASC;


/*     4C-1
Write a query to list the names of all courses where the # faculty assigned to those courses is zero.
The output should be in alphabetical order by course name.
*/

SELECT name
    FROM course
    WHERE id NOT IN (SELECT courseId FROM facultyCourse)
    ORDER BY name;


/*        4C-2
Using the above, write a query to list the course names and the # of students in those courses for all
courses where there are no assigned faculty.  The output should be ordered first by # of students 
descending and then by course name ascending.
*/

SELECT c.name, COUNT(sc.studentId) AS "# Students"
    FROM course c INNER JOIN studentCourse sc ON (c.id = sc.courseId)
    WHERE c.id NOT IN (SELECT courseId FROM facultyCourse)
    GROUP BY c.name
    ORDER BY "# Students" DESC, c.name ASC;


/*    4D
The enrollment team is gathering analytics about student enrollment throughout the years. Write a query 
that lists the total # of students that were enrolled in classes during each school year.  
The first column should have the header “Students?.  Provide a second “Year? column showing the enrollment year.
*/
    
SELECT COUNT(studentId) AS "Students", TO_CHAR(TRUNC(startDate, 'YEAR'), 'YYYY') AS "Year"
    FROM studentCourse
    GROUP BY TRUNC(startDate, 'YEAR')
    ORDER BY "Year";

/*       4E
The enrollment team is gathering analytics about student enrollment and they now want to know about August 
admissions specifically. Write a query that lists the Start Date and # of Students who enrolled in classes 
in August of each year. Output should be ordered by start date ascending.
*/

SELECT COUNT(studentId) AS "Students", TO_CHAR(startDate, 'YYYY-MM') AS "Year-Aug"
    FROM studentCourse WHERE TO_CHAR(startDate, 'MM') LIKE '%08%'
    GROUP BY startDate
    ORDER BY "Year-Aug";


/* 4F
Students are required to take 4 courses, and at least two of these courses must be from the department of their 
major.  Write a query to list students’ First Name, Last Name, and Number of Courses they are taking in their 
major department.  The output should be sorted first in increasing order of the number of courses, then by 
student last name.
*/

SELECT s.firstname AS "First Name", s.lastname AS "Last Name", COUNT(sc.courseId) AS "Number of Courses"
    FROM student s INNER JOIN studentCourse sc ON (s.id = sc.studentId) INNER JOIN course c ON (sc.courseId = c.id)
    WHERE s.majorId = c.deptId
    GROUP BY s.lastname, s.firstname
    ORDER BY "Number of Courses", "Last Name";


/*    4G
Students making average progress in their courses of less than 50% need to be offered tutoring assistance.  
Write a query to list First Name, Last Name and Average Progress of all students achieving average progress of 
less than 50%.  The average progress as displayed should be rounded to one decimal place.  Sort the
output by average progress descending.
*/

SELECT s.firstname AS "First Name", s.lastname AS "Last Name", ROUND(AVG(sc.progress),1) AS "Average Progress"
    FROM student s INNER JOIN studentCourse sc ON (s.id = sc.studentId)
    GROUP BY s.lastname, s.firstname
    HAVING AVG(sc.progress) < 50
    ORDER BY "Average Progress" DESC;


/*    4H-1
Write a query to list each Course Name and the Average Progress of students in that course.  
The output should be sorted descending by average progress.
*/

SELECT c.name AS "Course Name", ROUND(AVG(sc.progress),1) AS "Average Progress"
    FROM studentCourse sc INNER JOIN course c ON (sc.courseId = c.id)
    GROUP BY c.name
    ORDER BY "Average Progress" DESC;


/*   4H-2
Write a query that selects the maximum value of the average progress reported by the previous query.
*/
SELECT MAX("Average Progress") AS "Max Average"
    FROM (SELECT c.name AS "Course Name", ROUND(AVG(sc.progress),1) AS "Average Progress"
            FROM studentCourse sc INNER JOIN course c ON (sc.courseId = c.id)
            GROUP BY c.name
            ORDER BY "Average Progress" DESC);

/*  4H-3
Write a query that outputs the faculty first name, last name, and average of the progress made over all of their courses.
*/

SELECT f.firstname AS "First Name", f.lastname AS "Last Name", ROUND(AVG(sc.progress),1) AS "Average Progress"
    FROM studentCourse sc INNER JOIN facultyCourse fc ON (sc.courseId = fc.courseId)
        INNER JOIN faculty f ON (fc.facultyId = f.id)
    GROUP BY f.lastname, f.firstname
    ORDER BY "Average Progress";


/*       4H-4
Write a query just like #3, but where only those faculty where average progress in their courses is 90% or more 
of the maximum observed in #2.  Order the output by decreasing average progress.
*/

SELECT "First Name", "Last Name", "Average Progress"
    FROM (SELECT f.firstname AS "First Name", f.lastname AS "Last Name", ROUND(AVG(sc.progress),1) AS "Average Progress"
            FROM studentCourse sc INNER JOIN facultyCourse fc ON (sc.courseId = fc.courseId)
                INNER JOIN faculty f ON (fc.facultyId = f.id)
            GROUP BY f.lastname, f.firstname
            ORDER BY "Average Progress")
    WHERE "Average Progress" >=  0.9 * (SELECT MAX("Average Progress") AS "Max Average"
                                        FROM (SELECT c.name AS "Course Name", ROUND(AVG(sc.progress),1) AS "Average Progress"
                                            FROM studentCourse sc INNER JOIN course c ON (sc.courseId = c.id)
                                        GROUP BY c.name
                                        ORDER BY "Average Progress" DESC))
    ORDER BY "Average Progress" DESC; 


/*        4I
Students are awarded two grades based on the minimum and maximum progress they are making in the courses.  
The grading scale is as follows:

   Progress < 40:          F
  Progress < 50:         D
 Progress < 60:                C
        Progress < 70:               B
       Progress >= 70:             A

Write a query which displays each student’s first name, lastname, grade based on minimum progress, and grade based on maximum progress.
*/

SELECT s.firstname AS "First Name", s.lastname AS "Last Name", ROUND(MIN(sc.progress),1) AS "Min Grade",
        ROUND(MAX(sc.progress),1) AS "Max Grade", ROUND(AVG(sc.progress),1) AS "Average Progress"
    FROM student s INNER JOIN studentCourse sc ON (s.id = sc.studentId)
    GROUP BY s.lastname, s.firstname
    ORDER BY "Average Progress" DESC;


/* 4J
Write a query that returns students full name with “Student Name? as alias whose
progress is greater than the average progress for their course.
*/

SELECT TO_CHAR(s.firstname || ' ' || s.lastname) AS "Student Name", c.name AS "Course Name"
    FROM student s INNER JOIN studentCourse sc1 ON (s.id = sc1.studentId) INNER JOIN course c ON (sc1.courseId = c.id)
    WHERE sc1.progress > (SELECT AVG(sc2.progress)
                            FROM studentCourse sc2
                            WHERE sc1.courseId = sc2.courseId)
    ORDER BY "Student Name";
