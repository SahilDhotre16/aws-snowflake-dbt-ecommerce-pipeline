with order_items as (
    select * from {{ ref('silver_order_items') }}
),

orders as (
    select * from {{ ref('silver_orders') }}
),

users as (
    select * from {{ ref('silver_users') }}
),

products as (
    select * from {{ ref('silver_products') }}
),

distribution_centers as (
    select * from {{ ref('silver_distribution_centers') }}
),

obt as (
    select
        oi.id as order_item_id,
        oi.order_id,
        oi.user_id,
        oi.product_id,
        oi.inventory_item_id,
        oi.status as item_status,
        oi.sale_price,
        oi.created_at as item_created_at,
        date_trunc('month', oi.created_at) as item_created_month,
        oi.shipped_at,
        oi.delivered_at,
        oi.returned_at,
        o.status  as order_status,
        o.created_at as order_created_at,
        o.num_of_item,
        u.gender,
        u.age,
        u.country,
        u.state,
        u.city,
        u.traffic_source,
        u.created_at as user_created_at,
        p.name as product_name,
        p.brand,
        p.category,
        p.department,
        p.cost,
        p.retail_price,
        p.distribution_center_id,
        coalesce(d.name, 'Unknown (center 8)') as distribution_center_name,

        oi.sale_price - p.cost as profit,

        case when lower(oi.status) = 'returned'  then 1 else 0 end as is_returned,
        case when lower(oi.status) = 'cancelled' then 1 else 0 end as is_cancelled,
        datediff('day', oi.created_at, oi.shipped_at)   as days_to_ship,
        datediff('day', oi.shipped_at, oi.delivered_at) as days_to_deliver

    from order_items oi
    left join orders o
    on oi.order_id = o.order_id
    left join users u 
    on oi.user_id = u.id
    left join products p
    on oi.product_id = p.id
    left join distribution_centers d 
    on p.distribution_center_id = d.id
)

select * from obt