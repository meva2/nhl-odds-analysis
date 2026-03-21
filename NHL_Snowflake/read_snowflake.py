import snowflake.connector
import os
from dotenv import load_dotenv


class ReadSnowflake:
    def __init__(self):
        load_dotenv()
        self.USERNAME = os.environ['DBT_SNOWFLAKE_USER']
        self.PASSWORD = os.environ['DBT_SNOWFLAKE_PASSWORD']
        self.ACCOUNT = os.environ['DBT_SNOWFLAKE_ACCOUNT']
        self.WAREHOUSE = os.environ['DBT_SNOWFLAKE_WAREHOUSE']
        self.ROLE = os.environ['DBT_SNOWFLAKE_ROLE']
        self.DATABASE = os.environ['DBT_SNOWFLAKE_DB']
        self.SCHEMA = os.environ['DBT_SNOWFLAKE_SCHEMA']
        self.con = snowflake.connector.connect(
            user=self.USERNAME,
            password=self.PASSWORD,
            account=self.ACCOUNT,
            warehouse=self.WAREHOUSE,
            role=self.ROLE,
            database=self.DATABASE,
            schema=self.SCHEMA
        )
        self.cur = self.con.cursor()
