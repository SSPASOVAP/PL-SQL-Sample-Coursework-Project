-------------------------------------------------------------------------------           
            -------- Some Interesting and Useful Queries --------
------------------------------------------------------------------------------- 

-- 1. Type a query that selects how many events have at the database:
SELECT
    COUNT(*)
FROM
    events;


-- 2. Type a query that selects how many contestants have per salutation:
    SELECT
    COUNT(rider_id)
FROM
    contestants 
GROUP BY
    salutation_id;


-- 3. Type a query that splits the Reg_Dates to its elements:
SELECT
    reg_id
,   reg_date
,   EXTRACT(YEAR FROM reg_date) "Year"
,   EXTRACT(MONTH FROM reg_date) "Month"
,   EXTRACT(DAY FROM reg_date) "Day"
,   'Qtr. ' || TO_CHAR(reg_date, 'Q') Qtr
,   TO_CHAR(reg_date, 'D') day_of_week
,   TO_CHAR(reg_date, 'DD') day_of_month
,   TO_CHAR(reg_date, 'W') week_of_month
,   TO_CHAR(reg_date, 'WW') week_of_year
,   TO_CHAR(reg_date, 'Day', 'NLS_DATE_LANGUAGE = English') day_name
,   TO_CHAR(reg_date, 'Month', 'NLS_DATE_LANGUAGE = English') month_name
,   TO_CHAR(reg_date, 'dd-Mon-yyyy', 'NLS_DATE_LANGUAGE = English') "date"
,   TO_CHAR(reg_date, 'dd-Month', 'NLS_DATE_LANGUAGE = English') day_month
FROM
    registrations
WHERE 
    cancel_date IS NULL
ORDER BY
    reg_date


-- 4. Type a query that shows contestants in below format: 
-- F. Name Last Name  <age>, ID_Card as 123456****
SELECT
    SUBSTR(first_name, 1, 1) || '.' || Last_name || ' <' ||
        FLOOR((SYSDATE - birth_date)/365) || '>' Riders_details
,   REGEXP_REPLACE (id_card, '(.+)(\d{4})$', '\1****') masked_card
FROM
    contestants


-- 5. Problem: Is there a rider participating with more than 1 horse?:
SELECT 
    vt.first_name || ' ' || vt.last_name
,   vt.horse_count
FROM
    (SELECT
            t1.rider_id
        ,   t1.first_name
        ,   t1.last_name
        ,   COUNT(*) horse_count
        FROM
            contestants t1
                INNER JOIN
            horses t2
            ON t2.rider_id = t1.rider_id
        GROUP BY
            t1.rider_id
        ,   t1.first_name
        ,   t1.last_name
        ) VT
WHERE 
    vt.horse_count > 1


-- 6. Problem: Are there riders who are members of clubs outside their city?. 
-- Show rider's name, rider's city, club's name and club's city:
SELECT 
    t1.first_name || ' ' || t1.last_name
,   t2.city_name Rider_city
,   t3.club_name
,   t4.city_name Club_city
FROM
    contestants t1
        INNER JOIN
    cities t2
        ON t1.city_id = t2.city_id
        INNER JOIN
    clubs t3
        ON t1.club_id = t3.club_id
        INNER JOIN
    cities t4
        ON t4.city_id = t3.city_id
WHERE 
    t2.city_name <> t4.city_name


-- 7. Problem: Are there riders that will not attend any of the events?:
-- Show those who has not registered and those who has registered but then canceled:
SELECT
    t1.first_name || ' ' || t1.last_name Full_Name
,   t3.event_name
FROM
    
    contestants t1
        LEFT OUTER JOIN(
    registrations t2
        INNER JOIN
    events t3
        ON t3.event_id = t2.event_id
        )
         ON t2.rider_id = t1.rider_id
WHERE 
    t2.cancel_date IS NOT NULL
    OR
    t3.event_name IS NULL
ORDER BY
    2 NULLS FIRST


--8. Type a query that shows all winners at the event with ID = 1:
-- Show Rider's full name, horse's name, award type along with the money prize in EUR and BGN:
SELECT 
    t4.first_name || ' ' || t4.last_name  full_name
