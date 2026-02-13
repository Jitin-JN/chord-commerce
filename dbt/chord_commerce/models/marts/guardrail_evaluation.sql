with latest_week as (

    select *
    from {{ ref('weekly_orders_summary') }}
    qualify week_start_date = max(week_start_date) over ()

),

recon_rates as (

    -- Calculate mismatch rates per week using order_revenue_reconciliation
    select
        date_trunc('week', cast(order_purchase_ts as date)) as week_start_date,

        count(*) as orders_with_purchase_ts,
        sum(case when recon_status = 'large_diff' then 1 else 0 end) as large_diff_orders,
        sum(case when recon_status = 'missing_payment' then 1 else 0 end) as missing_payment_orders,

        (sum(case when recon_status = 'large_diff' then 1 else 0 end)::float
          / nullif(count(*), 0)
        ) as large_diff_rate

    from {{ ref('order_revenue_reconciliation') }}
    where order_purchase_ts is not null
    group by 1

),

latest_recon as (

    select *
    from recon_rates
    qualify week_start_date = max(week_start_date) over ()

),

margin_rates as (

    select
        date_trunc('week', cast(order_purchase_ts as date)) as week_start_date,

        (
          sum(order_contribution_margin)
          / nullif(sum(order_gross_revenue), 0)
        ) as contribution_margin_pct

    from {{ ref('fct_orders') }}
    where order_purchase_ts is not null
    group by 1

),

latest_margin as (

    select *
    from margin_rates
    qualify week_start_date = max(week_start_date) over ()

),


metrics as (

    select
        lw.week_start_date,
        lw.total_orders,
        lw.total_revenue,
        lw.avg_order_value,
        lw.cancellation_rate,

        lr.large_diff_orders,
        lr.missing_payment_orders,
        lr.large_diff_rate,

        mgn.contribution_margin_pct

    from latest_week lw
    left join latest_recon lr
      on lw.week_start_date = lr.week_start_date
    left join latest_margin mgn
      on lw.week_start_date = mgn.week_start_date



),


guardrails as (

    select *
    from {{ ref('context_guardrails') }}

),

final as (

    select
        g.guardrail_key,
        g.guardrail_name,
        g.description,
        g.severity,
        g.applies_to,

        m.week_start_date,

        m.total_orders,
        m.cancellation_rate,
        m.large_diff_rate,

        m.contribution_margin_pct,

        
        case
            when g.guardrail_key = 'revenue_payment_mismatch'
                and coalesce(m.large_diff_rate, 0) > 0.01
                then 'fail'
            when g.guardrail_key = 'high_cancellation_rate'
                and coalesce(m.cancellation_rate, 0) > 0.03
                then 'fail'
            when g.guardrail_key = 'low_data_coverage'
                and coalesce(m.total_orders, 0) < 50
                then 'fail'
            when g.guardrail_key = 'low_contribution_margin'
                and (m.contribution_margin_pct is null or m.contribution_margin_pct < 0.15)
                then 'fail'
            else 'pass'
        end as guardrail_status,

        case
            when (
                (g.guardrail_key = 'revenue_payment_mismatch' and coalesce(m.large_diff_rate, 0) > 0.01)
                or (g.guardrail_key = 'high_cancellation_rate' and coalesce(m.cancellation_rate, 0) > 0.03)
                or (g.guardrail_key = 'low_contribution_margin' and (m.contribution_margin_pct is null or m.contribution_margin_pct < 0.15))
            )
            then true
            else false
        end as blocks_growth_actions

    from guardrails g
    cross join metrics m

)

select *
from final
order by severity desc, guardrail_key
