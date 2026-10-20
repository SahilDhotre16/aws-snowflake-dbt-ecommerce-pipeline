with brand_category as (
    select
        category,
        brand,
        count(*) as items_sold,
        sum(is_cancelled) as cancelled_items,
        sum(is_returned) as returned_items,
        sum(case when item_status not in ('cancelled', 'returned') then sale_price else 0 end) as net_revenue,
        sum(case when item_status not in ('cancelled', 'returned') then profit else 0 end) as net_profit
    from {{ ref('gold_obt') }}
    where category is not null
    group by 1, 2
)

select
    category,
    brand,
    items_sold,
    cancelled_items,
    returned_items,
    net_revenue,
    net_profit,
    round(100 * net_profit / nullif(net_revenue, 0), 2) as profit_margin_pct,
    round(100 * cancelled_items / items_sold, 2) as cancellation_rate_pct,
    round(100 * returned_items / items_sold, 2) as return_rate_pct,
    rank() over (partition by category order by net_revenue desc) as brand_rank_in_category,
    rank() over (order by net_revenue desc) as overall_rank,
    round(100 * net_revenue / sum(net_revenue) over (partition by category), 2) as pct_of_category_revenue
from brand_category
order by category, brand_rank_in_category