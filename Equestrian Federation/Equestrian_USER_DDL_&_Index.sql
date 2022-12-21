--------------------------------------------------------------------------
--------------------------- Database: Equestrian -------------------------
--------------------------------------------------------------------------

-- Create User:
CREATE USER User_Equestrian IDENTIFIED BY xxxxxxxxx;
GRANT RESOURCE TO User_Equestrian;
GRANT CREATE SESSION TO User_Equestrian;

-- Create Table:
-- Regions (Region_ID, Region_Name)
CREATE TABLE Regions(
    Region_ID NUMBER,
    Region_Name VARCHAR2(100) NOT NULL,

    CONSTRAINT PK_Region
    PRIMARY KEY (Region_ID),

    CONSTRAINT UQ_RName
    UNIQUE (Region_Name)
);

-- Create Table:
-- Countries (Country_ID, Country_Code, Country_Name, Region_ID)
CREATE TABLE Countries(
    Country_ID NUMBER,
    Country_Code CHAR(2) NOT NULL,
    Country_Name VARCHAR2(100) NOT NULL,
    Region_ID NUMBER,

    CONSTRAINT PK_Country
    PRIMARY KEY(Country_ID),

    CONSTRAINT UQ_CountryCode
    UNIQUE(Country_Code),

    CONSTRAINT UQ_CountyName
    UNIQUE(Country_Name),

    CONSTRAINT FK_Cntry_Region
    FOREIGN KEY (Region_ID)
    REFERENCES Regions(Region_ID)
);

-- Create Table:
-- Cities (City_ID, City_Name, Country_ID)
CREATE TABLE Cities(
    City_ID NUMBER,
    City_Name VARCHAR2(100) NOT NULL,
    Country_ID NUMBER,

    CONSTRAINT PK_City
    PRIMARY KEY (City_ID),

    CONSTRAINT FK_City_Cntry
    FOREIGN KEY (Country_ID)
    REFERENCES Countries(Country_ID)
);

-- Create Table:
-- Arenas (Arena_ID, Arena_Name, City_ID, Seats, Boxes)
CREATE TABLE Arenas(
    Arena_ID NUMBER,
    Arena_Name VARCHAR2(50) NOT NULL,
    Boxes NUMBER NOT NULL,
    City_ID NUMBER,

    CONSTRAINT PK_Arena
    PRIMARY KEY (Arena_ID),

    CONSTRAINT FK_Arena_City
    FOREIGN KEY (City_ID)
    REFERENCES Cities(City_Id)
);

-- Create Table:
-- Disciplines (Discipline_ID, Discipline)
CREATE TABLE Disciplines(
    Discipline_ID NUMBER,
    Discipline VARCHAR2(50),

    CONSTRAINT PK_Discipline
    PRIMARY KEY (Discipline_ID),

    CONSTRAINT UQ_DName
    UNIQUE (Discipline)
);

-- Create Table:
-- Events (Event_ID, Event_Name, Discipline_ID, Event_Date, About_Event, Arena_ID)
CREATE TABLE Events(
    Event_ID NUMBER,
    Event_Name VARCHAR2(100) NOT NULL,
    Discipline_ID NUMBER,
    Event_Date DATE,
    About_Event VARCHAR(255) NOT NULL,
    Arena_ID NUMBER,

    CONSTRAINT PK_Event
    PRIMARY KEY(Event_ID),

    CONSTRAINT FK_Event_Discipl
    FOREIGN KEY (Discipline_ID)
    REFERENCES Disciplines(Discipline_ID),

    CONSTRAINT FK_Event_Arena
    FOREIGN KEY (Arena_ID)
    REFERENCES Arenas(Arena_ID),

    CONSTRAINT UQ_EName
    UNIQUE (Event_Name)
);

-- Create Table:
-- Industries (Industry_ID, Industry)
CREATE TABLE Industries(
    Industry_ID NUMBER,
    Industry VARCHAR2(100) NOT NULL,

    CONSTRAINT PK_Industry
    PRIMARY KEY(Industry_ID),

    CONSTRAINT UQ_IName
    UNIQUE(Industry)
);

