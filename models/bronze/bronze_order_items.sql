SELECT *
FROM {{ source('staging', 'order_items') }}