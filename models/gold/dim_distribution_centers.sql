select
    id as distribution_center_id,
    name as distribution_center_name,
    latitude,
    longitude
from {{ ref('silver_distribution_centers') }}

union all

select 8, 'Unknown (center 8)', null, null