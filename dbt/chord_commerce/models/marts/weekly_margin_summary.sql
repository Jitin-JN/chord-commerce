with orders as (

    select *
    from {{ ref('fct_orders') }}
    where order_purchase_ts is not null

),

weekly as (

    select
        date_trunc('week', cast(order_purchase_ts as date)) as week_start_date,

        count(*) as total_orders,
        sum(order_gross_revenue) as total_revenue,

        sum(order_contribution_margin) as total_contribution_margin,

        (
          sum(order_contribution_margin)
          / nullif(sum(order_gross_revenue), 0)
        ) as contribution_margin_pct

    from orders
    group by 1

)

select *
from weekly
order by week_start_date
