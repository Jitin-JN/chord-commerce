with orders as (

    select *
    from {{ ref('fct_orders') }}

),

recon as (

    select
        order_id,
        order_purchase_ts,
        order_status,

        order_gross_revenue,
        order_payment_total,

        (order_gross_revenue - order_payment_total) as revenue_minus_payment,

        case
            when order_payment_total is null then 'missing_payment'
            when abs(order_gross_revenue - order_payment_total) < 0.01 then 'match'
            when abs(order_gross_revenue - order_payment_total) < 5 then 'small_diff'
            else 'large_diff'
        end as recon_status

    from orders

)

select *
from recon
