
 RMDS: Advanced Database Programming
 Phase VI & VII: Packages, Triggers & Auditing
 Author: MUTAZ


SET DEFINE OFF;

 1. Create Package Specification
CREATE OR REPLACE PACKAGE restaurant_pkg AS
    PROCEDURE add_menu_item (
        p_name IN VARCHAR2,
        p_category IN VARCHAR2,
        p_price IN NUMBER
    );

    FUNCTION get_item_subtotal (
        p_item_id IN NUMBER,
        p_quantity IN NUMBER
    ) RETURN NUMBER;

    PROCEDURE list_all_menu_items;
END restaurant_pkg;
/

 2. Create Package Body
CREATE OR REPLACE PACKAGE BODY restaurant_pkg AS

    -- Procedure with Exception Handling & COMMIT
    PROCEDURE add_menu_item (
        p_name IN VARCHAR2,
        p_category IN VARCHAR2,
        p_price IN NUMBER
    ) IS
    BEGIN
        INSERT INTO Menu_Items (item_name, category, price)
        VALUES (p_name, p_category, p_price);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Success: ' || p_name || ' added to package menu.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in add_menu_item: Transaction Rollbacked.');
            ROLLBACK;
    END add_menu_item;

    -- Function with Exception Handling
    FUNCTION get_item_subtotal (
        p_item_id IN NUMBER,
        p_quantity IN NUMBER
    ) RETURN NUMBER IS
        v_price NUMBER(6,2);
        v_subtotal NUMBER(8,2);
    BEGIN
        SELECT price INTO v_price FROM Menu_Items WHERE item_id = p_item_id;
        v_subtotal := v_price * p_quantity;
        RETURN v_subtotal;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RETURN 0;
    END get_item_subtotal;

    -- Procedure using an Explicit Cursor
    PROCEDURE list_all_menu_items IS
        CURSOR c_menu IS 
            SELECT item_id, item_name, price FROM Menu_Items;
        v_id    Menu_Items.item_id%TYPE;
        v_name  Menu_Items.item_name%TYPE;
        v_price Menu_Items.price%TYPE;
    BEGIN
        OPEN c_menu;
        DBMS_OUTPUT.PUT_LINE('--- CURRENT RESTAURANT MENU ---');
        LOOP
            FETCH c_menu INTO v_id, v_name, v_price;
            EXIT WHEN c_menu%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ' | Item: ' || v_name || ' | Price: ' || v_price);
        END LOOP;
        CLOSE c_menu;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error using cursor.');
    END list_all_menu_items;

END restaurant_pkg;
/
 3. Create Security Restrictions Trigger (Simple Trigger)
CREATE OR REPLACE TRIGGER restrict_menu_changes
BEFORE INSERT OR UPDATE OR DELETE ON Menu_Items
DECLARE
    v_holiday_count NUMBER;
    v_day_name VARCHAR2(20);
BEGIN
    v_day_name := TO_CHAR(SYSDATE, 'DAY', 'NLS_DATE_LANGUAGE=ENGLISH');
    
    SELECT COUNT(*) INTO v_holiday_count 
    FROM Public_Holidays 
    WHERE TRUNC(holiday_date) = TRUNC(SYSDATE);

    IF TRIM(v_day_name) IN ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY') 
       OR v_holiday_count > 0 THEN
       
        RAISE_APPLICATION_ERROR(-20001, 'Security Restriction: Modifications to Menu_Items are blocked during weekdays or public holidays.');
    END IF;
END;
/

 4. Create Audit Compound Trigger (Advanced Trigger)
CREATE OR REPLACE TRIGGER audit_menu_compound
FOR INSERT OR UPDATE OR DELETE ON Menu_Items
COMPOUND TRIGGER

    v_action VARCHAR2(20);

    AFTER EACH ROW IS
    BEGIN
        IF INSERTING THEN
            v_action := 'INSERT';
        ELIF UPDATING THEN
            v_action := 'UPDATE';
        ELIF DELETING THEN
            v_action := 'DELETE';
        END IF;

        INSERT INTO Audit_Log (username, action_type, table_name, action_date)
        VALUES (USER, v_action, 'MENU_ITEMS', SYSTIMESTAMP);
    END AFTER EACH ROW;

END audit_menu_compound;
/