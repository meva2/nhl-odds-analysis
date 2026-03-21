with odds_game_id as (
    select
        gl.game_id,
        o.total,
        o.over_price,
        o.under_price
    from {{ ref('game_log') }} as gl inner join {{ ref('game_odds') }} as o
        on gl.start_time_utc = o.start_time_utc
            and gl.home_team = o.home_team
            and gl.away_team = o.away_team
    where substring(gl.game_id,7)::int > 250 and o.total < 7 and o.total > 5 and substring(gl.game_id,1,4) not like '2020%'
),
odds_ranks as (
    select
        cr.*,
        o.total,
        o.over_price,
        o.under_price
    from {{ ref('category_ranks') }} as cr inner join odds_game_id as o on cr.game_id = o.game_id
),
under_total_goals as (
    select
        'under total goals minus 0.35' as criteria,
        total,
        sum(
            case
                when ((home_total_goals_per_game + away_total_goals_per_game)/2 - total < -0.35)
                    and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when ((home_total_goals_per_game + away_total_goals_per_game)/2 - total < -0.35)
                    and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / games_count)*100, 2) as over_pct,
        round(sum(
            case
                when (home_total_goals_per_game + away_total_goals_per_game)/2 - total < -0.35 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when (home_total_goals_per_game + away_total_goals_per_game)/2 - total < -0.35 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when ((home_total_goals_per_game + away_total_goals_per_game)/2 - total < -0.35)
                    and total_goals < total
                then under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
over_total_goals as (
    select
        'over total goals plus 0.35' as criteria,
        total,
        sum(
            case
                when ((home_total_goals_per_game + away_total_goals_per_game)/2 - total > 0.35)
                    and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when ((home_total_goals_per_game + away_total_goals_per_game)/2 - total > 0.35)
                    and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when (home_total_goals_per_game + away_total_goals_per_game)/2 - total > 0.35 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when (home_total_goals_per_game + away_total_goals_per_game)/2 - total > 0.35 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when ((home_total_goals_per_game + away_total_goals_per_game)/2 - total > 0.35)
                    and total_goals > total
                then over_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
under_totals_ranks_combined as(
    select
        'under totals ranks combined < 40' as criteria,
        total,
        sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank
                    + home_total_goals_per_game_rank + away_total_goals_per_game_rank
                    < 40 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank
                    + home_total_goals_per_game_rank + away_total_goals_per_game_rank
                    < 40 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank + home_total_goals_per_game_rank + away_total_goals_per_game_rank < 40
                    and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank + home_total_goals_per_game_rank + away_total_goals_per_game_rank < 40
                    and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank
                    + home_total_goals_per_game_rank + away_total_goals_per_game_rank
                    < 40 and total_goals < total
                then under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
over_totals_ranks_combined as(
    select
        'over totals ranks combined > 80' as criteria,
        total,
        sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank
                    + home_total_goals_per_game_rank + away_total_goals_per_game_rank
                    > 80 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank
                    + home_total_goals_per_game_rank + away_total_goals_per_game_rank
                    > 80 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / games_count)*100, 2) as over_pct,
        round(sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank + home_total_goals_per_game_rank + away_total_goals_per_game_rank > 80
                    and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank + home_total_goals_per_game_rank + away_total_goals_per_game_rank > 80
                    and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank
                    + home_total_goals_per_game_rank + away_total_goals_per_game_rank
                    > 80 and total_goals > total
                then over_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
under_defense_ranks_combined as(
    select
        'under defense ranks combined < 40' as criteria,
        total,
        sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    + home_goals_against_per_game_rank + away_goals_against_per_game_rank
                    < 40 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    + home_goals_against_per_game_rank + away_goals_against_per_game_rank
                    < 40 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    + home_goals_against_per_game_rank + away_goals_against_per_game_rank < 40
                    and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    + home_goals_against_per_game_rank + away_goals_against_per_game_rank < 40
                    and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    + home_goals_against_per_game_rank + away_goals_against_per_game_rank
                    < 40 and total_goals < total
                then under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
over_defense_ranks_combined as(
    select
        'over defense ranks combined > 80' as criteria,
        total,
        sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    + home_goals_against_per_game_rank + away_goals_against_per_game_rank
                    > 80 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    + home_goals_against_per_game_rank + away_goals_against_per_game_rank
                    > 80 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    + home_goals_against_per_game_rank + away_goals_against_per_game_rank > 80
                    and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    + home_goals_against_per_game_rank + away_goals_against_per_game_rank > 80
                    and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    + home_goals_against_per_game_rank + away_goals_against_per_game_rank
                    > 80 and total_goals > total
                then over_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
over_offense_ranks_combined as(
    select
        'over offense ranks combined > 80' as criteria,
        total,
        sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    + home_goals_for_per_game_rank + away_goals_for_per_game_rank
                    > 80 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    + home_goals_for_per_game_rank + away_goals_for_per_game_rank
                    > 80 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    + home_goals_for_per_game_rank + away_goals_for_per_game_rank > 80
                    and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    + home_goals_for_per_game_rank + away_goals_for_per_game_rank > 80
                    and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    + home_goals_for_per_game_rank + away_goals_for_per_game_rank
                    > 80 and total_goals > total
                then over_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
under_offense_ranks_combined as(
    select
        'under offense ranks combined < 40' as criteria,
        total,
        sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    + home_goals_for_per_game_rank + away_goals_for_per_game_rank
                    < 40 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    + home_goals_for_per_game_rank + away_goals_for_per_game_rank
                    < 40 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    + home_goals_for_per_game_rank + away_goals_for_per_game_rank < 40
                    and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    + home_goals_for_per_game_rank + away_goals_for_per_game_rank < 40
                    and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    + home_goals_for_per_game_rank + away_goals_for_per_game_rank
                    < 40 and total_goals < total
                then under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
under_save_pct as(
    select
        'under save percent goals minus 0.75' as criteria,
        total,
        sum(
            case
                when ((o.home_sog_against_per_game + o.away_sog_for_per_game)/2 * (1 - s.home_save_percentage))
                    + ((o.away_sog_against_per_game + o.home_sog_for_per_game)/2 * (1 - s.home_save_percentage)) - o.total < -0.75
                    and o.total_goals < o.total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when ((o.home_sog_against_per_game + o.away_sog_for_per_game)/2 * (1 - s.home_save_percentage))
                    + ((o.away_sog_against_per_game + o.home_sog_for_per_game)/2 * (1 - s.home_save_percentage)) - o.total < -0.75
                    and o.total_goals > o.total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when ((o.home_sog_against_per_game + o.away_sog_for_per_game)/2 * (1 - s.home_save_percentage))
                    + ((o.away_sog_against_per_game + o.home_sog_for_per_game)/2 * (1 - s.home_save_percentage)) - o.total < -0.75
                    and o.total_goals != o.total
                then o.under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when ((o.home_sog_against_per_game + o.away_sog_for_per_game)/2 * (1 - s.home_save_percentage))
                    + ((o.away_sog_against_per_game + o.home_sog_for_per_game)/2 * (1 - s.home_save_percentage)) - o.total < -0.75
                    and o.total_goals != o.total
                then o.over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when ((o.home_sog_against_per_game + o.away_sog_for_per_game)/2 * (1 - s.home_save_percentage))
                    + ((o.away_sog_against_per_game + o.home_sog_for_per_game)/2 * (1 - s.home_save_percentage)) - o.total < -0.75
                    and o.total_goals < o.total
                then o.under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks as o inner join starter_stats as s
    on o.game_id = s.game_id
    group by total
),
over_save_pct as(
    select
        'over save percent plus 0.65 goals' as criteria,
        total,
        sum(
            case
                when ((o.home_sog_against_per_game + o.away_sog_for_per_game)/2 * (1 - s.home_save_percentage))
                    + ((o.away_sog_against_per_game + o.home_sog_for_per_game)/2 * (1 - s.home_save_percentage)) - o.total > 0.65
                    and o.total_goals < o.total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when ((o.home_sog_against_per_game + o.away_sog_for_per_game)/2 * (1 - s.home_save_percentage))
                    + ((o.away_sog_against_per_game + o.home_sog_for_per_game)/2 * (1 - s.home_save_percentage)) - o.total > 0.65
                    and o.total_goals > o.total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when ((o.home_sog_against_per_game + o.away_sog_for_per_game)/2 * (1 - s.home_save_percentage))
                    + ((o.away_sog_against_per_game + o.home_sog_for_per_game)/2 * (1 - s.home_save_percentage)) - o.total > 0.65
                    and o.total_goals != o.total
                then o.under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when ((o.home_sog_against_per_game + o.away_sog_for_per_game)/2 * (1 - s.home_save_percentage))
                    + ((o.away_sog_against_per_game + o.home_sog_for_per_game)/2 * (1 - s.home_save_percentage)) - o.total > 0.65
                    and o.total_goals != o.total
                then o.over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when ((o.home_sog_against_per_game + o.away_sog_for_per_game)/2 * (1 - s.home_save_percentage))
                    + ((o.away_sog_against_per_game + o.home_sog_for_per_game)/2 * (1 - s.home_save_percentage)) - o.total > 0.65
                    and o.total_goals > o.total
                then o.over_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks as o inner join starter_stats as s
    on o.game_id = s.game_id
    group by total
),
under_gaa as(
    select
        'under gaa minus 1 goal' as criteria,
        o.total,
        sum(
            case
                when s.home_gaa + s.away_gaa - o.total < -1
                    and o.total_goals < o.total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when s.home_gaa + s.away_gaa - o.total < -1
                    and o.total_goals > o.total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when s.home_gaa + s.away_gaa - o.total < -1
                    and o.total_goals != o.total
                then o.under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when s.home_gaa + s.away_gaa - o.total < -1
                    and o.total_goals != o.total
                then o.over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when s.home_gaa + s.away_gaa - o.total < -1
                    and o.total_goals < o.total
                then o.under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks as o inner join starter_stats as s
    on o.game_id = s.game_id
    group by o.total
),
over_gaa as(
    select
        'over gaa plus 0.5 goals' as criteria,
        o.total,
        sum(
            case
                when s.home_gaa + s.away_gaa - o.total > 0.5
                    and o.total_goals < o.total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when s.home_gaa + s.away_gaa - o.total > 0.5
                    and o.total_goals > o.total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when s.home_gaa + s.away_gaa - o.total > 0.5
                    and o.total_goals != o.total
                then o.under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when s.home_gaa + s.away_gaa - o.total > 0.5
                    and o.total_goals != o.total
                then o.over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when s.home_gaa + s.away_gaa - o.total > 0.5
                    and o.total_goals > o.total
                then o.over_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks as o inner join starter_stats as s
    on o.game_id = s.game_id
    group by o.total
),
over_shots_against_combined as(
    select
        'over shots against combined' as criteria,
        total,
        sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    > 42 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    > 42 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    > 42 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    > 42 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    > 42 and total_goals > total
                then over_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
under_shots_against_combined as(
    select
        'under shots against combined' as criteria,
        total,
        sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    < 21 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    < 21 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    < 21 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    < 21 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_sog_against_per_game_rank + away_sog_against_per_game_rank
                    < 21 and total_goals < total
                then under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
over_shots_against_individual as(
    select
        'over shots against individual' as criteria,
        total,
        sum(
            case
                when home_sog_against_per_game_rank > 21 and away_sog_against_per_game_rank
                    > 21 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_sog_against_per_game_rank > 21 and away_sog_against_per_game_rank
                    > 21 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_sog_against_per_game_rank > 21 and away_sog_against_per_game_rank
                    > 21 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_sog_against_per_game_rank > 21 and away_sog_against_per_game_rank
                    > 21 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_sog_against_per_game_rank > 21 and away_sog_against_per_game_rank
                    > 21 and total_goals > total
                then over_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
under_shots_against_individual as(
    select
        'under shots against individual' as criteria,
        total,
        sum(
            case
                when home_sog_against_per_game_rank < 11 and away_sog_against_per_game_rank
                    < 11 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_sog_against_per_game_rank < 11 and away_sog_against_per_game_rank
                    < 11 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_sog_against_per_game_rank < 11 and away_sog_against_per_game_rank
                    < 11 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_sog_against_per_game_rank < 11 and away_sog_against_per_game_rank
                    < 11 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_sog_against_per_game_rank < 11 and away_sog_against_per_game_rank
                    < 11 and total_goals < total
                then under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
over_goals_against_combined as(
    select
        'over goals against combined' as criteria,
        total,
        sum(
            case
                when home_goals_against_per_game_rank + away_goals_against_per_game_rank
                    > 42 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_goals_against_per_game_rank + away_goals_against_per_game_rank
                    > 42 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_goals_against_per_game_rank + away_goals_against_per_game_rank
                    > 42 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_goals_against_per_game_rank + away_goals_against_per_game_rank
                    > 42 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_goals_against_per_game_rank + away_goals_against_per_game_rank
                    > 42 and total_goals > total
                then over_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
under_goals_against_combined as(
    select
        'under goals against combined' as criteria,
        total,
        sum(
            case
                when home_goals_against_per_game_rank + away_goals_against_per_game_rank
                    < 21 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_goals_against_per_game_rank + away_goals_against_per_game_rank
                    < 21 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_goals_against_per_game_rank + away_goals_against_per_game_rank
                    < 21 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_goals_against_per_game_rank + away_goals_against_per_game_rank
                    < 21 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_goals_against_per_game_rank + away_goals_against_per_game_rank
                    < 21 and total_goals < total
                then under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
over_goals_against_individual as(
    select
        'over goals against individual' as criteria,
        total,
        sum(
            case
                when home_goals_against_per_game_rank > 21 and away_goals_against_per_game_rank
                    > 21 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_goals_against_per_game_rank > 21 and away_goals_against_per_game_rank
                    > 21 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_goals_against_per_game_rank > 21 and away_goals_against_per_game_rank
                    > 21 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_goals_against_per_game_rank > 21 and away_goals_against_per_game_rank
                    > 21 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_goals_against_per_game_rank > 21 and away_goals_against_per_game_rank
                    > 21 and total_goals > total
                then over_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
under_goals_against_individual as(
    select
        'under goals against individual' as criteria,
        total,
        sum(
            case
                when home_goals_against_per_game_rank < 11 and away_goals_against_per_game_rank
                    < 11 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_goals_against_per_game_rank < 11 and away_goals_against_per_game_rank
                    < 11 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_goals_against_per_game_rank < 11 and away_goals_against_per_game_rank
                    < 11 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_goals_against_per_game_rank < 11 and away_goals_against_per_game_rank
                    < 11 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_goals_against_per_game_rank < 11 and away_goals_against_per_game_rank
                    < 11 and total_goals < total
                then under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
over_goals_for_combined as(
    select
        'over goals for combined' as criteria,
        total,
        sum(
            case
                when home_goals_for_per_game_rank + away_goals_for_per_game_rank
                    > 47 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_goals_for_per_game_rank + away_goals_for_per_game_rank
                    > 47 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_goals_for_per_game_rank + away_goals_for_per_game_rank
                    > 47 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_goals_for_per_game_rank + away_goals_for_per_game_rank
                    > 47 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_goals_for_per_game_rank + away_goals_for_per_game_rank
                    > 47 and total_goals > total
                then over_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
under_goals_for_combined as(
    select
        'under goals for combined' as criteria,
        total,
        sum(
            case
                when home_goals_for_per_game_rank + away_goals_for_per_game_rank
                    < 17 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_goals_for_per_game_rank + away_goals_for_per_game_rank
                    < 17 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_goals_for_per_game_rank + away_goals_for_per_game_rank
                    < 17 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_goals_for_per_game_rank + away_goals_for_per_game_rank
                    < 17 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_goals_for_per_game_rank + away_goals_for_per_game_rank
                    < 17 and total_goals < total
                then under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
over_goals_for_individual as(
    select
        'over goals for individual' as criteria,
        total,
        sum(
            case
                when home_goals_for_per_game_rank < 11 and away_goals_for_per_game_rank
                    < 11 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_goals_for_per_game_rank < 11 and away_goals_for_per_game_rank
                    < 11 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_goals_for_per_game_rank < 11 and away_goals_for_per_game_rank
                    < 11 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_goals_for_per_game_rank < 11 and away_goals_for_per_game_rank
                    < 11 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_goals_for_per_game_rank < 11 and away_goals_for_per_game_rank
                    < 11 and total_goals > total
                then over_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
under_goals_for_individual as(
    select
        'under goals for individual' as criteria,
        total,
        sum(
            case
                when home_goals_for_per_game_rank > 21 and away_goals_for_per_game_rank
                    > 21 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_goals_for_per_game_rank > 21 and away_goals_for_per_game_rank
                    > 21 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_goals_for_per_game_rank > 21 and away_goals_for_per_game_rank
                    > 21 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_goals_for_per_game_rank > 21 and away_goals_for_per_game_rank
                    > 21 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_goals_for_per_game_rank > 21 and away_goals_for_per_game_rank
                    > 21 and total_goals < total
                then under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
over_shots_for_combined as(
    select
        'over shots for combined' as criteria,
        total,
        sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    > 47 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    > 47 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    > 47 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    > 47 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    > 47 and total_goals > total
                then over_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
under_shots_for_combined as(
    select
        'under shots for combined' as criteria,
        total,
        sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    < 17 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    < 17 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    < 17 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    < 17 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_sog_for_per_game_rank + away_sog_for_per_game_rank
                    < 17 and total_goals < total
                then under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
over_shots_for_individual as(
    select
        'over shots for individual' as criteria,
        total,
        sum(
            case
                when home_sog_for_per_game_rank < 11 and away_sog_for_per_game_rank
                    < 11 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_sog_for_per_game_rank < 11 and away_sog_for_per_game_rank
                    < 11 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_sog_for_per_game_rank < 11 and away_sog_for_per_game_rank
                    < 11 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_sog_for_per_game_rank < 11 and away_sog_for_per_game_rank
                    < 11 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_sog_for_per_game_rank < 11 and away_sog_for_per_game_rank
                    < 11 and total_goals > total
                then over_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
under_shots_for_individual as(
    select
        'under shots for individual' as criteria,
        total,
        sum(
            case
                when home_sog_for_per_game_rank > 21 and away_sog_for_per_game_rank
                    > 21 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_sog_for_per_game_rank > 21 and away_sog_for_per_game_rank
                    > 21 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_sog_for_per_game_rank > 21 and away_sog_for_per_game_rank
                    > 21 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_sog_for_per_game_rank > 21 and away_sog_for_per_game_rank
                    > 21 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_sog_for_per_game_rank > 21 and away_sog_for_per_game_rank
                    > 21 and total_goals < total
                then under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
over_total_goals_combined as(
    select
        'over total goals combined' as criteria,
        total,
        sum(
            case
                when home_total_goals_per_game_rank + away_total_goals_per_game_rank
                    > 42 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_total_goals_per_game_rank + away_total_goals_per_game_rank
                    > 42 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_total_goals_per_game_rank + away_total_goals_per_game_rank
                    > 42 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_total_goals_per_game_rank + away_total_goals_per_game_rank
                    > 42 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_total_goals_per_game_rank + away_total_goals_per_game_rank
                    > 42 and total_goals > total
                then over_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
under_total_goals_combined as(
    select
        'under total goals combined' as criteria,
        total,
        sum(
            case
                when home_total_goals_per_game_rank + away_total_goals_per_game_rank
                    < 21 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_total_goals_per_game_rank + away_total_goals_per_game_rank
                    < 21 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_total_goals_per_game_rank + away_total_goals_per_game_rank
                    < 21 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_total_goals_per_game_rank + away_total_goals_per_game_rank
                    < 21 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_total_goals_per_game_rank + away_total_goals_per_game_rank
                    < 21 and total_goals < total
                then under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
over_total_goals_individual as(
    select
        'over total goals individual' as criteria,
        total,
        sum(
            case
                when home_total_goals_per_game_rank > 21 and away_total_goals_per_game_rank
                    > 21 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_total_goals_per_game_rank > 21 and away_total_goals_per_game_rank
                    > 21 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_total_goals_per_game_rank > 21 and away_total_goals_per_game_rank
                    > 21 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_total_goals_per_game_rank > 21 and away_total_goals_per_game_rank
                    > 21 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_total_goals_per_game_rank > 21 and away_total_goals_per_game_rank
                    > 21 and total_goals > total
                then over_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
under_total_goals_individual as(
    select
        'under total_goals individual' as criteria,
        total,
        sum(
            case
                when home_total_goals_per_game_rank < 11 and away_total_goals_per_game_rank
                    < 11 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_total_goals_per_game_rank < 11 and away_total_goals_per_game_rank
                    < 11 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_total_goals_per_game_rank < 11 and away_total_goals_per_game_rank
                    < 11 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_total_goals_per_game_rank < 11 and away_total_goals_per_game_rank
                    < 11 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_total_goals_per_game_rank < 11 and away_total_goals_per_game_rank
                    < 11 and total_goals < total
                then under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
over_total_shots_combined as(
    select
        'over total shots combined' as criteria,
        total,
        sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank
                    > 42 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank
                    > 42 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank
                    > 42 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank
                    > 42 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank
                    > 42 and total_goals > total
                then over_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
under_total_shots_combined as(
    select
        'under total shots combined' as criteria,
        total,
        sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank
                    < 21 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank
                    < 21 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank
                    < 21 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank
                    < 21 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_total_sog_per_game_rank + away_total_sog_per_game_rank
                    < 21 and total_goals < total
                then under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
over_total_shots_individual as(
    select
        'over total shots individual' as criteria,
        total,
        sum(
            case
                when home_total_sog_per_game_rank > 21 and away_total_sog_per_game_rank
                    > 21 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_total_sog_per_game_rank > 21 and away_total_sog_per_game_rank
                    > 21 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_total_sog_per_game_rank > 21 and away_total_sog_per_game_rank
                    > 21 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_total_sog_per_game_rank > 21 and away_total_sog_per_game_rank
                    > 21 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_total_sog_per_game_rank > 21 and away_total_sog_per_game_rank
                    > 21 and total_goals > total
                then over_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
under_total_shots_individual as(
    select
        'under total_shots individual' as criteria,
        total,
        sum(
            case
                when home_total_sog_per_game_rank < 11 and away_total_sog_per_game_rank
                    < 11 and total_goals < total
                then 1
                else 0
            end
        ) as under_count,
        sum(
            case
                when home_total_sog_per_game_rank < 11 and away_total_sog_per_game_rank
                    < 11 and total_goals > total
                then 1
                else 0
            end
        ) as over_count,
        under_count + over_count as games_count,
        round((under_count / nullif(games_count,0))*100, 2) as under_pct,
        round((over_count / nullif(games_count,0))*100, 2) as over_pct,
        round(sum(
            case
                when home_total_sog_per_game_rank < 11 and away_total_sog_per_game_rank
                    < 11 and total_goals != total
                then under_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_under_price,
        round(sum(
            case
                when home_total_sog_per_game_rank < 11 and away_total_sog_per_game_rank
                    < 11 and total_goals != total
                then over_price
                else 0
            end
        ) / nullif(games_count,0),2) as avg_over_price,
        sum(
            case
                when home_total_sog_per_game_rank < 11 and away_total_sog_per_game_rank
                    < 11 and total_goals < total
                then under_price
                else 0
            end
        ) as units_won,
        round((units_won - games_count)/nullif(games_count,0)*100,2) as roi
    from odds_ranks
    group by total
),
combined as(
select * from under_total_goals
union
select * from over_total_goals
union
select * from under_totals_ranks_combined
union
select * from over_totals_ranks_combined
union
select * from under_defense_ranks_combined
union
select * from over_defense_ranks_combined
union
select * from under_offense_ranks_combined
union
select * from over_offense_ranks_combined
union
select * from under_save_pct
union
select * from over_save_pct
union
select * from under_gaa
union
select * from over_gaa
union
select * from over_shots_against_combined
union
select * from under_shots_against_combined
union
select * from over_goals_against_combined
union
select * from under_goals_against_combined
union
select * from over_goals_for_combined
union
select * from under_goals_for_combined
union
select * from over_shots_for_combined
union
select * from under_shots_for_combined
union
select * from over_total_goals_combined
union
select * from under_total_goals_combined
union
select * from under_total_shots_combined
union
select * from over_total_shots_combined
)
select * from combined
where games_count > 10
order by criteria, total desc
