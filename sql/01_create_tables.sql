-- ============================================================
-- Project: Student Progress Analytics System
-- File: 01_create_tables.sql
-- Description: Creates relational database tables for student progress tracking
-- Database: SQL Server
-- ============================================================

CREATE DATABASE StudentProgressDB;
GO

USE StudentProgressDB;
GO

-- ============================================================
-- 1. Students Table
-- ============================================================

CREATE TABLE Students (
    StudentID INT IDENTITY(1,1) PRIMARY KEY,
    StudentCode NVARCHAR(20) NOT NULL UNIQUE,
    StudentName NVARCHAR(100) NOT NULL,
    GradeLevel NVARCHAR(20) NOT NULL,
    ExamType NVARCHAR(20) NOT NULL,
    StartDate DATE NOT NULL,
    Status NVARCHAR(20) NOT NULL
);
GO

-- ============================================================
-- 2. Subjects Table
-- ============================================================

CREATE TABLE Subjects (
    SubjectID INT IDENTITY(1,1) PRIMARY KEY,
    SubjectName NVARCHAR(50) NOT NULL UNIQUE
);
GO

-- ============================================================
-- 3. Topics Table
-- ============================================================

CREATE TABLE Topics (
    TopicID INT IDENTITY(1,1) PRIMARY KEY,
    SubjectID INT NOT NULL,
    TopicName NVARCHAR(100) NOT NULL,
    GradeLevel NVARCHAR(20) NOT NULL,
    ExamType NVARCHAR(20) NOT NULL,

    CONSTRAINT FK_Topics_Subjects
        FOREIGN KEY (SubjectID) REFERENCES Subjects(SubjectID)
);
GO

-- ============================================================
-- 4. Lessons Table
-- ============================================================

CREATE TABLE Lessons (
    LessonID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL,
    TopicID INT NOT NULL,
    LessonDate DATE NOT NULL,
    DurationMinutes INT NOT NULL,
    AttendanceStatus NVARCHAR(20) NOT NULL,
    TeacherNote NVARCHAR(500),

    CONSTRAINT FK_Lessons_Students
        FOREIGN KEY (StudentID) REFERENCES Students(StudentID),

    CONSTRAINT FK_Lessons_Topics
        FOREIGN KEY (TopicID) REFERENCES Topics(TopicID)
);
GO

-- ============================================================
-- 5. Homework Table
-- ============================================================

CREATE TABLE Homework (
    HomeworkID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL,
    TopicID INT NOT NULL,
    AssignedDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    QuestionCount INT NOT NULL,
    CompletedQuestionCount INT NOT NULL,
    HomeworkStatus NVARCHAR(20) NOT NULL,

    CompletionRate AS 
        CAST(
            CASE 
                WHEN QuestionCount = 0 THEN 0
                ELSE (CompletedQuestionCount * 100.0 / QuestionCount)
            END AS DECIMAL(5,2)
        ),

    CONSTRAINT FK_Homework_Students
        FOREIGN KEY (StudentID) REFERENCES Students(StudentID),

    CONSTRAINT FK_Homework_Topics
        FOREIGN KEY (TopicID) REFERENCES Topics(TopicID)
);
GO

-- ============================================================
-- 6. Assessments Table
-- ============================================================

CREATE TABLE Assessments (
    AssessmentID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL,
    TopicID INT NOT NULL,
    AssessmentDate DATE NOT NULL,
    AssessmentType NVARCHAR(50) NOT NULL,
    CorrectAnswers INT NOT NULL,
    WrongAnswers INT NOT NULL,
    BlankAnswers INT NOT NULL,

    NetScore AS 
        CAST((CorrectAnswers - (WrongAnswers * 0.25)) AS DECIMAL(5,2)),

    CONSTRAINT FK_Assessments_Students
        FOREIGN KEY (StudentID) REFERENCES Students(StudentID),

    CONSTRAINT FK_Assessments_Topics
        FOREIGN KEY (TopicID) REFERENCES Topics(TopicID)
);
GO

-- ============================================================
-- 7. Topic Mastery Table
-- ============================================================

CREATE TABLE TopicMastery (
    MasteryID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL,
    TopicID INT NOT NULL,
    MasteryLevel NVARCHAR(20) NOT NULL,
    LastUpdated DATE NOT NULL,

    CONSTRAINT FK_TopicMastery_Students
        FOREIGN KEY (StudentID) REFERENCES Students(StudentID),

    CONSTRAINT FK_TopicMastery_Topics
        FOREIGN KEY (TopicID) REFERENCES Topics(TopicID)
);
GO
