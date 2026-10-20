SELECT *
FROM {{ source('staging', 'users') }}

