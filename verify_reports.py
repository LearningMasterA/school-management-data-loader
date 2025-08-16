import mysql.connector
import pandas as pd

# -------------------- DB CONFIG --------------------
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "Ankita@261203",
    "database": "school_db"
}

# -------------------- CONNECT TO DB --------------------
conn = mysql.connector.connect(**DB_CONFIG)
cursor = conn.cursor(dictionary=True)

# -------------------- VERIFICATION QUERIES --------------------
queries = {
    "1. Students with Attendance > 80%": """
        SELECT s.student_id, s.student_name, 
               ROUND(SUM(CASE WHEN ar.status='Present' THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS attendance_percentage
        FROM ss_t_students s
        JOIN ss_t_attendance_register ar ON s.student_id = ar.student_id
        GROUP BY s.student_id, s.student_name
        HAVING attendance_percentage > 80;
    """,

    "2. Homework per teacher = 3 entries": """
        SELECT t.teacher_id, t.teacher_name, COUNT(h.homework_id) AS homework_count
        FROM ss_t_teachers t
        JOIN ss_t_homework h ON t.teacher_id = h.teacher_id
        GROUP BY t.teacher_id, t.teacher_name
        HAVING homework_count = 3;
    """,

    "3. Class diary: 2 entries per teacher": """
        SELECT t.teacher_id, t.teacher_name, COUNT(cd.diary_id) AS diary_count
        FROM ss_t_teachers t
        JOIN ss_t_class_diary cd ON t.teacher_id = cd.teacher_id
        GROUP BY t.teacher_id, t.teacher_name
        HAVING diary_count = 2;
    """,

    "4. Fees collected vs Income module": """
        SELECT s.student_id, s.student_name, 
               SUM(fpi.amount_paid) AS total_fees_paid,
               SUM(si.amount) AS total_income_recorded,
               CASE 
                 WHEN SUM(fpi.amount_paid) = SUM(si.amount) THEN 'OK'
                 ELSE 'Mismatch'
               END AS verification_status
        FROM ss_t_students s
        JOIN ss_t_fee_payment_installment fpi ON s.student_id = fpi.student_id
        LEFT JOIN ss_t_school_income si ON s.school_id = si.school_id
        GROUP BY s.student_id, s.student_name;
    """,

    "5. Salary payslip for June & July": """
        SELECT t.teacher_id, t.teacher_name, tsp.month, tsp.year, tsp.amount
        FROM ss_t_teachers t
        JOIN ss_t_teacher_salary_payslip tsp ON t.teacher_id = tsp.teacher_id
        WHERE tsp.month IN ('June','July')
        ORDER BY t.teacher_id, FIELD(tsp.month,'June','July');
    """,

    "6. Timetable breaks, leaves, assignments": """
        SELECT ct.school_id, ct.grade_id, ct.section_id, ct.day_of_week, ct.period_no, ct.remarks,
               s.subject_name, t.teacher_name
        FROM ss_t_class_timetable ct
        LEFT JOIN ss_t_subjects s ON ct.subject_id = s.subject_id
        LEFT JOIN ss_t_teachers t ON ct.teacher_id = t.teacher_id
        WHERE ct.remarks IS NOT NULL
        ORDER BY ct.school_id, ct.grade_id, ct.section_id, ct.day_of_week, ct.period_no;
    """
}

#For Displaying the results
for title, query in queries.items():
    print(f"\n===== {title} =====")
    df = pd.read_sql(query, conn)
    if df.empty:
        print("No records found.")
    else:
        print(df.to_string(index=False))

# -------------------- CLOSE CONNECTION --------------------
cursor.close()
conn.close()
