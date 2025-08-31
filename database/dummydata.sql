-- Dummy data for school_performance_2 database
USE school_performance;

-- Insert users (using provided users plus additional ones)
INSERT INTO user (user_id, email, password, role, created_at, updated_at) VALUES
(1, 'jane.smith@example.com', 'b72f634fcca35ececbf21e8138d73f9fcd99f1d022e1db24fbf9569721dbb637', 'guest', '2025-08-24 12:40:58', '2025-08-24 12:40:58'),
(2, 'officer@example.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'officer', '2025-08-24 12:41:18', '2025-08-24 12:41:18'),
(5, 'teacher@example.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'teacher', '2025-08-30 16:34:46', '2025-08-30 16:34:46'),
(6, 'manager@example.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'manager', '2025-08-30 22:07:48', '2025-08-30 22:07:48'),
(7, 'sarah.johnson@school.edu', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'teacher', '2025-08-20 09:15:30', '2025-08-20 09:15:30'),
(8, 'michael.brown@school.edu', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'teacher', '2025-08-21 10:22:15', '2025-08-21 10:22:15'),
(9, 'emily.davis@school.edu', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'teacher', '2025-08-22 11:30:45', '2025-08-22 11:30:45'),
(10, 'david.wilson@school.edu', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'teacher', '2025-08-23 14:45:20', '2025-08-23 14:45:20'),
(11, 'lisa.anderson@school.edu', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'teacher', '2025-08-24 08:30:10', '2025-08-24 08:30:10'),
(12, 'john.martinez@school.edu', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'officer', '2025-08-25 13:20:35', '2025-08-25 13:20:35');

-- Insert profiles for users
INSERT INTO profile (name, phone_number, dob, user_id) VALUES
('Jane Smith', '+94771234567', '1990-05-15', 1),
('Administrative Officer', '+94112345678', '1985-03-22', 2),
('Sarah Johnson', '+94773456789', '1988-07-10', 5),
('Manager Admin', '+94114567890', '1982-12-08', 6),
('Sarah Johnson', '+94775678901', '1987-09-12', 7),
('Michael Brown', '+94776789012', '1985-11-25', 8),
('Emily Davis', '+94777890123', '1989-02-18', 9),
('David Wilson', '+94778901234', '1986-06-30', 10),
('Lisa Anderson', '+94779012345', '1984-04-14', 11),
('John Martinez', '+94770123456', '1983-08-27', 12);

-- Insert courses
INSERT INTO course (name, hall, year, user_id) VALUES
('Grade 10 A', 'Hall A', '2025', 6),
('Grade 10 B', 'Hall B', '2025', 6),
('Grade 11 A', 'Hall C', '2025', 6),
('Grade 11 B', 'Hall D', '2025', 6),
('Grade 12 A', 'Hall E', '2025', 6),
('Grade 12 B', 'Hall F', '2025', 6),
('Grade 9 A', 'Hall G', '2025', 6),
('Grade 9 B', 'Hall H', '2025', 6);

-- Insert subjects
INSERT INTO subject (name, weight, user_id) VALUES
('Mathematics', 4.0, 6),
('Science', 3.5, 6),
('English', 3.0, 6),
('History', 2.5, 6),
('Geography', 2.5, 6),
('Information Technology', 3.0, 6),
('Sinhala', 2.0, 6),
('Tamil', 2.0, 6),
('Religion', 1.5, 6),
('Physical Education', 1.0, 6);

-- Insert 100 students with realistic Sri Lankan names and data
INSERT INTO student (parent_nic, full_name, dob, user_id) VALUES
('751234567V', 'Amal Perera', '2008-01-15', 6),
('762345678V', 'Nimal Silva', '2008-02-20', 6),
('773456789V', 'Kamala Fernando', '2008-03-10', 6),
('784567890V', 'Sunil Jayawardena', '2008-04-25', 6),
('795678901V', 'Mala Gunasekara', '2008-05-30', 6),
('806789012V', 'Ravi Mendis', '2008-06-12', 6),
('817890123V', 'Sita Rajapaksa', '2008-07-18', 6),
('828901234V', 'Kumar Wickramasinghe', '2008-08-22', 6),
('839012345V', 'Indira Bandara', '2008-09-14', 6),
('840123456V', 'Ajith Dissanayake', '2008-10-08', 6),
('751345678V', 'Chandra Wijeratne', '2007-01-12', 6),
('762456789V', 'Priya Senanayake', '2007-02-28', 6),
('773567890V', 'Rohan Amarasinghe', '2007-03-15', 6),
('784678901V', 'Sandya Kumarasinghe', '2007-04-20', 6),
('795789012V', 'Dilshan Peiris', '2007-05-25', 6),
('806890123V', 'Malini Karunaratne', '2007-06-30', 6),
('817901234V', 'Thilaka Abeywardena', '2007-07-10', 6),
('829012345V', 'Janaka Liyanage', '2007-08-15', 6),
('830123456V', 'Kumari Herath', '2007-09-20', 6),
('841234567V', 'Dilan Rathnayake', '2007-10-25', 6),
('752345678V', 'Nadeeka Pathirana', '2006-01-05', 6),
('763456789V', 'Chaminda Weerasinghe', '2006-02-10', 6),
('774567890V', 'Anoma Jayasuriya', '2006-03-18', 6),
('785678901V', 'Upul Ratnayake', '2006-04-22', 6),
('796789012V', 'Shanti Perera', '2006-05-28', 6),
('807890123V', 'Nuwan Silva', '2006-06-15', 6),
('818901234V', 'Deepika Fernando', '2006-07-20', 6),
('820012345V', 'Gamini Jayawardena', '2006-08-25', 6),
('831123456V', 'Shirani Gunasekara', '2006-09-12', 6),
('842234567V', 'Mahesh Mendis', '2006-10-18', 6),
('753456789V', 'Lakshmi Rajapaksa', '2009-01-08', 6),
('764567890V', 'Prasad Wickramasinghe', '2009-02-14', 6),
('775678901V', 'Kumudini Bandara', '2009-03-20', 6),
('786789012V', 'Sarath Dissanayake', '2009-04-26', 6),
('797890123V', 'Ranjani Wijeratne', '2009-05-15', 6),
('808901234V', 'Viraj Senanayake', '2009-06-22', 6),
('810012345V', 'Padma Amarasinghe', '2009-07-28', 6),
('821123456V', 'Asanka Kumarasinghe', '2009-08-10', 6),
('832234567V', 'Mallika Peiris', '2009-09-16', 6),
('843345678V', 'Tharindu Karunaratne', '2009-10-22', 6),
('754567890V', 'Chamari Abeywardena', '2008-11-05', 6),
('765678901V', 'Buddhika Liyanage', '2008-12-12', 6),
('776789012V', 'Nimali Herath', '2008-11-18', 6),
('787890123V', 'Ruwan Rathnayake', '2008-12-24', 6),
('798901234V', 'Chitra Pathirana', '2009-01-30', 6),
('800012345V', 'Hasitha Weerasinghe', '2009-02-05', 6),
('811123456V', 'Vineeta Jayasuriya', '2009-03-12', 6),
('822234567V', 'Danushka Ratnayake', '2009-04-18', 6),
('833345678V', 'Prabha Perera', '2009-05-24', 6),
('844456789V', 'Manoj Silva', '2009-06-30', 6),
('755678901V', 'Chandima Fernando', '2007-11-06', 6),
('766789012V', 'Rasika Jayawardena', '2007-12-14', 6),
('777890123V', 'Nelum Gunasekara', '2007-11-20', 6),
('788901234V', 'Sampath Mendis', '2007-12-26', 6),
('790012345V', 'Hemanthi Rajapaksa', '2008-01-02', 6),
('801123456V', 'Thusitha Wickramasinghe', '2008-02-08', 6),
('812234567V', 'Rangani Bandara', '2008-03-16', 6),
('823345678V', 'Chathura Dissanayake', '2008-04-22', 6),
('834456789V', 'Sriyani Wijeratne', '2008-05-28', 6),
('845567890V', 'Lahiru Senanayake', '2008-06-04', 6),
('756789012V', 'Wasana Amarasinghe', '2006-11-10', 6),
('767890123V', 'Mahinda Kumarasinghe', '2006-12-16', 6),
('778901234V', 'Renuka Peiris', '2006-11-22', 6),
('780012345V', 'Sujeewa Karunaratne', '2006-12-28', 6),
('791123456V', 'Kanchana Abeywardena', '2007-01-04', 6),
('802234567V', 'Roshan Liyanage', '2007-02-10', 6),
('813345678V', 'Damayanthi Herath', '2007-03-18', 6),
('824456789V', 'Neranjan Rathnayake', '2007-04-24', 6),
('835567890V', 'Champika Pathirana', '2007-05-30', 6),
('846678901V', 'Nalaka Weerasinghe', '2007-06-06', 6),
('757890123V', 'Shanika Jayasuriya', '2009-11-12', 6),
('768901234V', 'Aruna Ratnayake', '2009-12-18', 6),
('770012345V', 'Menuka Perera', '2009-11-24', 6),
('781123456V', 'Jagath Silva', '2009-12-30', 6),
('792234567V', 'Chathurika Fernando', '2010-01-06', 6),
('803345678V', 'Amila Jayawardena', '2010-02-12', 6),
('814456789V', 'Sumana Gunasekara', '2010-03-20', 6),
('825567890V', 'Ravindra Mendis', '2010-04-26', 6),
('836678901V', 'Kusuma Rajapaksa', '2010-05-02', 6),
('847789012V', 'Nalin Wickramasinghe', '2010-06-08', 6),
('758901234V', 'Swarna Bandara', '2008-07-14', 6),
('760012345V', 'Susantha Dissanayake', '2008-08-20', 6),
('771123456V', 'Ayesha Wijeratne', '2008-09-26', 6),
('782234567V', 'Charith Senanayake', '2008-10-02', 6),
('793345678V', 'Geethika Amarasinghe', '2008-11-08', 6),
('804456789V', 'Saminda Kumarasinghe', '2008-12-14', 6),
('815567890V', 'Kalyani Peiris', '2009-01-20', 6),
('826678901V', 'Duminda Karunaratne', '2009-02-26', 6),
('837789012V', 'Shiroma Abeywardena', '2009-03-04', 6),
('848890123V', 'Niroshan Liyanage', '2009-04-10', 6),
('750901234V', 'Madhavi Herath', '2007-05-16', 6),
('761012345V', 'Ajantha Rathnayake', '2007-06-22', 6),
('772123456V', 'Sulochana Pathirana', '2007-07-28', 6),
('783234567V', 'Jayantha Weerasinghe', '2007-08-04', 6),
('794345678V', 'Nishantha Jayasuriya', '2007-09-10', 6),
('805456789V', 'Preethi Ratnayake', '2007-10-16', 6),
('816567890V', 'Udaya Perera', '2007-11-22', 6),
('827678901V', 'Kanthi Silva', '2007-12-28', 6),
('838789012V', 'Rohan Fernando', '2008-01-04', 6),
('840890123V', 'Sudharma Jayawardena', '2008-02-10', 6),
('751901234V', 'Dinesh Gunasekara', '2006-03-16', 6),
('762012345V', 'Indrani Mendis', '2006-04-22', 6),
('773123456V', 'Wasantha Rajapaksa', '2006-05-28', 6),
('784234567V', 'Champa Wickramasinghe', '2006-06-04', 6);

-- Insert subject_course_teacher relationships
INSERT INTO subject_course_teacher (subject_id, course_id, teacher_id, user_id) VALUES
-- Mathematics teachers
(1, 1, 5, 6), (1, 2, 7, 6), (1, 3, 8, 6), (1, 4, 5, 6),
(1, 5, 7, 6), (1, 6, 8, 6), (1, 7, 5, 6), (1, 8, 7, 6),
-- Science teachers
(2, 1, 8, 6), (2, 2, 9, 6), (2, 3, 10, 6), (2, 4, 8, 6),
(2, 5, 9, 6), (2, 6, 10, 6), (2, 7, 8, 6), (2, 8, 9, 6),
-- English teachers
(3, 1, 10, 6), (3, 2, 11, 6), (3, 3, 5, 6), (3, 4, 10, 6),
(3, 5, 11, 6), (3, 6, 5, 6), (3, 7, 10, 6), (3, 8, 11, 6),
-- History teachers
(4, 1, 7, 6), (4, 2, 8, 6), (4, 3, 9, 6), (4, 4, 7, 6),
(4, 5, 8, 6), (4, 6, 9, 6), (4, 7, 7, 6), (4, 8, 8, 6),
-- Geography teachers
(5, 1, 9, 6), (5, 2, 10, 6), (5, 3, 11, 6), (5, 4, 9, 6),
(5, 5, 10, 6), (5, 6, 11, 6), (5, 7, 9, 6), (5, 8, 10, 6);

-- Assign students to courses (distributing 100 students across 8 courses)
INSERT INTO student_course (student_id, course_id, user_id) VALUES
-- Grade 10 A (students 1-12)
(1, 1, 6), (2, 1, 6), (3, 1, 6), (4, 1, 6), (5, 1, 6), (6, 1, 6),
(7, 1, 6), (8, 1, 6), (9, 1, 6), (10, 1, 6), (11, 1, 6), (12, 1, 6),
-- Grade 10 B (students 13-25)
(13, 2, 6), (14, 2, 6), (15, 2, 6), (16, 2, 6), (17, 2, 6), (18, 2, 6),
(19, 2, 6), (20, 2, 6), (21, 2, 6), (22, 2, 6), (23, 2, 6), (24, 2, 6), (25, 2, 6),
-- Grade 11 A (students 26-37)
(26, 3, 6), (27, 3, 6), (28, 3, 6), (29, 3, 6), (30, 3, 6), (31, 3, 6),
(32, 3, 6), (33, 3, 6), (34, 3, 6), (35, 3, 6), (36, 3, 6), (37, 3, 6),
-- Grade 11 B (students 38-50)
(38, 4, 6), (39, 4, 6), (40, 4, 6), (41, 4, 6), (42, 4, 6), (43, 4, 6),
(44, 4, 6), (45, 4, 6), (46, 4, 6), (47, 4, 6), (48, 4, 6), (49, 4, 6), (50, 4, 6),
-- Grade 12 A (students 51-62)
(51, 5, 6), (52, 5, 6), (53, 5, 6), (54, 5, 6), (55, 5, 6), (56, 5, 6),
(57, 5, 6), (58, 5, 6), (59, 5, 6), (60, 5, 6), (61, 5, 6), (62, 5, 6),
-- Grade 12 B (students 63-75)
(63, 6, 6), (64, 6, 6), (65, 6, 6), (66, 6, 6), (67, 6, 6), (68, 6, 6),
(69, 6, 6), (70, 6, 6), (71, 6, 6), (72, 6, 6), (73, 6, 6), (74, 6, 6), (75, 6, 6),
-- Grade 9 A (students 76-87)
(76, 7, 6), (77, 7, 6), (78, 7, 6), (79, 7, 6), (80, 7, 6), (81, 7, 6),
(82, 7, 6), (83, 7, 6), (84, 7, 6), (85, 7, 6), (86, 7, 6), (87, 7, 6),
-- Grade 9 B (students 88-100)
(88, 8, 6), (89, 8, 6), (90, 8, 6), (91, 8, 6), (92, 8, 6), (93, 8, 6),
(94, 8, 6), (95, 8, 6), (96, 8, 6), (97, 8, 6), (98, 8, 6), (99, 8, 6), (100, 8, 6);

-- Insert student_subject_course relationships (each student takes 5 core subjects)
INSERT INTO student_subject_course (student_id, subject_id, course_id, user_id)
SELECT 
    sc.student_id,
    s.subject_id,
    sc.course_id,
    6
FROM student_course sc
CROSS JOIN subject s
WHERE s.subject_id IN (1, 2, 3, 4, 5); -- Core subjects: Math, Science, English, History, Geography

-- Insert tests for each subject
INSERT INTO test (t_name, t_type, year, user_id, subject_id) VALUES
-- Mathematics tests
('Mathematics Term 1 Test', 'tm1', '2025', 6, 1),
('Mathematics Term 2 Test', 'tm2', '2025', 6, 1),
('Mathematics Term 3 Test', 'tm3', '2025', 6, 1),
-- Science tests
('Science Term 1 Test', 'tm1', '2025', 6, 2),
('Science Term 2 Test', 'tm2', '2025', 6, 2),
('Science Term 3 Test', 'tm3', '2025', 6, 2),
-- English tests
('English Term 1 Test', 'tm1', '2025', 6, 3),
('English Term 2 Test', 'tm2', '2025', 6, 3),
('English Term 3 Test', 'tm3', '2025', 6, 3),
-- History tests
('History Term 1 Test', 'tm1', '2025', 6, 4),
('History Term 2 Test', 'tm2', '2025', 6, 4),
('History Term 3 Test', 'tm3', '2025', 6, 4),
-- Geography tests
('Geography Term 1 Test', 'tm1', '2025', 6, 5),
('Geography Term 2 Test', 'tm2', '2025', 6, 5),
('Geography Term 3 Test', 'tm3', '2025', 6, 5);

-- Insert realistic test marks for all students (Term 1 tests only for now)
INSERT INTO student_test_course_subject (student_id, course_id, subject_id, test_id, mark, user_id)
SELECT 
    ssc.student_id,
    ssc.course_id,
    ssc.subject_id,
    t.test_id,
    CASE 
        -- Generate realistic marks based on normal distribution
        WHEN RAND() < 0.05 THEN ROUND(30 + RAND() * 20, 1) -- 5% low performers (30-50)
        WHEN RAND() < 0.25 THEN ROUND(50 + RAND() * 20, 1) -- 20% below average (50-70)
        WHEN RAND() < 0.75 THEN ROUND(70 + RAND() * 15, 1) -- 50% average (70-85)
        ELSE ROUND(85 + RAND() * 15, 1) -- 25% high performers (85-100)
    END,
    6
FROM student_subject_course ssc
JOIN test t ON ssc.subject_id = t.subject_id
WHERE t.t_type = 'tm1'; -- Only Term 1 tests for initial data

-- Add some sample marks for Term 2 tests (partial data)
INSERT INTO student_test_course_subject (student_id, course_id, subject_id, test_id, mark, user_id)
SELECT 
    ssc.student_id,
    ssc.course_id,
    ssc.subject_id,
    t.test_id,
    CASE 
        WHEN RAND() < 0.05 THEN ROUND(35 + RAND() * 20, 1)
        WHEN RAND() < 0.25 THEN ROUND(55 + RAND() * 20, 1)
        WHEN RAND() < 0.75 THEN ROUND(72 + RAND() * 15, 1)
        ELSE ROUND(87 + RAND() * 13, 1)
    END,
    6
FROM student_subject_course ssc
JOIN test t ON ssc.subject_id = t.subject_id
WHERE t.t_type = 'tm2' 
AND ssc.student_id <= 50; -- Only first 50 students have Term 2 marks

-- Verification queries (uncomment to check data)
/*
SELECT 'Users' as table_name, COUNT(*) as count FROM user WHERE deleted_at IS NULL
UNION ALL
SELECT 'Students', COUNT(*) FROM student WHERE deleted_at IS NULL
UNION ALL
SELECT 'Courses', COUNT(*) FROM course WHERE deleted_at IS NULL
UNION ALL
SELECT 'Subjects', COUNT(*) FROM subject WHERE deleted_at IS NULL
UNION ALL
SELECT 'Tests', COUNT(*) FROM test WHERE deleted_at IS NULL
UNION ALL
SELECT 'Student Enrollments', COUNT(*) FROM student_course
UNION ALL
SELECT 'Test Results', COUNT(*) FROM student_test_course_subject;
*/