SELECT *
FROM {{ source('staging', 'orders') }}