with source as (
    select * from {{ref("bronze_distribution_centers")}}
),
dedup as (
    select * from source
    where id is not null
    qualify row_number() over (
        partition by id order by id desc 
    ) = 1
), 
cleaned as (
    select 
        id,
    coalesce(nullif(trim(name),''), 'NA') as NAME,
    latitude AS LATITUDE,
    longitude AS LONGITUDE
from dedup
) 
select * from cleaned 
