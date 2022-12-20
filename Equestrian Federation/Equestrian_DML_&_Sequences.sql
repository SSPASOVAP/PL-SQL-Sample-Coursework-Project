--------------------------------------------------------------------------
------------------------- DML statements INSERT INTO ---------------------
--------------------------------------------------------------------------


INSERT INTO Activities VALUES(1, 'Sports');
INSERT INTO Activities VALUES(2, 'Amateur');
INSERT INTO Activities VALUES(3, 'Touristic');
            -- Sequence created for eventual extension purposes:
            CREATE SEQUENCE SQ_Activity_ID START WITH 4;


INSERT INTO Age_Groups VALUES(1, '2 - 4');
INSERT INTO Age_Groups VALUES(2, '5 - 6');
INSERT INTO Age_Groups VALUES(3, '7 - 8');
INSERT INTO Age_Groups VALUES(4, '9 - 10');
INSERT INTO Age_Groups VALUES(5, '10+');
            -- Sequence created for eventual extension purposes:
            CREATE SEQUENCE SQ_AgeGroup_ID START WITH 5;


INSERT INTO Boxes VALUES(1, 'With Straw', 50);
INSERT INTO Boxes VALUES(2, 'Without Straw', 80);
            -- Sequence created for eventual extension purposes:
            CREATE SEQUENCE SQ_Box_ID START WITH 3;


INSERT INTO Categories VALUES(1, 'M/F');
INSERT INTO Categories VALUES(2, 'Amateur');
INSERT INTO Categories VALUES(3, 'Teens 14');
INSERT INTO Categories VALUES(4, 'Teens 18');
            -- Sequence created for eventual extension purposes:
            CREATE SEQUENCE SQ_Category_ID START WITH 5;


INSERT INTO Disciplines VALUES(1, 'Jumping');
INSERT INTO Disciplines VALUES(2, 'Еndurance');
INSERT INTO Disciplines VALUES(3, 'Dressage');
INSERT INTO Disciplines VALUES(4, 'Аll-Round Riding');
            -- Sequence created for eventual extension purposes:
            CREATE SEQUENCE SQ_Discipline_ID START WITH 5;


--No need of Sequence because of the limited records:
INSERT INTO Gender Values(1, 'Stallion');
INSERT INTO Gender Values(2, 'Mare');


--No need of Sequence because of the limited records:
INSERT INTO Awards Values(1, 'Gold');
INSERT INTO Awards Values(2, 'Silver');
INSERT INTO Awards Values(3, 'Bronze');


--No need of Sequence because of the limited records:
INSERT INTO Salutation Values(1, 'Mr.');
INSERT INTO Salutation Values(2, 'Ms.');


--No need of Sequence because of the limited records:
INSERT INTO Types Values(1, 'Light');
INSERT INTO Types Values(2, 'Heavy');
INSERT INTO Types Values(3, 'Wild');
INSERT INTO Types Values(4, 'Pony');


--------------------------------------------------------------------------
---------------------------- Create Sequence -----------------------------
--------------------------------------------------------------------------
CREATE SEQUENCE SQ_Region_ID START WITH 1;
CREATE SEQUENCE SQ_Country_ID START WITH 1;
CREATE SEQUENCE SQ_City_ID START WITH 1;
CREATE SEQUENCE SQ_Arena_ID START WITH 1;
CREATE SEQUENCE SQ_Event_ID START WITH 1;
CREATE SEQUENCE SQ_Indestry_ID START WITH 1;
CREATE SEQUENCE SQ_Sponsor_ID START WITH 1;
CREATE SEQUENCE SQ_Club_ID START WITH 1;
CREATE SEQUENCE SQ_Contestant_ID START WITH 1;
CREATE SEQUENCE SQ_Horse_ID START WITH 1;
CREATE SEQUENCE SQ_Breed_ID START WITH 1;
CREATE SEQUENCE SQ_Reg_ID START WITH 1;