with weekly_orders as (

    select *
    from {{ ref('weekly_orders_summary') }}

),

weekly_margin as (

    select *
    from {{ ref('weekly_margin_summary') }}

),

weekly_change as (

    select *
    from {{ ref('weekly_revenue_change_analysis') }}

),

guardrails as (

    select *
    from {{ ref('guardrail_evaluation') }}

),

guardrail_rollup as (

    select
        week_start_date,

        count_if(guardrail_status = 'fail') as guardrails_failed,
        count_if(guardrail_status = 'pass') as guardrails_passed,

        max(case when blocks_growth_actions and guardrail_status = 'fail' then 1 else 0 end) as is_blocked,

        listagg(case when guardrail_status = 'fail' then guardrail_key end, ', ')
            within group (order by guardrail_key) as failing_guardrails

    from guardrails
    group by 1

),

recommendation as (

    select *
    from {{ ref('action_recommendations') }}

),

final as (

    select
        w.week_start_date,

        w.total_orders,
        w.total_revenue,
        w.avg_order_value,
        w.cancellation_rate,

        m.total_contribution_margin,
        m.contribution_margin_pct,

        c.revenue_change,
        c.revenue_change_pct,
        c.orders_change,
        c.aov_change,
        c.cancellation_change,
        c.margin_change,

        g.guardrails_failed,
        g.guardrails_passed,
        g.is_blocked,
        g.failing_guardrails,

        r.proposed_action,
        r.recommendation_status,
        r.explanation

    from weekly_orders w
    left join weekly_margin m
        on w.week_start_date = m.week_start_date
    left join weekly_change c
        on w.week_start_date = c.week_start_date
    left join guardrail_rollup g
        on w.week_start_date = g.week_start_date
    left join recommendation r
        on w.week_start_date = r.week_start_date

)

select *
from final
order by week_start_date
