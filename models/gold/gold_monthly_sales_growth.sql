with monthly as (
    select
        item_created_month as month,
        count(distinct order_id) as orders,
        count(*) as items_sold,
        sum(case when item_status not in ('cancelled', 'returned') then sale_price else 0 end) as net_revenue,
        sum(case when item_status not in ('cancelled', 'returned') then profit else 0 end) as net_profit,
        sum(is_cancelled) as cancelled_items,   
        sum(is_returned) as returned_items
    from {{ ref('gold_obt') }}
    group by 1
)

select
    month,
    to_char(month, 'Mon YYYY') as month_year,
    orders,
    items_sold,
    cancelled_items,
    returned_items,
    items_sold - cancelled_items - returned_items as kept_items,
    net_revenue,
    net_profit,
    round(100 * net_profit / nullif(net_revenue, 0), 2) as profit_margin_pct,
    round(100 * cancelled_items / items_sold, 2) as cancellation_rate_pct,
    round(100 * returned_items / items_sold, 2) as return_rate_pct,
    lag(net_revenue) over (order by month) as prev_month_revenue,
    round(100 * (net_revenue - lag(net_revenue) over (order by month))
          / nullif(lag(net_revenue) over (order by month), 0), 2) as mom_growth_pct,
    sum(net_revenue) over (order by month) as cumulative_revenue
from monthly
order by month