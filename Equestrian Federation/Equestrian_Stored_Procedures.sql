--------------------------------------------------------------------------
---------------------------- Stored Procedures ---------------------------
--------------------------------------------------------------------------

-- Insert INTO Regions:
--------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_Insert_Region(
        -- parameter --
    p_name regions.region_name%TYPE
)
IS
BEGIN
    INSERT INTO Regions VALUES(SQ_REGION_ID.nextval, p_name); 
END;
        -- Execute Procedure --
        EXECUTE sp_insert_region('Region Name');
        -- Mass Insert --
        BEGIN
            sp_insert_region('Region Name');
            sp_insert_region('Region Name');
            sp_insert_region('Region Name');
            .....
        END;


-- Insert INTO Countries:
--------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_Insert_Country(  
        -- parameters --
    p_code countries.country_code%TYPE,
    p_country countries.country_name%TYPE,
    p_region regions.region_name%TYPE
)
IS
        -- variables --
    v_regionid regions.region_id%TYPE;
    v_count NUMBER;
BEGIN
        -- check if region exists --
    SELECT 
        COUNT(*)
        INTO v_count
    FROM
        regions
    WHERE 
        region_name = p_region;

        -- IF statement --
    IF v_count = 0 
    THEN RAISE_APPLICATION_ERROR(-20001, 'Region ' || p_region || ' not exist. You may need to insert into regions first!');
    END IF;

    SELECT 
        region_id
        INTO v_regionid
    FROM
        regions
    WHERE 
        region_name = p_region;

    INSERT INTO Countries VALUES(SQ_COUNTRY_ID.nextval, UPPER(p_code), INITCAP(p_country), v_regionid);
END;
        -- Execute Procedure --
        EXECUTE sp_insert_country('Country Code', 'Country Name', 'Region Name');
        


-- Insert INTO Cities:
--------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_Insert_City(
        -- parameters --
    p_city cities.city_name%TYPE,
    p_countrycode countries.country_code%TYPE
)
IS
        -- variables --
    v_countryid countries.country_id%TYPE;
    v_count NUMBER;
BEGIN
        -- check if country exists -- 
    SELECT 
        COUNT(*)
        INTO v_count
    FROM 
        countries
    WHERE 
        country_code = p_countrycode;

        -- IF statement --
    IF v_count = 0 
    THEN RAISE_APPLICATION_ERROR (-20001, 'Country Code is either wrong or you may need to insert into countries first!');
    END IF;

    SELECT 
        country_id 
        INTO v_countryid
    FROM 
        countries
    WHERE 
        country_code = p_countrycode;
        
    INSERT INTO Cities VALUES(SQ_CITY_ID.nextval, INITCAP(p_city), v_countryid);
END;
        -- Execute Procedure --
        EXEC SP_Insert_City('City Name', 'Country Code');



-- Insert INTO Arenas:
--------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_Insert_Arna(
        -- parameters --
    p_name arenas.arena_name%TYPE,
    p_boxes arenas.boxes%TYPE,
    p_city cities.city_name%TYPE
)

IS
        -- variables --
    v_city_id cities.city_id%TYPE;
    v_count NUMBER;
BEGIN
        -- check if city exists -- 
    SELECT
        COUNT(*)
        INTO v_count
    FROM
        cities
    WHERE 
        city_name = p_city;

        -- IF statement --
    IF v_count = 0 
    THEN RAISE_APPLICATION_ERROR (-20001, 'Invalid city name, you may need to insert a new city first!');
    END IF;

    SELECT 
        city_id
        INTO v_city_id
    FROM
        cities
    WHERE 
        city_name = p_city;
        
INSERT INTO Arenas VALUES(SQ_ARENA_ID.nextval, p_name, p_boxes, v_city_id);
END;
        -- Execute Procedure --
        EXEC SP_Insert_Arna('Arena Name', N_Boxes, 'City Name');



-- Insert INTO Events:
--------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_Insert_Event(
        -- parameters --
    p_name events.event_name%TYPE,
    p_discipline events.discipline_id%TYPE,
    p_date events.event_date%TYPE,
    p_details events.about_event%TYPE,
    p_arena events.arena_id%TYPE
)

IS
        -- variables --
    v_count NUMBER;
    v_days NUMBER := 30;
