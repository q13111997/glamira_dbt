SELECT
    SAFE_CAST(user_id_db AS INT64) AS user_id_db
    ,LOWER(email_address) AS email_address
FROM {{ source('glamira_raw', 'summary') }}
WHERE collection = 'checkout_success'