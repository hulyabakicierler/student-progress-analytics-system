-- ============================================================
-- Project: Student Progress Analytics System
-- File: 03_data_quality_checks.sql
-- Description: Performs data quality checks for synthetic student progress data
-- Database: SQL Server
-- ============================================================

USE StudentProgressDB;
GO

-- ============================================================
-- 1. Record Count Control
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

-- ============================================================
-- 2. Check Duplicate Student Codes
-- Expected result: No rows
-- ============================================================

SELECT 
    StudentCode,
    COUNT(*) AS DuplicateCount
FROM Students
GROUP BY StudentCode
HAVING COUNT(*) > 1;
GO

-- ============================================================
-- 3. Check Duplicate Lesson Records
-- Same student, same topic, same date should not appear more than once.
-- Expected result: No rows
-- ============================================================

SELECT
    StudentID,
    TopicID,
    LessonDate,
    COUNT(*) AS DuplicateLessonCount
FROM Lessons
GROUP BY StudentID, TopicID, LessonDate
HAVING COUNT(*) > 1;
GO

-- ============================================================
-- 4. Check Invalid Attendance Status
-- Expected result: No rows
-- ============================================================

SELECT *
FROM Lessons
WHERE AttendanceStatus NOT IN ('Attended', 'Absent');
GO

-- ============================================================
-- 5. Check Invalid Homework Status
-- Expected result: No rows
-- ============================================================

SELECT *
FROM Homework
WHERE HomeworkStatus NOT IN ('Completed', 'Partial', 'Missing');
GO

-- ============================================================
-- 6. Check Invalid Mastery Levels
-- Expected result: No rows
-- ============================================================

SELECT *
FROM TopicMastery
WHERE MasteryLevel NOT IN ('Low', 'Medium', 'High');
GO

-- ============================================================
-- 7. Check Homework Date Consistency
-- DueDate should not be earlier than AssignedDate.
-- Expected result: No rows
-- ============================================================

SELECT *
FROM Homework
WHERE DueDate < AssignedDate;
GO

-- ============================================================
-- 8. Check Homework Completion Logic
-- CompletedQuestionCount should not exceed QuestionCount.
-- Expected result: No rows
-- ============================================================

SELECT *
FROM Homework
WHERE CompletedQuestionCount > QuestionCount;
GO

-- ============================================================
-- 9. Check Negative Values in Homework
-- Expected result: No rows
-- ============================================================

SELECT *
FROM Homework
WHERE QuestionCount < 0
   OR CompletedQuestionCount < 0;
GO

-- ============================================================
-- 10. Check Assessment Answer Consistency
-- In this synthetic dataset, each assessment is designed over 20 questions.
-- Expected result: No rows
-- ============================================================

SELECT *
FROM Assessments
WHERE CorrectAnswers + WrongAnswers + BlankAnswers <> 20;
GO

-- ============================================================
-- 11. Check Negative Values in Assessments
-- Expected result: No rows
-- ============================================================

SELECT *
FROM Assessments
WHERE CorrectAnswers < 0
   OR WrongAnswers < 0
   OR BlankAnswers < 0;
GO

-- ============================================================
-- 12. Check Assessment Date Consistency
-- AssessmentDate should not be earlier than student StartDate.
-- Expected result: No rows
-- ============================================================

SELECT
    a.AssessmentID,
    s.StudentCode,
    s.StudentName,
    s.StartDate,
    a.AssessmentDate
FROM Assessments a
INNER JOIN Students s
    ON a.StudentID = s.StudentID
WHERE a.AssessmentDate < s.StartDate;
GO

-- ============================================================
-- 13. Check Lessons Before Student Start Date
-- LessonDate should not be earlier than student StartDate.
-- Expected result: No rows
-- ============================================================

SELECT
    l.LessonID,
    s.StudentCode,
    s.StudentName,
    s.StartDate,
    l.LessonDate
FROM Lessons l
INNER JOIN Students s
    ON l.StudentID = s.StudentID
WHERE l.LessonDate < s.StartDate;
GO

-- ============================================================
-- 14. Check Orphan Lesson Records
-- Foreign keys should prevent this, but this query documents the control.
-- Expected result: No rows
-- ============================================================

SELECT l.*
FROM Lessons l
LEFT JOIN Students s
    ON l.StudentID = s.StudentID
WHERE s.StudentID IS NULL;
GO

-- ============================================================
-- 15. Check Orphan Homework Records
-- Expected result: No rows
-- ============================================================

SELECT h.*
FROM Homework h
LEFT JOIN Students s
    ON h.StudentID = s.StudentID
WHERE s.StudentID IS NULL;
GO

-- ============================================================
-- 16. Check Orphan Assessment Records
-- Expected result: No rows
-- ============================================================

SELECT a.*
FROM Assessments a
LEFT JOIN Students s
    ON a.StudentID = s.StudentID
WHERE s.StudentID IS NULL;
GO

-- ============================================================
-- 17. Review Student Status Distribution
-- This is not an error check; it helps understand the dataset.
-- ============================================================

SELECT
    Status,
    COUNT(*) AS StudentCount
FROM Students
GROUP BY Status;
GO

-- ============================================================
-- 18. Review Exam Type Distribution
-- This is not an error check; it helps understand the dataset.
-- ============================================================

SELECT
    ExamType,
    COUNT(*) AS StudentCount
FROM Students
GROUP BY ExamType;
GO

-- ============================================================
-- 19. Review Subject and Topic Distribution
-- ============================================================

SELECT
    s.SubjectName,
    COUNT(t.TopicID) AS TopicCount
FROM Subjects s
LEFT JOIN Topics t
    ON s.SubjectID = t.SubjectID
GROUP BY s.SubjectName;
GO
