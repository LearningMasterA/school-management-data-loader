import pandas as pd
import mysql.connector
import logging
from mysql.connector import Error

# Configure logging
logging.basicConfig(
    filename="logs/etl_run.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

# MySQL connection function
def create_connection():
    try:
        connection = mysql.connector.connect(
            host="localhost",
            user="root",       # change to your MySQL username
            password="Ankita@261203",   # change to your MySQL password
            database="school_db"
        )
        if connection.is_connected():
            logging.info("Connected to MySQL database")
            return connection
    except Error as e:
        logging.error(f"Error connecting to MySQL: {e}")
        return None

# Loader function example
def load_schools():
    try:
        conn = create_connection()
        cursor = conn.cursor()
        df = pd.read_excel("sample_excels/schools.xlsx")
        print(df.columns.tolist())

        for _, row in df.iterrows():
            cursor.execute("""
                INSERT INTO ss_t_schools (school_name, school_type, contact_number, address)
                VALUES (%s, %s, %s, %s)
            """, (row['school_name'], row['school_type'], row['contact_number'], row['address']))
        conn.commit()
        logging.info(f"Inserted {len(df)} rows into ss_t_schools")
        cursor.close()
        conn.close()
    except Exception as e:
        logging.error(f"Error loading schools: {e}")

if __name__ == "__main__":
    logging.info("Starting ETL process...")
    load_schools()
    logging.info("ETL process completed.")
