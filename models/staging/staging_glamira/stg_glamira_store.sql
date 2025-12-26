SELECT DISTINCT
    store_id
    ,'Store '||store_id AS store_name
FROM {{ source('glamira_raw', 'summary') }}
WHERE collection = 'checkout_success'
ORDER BY store_id