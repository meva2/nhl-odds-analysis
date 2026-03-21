with away_starter as(
select
    gl.game_id as game_id,
    gl.start_time_utc as start_time_utc,
    gl.away_team as away_team,
    gl.home_team as home_team,
    ggl.goalie_game['name']['default']::string as away_starter_name,
    gl.away_starter_id as away_starter_id,
    split(ggl.goalie_game['toi'], ':')[0]::float*60 + split(ggl.goalie_game['toi'], ':')[1]::float as toi,
    ggl.goalie_game['shotsAgainst'] as shots_against,
    ggl.goalie_game['saves'] as saves,
    ggl.goalie_game['goalsAgainst'] as goals_against,
    ggl.start_time_utc as prev_game_time,
    ggl.away_team as prev_away,
    ggl.home_team as prev_home
from {{ ref('game_log') }} as gl
inner join {{ ref('goalie_game_log') }} as ggl
on (gl.away_starter_id = ggl.goalie_game['playerId'])
and (substring(gl.game_id::string, 1, 4) = substring(ggl.game_id::string, 1, 4))
and (gl.start_time_utc > ggl.start_time_utc)
),
away_aggregate as(
select
    game_id,
    away_team,
    home_team,
    away_starter_name,
    sum(toi) as total_toi,
    sum(goals_against) as total_goals_against,
    sum(saves) as total_saves,
    sum(shots_against) as total_shots_against,
    case
        when total_shots_against = 0 then null
        else truncate(round((total_saves / total_shots_against), 3), 3)
    end as save_percentage,
    case
        when total_toi = 0 then null
        else truncate(round(total_goals_against / (total_toi / 3600), 2), 2)
    end as gaa
from away_starter
group by game_id, away_team, home_team, away_starter_name
order by game_id desc
),
home_starter as(
select
    gl.game_id as game_id,
    gl.start_time_utc as start_time_utc,
    gl.away_team as away_team,
    gl.home_team as home_team,
    ggl.goalie_game['name']['default']::string as home_starter_name,
    gl.home_starter_id as home_starter_id,
    split(ggl.goalie_game['toi'], ':')[0]::float*60 + split(ggl.goalie_game['toi'], ':')[1]::float as toi,
    ggl.goalie_game['shotsAgainst'] as shots_against,
    ggl.goalie_game['saves'] as saves,
    ggl.goalie_game['goalsAgainst'] as goals_against,
    ggl.start_time_utc as prev_game_time,
    ggl.away_team as prev_away,
    ggl.home_team as prev_home
from {{ ref('game_log') }} as gl
inner join {{ ref('goalie_game_log') }} as ggl
on (gl.home_starter_id = ggl.goalie_game['playerId'])
and (substring(gl.game_id::string, 1, 4) = substring(ggl.game_id::string, 1, 4))
and (gl.start_time_utc > ggl.start_time_utc)
),
home_aggregate as(
select
    game_id,
    home_starter_name,
    sum(toi) as total_toi,
    sum(goals_against) as total_goals_against,
    sum(saves) as total_saves,
    sum(shots_against) as total_shots_against,
    case
        when total_shots_against = 0 then null
        else truncate(round((total_saves / total_shots_against), 3), 3)
    end as save_percentage,
    case
        when total_toi = 0 then null
        else truncate(round(total_goals_against / (total_toi / 3600), 2), 2)
    end as gaa
from home_starter
group by game_id, home_starter_name
order by game_id desc
)
select
    h.game_id as game_id,
    a.away_team,
    a.home_team,
    a.away_starter_name,
    a.gaa as away_gaa,
    a.save_percentage as away_save_percentage,
    h.home_starter_name,
    h.gaa as home_gaa,
    h.save_percentage as home_save_percentage
from away_aggregate as a
inner join home_aggregate as h
on a.game_id = h.game_id
where a.total_toi > 18000 and h.total_toi > 18000

