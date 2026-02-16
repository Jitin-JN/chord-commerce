with weekly_orders as (

    select *
    from {{ ref('weekly_orders_summary') }}

),

weekly_margin as (

    select *
    from {{ ref('weekly_margin_summary') }}

),

joined as (

    select
        w.week_start_date,
        w.total_orders,
        w.total_revenue,
        w.avg_order_value,
        w.cancellation_rate,
        m.contribution_margin_pct

    from weekly_orders w
    left join weekly_margin m
        on w.week_start_date = m.week_start_date

),

with_lag as (

    select
        week_start_date,

        total_orders,
        lag(total_orders) over (order by week_start_date) as prev_orders,

        total_revenue,
        lag(total_revenue) over (order by week_start_date) as prev_revenue,

        avg_order_value,
        lag(avg_order_value) over (order by week_start_date) as prev_aov,

        cancellation_rate,
        lag(cancellation_rate) over (order by week_start_date) as prev_cancellation,

        contribution_margin_pct,
        lag(contribution_margin_pct) over (order by week_start_date) as prev_margin

    from joined

),

final as (

    select
        week_start_date,

        total_orders,
        total_revenue,
        avg_order_value,
        cancellation_rate,
        contribution_margin_pct,

        (total_revenue - prev_revenue) as revenue_change,
        (total_revenue - prev_revenue) / nullif(prev_revenue, 0) as revenue_change_pct,

        (total_orders - prev_orders) as orders_change,
        (avg_order_value - prev_aov) as aov_change,
        (cancellation_rate - prev_cancellation) as cancellation_change,
        (contribution_margin_pct - prev_margin) as margin_change

    from with_lag

)

select *
from final
order by week_start_date
