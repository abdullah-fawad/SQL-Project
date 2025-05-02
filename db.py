# db.py

from sqlalchemy import create_engine, text

# Create engine once
engine = create_engine("mysql+pymysql://root:12345@127.0.0.1/library_system")

# Reusable connection function
def get_db_connection():
    conn = engine.connect()
    return conn.execution_options(isolation_level="AUTOCOMMIT")


def call_db_procedure(proc_name, params):
    with get_db_connection() as conn:
        query = text(f"CALL {proc_name}({', '.join([':' + key for key in params.keys()])})")
        conn.execute(query, params)
        conn.commit()
    
