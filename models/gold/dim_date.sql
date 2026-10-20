with dates as (
    select dateadd(day, seq4(), '2019-01-01'::date) as date_day
    from table(generator(rowcount => 2557))
)
select
    date_day                         as date_key,
    date_trunc('month', date_day)    as month_start,
    to_char(date_day, 'Mon YYYY')    as month_year,
    year(date_day)                   as year,
    quarter(date_day)                as quarter,
    month(date_day)                  as month_number,
    dayname(date_day)                as day_name,
    dayofweekiso(date_day) in (6, 7) as is_weekend
from dates