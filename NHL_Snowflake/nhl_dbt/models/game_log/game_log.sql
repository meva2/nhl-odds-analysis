{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

with json_game_log as(
    select
        game_id,
        parse_json(game_record) as game_record
    from {{ source('nhl', 'raw_game_log') }}
    {% if is_incremental() %}
    where elt_timestamp > (select max(elt_timestamp) from {{ this }})
    {% endif %}
),
duplicates_filter as (
    select *, row_number() over(partition by game_id order by game_id) as rn
    from json_game_log
),
filtered as (
    select
        game_id,
        game_record['startTimeUTC']::datetime as start_time_utc,
        concat(game_record['awayTeam']['placeName']['default'], ' ', game_record['awayTeam']['commonName']['default']) as away_team,
        concat(game_record['homeTeam']['placeName']['default'], ' ', game_record['homeTeam']['commonName']['default']) as home_team,
        case
            when game_record['playerByGameStats']['awayTeam']['goalies'][0]['starter'] = true
            then game_record['playerByGameStats']['awayTeam']['goalies'][0]['playerId']
            else game_record['playerByGameStats']['awayTeam']['goalies'][1]['playerId']
        end as away_starter_id,
        case
            when game_record['playerByGameStats']['homeTeam']['goalies'][0]['starter'] = true
            then game_record['playerByGameStats']['homeTeam']['goalies'][0]['playerId']
            else game_record['playerByGameStats']['homeTeam']['goalies'][1]['playerId']
        end as home_starter_id,
        game_record['awayTeam']['score']::int as away_goals,
        game_record['homeTeam']['score']::int as home_goals,
        away_goals + home_goals as total_goals,
        game_record['awayTeam']['sog']::int as away_sog,
        game_record['homeTeam']['sog']::int as home_sog,
        away_sog + home_sog as total_sog
    from duplicates_filter
    where rn = 1
)
select
    f.*,
    sysdate() as elt_timestamp
from filtered as f
