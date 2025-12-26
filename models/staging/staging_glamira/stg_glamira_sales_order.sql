SELECT
    user_id_db
    ,email_address
    ,ip
    ,CAST(FORMAT_DATE('%Y%m%d',DATE(TIMESTAMP_SECONDS(time_stamp))) AS INT64) AS date_id
    ,store_id
    ,cp.product_id
    ,opt.option_label
    ,opt.value_label
    ,order_id
    ,local_time AS order_ts_utc
    ,cp.currency
    ,CAST(cp.price AS NUMERIC) AS price
    ,CAST(cp.amount AS NUMERIC) AS quantity
    ,CAST(cp.price AS NUMERIC) * CAST(cp.amount AS NUMERIC) AS revenue
FROM {{ source('glamira_raw', 'summary') }}
CROSS JOIN UNNEST(cart_products) AS cp
LEFT JOIN UNNEST(cp.option) AS opt
WHERE collection = 'checkout_success'