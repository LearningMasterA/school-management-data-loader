-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS ss_t_teacher_section_map;
DROP TABLE IF EXISTS ss_t_teacher_salary_structure;
DROP TABLE IF EXISTS ss_t_teacher_salary_payslip;
DROP TABLE IF EXISTS ss_t_student_fee_structure;
DROP TABLE IF EXISTS ss_t_student_academic_map;
DROP TABLE IF EXISTS ss_t_school_income;
DROP TABLE IF EXISTS ss_t_lesson_plan_topic_map;
DROP TABLE IF EXISTS ss_t_lesson_plan;
DROP TABLE IF EXISTS ss_t_homework;
DROP TABLE IF EXISTS ss_t_grades;
DROP TABLE IF EXISTS ss_t_sections;
DROP TABLE IF EXISTS ss_t_subjects;
DROP TABLE IF EXISTS ss_t_students;
DROP TABLE IF EXISTS ss_t_teachers;
DROP TABLE IF EXISTS ss_t_fee_payment_installment;
DROP TABLE IF EXISTS ss_t_class_timetable;
DROP TABLE IF EXISTS ss_t_class_diary;
DROP TABLE IF EXISTS ss_t_attendance_register;
DROP TABLE IF EXISTS ss_t_attendance_type;
DROP TABLE IF EXISTS ss_t_schools;

-- 1. Schools
CREATE TABLE ss_t_schools (
    school_id INT PRIMARY KEY AUTO_INCREMENT,
    school_name VARCHAR(100) NOT NULL,
    school_type VARCHAR(50),
    contact_number VARCHAR(15),
    address VARCHAR(255)
);

-- 2. Attendance Type
CREATE TABLE ss_t_attendance_type (
    attendance_type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(20) NOT NULL
);

-- 3. Students
CREATE TABLE ss_t_students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    school_id INT NOT NULL,
    student_name VARCHAR(100) NOT NULL,
    dob DATE,
    gender ENUM('Male', 'Female'),
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id)
);

-- 4. Grades
CREATE TABLE ss_t_grades (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    school_id INT NOT NULL,
    grade_name VARCHAR(50) NOT NULL,
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id)
);

-- 5. Sections
CREATE TABLE ss_t_sections (
    section_id INT PRIMARY KEY AUTO_INCREMENT,
    grade_id INT NOT NULL,
    section_name VARCHAR(10) NOT NULL,
    FOREIGN KEY (grade_id) REFERENCES ss_t_grades(grade_id)
);

-- 6. Subjects
CREATE TABLE ss_t_subjects (
    subject_id INT PRIMARY KEY AUTO_INCREMENT,
    school_id INT NOT NULL,
    subject_name VARCHAR(50) NOT NULL,
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id)
);

-- 7. Teachers
CREATE TABLE ss_t_teachers (
    teacher_id INT PRIMARY KEY AUTO_INCREMENT,
    school_id INT NOT NULL,
    teacher_name VARCHAR(100) NOT NULL,
    qualification VARCHAR(100),
    contact_number VARCHAR(15),
    gender ENUM('Male', 'Female'),
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id)
);

-- 8. Attendance Register
CREATE TABLE ss_t_attendance_register (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    status VARCHAR(20),
    FOREIGN KEY (student_id) REFERENCES ss_t_students(student_id)
);

-- 9. Class Diary
CREATE TABLE ss_t_class_diary (
    diary_id INT PRIMARY KEY AUTO_INCREMENT,
    grade_id INT NOT NULL,
    section_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,
    diary_date DATE NOT NULL,
    content TEXT,
    FOREIGN KEY (grade_id) REFERENCES ss_t_grades(grade_id),
    FOREIGN KEY (section_id) REFERENCES ss_t_sections(section_id),
    FOREIGN KEY (subject_id) REFERENCES ss_t_subjects(subject_id),
    FOREIGN KEY (teacher_id) REFERENCES ss_t_teachers(teacher_id)
);

-- 10. Class Timetable
CREATE TABLE ss_t_class_timetable (
    timetable_id INT PRIMARY KEY AUTO_INCREMENT,
    school_id INT NOT NULL,
    grade_id INT NOT NULL,
    section_id INT NOT NULL,
    subject_id INT,
    teacher_id INT,
    day_of_week VARCHAR(15),
    period_no INT,
    remarks VARCHAR(255),
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id),
    FOREIGN KEY (grade_id) REFERENCES ss_t_grades(grade_id),
    FOREIGN KEY (section_id) REFERENCES ss_t_sections(section_id),
    FOREIGN KEY (subject_id) REFERENCES ss_t_subjects(subject_id),
    FOREIGN KEY (teacher_id) REFERENCES ss_t_teachers(teacher_id)
);

