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

def execute_read_only(
        query: str, 
        max_rows: int = 100
)->dict:
    if max_rows < 1:
        raise ValueError("No shuch number of rows")

    with connect() as connection:
        connection.read_only = True
        with connection.cursor(row_factory=dict_row) as cursor:
            cursor.execute("SET LOCAL statement_timeout = '5s'")
            cursor.execute(query, prepare=True)

            if cursor.description is None:
                raise ValueError("Expected a query returning rows")

            rows = cursor.fetchmany(max_rows + 1)

            return {
                "columns": [column.name for column in cursor.description],
                "rows": rows[:max_rows],
                "truncated": len(rows) > max_rows,
                "row_limit": max_rows,
            }

        
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