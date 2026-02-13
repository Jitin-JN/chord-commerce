with orders as (

    select *
    from {{ ref('stg_orders') }}

),

items_agg as (

    select
        order_id,

        count(*) as number_of_items,

        sum(item_gross_revenue) as order_gross_revenue,

        sum(contribution_margin) as order_contribution_margin,
        (
          sum(contribution_margin)
          / nullif(sum(item_gross_revenue), 0)
        ) as order_contribution_margin_pct

    from {{ ref('fct_order_items') }}
    group by 1

),


payments_agg as (

    select
        order_id,
        sum(payment_value) as order_payment_total
    from {{ ref('stg_payments') }}
    group by 1

),

final as (

    select
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchase_ts,

        coalesce(ia.number_of_items, 0) as number_of_items,
        coalesce(ia.order_gross_revenue, 0) as order_gross_revenue,
        coalesce(pa.order_payment_total, 0) as order_payment_total,

        coalesce(ia.order_contribution_margin, 0) as order_contribution_margin,
        case
            when coalesce(ia.order_gross_revenue, 0) = 0 then null
            else coalesce(ia.order_contribution_margin, 0) / nullif(coalesce(ia.order_gross_revenue, 0), 0)
        end as order_contribution_margin_pct,


        coalesce(ia.order_gross_revenue, 0) - coalesce(pa.order_payment_total, 0) as revenue_minus_payment

    from orders o
    left join items_agg ia
        on o.order_id = ia.order_id
    left join payments_agg pa
        on o.order_id = pa.order_id

)

select *
from final
