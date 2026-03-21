with future_odds as (
    select *
    from {{ ref('game_odds') }}
    where start_time_utc > sysdate()
),
odds_ranks as (
    select
        o.*,
        rh.total_goals_per_game as home_total_goals_per_game,
        rh.total_goals_per_game_rank as home_total_goals_per_game_rank,
        rh.goals_for_per_game as home_goals_for_per_game,
        rh.goals_for_per_game_rank as home_goals_for_per_game_rank,
        rh.goals_against_per_game as home_goals_against_per_game,
        rh.goals_against_per_game_rank as home_goals_against_per_game_rank,
        rh.total_sog_per_game as home_total_sog_per_game,
        rh.total_sog_per_game_rank as home_total_sog_per_game_rank,
        rh.sog_against_per_game as home_sog_against_per_game,
        rh.sog_against_per_game_rank as home_sog_against_per_game_rank,
        rh.sog_for_per_game as home_sog_for_per_game,
        rh.sog_for_per_game_rank as home_sog_for_per_game_rank,
        ra.total_goals_per_game as away_total_goals_per_game,
        ra.total_goals_per_game_rank as away_total_goals_per_game_rank,
        ra.goals_for_per_game as away_goals_for_per_game,
        ra.goals_for_per_game_rank as away_goals_for_per_game_rank,
        ra.goals_against_per_game as away_goals_against_per_game,
        ra.goals_against_per_game_rank as away_goals_against_per_game_rank,
        ra.total_sog_per_game as away_total_sog_per_game,
        ra.total_sog_per_game_rank as away_total_sog_per_game_rank,
        ra.sog_against_per_game as away_sog_against_per_game,
        ra.sog_against_per_game_rank as away_sog_against_per_game_rank,
        ra.sog_for_per_game as away_sog_for_per_game,
        ra.sog_for_per_game_rank as away_sog_for_per_game_rank,
    from future_odds as o inner join in_season_category_ranks as rh
        on o.home_team = rh.team
        inner join in_season_category_ranks as ra
        on o.away_team = ra.team
)
select
    start_time_utc,
    home_team,
    away_team,
    total,
    round(
        case
            when over_price >= 2 then (over_price - 1) * 100
            else -100/(over_price -1)
        end, 0) as over_price,
    round(
        case
            when under_price >= 2 then (under_price - 1) * 100
            else -100/(under_price -1)
        end, 0) as under_price,
    sum (
            -- over defense ranks > 80
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                        + home_goals_against_per_game_rank + away_goals_against_per_game_rank
                        > 80 and (total = 5.5 or total = 6 or total = 6.5)
                then 1
                else 0
                end
            -- over goals against
            + case
                when home_goals_against_per_game_rank + away_goals_against_per_game_rank
                        > 42 and (total = 5.5 or total = 6.5)
                then 1
                when home_goals_against_per_game_rank + away_goals_against_per_game_rank
                        > 42 and total = 6
                then 1
                else 0
                end
            -- over shots against
            + case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                        > 42 and total = 5.5
                then 0.75
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                        > 42 and total = 6
                then 0.75
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                        > 42 and total = 6.5
                then 1
                else 0
                end
            -- over offense ranks > 80
            + case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                        + home_goals_for_per_game_rank + away_goals_for_per_game_rank
                        > 80 and total = 5.5
                then 0.5
                else 0
                end
            -- over goals for
            + case
                when home_goals_for_per_game_rank + away_goals_for_per_game_rank
                        > 47 and total = 6
                then 1
                when home_goals_for_per_game_rank + away_goals_for_per_game_rank
                        > 47 and total = 6.5
                then 1
                else 0
                end
        ) as over_priority,
        sum (
            -- under goals against
            case
                when home_goals_against_per_game_rank + away_goals_against_per_game_rank
                        < 21 and total = 6
                then 0.75
                when home_goals_against_per_game_rank + away_goals_against_per_game_rank
                        < 21 and total = 6.5
                then 1
                else 0
                end
            -- under totals goals -0.35
            + case
                when ((home_total_goals_per_game + away_total_goals_per_game)/2 - total < -0.35)
                    and total = 6.5
                then 1
                else 0
                end
            -- under total goals
            + case
                when home_total_goals_per_game_rank + away_total_goals_per_game_rank
                        < 21 and total = 6
                then 1
                when home_total_goals_per_game_rank + away_total_goals_per_game_rank
                        < 21 and total = 6.5
                then 1
                else 0
                end
            -- under shots against
            + case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                        < 21 and total = 6.5
                then 1
                else 0
                end
            -- under offense ranks < 40
            + case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                        + home_goals_for_per_game_rank + away_goals_for_per_game_rank
                        < 40 and total = 5.5 or total = 6 or total = 6.5
                then 1
                else 0
                end
            -- under goals for
            + case
                when home_goals_for_per_game_rank + away_goals_for_per_game_rank
                        < 17 and total = 5.5
                then 1
                when home_goals_for_per_game_rank + away_goals_for_per_game_rank
                        < 17 and total = 6
                then 1
                else 0
                end
            -- under shots for
            + case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                        < 17 and total = 6.5
                then 1
                else 0
                end
            -- under defense ranks < 40
            + case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                        + home_goals_against_per_game_rank + away_goals_against_per_game_rank
                        < 40 and total = 6.5
                then 1
                else 0
                end
            -- under totals ranks < 40
            + case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank
                        + home_total_goals_per_game_rank + away_total_goals_per_game_rank
                        < 40 and total = 6.5
                then 1
                else 0
                end
        ) as under_priority,
from odds_ranks
group by
    start_time_utc,
    home_team,
    away_team,
    total,
    over_price,
    under_price
having abs(over_priority - under_priority) >= 2
order by start_time_utc asc, home_team asc, total desc
