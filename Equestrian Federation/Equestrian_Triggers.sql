--------------------------------------------------------------------------
--------------------------------- Triggers -------------------------------
--------------------------------------------------------------------------

-- Create Trigger
-- Before insert INTO Horses:
CREATE OR REPLACE TRIGGER TR_BEFORE_INSERT_HORSE 
BEFORE INSERT ON Horses
FOR EACH ROW
BEGIN  
    :NEW.Age_group_id := CASE
                WHEN FLOOR((SYSDATE - :NEW.birth_date)/365) IN(2, 3, 4) THEN 1
                WHEN FLOOR((SYSDATE - :NEW.birth_date)/365) IN(5, 6) THEN 2
                WHEN FLOOR((SYSDATE - :NEW.birth_date)/365) IN(7, 8) THEN 3
                WHEN FLOOR((SYSDATE - :NEW.birth_date)/365) IN(9, 10) THEN 4
                WHEN FLOOR((SYSDATE - :NEW.birth_date)/365) >10 THEN 5
            END;
END;


-- Create Trigger
-- Raise error when all boxes are booked:
CREATE OR REPLACE TRIGGER TR_CHECK_BOXES_COUNT
BEFORE INSERT ON Registrations
FOR EACH ROW

DECLARE
        -- variables --
    v_count NUMBER;
    v_boxes arenas.boxes%TYPE;
      
BEGIN 
    SELECT
        COUNT(*)
        INTO v_count
    FROM
        registrations
    WHERE box_id IS NOT NULL
                AND 
        event_id = :NEW.event_id;
    
    SELECT 
        arenas.boxes
        INTO v_boxes
    FROM 
        arenas
        INNER JOIN
        events
            ON 
        events.arena_id = arenas.arena_id
    WHERE 
        events.event_id = :NEW.event_id;
        
    IF v_count = v_boxes 
    THEN RAISE_APPLICATION_ERROR(-20001, 'There are no free boxes, please contact the event organizers!!');
    END IF;  
END;


-- Create Trigger for Auditing 

    -- 1. Create Table Audit and Sequence for the PK:
CREATE TABLE Audits (
    Audit_ID            NUMBER PRIMARY KEY,
    Table_Name          VARCHAR2(255),
    Transaction_Name    VARCHAR2(10),
    User_Name            VARCHAR2(30),
    Transaction_Date    DATE
    );

CREATE SEQUENCE SQ_Audit_ID START WITH 1;

    -- 2. Create TRIGGER to each table that needs to be tracked as follow:

    -- Create Trigger 
    -- Contestants Audit 
CREATE OR REPLACE TRIGGER TR_Contestants_Audit
AFTER 
INSERT OR UPDATE OR DELETE ON contestants
FOR EACH ROW    
DECLARE
    -- variable --
    v_transaction VARCHAR2(10);

BEGIN
    v_transaction := CASE  
        WHEN UPDATING THEN 'UPDATE'
        WHEN DELETING THEN 'DELETE'
        WHEN INSERTING THEN 'INSERT'
    END;

    INSERT INTO Audits VALUES(SQ_AUDIT_ID.nextval,'Contestants', v_transaction, USER, SYSDATE);
END;

-- Create Trigger
-- Triger After Delete On Contestants:
CREATE OR REPLACE TRIGGER TR_Set_NULL_OR_Delete_Rider
AFTER DELETE ON Contestants
FOR EACH ROW
BEGIN
    -- updating horses --
    UPDATE Horses 
    SET Horses.rider_id = NULL
    WHERE 
        horses.rider_id = :OLD.rider_id;

    -- deleting from registrations --
    DELETE FROM registrations
    WHERE 
        registrations.rider_id = :OLD.rider_id; 
END;


-- Crete Trigger
-- Trigger Before Insert On Awarding
create or replace TRIGGER TR_BEFORE_INSERT_AWARD
BEFORE INSERT ON Awarding
FOR EACH ROW
DECLARE 
    -- variable --
    v_sum NUMBER(15,2);
BEGIN  
    SELECT 
        SUM(budget)
        INTO v_sum
    FROM
        clubs;

:NEW.money_prize_eur := CASE
            WHEN  :NEW.award_id = 1 THEN v_sum * 0.1
            WHEN  :NEW.award_id = 2 THEN v_sum * 0.05 
            WHEN  :NEW.award_id = 3 THEN v_sum * 0.02 
            ELSE  :NEW.money_prize_eur
        END;
END;