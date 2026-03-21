with years_teams as (
    select distinct concat(substring(game_id,0,4),' ',away_team) as year_team
    from {{ ref('game_log') }}
),
game_log_teams as (
    select
        gl.game_id,
        gl.start_time_utc,
        gl.away_team,
        gl.home_team,
        gl.total_goals,
        substring(yt.year_team,6) as team
    from {{ ref('game_log') }} as gl inner join years_teams as yt on substring(gl.game_id, 0, 4) = substring(yt.year_team, 0, 4)

),
previous_game_logs as (
    select
        glt.*,
        gl.home_team as previous_home_team,
        gl.away_team as previous_away_team,
        gl.away_goals as previous_away_goals,
        gl.home_goals as previous_home_goals,
        gl.home_sog as previous_home_sog,
        gl.away_sog as previous_away_sog
    from game_log_teams as glt inner join {{ ref('game_log') }} gl
    on (glt.team = gl.home_team or glt.team = gl.away_team)
        and substring(glt.game_id, 0, 4) = substring(gl.game_id, 0, 4)
        and date(glt.start_time_utc) > date(gl.start_time_utc)
),
ranks_totals as (
    select
        game_id,
        away_team,
        home_team,
        total_goals,
        team,
        row_number() over(partition by game_id order by
            sum(
                previous_home_goals + previous_away_goals
            ) / count(*)
            asc) as total_goals_per_game_rank,
        round(sum(previous_away_goals + previous_home_goals)/count(*), 2) as total_goals_per_game,
        row_number() over(partition by game_id order by
            sum(
                case
                    when team = previous_home_team then previous_home_goals
                    when team = previous_away_team then previous_away_goals
                    else 0
                end
            ) / count(*)
            desc) as goals_for_per_game_rank,
        round(sum(
            case
                when team = previous_home_team then previous_home_goals
                when team = previous_away_team then previous_away_goals
                else 0
            end
        ) / count(*), 2) as goals_for_per_game,
        row_number() over(partition by game_id order by
            sum(
                case
                    when team = previous_away_team then previous_home_goals
                    when team = previous_home_team then previous_away_goals
                    else 0
                end
            ) / count(*)
            asc) as goals_against_per_game_rank,
        round(sum(
            case
                when team = previous_away_team then previous_home_goals
                when team = previous_home_team then previous_away_goals
                else 0
            end
        ) / count(*), 2) as goals_against_per_game,
        row_number() over(partition by game_id order by
            sum(
                previous_home_sog + previous_away_sog
            ) / count(*)
            asc) as total_sog_per_game_rank,
        round(sum(previous_away_sog + previous_home_sog)/count(*), 2) as total_sog_per_game,
        row_number() over(partition by game_id order by
            sum(
                case
                    when team = previous_away_team then previous_home_sog
                    when team = previous_home_team then previous_away_sog
                    else 0
                end
            ) / count(*)
            asc) as sog_against_per_game_rank,
        round(sum(
            case
                when team = previous_away_team then previous_home_sog
                when team = previous_home_team then previous_away_sog
                else 0
            end
        ) / count(*), 2) as sog_against_per_game,
        row_number() over(partition by game_id order by
            sum(
                case
                    when team = previous_home_team then previous_home_sog
                    when team = previous_away_team then previous_away_sog
                    else 0
                end
            ) / count(*)
            desc) as sog_for_per_game_rank,
        round(sum(
            case
                when team = previous_home_team then previous_home_sog
                when team = previous_away_team then previous_away_sog
                else 0
            end
        ) / count(*), 2) as sog_for_per_game
    from previous_game_logs
    group by
        game_id,
        away_team,
        home_team,
        total_goals,
        team

)
select
    h.game_id,
    h.home_team,
    h.away_team,
    h.total_goals,
    h.total_goals_per_game_rank as home_total_goals_per_game_rank,
    a.total_goals_per_game_rank as away_total_goals_per_game_rank,
    h.total_goals_per_game as home_total_goals_per_game,
    a.total_goals_per_game as away_total_goals_per_game,
    h.goals_for_per_game_rank as home_goals_for_per_game_rank,
    a.goals_for_per_game_rank as away_goals_for_per_game_rank,
    h.goals_for_per_game as home_goals_for_per_game,
    a.goals_for_per_game as away_goals_for_per_game,
    h.goals_against_per_game_rank as home_goals_against_per_game_rank,
    a.goals_against_per_game_rank as away_goals_against_per_game_rank,
    h.goals_against_per_game as home_goals_against_per_game,
    a.goals_against_per_game as away_goals_against_per_game,
    h.total_sog_per_game_rank as home_total_sog_per_game_rank,
    a.total_sog_per_game_rank as away_total_sog_per_game_rank,
    h.total_sog_per_game as home_total_sog_per_game,
    a.total_sog_per_game as away_total_sog_per_game,
    h.sog_against_per_game_rank as home_sog_against_per_game_rank,
    a.sog_against_per_game_rank as away_sog_against_per_game_rank,
    h.sog_against_per_game as home_sog_against_per_game,
    a.sog_against_per_game as away_sog_against_per_game,
    h.sog_for_per_game_rank as home_sog_for_per_game_rank,
    a.sog_for_per_game_rank as away_sog_for_per_game_rank,
    h.sog_for_per_game as home_sog_for_per_game,
    a.sog_for_per_game as away_sog_for_per_game,
from ranks_totals as h inner join ranks_totals as a
on h.game_id = a.game_id and h.team = h.home_team and a.team = h.away_team
order by h.game_id asc
