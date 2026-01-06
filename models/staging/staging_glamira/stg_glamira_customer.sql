WITH stg_customer__source AS (
    SELECT *
    FROM {{ source('glamira_raw', 'summary') }}
    WHERE collection = 'checkout_success'
),
stg_customer__cast_type AS (
    SELECT
        SAFE_CAST(user_id_db AS INT64) AS user_id_db
        ,LOWER(email_address) AS email_address
    FROM stg_customer__source
)
SELECT
    user_id_db
    ,COALESCE(email_address,'Unknown') AS email_address
FROM stg_customer__cast_type
WHERE user_id_db IS NOT NULL