BEGIN
     -- check if discipline exists --
    SELECT 
        COUNT(*)
        INTO v_count
    FROM
    disciplines
    WHERE 
        discipline_id = p_discipline;

        -- IF statements --
    IF v_count = 0 
    THEN RAISE_APPLICATION_ERROR(-20001, 'Invalid discipline ID, check discipline IDs!');
    END IF;

        -- validate period of time needed for an event to be set --
    IF p_date < (SYSDATE + v_days) 
    THEN RAISE_APPLICATION_ERROR(-20002, 'Invalid Date, Event must take place in at least one month!');
    END IF;
    
    -- check if arena exists --
     SELECT 
        COUNT(*)
        INTO v_count
    FROM
        arenas
    WHERE 
        arena_id = p_arena;
        
    -- IF statements --
    IF v_count = 0 
    THEN RAISE_APPLICATION_ERROR(-20003, 'Arena with ID ' || p_arena || ' does not exist!');
    END IF;
    
    INSERT INTO Events VALUES(SQ_EVENT_ID.nextval, p_name, p_discipline, p_date, p_details, p_arena);
END;
        -- Execute Procedure --
        EXEC SP_Insert_Event('Event Name', Discipline_ID, TO_DATE('', ''), 'About Event', Arena_ID);



-- Insert INTO Sponsors. IF Industry ID does not exist THEN Insert INTO Indestry AND THEN INSERT INTO Sponsors:
-- ! NOTE ! This type of double inserting is used for testing purposes.
    -- Automated nested Inserts should be well defined according to specific business needs, and used carefully.
    -- Otherwise may caused unpredicted scenarios hard to monitor and control */
-----------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_Insert_Sponsor(
        -- parameters --
    p_name sponsors.sponsor_name%TYPE,
    p_contact sponsors.contact_name%TYPE,
    p_phone sponsors.phone%TYPE,
    p_industry industries.industry%TYPE,
    p_about sponsors.about_sponsor%TYPE
)
IS
        -- variables --
    v_count NUMBER;
    v_indestryid  industries.industry_id%TYPE;
BEGIN
                        -- validates the patterns that needs to be followed for entering name and phone values --
                        -- REGEXP Patterns could be modified to match other specific rules and business requirements! --
IF NOT REGEXP_LIKE(p_contact, '^[a-z,A-Z]{2,}\s[a-z,A-Z]{3,}$') 
THEN RAISE_APPLICATION_ERROR(-20001, 'Contact name should contain only letters! Please provide at least 2 letters for First Name and at least 3 letters for Last Name!');
END IF;
    
IF NOT REGEXP_LIKE(p_phone, '^([(]\d{3}[)])?\s?(\+\d{1,3}\s?)?1?\-?\.?\s?\(?\d{3}\)?[\s.-]?(\d{3})?[\s.-]?\d{4,6}$') 
THEN RAISE_APPLICATION_ERROR(-20002, 'Phone does not match none of the standard phone patterns. Phone cannot contain letters!');
END IF;
        -- check if industry exists --
    SELECT 
        COUNT(*)
        INTO v_count
    FROM
        industries
    WHERE 
        industry =  p_industry;

        -- inserting into Industries if needed --
    IF v_count = 0 
    THEN INSERT INTO Industries VALUES(SQ_INDESTRY_ID.nextval, p_industry);
    END IF;

    SELECT 
       industry_id
       INTO v_indestryid 
    FROM
        industries
    WHERE 
        industry = p_industry;

INSERT INTO Sponsors VALUES(SQ_SPONSOR_ID.nextval, p_name, p_contact, p_phone, v_indestryid, p_about);
END;


-- Insert INTO Event_Sponosrs:
--------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_Insert_Event_Sponsor(
        -- parameters --
        p_sponsorid sponsors_events.sponsor_id%TYPE,
        p_eventid sponsors_events.event_id%TYPE
)
IS
        -- variable --
   v_count NUMBER;
BEGIN
        -- check if sponsor exists --
    SELECT 
        COUNT(*)
        INTO v_count
    FROM
        sponsors
    WHERE 
        sponsor_id = p_sponsorid;

        -- IF statement --
    IF v_count = 0 
    THEN RAISE_APPLICATION_ERROR(-20001, 'Sponsor with ID ' ||  p_sponsorid || ' does not exist. Check sponsors list!');
    END IF;

        -- check if event exists --
    SELECT 
        COUNT(*)
        INTO v_count
    FROM
        events
    WHERE 
        event_id = p_eventid;  

        -- IF statement --
    IF v_count = 0 
    THEN RAISE_APPLICATION_ERROR(-20002, 'Event with ID ' ||  p_eventid || ' does not exist. Check events list!');
    END IF;

    INSERT INTO sponsors_events VALUES(p_sponsorid, p_eventid);
