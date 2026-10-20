SELECT *
FROM {{ source('staging', 'products') }}