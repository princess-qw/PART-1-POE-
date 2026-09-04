-- ============================================================
-- RaceDay Database
-- Section C - SQL Database Script
-- ============================================================

CREATE DATABASE RaceDayDB;
GO

USE RaceDayDB;
GO


-- ============================================================
-- TABLE 1: Users
-- ============================================================
CREATE TABLE Users (
    User_ID INT IDENTITY(1,1) PRIMARY KEY,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Password_Hash VARCHAR(255) NOT NULL,
    Role VARCHAR(20) NOT NULL
        CHECK (Role IN ('Organiser', 'Participant')),
    Created_At DATETIME NOT NULL DEFAULT GETDATE()
);
GO


-- ============================================================
-- TABLE 2: Organisers
-- ============================================================
CREATE TABLE Organisers (
    Organiser_ID INT IDENTITY(1,1) PRIMARY KEY,
    User_ID INT NOT NULL UNIQUE,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Organisation_Name VARCHAR(100) NOT NULL,
    Created_At DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Organisers_Users
        FOREIGN KEY (User_ID)
        REFERENCES Users(User_ID)
);
GO


-- ============================================================
-- TABLE 3: Participants
-- ============================================================
CREATE TABLE Participants (
    Participant_ID INT IDENTITY(1,1) PRIMARY KEY,
    User_ID INT NOT NULL UNIQUE,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Date_Of_Birth DATE NOT NULL,
    Created_At DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Participants_Users
        FOREIGN KEY (User_ID)
        REFERENCES Users(User_ID)
);
GO


-- ============================================================
-- TABLE 4: Events
-- ============================================================
CREATE TABLE Events (
    Event_ID INT IDENTITY(1,1) PRIMARY KEY,
    Organiser_ID INT NOT NULL,
    Event_Name VARCHAR(100) NOT NULL,
    Event_Date DATE NOT NULL,
    Event_Location VARCHAR(100) NOT NULL,
    Event_Type VARCHAR(50) NOT NULL,
    Description VARCHAR(255) NULL,
    Registration_Deadline DATE NOT NULL,
    Created_At DATETIME NOT NULL DEFAULT GETDATE(),

  CONSTRAINT FK_Events_Organisers
    FOREIGN KEY (Organiser_ID)
    REFERENCES Organisers(Organiser_ID),

CONSTRAINT CK_Events_RegistrationDeadline
    CHECK (Registration_Deadline <= Event_Date)
);
GO


-- ============================================================
-- TABLE 5: Categories
-- ============================================================
CREATE TABLE Categories (
    Category_ID INT IDENTITY(1,1) PRIMARY KEY,
    Event_ID INT NOT NULL,
    Category_Name VARCHAR(100) NOT NULL,
    Distance_Km DECIMAL(6,2) NOT NULL,
    Entry_Fee DECIMAL(10,2) NOT NULL,
    Maximum_Participation INT NOT NULL,
    Start_Point VARCHAR(100) NOT NULL,
    End_Point VARCHAR(100) NOT NULL,
    Elevation_Gain_M INT NULL,
    Map_URL VARCHAR(255) NULL,
    Created_At DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_WeatherLogs_Events
    FOREIGN KEY (Event_ID)
    REFERENCES Events(Event_ID),
-- ============================================================
-- SHOW CATEGORY ENROLMENT CAPACITY
-- ============================================================
SELECT
    E.Event_Name,
    C.Category_Name,
    C.Maximum_Participation,
    COUNT(EN.Enrolment_ID) AS Current_Enrolments,
    C.Maximum_Participation - COUNT(EN.Enrolment_ID)
        AS Spaces_Remaining
FROM Categories C
INNER JOIN Events E
    ON C.Event_ID = E.Event_ID
LEFT JOIN Enrolments EN
    ON C.Category_ID = EN.Category_ID
GROUP BY
    E.Event_Name,
    C.Category_Name,
    C.Maximum_Participation
ORDER BY E.Event_Name, C.Category_Name;
GO
);


-- ============================================================
-- TABLE 6: Sponsors
-- ============================================================
CREATE TABLE Sponsors (
    Sponsor_ID INT IDENTITY(1,1) PRIMARY KEY,
    Sponsor_Name VARCHAR(100) NOT NULL,
    Contact_Person VARCHAR(100) NULL,
    Email VARCHAR(100) NULL,
    Phone VARCHAR(20) NULL,
    Sponsor_Type VARCHAR(50) NULL,
    Created_At DATETIME NOT NULL DEFAULT GETDATE()
);
GO


