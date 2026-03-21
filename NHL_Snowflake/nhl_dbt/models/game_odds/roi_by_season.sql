with odds_game_id as (
    select
        substring(gl.game_id,1,4) as season,
        gl.game_id,
        gl.total_goals,
        o.total,
        o.over_price,
        o.under_price
    from {{ ref('game_log') }} as gl inner join game_odds as o
        on gl.start_time_utc = o.start_time_utc
            and gl.home_team = o.home_team
            and gl.away_team = o.away_team
    where substring(gl.game_id,7)::int > 250 and substring(gl.game_id,1,4) not like '2020%'
),
odds_ranks as (
    select
        cr.*,
        o.season,
        o.total,
        o.over_price,
        o.under_price
    from {{ ref('category_ranks') }} as cr inner join odds_game_id as o on cr.game_id = o.game_id
), total_criteria as (
    select
        game_id,
        total_goals,
        total,
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
        season,
        over_price,
        under_price
    from odds_ranks
    group by
        game_id,
        total_goals,
        total,
        season,
        over_price,
        under_price
    having abs(over_priority - under_priority) >= 2
), roi as (
    select
        season,
        total,
        sum (
            case
                when total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        sum (
            case
                when total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        over_count + under_count as games_count,
        sum (
            case
                when over_priority > under_priority and total_goals > total then over_price
                when over_priority < under_priority and total_goals < total then under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/games_count,2)*100 as roi
    from total_criteria
    group by
        season,
        total
    order by
        season,
        total
)
select
    season,
    round((sum(units_won) - sum(games_count))/sum(games_count)*100,2) as combined_roi,
    sum(games_count) as games_count
from roi
group by season
order by season asc