,   t3.horse_name
,   t1.award_type
,   TO_CHAR(t2.money_prize_eur, '999999.99C', 'NLS_ISO_CURRENCY = Spain') Mony_price_eur
,   TO_CHAR(t2.money_prize_eur * 1.95583, '999999.99C', 'NLS_ISO_CURRENCY = Bulgaria') Mony_price_bgn
FROM
    awards t1
        INNER JOIN
    awarding t2
        ON t2.award_id = t1.award_id
        INNER JOIN
    horses t3
        ON t3.horse_id = t2.horse_id
        INNER JOIN
    contestants t4
        ON t3.rider_id = t4.rider_id
WHERE 
    t2.event_id = 1 AND 
    t2.award_id IS NOT NULL
ORDER BY 
    t2.total_score DESC


-- 9. Type a query that shows which are the clubs having above or equal to the average of the budget from all registered clubs.
-- Calculate result not as a global value, but according to each activity:
WITH 
    clubs_budgeting
        AS (SELECT 
                t1.club_name
            ,   t1.chairman
            ,   t1.budget
            ,   t2.activity
            FROM
                clubs t1
                    INNER JOIN
                activities t2
                    ON t1.activity_id = t2.activity_id
            )
,   activity_avg

        AS (SELECT
                cb.activity
            ,   AVG(cb.budget) activity_avg
            FROM
                clubs_budgeting cb
            GROUP BY 
                cb.activity
            )
SELECT
    cb.club_name
,   cb.chairman
,   cb.budget
,   cb.activity
FROM
    clubs_budgeting cb
        INNER JOIN
     activity_avg aa
        ON cb.activity = aa.activity
WHERE 
    cb.budget >= aa.activity_avg


-- 10. Type a query that shows all riders in database split per age groups like: 
-- 14 - 20, 21 - 30, 30 - 40 for each activity of their clubs.
-- Show the result with Grand Totals as a Pivot:
WITH 
    activities_summary
        AS (SELECT
        t3.activity
    ,   FLOOR((SYSDATE - t1.birth_date)/365) Age
    FROM
        contestants t1
            INNER JOIN
        clubs t2
            ON t1.club_id = t2.club_id
            INNER JOIN
        activities t3
            ON t3.activity_id = t2.activity_id
            )
,   riders_counts
        AS (SELECT
            asum.activity
        ,   SUM(CASE WHEN asum.age BETWEEN 14 AND 20 THEN 1 ELSE 0 END) Btw_15_20
        ,   SUM(CASE WHEN asum.age BETWEEN 21 AND 30 THEN 1 ELSE 0 END) Btw_21_30
        ,   SUM(CASE WHEN asum.age BETWEEN 31 AND 40 THEN 1 ELSE 0 END) Btw_31_40
        ,   COUNT(asum.age) Total_Count
        FROM
             activities_summary asum 
        GROUP BY
             asum.activity
             )
SELECT
    rc.activity
,   rc.btw_15_20
,   rc.btw_21_30
,   rc.btw_31_40
,   rc.total_count
FROM
    riders_counts rc
    UNION
SELECT
    NULL -- Grand_Total
,   SUM(rc.btw_15_20)
,   SUM(rc.btw_21_30)
,   SUM(rc.btw_31_40)
,   SUM(rc.total_count)
FROM
    riders_counts rc


-- 11. Type a query that shows the rank for specific event:
SELECT
    t1.event_name
,   t4.first_name || ' ' || t4.last_name Rider_Name
,   t3.horse_name
,   t2.total_score 
,   RANK()
    OVER (ORDER BY t2.total_score DESC) Ranking
FROM
    events t1
       INNER JOIN
    awarding t2
        ON t1.event_id = t2.event_id
        INNER JOIN
    horses t3
        ON t3.horse_id = t2.horse_id
        INNER JOIN
    contestants t4
        ON t3.rider_id = t4.rider_id
WHERE 
    t1.event_id = 1


-- 12. Problem: How many registrations have per year?:
WITH
    yearly_regs
        AS (SELECT 
            EXTRACT(YEAR FROM reg_date) Yearly
        ,   TO_CHAR(reg_date, 'Q') Qtr
        ,   COUNT(reg_id) reg_numb
        FROM
            registrations
    -- Remove where clause to see the the total number of registrations, including ones that are canceled
        WHERE cancel_date IS NULL  -- Change where clause to: IS NOT NULL, to see only canceled ones
        GROUP BY
            EXTRACT(YEAR FROM reg_date)
        ,   TO_CHAR(reg_date, 'Q')
        )
