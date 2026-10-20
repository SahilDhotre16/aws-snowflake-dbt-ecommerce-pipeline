with customer as (
    select
        user_id,
        max(item_created_at) as last_purchase_at,
        count(distinct order_id) as frequency,
        sum(sale_price) as monetary
    from {{ ref('gold_obt') }}
    where item_status not in ('cancelled', 'returned')
      and user_id is not null
    group by user_id
),

scored as (
    select
        *,
        ntile(5) over (order by last_purchase_at) as recency_score,
        ntile(5) over (order by frequency)        as frequency_score,
        ntile(5) over (order by monetary)         as monetary_score
    from customer
)

select
    user_id,
    last_purchase_at,
    to_char(last_purchase_at, 'Mon YYYY') as month_year,
    frequency,
    round(monetary, 2) as monetary,
    recency_score,
    frequency_score,
    monetary_score,
    case
        when recency_score >= 4 and frequency_score >= 4 then 'Champions'
        when recency_score >= 4 and frequency_score <= 2 then 'New / Recent'
        when frequency_score >= 4 then 'Loyal'
        when recency_score <= 2 and frequency_score >= 3 then 'At risk'
        when recency_score <= 2 then 'Lost'
        else 'Regular'
    end as segment
from scored