-- ============================================================
-- TABLE 7: EventSponsors
-- ============================================================
CREATE TABLE EventSponsors (
    Event_Sponsor_ID INT IDENTITY(1,1) PRIMARY KEY,
    Event_ID INT NOT NULL,
    Sponsor_ID INT NOT NULL,
    Sponsorship_Tier VARCHAR(50) NOT NULL,
    Created_At DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_EventSponsors_Events
        FOREIGN KEY (Event_ID)
        REFERENCES Events(Event_ID),

    CONSTRAINT FK_EventSponsors_Sponsors
        FOREIGN KEY (Sponsor_ID)
        REFERENCES Sponsors(Sponsor_ID),

    CONSTRAINT UQ_EventSponsors
        UNIQUE (Event_ID, Sponsor_ID)
);
GO


-- ============================================================
-- TABLE 8: WeatherLogs
-- ============================================================
CREATE TABLE WeatherLogs (
    Weather_Log_ID INT IDENTITY(1,1) PRIMARY KEY,
    Event_ID INT NOT NULL,
    Logged_At DATETIME NOT NULL DEFAULT GETDATE(),
    Temperature_C DECIMAL(5,2) NULL,
    Humidity_Percent DECIMAL(5,2) NULL,
    Condition VARCHAR(50) NULL,
    Wind_Speed_Kmh DECIMAL(6,2) NULL,
    Created_At DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_WeatherLogs_Events
        FOREIGN KEY (Event_ID)
        REFERENCES Events(Event_ID)
);
GO


-- ============================================================
-- TABLE 9: Enrolments
-- ============================================================
CREATE TABLE Enrolments (
    Enrolment_ID INT IDENTITY(1,1) PRIMARY KEY,
    Participant_ID INT NOT NULL,
    Category_ID INT NOT NULL,
    Enrolment_Date DATETIME NOT NULL DEFAULT GETDATE(),
    Status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    Bib_Number VARCHAR(20) NOT NULL UNIQUE,
    Created_At DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Enrolments_Participants
        FOREIGN KEY (Participant_ID)
        REFERENCES Participants(Participant_ID),

    CONSTRAINT FK_Enrolments_Categories
        FOREIGN KEY (Category_ID)
        REFERENCES Categories(Category_ID),

    CONSTRAINT CK_Enrolments_Status
        CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled')),

    CONSTRAINT UQ_Participant_Category
        UNIQUE (Participant_ID, Category_ID)
);
GO


-- ============================================================
-- TABLE 10: Payments
-- ============================================================
CREATE TABLE Payments (
    Payment_ID INT IDENTITY(1,1) PRIMARY KEY,
    Enrolment_ID INT NOT NULL UNIQUE,
    Amount DECIMAL(10,2) NOT NULL,
    Payment_Method VARCHAR(50) NULL,
    Payment_Status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    Transaction_Ref VARCHAR(100) NULL UNIQUE,
    Paid_At DATETIME NULL,
    Created_At DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Payments_Enrolments
        FOREIGN KEY (Enrolment_ID)
        REFERENCES Enrolments(Enrolment_ID),

    CONSTRAINT CK_Payments_Amount
        CHECK (Amount >= 0),

    CONSTRAINT CK_Payments_Status
        CHECK (Payment_Status IN ('Pending', 'Paid', 'Failed', 'Refunded'))
);
GO


-- ============================================================
-- TABLE 11: Results
-- ============================================================
CREATE TABLE Results (
    Result_ID INT IDENTITY(1,1) PRIMARY KEY,
    Enrolment_ID INT NOT NULL UNIQUE,
    Finish_Time TIME NULL,
    Position INT NULL,
    Result_Status VARCHAR(20) NOT NULL DEFAULT 'Completed',
    Created_At DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Results_Enrolments
        FOREIGN KEY (Enrolment_ID)
        REFERENCES Enrolments(Enrolment_ID),

    CONSTRAINT CK_Results_Position
        CHECK (Position IS NULL OR Position > 0),

    CONSTRAINT CK_Results_Status
        CHECK (Result_Status IN ('Completed', 'DNS', 'DNF'))
);
GO


-- ============================================================
-- SAMPLE DATA
-- ============================================================


-- ============================================================
-- INSERT USERS
-- ============================================================
INSERT INTO Users (Email, Password_Hash, Role)
VALUES
('organiser1@raceday.co.za', 'hashedpassword1', 'Organiser'),
('organiser2@raceday.co.za', 'hashedpassword2', 'Organiser'),
('participant1@email.com', 'hashedpassword3', 'Participant'),
('participant2@email.com', 'hashedpassword4', 'Participant');
GO


