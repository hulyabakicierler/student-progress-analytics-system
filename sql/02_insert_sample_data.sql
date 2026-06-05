-- ============================================================
-- Project: Student Progress Analytics System
-- File: 02_insert_sample_data.sql
-- Description: Inserts synthetic sample data for student progress tracking
-- Database: SQL Server
-- ============================================================

USE StudentProgressDB;
GO

SET NOCOUNT ON;
GO

-- ============================================================
-- Clear existing demo data
-- This section makes the script reusable during development.
-- ============================================================

DELETE FROM TopicMastery;
DELETE FROM Assessments;
DELETE FROM Homework;
DELETE FROM Lessons;
DELETE FROM Topics;
DELETE FROM Subjects;
DELETE FROM Students;
GO

DBCC CHECKIDENT ('TopicMastery', RESEED, 0);
DBCC CHECKIDENT ('Assessments', RESEED, 0);
DBCC CHECKIDENT ('Homework', RESEED, 0);
DBCC CHECKIDENT ('Lessons', RESEED, 0);
DBCC CHECKIDENT ('Topics', RESEED, 0);
DBCC CHECKIDENT ('Subjects', RESEED, 0);
DBCC CHECKIDENT ('Students', RESEED, 0);
GO

-- ============================================================
-- 1. Insert Students
-- ============================================================

INSERT INTO Students 
    (StudentCode, StudentName, GradeLevel, ExamType, StartDate, Status)
VALUES
    ('S001', 'Student_001', '8th Grade',  'LGS', '2026-06-01', 'Active'),
    ('S002', 'Student_002', '8th Grade',  'LGS', '2026-06-03', 'Active'),
    ('S003', 'Student_003', '8th Grade',  'LGS', '2026-06-05', 'Active'),
    ('S004', 'Student_004', '10th Grade', 'TYT', '2026-06-02', 'Active'),
    ('S005', 'Student_005', '11th Grade', 'TYT', '2026-06-04', 'Active'),
    ('S006', 'Student_006', '11th Grade', 'AYT', '2026-06-06', 'Active'),
    ('S007', 'Student_007', '12th Grade', 'AYT', '2026-06-01', 'Active'),
    ('S008', 'Student_008', '12th Grade', 'TYT', '2026-06-08', 'Active'),
    ('S009', 'Student_009', '8th Grade',  'LGS', '2026-06-10', 'Active'),
    ('S010', 'Student_010', '11th Grade', 'TYT', '2026-06-12', 'Inactive');
GO

-- ============================================================
-- 2. Insert Subjects
-- ============================================================

INSERT INTO Subjects 
    (SubjectName)
VALUES
    ('Mathematics'),
    ('Biology');
GO

-- ============================================================
-- 3. Insert Topics
-- ============================================================

INSERT INTO Topics
    (SubjectID, TopicName, GradeLevel, ExamType)
VALUES
    ((SELECT SubjectID FROM Subjects WHERE SubjectName = 'Mathematics'), 'Rational Numbers',       '8th Grade',  'LGS'),
    ((SELECT SubjectID FROM Subjects WHERE SubjectName = 'Mathematics'), 'Linear Equations',       '8th Grade',  'LGS'),
    ((SELECT SubjectID FROM Subjects WHERE SubjectName = 'Mathematics'), 'Ratio and Proportion',   '8th Grade',  'LGS'),
    ((SELECT SubjectID FROM Subjects WHERE SubjectName = 'Mathematics'), 'Problem Solving',        '8th Grade',  'LGS'),
    ((SELECT SubjectID FROM Subjects WHERE SubjectName = 'Mathematics'), 'Functions',              '11th Grade', 'TYT'),
    ((SELECT SubjectID FROM Subjects WHERE SubjectName = 'Mathematics'), 'Quadratic Equations',    '11th Grade', 'AYT'),
    ((SELECT SubjectID FROM Subjects WHERE SubjectName = 'Mathematics'), 'Probability',            '12th Grade', 'TYT'),
    ((SELECT SubjectID FROM Subjects WHERE SubjectName = 'Mathematics'), 'Geometry - Triangles',   '12th Grade', 'AYT'),
    ((SELECT SubjectID FROM Subjects WHERE SubjectName = 'Biology'),     'Cell Biology',           '10th Grade', 'TYT'),
    ((SELECT SubjectID FROM Subjects WHERE SubjectName = 'Biology'),     'Genetics',               '11th Grade', 'AYT'),
    ((SELECT SubjectID FROM Subjects WHERE SubjectName = 'Biology'),     'Ecology',                '12th Grade', 'TYT'),
    ((SELECT SubjectID FROM Subjects WHERE SubjectName = 'Biology'),     'Human Systems',          '11th Grade', 'TYT');
