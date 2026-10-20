with source as (
    select * from {{ref("bronze_inventory_items")}}
),

dedup as (
    select * from source
    where id is not null
    qualify row_number() over (
        partition by id order by created_at nulls last 
    ) = 1
),
cleaned as (
    select id,
           product_id,
           trim(product_name) as product_name,
           trim(product_brand) as product_brand,
           trim(product_category) as product_category,
           trim(product_department) as product_department,
           sold_at,
           product_retail_price,
           cost,
           trim(product_sku) as product_sku,
           product_distribution_center_id
    from dedup
)
select * from cleaned