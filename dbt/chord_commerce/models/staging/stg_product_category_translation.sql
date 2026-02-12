with source as (

    select *
    from {{ source('raw', 'PRODUCT_CATEGORY_NAME_ENGLISH') }}

)

select
    product_category_name,
    product_category_name_english
from source