GO

-- ============================================================
-- 4. Insert Lessons
-- ============================================================

INSERT INTO Lessons
    (StudentID, TopicID, LessonDate, DurationMinutes, AttendanceStatus, TeacherNote)
VALUES
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S001'), (SELECT TopicID FROM Topics WHERE TopicName = 'Rational Numbers'),     '2026-06-01', 60, 'Attended', 'Student understood basic concepts but needs more practice.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S001'), (SELECT TopicID FROM Topics WHERE TopicName = 'Linear Equations'),     '2026-06-08', 60, 'Attended', 'Equation solving steps were reviewed.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S002'), (SELECT TopicID FROM Topics WHERE TopicName = 'Ratio and Proportion'), '2026-06-03', 60, 'Attended', 'Good participation during lesson.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S002'), (SELECT TopicID FROM Topics WHERE TopicName = 'Problem Solving'),      '2026-06-10', 60, 'Attended', 'Needs improvement in word problems.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S003'), (SELECT TopicID FROM Topics WHERE TopicName = 'Rational Numbers'),     '2026-06-05', 60, 'Absent',   'Student did not attend the lesson.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S003'), (SELECT TopicID FROM Topics WHERE TopicName = 'Problem Solving'),      '2026-06-12', 60, 'Attended', 'Basic problem-solving strategy introduced.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S004'), (SELECT TopicID FROM Topics WHERE TopicName = 'Functions'),            '2026-06-02', 75, 'Attended', 'Function notation and graph interpretation studied.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S004'), (SELECT TopicID FROM Topics WHERE TopicName = 'Cell Biology'),         '2026-06-09', 60, 'Attended', 'Cell organelles reviewed with examples.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S005'), (SELECT TopicID FROM Topics WHERE TopicName = 'Functions'),            '2026-06-04', 75, 'Attended', 'Student needs more graph-based practice.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S005'), (SELECT TopicID FROM Topics WHERE TopicName = 'Human Systems'),        '2026-06-11', 60, 'Attended', 'Main systems were summarized.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S006'), (SELECT TopicID FROM Topics WHERE TopicName = 'Quadratic Equations'),  '2026-06-06', 75, 'Attended', 'Factorization method was practiced.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S006'), (SELECT TopicID FROM Topics WHERE TopicName = 'Genetics'),             '2026-06-13', 60, 'Attended', 'Punnett square examples solved.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S007'), (SELECT TopicID FROM Topics WHERE TopicName = 'Geometry - Triangles'), '2026-06-01', 75, 'Attended', 'Triangle similarity rules reviewed.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S007'), (SELECT TopicID FROM Topics WHERE TopicName = 'Quadratic Equations'),  '2026-06-08', 75, 'Attended', 'Student improved in equation solving.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S008'), (SELECT TopicID FROM Topics WHERE TopicName = 'Probability'),          '2026-06-08', 60, 'Attended', 'Probability basics explained.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S008'), (SELECT TopicID FROM Topics WHERE TopicName = 'Ecology'),              '2026-06-15', 60, 'Attended', 'Ecosystem and food chain concepts studied.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S009'), (SELECT TopicID FROM Topics WHERE TopicName = 'Linear Equations'),     '2026-06-10', 60, 'Attended', 'Student showed strong calculation skills.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S009'), (SELECT TopicID FROM Topics WHERE TopicName = 'Problem Solving'),      '2026-06-17', 60, 'Attended', 'More practice needed for multi-step questions.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S010'), (SELECT TopicID FROM Topics WHERE TopicName = 'Functions'),            '2026-06-12', 75, 'Attended', 'Initial level assessment completed.'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S010'), (SELECT TopicID FROM Topics WHERE TopicName = 'Human Systems'),        '2026-06-19', 60, 'Absent',   'Student did not attend the lesson.');
GO

