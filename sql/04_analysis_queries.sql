-- ============================================================
-- Project: Student Progress Analytics System
-- File: 04_analysis_queries.sql
-- Description: Analysis queries for student progress, homework, assessment,
--              topic performance, attendance, and parent reporting
-- Database: SQL Server
-- ============================================================

USE StudentProgressDB;
GO

-- ============================================================
-- 1. Student-Level Progress Overview
-- Business Question:
-- What is the overall progress summary for each student?
-- ============================================================

WITH LessonSummary AS (
    SELECT
        StudentID,
        COUNT(LessonID) AS TotalLessons,
        SUM(DurationMinutes) AS TotalLessonMinutes,
        SUM(CASE WHEN AttendanceStatus = 'Attended' THEN 1 ELSE 0 END) AS AttendedLessons,
        SUM(CASE WHEN AttendanceStatus = 'Absent' THEN 1 ELSE 0 END) AS AbsentLessons
    FROM Lessons
    GROUP BY StudentID
),
HomeworkSummary AS (
    SELECT
        StudentID,
        COUNT(HomeworkID) AS TotalHomework,
        AVG(CompletionRate) AS AvgHomeworkCompletion
    FROM Homework
    GROUP BY StudentID
),
AssessmentSummary AS (
    SELECT
        StudentID,
        COUNT(AssessmentID) AS TotalAssessments,
        AVG(NetScore) AS AvgNetScore
    FROM Assessments
    GROUP BY StudentID
),
MasterySummary AS (
    SELECT
        StudentID,
        AVG(
            CASE 
                WHEN MasteryLevel = 'Low' THEN 1.0
                WHEN MasteryLevel = 'Medium' THEN 2.0
                WHEN MasteryLevel = 'High' THEN 3.0
            END
        ) AS AvgMasteryScore
    FROM TopicMastery
    GROUP BY StudentID
)
SELECT
    s.StudentCode,
    s.StudentName,
    s.GradeLevel,
    s.ExamType,
    s.Status,
    ISNULL(ls.TotalLessons, 0) AS TotalLessons,
    ISNULL(ls.TotalLessonMinutes, 0) AS TotalLessonMinutes,
    ISNULL(ls.AttendedLessons, 0) AS AttendedLessons,
    ISNULL(ls.AbsentLessons, 0) AS AbsentLessons,
    CAST(
        CASE 
            WHEN ISNULL(ls.TotalLessons, 0) = 0 THEN 0
            ELSE ls.AttendedLessons * 100.0 / ls.TotalLessons
        END AS DECIMAL(5,2)
    ) AS AttendanceRate,
    ISNULL(hs.TotalHomework, 0) AS TotalHomework,
    CAST(ISNULL(hs.AvgHomeworkCompletion, 0) AS DECIMAL(5,2)) AS AvgHomeworkCompletion,
    ISNULL(a.TotalAssessments, 0) AS TotalAssessments,
    CAST(ISNULL(a.AvgNetScore, 0) AS DECIMAL(5,2)) AS AvgNetScore,
    CAST(ISNULL(ms.AvgMasteryScore, 0) AS DECIMAL(5,2)) AS AvgMasteryScore
FROM Students s
LEFT JOIN LessonSummary ls
    ON s.StudentID = ls.StudentID
LEFT JOIN HomeworkSummary hs
    ON s.StudentID = hs.StudentID
LEFT JOIN AssessmentSummary a
    ON s.StudentID = a.StudentID
LEFT JOIN MasterySummary ms
    ON s.StudentID = ms.StudentID
ORDER BY s.StudentCode;
GO

-- ============================================================
-- 2. Homework Performance by Student
-- Business Question:
-- Which students complete homework consistently?
-- ============================================================

SELECT
    s.StudentCode,
    s.StudentName,
    s.ExamType,
    COUNT(h.HomeworkID) AS TotalHomeworkAssigned,
    SUM(h.QuestionCount) AS TotalQuestionsAssigned,
    SUM(h.CompletedQuestionCount) AS TotalQuestionsCompleted,
    CAST(AVG(h.CompletionRate) AS DECIMAL(5,2)) AS AvgCompletionRate,
    SUM(CASE WHEN h.HomeworkStatus = 'Completed' THEN 1 ELSE 0 END) AS CompletedHomeworkCount,
    SUM(CASE WHEN h.HomeworkStatus = 'Partial' THEN 1 ELSE 0 END) AS PartialHomeworkCount,
    SUM(CASE WHEN h.HomeworkStatus = 'Missing' THEN 1 ELSE 0 END) AS MissingHomeworkCount
