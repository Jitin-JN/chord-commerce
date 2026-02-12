with source as (

    select *
    from {{ source('raw', 'OLIST_ORDER_ITEMS_DATASET') }}

)

select
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
from source
