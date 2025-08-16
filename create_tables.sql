-- ============================================
-- Drop tables (child tables first to avoid FK errors)
-- ============================================

DROP TABLE IF EXISTS ss_t_teacher_section_map;
DROP TABLE IF EXISTS ss_t_teacher_salary_payslip;
DROP TABLE IF EXISTS ss_t_teacher_salary_structure;
DROP TABLE IF EXISTS ss_t_student_fee_structure;
DROP TABLE IF EXISTS ss_t_student_academic_map;
DROP TABLE IF EXISTS ss_t_school_income;
DROP TABLE IF EXISTS ss_t_lesson_plan_topic_map;
DROP TABLE IF EXISTS ss_t_lesson_plan;
DROP TABLE IF EXISTS ss_t_homework;
DROP TABLE IF EXISTS ss_t_attendance_register;
DROP TABLE IF EXISTS ss_t_class_diary;
DROP TABLE IF EXISTS ss_t_class_timetable;
DROP TABLE IF EXISTS ss_t_fee_payment_installment;

DROP TABLE IF EXISTS ss_t_sections;
DROP TABLE IF EXISTS ss_t_subjects;
DROP TABLE IF EXISTS ss_t_students;
DROP TABLE IF EXISTS ss_t_teachers;
DROP TABLE IF EXISTS ss_t_grades;

DROP TABLE IF EXISTS ss_t_attendance_type;
DROP TABLE IF EXISTS ss_t_schools;

-- Creating the tables

-- 1. Schools
CREATE TABLE ss_t_schools (
    school_id INT AUTO_INCREMENT PRIMARY KEY,
    school_name VARCHAR(255) NOT NULL,
    school_type VARCHAR(100),
    contact_number VARCHAR(20),
    address VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Attendance Type
CREATE TABLE ss_t_attendance_type (
    attendance_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 3. Grades
CREATE TABLE ss_t_grades (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    school_id INT NOT NULL,
    grade_name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id)
);

-- 4. Sections
CREATE TABLE ss_t_sections (
    section_id INT AUTO_INCREMENT PRIMARY KEY,
    grade_id INT NOT NULL,
    section_name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (grade_id) REFERENCES ss_t_grades(grade_id)
);

-- 5. Subjects
CREATE TABLE ss_t_subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    school_id INT NOT NULL,
    subject_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id)
);

-- 6. Teachers
CREATE TABLE ss_t_teachers (
    teacher_id INT AUTO_INCREMENT PRIMARY KEY,
    school_id INT NOT NULL,
    teacher_name VARCHAR(255) NOT NULL,
    qualification VARCHAR(255),
    contact_number VARCHAR(20),
    gender VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id)
);

-- 7. Students
CREATE TABLE ss_t_students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    school_id INT NOT NULL,
    student_name VARCHAR(255) NOT NULL,
    dob DATE NOT NULL,
    gender VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id)
);

-- 8. Lesson Plan
CREATE TABLE ss_t_lesson_plan (
    lesson_plan_id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_id INT NOT NULL,
    subject_id INT NOT NULL,
    plan_date DATE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES ss_t_teachers(teacher_id),
    FOREIGN KEY (subject_id) REFERENCES ss_t_subjects(subject_id)
);

-- 9. Lesson Plan Topic Map
CREATE TABLE ss_t_lesson_plan_topic_map (
    topic_map_id INT AUTO_INCREMENT PRIMARY KEY,
    lesson_plan_id INT NOT NULL,
    topic_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (lesson_plan_id) REFERENCES ss_t_lesson_plan(lesson_plan_id)
);

-- 10. Class Timetable
CREATE TABLE ss_t_class_timetable (
    timetable_id INT AUTO_INCREMENT PRIMARY KEY,
    school_id INT NOT NULL,
    grade_id INT NOT NULL,
    section_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,
    day_of_week VARCHAR(20) NOT NULL,
    period_no INT NOT NULL,
    remarks VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id),
    FOREIGN KEY (grade_id) REFERENCES ss_t_grades(grade_id),
    FOREIGN KEY (section_id) REFERENCES ss_t_sections(section_id),
    FOREIGN KEY (subject_id) REFERENCES ss_t_subjects(subject_id),
    FOREIGN KEY (teacher_id) REFERENCES ss_t_teachers(teacher_id)
);

-- 11. Class Diary
CREATE TABLE ss_t_class_diary (
    diary_id INT AUTO_INCREMENT PRIMARY KEY,
    grade_id INT NOT NULL,
    section_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,
    diary_date DATE NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (grade_id) REFERENCES ss_t_grades(grade_id),
    FOREIGN KEY (section_id) REFERENCES ss_t_sections(section_id),
    FOREIGN KEY (subject_id) REFERENCES ss_t_subjects(subject_id),
    FOREIGN KEY (teacher_id) REFERENCES ss_t_teachers(teacher_id)
);

-- 12. Homework
CREATE TABLE ss_t_homework (
    homework_id INT AUTO_INCREMENT PRIMARY KEY,
    school_id INT NOT NULL,
    grade_id INT NOT NULL,
    section_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id),
    FOREIGN KEY (grade_id) REFERENCES ss_t_grades(grade_id),
    FOREIGN KEY (section_id) REFERENCES ss_t_sections(section_id),
    FOREIGN KEY (subject_id) REFERENCES ss_t_subjects(subject_id),
    FOREIGN KEY (teacher_id) REFERENCES ss_t_teachers(teacher_id)
);

-- 13. Attendance Register
CREATE TABLE ss_t_attendance_register (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES ss_t_students(student_id)
);

-- 14. Fee Payment Installment
CREATE TABLE ss_t_fee_payment_installment (
    installment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES ss_t_students(student_id)
);

-- 15. School Income
CREATE TABLE ss_t_school_income (
    income_id INT AUTO_INCREMENT PRIMARY KEY,
    school_id INT NOT NULL,
    source VARCHAR(255) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    date_received DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id)
);

-- 16. Student Academic Map
CREATE TABLE ss_t_student_academic_map (
    map_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    grade_id INT NOT NULL,
    section_id INT NOT NULL,
    academic_year VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES ss_t_students(student_id),
    FOREIGN KEY (grade_id) REFERENCES ss_t_grades(grade_id),
    FOREIGN KEY (section_id) REFERENCES ss_t_sections(section_id)
);

-- 17. Student Fee Structure
CREATE TABLE ss_t_student_fee_structure (
    fee_structure_id INT AUTO_INCREMENT PRIMARY KEY,
    grade_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (grade_id) REFERENCES ss_t_grades(grade_id)
);

-- 18. Teacher Salary Structure
CREATE TABLE ss_t_teacher_salary_structure (
    salary_structure_id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_id INT NOT NULL,
    basic_pay DECIMAL(10,2) NOT NULL,
    allowances DECIMAL(10,2),
    deductions DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES ss_t_teachers(teacher_id)
);

-- 19. Teacher Salary Payslip
CREATE TABLE ss_t_teacher_salary_payslip (
    payslip_id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_id INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES ss_t_teachers(teacher_id)
);

-- 20. Teacher Section Map
CREATE TABLE ss_t_teacher_section_map (
    map_id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_id INT NOT NULL,
    grade_id INT NOT NULL,
    section_id INT NOT NULL,
    subject_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES ss_t_teachers(teacher_id),
    FOREIGN KEY (grade_id) REFERENCES ss_t_grades(grade_id),
    FOREIGN KEY (section_id) REFERENCES ss_t_sections(section_id),
    FOREIGN KEY (subject_id) REFERENCES ss_t_subjects(subject_id)
);
