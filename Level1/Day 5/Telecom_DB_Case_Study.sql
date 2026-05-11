-- =====================================================
-- PART 1
-- =====================================================

-- Q1 : CREATE database telecom_db
CREATE database telecom_db;
USE telecom_db;

-- Q2 : Create table subscribers 
CREATE TABLE subscribers (
    subscriber_id    INT           AUTO_INCREMENT PRIMARY KEY,
    subscriber_name  VARCHAR(100)  NOT NULL,
    phone_number     VARCHAR(20)   UNIQUE,
    city             VARCHAR(50),
    registration_date DATE
);

-- Q3 : Create table plans 
CREATE TABLE plans (
    plan_id      INT            AUTO_INCREMENT PRIMARY KEY,
    plan_name    VARCHAR(100),
    monthly_fee  DECIMAL(10,2),
    data_limit   INT            -- in GB
);

-- Q4 : Create table usuage_records
 CREATE TABLE usage_records (
    usage_id      INT            AUTO_INCREMENT PRIMARY KEY,
    subscriber_id INT,
    data_used     DECIMAL(10,2),
    call_minutes  INT,
    usage_date    DATE,
    CONSTRAINT fk_usage_subscriber
        FOREIGN KEY (subscriber_id) REFERENCES subscribers(subscriber_id)
        ON DELETE CASCADE
);

-- Q5 : Add column email to subscriber
ALTER TABLE subscribers
ADD email VARCHAR(100);

-- Q6 : Modify column city 
ALTER TABLE subscribers
MODIFY city VARCHAR(100);

-- Q7 : Drop column email
ALTER TABLE subscribers
DROP COLUMN email;

-- =====================================================
-- PART 2 
-- =====================================================

-- Q8 :  Insert subscribers
INSERT INTO subscribers (subscriber_name, phone_number, city, registration_date) VALUES
    ('Aung Aung', '0912345678', 'Yangon',   '2025-01-01'),
    ('Su Su',     '0923456789', 'Mandalay', '2025-02-01'),
    ('Kyaw Kyaw', '0934567890', 'Yangon',   '2025-03-01');
    
-- Q9 : Insert Plans 
INSERT INTO plans (plan_name, monthly_fee, data_limit) VALUES
    ('Basic',    10, 5),
    ('Standard', 20, 10),
    ('Premium',  30, 20);

-- Q10 : Insert Usage Records
INSERT INTO usage_records (subscriber_id, data_used, call_minutes, usage_date) VALUES
    (1, 2.5, 30, '2025-04-01'),   -- Aung Aung: first record
    (1, 1.0, 10, '2025-04-02'),   -- Aung Aung: second record
    (2, 5.0, 60, '2025-04-01'),   -- Su Su
    (3, 8.0, 90, '2025-04-03');
    
-- Q11 : Update Data Usage
UPDATE usage_records
SET    data_used = data_used + 1
WHERE  subscriber_id = 1;

-- Q12 : Delete Inactive Subscriber
DELETE FROM subscribers
WHERE  subscriber_id = 3;

-- =====================================================
-- PART 3
-- =====================================================

-- Q13 : Select All Subscribers
SELECT * FROM subscribers;

-- Q14 : Find Subscribers in Yangon
SELECT * FROM subscribers
WHERE  city = 'Yangon';

-- Q15 : Total Data Usage per Subscriber
SELECT   subscriber_id,
         SUM(data_used) AS total_data
FROM     usage_records
GROUP BY subscriber_id;

-- Q16 : Subscriber with High Usage (> 5GB)
SELECT   subscriber_id,
         SUM(data_used) AS total_data
FROM     usage_records
GROUP BY subscriber_id
HAVING   SUM(data_used) > 5;

-- Q17 : Sort Subscribers by Registration Date (Latest First)
SELECT * FROM subscribers
ORDER BY registration_date DESC;

-- Q18 : Join Subscriber with Usage Records
SELECT  s.subscriber_name,
        u.data_used,
        u.call_minutes,
        u.usage_date
FROM    subscribers  s
JOIN    usage_records u ON s.subscriber_id = u.subscriber_id
ORDER BY s.subscriber_name, u.usage_date;

-- =====================================================
-- PART 4 
-- =====================================================

-- Q19 : Data Correction with Rollback
START TRANSACTION;
UPDATE usage_records
SET    data_used = data_used + 10
WHERE  subscriber_id = 2;
-- Inside transaction: current session sees the change
SELECT subscriber_id, data_used FROM usage_records WHERE subscriber_id = 2;
-- Result: 15.00 (5.00 + 10.00)
ROLLBACK;

-- Q20 : Confirm Update with commit 
START TRANSACTION;

UPDATE usage_records
SET    data_used = data_used + 2
WHERE  subscriber_id = 2;

COMMIT;

-- Q21 : Use savepoint
START TRANSACTION;
-- First update: +1 GB to subscriber 1
UPDATE usage_records SET data_used = data_used + 1 WHERE subscriber_id = 1;
SAVEPOINT sp1;  -- Checkpoint saved here
-- Second update: +5 GB to subscriber 1
UPDATE usage_records SET data_used = data_used + 5 WHERE subscriber_id = 1;
-- Rollback only the second update (after sp1)
ROLLBACK TO SAVEPOINT sp1;
-- Commit the first update (before sp1) permanently
COMMIT;

-- =====================================================
-- PART 5
-- =====================================================

-- Q22 :  Create User : telecom_user
CREATE USER 'telecom_user'@'localhost' IDENTIFIED BY 'password123';
-- Verify the user was created
SELECT user, host FROM mysql.user WHERE user = 'telecom_user';

-- Q23 : Grant SELECT Access on Entire Database
GRANT SELECT
ON    telecom_db.*
TO    'telecom_user'@'localhost';

-- Q24 : Grant INSERT and UPDATE on usage_records
GRANT INSERT, UPDATE
ON    telecom_db.usage_records
TO    'telecom_user'@'localhost';

-- Q25 : Revoke UPDATE Permission
REVOKE UPDATE
ON    telecom_db.usage_records
FROM  'telecom_user'@'localhost';

-- Q26 : Show All Permissions for telecom_user
SHOW GRANTS FOR 'telecom_user'@'localhost';

-- Q27 : Drop User: telecom_user
DROP USER 'telecom_user'@'localhost';














    
    





