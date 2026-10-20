with source as (
    select * from {{ ref('bronze_users') }}
),

deduped as (
    select *
    from source
    where id is not null
    qualify row_number() over (
        partition by id
        order by created_at desc nulls last
    ) = 1
),

cleaned as(
select 
    id,
    initcap(trim(first_name)) as FIRST_NAME,
    initcap(trim(last_name)) as LAST_NAME,
    lower(trim(email)) as email ,
    age,
    CASE
      WHEN (TRIM(gender)) = 'F' THEN 'Female'
      WHEN (TRIM(gender)) = 'M' THEN 'Male'
      ELSE 'Unknown'
    END AS GENDER,
    trim(state) as state,
    trim(street_address) as STREET_ADDRESS,
    trim(postal_code) as POSTAL_CODE,
    trim(city) as CITY,
    trim(country) as COUNTRY,
    latitude,
    longitude,
    lower(trim(traffic_source)) as TRAFFIC_SOURCE,
    created_at
    from deduped
)

select * from cleaned