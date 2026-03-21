{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

with json_odds as(
    select
        game_id,
        parse_json(game_odds) as game_odds
    from {{ source('nhl', 'raw_game_odds') }}
    {% if is_incremental() %}
    where elt_timestamp > (select max(elt_timestamp) from {{ this }})
    {% endif %}
),
bookmaker_flatten as(
    select
        game_id,
        game_odds['commence_time']::datetime as start_time,
        game_odds['home_team']::string as home_team,
        game_odds['away_team']::string as away_team,
        b.value as bookmaker
    from json_odds, lateral flatten(game_odds['bookmakers']) b
),
odds_conversion as(
select
    start_time,
    home_team,
    away_team,
    bookmaker['title']::string as bookmaker,
    bookmaker['last_update']::datetime as last_update,
    bookmaker['markets'][0]['outcomes'][0]['point']::float as total,
    case
        when bookmaker['markets'][0]['outcomes'][0]['price']::int > 0
            then truncate(round(((bookmaker['markets'][0]['outcomes'][0]['price']::int/100) + 1),2),2)
        when bookmaker['markets'][0]['outcomes'][0]['price']::int < 0
            then truncate(round((abs((100/bookmaker['markets'][0]['outcomes'][0]['price']::int)) + 1),2),2)
    end as over_price,
    case
        when bookmaker['markets'][0]['outcomes'][1]['price']::int > 0
            then truncate(round(((bookmaker['markets'][0]['outcomes'][1]['price']::int/100) + 1),2),2)
        when bookmaker['markets'][0]['outcomes'][1]['price']::int < 0
            then truncate(round((abs((100/bookmaker['markets'][0]['outcomes'][1]['price']::int)) + 1),2),2)
    end as under_price,
    game_id
from bookmaker_flatten),
rank_odds_times as(
select
    start_time,
    home_team,
    away_team,
    bookmaker,
    last_update,
    row_number() over (partition by game_id, bookmaker order by last_update desc) as latest_odds,
    total,
    over_price,
    under_price,
    game_id
from odds_conversion
),
latest_odds_only as(
select * exclude(latest_odds)
from rank_odds_times
where latest_odds = 1 and last_update < start_time
)
select
    l.start_time as start_time_utc,
    l.home_team,
    l.away_team,
    l.total,
    round(avg(l.over_price), 2) as over_price,
    round(avg(l.under_price), 2) as under_price,
    l.game_id,
    sysdate() as elt_timestamp
from latest_odds_only as l
group by start_time, home_team, away_team, total, game_id

