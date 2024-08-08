CREATE DATABASE hack;
USE hack;
drop database hack;

CREATE TABLE users (
  Id INT AUTO_INCREMENT PRIMARY KEY,
  Email VARCHAR(255) NOT NULL,
  Password VARCHAR(255) NOT NULL,
  Latitude DECIMAL(10, 3) NOT NULL,
  Longitude DECIMAL(10, 3) NOT NULL,
  LocationName VARCHAR(255) NOT NULL
);


select * from users;
drop table users;

INSERT INTO users (Email, Password, Latitude, Longitude, LocationName)
VALUES ('satvik@gmail.com', '123456', 37.785, -122.406, 'Ventura County');

INSERT INTO users (Email, Password, Latitude, Longitude, LocationName)
VALUES ('satvik@123.com', '12345', 37.785, -122.406, 'Dublin');

CREATE TABLE IF NOT EXISTS students_profile (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  student_First_Name VARCHAR(255) NOT NULL,
  student_Last_Name VARCHAR(255) NOT NULL,
  Age INT,
  Email VARCHAR(255) UNIQUE NOT NULL,
  Password VARCHAR(255),
  Alternate_Email VARCHAR(255),
  Address_line_1 VARCHAR(255),
  Address_line_2 VARCHAR(255),
  Zip_code VARCHAR(10),
  parent_guardian VARCHAR(255),
  secondary_parent_guardian VARCHAR(255),
  phonenumber VARCHAR(15),
  sign_up_date DATE,
  expire_date DATE,
  dw_create_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO students_profile (
  student_First_Name,
  student_Last_Name,
  Age,
  Email,
  Password,
  Alternate_Email,
  Address_line_1,
  Address_line_2,
  Zip_code,
  parent_guardian,
  secondary_parent_guardian,
  phonenumber,
  sign_up_date,
  expire_date
) VALUES (
  'John',
  'Doe',
  20,
  'john.doe@example.com',
  NULL,
  'john.alternate@example.com',
  '123 Main St',
  'Apt 456',
  '12345',
  'Jane Doe',
  'Jim Doe',
  '1234567890',
  '2024-03-04', 
  '2025-03-04' 
);


CREATE TABLE IF NOT EXISTS checked_in (
  check_in_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT,
  Email VARCHAR(255) NOT NULL,
  Checkin_DateTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  Checkout_DateTime DATETIME,
  stayForDinner ENUM('Yes', 'No'),
  disclaimerChecked BOOLEAN NOT NULL DEFAULT FALSE,  -- New attribute
  FOREIGN KEY (student_id) REFERENCES students_profile(student_id)
);


select * from students_profile;
select * from checked_in;

UPDATE checked_in
SET Checkout_DateTime = 
  CASE 
    WHEN Checkout_DateTime IS NULL AND NOW() > CONCAT(DATE(Checkin_DateTime), ' 23:59:00') THEN
      CONCAT(DATE(Checkin_DateTime), ' 23:59:00')
    ELSE Checkout_DateTime
  END
WHERE Checkout_DateTime IS NULL AND student_id IS NOT NULL;


drop table checked_in;
drop table students_profile;

SELECT check_in_id, students_profile.student_id, student_First_Name, student_Last_Name, students_profile.Email, Checkin_DateTime
FROM checked_in
JOIN students_profile ON checked_in.student_id = students_profile.student_id
WHERE Checkout_DateTime IS NULL;

CREATE TABLE IF NOT EXISTS mentor_profile (
  mentor_id INT AUTO_INCREMENT PRIMARY KEY,
  mentor_first_name VARCHAR(255) NOT NULL,
  mentor_last_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  subject_expertise VARCHAR(255) NOT NULL,
  signup_date DATE,
  expire_date DATE,
  active BOOLEAN DEFAULT TRUE
);

select * from mentor_profile;
drop table mentor_profile;

INSERT INTO mentor_profile(mentor_first_name, mentor_last_name, email, subject_expertise, signup_date, expire_date, active)
VALUES ('Nathaneal', 'Read', 'nr@gmail.com', 'all', '2020-01-01', NULL, TRUE);

INSERT INTO mentor_profile(mentor_first_name, mentor_last_name, email, subject_expertise, signup_date, expire_date, active)
VALUES ('Bob', 'Smith', 'bsmith@gmail.com', 'all', '2020-01-01', NULL, TRUE);

CREATE TABLE IF NOT EXISTS mentor_schedule(
mentor_id INT, 
week_start_date DATE, 
week_end_date DATE,
active BOOLEAN DEFAULT TRUE,
Monday_start_time TIME,
Monday_end_time TIME, 
Tuesday_start_time TIME,
Tuesday_end_time TIME,
Wednesday_start_time TIME,
Wednesday_end_time TIME,
Thursday_start_time TIME,
Thursday_end_time TIME,
Friday_start_time TIME,
Friday_end_time TIME,
Saturday_start_time TIME,
Saturday_end_time TIME,
Sunday_start_time TIME,
Sunday_end_time TIME
);

select * from mentor_schedule;
drop table mentor_schedule;

INSERT INTO mentor_schedule (mentor_id, week_start_date, week_end_date, active, Monday_start_time, Monday_end_time, Tuesday_start_time, Tuesday_end_time, Wednesday_start_time, Wednesday_end_time, 
    Thursday_start_time, Thursday_end_time, Friday_start_time, Friday_end_time) 
VALUES (1, '2024-06-24', '2024-06-29', TRUE, '14:00:00', '19:00:00', '14:00:00', '19:00:00', '14:00:00', '19:00:00', 
    '14:00:00', '19:00:00', '14:00:00', '19:00:00');

INSERT INTO mentor_schedule (mentor_id, week_start_date, week_end_date, active, Monday_start_time, Monday_end_time, Tuesday_start_time, Tuesday_end_time, Wednesday_start_time, Wednesday_end_time, 
    Thursday_start_time, Thursday_end_time, Friday_start_time, Friday_end_time) 
VALUES (2, '2024-06-24', '2024-06-29', TRUE, '14:00:00', '19:00:00', '14:00:00', '19:00:00', '14:00:00', '19:00:00', 
    '14:00:00', '19:00:00', '14:00:00', '19:00:00');

CREATE TABLE IF NOT EXISTS appointment_center(
appointment_id INT AUTO_INCREMENT PRIMARY KEY, 
mentor_id INT, 
-- topic VARCHAR(255),
schedule_status ENUM('Available', 'Taken'),
appointment_datetime VARCHAR(255),
appointment_timeslot VARCHAR(255),
student_id INT, 
student_status ENUM('show', 'no show'),
mentor_status ENUM('attended', 'canceled'),
booking_datetime DATETIME
);

drop table appointment_center;
select * from appointment_center;

-- Start

-- 1. New Tables for Admin Dashboard to Retrieve Dashboard on Demand
CREATE TABLE IF NOT EXISTS admin_dashboard_checkin (
  dashboard_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT,
  student_First_Name VARCHAR(255),
  student_Last_Name VARCHAR(255),
  Checkin_DateTime TIMESTAMP,
  Checkout_DateTime TIMESTAMP,
  stayForDinner ENUM('Yes', 'No'),
  FOREIGN KEY (student_id) REFERENCES students_profile(student_id)
);

-- Insert Query for incoming check-in data
INSERT INTO admin_dashboard_checkin (
  student_id, 
  student_First_Name, 
  student_Last_Name, 
  Checkin_DateTime, 
  stayForDinner
) 
SELECT 
  c.student_id, 
  s.student_First_Name, 
  s.student_Last_Name, 
  c.Checkin_DateTime, 
  c.stayForDinner 
FROM checked_in c
JOIN students_profile s ON c.student_id = s.student_id
WHERE c.Checkout_DateTime IS NULL;

-- Update Query for incoming checkout data
UPDATE admin_dashboard_checkin 
SET Checkout_DateTime = NOW()
WHERE student_id = 1 AND Checkout_DateTime IS NULL;

-- 2. Manually Add 1 on 1s in Admin Dashboard
CREATE TABLE IF NOT EXISTS admin_appointments (
  appointment_id INT AUTO_INCREMENT PRIMARY KEY,
  mentor_id INT,
  student_id INT,
  appointment_datetime TIMESTAMP,
  topic VARCHAR(255),
  FOREIGN KEY (mentor_id) REFERENCES mentor_profile(mentor_id),
  FOREIGN KEY (student_id) REFERENCES students_profile(student_id)
);

-- Insert Query for new 1 on 1 appointments
INSERT INTO admin_appointments (
  mentor_id, 
  student_id, 
  appointment_datetime, 
  topic
) 
VALUES (1, 1, '2024-07-31 10:00:00', 'Homework');

-- 3. New Tables for Admin Dashboard to Retrieve Dashboard on Up-to-Date Setup
CREATE TABLE IF NOT EXISTS admin_dashboard_setup (
  setup_id INT AUTO_INCREMENT PRIMARY KEY,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  configuration JSON
);

-- Insert or Update the setup information
INSERT INTO admin_dashboard_setup (configuration) 
VALUES ('{"example_config_key": "example_value"}')
ON DUPLICATE KEY UPDATE
configuration = VALUES(configuration);

-- 4. Remove Availability and Student Appointments for 1:1 from Kiosk as Admins Will Handle
ALTER TABLE appointment_center 
DROP COLUMN schedule_status,
DROP COLUMN appointment_datetime,
DROP COLUMN appointment_timeslot;

-- Ensure admin_appointments table handles this data instead

-- 5. Create Database for Daily Check-ins and Checkouts for Admin Access Up to 30 Days
CREATE TABLE IF NOT EXISTS daily_checkins (
  record_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT,
  student_First_Name VARCHAR(255),
  student_Last_Name VARCHAR(255),
  Checkin_DateTime TIMESTAMP,
  Checkout_DateTime TIMESTAMP,
  stayForDinner ENUM('Yes', 'No'),
  FOREIGN KEY (student_id) REFERENCES students_profile(student_id)
);

-- Insert Query for new daily records
INSERT INTO daily_checkins (
  student_id, 
  student_First_Name, 
  student_Last_Name, 
  Checkin_DateTime, 
  Checkout_DateTime, 
  stayForDinner
) 
SELECT 
  c.student_id, 
  s.student_First_Name, 
  s.student_Last_Name, 
  c.Checkin_DateTime, 
  c.Checkout_DateTime, 
  c.stayForDinner 
FROM checked_in c
JOIN students_profile s ON c.student_id = s.student_id
WHERE c.Checkin_DateTime >= CURDATE() - INTERVAL 30 DAY;

-- Query to retrieve data up to 30 days
SELECT * FROM daily_checkins
WHERE Checkin_DateTime >= CURDATE() - INTERVAL 30 DAY;