-- Create Table:
-- Sponsors (Sponsor_ID, Sponsor_Name, Contact_Name, Phone, Industry_ID, About_Sponsor)
CREATE TABLE Sponsors(
    Sponsor_ID NUMBER,
    Sponsor_Name NVARCHAR2(100) NOT NULL,
    Contact_Name NVARCHAR2(100) NOT NULL,
    Phone VARCHAR2(15) NOT NULL,
    Industry_ID NUMBER,
    About_Sponsor VARCHAR(255) DEFAULT NULL,

    CONSTRAINT PK_Sponsor
    PRIMARY KEY (Sponsor_ID),

    CONSTRAINT FK_Sponsor_Industry
    FOREIGN KEY (Industry_ID)
    REFERENCES Industries(Industry_ID),

    CONSTRAINT Chk_C_Name
    CHECK(REGEXP_LIKE(contact_name, '^[a-z,A-Z]{2,}\s[a-z,A-Z]{3,}$')),

    CONSTRAINT UQ_SPhone
    UNIQUE (Phone),

    CONSTRAINT Chk_phone
    CHECK(REGEXP_LIKE(phone, '^([(]\d{3}[)])?\s?(\+\d{1,3}\s?)?1?\-?\.?\s?\(?\d{3}\)?[\s.-]?(\d{3})?[\s.-]?\d{4,6}$'))
);

-- Create Table:
-- Sponsors_Event (Sponsor_ID, Event_ID)
CREATE TABLE Sponsors_Events(
    Sponsor_ID NUMBER,
    Event_ID NUMBER,

    CONSTRAINT PK_Sponsor_Event
    PRIMARY KEY (Sponsor_ID, Event_ID),

    CONSTRAINT FK_SE_Sponsor
    FOREIGN KEY (Sponsor_ID)
    REFERENCES Sponsors(Sponsor_ID),

    CONSTRAINT FK_SE_Event
    FOREIGN KEY (Event_ID)
    REFERENCES Events(Event_ID)
);

-- Create Table:
-- Salutation(Salutation_ID, Salutation)
CREATE TABLE Salutation(
    Salutation_ID NUMBER,
    Salutation CHAR(3) NOT NULL,

    CONSTRAINT PK_Salutation
    PRIMARY KEY (Salutation_ID),

    CONSTRAINT UQ_Salutation
    UNIQUE (Salutation)
);

-- Create Table:
-- Activities (Activity_ID, Activity)
CREATE TABLE Activities(
    Activity_ID NUMBER,
    Activity VARCHAR2(50) NOT NULL,

    CONSTRAINT PK_Activity
    PRIMARY KEY (Activity_ID),

    CONSTRAINT UQ_Activity
    UNIQUE (Activity)
);

-- Create Table:
-- Clubs (Club_ID, Club_Name, Chairman, Activity_ID, Budget, City_ID)
CREATE TABLE Clubs(
    Club_ID NUMBER,
    Club_Name NVARCHAR2(100) NOT NULL,
    Chairman NVARCHAR2(100) NOT NULL,
    Activity_Id NUMBER,
    Budget NUMBER(15,2) NOT NULL,
    City_ID NUMBER,

    CONSTRAINT PK_Club
    PRIMARY KEY (Club_ID),

    CONSTRAINT Chk_Charman_Name
    CHECK(REGEXP_LIKE(Chairman, '^[a-z,A-Z]{2,}\s[a-z,A-Z]{3,}$')),

    CONSTRAINT Chk_Budget
    CHECK(Budget >= 5000),

    CONSTRAINT FK_Club_Activity
    FOREIGN KEY (Activity_ID)
    REFERENCES Activities(Activity_ID),

    CONSTRAINT FK_Club_City
    FOREIGN KEY(City_ID)
    REFERENCES Cities(City_ID)
);

-- Create Table:
-- Categories (Category_ID, Category)
CREATE TABLE Categories(
    Category_ID NUMBER,
    Category VARCHAR2(50) NOT NULL,

    CONSTRAINT PK_Category
    PRIMARY KEY (Category_ID),

    CONSTRAINT UQ_Category
    UNIQUE (Category)
);

