import pandas as pd
import mysql.connector
import logging
from datetime import datetime
import os

# -------------------- CONFIG --------------------
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "Ankita@261203",  # change this
    "database": "school_db"       # change this
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
        sql = f"INSERT INTO {table} ({col_names}) VALUES ({placeholders})"

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
# Fill this list with your 20 tables
TABLES = [
    {
        "table": "ss_t_schools",
        "excel": "schools.xlsx",
        "columns": ["school_name", "school_type", "contact_number", "address"],
        "required": ["school_name"]
    },
    {
        "table": "ss_t_grade",
        "excel": "grades.xlsx",
        "columns": ["school_id", "grade_name"],
        "required": ["school_id", "grade_name"],
        "fk_specs": [("school_id", "ss_t_schools", "school_id")]
    },
    # Add remaining tables here...
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