FROM Students s
INNER JOIN Homework h
    ON s.StudentID = h.StudentID
GROUP BY
    s.StudentCode,
    s.StudentName,
    s.ExamType
ORDER BY AvgCompletionRate DESC;
GO

-- ============================================================
-- 3. Assessment Performance by Student
-- Business Question:
-- Which students have stronger assessment performance?
-- ============================================================

SELECT
    s.StudentCode,
    s.StudentName,
    s.ExamType,
    COUNT(a.AssessmentID) AS TotalAssessments,
    SUM(a.CorrectAnswers) AS TotalCorrectAnswers,
    SUM(a.WrongAnswers) AS TotalWrongAnswers,
    SUM(a.BlankAnswers) AS TotalBlankAnswers,
    CAST(AVG(a.NetScore) AS DECIMAL(5,2)) AS AvgNetScore,
    CAST(MAX(a.NetScore) AS DECIMAL(5,2)) AS BestNetScore,
    CAST(MIN(a.NetScore) AS DECIMAL(5,2)) AS LowestNetScore
FROM Students s
INNER JOIN Assessments a
    ON s.StudentID = a.StudentID
GROUP BY
    s.StudentCode,
    s.StudentName,
    s.ExamType
ORDER BY AvgNetScore DESC;
GO

-- ============================================================
-- 4. Topic-Based Performance Analysis
-- Business Question:
-- Which topics have the strongest and weakest performance overall?
-- ============================================================

SELECT
    sub.SubjectName,
    t.TopicName,
    t.ExamType,
    COUNT(DISTINCT a.StudentID) AS StudentCount,
    COUNT(a.AssessmentID) AS AssessmentCount,
    CAST(AVG(a.NetScore) AS DECIMAL(5,2)) AS AvgNetScore,
    CAST(AVG(h.CompletionRate) AS DECIMAL(5,2)) AS AvgHomeworkCompletion
FROM Topics t
INNER JOIN Subjects sub
    ON t.SubjectID = sub.SubjectID
LEFT JOIN Assessments a
    ON t.TopicID = a.TopicID
LEFT JOIN Homework h
    ON t.TopicID = h.TopicID
GROUP BY
    sub.SubjectName,
    t.TopicName,
    t.ExamType
ORDER BY AvgNetScore ASC;
GO

-- ============================================================
-- 5. Student-Topic Detail Analysis
-- Business Question:
-- How does each student perform in each topic?
-- ============================================================

SELECT
    s.StudentCode,
    s.StudentName,
    s.ExamType,
    sub.SubjectName,
    t.TopicName,
    CAST(AVG(h.CompletionRate) AS DECIMAL(5,2)) AS AvgHomeworkCompletion,
    CAST(AVG(a.NetScore) AS DECIMAL(5,2)) AS AvgNetScore,
    MAX(tm.MasteryLevel) AS MasteryLevel
FROM Students s
INNER JOIN Topics t
    ON s.ExamType = t.ExamType
LEFT JOIN Subjects sub
    ON t.SubjectID = sub.SubjectID
LEFT JOIN Homework h
    ON s.StudentID = h.StudentID
    AND t.TopicID = h.TopicID
LEFT JOIN Assessments a
    ON s.StudentID = a.StudentID
    AND t.TopicID = a.TopicID
LEFT JOIN TopicMastery tm
    ON s.StudentID = tm.StudentID
    AND t.TopicID = tm.TopicID
WHERE h.HomeworkID IS NOT NULL
   OR a.AssessmentID IS NOT NULL
   OR tm.MasteryID IS NOT NULL
GROUP BY
    s.StudentCode,
    s.StudentName,
    s.ExamType,
    sub.SubjectName,
    t.TopicName
ORDER BY
    s.StudentCode,
    AvgNetScore ASC;
GO

-- ============================================================
-- 6. Weak Topic Detection by Student
-- Business Question:
-- Which topics should each student focus on next?
-- ============================================================

