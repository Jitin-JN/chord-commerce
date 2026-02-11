with source as (

    select * 
    from {{ source('raw', 'OLIST_ORDERS_DATASET') }}

),

renamed as (

    select
        order_id,
        customer_id,
        order_status,

        order_purchase_timestamp as order_purchase_ts,
        order_approved_at as order_approved_ts,
        order_delivered_carrier_date as order_delivered_carrier_ts,
        order_delivered_customer_date as order_delivered_customer_ts,
        order_estimated_delivery_date as order_estimated_delivery_ts

    from source

)

select * from renamed
