with source as (
    select * from {{ ref('bronze_orders') }}
),

deduped as (
    select *
    from source
    where order_id is not null
    qualify row_number() over (
        partition by order_id
        order by created_at desc nulls last
    ) = 1
),

cleaned as (
    select
        order_id,
        user_id,
        lower(trim(status)) as status,
        case
            when upper(trim(gender)) = 'F' then 'Female'
            when upper(trim(gender)) = 'M' then 'Male'
            else 'Unknown'
        end as gender,
        num_of_item,
        created_at
    from deduped
)

select * from cleaned