-- ============================================================
-- 5. Insert Homework
-- CompletionRate is calculated automatically in the table.
-- ============================================================

INSERT INTO Homework
    (StudentID, TopicID, AssignedDate, DueDate, QuestionCount, CompletedQuestionCount, HomeworkStatus)
VALUES
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S001'), (SELECT TopicID FROM Topics WHERE TopicName = 'Rational Numbers'),     '2026-06-01', '2026-06-07', 40, 34, 'Completed'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S001'), (SELECT TopicID FROM Topics WHERE TopicName = 'Linear Equations'),     '2026-06-08', '2026-06-14', 35, 25, 'Partial'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S002'), (SELECT TopicID FROM Topics WHERE TopicName = 'Ratio and Proportion'), '2026-06-03', '2026-06-09', 30, 30, 'Completed'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S002'), (SELECT TopicID FROM Topics WHERE TopicName = 'Problem Solving'),      '2026-06-10', '2026-06-16', 45, 28, 'Partial'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S003'), (SELECT TopicID FROM Topics WHERE TopicName = 'Rational Numbers'),     '2026-06-05', '2026-06-11', 30, 0,  'Missing'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S003'), (SELECT TopicID FROM Topics WHERE TopicName = 'Problem Solving'),      '2026-06-12', '2026-06-18', 40, 18, 'Partial'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S004'), (SELECT TopicID FROM Topics WHERE TopicName = 'Functions'),            '2026-06-02', '2026-06-08', 35, 31, 'Completed'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S004'), (SELECT TopicID FROM Topics WHERE TopicName = 'Cell Biology'),         '2026-06-09', '2026-06-15', 25, 20, 'Completed'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S005'), (SELECT TopicID FROM Topics WHERE TopicName = 'Functions'),            '2026-06-04', '2026-06-10', 35, 22, 'Partial'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S005'), (SELECT TopicID FROM Topics WHERE TopicName = 'Human Systems'),        '2026-06-11', '2026-06-17', 25, 16, 'Partial'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S006'), (SELECT TopicID FROM Topics WHERE TopicName = 'Quadratic Equations'),  '2026-06-06', '2026-06-12', 40, 36, 'Completed'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S006'), (SELECT TopicID FROM Topics WHERE TopicName = 'Genetics'),             '2026-06-13', '2026-06-19', 30, 24, 'Completed'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S007'), (SELECT TopicID FROM Topics WHERE TopicName = 'Geometry - Triangles'), '2026-06-01', '2026-06-07', 40, 33, 'Completed'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S007'), (SELECT TopicID FROM Topics WHERE TopicName = 'Quadratic Equations'),  '2026-06-08', '2026-06-14', 40, 38, 'Completed'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S008'), (SELECT TopicID FROM Topics WHERE TopicName = 'Probability'),          '2026-06-08', '2026-06-14', 30, 21, 'Partial'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S008'), (SELECT TopicID FROM Topics WHERE TopicName = 'Ecology'),              '2026-06-15', '2026-06-21', 25, 23, 'Completed'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S009'), (SELECT TopicID FROM Topics WHERE TopicName = 'Linear Equations'),     '2026-06-10', '2026-06-16', 35, 35, 'Completed'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S009'), (SELECT TopicID FROM Topics WHERE TopicName = 'Problem Solving'),      '2026-06-17', '2026-06-23', 45, 32, 'Partial'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S010'), (SELECT TopicID FROM Topics WHERE TopicName = 'Functions'),            '2026-06-12', '2026-06-18', 35, 14, 'Partial'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S010'), (SELECT TopicID FROM Topics WHERE TopicName = 'Human Systems'),        '2026-06-19', '2026-06-25', 25, 0,  'Missing');
GO

