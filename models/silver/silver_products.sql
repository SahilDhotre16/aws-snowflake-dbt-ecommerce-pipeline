with source as (
    select * from {{ref ('bronze_products')}}
),

dedup as(
    select * from source
    where id is not null
    qualify row_number() over (
        partition by id order by id 
    ) = 1
),
cleaned as (
        select 
            id,
            COALESCE(NULLIF(TRIM(name), ''), 'NA') AS NAME ,
            TRIM(brand) as BRAND,
            TRIM(category) as CATEGORY,
            TRIM(department) as DEPARTMENT,
            TRIM(sku)  as SKU,
            cost,
            retail_price,
            distribution_center_id
        from dedup
)
select * from cleaned