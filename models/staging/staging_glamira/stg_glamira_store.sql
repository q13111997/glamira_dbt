SELECT DISTINCT
    CAST(store_id AS INT64) AS store_id
    ,'Store '||store_id AS store_name
FROM {{ source('glamira_raw', 'summary') }}
WHERE collection = 'checkout_success'