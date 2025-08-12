-- Create Database
CREATE DATABASE IF NOT EXISTS school_db;
USE school_db;

-- 1. Schools
CREATE TABLE ss_t_schools (
    school_id INT AUTO_INCREMENT PRIMARY KEY,
    school_name VARCHAR(255) NOT NULL,
    school_type VARCHAR(100),
    contact_number VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Grades
CREATE TABLE ss_t_grade (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    school_id INT NOT NULL,
    grade_name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id)
);

-- 3. Sections
CREATE TABLE ss_t_section (
    section_id INT AUTO_INCREMENT PRIMARY KEY,
    grade_id INT NOT NULL,
    section_name VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (grade_id) REFERENCES ss_t_grade(grade_id)
);

-- 4. Subjects
CREATE TABLE ss_t_subject (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    school_id INT NOT NULL,
    subject_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id)
);

-- 5. Teachers
CREATE TABLE ss_t_teacher (
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

-- 6. Teacher-Section Map
CREATE TABLE ss_t_teacher_section_map (
    map_id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_id INT NOT NULL,
    grade_id INT NOT NULL,
    section_id INT NOT NULL,
    subject_id INT NOT NULL,
    FOREIGN KEY (teacher_id) REFERENCES ss_t_teacher(teacher_id),
    FOREIGN KEY (grade_id) REFERENCES ss_t_grade(grade_id),
    FOREIGN KEY (section_id) REFERENCES ss_t_section(section_id),
    FOREIGN KEY (subject_id) REFERENCES ss_t_subject(subject_id)
);

-- 7. Students
CREATE TABLE ss_t_student (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    school_id INT NOT NULL,
    student_name VARCHAR(255) NOT NULL,
    dob DATE,
    gender VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id)
);

-- 8. Student Academic Map
CREATE TABLE ss_t_student_academic_map (
    map_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    grade_id INT NOT NULL,
    section_id INT NOT NULL,
    academic_year VARCHAR(20),
    FOREIGN KEY (student_id) REFERENCES ss_t_student(student_id),
    FOREIGN KEY (grade_id) REFERENCES ss_t_grade(grade_id),
    FOREIGN KEY (section_id) REFERENCES ss_t_section(section_id)
);

-- 9. Timetable
CREATE TABLE ss_t_class_timetable (
    timetable_id INT AUTO_INCREMENT PRIMARY KEY,
    school_id INT NOT NULL,
    grade_id INT NOT NULL,
    section_id INT NOT NULL,
    subject_id INT,
    teacher_id INT,
    day_of_week VARCHAR(15),
    period_no INT,
    remarks VARCHAR(255),
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id),
    FOREIGN KEY (grade_id) REFERENCES ss_t_grade(grade_id),
    FOREIGN KEY (section_id) REFERENCES ss_t_section(section_id),
    FOREIGN KEY (subject_id) REFERENCES ss_t_subject(subject_id),
    FOREIGN KEY (teacher_id) REFERENCES ss_t_teacher(teacher_id)
);

-- 10. Class Diary
CREATE TABLE ss_t_class_diary (
    diary_id INT AUTO_INCREMENT PRIMARY KEY,
    grade_id INT NOT NULL,
    section_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,
    diary_date DATE,
    content TEXT,
    FOREIGN KEY (grade_id) REFERENCES ss_t_grade(grade_id),
    FOREIGN KEY (section_id) REFERENCES ss_t_section(section_id),
    FOREIGN KEY (subject_id) REFERENCES ss_t_subject(subject_id),
    FOREIGN KEY (teacher_id) REFERENCES ss_t_teacher(teacher_id)
);

-- 11. Homework Details
CREATE TABLE ss_t_homework_details (
    homework_id INT AUTO_INCREMENT PRIMARY KEY,
    school_id INT NOT NULL,
    grade_id INT NOT NULL,
    section_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,
    status ENUM('Pending', 'Submitted', 'Completed'),
    description TEXT,
    FOREIGN KEY (school_id) REFERENCES ss_t_schools(school_id),
    FOREIGN KEY (grade_id) REFERENCES ss_t_grade(grade_id),
    FOREIGN KEY (section_id) REFERENCES ss_t_section(section_id),
    FOREIGN K