END;
        -- Execute Procedure --
        EXEC SP_Insert_Event_Sponsor(Sponsor_ID, Event_ID);



-- Insert INTO Clubs
--------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_Insert_Club(
        -- parameters --
    p_name clubs.club_name%TYPE,
    p_chairman clubs.chairman%TYPE,
    p_activity activities.activity%TYPE,
    p_budget clubs.budget%TYPE,
    p_city cities.city_name%TYPE
)
IS
        -- variables --
    v_count NUMBER;
    v_activityid activities.activity_id%TYPE;
    v_cityid cities.city_id%TYPE;

BEGIN
        -- Validates the patterns that needs to be followed for entering a name value --
        -- REGEXP Pattern could be modified to match other specific rules and business requirements! --

    IF NOT REGEXP_LIKE(p_chairman, '^[a-z,A-Z]{2,}\s[a-z,A-Z]{3,}$')
    THEN RAISE_APPLICATION_ERROR(-20001, 'Name should contain only letters! Please provide at least 2 letters for First Name and at least 3 letters for Last Name!');
    END IF;
    
        -- check if activity exists --
        SELECT 
            COUNT(*)
            INTO v_count
        FROM
            activities
        WHERE 
            activity = p_activity;

    IF v_count = 0 
    THEN RAISE_APPLICATION_ERROR(-20002, 'Activity: ' || p_activity || ' does not exist. Check the activity list!');
    END IF;

        -- check if budget corresponds to the approved business threshold --
    IF  p_budget < 5000 
    THEN RAISE_APPLICATION_ERROR(-20003, 'Budget is below the the approved threshold for club participation!');
    END IF;

        -- check if city exists --
        SELECT 
            COUNT(*)
            INTO v_count
        FROM
            cities
        WHERE 
            city_name = p_city;

    IF v_count = 0 
    THEN RAISE_APPLICATION_ERROR(-20004, 'City: ' || p_city || ' does not exist. Check the city list and update it if needed!');
    END IF;

        SELECT 
            activity_id
            INTO v_activityid
        FROM
            activities
        WHERE 
            activity = p_activity;

        SELECT 
            city_id
            INTO v_cityid
        FROM
            cities
        WHERE 
            city_name = p_city;

    INSERT INTO Clubs VALUES(SQ_CLUB_ID.nextval, p_name, p_chairman, v_activityid, p_budget, v_cityid);
END;
        -- Execute Procedure -- 
        EXEC sp_insert_club('Club Name', 'Chairman', 'Activity', Budget, 'City Name');


-- Insert INTO Contestants:
--------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_Insert_Contestant(
        -- parameters --
   p_idcard contestants.id_card%TYPE,
   p_firstname contestants.first_name%TYPE,
   p_lastname contestants.last_name%TYPE,
   p_salutation salutation.salutation%TYPE,
   p_email contestants.email%TYPE,
   p_phone contestants.phone%TYPE,
   p_bdate contestants.birth_date%TYPE,
   p_category categories.category_name%TYPE,
   p_city cities.city_name%TYPE,
   p_club clubs.club_name%TYPE
)
IS
        -- variables --
    v_salutationid salutation.salutation_id%TYPE;
    v_category_id categories.category_id%TYPE;
    v_cityid cities.city_id%TYPE;
    v_clubid clubs.club_id%TYPE;
    v_email contestants.email%TYPE := p_email;
    v_count NUMBER;
    
