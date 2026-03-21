from nhl_api import NhlApi
from odds_api import OddsApi
import unittest
from unittest import mock
from unittest.mock import patch, MagicMock
from asyncio import Future
import pandas as pd
from requests.exceptions import HTTPError
import datetime
from freezegun import freeze_time


class TestNhlApi(unittest.TestCase):

    @classmethod
    def setUpClass(cls) -> None:
        cls.nhl_api = NhlApi()

    @freeze_time('2026-01-01')
    @patch('requests.get')
    def test_get_game(self, mock_get):
        game_id = 'fake_id'
        mock_get.return_value.status_code = 404
        try:
            self.nhl_api.get_game(game_id)
        except HTTPError as e:
            self.assertEqual(str(e), 'Failed to download game: fake_id with response status: 404')
        mock_get.return_value.status_code = 200
        mock_get.return_value.text = 'fake_json'
        result = self.nhl_api.get_game(game_id)
        self.assertEqual(result, ['fake_id', 'fake_json', datetime.datetime.now().timestamp()])

    @patch('nhl_api.NhlApi.get_game')
    def test_get_season(self, mock_get_game):
        year = 1999
        num_games = 3
        fut1 = Future()
        fut2 = Future()
        fut3 = Future()
        fut1.set_result('game1')
        fut2.set_result('game2')
        fut3.set_result('game3')
        mock_get_game.side_effect = [fut1, fut2, fut3]
        results = self.nhl_api.get_season(year, num_games)
        mock_get_game.assert_any_call('1999020001')
        mock_get_game.assert_any_call('1999020002')
        mock_get_game.assert_any_call('1999020003')
        self.assertEqual([result.result() for result in results], ['game1', 'game2', 'game3'])

    def test_get_games_per_season(self):
        self.nhl_api.seasons = [{'id': 20202021, 'totalRegularSeasonGames': 13}, {'id': 20222023, 'totalRegularSeasonGames': 7}]
        result = self.nhl_api.get_games_per_season()
        self.assertEqual(result, {'20202021': 13, '20222023': 7})

    @patch('nhl_api.NhlApi.get_season')
    def test_get_all_seasons(self, mock_get_season):
        fake_now = datetime.datetime.now().timestamp()
        self.nhl_api.games_per_season = {'20202021': 13, '20222023': 7}
        fake_season1 = [[2020020001, 'fake game data 1', fake_now], [2020020002, 'fake game data 2', fake_now]]
        fake_season2 = [[2022020001, 'fake game data 3', fake_now], [2022020002, 'fake game data 4', fake_now]]
        mock_get_season.side_effect = [fake_season1, fake_season2]
        columns = ['GAME_ID', 'GAME_RECORD', 'ELT_TIMESTAMP']
        fake_df1 = pd.DataFrame(fake_season1, columns=columns)
        fake_df2 = pd.DataFrame(fake_season2, columns=columns)
        fake_gen = self.nhl_api.get_all_seasons()
        result1 = next(fake_gen)
        result2 = next(fake_gen)
        self.assertTrue(fake_df1.equals(result1))
        self.assertTrue(fake_df2.equals(result2))
        calls = [mock.call.get_season('20202021', 13), mock.call.get_season('20222023', 7)]
        mock_get_season.assert_has_calls(calls)
        with self.assertRaises(StopIteration) as context:
            next(fake_gen)

    @patch('requests.get')
    def test_get_schedule_day(self, mock_get):
        date = 'fake_date'
        mock_get.return_value.status_code = 404
        result = self.nhl_api.get_schedule_day(date)
        self.assertEqual(result, f'Failed to download schedule for day: {date}')
        mock_get.return_value.status_code = 200
        mock_response = mock_get.return_value
        mock_response.json.return_value = {"gameWeek": [{"date": "fake_date", "games": [{"id": 2025020001}, {"id": 2025020002}, {"id": 2025030003}]}, {"date": "nonexistant", "games": [{"id": 3}, {"id": 4}]}]}
        result = self.nhl_api.get_schedule_day(date)
        expected = [['2025020001', str({"id": 2025020001})], ['2025020002', str({"id": 2025020002})]]
        self.assertEqual(result, expected)

    @patch('nhl_api.NhlApi.get_schedule_day')
    def test_get_schedule_seasons(self, mock_get_day):
        self.nhl_api.odds_season_intervals = [['2022-10-07T14:00:00', '2022-10-08T14:00:00'], ['2025-01-01T14:00:00', '2025-01-03T14:00:00']]
        mock_get_day.side_effect = [[['1', 'game1']], [['2', 'game2']], [['3', 'game3']], [['4', 'game4']], [['5', 'game5'], ['6', 'game6']]]
        columns = ['GAME_ID', 'GAME_SCHEDULE']
        fake_season1 = [['1', 'game1'], ['2', 'game2']]
        fake_season2 = [['3', 'game3'], ['4', 'game4'], ['5', 'game5'], ['6', 'game6']]
        fake_df1 = pd.DataFrame(fake_season1, columns=columns)
        fake_df2 = pd.DataFrame(fake_season2, columns=columns)
        fake_gen = self.nhl_api.get_schedule_seasons()
        result1 = next(fake_gen)
        result2 = next(fake_gen)
        self.assertTrue(fake_df1.equals(result1))
        self.assertTrue(fake_df2.equals(result2))
        calls = [mock.call.get_day_schedule('2022-10-07'), mock.call.get_day_schedule('2022-10-08'), mock.call.get_day_schedule('2025-01-01'), mock.call.get_day_schedule('2025-01-02'), mock.call.get_day_schedule('2025-01-03')]
        mock_get_day.assert_has_calls(calls)
        with self.assertRaises(StopIteration) as context:
            next(fake_gen)

    @patch('nhl_api.NhlApi.get_game')
    @patch('snowflake.connector.connect')
    def test_get_recent_results(self, mock_sql, mock_get_game):
        sql_return = [5]
        mock_con = mock_sql.return_value
        mock_cur = mock_con.cursor.return_value
        mock_cur.execute.return_value.fetchone.return_value = sql_return
        fake_time = datetime.datetime(2026, 1, 1)
        fake_time2 = datetime.datetime(2026, 1, 2)
        mock_get_game.side_effect = [[6, '{"gameState": "OFF"}', fake_time.timestamp()], [7, '{"gameState": "OFF"}', fake_time2.timestamp()], [8, '{"gameState": "FUT"}', fake_time.timestamp()]]
        columns = ['GAME_ID', 'GAME_RECORD', 'ELT_TIMESTAMP']
        expected = pd.DataFrame([[6, '{"gameState": "OFF"}', fake_time.timestamp()], [7, '{"gameState": "OFF"}', fake_time2.timestamp()]], columns=columns)
        result = self.nhl_api.get_recent_results()
        self.assertTrue(result.equals(expected))
        calls = [mock.call.get_game(6), mock.call.get_game(7), mock.call.get_game(8)]
        mock_get_game.assert_has_calls(calls)