-- ============================================================
-- 6. Insert Assessments
-- NetScore is calculated automatically in the table.
-- Formula: CorrectAnswers - WrongAnswers * 0.25
-- ============================================================

INSERT INTO Assessments
    (StudentID, TopicID, AssessmentDate, AssessmentType, CorrectAnswers, WrongAnswers, BlankAnswers)
VALUES
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S001'), (SELECT TopicID FROM Topics WHERE TopicName = 'Rational Numbers'),     '2026-06-07', 'Quiz',          16, 4, 0),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S001'), (SELECT TopicID FROM Topics WHERE TopicName = 'Linear Equations'),     '2026-06-14', 'Quiz',          14, 5, 1),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S002'), (SELECT TopicID FROM Topics WHERE TopicName = 'Ratio and Proportion'), '2026-06-09', 'Quiz',          18, 2, 0),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S002'), (SELECT TopicID FROM Topics WHERE TopicName = 'Problem Solving'),      '2026-06-16', 'Quiz',          13, 6, 1),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S003'), (SELECT TopicID FROM Topics WHERE TopicName = 'Rational Numbers'),     '2026-06-11', 'Quiz',           8, 8, 4),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S003'), (SELECT TopicID FROM Topics WHERE TopicName = 'Problem Solving'),      '2026-06-18', 'Quiz',          10, 7, 3),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S004'), (SELECT TopicID FROM Topics WHERE TopicName = 'Functions'),            '2026-06-08', 'Mini Exam',     17, 3, 0),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S004'), (SELECT TopicID FROM Topics WHERE TopicName = 'Cell Biology'),         '2026-06-15', 'Quiz',          15, 4, 1),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S005'), (SELECT TopicID FROM Topics WHERE TopicName = 'Functions'),            '2026-06-10', 'Mini Exam',     12, 6, 2),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S005'), (SELECT TopicID FROM Topics WHERE TopicName = 'Human Systems'),        '2026-06-17', 'Quiz',          11, 7, 2),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S006'), (SELECT TopicID FROM Topics WHERE TopicName = 'Quadratic Equations'),  '2026-06-12', 'Mini Exam',     18, 2, 0),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S006'), (SELECT TopicID FROM Topics WHERE TopicName = 'Genetics'),             '2026-06-19', 'Quiz',          16, 3, 1),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S007'), (SELECT TopicID FROM Topics WHERE TopicName = 'Geometry - Triangles'), '2026-06-07', 'Mini Exam',     15, 5, 0),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S007'), (SELECT TopicID FROM Topics WHERE TopicName = 'Quadratic Equations'),  '2026-06-14', 'Mini Exam',     19, 1, 0),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S008'), (SELECT TopicID FROM Topics WHERE TopicName = 'Probability'),          '2026-06-14', 'Quiz',          12, 5, 3),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S008'), (SELECT TopicID FROM Topics WHERE TopicName = 'Ecology'),              '2026-06-21', 'Quiz',          17, 2, 1),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S009'), (SELECT TopicID FROM Topics WHERE TopicName = 'Linear Equations'),     '2026-06-16', 'Quiz',          19, 1, 0),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S009'), (SELECT TopicID FROM Topics WHERE TopicName = 'Problem Solving'),      '2026-06-23', 'Quiz',          14, 5, 1),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S010'), (SELECT TopicID FROM Topics WHERE TopicName = 'Functions'),            '2026-06-18', 'Mini Exam',      9, 8, 3),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S010'), (SELECT TopicID FROM Topics WHERE TopicName = 'Human Systems'),        '2026-06-25', 'Quiz',           7, 9, 4);
GO

