with source as ( 
    select * from {{ ref('bronze_order_items')}}
),

dedup as (
        select * from source
        where id is not null
        qualify row_number() over(
            partition by id 
            order by created_at desc nulls last 
        ) = 1
),
cleaned as (
    select 
        id,
        order_id,
        user_id,
        product_id,
        inventory_item_id,
        lower(trim(status)) as status,
        sale_price,
        created_at,
        shipped_at,
        delivered_at,
        returned_at
    from dedup
)
select* from cleaned