with g as (

    select *
    from {{ ref('guardrail_evaluation') }}

),

guardrail_summary as (

    select
        week_start_date,

        
        max(case when blocks_growth_actions then 1 else 0 end) as is_blocked,

        
        listagg(
            case when guardrail_status = 'fail' then guardrail_key end,
            ', '
        ) within group (order by guardrail_key) as failing_guardrails

    from g
    group by 1

),

kpis as (

    select *
    from {{ ref('weekly_orders_summary') }}
    qualify week_start_date = max(week_start_date) over ()

),

final as (

    select
        k.week_start_date,

        
        'increase_paid_spend' as proposed_action,

        case
            when gs.is_blocked = 1 then 'blocked'
            else 'recommended'
        end as recommendation_status,

        
        case
            when gs.is_blocked = 1 then
                'Action blocked due to failing guardrails: ' || gs.failing_guardrails
            else
                'Guardrails passed. Based on stable cancellation rate and data quality, scaling is safe.'
        end as explanation,

        
        k.total_orders,
        k.total_revenue,
        k.avg_order_value,
        k.cancellation_rate,

        gs.is_blocked,
        gs.failing_guardrails

    from kpis k
    left join guardrail_summary gs
        on k.week_start_date = gs.week_start_date

)

select *
from final