-- Create Table:
-- Contestants (Rider_ID, ID_Card, First_Name, Last_Name, Salutation, Email, Phone, Birth_Date, Category_ID, City_ID, Club_ID)
CREATE TABLE Contestants(
    Rider_ID NUMBER,
    ID_Card CHAR(10) NOT NULL,
    First_Name NVARCHAR2(100) NOT NULL,
    Last_Name NVARCHAR2(100) NOT NULL,
    Salutation_ID NUMBER,
    Email VARCHAR2(100) NOT NULL,
    Phone VARCHAR2(15) NOT NULL,
    Birth_Date DATE NOT NULL,
    Category_ID NUMBER,
    City_ID NUMBER,
    Club_ID NUMBER,

    CONSTRAINT PK_Rider
    PRIMARY KEY (Rider_ID),

    CONSTRAINT UQ_Card
    UNIQUE (ID_Card),

    CONSTRAINT UQ_Email
    UNIQUE (Email),

    CONSTRAINT UQ_Phone
    UNIQUE (Phone),

    CONSTRAINT Chk_B_Date
    CHECK (Birth_Date > TO_DATE('01-01-1920','dd-mm-yyyy')),

    CONSTRAINT Chk_Email
    CHECK (Email LIKE '%@gmail.com' OR Email LIKE '%@abv.bg' OR Email LIKE '%@hotmail.com' OR Email LIKE '%@yahoo.com'),

    CONSTRAINT FK_Rider_Category
    FOREIGN KEY (Category_ID)
    REFERENCES Categories(Category_ID),

    CONSTRAINT FK_Rider_City
    FOREIGN KEY (City_ID)
    REFERENCES Cities(City_ID),

    CONSTRAINT FK_Rider_Club
    FOREIGN KEY (Club_ID)
    REFERENCES Clubs(Club_ID),

    CONSTRAINT FK_Rider_Salutation
    FOREIGN KEY (Salutation_ID)
    REFERENCES Salutations(Salutation_ID)
);

-- Create Table:
-- Boxes (Box_ID, Box_Type, Price_Per_Day_EUR)
CREATE TABLE Boxes(
    Box_ID NUMBER,
    Box_Type VARCHAR2(50) NOT NULL,
    Price_Per_Day_EUR NUMBER(5,2) NOT NULL,

    CONSTRAINT PK_Box
    PRIMARY KEY (Box_Id),

    CONSTRAINT UQ_Box
    UNIQUE (Box_Type)
);

-- Create Table:
-- Registrations (Reg_ID, Rider_ID, Event_ID, Box_ID, Reg_date, Cancel_Date)
CREATE TABLE Registrations(
    Reg_ID NUMBER,
    Rider_ID NUMBER,
    Event_ID NUMBER,
    Box_ID NUMBER,
    Reg_Date DATE NOT NULL,
    Cancel_Date DATE DEFAULT NULL,

    CONSTRAINT PK_Regs
    PRIMARY KEY (Reg_ID),

    CONSTRAINT FK_Reg_Rider
    FOREIGN KEY (Rider_ID)
    REFERENCES Contestants(Rider_ID),

    CONSTRAINT FK_Box
    FOREIGN KEY (Box_ID)
    REFERENCES Boxes(Box_ID),

    CONSTRAINT FK_Reg_Event
    FOREIGN KEY (Event_ID)
    REFERENCES Events(Event_ID)
);

-- Create Table:
-- Types (Type_ID, Type)
CREATE TABLE Types(
    Type_ID NUMBER,
    Horse_Type VARCHAR2(10) NOT NULL,

    CONSTRAINT PK_Type
    PRIMARY KEY (Type_ID),

    CONSTRAINT UQ_HorseType
    UNIQUE (Horse_Type)
);

-- Create Table:
-- Breeds (Breed_ID, Breed_Name)
CREATE TABLE Breeds(
    Breed_ID NUMBER,
    Breed_Name VARCHAR2(50) NOT NULL,

    CONSTRAINT PK_Breed
    PRIMARY KEY (Breed_ID),

    CONSTRAINT UQ_Breed
    UNIQUE (Breed_Name)
);

