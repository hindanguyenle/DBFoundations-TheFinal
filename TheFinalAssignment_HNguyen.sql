--**********************************************************************************************--
-- Title: ITFnd130Final
-- Author: HNguyen
-- Desc: This file demonstrates how to design and create; 
--       tables, views, and stored procedures
-- Change Log: When,Who,What
-- 2025-08-23,HNguyen,Created File
--***********************************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'ITFnd130FinalDB_HNguyen')
	 Begin 
	  Alter Database [ITFnd130FinalDB_HNguyen] set Single_user With Rollback Immediate;
	  Drop Database ITFnd130FinalDB_HNguyen;
	 End
	Create Database ITFnd130FinalDB_HNguyen;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use ITFnd130FinalDB_HNguyen;

-- Create Tables (Review Module 01) --

CREATE TABLE Courses (
    [CourseID] INT IDENTITY(1,1) NOT NULL,
    [CourseName] NVARCHAR(100) NOT NULL,
    [CourseStartDate] DATE NULL,
    [CourseEndDate] DATE NULL,
    [CourseStartTime] TIME NULL,
    [CourseEndTime] TIME NULL,
    [CourseDaysOfWeek] NVARCHAR(100) NULL,
    [CourseCurrentPrice] MONEY NULL
);

CREATE TABLE Students (
    [StudentID] INT IDENTITY(1,1) NOT NULL,
    [StudentNumber] NVARCHAR(100) NOT NULL,
    [StudentFirstName] NVARCHAR(100) NOT NULL,
    [StudentLastName] NVARCHAR(100) NOT NULL,
    [StudentEmail] NVARCHAR(100) NOT NULL,
    [StudentPhone] NVARCHAR(12) NOT NULL,
    [StudentAddress1] NVARCHAR(100) NOT NULL,
    [StudentAddress2] NVARCHAR(100) NULL,
    [StudentCity] NVARCHAR(100) NOT NULL,
    [StudentStateCode] NVARCHAR(2) NOT NULL,
    [StudentZipCode] NVARCHAR(10) NOT NULL
);

CREATE TABLE Enrollments (
    [EnrollmentID] INT IDENTITY(1,1) NOT NULL,
    [StudentID] INT NOT NULL,
    [CourseID] INT NOT NULL,
    [EnrollmentDateTime] DATETIME NOT NULL,
    [EnrollmentPrice] MONEY NOT NULL
);

-- Add Constraints (Review Module 02) --

-- Courses Table Constraints
ALTER TABLE Courses
ADD CONSTRAINT PK_Courses PRIMARY KEY (CourseID);

ALTER TABLE Courses
ADD CONSTRAINT UQ_CourseName UNIQUE (CourseName);

ALTER TABLE Courses
ADD CONSTRAINT CHK_CourseEndDateGreaterThanStart CHECK (CourseEndDate IS NULL OR CourseEndDate > CourseStartDate);

ALTER TABLE Courses
ADD CONSTRAINT CHK_CourseStartDateLessThanEnd CHECK (CourseStartDate IS NULL OR CourseStartDate < CourseEndDate);

ALTER TABLE Courses
ADD CONSTRAINT CHK_CourseEndTimeGreaterThanStart CHECK (CourseEndTime IS NULL OR CourseEndTime > CourseStartTime);

ALTER TABLE Courses
ADD CONSTRAINT CHK_CourseStartTimeLessThanEnd CHECK (CourseStartTime IS NULL OR CourseStartTime < CourseEndTime);

-- Students Table Constraints
ALTER TABLE Students
ADD CONSTRAINT PK_Students PRIMARY KEY (StudentID);

ALTER TABLE Students
ADD CONSTRAINT UQ_StudentNumber UNIQUE (StudentNumber);

ALTER TABLE Students
ADD CONSTRAINT UQ_StudentEmail UNIQUE (StudentEmail);

ALTER TABLE Students
ADD CONSTRAINT CHK_StudentEmail CHECK (StudentEmail LIKE '%_@%_._%');

ALTER TABLE Students
ADD CONSTRAINT CHK_StudentZipCode CHECK (StudentZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]' 
    OR StudentZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' );

