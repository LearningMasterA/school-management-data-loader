import pandas as pd
import mysql.connector
import logging
from datetime import datetime
import os

# -------------------- CONFIG --------------------
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "Ankita@261203",  
    "database": "school_db"      
}

EXCEL_DIR = "sample_excels"

# -------------------- LOGGING --------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("etl.log"),
        logging.StreamHandler()
    ]
)

# -------------------- DB HELPER --------------------
def get_conn():
    return mysql.connector.connect(**DB_CONFIG)

def fetch_valid_ids(conn, table, col):
    cursor = conn.cursor()
    cursor.execute(f"SELECT {col} FROM {table}")
    return {row[0] for row in cursor.fetchall()}

# -------------------- VALIDATION --------------------
def validate_required(df, cols):
    for col in cols:
        if df[col].isnull().any():
            raise ValueError(f"Missing required values in column: {col}")

def validate_enum(df, col, allowed):
    invalid = df[~df[col].isin(allowed)]
    if not invalid.empty:
        raise ValueError(f"Invalid values in column '{col}': {invalid[col].unique()}")

def validate_fk(df, fk_specs, conn):
    for col, ref_table, ref_col in fk_specs:
        valid_ids = fetch_valid_ids(conn, ref_table, ref_col)
        invalid_ids = set(df[col].dropna()) - valid_ids
        if invalid_ids:
            raise ValueError(f"Invalid FK values in '{col}': {invalid_ids}")

# -------------------- LOADER --------------------
def load_table(table, excel, columns, required=None, enum_specs=None, fk_specs=None, preprocess=None):
    logging.info(f"Loading table: {table} from {excel}")
    path = os.path.join(EXCEL_DIR, excel)

    try:
        df = pd.read_excel(path, engine="openpyxl")
    except Exception as e:
        logging.error(f"Error reading {excel}: {e}")
        return

    # Normalize column names
    df.columns = df.columns.str.strip().str.lower()
    columns_lower = [c.lower() for c in columns]
    df = df[columns_lower]

    # Optional preprocessing
    if preprocess:
        df = preprocess(df)

    conn = get_conn()
    try:
        if required:
            validate_required(df, [c.lower() for c in required])
        if enum_specs:
            for col, allowed in enum_specs.items():
                validate_enum(df, col.lower(), allowed)
        if fk_specs:
            validate_fk(df, fk_specs, conn)

        placeholders = ", ".join(["%s"] * len(columns))
        col_names = ", ".join(columns)
        update_cols = ", ".join([f"{col}=VALUES({col})" for col in columns if col.lower() != 'id'])
        sql = f"""
        INSERT INTO {table} ({col_names})
        VALUES ({placeholders})
        ON DUPLICATE KEY UPDATE {update_cols}, updated_at=NOW()
        """

        cursor = conn.cursor()
        cursor.executemany(sql, df.values.tolist())
        conn.commit()

        logging.info(f"Inserted {cursor.rowcount} rows into {table}")

    except Exception as e:
        conn.rollback()
        logging.error(f"Error loading {table}: {e}")
    finally:
        conn.close()

