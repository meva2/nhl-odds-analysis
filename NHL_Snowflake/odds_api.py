import pandas as pd
import requests
import os
from dotenv import load_dotenv
from nhl_api import NhlApi
from datetime import datetime, timezone
from datetime import timedelta
from requests.exceptions import HTTPError


class OddsApi:
    def __init__(self):
        load_dotenv()
        self.api_key = os.environ['ODDS_API_KEY']
        self.nhl = NhlApi()
        self.GAME_ODDS_COLUMNS = ['GAME_ID', 'GAME_ODDS', 'ELT_TIMESTAMP']

    def get_day_odds(self):
        for interval in self.nhl.odds_season_intervals:
            odds_date = datetime.strptime(interval[0], "%Y-%m-%dT%H:%M:%S")
            while odds_date <= datetime.strptime(interval[1], "%Y-%m-%dT%H:%M:%S"):
                game_odds = []
                url = f'https://api.the-odds-api.com/v4/historical/sports/icehockey_nhl/odds/?apiKey={self.api_key}&regions=us&markets=totals&oddsFormat=american&date={odds_date.date()}T08:00:00Z'
                response = requests.get(url=url)
                if response.status_code == 200:
                    games = response.json()['data']
                    for game in games:
                        game_odds.append([game['id'], game, datetime.now(timezone.utc).timestamp()])
                else:
                    raise HTTPError(f'Failed to download historical odds with response status: {response.status_code}')
                odds_date = odds_date + timedelta(days=1)
                df = pd.DataFrame(game_odds, columns=self.GAME_ODDS_COLUMNS)
                yield df

    def get_current_odds(self):
        game_odds = []
        url = f'https://api.the-odds-api.com/v4/sports/icehockey_nhl/odds/?apiKey={self.api_key}&regions=us&markets=totals&oddsFormat=american'
        response = requests.get(url=url)
        if response.status_code == 200:
            games = response.json()
            for game in games:
                game_odds.append([game['id'], game, datetime.now(timezone.utc).timestamp()])
        else:
            raise HTTPError(f'Failed to download current odds with response status: {response.status_code}')
        df = pd.DataFrame(game_odds, columns=self.GAME_ODDS_COLUMNS)
        return df