ALTER TABLE Students 
ADD CONSTRAINT CHK_StudentPhone CHECK (StudentPhone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')

-- Enrollments Table Constraints
ALTER TABLE Enrollments
ADD CONSTRAINT FK_Enrollments_Student FOREIGN KEY (StudentID) REFERENCES Students(StudentID);

ALTER TABLE Enrollments
ADD CONSTRAINT FK_Enrollments_Course FOREIGN KEY (CourseID) REFERENCES Courses(CourseID);

ALTER TABLE Enrollments
ADD CONSTRAINT DF_EnrollmentDateTime DEFAULT GETDATE() FOR EnrollmentDateTime;

ALTER TABLE Enrollments
ADD CONSTRAINT CHK_EnrollmentPriceZeroOrHigher CHECK ([EnrollmentPrice] >= 0);

ALTER TABLE Enrollments
ADD CONSTRAINT UQ_StudentCourse UNIQUE (StudentID, CourseID);

-- Adding Validation Funtions

go

CREATE OR ALTER FUNCTION dbo.fGetCourseStartDate
(@CourseID int)
RETURNS DATE
AS
    BEGIN
        RETURN (SELECT CourseStartDate
                FROM Courses
                WHERE Courses.CourseID = @CourseID)
    END

go

ALTER TABLE Enrollments
ADD CONSTRAINT CHK_EnrollmentDateTimeBeforeStartDate
CHECK (EnrollmentDateTime <= dbo.fGetCourseStartDate(CourseID));

-- Add Views (Review Module 03 and 06) --

GO

CREATE OR ALTER VIEW vCourses
WITH SCHEMABINDING
AS
SELECT
    CourseID,
    CourseName,
    CourseStartDate,
    CourseEndDate,
    CourseStartTime,
    CourseEndTime,
    CourseDaysOfWeek,
    CourseCurrentPrice
FROM dbo.Courses;
GO

CREATE OR ALTER VIEW vStudents
WITH SCHEMABINDING
AS
SELECT
    StudentID,
    StudentNumber,
    StudentFirstName,
    StudentLastName,
    StudentEmail,
    StudentPhone,
    StudentAddress1,
    StudentAddress2,
    StudentCity,
    StudentStateCode,
    StudentZipCode
FROM dbo.Students;
GO

CREATE OR ALTER VIEW vEnrollments
WITH SCHEMABINDING
AS
SELECT
    EnrollmentID,
    StudentID,
    CourseID,
    EnrollmentDateTime,
    EnrollmentPrice
FROM dbo.Enrollments;
GO

CREATE OR ALTER VIEW dbo.vStudentCourseEnrollments
AS
SELECT
    E.EnrollmentID,
    E.EnrollmentDateTime,
    E.EnrollmentPrice,
    S.StudentID,
    S.StudentNumber,
    S.StudentFirstName,
    S.StudentLastName,
    S.StudentEmail,
    S.StudentPhone,
    S.StudentAddress1,
    S.StudentAddress2,
    S.StudentCity,
    S.StudentStateCode,
    S.StudentZipCode,
    C.CourseID,
    C.CourseName,
    C.CourseStartDate,
    C.CourseEndDate,
    C.CourseStartTime,
    C.CourseEndTime,
    C.CourseDaysOfWeek,
    C.CourseCurrentPrice
FROM dbo.vEnrollments AS E
JOIN dbo.vStudents AS S
    ON E.StudentID = S.StudentID
JOIN dbo.vCourses AS C
    ON E.CourseID = C.CourseID;
GO

--< Test Tables by adding Sample Data >--  

-- Insert sample data into Courses
INSERT INTO Courses 
    (CourseName, CourseStartDate, CourseEndDate, CourseStartTime, CourseEndTime, CourseDaysOfWeek, CourseCurrentPrice)
VALUES 
('SQL1 - Winter 2017', '2017-01-10', '2017-01-24', '18:00', '20:50', 'T', 399),
('SQL2 - Winter 2017', '2017-01-31', '2017-02-14', '18:00', '20:50', 'T', 399);

-- Insert sample data into Students
INSERT INTO Students 
    (StudentNumber, StudentFirstName, StudentLastName, StudentEmail, StudentPhone,
     StudentAddress1, StudentCity, StudentStateCode, StudentZipCode)
VALUES
('B-Smith-071','Bob','Smith','Bsmith@HipMail.com','2061112222',
 '123 Main St.','Seattle','WA','98001'),
('S-Jones-003','Sue','Jones','SueJones@YaYou.com','2062314321',
 '333 1st Ave.','Seattle','WA','98001');

-- Insert sample data into Enrollments
-- Assuming auto-increment IDs: Bob = StudentID 1, Sue = StudentID 2
-- Course 1 = SQL1, Course 2 = SQL2

INSERT INTO Enrollments 
    (StudentID, CourseID, EnrollmentDateTime, EnrollmentPrice)
VALUES
(1, 1, '2017-01-03', 399),  -- Bob Smith in SQL1
(2, 1, '2016-12-14', 349),  -- Sue Jones in SQL1
(1, 2, '2017-01-12', 399),  -- Bob Smith in SQL2
(2, 2, '2016-12-14', 349);  -- Sue Jones in SQL2

/* Instead of using 1,2, we can also explicity code the column data. 
   This helps to avoid confusion, but is lengthy.

-- Bob Smith in SQL1
INSERT INTO Enrollments (StudentID, CourseID, EnrollmentDateTime, EnrollmentPrice)
VALUES (
    (SELECT StudentID 
     FROM Students 
     WHERE StudentFirstName = 'Bob' AND StudentLastName = 'Smith'),
    (SELECT CourseID 
     FROM Courses 
     WHERE CourseName = 'SQL1 - Winter 2017'),
    '2017-01-03',
    399
);

-- Sue Jones in SQL1
INSERT INTO Enrollments (StudentID, CourseID, EnrollmentDateTime, EnrollmentPrice)
VALUES (
    (SELECT StudentID 
     FROM Students 
     WHERE StudentFirstName = 'Sue' AND StudentLastName = 'Jones'),
    (SELECT CourseID 
     FROM Courses 
     WHERE CourseName = 'SQL1 - Winter 2017'),
    '2016-12-14',
    349
);

-- Bob Smith in SQL2
INSERT INTO Enrollments (StudentID, CourseID, EnrollmentDateTime, EnrollmentPrice)
VALUES (
    (SELECT StudentID 
     FROM Students 
     WHERE StudentFirstName = 'Bob' AND StudentLastName = 'Smith'),
    (SELECT CourseID 
     FROM Courses 
     WHERE CourseName = 'SQL2 - Winter 2017'),
    '2017-01-12',
    399
);

-- Sue Jones in SQL2
INSERT INTO Enrollments (StudentID, CourseID, EnrollmentDateTime, EnrollmentPrice)
VALUES (
    (SELECT StudentID 
     FROM Students 
     WHERE StudentFirstName = 'Sue' AND StudentLastName = 'Jones'),
    (SELECT CourseID 
     FROM Courses 
     WHERE CourseName = 'SQL2 - Winter 2017'),
    '2016-12-14',
    349
);

*/

-- Add Stored Procedures (Review Module 04 and 08) --

-- ==============================================
-- Add Course Procedure
-- ==============================================
GO
CREATE OR ALTER PROCEDURE pAddCourse
    @CourseName NVARCHAR(100),
    @CourseStartDate DATE = NULL,
    @CourseEndDate DATE = NULL,
    @CourseStartTime TIME = NULL,
    @CourseEndTime TIME = NULL,
    @CourseDaysOfWeek NVARCHAR(100) = NULL,
    @CourseCurrentPrice MONEY = NULL,
    @NewCourseID INT OUTPUT
AS
BEGIN
    DECLARE @RC INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Courses (
            CourseName, CourseStartDate, CourseEndDate,
            CourseStartTime, CourseEndTime, CourseDaysOfWeek, CourseCurrentPrice
        )
        VALUES (
            @CourseName, @CourseStartDate, @CourseEndDate,
            @CourseStartTime, @CourseEndTime, @CourseDaysOfWeek, @CourseCurrentPrice
        );

        SET @NewCourseID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @RC = -1;
        THROW;
    END CATCH;

    RETURN @RC;
END;
GO

-- ==============================================
-- Update Course
-- ==============================================
GO
CREATE OR ALTER PROCEDURE pUpdateCourse
    @CourseID INT,
    @CourseName NVARCHAR(100),
    @CourseStartDate DATE = NULL,
    @CourseEndDate DATE = NULL,
    @CourseStartTime TIME = NULL,
    @CourseEndTime TIME = NULL,
    @CourseDaysOfWeek NVARCHAR(100) = NULL,
    @CourseCurrentPrice MONEY = NULL
AS
BEGIN
    DECLARE @RC INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Courses
        SET CourseName = @CourseName,
            CourseStartDate = @CourseStartDate,
            CourseEndDate = @CourseEndDate,
            CourseStartTime = @CourseStartTime,
            CourseEndTime = @CourseEndTime,
            CourseDaysOfWeek = @CourseDaysOfWeek,
            CourseCurrentPrice = @CourseCurrentPrice
        WHERE CourseID = @CourseID;

        SET @RC = @@ROWCOUNT; -- number of rows updated

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @RC = -1;
        THROW;
    END CATCH;

    RETURN @RC;
END;
GO

-- ==============================================
-- Delete Course
-- ==============================================
GO
CREATE OR ALTER PROCEDURE pDeleteCourse
    @CourseID INT
AS
BEGIN
    DECLARE @RC INT = 0; -- success by default

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Delete related enrollments first
        DELETE FROM Enrollments
        WHERE CourseID = @CourseID;

        -- Delete the course
        DELETE FROM Courses
        WHERE CourseID = @CourseID;

        SET @RC = @@ROWCOUNT; -- return # of courses deleted

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;
        SET @RC = -1;
        THROW;
    END CATCH;

    RETURN @RC;
END
GO

-- ==============================================
-- Add Student Procedure
-- ==============================================
GO
CREATE OR ALTER PROCEDURE pAddStudent
    @StudentNumber NVARCHAR(100),
    @StudentFirstName NVARCHAR(100),
    @StudentLastName NVARCHAR(100),
    @StudentEmail NVARCHAR(100),
    @StudentPhone NVARCHAR(12),
    @StudentAddress1 NVARCHAR(100),
    @StudentAddress2 NVARCHAR(100) = NULL,
    @StudentCity NVARCHAR(100),
    @StudentStateCode NVARCHAR(2),
    @StudentZipCode NVARCHAR(10),
    @NewStudentID INT OUTPUT
AS
BEGIN
    DECLARE @RC INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Students (
            StudentNumber, StudentFirstName, StudentLastName,
            StudentEmail, StudentPhone, StudentAddress1, StudentAddress2,
            StudentCity, StudentStateCode, StudentZipCode
        )
        VALUES (
            @StudentNumber, @StudentFirstName, @StudentLastName,
            @StudentEmail, @StudentPhone, @StudentAddress1, @StudentAddress2,
            @StudentCity, @StudentStateCode, @StudentZipCode
        );

        SET @NewStudentID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @RC = -1;
        THROW;
    END CATCH;

    RETURN @RC;
END;
GO

-- ==============================================
-- Update Student
-- ==============================================
GO
CREATE OR ALTER PROCEDURE pUpdateStudent
    @StudentID INT,
    @StudentNumber NVARCHAR(100),
    @StudentFirstName NVARCHAR(100),
    @StudentLastName NVARCHAR(100),
    @StudentEmail NVARCHAR(100),
    @StudentPhone NVARCHAR(12),
    @StudentAddress1 NVARCHAR(100),
    @StudentAddress2 NVARCHAR(100) = NULL,
    @StudentCity NVARCHAR(100),
    @StudentStateCode NVARCHAR(2),
    @StudentZipCode NVARCHAR(10)
AS
BEGIN
    DECLARE @RC INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Students
        SET StudentNumber = @StudentNumber,
            StudentFirstName = @StudentFirstName,
            StudentLastName = @StudentLastName,
            StudentEmail = @StudentEmail,
            StudentPhone = @StudentPhone,
            StudentAddress1 = @StudentAddress1,
            StudentAddress2 = @StudentAddress2,
            StudentCity = @StudentCity,
            StudentStateCode = @StudentStateCode,
            StudentZipCode = @StudentZipCode
        WHERE StudentID = @StudentID;

        SET @RC = @@ROWCOUNT;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @RC = -1;
        THROW;
    END CATCH;

    RETURN @RC;
END;
GO

-- ==============================================
-- Delete Student
-- ==============================================
GO
CREATE OR ALTER PROCEDURE pDeleteStudent
    @StudentID INT
AS
BEGIN
    DECLARE @RC INT = 0; -- success by default

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Delete related enrollments first
        DELETE FROM Enrollments
        WHERE StudentID = @StudentID;

        -- Delete the student
        DELETE FROM Students
        WHERE StudentID = @StudentID;

        SET @RC = @@ROWCOUNT; -- return # of students deleted

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;
        SET @RC = -1;
        THROW;
    END CATCH;

    RETURN @RC;
END
GO

-- ==============================================
-- Add Enrollment Procedure
-- ==============================================
GO
CREATE OR ALTER PROCEDURE pAddEnrollment
    @StudentID INT,
    @CourseID INT,
    @EnrollmentDateTime DATETIME = NULL,
    @EnrollmentPrice MONEY = NULL,
    @NewEnrollmentID INT OUTPUT
AS
BEGIN
    DECLARE @RC INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Enrollments (
            StudentID, CourseID, EnrollmentDateTime, EnrollmentPrice
        )
        VALUES (
            @StudentID, @CourseID,
            ISNULL(@EnrollmentDateTime, GETDATE()),
            @EnrollmentPrice
        );

        SET @NewEnrollmentID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @RC = -1;
        THROW;
    END CATCH;

    RETURN @RC;
END;
GO

-- ==============================================
-- Update Enrollment
-- ==============================================
GO
CREATE OR ALTER PROCEDURE pUpdateEnrollment
    @EnrollmentID INT,
    @StudentID INT,
    @CourseID INT,
    @EnrollmentDateTime DATETIME = NULL,
    @EnrollmentPrice MONEY = NULL
AS
BEGIN
    DECLARE @RC INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Enrollments
        SET StudentID = @StudentID,
            CourseID = @CourseID,
            EnrollmentDateTime = ISNULL(@EnrollmentDateTime, GETDATE()),
            EnrollmentPrice = @EnrollmentPrice
        WHERE EnrollmentID = @EnrollmentID;

        SET @RC = @@ROWCOUNT;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @RC = -1;
        THROW;
    END CATCH;

    RETURN @RC;
END;
GO

-- ==============================================
-- Delete Enrollment
-- ==============================================
GO
CREATE OR ALTER PROCEDURE pDeleteEnrollment
    @EnrollmentID INT
AS
BEGIN
    DECLARE @RC INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM Enrollments
        WHERE EnrollmentID = @EnrollmentID;

        SET @RC = @@ROWCOUNT;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;
        SET @RC = -1;
        THROW;
    END CATCH;

    RETURN @RC;
END
GO

-- =======================================
-- Lock down base tables
-- =======================================
DENY SELECT, INSERT, UPDATE, DELETE ON [dbo].[Courses]    TO PUBLIC;
DENY SELECT, INSERT, UPDATE, DELETE ON [dbo].[Students]   TO PUBLIC;
DENY SELECT, INSERT, UPDATE, DELETE ON [dbo].[Enrollments] TO PUBLIC;
GO

-- =======================================
-- Grant access only via views
-- =======================================
GRANT SELECT ON [dbo].[vCourses]    TO PUBLIC;
GRANT SELECT ON [dbo].[vStudents]   TO PUBLIC;
GRANT SELECT ON [dbo].[vEnrollments] TO PUBLIC;
GRANT SELECT ON [dbo].[vStudentCourseEnrollments] TO PUBLIC;
GO

-- =======================================
-- Grant execute access on stored procedures
-- =======================================
GRANT EXECUTE ON [dbo].[pAddStudent]       TO PUBLIC;
GRANT EXECUTE ON [dbo].[pUpdateStudent]    TO PUBLIC;
GRANT EXECUTE ON [dbo].[pDeleteStudent]    TO PUBLIC;

GRANT EXECUTE ON [dbo].[pAddCourse]        TO PUBLIC;
GRANT EXECUTE ON [dbo].[pUpdateCourse]     TO PUBLIC;
GRANT EXECUTE ON [dbo].[pDeleteCourse]     TO PUBLIC;

GRANT EXECUTE ON [dbo].[pAddEnrollment]    TO PUBLIC;
GRANT EXECUTE ON [dbo].[pUpdateEnrollment] TO PUBLIC;
GRANT EXECUTE ON [dbo].[pDeleteEnrollment] TO PUBLIC;
GO

-- =======================================
-- Test Sprocs  
-- =======================================

DECLARE @rc INT, 
        @newCourseID INT,
        @newStudentID INT,
        @newEnrollmentID INT;

-- =======================================
-- 1) ADD RECORDS
-- =======================================

