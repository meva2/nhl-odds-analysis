with json_game_log as(
    select
        game_id,
        parse_json(game_record) as game_record
    from {{ source('nhl', 'raw_game_log') }}
    where game_id >= 2020020001
),
away_goalie_games as(
    select
        game_id,
        game_record['startTimeUTC']::datetime as start_time_utc,
        concat(game_record['awayTeam']['placeName']['default'], ' ', game_record['awayTeam']['commonName']['default']) as away_team,
        concat(game_record['homeTeam']['placeName']['default'], ' ', game_record['homeTeam']['commonName']['default']) as home_team,
        away.value as goalie_game
    from
        json_game_log,
        lateral flatten(game_record['playerByGameStats']['awayTeam']['goalies']) as away
),
home_goalie_games as(
    select
        game_id,
        game_record['startTimeUTC']::datetime as start_time_utc,
        concat(game_record['awayTeam']['placeName']['default'], ' ', game_record['awayTeam']['commonName']['default']) as away_team,
        concat(game_record['homeTeam']['placeName']['default'], ' ', game_record['homeTeam']['commonName']['default']) as home_team,
        home.value as goalie_game
    from
        json_game_log,
        lateral flatten(game_record['playerByGameStats']['homeTeam']['goalies']) as home
)
select *
from away_goalie_games
union
select *
from home_goalie_games


