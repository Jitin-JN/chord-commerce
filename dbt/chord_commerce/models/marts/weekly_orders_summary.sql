with daily as (

    select *
    from {{ ref('orders_kpis') }}

),

weekly as (

    select
        date_trunc('week', order_date) as week_start_date,

        sum(orders) as total_orders,
        sum(gross_revenue) as total_revenue,
        sum(gross_revenue) / nullif(sum(orders), 0) as avg_order_value,


        sum(canceled_orders)::float / nullif(sum(orders), 0) as cancellation_rate

    from daily
    group by 1

)

select *
from weekly
order by week_start_date