WITH StudentTopicPerformance AS (
    SELECT
        s.StudentCode,
        s.StudentName,
        s.ExamType,
        sub.SubjectName,
        t.TopicName,
        CAST(AVG(h.CompletionRate) AS DECIMAL(5,2)) AS AvgHomeworkCompletion,
        CAST(AVG(a.NetScore) AS DECIMAL(5,2)) AS AvgNetScore,
        MAX(tm.MasteryLevel) AS MasteryLevel,
        ROW_NUMBER() OVER (
            PARTITION BY s.StudentID
            ORDER BY 
                AVG(a.NetScore) ASC,
                AVG(h.CompletionRate) ASC
        ) AS WeakTopicRank
    FROM Students s
    INNER JOIN Topics t
        ON s.ExamType = t.ExamType
    LEFT JOIN Subjects sub
        ON t.SubjectID = sub.SubjectID
    LEFT JOIN Homework h
        ON s.StudentID = h.StudentID
        AND t.TopicID = h.TopicID
    LEFT JOIN Assessments a
        ON s.StudentID = a.StudentID
        AND t.TopicID = a.TopicID
    LEFT JOIN TopicMastery tm
        ON s.StudentID = tm.StudentID
        AND t.TopicID = tm.TopicID
    WHERE h.HomeworkID IS NOT NULL
       OR a.AssessmentID IS NOT NULL
       OR tm.MasteryID IS NOT NULL
    GROUP BY
        s.StudentID,
        s.StudentCode,
        s.StudentName,
        s.ExamType,
        sub.SubjectName,
        t.TopicName
)
SELECT
    StudentCode,
    StudentName,
    ExamType,
    SubjectName,
    TopicName,
    AvgHomeworkCompletion,
    AvgNetScore,
    MasteryLevel,
    WeakTopicRank
FROM StudentTopicPerformance
WHERE WeakTopicRank <= 2
ORDER BY
    StudentCode,
    WeakTopicRank;
GO

-- ============================================================
-- 7. Weekly Progress Analysis
-- Business Question:
-- How does student performance change over time?
-- ============================================================

SELECT
    s.StudentCode,
    s.StudentName,
    s.ExamType,
    DATEPART(YEAR, a.AssessmentDate) AS AssessmentYear,
    DATEPART(WEEK, a.AssessmentDate) AS AssessmentWeek,
    COUNT(a.AssessmentID) AS AssessmentCount,
    CAST(AVG(a.NetScore) AS DECIMAL(5,2)) AS AvgWeeklyNetScore
FROM Students s
INNER JOIN Assessments a
    ON s.StudentID = a.StudentID
GROUP BY
    s.StudentCode,
    s.StudentName,
    s.ExamType,
    DATEPART(YEAR, a.AssessmentDate),
    DATEPART(WEEK, a.AssessmentDate)
ORDER BY
    s.StudentCode,
    AssessmentYear,
    AssessmentWeek;
GO

-- ============================================================
-- 8. Attendance Analysis
-- Business Question:
-- Which students have attendance problems?
-- ============================================================

SELECT
    s.StudentCode,
    s.StudentName,
    s.ExamType,
    COUNT(l.LessonID) AS TotalLessons,
    SUM(CASE WHEN l.AttendanceStatus = 'Attended' THEN 1 ELSE 0 END) AS AttendedLessons,
    SUM(CASE WHEN l.AttendanceStatus = 'Absent' THEN 1 ELSE 0 END) AS AbsentLessons,
    CAST(
        SUM(CASE WHEN l.AttendanceStatus = 'Attended' THEN 1 ELSE 0 END) * 100.0 / COUNT(l.LessonID)
        AS DECIMAL(5,2)
    ) AS AttendanceRate
FROM Students s
INNER JOIN Lessons l
    ON s.StudentID = l.StudentID
GROUP BY
    s.StudentCode,
    s.StudentName,
    s.ExamType
ORDER BY AttendanceRate ASC;
GO

-- ============================================================
-- 9. Students Requiring Attention
-- Business Question:
-- Which students may need closer follow-up?
-- Rule:
-- Avg homework completion below 70 OR attendance below 80 OR average net below 12
-- ============================================================

WITH StudentKPIs AS (
    SELECT
        s.StudentID,
        s.StudentCode,
        s.StudentName,
        s.ExamType,
        CAST(AVG(h.CompletionRate) AS DECIMAL(5,2)) AS AvgHomeworkCompletion,
        CAST(AVG(a.NetScore) AS DECIMAL(5,2)) AS AvgNetScore,
        CAST(
            SUM(CASE WHEN l.AttendanceStatus = 'Attended' THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT l.LessonID)
            AS DECIMAL(5,2)
        ) AS AttendanceRate
    FROM Students s
    LEFT JOIN Homework h
        ON s.StudentID = h.StudentID
    LEFT JOIN Assessments a
        ON s.StudentID = a.StudentID
    LEFT JOIN Lessons l
        ON s.StudentID = l.StudentID
    GROUP BY
        s.StudentID,
        s.StudentCode,
        s.StudentName,
        s.ExamType
)
SELECT
    StudentCode,
    StudentName,
    ExamType,
    AvgHomeworkCompletion,
    AvgNetScore,
    AttendanceRate,
    CASE
        WHEN AvgHomeworkCompletion < 70 THEN 'Low homework completion'
        WHEN AttendanceRate < 80 THEN 'Attendance risk'
        WHEN AvgNetScore < 12 THEN 'Low assessment performance'
        ELSE 'On track'
    END AS RiskReason
