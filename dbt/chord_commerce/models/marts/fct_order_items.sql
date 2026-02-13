with order_items as (

    select *
    from {{ ref('stg_order_items') }}

),

orders as (

    select *
    from {{ ref('stg_orders') }}

),

customers as (

    select *
    from {{ ref('stg_customers') }}

),

products as (

    select *
    from {{ ref('stg_products') }}

),

category_translation as (

    select *
    from {{ ref('stg_product_category_translation') }}

),

final as (

    select
        
        oi.order_id,
        oi.order_item_id,

        o.customer_id,
        c.customer_unique_id,
        oi.product_id,
        oi.seller_id,

        o.order_status,
        o.order_purchase_ts,

        p.product_category_name,
        ct.product_category_name_english as product_category_name_en,

        oi.price as item_price,
        oi.freight_value as item_freight_value,
        (oi.price + oi.freight_value) as item_gross_revenue,

        -- simulated cost fields (since Olist does not include real costs)
        (oi.price * 0.60) as estimated_cogs,
        (oi.price * 0.03) as estimated_payment_fee,

        (oi.price + oi.freight_value)
          - (oi.price * 0.60)
          - (oi.price * 0.03)
        as contribution_margin,

        (
          (
            (oi.price + oi.freight_value)
            - (oi.price * 0.60)
            - (oi.price * 0.03)
          )
          / nullif((oi.price + oi.freight_value), 0)
        ) as contribution_margin_pct

    from order_items oi

    left join orders o
        on oi.order_id = o.order_id

    left join customers c
        on o.customer_id = c.customer_id

    left join products p
        on oi.product_id = p.product_id

    left join category_translation ct
        on p.product_category_name = ct.product_category_name

)

select *
from final
