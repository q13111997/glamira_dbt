WITH t1 AS (
    SELECT
        SAFE_CAST(user_id_db AS INT64) AS user_id_db
        ,LOWER(email_address) AS email_address
        ,ip
        ,FORMAT_DATE('%Y%m%d',DATE(TIMESTAMP_SECONDS(time_stamp))) AS date_id
        ,CAST(store_id AS INT64) AS store_id
        ,CAST(cp.product_id AS INT64) AS product_id
        ,opt.option_label
        ,opt.value_label
        ,CAST(CAST(order_id AS FLOAT64) AS INT64) AS order_id
        ,PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', local_time) AS order_ts_utc
        ,cp.currency
        ,REGEXP_REPLACE(cp.price, r'[^\x20-\x7E]', '') AS price
        ,CAST(cp.amount AS INT64) AS quantity
    FROM {{ source('glamira_raw', 'summary') }}
    CROSS JOIN UNNEST(cart_products) AS cp
    LEFT JOIN UNNEST(cp.option) AS opt
    WHERE collection = 'checkout_success'
), t2 AS (
    SELECT
        user_id_db
        ,email_address
        ,ip
        ,date_id
        ,store_id
        ,product_id
        ,option_label
        ,value_label
        ,order_id
        ,order_ts_utc
        ,currency
        ,CAST(
            CASE 
                WHEN TRIM(price) = '' THEN NULL 
                WHEN REGEXP_CONTAINS(price, r',\d{2}$') 
                    THEN REPLACE(REGEXP_REPLACE(price, r"[.\' ]", ''),',', '.')
                WHEN REGEXP_CONTAINS(price, r'\.\d{2}$') 
                    THEN REGEXP_REPLACE(price, r"[,\']", '')
            END
        AS NUMERIC) AS price
        ,quantity
    FROM t1
)
SELECT
    user_id_db
    ,email_address
    ,ip
    ,date_id
    ,store_id
    ,product_id
    ,option_label
    ,value_label
    ,order_id
    ,order_ts_utc
    ,currency
    ,price
    ,quantity
    ,COALESCE(price,0) * COALESCE(quantity,0) AS revenue
FROM t2