-- ============================================================
-- 7. Insert Topic Mastery
-- ============================================================

INSERT INTO TopicMastery
    (StudentID, TopicID, MasteryLevel, LastUpdated)
VALUES
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S001'), (SELECT TopicID FROM Topics WHERE TopicName = 'Rational Numbers'),     'High',   '2026-06-07'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S001'), (SELECT TopicID FROM Topics WHERE TopicName = 'Linear Equations'),     'Medium', '2026-06-14'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S002'), (SELECT TopicID FROM Topics WHERE TopicName = 'Ratio and Proportion'), 'High',   '2026-06-09'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S002'), (SELECT TopicID FROM Topics WHERE TopicName = 'Problem Solving'),      'Medium', '2026-06-16'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S003'), (SELECT TopicID FROM Topics WHERE TopicName = 'Rational Numbers'),     'Low',    '2026-06-11'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S003'), (SELECT TopicID FROM Topics WHERE TopicName = 'Problem Solving'),      'Low',    '2026-06-18'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S004'), (SELECT TopicID FROM Topics WHERE TopicName = 'Functions'),            'High',   '2026-06-08'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S004'), (SELECT TopicID FROM Topics WHERE TopicName = 'Cell Biology'),         'Medium', '2026-06-15'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S005'), (SELECT TopicID FROM Topics WHERE TopicName = 'Functions'),            'Medium', '2026-06-10'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S005'), (SELECT TopicID FROM Topics WHERE TopicName = 'Human Systems'),        'Medium', '2026-06-17'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S006'), (SELECT TopicID FROM Topics WHERE TopicName = 'Quadratic Equations'),  'High',   '2026-06-12'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S006'), (SELECT TopicID FROM Topics WHERE TopicName = 'Genetics'),             'High',   '2026-06-19'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S007'), (SELECT TopicID FROM Topics WHERE TopicName = 'Geometry - Triangles'), 'Medium', '2026-06-07'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S007'), (SELECT TopicID FROM Topics WHERE TopicName = 'Quadratic Equations'),  'High',   '2026-06-14'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S008'), (SELECT TopicID FROM Topics WHERE TopicName = 'Probability'),          'Medium', '2026-06-14'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S008'), (SELECT TopicID FROM Topics WHERE TopicName = 'Ecology'),              'High',   '2026-06-21'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S009'), (SELECT TopicID FROM Topics WHERE TopicName = 'Linear Equations'),     'High',   '2026-06-16'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S009'), (SELECT TopicID FROM Topics WHERE TopicName = 'Problem Solving'),      'Medium', '2026-06-23'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S010'), (SELECT TopicID FROM Topics WHERE TopicName = 'Functions'),            'Low',    '2026-06-18'),
    ((SELECT StudentID FROM Students WHERE StudentCode = 'S010'), (SELECT TopicID FROM Topics WHERE TopicName = 'Human Systems'),        'Low',    '2026-06-25');
GO

-- ============================================================
-- 8. Quick Control Queries
-- ============================================================

SELECT 'Students' AS TableName, COUNT(*) AS RecordCount FROM Students
UNION ALL
SELECT 'Subjects', COUNT(*) FROM Subjects
UNION ALL
SELECT 'Topics', COUNT(*) FROM Topics
UNION ALL
SELECT 'Lessons', COUNT(*) FROM Lessons
UNION ALL
SELECT 'Homework', COUNT(*) FROM Homework
UNION ALL
SELECT 'Assessments', COUNT(*) FROM Assessments
UNION ALL
SELECT 'TopicMastery', COUNT(*) FROM TopicMastery;
GO
