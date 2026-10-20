SELECT *
FROM {{ source('staging', 'distribution_centers') }}