import psycopg
from psycopg.rows import dict_row

def connect():
    return psycopg.connect(
        dbname="tutorial_db",
        user="juan"
    )

def execute_query(connection, sql, params=None):
    with connection.cursor(row_factory=dict_row) as cursor:
        cursor.execute(sql, params)
        return cursor.fetchall()

if __name__ == "__main__":
    with connect() as connection:
        rows = execute_query(
            connection,
            """
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_schema = %s
            ORDER BY table_name
            """,
            ("from_zero_to_hero",),
        )
        for row in rows:
            print(row)