BEGIN
        -- check if an ID Card number already exists --
    SELECT
        COUNT(*)
        INTO v_count
    FROM
        contestants
    WHERE id_card = p_idcard;

        -- IF statements --
        -- validate the ID card number --
    IF v_count > 0 
    THEN RAISE_APPLICATION_ERROR(-20001, 'ID_CARD with the provided number already exist! Please provide a valid unique number!');
    END IF;

        -- validate the ID card pattern --
    IF NOT REGEXP_LIKE(p_idcard, '^[0-9]{10}$') 
    THEN RAISE_APPLICATION_ERROR(-20002, 'ID Card should contain exact 10 digits!');
    END IF;

        -- validate first name pattern --
    IF NOT REGEXP_LIKE(p_firstname, '^[a-z,A-Z]{2,}$') 
    THEN RAISE_APPLICATION_ERROR(-20003, 'First Name should be at least 2 symbols and can contain only letters!');
    END IF;

        -- validate last name pattern --
    IF NOT REGEXP_LIKE(p_lastname, '^[a-z,A-Z]{3,}$') 
    THEN RAISE_APPLICATION_ERROR(-20004, 'Last Name should be at least 3 symbols and can contain only letters!');
    END IF;

        -- validate  salutation --
    IF p_salutation NOT IN ('Mr.', 'Ms.') 
    THEN RAISE_APPLICATION_ERROR(-20005, 'Salutation must be either Mr. or Ms.!');
    END IF;

        -- validate  email --
    IF v_email LIKE '%@gmail.com' THEN  v_email := v_email;
        ELSIF v_email LIKE '%@abv.bg' THEN  v_email := v_email;
        ELSIF v_email LIKE '%@hotmail.com' THEN v_email := v_email;
        ELSIF v_email LIKE '%@yahoo.com' THEN v_email := v_email;
        ELSE RAISE_APPLICATION_ERROR(-20006,'Please provide a valid email!');
    END IF;


        -- validate date of birth --
    IF p_bdate < TO_DATE('01-01-1920','dd-mm-yyyy') 
    THEN RAISE_APPLICATION_ERROR(-20007,'Please provide a valid date of birth!');
    END IF;

        -- check if phone number alraedy exists --
    SELECT 
        COUNT(*)
        INTO v_count
    FROM
        contestants
    WHERE 
        phone = p_phone;

    IF v_count > 0 
    THEN RAISE_APPLICATION_ERROR(-20008, 'Phone: ' || p_phone || ' already exist! Please provide a valid unique phone number!');
    END IF;
    
        -- validate categoty name and id -- 
    SELECT 
        COUNT(*)
        INTO v_count
    FROM
        categories
    WHERE 
        category_name = p_category ;

    IF v_count = 0 
    THEN RAISE_APPLICATION_ERROR(-20009, 'Category shoud be one of the follows: "M/F", "Amateur", "Teens 14", "Teens 18"!');
    END IF;

        -- check if city exists --
    SELECT     
        COUNT(*)
        INTO v_count
    FROM
        cities
    WHERE 
        city_name = p_city;

    IF v_count = 0 
    THEN RAISE_APPLICATION_ERROR(-20010, 'City: ' || p_city || ' does not exist!');
    END IF;

        -- check if club exists --
    SELECT     
        COUNT(*)
        INTO v_count
    FROM
        clubs
    WHERE 
        club_name = p_club;
        
    IF v_count = 0 
    THEN RAISE_APPLICATION_ERROR(-20011, 'Club: ' || p_club || ' does not exist!');
    END IF;  

    SELECT 
        salutation.salutation_id
        INTO v_salutationid
    FROM
        salutation
    WHERE 
        salutation = p_salutation;

    SELECT 
        category_id
        INTO v_category_id
    FROM
        categories
    WHERE 
        category_name = p_category;

    SELECT
        city_id
        INTO v_cityid
    FROM
        cities
    WHERE 
        city_name = p_city;

    SELECT
        club_id
        INTO v_clubid
    FROM
        clubs
    WHERE 
        club_name = p_club;

    INSERT INTO Contestants VALUES(SQ_CONTESTANT_ID.nextval, p_idcard, p_firstname, p_lastname, v_salutationid, p_email, p_phone, p_bdate, v_category_id, v_cityid, v_clubid);
END;
        -- Execute Procedure --
        EXEC sp_insert_contestant('ID Card', 'First Name', 'Last Name', 'Salutation', 'Email', 'Phone', 
                TO_DATE('00-00-0000','dd-mm-yyyy'), 'Category Name', 'City Name', 'Club Name');


-- Insert INTO Horses:
--------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_Insert_Hores(
        -- parameters --
    p_UELN horses.ueln%TYPE,
    p_name horses.horse_name%TYPE,
    p_type types.horse_type%TYPE,
    p_breed breeds.breed_name%TYPE,
    p_gender gender.gender%TYPE,
    p_bdate horses.birth_date%TYPE,
    p_riderid horses.rider_id%TYPE
)
IS
        -- variables --
    v_rider_id contestants.rider_id%TYPE;
    v_type types.type_id%TYPE;
    v_breed breeds.breed_id%TYPE;
    v_gender gender.gender_id%TYPE;
    v_count NUMBER;
