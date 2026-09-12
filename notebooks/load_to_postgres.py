"""
NYC 311 HPD Complaint Resolution Analysis — Phase 2
Loads the cleaned dataset (produced by nyc311_data_cleaning.ipynb) into a
local PostgreSQL table, so the Phase 3 SQL queries (sql/nyc311_analysis.sql)
have something to run against.

Credentials are read from environment variables rather than hardcoded —
set these in your shell before running, e.g.:

    export PGUSER=your_mac_username
    export PGPASSWORD=your_postgres_password
    export PGHOST=localhost
    export PGPORT=5432
    export PGDATABASE=nyc311_tickets

Note: on Postgres.app (Mac), the default role matches your OS username,
not "postgres".
"""

import os
import pandas as pd
from sqlalchemy import create_engine

username = os.environ["PGUSER"]
password = os.environ["PGPASSWORD"]
host = os.environ.get("PGHOST", "localhost")
port = os.environ.get("PGPORT", "5432")
database = os.environ.get("PGDATABASE", "nyc311_tickets")

engine = create_engine(f"postgresql+psycopg2://{username}:{password}@{host}:{port}/{database}")

df = pd.read_csv("../data/nyc311_hpd_complaints_cleaned.csv")

table_name = "hpd_complaints"
df.to_sql(table_name, engine, if_exists="replace", index=False)

print(f"Loaded {len(df)} rows into {table_name}.")
