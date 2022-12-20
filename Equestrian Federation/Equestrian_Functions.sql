--------------------------------------------------------------------------
--------------------------------- Functions ------------------------------
--------------------------------------------------------------------------

-- Create Function
-- How many boxes are booked per type and event:
CREATE OR REPLACE FUNCTION UDF_Booked_boxes(
    -- parameters --
        p_box_type boxes.box_type%TYPE,
        p_event_name events.event_name%TYPE
)
    
RETURN NUMBER

IS 
    -- variable --
    v_count NUMBER;
BEGIN
    SELECT 
        COUNT(*)
        INTO v_count
    FROM
        registrations
    WHERE 
            box_id = (SELECT 
                        box_id 
                    FROM 
                        boxes 
                    WHERE 
                        box_type = p_box_type)
        AND 
            event_id = (SELECT 
                        event_id 
                    FROM 
                        events 
                    WHERE 
                        event_name = p_event_name)
    GROUP BY 
        event_id;
    
RETURN
    v_count;
END;


-- Create Function
-- How many riders attend per city:
CREATE OR REPLACE FUNCTION UDF_Riders_per_City(
        -- parameter --
        p_city cities.city_name%TYPE
)
    
RETURN NUMBER

IS 
        -- variable --
    v_count NUMBER;
BEGIN
    SELECT 
        COUNT(*)
        INTO v_count
    FROM
        contestants
    WHERE city_id = (SELECT 
                        city_id 
                    FROM 
                        cities 
                    WHERE 
                        city_name = p_city); 
RETURN
    v_count;
END;

-- Create Function
-- Get horse owner's name and phone:
CREATE OR REPLACE FUNCTION UDF_Get_Horse_Owner(
        -- parameter --
        p_horseid horses.horse_id%TYPE
)
    
RETURN VARCHAR2

IS 
        -- variables --
    v_rider_fname contestants.first_name%TYPE;
    v_rider_lname contestants.last_name%TYPE;
    v_phone contestants.phone%TYPE;
BEGIN
    SELECT 
        first_name, last_name, phone
        INTO  v_rider_fname, v_rider_lname, v_phone
    FROM
        contestants
    WHERE 
        rider_id = (SELECT rider_id FROM horses WHERE horse_id =  p_horseid);
RETURN
    v_rider_fname || ' ' ||  v_rider_lname || ' (' || v_phone ||')';
END;


-- Create Function
-- Get total clubs budget of all clubs:
CREATE OR REPLACE FUNCTION UDF_Get_Budget  
RETURN NUMBER

IS 
    -- variable --
    v_sum NUMBER;
BEGIN
    SELECT 
        SUM(budget)
        INTO v_sum
    FROM 
        clubs;

RETURN
    v_sum;
END;

-- Create Function
-- Get rider's name and age:
CREATE OR REPLACE FUNCTION UDF_Get_Rider_Name_Age(
        -- parameter --
        p_rider_id contestants.rider_id%TYPE
)

RETURN VARCHAR2
IS
        -- variables --
    v_fname contestants.first_name%TYPE;
    v_lname contestants.last_name%TYPE;
    v_age NUMBER;
BEGIN
    SELECT
        first_name, last_name, FLOOR((SYSDATE - birth_date)/365)
        INTO  v_fname, v_lname, v_age
    FROM
        contestants
    WHERE 
        rider_id = p_rider_id;
    
    RETURN  v_fname || ' ' ||  v_lname ||' <' || v_age || '>';
END;

-- Create Function
-- Get rider's ID_Card as masked data:
CREATE OR REPLACE FUNCTION UDF_Get_Rider_IDCARD(
        -- parameter --
        p_rider_d contestants.rider_id%TYPE
)
RETURN 
    VARCHAR2
IS
        -- variables --
    v_fname contestants.first_name%TYPE;
    v_l_name contestants.last_name%TYPE;
    v_cardid contestants.id_card%TYPE;
BEGIN
    SELECT 
        first_name, last_name, id_card
        INTO v_fname, v_l_name, v_cardid
    FROM
        contestants
    WHERE
        rider_id =  p_rider_d;
RETURN
    SUBSTR(v_fname, 1, 1) || '. ' ||  v_l_name || ', ID_CARD: ' || REGEXP_REPLACE ( v_cardid, '(.+)(\d{4})$', '\1****');
END;
