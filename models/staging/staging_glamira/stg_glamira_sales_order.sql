WITH t1 AS (
    SELECT
        SAFE_CAST(user_id_db AS INT64) AS user_id_db,
        LOWER(email_address) AS email_address,
        ip,
        FORMAT_DATE('%Y%m%d', DATE(TIMESTAMP_SECONDS(time_stamp))) AS date_id,
        SAFE_CAST(store_id AS INT64) AS store_id,
        SAFE_CAST(cp.product_id AS INT64) AS product_id,
        SAFE_CAST(SAFE_CAST(order_id AS FLOAT64) AS INT64) AS order_id,
        PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', local_time) AS order_ts_utc,
        cp.currency,
        REGEXP_REPLACE(cp.price, r'[^\x20-\x7E]', '') AS price,
        SAFE_CAST(cp.amount AS INT64) AS quantity
    FROM {{ source('glamira_raw', 'summary') }}
    CROSS JOIN UNNEST(cart_products) AS cp
    WHERE collection = 'checkout_success'
), t2 AS (
    SELECT
        *,
        CAST(
            CASE 
                WHEN TRIM(price) = '' THEN NULL 
                WHEN REGEXP_CONTAINS(price, r',\d{2}$') 
                    THEN REPLACE(REGEXP_REPLACE(price, r"[.\' ]", ''),',', '.')
                WHEN REGEXP_CONTAINS(price, r'\.\d{2}$') 
                    THEN REGEXP_REPLACE(price, r"[,\']", '')
            END
        AS NUMERIC) AS price_num
    FROM t1
), customer_per_order AS (
    SELECT
        order_id,
        user_id_db,
        email_address,
        ip,
        store_id,
        date_id,
        order_ts_utc,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY order_ts_utc
        ) AS rn
    FROM t2
), order_customer AS (
    SELECT
        order_id,
        user_id_db,
        email_address,
        ip,
        store_id,
        date_id,
        order_ts_utc
    FROM customer_per_order
    WHERE rn = 1
), order_product AS (
    SELECT
        order_id,
        product_id,
        currency,
        SUM(quantity) AS quantity,
        SUM(COALESCE(price_num, 0) * quantity) AS revenue,
        SUM(COALESCE(price_num, 0) * quantity) / SUM(quantity) AS price
    FROM t2
    GROUP BY
        order_id,
        product_id,
        currency
)
SELECT
    oc.user_id_db,
    oc.email_address,
    oc.ip,
    oc.date_id,
    oc.store_id,
    oc.order_id,
    oc.order_ts_utc,
    op.product_id,
    op.currency,
    op.price,
    op.quantity,
    op.revenue
FROM order_product op
JOIN order_customer oc USING (order_id)
