select
    id as user_id,
    first_name,
    last_name,
    email,
    gender,
    age,
    country,
    state,
    city,
    postal_code,
    latitude,
    longitude,
    traffic_source,
    created_at as user_created_at
from {{ ref('silver_users') }}