-- Add a Course
EXEC @rc = pAddCourse
    @CourseName = 'SQL3 - Spring 2017',
    @CourseStartDate = '2017-04-05',
    @CourseEndDate = '2017-04-19',
    @CourseStartTime = '18:00',
    @CourseEndTime = '20:50',
    @CourseDaysOfWeek = 'W',
    @CourseCurrentPrice = 499,
    @NewCourseID = @newCourseID OUTPUT;

PRINT 'Rows Inserted (Course): ' + CAST(@rc AS NVARCHAR);
PRINT 'New CourseID = ' + CAST(@newCourseID AS NVARCHAR);

-- Add a Student
EXEC @rc = pAddStudent
    @StudentNumber = 'J-Doe-015',
    @StudentFirstName = 'John',
    @StudentLastName = 'Doe',
    @StudentEmail = 'jdoe@email.com',
    @StudentPhone = '2065557890',
    @StudentAddress1 = '500 University St.',
    @StudentCity = 'Seattle',
    @StudentStateCode = 'WA',
    @StudentZipCode = '98101',
    @NewStudentID = @newStudentID OUTPUT;

PRINT 'Rows Inserted (Student): ' + CAST(@rc AS NVARCHAR);
PRINT 'New StudentID = ' + CAST(@newStudentID AS NVARCHAR);

