select
    oi.id                   as order_item_id,
    oi.order_id,
    oi.user_id,
    oi.product_id,
    p.distribution_center_id,
    oi.inventory_item_id,
    oi.status as item_status,
    oi.created_at as item_created_at,
    oi.created_at::date as item_created_date,
    oi.shipped_at,
    oi.delivered_at,
    oi.returned_at,
    oi.sale_price,
    p.cost,
    oi.sale_price - p.cost  as profit
from {{ ref('silver_order_items') }} oi
left join {{ ref('silver_products') }} p on oi.product_id = p.id