SELECT
    yr.yearly
,   NVL((SELECT(SUM(y.reg_numb)) FROM yearly_regs y WHERE y.yearly = yr.yearly AND y.qtr = 1), 0) Qtr1
,   NVL((SELECT(SUM(y.reg_numb)) FROM yearly_regs y WHERE y.yearly = yr.yearly AND y.qtr = 2), 0) Qtr2
,   NVL((SELECT(SUM(y.reg_numb)) FROM yearly_regs y WHERE y.yearly = yr.yearly AND y.qtr = 3), 0) Qtr3
,   NVL((SELECT(SUM(y.reg_numb)) FROM yearly_regs y WHERE y.yearly = yr.yearly AND y.qtr = 4), 0) Qtr4
FROM
     yearly_regs yr


-- 13. Problem: What is the percentage share between the clubs according to their budgets?:
SELECT
    vt.club_name
,   vt.budget
,   TO_CHAR (vt.budget / vt.total_sum * 100, '990.99') || ' %' Percentage
FROM (SELECT 
    club_name
,   budget
,   SUM(budget)
    OVER(
    ORDER BY budget
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) total_sum
FROM
    clubs
    ) VT -- virtual_table


    -- 13.1. Same as problem 13 + partition by activity of each club:
SELECT
    vt.club_name
,   vt.budget
,   TO_CHAR (vt.budget / vt.total_sum * 100, '990.99') || ' %' Percentage
FROM
    (SELECT 
        t1.club_name
    ,   t1.budget
    ,   SUM(t1.budget)
        OVER(
        PARTITION BY t2.activity
        ORDER BY t1.budget
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) total_sum
    FROM
        clubs t1
        INNER JOIN
        activities t2
            ON t1.activity_id = t2.activity_id
        ) VT


-- 14. Type a query that shows all cities per country and present them like a listed with ',':
SELECT 
    t1.country_name
,   LISTAGG(t2.city_name, ', ') 
    WITHIN GROUP (ORDER BY t2.city_name DESC)
FROM 
    countries t1
        INNER JOIN
    cities t2
        ON t2.country_id = t1.country_id
GROUP BY
    t1.country_name


    --14.1 Type a query showing number of cities, presented graphically:
SELECT 
        t1.country_name
    ,   COUNT(*) n_cities
    ,   RPAD(' ', COUNT(*) * 2, '*' ) Graph
    FROM 
        countries t1
            INNER JOIN
        cities t2
            ON t2.country_id = t1.country_id
    GROUP BY
        t1.country_name
ORDER BY 
    2


--15. Type a query that shows in details all useful information about participating teams (rider and horse):
        -- It is a good candidate for creating a View --

CREATE OR REPLACE VIEW Competitors_Information AS
SELECT
    1.region_name
,   t2.country_name
,   t3.city_name
,   t4.first_name || t4.last_name full_name
,   t5.category_name
,   FLOOR((SYSDATE - t4.birth_date)/365) Age
,   t6.horse_name
,   t7.breed_name
,   t8.gender
,   FLOOR((SYSDATE - t6.birth_date)/365) Horse_Age
,   t9.age_group
FROM
    regions t1
        INNER JOIN
    countries t2
        ON t2.region_id = t1.region_id
        INNER JOIN
    cities t3
        ON t3.country_id = t2.country_id
        INNER JOIN
    contestants t4
        ON t4.city_id = t3.city_id
        INNER JOIN
    categories t5
        ON t5.category_id = t4.category_id
        INNER JOIN
    horses t6
        ON t6.rider_id = t4.rider_id
        INNER JOIN
    breeds t7
        ON t7.breed_id = t6.breed_id
        INNER JOIN
    gender t8
        ON t8.gender_id = t6.gender_id
        INNER JOIN
    age_groups t9
        ON t9.age_group_id = t6.age_group_id
[WITH READ ONLY] -- prevents the underlying tables from changes through the view.
[WITH CHECK OPTION]; -- protects the view from any changes to the underlying table that would produce rows which are not included in the defining query.