-- Add an Enrollment
EXEC @rc = pAddEnrollment
    @StudentID = @newStudentID,
    @CourseID = @newCourseID,
    @EnrollmentDateTime = '2017-03-29',
    @EnrollmentPrice = 499,
    @NewEnrollmentID = @newEnrollmentID OUTPUT;

PRINT 'Rows Inserted (Enrollment): ' + CAST(@rc AS NVARCHAR);
PRINT 'New EnrollmentID = ' + CAST(@newEnrollmentID AS NVARCHAR);

-- =======================================
-- 2) UPDATE RECORDS
-- =======================================

-- Update Course
EXEC @rc = pUpdateCourse
    @CourseID = @newCourseID,
    @CourseName = 'SQL3 - Updated Spring 2017',
    @CourseStartDate = '2017-04-10',
    @CourseEndDate = '2017-04-24',
    @CourseStartTime = '18:30',
    @CourseEndTime = '21:00',
    @CourseDaysOfWeek = 'MW',
    @CourseCurrentPrice = 550;
PRINT 'Rows Updated (Course): ' + CAST(@rc AS NVARCHAR);

-- Update Student
EXEC @rc = pUpdateStudent
    @StudentID = @newStudentID,
    @StudentNumber = 'J-Doe-015',
    @StudentFirstName = 'Johnny',
    @StudentLastName = 'Doe',
    @StudentEmail = 'johnny.doe@email.com',
    @StudentPhone = '2065550000',
    @StudentAddress1 = '501 University St.',
    @StudentAddress2 = 'Apt 2B',
    @StudentCity = 'Seattle',
    @StudentStateCode = 'WA',
    @StudentZipCode = '98102';