-- Create Table:
-- Gender (Gender_ID, Gender)
CREATE TABLE Gender(
    Gender_ID NUMBER,
    Gender VARCHAR2(10) NOT NULL,

    CONSTRAINT PK_Gender
    PRIMARY KEY (Gender_ID),

    CONSTRAINT UQ_Gender
    UNIQUE (Gender)
);

-- Create Table:
-- Age_Groups (Age_Group_ID, Age_Group)
CREATE TABLE Age_Groups(
    Age_Group_ID NUMBER,
    Age_Group VARCHAR2(10) NOT NULL,

    CONSTRAINT PK_Age_Group
    PRIMARY KEY (Group_ID),

    CONSTRAINT UQ_Age_Group
    UNIQUE (Age_Group)
);

-- Create Table:
-- Horses (Horse_ID, Reg_Number, UELN, Horse_Name, Type_ID, Breed_ID, Gender_ID, Birth_Date, Age_Group_ID, Rider_ID)
CREATE TABLE Horses(
    Horse_ID NUMBER,
    Reg_Number NUMBER NOT NULL,
    UELN CHAR(15) NOT NULL,
    Horse_Name VARCHAR2(50) NOT NULL,
    Type_ID NUMBER,
    Breed_ID NUMBER,
    Gender_ID NUMBER,
    Birth_Date DATE NOT NULL, 
    Age_Group_ID NUMBER,
    Rider_ID NUMBER,

    CONSTRAINT PK_Horses
    PRIMARY KEY (Horse_ID),

    CONSTRAINT UQ_Reg_Number
    UNIQUE (Reg_Number),

    CONSTRAINT UQ_UELN
    UNIQUE (UELN),

    CONSTRAINT Chk_Birth_Date
    CHECK (Birth_Date > TO_DATE('01-01-2000','dd-mm-yyyy')),

    CONSTRAINT FK_Horse_Group
    FOREIGN KEY (Group_ID)
    REFERENCES Age_Groups(Group_ID),

    CONSTRAINT FK_Horse_Type
    FOREIGN KEY (Type_ID)
    REFERENCES Types(Type_ID),

    CONSTRAINT FK_Horse_Breed
    FOREIGN KEY (Breed_ID)
    REFERENCES Breeds(Breed_ID), 

    CONSTRAINT FK_Horse_Gender
    FOREIGN KEY (Gender_ID)
    REFERENCES Genders(Gender_ID),

    CONSTRAINT FK_Horse_Rider
    FOREIGN KEY (Rider_ID)
    REFERENCES Contestants(Rider_ID)
);

-- Create Table:
-- Awards(Award_ID, Award_type)
CREATE TABLE Rewards(
    Award_ID NUMBER,
    Award_Type VARCHAR2(30) NOT NULL,

    CONSTRAINT PK_Award
    PRIMARY KEY (Award_ID),

    CONSTRAINT UQ_Award
    UNIQUE (Award_type)
);

-- Create Table:
-- Awarding (Horse_ID, Event_ID, Total_Score, Award_ID, Money_Prize_EUR)
CREATE TABLE Ranking (
    Horse_ID NUMBER,
    Event_ID NUMBER,
    Total_Score NUMBER NOT NULL,
    Award_ID NUMBER DEFAULT NULL,
    Money_Prize_EUR NUMBER(15,2) DEFAULT 0,

    CONSTRAINT PK_Awarding
    PRIMARY KEY (Horse_ID, Event_ID),

    CONSTRAINT FK_Award_Horse
    FOREIGN KEY (Horse_ID)
    REFERENCES Horses(Horse_ID),

    CONSTRAINT FK_Award_Event
    FOREIGN KEY (Event_ID)
    REFERENCES Events(Event_ID),

    CONSTRAINT FK_Awarding_Award
    FOREIGN KEY (Award_ID)
    REFERENCES Awards(Award_ID)
);

-- Create Index
-- Creating index over Award_ID will be useful having the data is growing. 
-- It supposed the column to contain a lot of NULLs, where queries will be mainly selecting those records having a value.

CREATE INDEX IND_Awarding
ON Awarding (reward_id)
COMPUTE STATISTICS;