BEGIN
        -- check if rider exists --
    SELECT 
        COUNT(*)
        INTO v_count
    FROM
        contestants
    WHERE rider_id = p_riderid;

    IF v_count = 0 
    THEN RAISE_APPLICATION_ERROR (-20001, 'Rider with ID: ' || p_riderid || ' does not exist!');
    END IF;

        -- check if horse type exists -- 
    SELECT 
        COUNT(*)
        INTO v_count
    FROM
        Types
    WHERE horse_type = p_type;

    IF v_count = 0 
    THEN RAISE_APPLICATION_ERROR (-20002, 'Type you entered does not exist!');
    END IF;

        -- check if horse breed exists --
    SELECT 
        COUNT(*)
        INTO v_count
    FROM
        breeds
    WHERE breed_name = p_breed;

    IF v_count = 0 
    THEN RAISE_APPLICATION_ERROR (-20003, 'Breed you entered does not exist!');
    END IF;

        -- check for UELN duplications --
    SELECT 
        COUNT(*)
        INTO v_count
    FROM
        horses
    WHERE 
        ueln = p_UELN;

        -- validate UELN number --
    IF v_count > 0 
    THEN RAISE_APPLICATION_ERROR(-20004, 'UELN alraedy exists and it must be unique!');
    END IF;

        -- validate UELN pattern --
    IF NOT REGEXP_LIKE(p_UELN, '^[0-9]{15}$')
    THEN RAISE_APPLICATION_ERROR(-20005, 'UELN should contain exact 15 digits!');
    END IF;

        -- validate gender -- 
    IF  p_gender NOT IN ('Stallion', 'Mare')
    THEN RAISE_APPLICATION_ERROR(-20006, 'Horse gender must be either "Stallion" or "Mare"!');
    END IF;

        -- validate date of birth --
    IF p_bdate < TO_DATE('01-01-2000','dd-mm-yyyy')
    THEN RAISE_APPLICATION_ERROR (-20007, 'Please provide a valid date of birth!');
    END IF;

    SELECT 
        type_id
        INTO v_type
    FROM
        Types
    WHERE 
        horse_type = p_type;

    SELECT
        breed_id
        INTO v_breed
    FROM
        breeds
    WHERE
        breed_name = p_breed;
        
    SELECT
        gender_id
        INTO v_gender
    FROM
        gender
    WHERE 
        gender = p_gender;
                            -- Keeping both attributes: horse_id and reg_number might be put under consideration --
                            -- each of them could be taken as a Primary Key, depends on the business need -- 
    INSERT INTO Horses VALUES(SQ_HORSE_ID.nextval, SQ_HORSE_REGNUMB.nextval || p_riderid, p_UELN, p_name, v_type, v_breed, v_gender, p_bdate, 0, p_riderid);
END;
        -- Execute Procedure --
        EXEC sp_insert_hores('UELN', 'Horse Name', 'Type', 'Breed', 'Gender', Birth_DATE AS TO_DATE('',''), Rider_ID);


-- Insert Registration:
--------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_Insert_Registration(
        -- parameters --
    p_rider registrations.rider_id%TYPE,
    p_event events.event_name%TYPE,
    p_box boxes.box_type%TYPE,
    p_reg_date registrations.reg_date%TYPE 
)
-- Usually Reg Date would be a SYSDATE, so it could be moved to variable as 
-- v_reg_date registrations.reg_date%TYPE := SYSDATE and removed from the parameters!
IS
        -- variables --
    v_eventid events.event_id%TYPE;
    v_date events.event_date%TYPE;
    v_boxid boxes.box_id%TYPE;
    v_count NUMBER;
    v_days NUMBER := 10;
BEGIN
        -- check if rider exists --
    SELECT 
        COUNT(*)
        INTO v_count
    FROM
        contestants
    WHERE 
        rider_id = p_rider;

    IF v_count = 0 
    THEN RAISE_APPLICATION_ERROR (-20002, 'Invalid rider ID!');
    END IF;

        -- check if event exists --
    SELECT 
        COUNT(*)
        INTO v_count
    FROM
        events
    WHERE 
        event_name = p_event;
        
    IF v_count = 0 
    THEN RAISE_APPLICATION_ERROR (-20003, 'Invalid event Name!');
    END IF;

            -- validate the box type --
    IF p_box NOT IN('With Straw', 'Without Straw') 
    THEN RAISE_APPLICATION_ERROR (-20004, 'Boxes are two types, either "With Straw" or "Without Straw"!');
    END IF;

            -- validate the registration period --
    SELECT 
        event_date
        INTO v_date
    FROM
        events
    WHERE 
        event_name = p_event;
    
    IF p_reg_date > v_date - v_days 
    THEN RAISE_APPLICATION_ERROR(-20005, 'There are ' || v_days || ' days left for this event, registration period is already closed!');
    END IF;  

    SELECT 
        event_id
        INTO v_eventid
    FROM 
        events
    WHERE 
        event_name = p_event;

    SELECT 
        box_id
        INTO v_boxid
    FROM 
        boxes
    WHERE 
        box_type = p_box;

    INSERT INTO Registrations VALUES(SQ_REG_ID.nextval, p_rider, v_eventid, v_boxid, p_reg_date, NULL);
