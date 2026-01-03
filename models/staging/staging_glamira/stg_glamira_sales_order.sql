WITH t1 AS (
    SELECT
        SAFE_CAST(user_id_db AS INT64) AS user_id_db
        ,LOWER(email_address) AS email_address
        ,ip
        ,FORMAT_DATE('%Y%m%d', DATE(TIMESTAMP_SECONDS(time_stamp))) AS date_id
        ,SAFE_CAST(store_id AS INT64) AS store_id
        ,SAFE_CAST(cp.product_id AS INT64) AS product_id
        ,SAFE_CAST(SAFE_CAST(order_id AS FLOAT64) AS INT64) AS order_id
        ,PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', local_time) AS order_ts_utc
        ,CASE TRIM(REGEXP_REPLACE(cp.currency, CONCAT('[', CHR(8206), CHR(8207), CHR(1564), ']'), ''))
            WHEN '€' THEN 'EUR'
            WHEN '£' THEN 'GBP'
            WHEN 'CHF' THEN 'CHF'
            WHEN 'kr' THEN 'SEK'
            WHEN '₺' THEN 'TRY'
            WHEN '￥' THEN 'JPY'
            WHEN 'R$' THEN 'BRL'
            WHEN 'AU $' THEN 'AUD'
            WHEN 'SGD $' THEN 'SGD'
            WHEN 'CAD $' THEN 'CAD'
            WHEN '$' THEN 'USD'
            WHEN 'Kč' THEN 'CZK'
            WHEN 'Ft' THEN 'HUF'
            WHEN 'HKD $' THEN 'HKD'
            WHEN 'zł' THEN 'PLN'
            WHEN 'din.' THEN 'RSD'
            WHEN '₫' THEN 'VND'
            WHEN 'kn' THEN 'HRK'
            WHEN 'NZD $' THEN 'NZD'
            WHEN 'MXN $' THEN 'MXN'
            WHEN '₹' THEN 'INR'
            WHEN 'лв.' THEN 'BGN'
            WHEN 'BOB Bs' THEN 'BOB'
            WHEN 'COP $' THEN 'COP'
            WHEN 'CRC ₡' THEN 'CRC'
            WHEN 'USD $' THEN 'USD'
            WHEN 'GTQ Q' THEN 'GTQ'
            WHEN 'PEN S/.' THEN 'PEN'
            WHEN 'DOP $' THEN 'DOP'
            WHEN 'CLP' THEN 'CLP'
            WHEN '₱' THEN 'PHP'
            WHEN 'Lei' THEN 'RON'
            WHEN 'UYU' THEN 'UYU'
            WHEN '₲' THEN 'PYG'
            WHEN 'د.ك.' THEN 'KWD'
            WHEN '' THEN 'USD'
            ELSE COALESCE(cp.currency,'USD')
        END AS currency_code
        ,REGEXP_REPLACE(cp.price, r'[^\x20-\x7E]', '') AS unit_price
        ,SAFE_CAST(cp.amount AS INT64) AS quantity
    FROM {{ source('glamira_raw', 'summary') }}
    CROSS JOIN UNNEST(cart_products) AS cp
    WHERE collection = 'checkout_success'
), 
-- Chuẩn hóa dấu ngăn cách thập phân ở cột unit_price
t2 AS (
    SELECT
        t1.user_id_db
        ,t1.email_address
        ,t1.ip
        ,t1.date_id
        ,t1.store_id
        ,t1.product_id
        ,t1.order_id
        ,t1.order_ts_utc
        ,t1.currency_code
        ,t1.unit_price
        ,t1.quantity
        ,SAFE_CAST(
            CASE 
                WHEN TRIM(t1.unit_price) = '' THEN NULL 
                WHEN REGEXP_CONTAINS(unit_price, r',\d{2}$') THEN REPLACE(REGEXP_REPLACE(t1.unit_price, r"[.\' ]", ''),',', '.')
                WHEN REGEXP_CONTAINS(t1.unit_price, r'\.\d{2}$') THEN REGEXP_REPLACE(t1.unit_price, r"[,\']", '')
            END
        AS NUMERIC) AS unit_price_num
        ,rate.rate_to_usd
    FROM t1
    LEFT JOIN {{ ref ('dim_fx_rate')}} rate ON t1.currency_code = rate.currency_code
), 
-- Đánh số khách hàng trong cùng 1 đơn hàng (xử lý lỗi dữ liệu 1 đơn hàng thuộc về nhiều khách hàng)
customer_per_order AS (
    SELECT
        order_id
        ,user_id_db
        ,email_address
        ,ip
        ,store_id
        ,date_id
        ,order_ts_utc
        ,ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_ts_utc) AS rn
    FROM t2
), 
-- Lấy đơn hàng và mã khách hàng đầu tiên trong đơn hàng
order_customer AS (
    SELECT
        order_id
        ,user_id_db
        ,email_address
        ,ip
        ,store_id
        ,date_id
        ,order_ts_utc
    FROM customer_per_order
    WHERE rn = 1
), 
-- Mỗi sản phẩm trong đơn hàng sẽ được tính tổng số lượng, doanh thu, giá trị trung bình (xử lý trường hợp 1 sản phẩm xuất hiện nhiều lần trong 1 đơn hàng)
order_product AS (
    SELECT
        order_id
        ,product_id
        ,currency_code
        ,SUM(ROUND(COALESCE(unit_price_num,0) * rate_to_usd,2) * quantity) / SUM(quantity) AS unit_price
        ,SUM(quantity) AS quantity
        ,SUM(ROUND(COALESCE(unit_price_num,0) * rate_to_usd,2) * quantity) AS revenue
    FROM t2
    GROUP BY
        order_id
        ,product_id
        ,currency_code
)
-- Join order_customer và order_product để chuẩn hóa khách hàng, sản phẩm trong 1 đơn hàng
SELECT
    oc.user_id_db
    ,COALESCE(oc.email_address,'Unknown') AS email_address
    ,COALESCE(oc.ip,'Unknown') AS ip_address
    ,oc.date_id
    ,oc.store_id
    ,oc.order_id
    ,oc.order_ts_utc
    ,op.product_id
    ,op.currency_code
    ,op.unit_price
    ,op.quantity
    ,op.revenue
FROM order_product op
JOIN order_customer oc USING (order_id)
