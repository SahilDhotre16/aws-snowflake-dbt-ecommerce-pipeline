with items as (
    select
        order_id,
        count(*)        as items_in_order,
        sum(sale_price) as order_value
    from {{ ref('silver_order_items') }}
    group by 1
)
select
    o.order_id,
    o.user_id,
    o.status as order_status,
    o.created_at as order_created_at,
    o.created_at::date as order_created_date,
    o.num_of_item,
    i.items_in_order,
    i.order_value
from {{ ref('silver_orders') }} o
left join items i on o.order_id = i.order_id