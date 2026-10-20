SELECT *
FROM {{ source('staging', 'inventory_items') }}