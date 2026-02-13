with orders as (

    select *
    from {{ ref('fct_orders') }}

),

daily as (

    select
        cast(order_purchase_ts as date) as order_date,

        count(*) as orders,
        sum(order_gross_revenue) as gross_revenue,
        avg(order_gross_revenue) as aov,

        sum(case when order_status = 'delivered' then 1 else 0 end) as delivered_orders,
        sum(case when order_status = 'canceled' then 1 else 0 end) as canceled_orders

    from orders
    where order_purchase_ts is not null
    group by 1

)

select *
from daily
order by order_date
