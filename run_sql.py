import mysql.connector

DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "Ankita@261203",
    "database": "school_db"
}

conn = mysql.connector.connect(**DB_CONFIG)
cursor = conn.cursor()

with open("create_tables.sql", "r") as f:
    sql_commands = f.read()

# Split commands by semicolon
for command in sql_commands.split(";"):
    command = command.strip()
    if command:
        cursor.execute(command)

conn.commit()
cursor.close()
conn.close()
print("Tables created successfully!")