END;
        -- Execute Procedure --
        EXECUTE sp_insert_registration(Rider_ID, 'Event Name', 'Box Type', Reg_Date);
        

-- UPDATE Registrations:
--------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_Update_Regs(
        -- parameters --
    p_reg_id registrations.reg_id%TYPE,
    p_cancel_date registrations.cancel_date%TYPE 
)
-- Usually Cancel Date would be a SYSDATE, so it could be moved to variable as 
-- v_cancel_date registrations.cancel_date%TYPE := SYSDATE and removed from the parameters!

IS
    -- variables --
    v_date events.event_date%TYPE;
    v_days NUMBER := 3;
    
BEGIN
    -- validate the cancel period --
    SELECT 
        event_date 
        INTO v_date
    FROM
        events
    WHERE event_id = (SELECT event_id FROM registrations WHERE reg_id = p_reg_id);

    IF  p_cancel_date > v_date - v_days
    THEN RAISE_APPLICATION_ERROR(-20001, 'Registrations cannot be canceled ' || v_days || ' days before the event!');
    END IF;    

    UPDATE registrations 
    SET cancel_date = p_cancel_date,
        box_id = NULL
    WHERE reg_id = p_reg_id;
END;
        -- Execute Procedure --
        EXECUTE SP_Update_Regs(Reg_ID, SYSDATE);



-- Delete from Contestants:
--------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_Delete_Contestant(
        -- parameter --
    p_riderid contestants.rider_id%TYPE
)

IS
BEGIN
    DELETE FROM contestants
    WHERE rider_id = p_riderid;
END; 
        -- Execute Procedure --
        EXECUTE SP_Delete_Contestant(Rider_ID);


-- Insert Into Awarding:
--------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_Insert_Award(
        -- parameters --
    p_horseid awarding.horse_id%TYPE,
    p_eventid awarding.event_id%TYPE,
    p_score awarding.total_score%TYPE,
    p_award awarding.award_id%TYPE)

IS
    -- variables --
    v_count NUMBER;
    v_attend registrations.cancel_date%TYPE;

BEGIN
        -- check if a rider has been registered for the event --
     SELECT
        COUNT(*)
        INTO v_count
    FROM
        registrations
    WHERE rider_id = (SELECT rider_id FROM contestants WHERE rider_id = (SELECT rider_id FROM horses WHERE horse_id = p_horseid));
    
    IF v_count = 0
    THEN RAISE_APPLICATION_ERROR(-20001, 'Horse with ID: ' || p_horseid || ' has not participated in this competition!');
    END IF;

        -- check if rider's registration is still valid, and has not been canceled --
    SELECT
        r.cancel_date
        INTO v_attend
    FROM
        horses h
            INNER JOIN
        contestants c
            ON h.rider_id = c.rider_id
            INNER JOIN
        registrations r
            ON r.rider_id = c.rider_id
    WHERE 
        horse_id = p_horseid;
        
    IF v_attend IS NOT NULL
    THEN RAISE_APPLICATION_ERROR(-20002, 'Horse with ID: ' || p_horseid || ' has not participated in this competition!');
    END IF;
        
        -- validate the award places -- 
    IF p_award NOT IN (1, 2, 3)
    THEN RAISE_APPLICATION_ERROR(- 20004, 'Awarded places must be from 1 to 3!');
    END IF;
        
        -- validate only 3 awarded places per event -- 
    SELECT 
        (SELECT COUNT(*) FROM Awarding WHERE event_id = p_eventid AND award_id = p_award)
        INTO v_count
    FROM Dual;

    IF v_count = 1
    THEN RAISE_APPLICATION_ERROR(-20005, 'There should have only 3 awarded places for event!!');
    END IF;
     

    INSERT INTO Awarding VALUES(p_horseid, p_eventid, p_score,  p_award, 0);
END;

        EXECUTE sp_insert_award(horse_id, event_id, total_score, award_id);