# Student Onboarding ETL Project

## Folder Structure
- `create_tables.sql` → All table creation scripts with audit columns
- `data_loader.py` → Python script to load Excel data to DB
- `verify_reports.py` → Python script to verify reports like attendance, homework, fees, salary, class diary
- `run_sql.py` → Python script to execute SQL queries for verification
- `sample_excels/` → Sample Excel files for each table
- `README.md` → This documentation

## How to Run the Loader
1. Create MySQL database `school_db`.
2. Run `create_tables.sql` to create tables.
3. Place your Excel files in `sample_excels/` folder.
4. Update DB credentials in `data_loader.py`.
5. Run: `python data_loader.py` to load data.
6. Run: `python verify_reports.py` or `python run_sql.py` to validate reports.
7. Check tables for loaded data and verification results.

## Changes Made
- Handled NaN values in Excel.
- Added audit columns `created_at` and `updated_at`.
- Ensured foreign key constraints for referential integrity.
- Modularized loader function for reusability.
- Created `verify_reports.py` to automate verification of key reports.
- Created `run_sql.py` to run verification queries directly from Python.

## How Criteria Are Met
1. **Data completeness and correctness (25%)**  
   - Row counts and null checks verified.  
   - Attendance, fees, salary, homework, class diary validated using `verify_reports.py`.

2. **Excel-driven ETL process (25%)**  
   - Loader reads all tables from Excel files.  
   - Transformation: fills NaN, formats dates, maps IDs.

3. **Referential integrity maintained (15%)**  
   - Foreign keys used for students, teachers, class_id references.

4. **Logical data setup & attendance/fees/salary coverage (15%)**  
   - Attendance > 80%, homework (3 entries per teacher), class diary (2 entries per teacher), fees reflected in income, salary payslips for June/July.  
   - Verified using `verify_reports.py` and `run_sql.py`.

5. **Code quality, modularity & documentation (10%)**  
   - Loader is modular, commented, with exception handling.  
   - Audit columns track inserts and updates.

6. **Clarity in timetable and leave reflections (10%)**  
   - Timetable clearly shows breaks, leaves, and assignments.



Here is the detailed demonstration of the project 
https://drive.google.com/file/d/1mnt8NX5W6Wop4K72MU_p2Ma-xs7jn311/view?usp=sharing
