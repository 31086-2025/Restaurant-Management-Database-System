
 RMDS: Restaurant Management Database System
 Phase IV & V: Table Creation & Setup
 Author: MUTAZ

 1. Drop existing tables to ensure clean installation (Optional)
DROP TABLE Audit_Log CASCADE CONSTRAINTS;
DROP TABLE Public_Holidays CASCADE CONSTRAINTS;
DROP TABLE Menu_Items CASCADE CONSTRAINTS;

2. Create Core Menu Items Table
CREATE TABLE Menu_Items (
    item_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    item_name VARCHAR2(100) NOT NULL,
    category VARCHAR2(50) NOT NULL,
    price NUMBER(6,2) NOT NULL CONSTRAINT chk_price_positive CHECK (price > 0)
);

3. Create Public Holidays Table (For Security Rules)
CREATE TABLE Public_Holidays (
    holiday_date DATE PRIMARY KEY,
    holiday_name VARCHAR2(100) NOT NULL
);

 4. Create Audit Log Table (For User Activity Tracking)
CREATE TABLE Audit_Log (
    log_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR2(30),
    action_type VARCHAR2(20),
    table_name VARCHAR2(30),
    action_date TIMESTAMP
);

-- 5. Insert Sample Data
INSERT INTO Menu_Items (item_name, category, price) VALUES ('Burger', 'Main Course', 12.50);
INSERT INTO Menu_Items (item_name, category, price) VALUES ('Pizza', 'Main Course', 15.00);
INSERT INTO Menu_Items (item_name, category, price) VALUES ('Coca Cola', 'Beverage', 2.50);
INSERT INTO Menu_Items (item_name, category, price) VALUES ('Pasta', 'Main Course', 14.00);

 Insert Holiday (Sample for Testing: National Holiday)
INSERT INTO Public_Holidays VALUES (TO_DATE('2026-07-12', 'YYYY-MM-DD'), 'National Holiday');

COMMIT;