PRINT 'Rows Updated (Student): ' + CAST(@rc AS NVARCHAR);

-- Update Enrollment
EXEC @rc = pUpdateEnrollment
    @EnrollmentID = @newEnrollmentID,
    @StudentID = @newStudentID,
    @CourseID = @newCourseID,
    @EnrollmentDateTime = '2017-04-01',
    @EnrollmentPrice = 575;
PRINT 'Rows Updated (Enrollment): ' + CAST(@rc AS NVARCHAR);

-- =======================================
-- 3) DELETE RECORDS
-- =======================================

-- Delete Enrollment
EXEC @rc = pDeleteEnrollment @EnrollmentID = @newEnrollmentID;
PRINT 'Rows Deleted (Enrollment): ' + CAST(@rc AS NVARCHAR);

-- Delete Student
EXEC @rc = pDeleteStudent @StudentID = @newStudentID;
PRINT 'Rows Deleted (Student): ' + CAST(@rc AS NVARCHAR);

-- Delete Course
EXEC @rc = pDeleteCourse @CourseID = @newCourseID;
PRINT 'Rows Deleted (Course): ' + CAST(@rc AS NVARCHAR);

-- =======================================
-- 4) VERIFY (should be clean)
-- =======================================
SELECT * FROM vCourses;
SELECT * FROM vStudents;
SELECT * FROM vEnrollments;
SELECT * FROM vStudentCourseEnrollments;

--{ IMPORTANT!!! }--
-- To get full credit, your script must run without having to highlight individual statements!!!  
/**************************************************************************************************/