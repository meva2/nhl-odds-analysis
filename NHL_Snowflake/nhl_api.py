import requests
import pandas as pd
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone
from datetime import timedelta
from read_snowflake import ReadSnowflake
import json
from requests.exceptions import HTTPError


class NhlApi:

    def __init__(self):
        self.seasons = requests.get('https://api.nhle.com/stats/rest/en/season').json()['data']
        self.target_seasons = [20202021, 20212022, 20222023, 20232024, 20242025, 20252026]
        self.games_per_season = self.get_games_per_season()
        self.odds_season_intervals = self.get_odds_season_intervals()

    def get_games_per_season(self):
        games_per_season = {}
        for year in self.target_seasons:
            for season in self.seasons:
                if year == season['id']:
                    games_per_season[str(season['id'])] = season['totalRegularSeasonGames']
        return games_per_season

    def get_game(self, game_id):
        response = requests.get(f'https://api-web.nhle.com/v1/gamecenter/{game_id}/boxscore')
        if response.status_code == 200:
            record = [game_id, response.text, datetime.now(timezone.utc).timestamp()]
            return record
        else:
            raise HTTPError(f'Failed to download game: {game_id} with response status: {response.status_code}')

    def get_season(self, year, num_games):
        season_code = str(year)[0:4] + '02'
        with ThreadPoolExecutor() as ex:
            futures = [ex.submit(self.get_game, season_code + "{:04d}".format(game_id)) for game_id in range(1, num_games+1)]
        return [future.result() for future in futures]

    def get_all_seasons(self):
        for season in self.games_per_season.keys():
            data = self.get_season(season, self.games_per_season[season])
            columns = ['GAME_ID', 'GAME_RECORD', 'ELT_TIMESTAMP']
            df = pd.DataFrame(data, columns=columns)
            yield df

    def get_odds_season_intervals(self):
        odds_season_intervals = []
        for season in self.seasons:
            if season['id'] in self.target_seasons:
                odds_season_intervals.append([season['startDate'], season['regularSeasonEndDate']])
        return odds_season_intervals

    def get_schedule_day(self, date):
        response = requests.get(f'https://api-web.nhle.com/v1/schedule/{date}')
        if response.status_code == 200:
            data = response.json()['gameWeek']
            for game_day in data:
                if game_day['date'] == date:
                    records = []
                    for game in game_day['games']:
                        if str(game['id'])[4:6] == '02':
                            records.append([str(game['id']), str(game)])
                    return records
        else:
            return f'Failed to download schedule for day: {date}'

    def get_schedule_seasons(self):
        for interval in self.odds_season_intervals:
            season_games = []
            schedule_date = datetime.strptime(interval[0], "%Y-%m-%dT%H:%M:%S")
            while schedule_date <= datetime.strptime(interval[1], "%Y-%m-%dT%H:%M:%S"):
                day_games = self.get_schedule_day(str(schedule_date.date()))
                for game in day_games:
                    season_games.append(game)
                schedule_date = schedule_date + timedelta(days=1)
            columns = ['GAME_ID', 'GAME_SCHEDULE']
            df = pd.DataFrame(season_games, columns=columns)
            yield df

    def get_recent_results(self):
        recent_results = []
        snf = ReadSnowflake()
        sql = 'select max(game_id) from raw_game_log'
        game_id = int(snf.cur.execute(sql).fetchone()[0])
        game_id += 1
        record = self.get_game(game_id)
        while json.loads(record[1])['gameState'] == 'OFF':
            recent_results.append(record)
            game_id += 1
            record = self.get_game(game_id)
        columns = ['GAME_ID', 'GAME_RECORD', 'ELT_TIMESTAMP']
        df = pd.DataFrame(recent_results, columns=columns)
        return df
