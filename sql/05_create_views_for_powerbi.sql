-- ============================================================
-- Project: Student Progress Analytics System
-- File: 05_create_views_for_powerbi.sql
-- Description: Creates SQL views for Power BI dashboard reporting
-- Database: SQL Server
-- ============================================================

USE StudentProgressDB;
GO

-- ============================================================
-- 1. Student Progress Overview View
-- Power BI Usage:
-- General student-level KPI cards and overview dashboard
-- ============================================================

IF OBJECT_ID('dbo.vw_student_progress_overview', 'V') IS NOT NULL
    DROP VIEW dbo.vw_student_progress_overview;
GO

CREATE VIEW dbo.vw_student_progress_overview AS
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
        SUM(QuestionCount) AS TotalQuestionsAssigned,
        SUM(CompletedQuestionCount) AS TotalQuestionsCompleted,
        AVG(CompletionRate) AS AvgHomeworkCompletion
    FROM Homework
    GROUP BY StudentID
),
AssessmentSummary AS (
    SELECT
        StudentID,
        COUNT(AssessmentID) AS TotalAssessments,
        AVG(NetScore) AS AvgNetScore,
        MAX(NetScore) AS BestNetScore,
        MIN(NetScore) AS LowestNetScore
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
    s.StudentID,
    s.StudentCode,
    s.StudentName,
    s.GradeLevel,
    s.ExamType,
    s.StartDate,
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
    ISNULL(hs.TotalQuestionsAssigned, 0) AS TotalQuestionsAssigned,
    ISNULL(hs.TotalQuestionsCompleted, 0) AS TotalQuestionsCompleted,
    CAST(ISNULL(hs.AvgHomeworkCompletion, 0) AS DECIMAL(5,2)) AS AvgHomeworkCompletion,

    ISNULL(a.TotalAssessments, 0) AS TotalAssessments,
    CAST(ISNULL(a.AvgNetScore, 0) AS DECIMAL(5,2)) AS AvgNetScore,
    CAST(ISNULL(a.BestNetScore, 0) AS DECIMAL(5,2)) AS BestNetScore,
    CAST(ISNULL(a.LowestNetScore, 0) AS DECIMAL(5,2)) AS LowestNetScore,

    CAST(ISNULL(ms.AvgMasteryScore, 0) AS DECIMAL(5,2)) AS AvgMasteryScore
FROM Students s
LEFT JOIN LessonSummary ls
    ON s.StudentID = ls.StudentID
LEFT JOIN HomeworkSummary hs
    ON s.StudentID = hs.StudentID
LEFT JOIN AssessmentSummary a
    ON s.StudentID = a.StudentID
LEFT JOIN MasterySummary ms
    ON s.StudentID = ms.StudentID;
GO

-- ============================================================
-- 2. Student Topic Performance View
-- Power BI Usage:
-- Topic-based performance matrix and weak topic analysis
-- ============================================================

IF OBJECT_ID('dbo.vw_student_topic_performance', 'V') IS NOT NULL
    DROP VIEW dbo.vw_student_topic_performance;
GO

CREATE VIEW dbo.vw_student_topic_performance AS
WITH StudentTopicBase AS (
    SELECT StudentID, TopicID FROM Lessons
    UNION
    SELECT StudentID, TopicID FROM Homework
    UNION
    SELECT StudentID, TopicID FROM Assessments
    UNION
    SELECT StudentID, TopicID FROM TopicMastery
),
LessonAgg AS (
    SELECT
        StudentID,
        TopicID,
        COUNT(LessonID) AS LessonCount,
        SUM(CASE WHEN AttendanceStatus = 'Attended' THEN 1 ELSE 0 END) AS AttendedLessonCount
    FROM Lessons
    GROUP BY StudentID, TopicID
),
HomeworkAgg AS (
    SELECT
        StudentID,
        TopicID,
        COUNT(HomeworkID) AS HomeworkCount,
        AVG(CompletionRate) AS AvgHomeworkCompletion
    FROM Homework
    GROUP BY StudentID, TopicID
),
AssessmentAgg AS (
    SELECT
        StudentID,
        TopicID,
        COUNT(AssessmentID) AS AssessmentCount,
        AVG(NetScore) AS AvgNetScore,
        SUM(CorrectAnswers) AS TotalCorrectAnswers,
        SUM(WrongAnswers) AS TotalWrongAnswers,
        SUM(BlankAnswers) AS TotalBlankAnswers
    FROM Assessments
    GROUP BY StudentID, TopicID
)
SELECT
    s.StudentID,
    s.StudentCode,
    s.StudentName,
    s.GradeLevel,
    s.ExamType,
    sub.SubjectName,
    t.TopicID,
    t.TopicName,

    ISNULL(la.LessonCount, 0) AS LessonCount,
    ISNULL(la.AttendedLessonCount, 0) AS AttendedLessonCount,

    ISNULL(ha.HomeworkCount, 0) AS HomeworkCount,
    CAST(ISNULL(ha.AvgHomeworkCompletion, 0) AS DECIMAL(5,2)) AS AvgHomeworkCompletion,

    ISNULL(aa.AssessmentCount, 0) AS AssessmentCount,
    CAST(ISNULL(aa.AvgNetScore, 0) AS DECIMAL(5,2)) AS AvgNetScore,
    ISNULL(aa.TotalCorrectAnswers, 0) AS TotalCorrectAnswers,
    ISNULL(aa.TotalWrongAnswers, 0) AS TotalWrongAnswers,
    ISNULL(aa.TotalBlankAnswers, 0) AS TotalBlankAnswers,

    ISNULL(tm.MasteryLevel, 'Not Evaluated') AS MasteryLevel,

    CASE 
        WHEN ISNULL(aa.AvgNetScore, 0) < 12 
          OR ISNULL(ha.AvgHomeworkCompletion, 0) < 70
          OR tm.MasteryLevel = 'Low'
        THEN 'Needs Improvement'
        WHEN ISNULL(aa.AvgNetScore, 0) >= 16 
          AND ISNULL(ha.AvgHomeworkCompletion, 0) >= 85
        THEN 'Strong'
        ELSE 'Moderate'
    END AS TopicStatus
FROM StudentTopicBase stb
INNER JOIN Students s
    ON stb.StudentID = s.StudentID
INNER JOIN Topics t
    ON stb.TopicID = t.TopicID
INNER JOIN Subjects sub
    ON t.SubjectID = sub.SubjectID
LEFT JOIN LessonAgg la
    ON stb.StudentID = la.StudentID
    AND stb.TopicID = la.TopicID
LEFT JOIN HomeworkAgg ha
    ON stb.StudentID = ha.StudentID
    AND stb.TopicID = ha.TopicID
LEFT JOIN AssessmentAgg aa
    ON stb.StudentID = aa.StudentID
    AND stb.TopicID = aa.TopicID
LEFT JOIN TopicMastery tm
    ON stb.StudentID = tm.StudentID
    AND stb.TopicID = tm.TopicID;
GO

-- ============================================================
-- 3. Topic Performance Summary View
-- Power BI Usage:
-- Overall topic difficulty and performance analysis
-- ============================================================

IF OBJECT_ID('dbo.vw_topic_performance_summary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_topic_performance_summary;
GO

CREATE VIEW dbo.vw_topic_performance_summary AS
WITH HomeworkTopicAgg AS (
    SELECT
        TopicID,
        COUNT(HomeworkID) AS HomeworkCount,
        AVG(CompletionRate) AS AvgHomeworkCompletion
    FROM Homework
    GROUP BY TopicID
),
AssessmentTopicAgg AS (
    SELECT
        TopicID,
        COUNT(AssessmentID) AS AssessmentCount,
        COUNT(DISTINCT StudentID) AS StudentCount,
        AVG(NetScore) AS AvgNetScore
    FROM Assessments
    GROUP BY TopicID
),
MasteryTopicAgg AS (
    SELECT
        TopicID,
        SUM(CASE WHEN MasteryLevel = 'Low' THEN 1 ELSE 0 END) AS LowMasteryCount,
        SUM(CASE WHEN MasteryLevel = 'Medium' THEN 1 ELSE 0 END) AS MediumMasteryCount,
        SUM(CASE WHEN MasteryLevel = 'High' THEN 1 ELSE 0 END) AS HighMasteryCount
    FROM TopicMastery
    GROUP BY TopicID
)
SELECT
    sub.SubjectName,
    t.TopicID,
    t.TopicName,
    t.GradeLevel,
    t.ExamType,

    ISNULL(ata.StudentCount, 0) AS StudentCount,
    ISNULL(ata.AssessmentCount, 0) AS AssessmentCount,
    CAST(ISNULL(ata.AvgNetScore, 0) AS DECIMAL(5,2)) AS AvgNetScore,

    ISNULL(hta.HomeworkCount, 0) AS HomeworkCount,
    CAST(ISNULL(hta.AvgHomeworkCompletion, 0) AS DECIMAL(5,2)) AS AvgHomeworkCompletion,

    ISNULL(mta.LowMasteryCount, 0) AS LowMasteryCount,
    ISNULL(mta.MediumMasteryCount, 0) AS MediumMasteryCount,
    ISNULL(mta.HighMasteryCount, 0) AS HighMasteryCount,

    CASE
        WHEN ISNULL(ata.AvgNetScore, 0) < 12 THEN 'Difficult Topic'
        WHEN ISNULL(ata.AvgNetScore, 0) >= 16 THEN 'Strong Topic'
        ELSE 'Moderate Topic'
    END AS TopicDifficultyStatus
FROM Topics t
INNER JOIN Subjects sub
    ON t.SubjectID = sub.SubjectID
LEFT JOIN HomeworkTopicAgg hta
    ON t.TopicID = hta.TopicID
LEFT JOIN AssessmentTopicAgg ata
    ON t.TopicID = ata.TopicID
LEFT JOIN MasteryTopicAgg mta
    ON t.TopicID = mta.TopicID;
GO

-- ============================================================
-- 4. Weekly Progress View
-- Power BI Usage:
-- Line charts for student performance trend over time
-- ============================================================

IF OBJECT_ID('dbo.vw_weekly_progress', 'V') IS NOT NULL
    DROP VIEW dbo.vw_weekly_progress;
GO

CREATE VIEW dbo.vw_weekly_progress AS
SELECT
    s.StudentID,
    s.StudentCode,
    s.StudentName,
    s.ExamType,
    DATEPART(YEAR, a.AssessmentDate) AS AssessmentYear,
    DATEPART(WEEK, a.AssessmentDate) AS AssessmentWeek,
    MIN(a.AssessmentDate) AS WeekStartDate,
    COUNT(a.AssessmentID) AS AssessmentCount,
    CAST(AVG(a.NetScore) AS DECIMAL(5,2)) AS AvgWeeklyNetScore,
    CAST(AVG(a.CorrectAnswers) AS DECIMAL(5,2)) AS AvgCorrectAnswers,
    CAST(AVG(a.WrongAnswers) AS DECIMAL(5,2)) AS AvgWrongAnswers
FROM Students s
INNER JOIN Assessments a
    ON s.StudentID = a.StudentID
GROUP BY
    s.StudentID,
    s.StudentCode,
    s.StudentName,
    s.ExamType,
    DATEPART(YEAR, a.AssessmentDate),
    DATEPART(WEEK, a.AssessmentDate);
GO

-- ============================================================
-- 5. Students Requiring Attention View
-- Power BI Usage:
-- Risk table for teacher follow-up
-- ============================================================

IF OBJECT_ID('dbo.vw_students_requiring_attention', 'V') IS NOT NULL
    DROP VIEW dbo.vw_students_requiring_attention;
GO

CREATE VIEW dbo.vw_students_requiring_attention AS
WITH StudentKPIs AS (
    SELECT
        StudentID,
        StudentCode,
        StudentName,
        GradeLevel,
        ExamType,
        Status,
        AttendanceRate,
        AvgHomeworkCompletion,
        AvgNetScore,
        AvgMasteryScore
    FROM dbo.vw_student_progress_overview
)
SELECT
    StudentID,
    StudentCode,
    StudentName,
    GradeLevel,
    ExamType,
    Status,
    AttendanceRate,
    AvgHomeworkCompletion,
    AvgNetScore,
    AvgMasteryScore,

    CASE
        WHEN AttendanceRate < 80 THEN 'Attendance risk'
        WHEN AvgHomeworkCompletion < 70 THEN 'Low homework completion'
        WHEN AvgNetScore < 12 THEN 'Low assessment performance'
        WHEN AvgMasteryScore < 2 THEN 'Low topic mastery'
        ELSE 'On track'
    END AS RiskReason,

    CASE
        WHEN AttendanceRate < 80 
          OR AvgHomeworkCompletion < 70
          OR AvgNetScore < 12
          OR AvgMasteryScore < 2
        THEN 'Needs Follow-up'
        ELSE 'On Track'
    END AS FollowUpStatus
FROM StudentKPIs
WHERE AttendanceRate < 80
   OR AvgHomeworkCompletion < 70
   OR AvgNetScore < 12
   OR AvgMasteryScore < 2;
GO

-- ============================================================
-- 6. Parent Report Summary View
-- Power BI Usage:
-- Parent-friendly monthly/student report page
-- ============================================================

IF OBJECT_ID('dbo.vw_parent_report_summary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_parent_report_summary;
GO

CREATE VIEW dbo.vw_parent_report_summary AS
WITH WeakTopic AS (
    SELECT
        StudentID,
        TopicName,
        AvgNetScore
    FROM (
        SELECT
            stp.StudentID,
            stp.TopicName,
            stp.AvgNetScore,
            ROW_NUMBER() OVER (
                PARTITION BY stp.StudentID
                ORDER BY stp.AvgNetScore ASC, stp.AvgHomeworkCompletion ASC
            ) AS rn
        FROM dbo.vw_student_topic_performance stp
        WHERE stp.AssessmentCount > 0
    ) x
    WHERE rn = 1
),
StrongTopic AS (
    SELECT
        StudentID,
        TopicName,
        AvgNetScore
    FROM (
        SELECT
            stp.StudentID,
            stp.TopicName,
            stp.AvgNetScore,
            ROW_NUMBER() OVER (
                PARTITION BY stp.StudentID
                ORDER BY stp.AvgNetScore DESC, stp.AvgHomeworkCompletion DESC
            ) AS rn
        FROM dbo.vw_student_topic_performance stp
        WHERE stp.AssessmentCount > 0
    ) x
    WHERE rn = 1
)
SELECT
    spo.StudentID,
    spo.StudentCode,
    spo.StudentName,
    spo.GradeLevel,
    spo.ExamType,
    spo.Status,

    spo.TotalLessons,
    spo.AttendedLessons,
    spo.AbsentLessons,
    spo.AttendanceRate,

    spo.TotalHomework,
    spo.AvgHomeworkCompletion,

    spo.TotalAssessments,
    spo.AvgNetScore,
    spo.BestNetScore,
    spo.LowestNetScore,

    spo.AvgMasteryScore,

    ISNULL(wt.TopicName, 'No assessment yet') AS PriorityTopicForImprovement,
    ISNULL(st.TopicName, 'No assessment yet') AS StrongestTopic,

    CASE
        WHEN spo.AvgHomeworkCompletion >= 85 
          AND spo.AttendanceRate >= 90
          AND spo.AvgNetScore >= 16
        THEN 'Strong progress'
        WHEN spo.AvgHomeworkCompletion < 70
          OR spo.AttendanceRate < 80
          OR spo.AvgNetScore < 12
        THEN 'Needs closer follow-up'
        ELSE 'Progressing steadily'
    END AS ParentReportStatus
FROM dbo.vw_student_progress_overview spo
LEFT JOIN WeakTopic wt
    ON spo.StudentID = wt.StudentID
LEFT JOIN StrongTopic st
    ON spo.StudentID = st.StudentID;
GO

-- ============================================================
-- 7. Homework Detail View
-- Power BI Usage:
-- Homework completion charts and detail table
-- ============================================================

IF OBJECT_ID('dbo.vw_homework_detail', 'V') IS NOT NULL
    DROP VIEW dbo.vw_homework_detail;
GO

CREATE VIEW dbo.vw_homework_detail AS
SELECT
    h.HomeworkID,
    s.StudentID,
    s.StudentCode,
    s.StudentName,
    s.GradeLevel,
    s.ExamType,
    sub.SubjectName,
    t.TopicName,
    h.AssignedDate,
    h.DueDate,
    h.QuestionCount,
    h.CompletedQuestionCount,
    h.CompletionRate,
    h.HomeworkStatus
FROM Homework h
INNER JOIN Students s
    ON h.StudentID = s.StudentID
INNER JOIN Topics t
    ON h.TopicID = t.TopicID
INNER JOIN Subjects sub
    ON t.SubjectID = sub.SubjectID;
GO

-- ============================================================
-- 8. Assessment Detail View
-- Power BI Usage:
-- Assessment detail table and drill-through pages
-- ============================================================

IF OBJECT_ID('dbo.vw_assessment_detail', 'V') IS NOT NULL
    DROP VIEW dbo.vw_assessment_detail;
GO

CREATE VIEW dbo.vw_assessment_detail AS
SELECT
    a.AssessmentID,
    s.StudentID,
    s.StudentCode,
    s.StudentName,
    s.GradeLevel,
    s.ExamType,
    sub.SubjectName,
    t.TopicName,
    a.AssessmentDate,
    a.AssessmentType,
    a.CorrectAnswers,
    a.WrongAnswers,
    a.BlankAnswers,
    a.NetScore
FROM Assessments a
INNER JOIN Students s
    ON a.StudentID = s.StudentID
INNER JOIN Topics t
    ON a.TopicID = t.TopicID
INNER JOIN Subjects sub
    ON t.SubjectID = sub.SubjectID;
GO

-- ============================================================
-- 9. Quick View Control Queries
-- ============================================================

SELECT 'vw_student_progress_overview' AS ViewName, COUNT(*) AS RecordCount 
FROM dbo.vw_student_progress_overview
UNION ALL
SELECT 'vw_student_topic_performance', COUNT(*) 
FROM dbo.vw_student_topic_performance
UNION ALL
SELECT 'vw_topic_performance_summary', COUNT(*) 
FROM dbo.vw_topic_performance_summary
UNION ALL
SELECT 'vw_weekly_progress', COUNT(*) 
FROM dbo.vw_weekly_progress
UNION ALL
SELECT 'vw_students_requiring_attention', COUNT(*) 
FROM dbo.vw_students_requiring_attention
UNION ALL
SELECT 'vw_parent_report_summary', COUNT(*) 
FROM dbo.vw_parent_report_summary
UNION ALL
SELECT 'vw_homework_detail', COUNT(*) 
FROM dbo.vw_homework_detail
UNION ALL
SELECT 'vw_assessment_detail', COUNT(*) 
FROM dbo.vw_assessment_detail;
GO