# -------------------- TABLE METADATA --------------------
TABLES = [
    # 1. Schools
    {
        "table": "ss_t_schools",
        "excel": "schools.xlsx",
        "columns": ["school_name", "school_type", "contact_number", "address"],
        "required": ["school_name"]
    },
    # 2. Grades
    {
        "table": "ss_t_grades",
        "excel": "grades.xlsx",
        "columns": ["school_id", "grade_name"],
        "required": ["school_id", "grade_name"],
        "fk_specs": [("school_id", "ss_t_schools", "school_id")]
    },
    # 3. Sections
    {
        "table": "ss_t_sections",
        "excel": "sections.xlsx",
        "columns": ["grade_id", "section_name"],
        "required": ["grade_id", "section_name"],
        "fk_specs": [("grade_id", "ss_t_grades", "grade_id")]
    },
    # 4. Subjects
    {
        "table": "ss_t_subjects",
        "excel": "subjects.xlsx",
        "columns": ["school_id", "subject_name"],
        "required": ["school_id", "subject_name"],
        "fk_specs": [("school_id", "ss_t_schools", "school_id")]
    },
    # 5. Teachers
    {
        "table": "ss_t_teachers",
        "excel": "teachers.xlsx",
        "columns": ["school_id", "teacher_name", "qualification", "contact_number", "gender"],
        "required": ["school_id", "teacher_name"],
        "fk_specs": [("school_id", "ss_t_schools", "school_id")]
    },
    # 6. Students
    {
        "table": "ss_t_students",
        "excel": "students.xlsx",
        "columns": ["school_id", "student_name", "dob", "gender"],
        "required": ["school_id", "student_name", "dob", "gender"],
        "fk_specs": [("school_id", "ss_t_schools", "school_id")]
    },
    # 7. Attendance Type
    {
        "table": "ss_t_attendance_type",
        "excel": "attendance_type.xlsx",
        "columns": ["type_name"],
        "required": ["type_name"]
    },
    # 8. Lesson Plan
    {
        "table": "ss_t_lesson_plan",
        "excel": "lesson_plan.xlsx",
        "columns": ["teacher_id", "subject_id", "plan_date", "description"],
        "required": ["teacher_id", "subject_id", "plan_date"],
        "fk_specs": [
            ("teacher_id", "ss_t_teachers", "teacher_id"),
            ("subject_id", "ss_t_subjects", "subject_id")
        ]
    },
    # 9. Lesson Plan Topic Map
    {
        "table": "ss_t_lesson_plan_topic_map",
        "excel": "lesson_plan_topic_map.xlsx",
        "columns": ["lesson_plan_id", "topic_name"],
        "required": ["lesson_plan_id", "topic_name"],
        "fk_specs": [("lesson_plan_id", "ss_t_lesson_plan", "lesson_plan_id")]
    },
    # 10. Class Timetable
    {
        "table": "ss_t_class_timetable",
        "excel": "class_timetable.xlsx",
        "columns": ["school_id", "grade_id", "section_id", "subject_id", "teacher_id", "day_of_week", "period_no", "remarks"],
        "required": ["school_id", "grade_id", "section_id", "day_of_week", "period_no"],
        "fk_specs": [
            ("school_id", "ss_t_schools", "school_id"),
            ("grade_id", "ss_t_grades", "grade_id"),
            ("section_id", "ss_t_sections", "section_id"),
            ("subject_id", "ss_t_subjects", "subject_id"),
            ("teacher_id", "ss_t_teachers", "teacher_id")
        ]
    },
    # 11. Class Diary
    {
        "table": "ss_t_class_diary",
        "excel": "class_diary.xlsx",
        "columns": ["grade_id", "section_id", "subject_id", "teacher_id", "diary_date", "content"],
        "required": ["grade_id", "section_id", "subject_id", "teacher_id", "diary_date"],
        "fk_specs": [
            ("grade_id", "ss_t_grades", "grade_id"),
            ("section_id", "ss_t_sections", "section_id"),
            ("subject_id", "ss_t_subjects", "subject_id"),
            ("teacher_id", "ss_t_teachers", "teacher_id")
        ]
    },
    # 12. Homework
    {
        "table": "ss_t_homework",
        "excel": "homework.xlsx",
        "columns": ["school_id", "grade_id", "section_id", "subject_id", "teacher_id", "status", "description"],
        "required": ["school_id", "grade_id", "section_id", "subject_id", "teacher_id", "status"],
        "fk_specs": [
            ("school_id", "ss_t_schools", "school_id"),
            ("grade_id", "ss_t_grades", "grade_id"),
            ("section_id", "ss_t_sections", "section_id"),
            ("subject_id", "ss_t_subjects", "subject_id"),
            ("teacher_id", "ss_t_teachers", "teacher_id")
        ]
    },
    # 13. Attendance Register
    {
        "table": "ss_t_attendance_register",
        "excel": "attendance_register.xlsx",
        "columns": ["student_id", "attendance_date", "status"],
        "required": ["student_id", "attendance_date", "status"],
        "fk_specs": [("student_id", "ss_t_students", "student_id")]
    },
    # 14. Fee Payment Installment
    {
        "table": "ss_t_fee_payment_installment",
        "excel": "fee_payment_installment.xlsx",
        "columns": ["student_id", "amount_paid", "payment_date"],
        "required": ["student_id", "amount_paid", "payment_date"],
        "fk_specs": [("student_id", "ss_t_students", "student_id")]
    },
    # 15. School Income
    {
        "table": "ss_t_school_income",
        "excel": "school_income.xlsx",
        "columns": ["school_id", "source", "amount", "date_received"],
        "required": ["school_id", "source", "amount", "date_received"],
        "fk_specs": [("school_id", "ss_t_schools", "school_id")]
    },
    # 16. Student Academic Map
    {
        "table": "ss_t_student_academic_map",
        "excel": "student_academic_map.xlsx",
        "columns": ["student_id", "grade_id", "section_id", "academic_year"],
        "required": ["student_id", "grade_id", "section_id", "academic_year"],
        "fk_specs": [
            ("student_id", "ss_t_students", "student_id"),
            ("grade_id", "ss_t_grades", "grade_id"),
            ("section_id", "ss_t_sections", "section_id")
        ]
    },
    # 17. Student Fee Structure
    {
        "table": "ss_t_student_fee_structure",
        "excel": "student_fee_structure.xlsx",
        "columns": ["grade_id", "amount"],
        "required": ["grade_id", "amount"],
        "fk_specs": [("grade_id", "ss_t_grades", "grade_id")]
    },
    # 18. Teacher Salary Structure
    {
        "table": "ss_t_teacher_salary_structure",
        "excel": "teacher_salary_structure.xlsx",
        "columns": ["teacher_id", "basic_pay", "allowances", "deductions"],
        "required": ["teacher_id", "basic_pay"],
        "fk_specs": [("teacher_id", "ss_t_teachers", "teacher_id")]
    },
    # 19. Teacher Salary Payslip
    {
        "table": "ss_t_teacher_salary_payslip",
        "excel": "teacher_salary_payslip.xlsx",
        "columns": ["teacher_id", "month", "year", "amount"],
        "required": ["teacher_id", "month", "year", "amount"],
        "fk_specs": [("teacher_id", "ss_t_teachers", "teacher_id")]
    },
    # 20. Teacher Section Map
    {
        "table": "ss_t_teacher_section_map",
        "excel": "teacher_section_map.xlsx",
        "columns": ["teacher_id", "grade_id", "section_id", "subject_id"],
        "required": ["teacher_id", "grade_id", "section_id", "subject_id"],
        "fk_specs": [
            ("teacher_id", "ss_t_teachers", "teacher_id"),
            ("grade_id", "ss_t_grades", "grade_id"),
            ("section_id", "ss_t_sections", "section_id"),
            ("subject_id", "ss_t_subjects", "subject_id")
        ]
    }
]



# -------------------- MAIN --------------------
if __name__ == "__main__":
    logging.info("Starting ETL process...")
    for meta in TABLES:
        load_table(
            table=meta["table"],
            excel=meta["excel"],
            columns=meta["columns"],
            required=meta.get("required"),
            enum_specs=meta.get("enum_specs"),
            fk_specs=meta.get("fk_specs"),
            preprocess=meta.get("preprocess")
        )
    logging.info("ETL process completed.")