-- ============================================================
-- INSERT ORGANISERS
-- ============================================================
INSERT INTO Organisers
(User_ID, First_Name, Last_Name, Phone, Organisation_Name)
VALUES
(1, 'Thabo', 'Mokoena', '0712345678', 'Run Gauteng Events'),
(2, 'Lerato', 'Nkosi', '0723456789', 'Active Race Events');
GO


-- ============================================================
-- INSERT PARTICIPANTS
-- ============================================================
-- SHOW FULL PARTICIPANT RACE ENROLMENT DETAILS
-- ============================================================
SELECT
    P.Participant_ID,
    P.First_Name,
    P.Last_Name,
    E.Event_Name,
    E.Event_Date,
    C.Category_Name,
    C.Distance_Km,
    EN.Bib_Number,
    EN.Status
FROM Enrolments EN
INNER JOIN Participants P
    ON EN.Participant_ID = P.Participant_ID
INNER JOIN Categories C
    ON EN.Category_ID = C.Category_ID
INNER JOIN Events E
    ON C.Event_ID = E.Event_ID
ORDER BY E.Event_Date;
GO


-- ============================================================
-- INSERT EVENTS
-- ============================================================
INSERT INTO Events
(Organiser_ID, Event_Name, Event_Date, Event_Location,
 Event_Type, Description, Registration_Deadline)
VALUES
(1, 'Pretoria Spring Run', '2026-10-10', 'Pretoria',
 'Road Race', 'Annual spring road running event.',
 '2026-10-01'),

(1, 'Johannesburg City Marathon', '2026-11-15', 'Johannesburg',
 'Marathon', 'City marathon for runners of different levels.',
 '2026-11-05'),

(2, 'Centurion Fun Run', '2026-12-05', 'Centurion',
 'Fun Run', 'Community fun run for families and runners.',
 '2026-11-25');
GO


-- ============================================================
-- INSERT CATEGORIES
-- ============================================================
INSERT INTO Categories
(Event_ID, Category_Name, Distance_Km, Entry_Fee,
 Maximum_Participation, Start_Point, End_Point,
 Elevation_Gain_M, Map_URL)
VALUES
(1, '5 km Run', 5.00, 150.00, 200,
 'Union Buildings', 'Loftus Versfeld', 80,
 'https://example.com/map1'),

(1, '10 km Run', 10.00, 220.00, 150,
 'Union Buildings', 'Loftus Versfeld', 150,
 'https://example.com/map2'),

(2, '21 km Half Marathon', 21.10, 350.00, 300,
 'Johannesburg CBD', 'FNB Stadium', 300,
 'https://example.com/map3'),

(2, '42 km Marathon', 42.20, 500.00, 250,
 'Johannesburg CBD', 'FNB Stadium', 600,
 'https://example.com/map4'),

(3, '5 km Fun Run', 5.00, 100.00, 180,
 'Centurion Park', 'Centurion Park', 50,
 'https://example.com/map5');
GO


-- ============================================================
-- INSERT SPONSORS
-- ============================================================
INSERT INTO Sponsors
(Sponsor_Name, Contact_Person, Email, Phone, Sponsor_Type)
VALUES
('FitLife Sports', 'Amanda Ndlovu',
 'amanda@fitlife.co.za', '0115551234', 'Sports'),

('HydroPlus', 'Kabelo Mokoena',
 'kabelo@hydroplus.co.za', '0125559876', 'Beverage');
CONSTRAINT UQ_EventSponsors
    UNIQUE (Event_ID, Sponsor_ID),

CONSTRAINT CK_EventSponsors_Tier
    CHECK (Sponsorship_Tier IN ('Bronze', 'Silver', 'Gold', 'Platinum'))
);
GO


-- ============================================================
-- INSERT EVENT SPONSORS
-- ============================================================
INSERT INTO EventSponsors
(Event_ID, Sponsor_ID, Sponsorship_Tier)
VALUES
(1, 1, 'Gold'),
(2, 1, 'Silver'),
(3, 2, 'Gold');
GO


-- ============================================================
-- INSERT WEATHER LOGS
-- ============================================================
INSERT INTO WeatherLogs
(Event_ID, Temperature_C, Humidity_Percent,
 Condition, Wind_Speed_Kmh)
VALUES
(1, 24.50, 55.00, 'Sunny', 12.50),
(2, 21.00, 62.00, 'Cloudy', 9.20),
(3, 27.30, 48.00, 'Clear', 10.00);
GO


-- ============================================================
-- INSERT ENROLMENTS
-- ============================================================
INSERT INTO Enrolments
(Participant_ID, Category_ID, Status, Bib_Number)
VALUES
(1, 1, 'Confirmed', 'BIB001'),
(2, 2, 'Confirmed', 'BIB002'),
(1, 3, 'Pending', 'BIB003');
GO


