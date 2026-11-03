/*
    Coworking Space Booking sample database for Microsoft SQL Server
    Topic: Small coworking office room and desk booking system.
*/

IF DB_ID(N'CoworkingSpaceBookingDB') IS NULL
BEGIN
    CREATE DATABASE CoworkingSpaceBookingDB;
END;
GO

USE CoworkingSpaceBookingDB;
GO

IF OBJECT_ID(N'dbo.Payments', N'U') IS NOT NULL DROP TABLE dbo.Payments;
IF OBJECT_ID(N'dbo.Bookings', N'U') IS NOT NULL DROP TABLE dbo.Bookings;
IF OBJECT_ID(N'dbo.Workspaces', N'U') IS NOT NULL DROP TABLE dbo.Workspaces;
IF OBJECT_ID(N'dbo.Members', N'U') IS NOT NULL DROP TABLE dbo.Members;
GO

CREATE TABLE dbo.Members
(
    MemberId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Members PRIMARY KEY,
    FullName NVARCHAR(120) NOT NULL,
    Email NVARCHAR(255) NOT NULL CONSTRAINT UQ_Members_Email UNIQUE,
    MembershipType NVARCHAR(20) NOT NULL,
    JoinedAt DATE NOT NULL CONSTRAINT DF_Members_JoinedAt DEFAULT CONVERT(date, GETDATE()),
    CONSTRAINT CK_Members_MembershipType CHECK (MembershipType IN (N'Daily', N'Monthly', N'Premium'))
);

CREATE TABLE dbo.Workspaces
(
    WorkspaceId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Workspaces PRIMARY KEY,
    WorkspaceName NVARCHAR(100) NOT NULL,
    WorkspaceType NVARCHAR(30) NOT NULL,
    Capacity INT NOT NULL,
    HourlyRate DECIMAL(10,2) NOT NULL,
    CONSTRAINT CK_Workspaces_Type CHECK (WorkspaceType IN (N'Desk', N'MeetingRoom', N'PrivateOffice')),
    CONSTRAINT CK_Workspaces_Capacity CHECK (Capacity > 0),
    CONSTRAINT CK_Workspaces_HourlyRate CHECK (HourlyRate >= 0)
);

CREATE TABLE dbo.Bookings
(
    BookingId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Bookings PRIMARY KEY,
    MemberId INT NOT NULL,
    WorkspaceId INT NOT NULL,
    BookingDate DATE NOT NULL,
    StartHour TINYINT NOT NULL,
    DurationHours TINYINT NOT NULL,
    Status NVARCHAR(20) NOT NULL CONSTRAINT DF_Bookings_Status DEFAULT N'Confirmed',
    CONSTRAINT FK_Bookings_Members FOREIGN KEY (MemberId) REFERENCES dbo.Members(MemberId),
    CONSTRAINT FK_Bookings_Workspaces FOREIGN KEY (WorkspaceId) REFERENCES dbo.Workspaces(WorkspaceId),
    CONSTRAINT CK_Bookings_StartHour CHECK (StartHour BETWEEN 7 AND 22),
    CONSTRAINT CK_Bookings_DurationHours CHECK (DurationHours BETWEEN 1 AND 8),
    CONSTRAINT CK_Bookings_Status CHECK (Status IN (N'Confirmed', N'Cancelled', N'Completed'))
);

CREATE TABLE dbo.Payments
(
    PaymentId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Payments PRIMARY KEY,
    BookingId INT NOT NULL,
    PaidAmount DECIMAL(10,2) NOT NULL,
    PaidAt DATE NOT NULL,
    PaymentMethod NVARCHAR(20) NOT NULL,
    CONSTRAINT FK_Payments_Bookings FOREIGN KEY (BookingId) REFERENCES dbo.Bookings(BookingId),
    CONSTRAINT CK_Payments_PaidAmount CHECK (PaidAmount >= 0),
    CONSTRAINT CK_Payments_Method CHECK (PaymentMethod IN (N'Card', N'Cash', N'Online'))
);
GO

