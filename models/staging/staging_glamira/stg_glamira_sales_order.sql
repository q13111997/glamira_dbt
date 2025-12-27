SELECT
    CAST(user_id_db AS INT64) AS user_id_db
    ,LOWER(email_address) AS email_address
    ,ip
    ,CAST(FORMAT_DATE('%Y%m%d',DATE(TIMESTAMP_SECONDS(time_stamp))) AS INT64) AS date_id
    ,CAST(store_id AS INT64) AS store_id
    ,CAST(cp.product_id AS INT64) AS product_id
    ,opt.option_label
    ,opt.value_label
    ,CAST(order_id AS INT64) AS order_id
    ,PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', local_time) AS order_ts_utc
    ,cp.currency
    ,CAST(cp.price AS NUMERIC) AS price
    ,CAST(cp.amount AS NUMERIC) AS quantity
    ,COALESCE(CAST(cp.price AS NUMERIC),0) * COALESCE(CAST(cp.amount AS NUMERIC),0) AS revenue
FROM {{ source('glamira_raw', 'summary') }}
CROSS JOIN UNNEST(cart_products) AS cp
LEFT JOIN UNNEST(cp.option) AS opt
WHERE collection = 'checkout_success'