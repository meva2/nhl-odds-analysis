import snowflake.connector
import os
from dotenv import load_dotenv
from nhl_api import NhlApi
from odds_api import OddsApi
from snowflake.connector.pandas_tools import write_pandas


class WriteSnowflake:
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

    def write_games(self):
        nhl = NhlApi()
        for season in nhl.get_all_seasons():
            try:
                write_pandas(conn=self.con, df=season, table_name="RAW_GAME_LOG")
            except Exception:
                print(f'Failed to write season to snowflake: {season}')

    def write_odds(self):
        odds = OddsApi()
        for day in odds.get_day_odds():
            try:
                write_pandas(conn=self.con, df=day, table_name="RAW_GAME_ODDS")
            except Exception:
                print(f'Failed to write day odds to snowflake: {day}')

    def write_current_odds(self):
        odds = OddsApi()
        df = odds.get_current_odds()
        try:
            write_pandas(conn=self.con, df=df, table_name="RAW_GAME_ODDS")
        except Exception:
            print(f'Failed to write current day odds to snowflake')

    def write_schedule(self):
        nhl = NhlApi()
        for season in nhl.get_schedule_seasons():
            try:
                write_pandas(conn=self.con, df=season, table_name="RAW_GAME_SCHEDULE")
            except Exception:
                print(f'Failed to write season to snowflake: {season}')

    def write_recent_results(self):
        nhl = NhlApi()
        results = nhl.get_recent_results()
        try:
            write_pandas(conn=self.con, df=results, table_name="RAW_GAME_LOG")
        except Exception:
            print(f'Failed to write recent results to snowflake')
