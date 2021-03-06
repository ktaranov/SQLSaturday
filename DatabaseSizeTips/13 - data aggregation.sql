USE tempdb
GO

IF OBJECT_ID('t1') IS NOT NULL
	DROP TABLE t1
GO
CREATE TABLE t1 (
	UserID SMALLINT,
	ReportID TINYINT,
	ViewDate DATETIME2 DEFAULT SYSUTCDATETIME()
	CONSTRAINT pk1 PRIMARY KEY (UserID, ReportID, ViewDate)
)
GO

INSERT INTO dbo.t1 (UserID, ReportID, ViewDate)
VALUES (1, 1, DEFAULT)
GO

INSERT INTO dbo.t1 (UserID, ReportID, ViewDate)
VALUES (1, 2, DEFAULT)
GO

INSERT INTO dbo.t1 (UserID, ReportID, ViewDate)
VALUES (1, 1, DEFAULT)
GO

INSERT INTO dbo.t1 (UserID, ReportID, ViewDate)
VALUES (2, 1, DEFAULT)
GO

INSERT INTO dbo.t1 (UserID, ReportID, ViewDate)
VALUES (1, 1, DEFAULT)
GO

-------------------------------------------------------------------

SELECT UserID, ReportID, MAX(ViewDate), COUNT_BIG(1)
FROM t1
GROUP BY UserID, ReportID
GO

-------------------------------------------------------------------

IF OBJECT_ID('t2') IS NOT NULL
	DROP TABLE t2
GO
CREATE TABLE t2 (
	UserID SMALLINT,
	ReportID TINYINT,
	LastViewDate SMALLDATETIME DEFAULT GETDATE(),
	TotalViews SMALLINT DEFAULT 1
	CONSTRAINT pk2 PRIMARY KEY (UserID, ReportID)
)
GO

IF OBJECT_ID('p') IS NOT NULL
	DROP PROCEDURE p
GO
CREATE PROCEDURE p
(
	  @UserID SMALLINT
	, @ReportID TINYINT
)
AS
BEGIN

	SET NOCOUNT ON;

	MERGE t2 t
	USING (
		SELECT
			  UserID = @UserID
			, ReportID = @ReportID
	) s ON s.UserID = t.UserID AND s.ReportID = t.ReportID 
	WHEN MATCHED
		THEN
			UPDATE SET LastViewDate = GETDATE(), TotalViews += 1
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (UserID, ReportID) VALUES (s.UserID, s.ReportID); 

END
GO

EXEC dbo.p @UserID = 1, @ReportID = 1
EXEC dbo.p @UserID = 1, @ReportID = 2
EXEC dbo.p @UserID = 1, @ReportID = 1
EXEC dbo.p @UserID = 2, @ReportID = 1
EXEC dbo.p @UserID = 1, @ReportID = 1

-------------------------------------------------------------------

SELECT *
FROM t2