-- 11. Fee Payment Installment
CREATE TABLE ss_t_fee_payment_installment (
    installment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    amount_paid DECIMAL(10,2),
    payment_date DATE,
    FOREIGN KEY (student_id) REFERENCES ss_t_students(student_id)
);

-- 12. Homework
CREATE TABLE ss_t_homework (
    homework_id INT PRIMARY KEY AUTO_INCREMENT,
    school_id INT NOT NULL,
    grade_id INT NOT NULL,
    section_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,
    status VARCHAR(50),
    description TEXT,
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id),
    FOREIGN KEY (grade_id) REFERENCES ss_t_grades(grade_id),
    FOREIGN KEY (section_id) REFERENCES ss_t_sections(section_id),
    FOREIGN KEY (subject_id) REFERENCES ss_t_subjects(subject_id),
    FOREIGN KEY (teacher_id) REFERENCES ss_t_teachers(teacher_id)
);

-- 13. Lesson Plan
CREATE TABLE ss_t_lesson_plan (
    lesson_plan_id INT PRIMARY KEY AUTO_INCREMENT,
    teacher_id INT NOT NULL,
    subject_id INT NOT NULL,
    plan_date DATE,
    description TEXT,
    FOREIGN KEY (teacher_id) REFERENCES ss_t_teachers(teacher_id),
    FOREIGN KEY (subject_id) REFERENCES ss_t_subjects(subject_id)
);

-- 14. Lesson Plan Topic Map
CREATE TABLE ss_t_lesson_plan_topic_map (
    map_id INT PRIMARY KEY AUTO_INCREMENT,
    lesson_plan_id INT NOT NULL,
    topic_name VARCHAR(255),
    FOREIGN KEY (lesson_plan_id) REFERENCES ss_t_lesson_plan(lesson_plan_id)
);

-- 15. School Income
CREATE TABLE ss_t_school_income (
    income_id INT PRIMARY KEY AUTO_INCREMENT,
    school_id INT NOT NULL,
    source VARCHAR(100),
    amount DECIMAL(10,2),
    date_received DATE,
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id)
);

-- 16. Student Academic Map
CREATE TABLE ss_t_student_academic_map (
    map_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    grade_id INT NOT NULL,
    section_id INT NOT NULL,
    academic_year VARCHAR(20),
    FOREIGN KEY (student_id) REFERENCES ss_t_students(student_id),
    FOREIGN KEY (grade_id) REFERENCES ss_t_grades(grade_id),
    FOREIGN KEY (section_id) REFERENCES ss_t_sections(section_id)
);

-- 17. Student Fee Structure
CREATE TABLE ss_t_student_fee_structure (
    fee_id INT PRIMARY KEY AUTO_INCREMENT,
    grade_id INT NOT NULL,
    amount DECIMAL(10,2),
    FOREIGN KEY (grade_id) REFERENCES ss_t_grades(grade_id)
);

-- 18. Teacher Salary Payslip
CREATE TABLE ss_t_teacher_salary_payslip (
    payslip_id INT PRIMARY KEY AUTO_INCREMENT,
    teacher_id INT NOT NULL,
    month VARCHAR(20),
    year INT,
    amount DECIMAL(10,2),
    FOREIGN KEY (teacher_id) REFERENCES ss_t_teachers(teacher_id)
);

-- 19. Teacher Salary Structure
CREATE TABLE ss_t_teacher_salary_structure (
    salary_id INT PRIMARY KEY AUTO_INCREMENT,
    teacher_id INT NOT NULL,
    basic_pay DECIMAL(10,2),
    allowances DECIMAL(10,2),
    deductions DECIMAL(10,2),
    FOREIGN KEY (teacher_id) REFERENCES ss_t_teachers(teacher_id)
);

-- 20. Teacher Section Map
CREATE TABLE ss_t_teacher_section_map (
    map_id INT PRIMARY KEY AUTO_INCREMENT,
    teacher_id INT NOT NULL,
    grade_id INT NOT NULL,
    section_id INT NOT NULL,
    subject_id INT NOT NULL,
    FOREIGN KEY (teacher_id) REFERENCES ss_t_teachers(teacher_id),
    FOREIGN KEY (grade_id) REFERENCES ss_t_grades(grade_id),
    FOREIGN KEY (section_id) REFERENCES ss_t_sections(section_id),
    FOREIGN KEY (subject_id) REFERENCES ss_t_subjects(subject_id)
);
