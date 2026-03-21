with teams_list as(
    select distinct away_team as team
    from {{ ref('game_log') }}
    where substring(game_id, 0, 4) = '2025'
),
team_games as (
    select
        tl.team,
        gl.*
    from teams_list as tl inner join {{ ref('game_log') }} as gl
    on tl.team = gl.home_team or tl.team = gl.away_team
    where substring(gl.game_id, 0, 4) = '2025'
),
ranks_totals as (
    select
        team,
        round(sum(away_goals + home_goals)/count(*), 2) as total_goals_per_game,
        row_number() over(order by total_goals_per_game asc) as total_goals_per_game_rank,
        round(sum(
            case
                when team = home_team then home_goals
                when team = away_team then away_goals
                else 0
            end
        ) / count(*), 2) as goals_for_per_game,
        row_number() over(order by goals_for_per_game desc) as goals_for_per_game_rank,
        round(sum(
            case
                when team = away_team then home_goals
                when team = home_team then away_goals
                else 0
            end
        ) / count(*), 2) as goals_against_per_game,
        row_number() over(order by goals_against_per_game asc) as goals_against_per_game_rank,
        round(sum(away_sog + home_sog)/count(*), 2) as total_sog_per_game,
        row_number() over(order by total_sog_per_game asc) as total_sog_per_game_rank,
        round(sum(
            case
                when team = away_team then home_sog
                when team = home_team then away_sog
                else 0
            end
        ) / count(*), 2) as sog_against_per_game,
        row_number() over(order by sog_against_per_game asc) as sog_against_per_game_rank,
        round(sum(
            case
                when team = home_team then home_sog
                when team = away_team then away_sog
                else 0
            end
        ) / count(*), 2) as sog_for_per_game,
        row_number() over(order by sog_for_per_game desc) as sog_for_per_game_rank
    from team_games
    group by
        team

)
select * from ranks_totals