-- ============================================================
-- INSERT PAYMENTS
-- ============================================================
INSERT INTO Payments
(Enrolment_ID, Amount, Payment_Method,
 Payment_Status, Transaction_Ref, Paid_At)
VALUES
(1, 150.00, 'Card', 'Paid', 'TXN1001', GETDATE()),
(2, 220.00, 'EFT', 'Paid', 'TXN1002', GETDATE()),
(3, 350.00, NULL, 'Pending', NULL, NULL);
GO


-- ============================================================
-- INSERT RESULTS
-- ============================================================
INSERT INTO Results
(Enrolment_ID, Finish_Time, Position, Result_Status)
VALUES
(1, '00:28:45', 12, 'Completed'),
(2, '00:55:20', 8, 'Completed');
GO


-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================


-- Show all tables
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO


-- ============================================================
-- SHOW EVENTS WITH ORGANISERS
-- ============================================================
SELECT
    E.Event_ID,
    E.Event_Name,
    E.Event_Date,
    O.First_Name,
    O.Last_Name,
    O.Organisation_Name
FROM Events E
INNER JOIN Organisers O
    ON E.Organiser_ID = O.Organiser_ID;
GO


-- ============================================================
-- SHOW CATEGORIES WITH EVENTS
-- ============================================================
SELECT
    C.Category_ID,
    C.Category_Name,
    C.Distance_Km,
    C.Entry_Fee,
    E.Event_Name
FROM Categories C
INNER JOIN Events E
    ON C.Event_ID = E.Event_ID;
GO


-- ============================================================
-- SHOW PARTICIPANT ENROLMENTS
-- ============================================================
SELECT
    EN.Enrolment_ID,
    P.First_Name,
    P.Last_Name,
    C.Category_Name,
    EN.Bib_Number,
    EN.Status
FROM Enrolments EN
INNER JOIN Participants P
    ON EN.Participant_ID = P.Participant_ID
INNER JOIN Categories C
    ON EN.Category_ID = C.Category_ID;
GO


-- ============================================================
-- SHOW ENROLMENTS WITH PAYMENTS
-- ============================================================
SELECT
    EN.Enrolment_ID,
    EN.Bib_Number,
    P.Amount,
    P.Payment_Method,
    P.Payment_Status
FROM Enrolments EN
INNER JOIN Payments P
    ON EN.Enrolment_ID = P.Enrolment_ID;
GO


-- ============================================================
-- SHOW RESULTS
-- ============================================================
SELECT
    R.Result_ID,
    EN.Bib_Number,
    P.First_Name,
    P.Last_Name,
    R.Finish_Time,
    R.Position,
    R.Result_Status
FROM Results R
INNER JOIN Enrolments EN
    ON R.Enrolment_ID = EN.Enrolment_ID
INNER JOIN Participants P
    ON EN.Participant_ID = P.Participant_ID
ORDER BY R.Position;
GO


-- ============================================================
-- SHOW EVENT SPONSORS
-- ============================================================
SELECT
    E.Event_Name,
    S.Sponsor_Name,
    ES.Sponsorship_Tier
FROM EventSponsors ES
INNER JOIN Events E
    ON ES.Event_ID = E.Event_ID
INNER JOIN Sponsors S
    ON ES.Sponsor_ID = S.Sponsor_ID;
GO


-- ============================================================
-- SHOW EVENT WEATHER
-- ============================================================
SELECT
    E.Event_Name,
    W.Temperature_C,
    W.Humidity_Percent,
    W.Condition,
    W.Wind_Speed_Kmh,
    W.Logged_At
FROM WeatherLogs W
INNER JOIN Events E
    ON W.Event_ID = E.Event_ID;
GO


-- ============================================================
-- FINAL ROW COUNT
-- ============================================================
SELECT 'Users' AS Table_Name, COUNT(*) AS Total_Rows FROM Users
UNION ALL
SELECT 'Organisers', COUNT(*) FROM Organisers
UNION ALL
SELECT 'Participants', COUNT(*) FROM Participants
UNION ALL
SELECT 'Events', COUNT(*) FROM Events
UNION ALL
SELECT 'Categories', COUNT(*) FROM Categories
UNION ALL
SELECT 'Sponsors', COUNT(*) FROM Sponsors
UNION ALL
SELECT 'EventSponsors', COUNT(*) FROM EventSponsors
UNION ALL
SELECT 'WeatherLogs', COUNT(*) FROM WeatherLogs
UNION ALL
SELECT 'Enrolments', COUNT(*) FROM Enrolments
UNION ALL
SELECT 'Payments', COUNT(*) FROM Payments
UNION ALL
SELECT 'Results', COUNT(*) FROM Results;
GO