INSERT INTO dbo.Members (FullName, Email, MembershipType, JoinedAt)
VALUES
    (N'Nima Rahimi', N'nima.rahimi@example.com', N'Monthly', '2026-01-05'),
    (N'Parisa Jafari', N'parisa.jafari@example.com', N'Premium', '2026-02-11'),
    (N'Arman Sadeghi', N'arman.sadeghi@example.com', N'Daily', '2026-04-19'),
    (N'Laleh Hosseini', N'laleh.hosseini@example.com', N'Monthly', '2026-05-03');

INSERT INTO dbo.Workspaces (WorkspaceName, WorkspaceType, Capacity, HourlyRate)
VALUES
    (N'Focus Desk A1', N'Desk', 1, 6.00),
    (N'Focus Desk A2', N'Desk', 1, 6.00),
    (N'Blue Meeting Room', N'MeetingRoom', 6, 22.00),
    (N'Green Meeting Room', N'MeetingRoom', 10, 35.00),
    (N'Startup Private Office', N'PrivateOffice', 4, 28.00);

INSERT INTO dbo.Bookings (MemberId, WorkspaceId, BookingDate, StartHour, DurationHours, Status)
VALUES
    (1, 1, '2026-07-01', 9, 4, N'Completed'),
    (2, 3, '2026-07-01', 10, 2, N'Completed'),
    (3, 2, '2026-07-02', 14, 3, N'Confirmed'),
    (4, 5, '2026-07-03', 8, 6, N'Completed'),
    (2, 4, '2026-07-05', 11, 2, N'Cancelled');

INSERT INTO dbo.Payments (BookingId, PaidAmount, PaidAt, PaymentMethod)
VALUES
    (1, 24.00, '2026-07-01', N'Online'),
    (2, 44.00, '2026-07-01', N'Card'),
    (4, 168.00, '2026-07-03', N'Online');
GO

/* CRUD examples */

INSERT INTO dbo.Members (FullName, Email, MembershipType)
VALUES (N'Mehrdad Tavakoli', N'mehrdad.tavakoli@example.com', N'Daily');

SELECT MemberId, FullName, Email, MembershipType
FROM dbo.Members
WHERE MembershipType = N'Monthly'
ORDER BY FullName;

UPDATE dbo.Bookings
SET Status = N'Completed'
WHERE BookingId = 3;

DELETE m
FROM dbo.Members AS m
WHERE m.Email = N'mehrdad.tavakoli@example.com'
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.Bookings AS b
      WHERE b.MemberId = m.MemberId
  );
GO

/* Reporting queries */

SELECT
    b.BookingId,
    m.FullName,
    w.WorkspaceName,
    b.BookingDate,
    b.DurationHours,
    b.DurationHours * w.HourlyRate AS ExpectedAmount
FROM dbo.Bookings AS b
INNER JOIN dbo.Members AS m ON m.MemberId = b.MemberId
INNER JOIN dbo.Workspaces AS w ON w.WorkspaceId = b.WorkspaceId
ORDER BY b.BookingDate;

SELECT
    w.WorkspaceType,
    COUNT(*) AS BookingCount,
    SUM(b.DurationHours) AS TotalBookedHours
FROM dbo.Bookings AS b
INNER JOIN dbo.Workspaces AS w ON w.WorkspaceId = b.WorkspaceId
WHERE b.Status <> N'Cancelled'
GROUP BY w.WorkspaceType
ORDER BY TotalBookedHours DESC;

SELECT
    m.MembershipType,
    SUM(p.PaidAmount) AS TotalRevenue
FROM dbo.Payments AS p
INNER JOIN dbo.Bookings AS b ON b.BookingId = p.BookingId
INNER JOIN dbo.Members AS m ON m.MemberId = b.MemberId
GROUP BY m.MembershipType
ORDER BY TotalRevenue DESC;

SELECT
    w.WorkspaceName,
    AVG(CAST(b.DurationHours AS DECIMAL(10,2))) AS AverageBookingHours
FROM dbo.Bookings AS b
INNER JOIN dbo.Workspaces AS w ON w.WorkspaceId = b.WorkspaceId
GROUP BY w.WorkspaceName
ORDER BY AverageBookingHours DESC;

SELECT
    m.FullName,
    COUNT(*) AS BookingCount
FROM dbo.Members AS m
INNER JOIN dbo.Bookings AS b ON b.MemberId = m.MemberId
GROUP BY m.FullName
HAVING COUNT(*) >= 1
ORDER BY BookingCount DESC;
GO