class TestOddsApi(unittest.TestCase):

    @classmethod
    def setUpClass(cls) -> None:
        cls.odds_api = OddsApi()

    @freeze_time('2026-01-01')
    @patch('requests.get')
    def test_get_day_odds(self, mock_get):
        self.odds_api.nhl.odds_season_intervals = [['2022-10-07T14:00:00', '2022-10-08T14:00:00']]
        mock_get.return_value.status_code = 403

        result = self.odds_api.get_day_odds()
        try:
            next(result)
        except HTTPError as e:
            self.assertEqual(str(e), 'Failed to download historical odds with response status: 403')
        mock_get.reset_mock()
        mock_get.side_effect = [
            MagicMock(status_code=200, json=lambda: {'data': [{'id': 'day 1 game 1'}, {'id': 'day 1 game 2'}]}),
            MagicMock(status_code=200, json=lambda: {'data': [{'id': 'day 2 game 1'}, {'id': 'day 2 game 2'}]})
        ]
        fake_day1 = [['day 1 game 1', {'id': 'day 1 game 1'}, datetime.datetime.now().timestamp()], ['day 1 game 2', {'id': 'day 1 game 2'}, datetime.datetime.now().timestamp()]]
        fake_day2 = [['day 2 game 1', {'id': 'day 2 game 1'}, datetime.datetime.now().timestamp()], ['day 2 game 2', {'id': 'day 2 game 2'}, datetime.datetime.now().timestamp()]]
        fake_df1 = pd.DataFrame(fake_day1, columns=self.odds_api.GAME_ODDS_COLUMNS)
        fake_df2 = pd.DataFrame(fake_day2, columns=self.odds_api.GAME_ODDS_COLUMNS)
        fake_gen = self.odds_api.get_day_odds()
        result1 = next(fake_gen)
        result2 = next(fake_gen)
        self.assertTrue(fake_df1.equals(result1))
        self.assertTrue(fake_df2.equals(result2))
        with self.assertRaises(StopIteration) as context:
            next(fake_gen)

    @freeze_time('2026-01-01')
    @patch('requests.get')
    def test_get_current_odds(self, mock_get):
        mock_get.return_value.status_code = 403
        try:
            self.odds_api.get_current_odds()
        except HTTPError as e:
            self.assertEqual(str(e), 'Failed to download current odds with response status: 403')
        mock_get.reset_mock()
        mock_get.side_effect = [MagicMock(status_code=200, json=lambda: [{'id': 'day 1 game 1'}, {'id': 'day 1 game 2'}])]
        fake_odds = [['day 1 game 1', {'id': 'day 1 game 1'}, datetime.datetime.now().timestamp()], ['day 1 game 2', {'id': 'day 1 game 2'}, datetime.datetime.now().timestamp()]]
        expected = pd.DataFrame(fake_odds, columns=self.odds_api.GAME_ODDS_COLUMNS)
        result = self.odds_api.get_current_odds()
        self.assertTrue(expected.equals(result))