FROM StudentKPIs
WHERE AvgHomeworkCompletion < 70
   OR AttendanceRate < 80
   OR AvgNetScore < 12
ORDER BY
    AvgNetScore ASC,
    AvgHomeworkCompletion ASC;
GO

-- ============================================================
-- 10. Parent Report Summary
-- Business Question:
-- What information can be summarized for parent reporting?
-- ============================================================

WITH LessonSummary AS (
    SELECT
        StudentID,
        COUNT(LessonID) AS TotalLessons,
        SUM(CASE WHEN AttendanceStatus = 'Attended' THEN 1 ELSE 0 END) AS AttendedLessons
    FROM Lessons
    GROUP BY StudentID
),
HomeworkSummary AS (
    SELECT
        StudentID,
        AVG(CompletionRate) AS AvgHomeworkCompletion
    FROM Homework
    GROUP BY StudentID
),
AssessmentSummary AS (
    SELECT
        StudentID,
        AVG(NetScore) AS AvgNetScore
    FROM Assessments
    GROUP BY StudentID
),
WeakTopic AS (
    SELECT
        StudentID,
        TopicName,
        AvgNetScore
    FROM (
        SELECT
            s.StudentID,
            t.TopicName,
            AVG(a.NetScore) AS AvgNetScore,
            ROW_NUMBER() OVER (
                PARTITION BY s.StudentID
                ORDER BY AVG(a.NetScore) ASC
            ) AS rn
        FROM Students s
        INNER JOIN Assessments a
            ON s.StudentID = a.StudentID
        INNER JOIN Topics t
            ON a.TopicID = t.TopicID
        GROUP BY
            s.StudentID,
            t.TopicName
    ) x
    WHERE rn = 1
)
SELECT
    s.StudentCode,
    s.StudentName,
    s.GradeLevel,
    s.ExamType,
    ISNULL(ls.TotalLessons, 0) AS TotalLessons,
    ISNULL(ls.AttendedLessons, 0) AS AttendedLessons,
    CAST(ISNULL(hs.AvgHomeworkCompletion, 0) AS DECIMAL(5,2)) AS AvgHomeworkCompletion,
    CAST(ISNULL(a.AvgNetScore, 0) AS DECIMAL(5,2)) AS AvgNetScore,
    ISNULL(wt.TopicName, 'No assessment yet') AS PriorityTopicForImprovement
FROM Students s
LEFT JOIN LessonSummary ls
    ON s.StudentID = ls.StudentID
LEFT JOIN HomeworkSummary hs
    ON s.StudentID = hs.StudentID
LEFT JOIN AssessmentSummary a
    ON s.StudentID = a.StudentID
LEFT JOIN WeakTopic wt
    ON s.StudentID = wt.StudentID
ORDER BY
    s.StudentCode;
GO

-- ============================================================
-- 11. Exam Type Summary
-- Business Question:
-- How do LGS, TYT, and AYT students compare?
-- ============================================================

SELECT
    s.ExamType,
    COUNT(DISTINCT s.StudentID) AS StudentCount,
    COUNT(DISTINCT l.LessonID) AS TotalLessons,
    CAST(AVG(h.CompletionRate) AS DECIMAL(5,2)) AS AvgHomeworkCompletion,
    CAST(AVG(a.NetScore) AS DECIMAL(5,2)) AS AvgNetScore
FROM Students s
LEFT JOIN Lessons l
    ON s.StudentID = l.StudentID
LEFT JOIN Homework h
    ON s.StudentID = h.StudentID
LEFT JOIN Assessments a
    ON s.StudentID = a.StudentID
GROUP BY
    s.ExamType
ORDER BY
    AvgNetScore DESC;
GO

-- ============================================================
-- 12. Topic Mastery Distribution
-- Business Question:
-- What is the distribution of topic mastery levels?
-- ============================================================

SELECT
    sub.SubjectName,
    t.TopicName,
    tm.MasteryLevel,
    COUNT(*) AS StudentCount
FROM TopicMastery tm
INNER JOIN Topics t
    ON tm.TopicID = t.TopicID
INNER JOIN Subjects sub
    ON t.SubjectID = sub.SubjectID
GROUP BY
    sub.SubjectName,
    t.TopicName,
    tm.MasteryLevel
ORDER BY
    sub.SubjectName,
    t.TopicName,
    tm.MasteryLevel;
GO
